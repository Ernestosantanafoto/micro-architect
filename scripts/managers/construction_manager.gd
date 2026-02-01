extends Node

# --- PRECARGAS ---
# Solo God Siphon (atajo tecla 0); el resto usa RECETAS / HUD
var god_siphon_escena = preload("res://scenes/buildings/god_siphon.tscn")

# --- ESTADO ---
var fantasma = null
var posicion_valida_actual = false
var nombre_item_en_mano: String = ""

func _process(_delta):
	if fantasma:
		actualizar_fantasma()

# --- LÓGICA DE SELECCIÓN ---
func seleccionar_para_construir(escena: PackedScene, nombre_item: String):
	# Si ya teníamos algo en la mano, lo devolvemos primero
	cancelar_construccion_y_guardar()
	
	# Verificar stock (excepto en modo debug o GodSiphon)
	var es_debug = (nombre_item == "GodSiphon") or GameConstants.DEBUG_MODE
	if not es_debug:
		if GlobalInventory.get_amount(nombre_item) <= 0:
			print("[CM] Sin stock de: ", nombre_item)
			return 

	# Consumir del inventario
	if not es_debug:
		GlobalInventory.consume_item(nombre_item, 1)

	nombre_item_en_mano = nombre_item
	fantasma = escena.instantiate()
	get_parent().add_child(fantasma)
	
	# Desactivar funciones activas mientras es fantasma
	if fantasma.has_method("desconectar_sifon"):
		fantasma.desconectar_sifon()
	
	_preparar_fantasma_visual()

# --- CONFIRMACIÓN Y COLOCACIÓN ---
func confirmar_colocacion():
	if not fantasma: return
	
	_limpiar_materiales_fantasma(fantasma)
	
	# Activar el edificio
	if fantasma.has_method("check_ground"):
		fantasma.check_ground()
	
	# Registrar en GridManager
	var map = get_parent().get_node_or_null("GridMap")
	if map and GridManager:
		var celda = map.local_to_map(fantasma.global_position)
		var pos_2d = Vector2i(celda.x, celda.z)
		GridManager.register_building(pos_2d, fantasma)
	
	# PERSISTENCIA: Registrar el estado inicial en el diccionario global
	if fantasma.has_method("_actualizar_mi_estado_global"):
		fantasma._actualizar_mi_estado_global()
		
	fantasma.scale = Vector3.ONE
	fantasma = null
	nombre_item_en_mano = ""
	print("[CM] Edificio colocado con éxito.")

# --- INTERACCIÓN CON EL MUNDO (CLIC IZQUIERDO) ---
func gestionar_clic_izquierdo():
	var res = _lanzar_raycast_a_edificios()
	if not res: return
	
	var edificio = res.collider
	
	# Desregistrar de GridManager
	var map = get_parent().get_node_or_null("GridMap")
	if map and GridManager:
		var celda = map.local_to_map(edificio.global_position)
		var pos_2d = Vector2i(celda.x, celda.z)
		GridManager.unregister_building(pos_2d)
	
	# Eliminamos la apertura de menú de aquí para que solo sea para recoger
	nombre_item_en_mano = _identificar_item_por_ruta(edificio.scene_file_path)
	
	if map:
		GlobalInventory.borrar_estado(map.local_to_map(edificio.global_position))
	
	fantasma = edificio
	_preparar_fantasma_visual()

# --- GESTIÓN DE INVENTARIO Y FANTASMA ---
func devolver_a_inventario():
	if fantasma:
		if nombre_item_en_mano != "":
			GlobalInventory.refund_item(nombre_item_en_mano, 1)
			print("[CM] Devolución exitosa: ", nombre_item_en_mano)
		else:
			print("[CM] Aviso: Item desconocido, no se sumó al inventario.")
		
		fantasma.queue_free()
		fantasma = null
		nombre_item_en_mano = ""
		posicion_valida_actual = false

func destruir_item_en_mano():
	if fantasma:
		print("[CM] Item eliminado permanentemente.")
		fantasma.queue_free()
		fantasma = null
		nombre_item_en_mano = ""
		posicion_valida_actual = false

func cancelar_construccion_y_guardar():
	# Si es un fantasma nuevo (sacado del inventario), lo devolvemos
	devolver_a_inventario()

