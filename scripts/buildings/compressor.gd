extends Area3D

# --- CONFIGURACIÓN ---
@export var grupo_placement: String = "Compresores"  # "CompresoresT2" para T2 (permite vacío o rojo)
@onready var ui_root = $UI_Root
@onready var barra_visual = %BarraVisual
@onready var label_texto = %TextoCantidad

# --- COMPONENTES ---
var beam_emitter: BeamEmitter

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

func recibir_energia_numerica(cantidad: int, tipo_recurso: String, _origen: Node = null) -> void:
	if not esta_construido or cargando: return
	if tipo_recurso.begins_with(GameConstants.PREFIJO_COMPRIMIDO):
		return
	recurso_actual = tipo_recurso
	buffer += cantidad
	if buffer >= 10:
		iniciar_secuencia_carga()
	_actualizar_mi_estado_global()
	actualizar_interfaz()

func _on_area_entered(area):
	if not esta_construido or cargando: return
	if area.is_in_group("Pulsos"):
		if not area.tipo_recurso.begins_with(GameConstants.PREFIJO_COMPRIMIDO):
			recibir_energia_numerica(area.cantidad_energia, area.tipo_recurso)
			area.queue_free()

func iniciar_secuencia_carga():
	buffer -= 10
	cargando = true
	tiempo_restante_carga = GameConstants.COMPRESOR_TIEMPO_CARGA

func disparar_comprimido():
	var scene = GameConstants.get_scene_root_for(self)
	var map = scene.find_child("GridMap") if scene else null
	var space = get_world_3d().direct_space_state
	var dir = -global_transform.basis.z
	var dir_flat = Vector3(dir.x, 0, dir.z).normalized()
	var longitud = GameConstants.HAZ_LONGITUD_MAXIMA
	var tipo_comprimido = GameConstants.PREFIJO_COMPRIMIDO + recurso_actual
	var color = GameConstants.COLOR_STABILITY if "Stability" in recurso_actual else GameConstants.COLOR_CHARGE
	var from_pos = global_position + Vector3(0, 0.5, 0)
	
	if map and space and EnergyManager:
		# Solo crear pulso/flujo si hay haz activo (mismo criterio que el beam)
		if PulseValidator and not PulseValidator.haces_activos.has(self):
			pass
		else:
			var resultado = beam_emitter.obtener_objetivo(global_position, dir, longitud, map, space, self)
			var to_pos = resultado["impact_pos"] if resultado else from_pos + dir_flat * longitud
			if EnergyManager.MOSTRAR_VISUAL_PULSO:
				EnergyManager.spawn_pulse_visual(from_pos, to_pos, color, self, tipo_comprimido)
			if resultado:
				EnergyManager.register_flow(self, resultado["target"], GameConstants.ENERGIA_COMPRIMIDA, tipo_comprimido, color)
		# Contabilizar producción en inventario global para desbloqueos (F2)
		if GlobalInventory:
			GlobalInventory.add_item(tipo_comprimido, 1)
	
	cargando = false
	buffer = 0
	_actualizar_mi_estado_global()
	actualizar_interfaz()

func _gestionar_haz(longitud):
	var scene = GameConstants.get_scene_root_for(self)
	var map = scene.find_child("GridMap") if scene else null
	var space = get_world_3d().direct_space_state
	if map:
		var dir = -global_transform.basis.z
		var color = Color.WHITE
		if recurso_actual != "":
			color = GameConstants.COLOR_STABILITY if "Stability" in recurso_actual else GameConstants.COLOR_CHARGE
		beam_emitter.dibujar_haz(global_position, dir, longitud, color, map, space)
		if esta_construido:
			if PulseValidator: PulseValidator.registrar_haz_activo(self)
		else:
			if PulseValidator: PulseValidator.desregistrar_haz_activo(self)
			if EnergyManager: EnergyManager.remove_flows_from_source(self)

func actualizar_interfaz():
	if label_texto:
		label_texto.text = "%.1f" % tiempo_restante_carga if cargando else str(buffer)+"/10"
		var color_ui = GameConstants.COLOR_STABILITY if ("Stability" in recurso_actual or recurso_actual.is_empty()) else GameConstants.COLOR_CHARGE
		label_texto.modulate = color_ui
	if barra_visual:
		var progreso: float
		if cargando:
			progreso = tiempo_restante_carga / GameConstants.COMPRESOR_TIEMPO_CARGA
		else:
			progreso = buffer / 10.0
		barra_visual.scale.x = clamp(progreso, 0.001, 1.0)
		var mat = barra_visual.get_active_material(0)
		if mat:
			var color_barra = GameConstants.COLOR_STABILITY if ("Stability" in recurso_actual or recurso_actual.is_empty()) else GameConstants.COLOR_CHARGE
			mat.albedo_color = color_barra

func check_ground():
	esta_construido = true
	collision_layer = GameConstants.LAYER_EDIFICIOS
	if BuildingManager: BuildingManager.register_building(self)
	_recuperar_estado_guardado()

func desconectar_sifon():
	if BuildingManager: BuildingManager.unregister_building(self)
	collision_layer = 0
	esta_construido = false
	cargando = false
	buffer = 0

func es_suelo_valido(id):
	return PlacementLogic.es_posicion_valida(grupo_placement, id)

func _actualizar_mi_estado_global():
	var scene = GameConstants.get_scene_root_for(self)
	var map = scene.find_child("GridMap") if scene else null
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
