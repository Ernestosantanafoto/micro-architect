extends Node

@export var playlist : Array[AudioStream] = [] 
var current_track_index : int = -1
var muted : bool = false

@onready var p1 = $MusicPlayer1
@onready var p2 = $MusicPlayer2
var players : Array = []
var active_player : int = 0

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS 
	players = [p1, p2]
	_load_mute_from_config()
	await get_tree().process_frame
	if playlist.size() > 0:
		play_random_song()
	_apply_mute()

func toggle_muted() -> void:
	muted = not muted
	_apply_mute()
	_save_mute_to_config()

func is_muted() -> bool:
	return muted

func _load_mute_from_config() -> void:
	var cfg = ConfigFile.new()
	if cfg.load(GameConstants.PREFERENCIAS_PATH) == OK:
		muted = cfg.get_value(GameConstants.PREF_SECTION_AUDIO, GameConstants.PREF_KEY_MUTE, false)

func _save_mute_to_config() -> void:
	var cfg = ConfigFile.new()
	var _err = cfg.load(GameConstants.PREFERENCIAS_PATH)
	cfg.set_value(GameConstants.PREF_SECTION_AUDIO, GameConstants.PREF_KEY_MUTE, muted)
	cfg.save(GameConstants.PREFERENCIAS_PATH)

func _apply_mute() -> void:
	for i in players.size():
		if muted:
			players[i].volume_db = -80.0
		else:
			players[i].volume_db = 0.0 if (i == active_player) else -80.0

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
	
	var t = create_tween().set_parallel(true)
	t.tween_property(p_old, "volume_db", -80, 3.0) 
	t.tween_property(p_new, "volume_db", 0.0, 3.0) 
	
	await t.finished
	p_old.stop()
	active_player = next_player_idx
	_apply_mute()
	
	if not p_new.finished.is_connected(play_random_song):
		p_new.finished.connect(play_random_song, CONNECT_ONE_SHOT)
