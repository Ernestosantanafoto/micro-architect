extends Area3D

@export var ticks_disparo: int = GameConstants.SIFON_TICKS_POR_DISPARO
@export var energia_por_disparo: int = 1
@export var brillo_intensidad: float = GameConstants.SIFON_BRILLO_CARA
@export var es_tier2: bool = false

var recurso_actual = ""
var color_recurso = Color.WHITE
var contador_ticks = 0
var esta_construido: bool = false

var beam_emitter: BeamEmitter

func _ready():
	beam_emitter = BeamEmitter.new()
	add_child(beam_emitter)
	
	# Conectarse al reloj global - usar call_deferred para asegurar que main existe
	call_deferred("_conectar_game_tick")
	
	# Configurar según tier
	if es_tier2:
		ticks_disparo = GameConstants.SIFON_T2_TICKS
		energia_por_disparo = GameConstants.SIFON_T2_ENERGIA
		brillo_intensidad = GameConstants.SIFON_T2_BRILLO
	
	collision_layer = 0
	collision_mask = 0
	desconectar_sifon()

func _conectar_game_tick():
	var main = get_tree().current_scene
	if main and main.has_signal("game_tick"):
		if not main.game_tick.is_connected(_on_game_tick):
			main.game_tick.connect(_on_game_tick)
			if GameConstants.DEBUG_MODE: print("[SIFON] Conectado a game_tick")

func _process(_delta):
	var longitud = 0
	
	if not esta_construido:
		_detectar_recurso_bajo_pies()
		if recurso_actual != "": 
			longitud = GameConstants.HAZ_LONGITUD_PREVIEW
		else: 
			beam_emitter.apagar()
			return
	else:
		if recurso_actual != "":
			longitud = GameConstants.HAZ_LONGITUD_MAXIMA
			if PulseValidator: PulseValidator.registrar_haz_activo(self)
		else:
			beam_emitter.apagar()
			if PulseValidator: PulseValidator.desregistrar_haz_activo(self)
			return

	if longitud > 0:
		var map = get_tree().current_scene.find_child("GridMap")
		var space = get_world_3d().direct_space_state
		if map:
			var dir = -global_transform.basis.z
			beam_emitter.dibujar_haz(global_position, dir, longitud, color_recurso, map, space)

func _on_game_tick(_c):
	if esta_construido and recurso_actual != "":
		contador_ticks += 1
		if contador_ticks >= ticks_disparo:
			disparar()
			contador_ticks = 0

func disparar():
	var map = get_tree().current_scene.find_child("GridMap")
	var space = get_world_3d().direct_space_state
	if not map or not space or not EnergyManager:
		return
	var dir = -global_transform.basis.z
	var dir_flat = Vector3(dir.x, 0, dir.z).normalized()
	var longitud = GameConstants.HAZ_LONGITUD_MAXIMA
	var resultado = beam_emitter.obtener_objetivo(global_position, dir, longitud, map, space, self)
	var from_pos = global_position + Vector3(0, GameConstants.SIFON_OFFSET_SALIDA_Y, 0)
	var to_pos = resultado["impact_pos"] if resultado else from_pos + dir_flat * longitud
	if EnergyManager.MOSTRAR_VISUAL_PULSO:
		EnergyManager.spawn_pulse_visual(from_pos, to_pos, color_recurso, self, recurso_actual)
	if resultado:
		EnergyManager.register_flow(self, resultado["target"], energia_por_disparo, recurso_actual, color_recurso)

func _detectar_recurso_bajo_pies():
	var map = get_tree().current_scene.find_child("GridMap")
	if not map: return
	
	var id = map.get_cell_item(map.local_to_map(global_position))
	
	if id == GameConstants.TILE_ESTABILIDAD:
		recurso_actual = GameConstants.RECURSO_STABILITY
		color_recurso = GameConstants.COLOR_STABILITY
	elif id == GameConstants.TILE_CARGA:
		recurso_actual = GameConstants.RECURSO_CHARGE
		color_recurso = GameConstants.COLOR_CHARGE
	else:
		recurso_actual = ""
		color_recurso = Color.WHITE

func check_ground():
	_detectar_recurso_bajo_pies()
	
	# Siempre activar aunque no haya recurso (para que se pueda recoger/rotar)
	collision_layer = GameConstants.LAYER_EDIFICIOS
	esta_construido = true
	if BuildingManager: BuildingManager.register_building(self)
	
	# Reconectar al game_tick por si acaso
	_conectar_game_tick()
	
	if recurso_actual != "":
		_actualizar_cara_visual()
		if GameConstants.DEBUG_MODE: print("[SIFON] Activado sobre: ", recurso_actual)
	else:
		if GameConstants.DEBUG_MODE: print("[SIFON] Activado pero sin recurso debajo")

func desconectar_sifon():
	collision_layer = 0
	esta_construido = false
	contador_ticks = 0
	if BuildingManager: BuildingManager.unregister_building(self)
	if beam_emitter: beam_emitter.apagar()
	if PulseValidator: PulseValidator.desregistrar_haz_activo(self)
	_actualizar_cara_visual()

func _actualizar_cara_visual():
	var cara = find_child("CaraEmisora")
	if cara:
		var mat = StandardMaterial3D.new()
		mat.albedo_color = color_recurso
		mat.emission_enabled = recurso_actual != ""
		mat.emission = color_recurso
		mat.emission_energy_multiplier = brillo_intensidad
		cara.set_surface_override_material(0, mat)

func es_suelo_valido(id):
	return PlacementLogic.es_posicion_valida("Sifones", id)

func recibir_luz_instantanea(_c, _r, _d): 
	pass