# --- PROCESO DE ACTUALIZACIÓN VISUAL ---
func actualizar_fantasma():
	var cam = get_viewport().get_camera_3d()
	var mouse = get_viewport().get_mouse_position()
	var pos_mundo = Plane(Vector3.UP, 0).intersects_ray(cam.project_ray_origin(mouse), cam.project_ray_normal(mouse))
	var map = get_parent().get_node_or_null("GridMap")
	
	if pos_mundo and map:
		var map_pos = map.local_to_map(pos_mundo)
		fantasma.global_position = map.map_to_local(map_pos)
		fantasma.global_position.y = 0.5 # Altura visual de construcción
		
		# Validación 1: ¿Es el suelo correcto?
		var id_tile = map.get_cell_item(map_pos)
		var suelo_ok = true
		if fantasma.has_method("es_suelo_valido"):
			suelo_ok = fantasma.es_suelo_valido(id_tile)
		
		# Validación 2: ¿Está el hueco libre? (GridManager o fallback a PlacementLogic)
		var ocupado = false
		var pos_2d = Vector2i(map_pos.x, map_pos.z)
		var radio = fantasma.get("radio_ocupacion") if fantasma.get("radio_ocupacion") != null else 0
		if GridManager:
			ocupado = GridManager.hay_edificio_en_radio(pos_2d, radio)
		else:
			var espacio = get_parent().get_world_3d().direct_space_state
			ocupado = PlacementLogic.esta_celda_ocupada(fantasma.global_position, espacio, fantasma, radio)
		
		posicion_valida_actual = suelo_ok and not ocupado
		_aplicar_color_validacion(posicion_valida_actual)

func _aplicar_color_validacion(valido):
	var c = Color(0.4, 0.6, 1.0, 0.5) if valido else Color(1.0, 0.2, 0.2, 0.5)
	for m in fantasma.find_children("*", "GeometryInstance3D", true):
		var mat = StandardMaterial3D.new()
		mat.albedo_color = c
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		m.material_override = mat

func _limpiar_materiales_fantasma(nodo):
	for m in nodo.find_children("*", "GeometryInstance3D", true):
		m.material_override = null

func _preparar_fantasma_visual():
	if fantasma.has_method("desconectar_sifon"): 
		fantasma.desconectar_sifon()
	fantasma.scale = Vector3.ONE * 1.2 # Efecto de "levantado"

# --- HELPERS ---
func _identificar_item_por_ruta(ruta_archivo: String) -> String:
	if "god_siphon" in ruta_archivo.to_lower(): return "GodSiphon"
	for nombre in GameConstants.RECETAS:
		if GameConstants.RECETAS[nombre]["output_scene"] == ruta_archivo:
			return nombre
	return ""

func _lanzar_raycast_a_edificios():
	var cam = get_viewport().get_camera_3d()
	var mouse = get_viewport().get_mouse_position()
	var from = cam.project_ray_origin(mouse)
	var to = from + cam.project_ray_normal(mouse) * 1000.0
	var query = PhysicsRayQueryParameters3D.create(from, to, GameConstants.LAYER_EDIFICIOS)
	query.collide_with_areas = true
	return get_parent().get_world_3d().direct_space_state.intersect_ray(query)

# --- INPUTS ---
# Procesar clic derecho ANTES de que lo capture el FondoDetector de los menús
func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		if not fantasma and _procesar_clic_derecho_con_ui_abierta():
			get_viewport().set_input_as_handled()

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if fantasma:
				if posicion_valida_actual: confirmar_colocacion()
			else:
				gestionar_clic_izquierdo()
		
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			if fantasma:
				fantasma.rotate_y(deg_to_rad(-90))
			else:
				if _procesar_clic_derecho_con_ui_abierta():
					return
				_intentar_rotar_edificio_suelo()
				
func _procesar_clic_derecho_con_ui_abierta() -> bool:
	var alguno_visible = false
	for n in get_tree().get_nodes_in_group("UIsEdificios"):
		if n.visible:
			alguno_visible = true
			break
	if not alguno_visible:
		return false
	var res = _lanzar_raycast_a_edificios()
	if res:
		var edificio = res.collider
		if edificio.is_in_group("AbreUIClicDerecho") and edificio.has_method("abrir_ui"):
			edificio.abrir_ui()
			return true
	for n in get_tree().get_nodes_in_group("UIsEdificios"):
		if n.has_method("cerrar") and n.visible:
			n.cerrar()
	return true

func _intentar_rotar_edificio_suelo():
	var res = _lanzar_raycast_a_edificios()
	if res:
		var edificio = res.collider
		if edificio.is_in_group("AbreUIClicDerecho"):
			return
		edificio.rotate_y(deg_to_rad(-90))
		if edificio.has_method("_actualizar_mi_estado_global"):
			edificio._actualizar_mi_estado_global()
		print("[CM] Edificio rotado en suelo.")
