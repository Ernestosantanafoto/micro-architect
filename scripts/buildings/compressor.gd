extends Area3D

# --- CONFIGURACIÓN ---
@onready var ui_root = $UI_Root
@onready var barra_visual = %BarraVisual
@onready var label_texto = %TextoCantidad

# --- COMPONENTES ---
var beam_emitter: BeamEmitter 
var pulse_scene = preload("res://scenes/world/energy_pulse.tscn")

# --- ESTADO ---
var buffer: int = 0
var recurso_actual: String = ""
var esta_construido: bool = false
var cargando: bool = false
var tiempo_restante_carga: float = 0.0

func _ready():
	beam_emitter = BeamEmitter.new()
	add_child(beam_emitter)
	
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)
	
	# Desacoplar UI
	if ui_root:
		ui_root.set_as_top_level(true)
		ui_root.global_rotation = Vector3.ZERO
	
	actualizar_interfaz()

func _process(delta):
	# 1. ESTABILIZACIÓN UI
	if ui_root and is_instance_valid(ui_root):
		ui_root.global_position = global_position + Vector3(0, GameConstants.COMPRESOR_UI_OFFSET_Y, 0)
		ui_root.global_rotation = Vector3.ZERO
	
	# 2. LÓGICA DE JUEGO
	if not esta_construido:
		_gestionar_haz(GameConstants.HAZ_LONGITUD_PREVIEW)
		return

	if cargando:
		tiempo_restante_carga -= delta
		_actualizar_mi_estado_global()
		actualizar_interfaz()
		if tiempo_restante_carga <= 0: 
			disparar_comprimido()
			
	_gestionar_haz(GameConstants.HAZ_LONGITUD_MAXIMA)

func _on_area_entered(area):
	if not esta_construido or cargando: return
	if area.is_in_group("Pulsos"):
		if not area.tipo_recurso.begins_with(GameConstants.PREFIJO_COMPRIMIDO):
			recurso_actual = area.tipo_recurso
			buffer += area.cantidad_energia
			area.queue_free()
			if buffer >= 10: iniciar_secuencia_carga()
			_actualizar_mi_estado_global()
			actualizar_interfaz()

func iniciar_secuencia_carga():
	buffer -= 10
	cargando = true
	tiempo_restante_carga = GameConstants.COMPRESOR_TIEMPO_CARGA

func disparar_comprimido():
	var p = pulse_scene.instantiate()
	get_tree().current_scene.add_child(p)
	
	var dir = -global_transform.basis.z
	p.global_position = global_position + Vector3(0, 0.5, 0)
	p.direccion = dir
	
	if p.has_method("configurar_pulso"):
		var color = GameConstants.COLOR_STABILITY if "Stability" in recurso_actual else GameConstants.COLOR_CHARGE
		p.configurar_pulso(GameConstants.PREFIJO_COMPRIMIDO + recurso_actual, color, 1.5)
		p.cantidad_energia = 10
	cargando = false
	buffer = 0
	_actualizar_mi_estado_global()
	actualizar_interfaz()

func _gestionar_haz(longitud):
	var map = get_tree().current_scene.find_child("GridMap")
	var space = get_world_3d().direct_space_state
	if map:
		var dir = -global_transform.basis.z
		var color = Color.WHITE
		if recurso_actual != "":
			color = GameConstants.COLOR_STABILITY if "Stability" in recurso_actual else GameConstants.COLOR_CHARGE
		beam_emitter.dibujar_haz(global_position, dir, longitud, color, map, space)

func actualizar_interfaz():
	if label_texto: label_texto.text = "%.1f" % tiempo_restante_carga if cargando else str(buffer)+"/10"
	if barra_visual:
		var progreso = (1.0 - (tiempo_restante_carga/GameConstants.COMPRESOR_TIEMPO_CARGA)) if cargando else (buffer/10.0)
		barra_visual.scale.x = clamp(progreso, 0.001, 1.0)
		var mat = barra_visual.get_active_material(0)
		if mat: mat.albedo_color = Color.ORANGE if cargando else Color.CYAN

func check_ground():
	esta_construido = true
	collision_layer = GameConstants.LAYER_EDIFICIOS
	_recuperar_estado_guardado()

func es_suelo_valido(id):
	return id == GameConstants.TILE_ROJO

func _actualizar_mi_estado_global():
	var map = get_tree().current_scene.find_child("GridMap")
	if map and esta_construido:
		var datos = {"buf": buffer, "rec": recurso_actual, "crg": cargando, "rem": tiempo_restante_carga}
		GlobalInventory.registrar_estado(map.local_to_map(global_position), datos)

func _recuperar_estado_guardado():
	var map = get_tree().get_first_node_in_group("MapaPrincipal")
	if map:
		var e = GlobalInventory.obtener_estado(map.local_to_map(global_position))
		if e.size() > 0:
			buffer = e.get("buf", 0)
			recurso_actual = e.get("rec", "")
			cargando = e.get("crg", false)
			tiempo_restante_carga = e.get("rem", 0.0)
			actualizar_interfaz()

func _exit_tree():
	if ui_root and is_instance_valid(ui_root): ui_root.queue_free()
