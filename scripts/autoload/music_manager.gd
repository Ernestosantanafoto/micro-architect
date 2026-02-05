extends Node

@export var playlist : Array[AudioStream] = [] 
var current_track_index : int = -1
var muted : bool = false
var music_volume : float = 1.0

@onready var p1 = $MusicPlayer1
@onready var p2 = $MusicPlayer2
var players : Array = []
var active_player : int = 0

const BUS_MUSIC := "Music"
const MUFFLE_CUTOFF_MIN := 400.0   # Hz cuando zoom máximo (muy apagado)
const MUFFLE_CUTOFF_MAX := 20000.0 # Hz cuando zoom normal (sin filtro efectivo)
const MUFFLE_VOLUME_MIN := 0.65   # Factor volumen cuando zoom máximo (ligera bajada)

var _zoom_muffle_normalized := 0.0

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS 
	players = [p1, p2]
	_ensure_music_bus()
	_load_mute_from_config()
	_load_volume_from_config()
	# Aplicar volumen/mute antes de cualquier reproducción para evitar glitch al iniciar
	_apply_volume()
	await get_tree().process_frame
	if playlist.size() > 0:
		play_random_song()

func set_volume(val: float) -> void:
	music_volume = clampf(val, 0.0, 1.0)
	_apply_volume()
	_save_volume_to_config()

func get_volume() -> float:
	return music_volume

func toggle_muted() -> void:
	muted = not muted
	_apply_volume()
	_save_mute_to_config()

func is_muted() -> bool:
	return muted

func _ensure_music_bus() -> void:
	var bus_idx = -1
	for i in range(AudioServer.bus_count):
		if AudioServer.get_bus_name(i) == BUS_MUSIC:
			bus_idx = i
			break
	if bus_idx < 0:
		AudioServer.add_bus(AudioServer.bus_count)
		bus_idx = AudioServer.bus_count - 1
		AudioServer.set_bus_name(bus_idx, BUS_MUSIC)
		var lowpass = AudioEffectLowPassFilter.new()
		lowpass.cutoff_hz = MUFFLE_CUTOFF_MAX
		AudioServer.add_bus_effect(bus_idx, lowpass, 0)
	for p in players:
		if p is AudioStreamPlayer:
			p.bus = BUS_MUSIC

func _load_mute_from_config() -> void:
	var cfg = ConfigFile.new()
	if cfg.load(GameConstants.PREFERENCIAS_PATH) == OK:
		muted = cfg.get_value(GameConstants.PREF_SECTION_AUDIO, GameConstants.PREF_KEY_MUTE, false)

func _save_mute_to_config() -> void:
	var cfg = ConfigFile.new()
	var _err = cfg.load(GameConstants.PREFERENCIAS_PATH)
	cfg.set_value(GameConstants.PREF_SECTION_AUDIO, GameConstants.PREF_KEY_MUTE, muted)
	cfg.save(GameConstants.PREFERENCIAS_PATH)

func _load_volume_from_config() -> void:
	var cfg = ConfigFile.new()
	if cfg.load(GameConstants.PREFERENCIAS_PATH) == OK:
		music_volume = clampf(cfg.get_value(GameConstants.PREF_SECTION_AUDIO, GameConstants.PREF_KEY_MUSIC_VOLUME, 1.0), 0.0, 1.0)

func _save_volume_to_config() -> void:
	var cfg = ConfigFile.new()
	var _err = cfg.load(GameConstants.PREFERENCIAS_PATH)
	cfg.set_value(GameConstants.PREF_SECTION_AUDIO, GameConstants.PREF_KEY_MUSIC_VOLUME, music_volume)
	cfg.save(GameConstants.PREFERENCIAS_PATH)

func _volume_to_db() -> float:
	if music_volume <= 0.0:
		return -80.0
	return linear_to_db(music_volume)

func _apply_volume() -> void:
	if muted:
		for i in players.size():
			players[i].volume_db = -80.0
		return
	var base_db := _volume_to_db()
	var vol_mult := 1.0 - _zoom_muffle_normalized * (1.0 - MUFFLE_VOLUME_MIN)
	var linear_base := db_to_linear(base_db) if base_db > -80.0 else 0.0
	var db := linear_to_db(linear_base * vol_mult) if linear_base > 0.0 else -80.0
	for i in players.size():
		players[i].volume_db = db if (i == active_player) else -80.0

## 0 = sin apagar, 1 = máximo apagado (zoom extremo). Afecta low-pass y ligera bajada de volumen.
func set_zoom_muffle(normalized: float) -> void:
	_zoom_muffle_normalized = clampf(normalized, 0.0, 1.0)
	var bus_idx = AudioServer.get_bus_index(BUS_MUSIC)
	if bus_idx >= 0 and AudioServer.get_bus_effect_count(bus_idx) > 0:
		var eff = AudioServer.get_bus_effect(bus_idx, 0)
		if eff is AudioEffectLowPassFilter:
			eff.cutoff_hz = lerpf(MUFFLE_CUTOFF_MAX, MUFFLE_CUTOFF_MIN, _zoom_muffle_normalized)
	if not muted:
		_apply_volume()

func play_random_song():
	var next_index = randi() % playlist.size()
	while next_index == current_track_index and playlist.size() > 1:
		next_index = randi() % playlist.size()
	
	current_track_index = next_index
	_fade_to_track(playlist[current_track_index])

func _fade_to_track(stream: AudioStream):
	var next_player_idx = (active_player + 1) % 2
	var p_old = players[active_player]
	var p_new = players[next_player_idx]
	
	p_new.stream = stream
	p_new.volume_db = -80 
	p_new.play()
	
	var target_db := -80.0 if muted else _volume_to_db()
	var t = create_tween().set_parallel(true)
	t.tween_property(p_old, "volume_db", -80, 3.0) 
	t.tween_property(p_new, "volume_db", target_db, 3.0) 
	
	await t.finished
	p_old.stop()
	active_player = next_player_idx
	_apply_volume()
	
	if not p_new.finished.is_connected(play_random_song):
		p_new.finished.connect(play_random_song, CONNECT_ONE_SHOT)
