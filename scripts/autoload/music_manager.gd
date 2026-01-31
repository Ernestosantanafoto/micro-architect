extends Node

@export var playlist : Array[AudioStream] = [] 
var current_track_index : int = -1

# Estas referencias ahora buscan a los hijos que acabas de crear
@onready var p1 = $MusicPlayer1
@onready var p2 = $MusicPlayer2
@onready var players = [p1, p2]
var active_player = 0

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS 
	# Esperar un frame para asegurar que el playlist no esté vacío
	await get_tree().process_frame
	if playlist.size() > 0:
		play_random_song()

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
	
	# Conectar el final de la canción para poner la siguiente
	if not p_new.finished.is_connected(play_random_song):
		p_new.finished.connect(play_random_song, CONNECT_ONE_SHOT)
