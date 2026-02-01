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
	
	# Registrar en GridManager (todas las celdas del footprint si es multi-celda)
	var map = get_parent().get_node_or_null("GridMap")
	if map and GridManager:
		var celda = map.local_to_map(fantasma.global_position)
		var pos_2d = Vector2i(celda.x, celda.z)
		if fantasma.has_method("get_footprint_offsets"):
			for off in fantasma.get_footprint_offsets():
				GridManager.register_building(pos_2d + off, fantasma)
		else:
			GridManager.register_building(pos_2d, fantasma)
	
	# PERSISTENCIA: Registrar el estado inicial en el diccionario global
	if fantasma.has_method("_actualizar_mi_estado_global"):
		fantasma._actualizar_mi_estado_global()
	
	# Feedback visual: pequeño "pop" al colocar (scale 1.2 → 1.08 → 1.0)
	var edificio = fantasma
	fantasma = null
	nombre_item_en_mano = ""
	if is_instance_valid(edificio):
		edificio.scale = Vector3.ONE * 1.2
		var t = edificio.create_tween()
		t.tween_property(edificio, "scale", Vector3(1.08, 1.08, 1.08), 0.06)
		t.tween_property(edificio, "scale", Vector3.ONE, 0.18).set_trans(Tween.TRANS_BACK)
	print("[CM] Edificio colocado con éxito.")

# --- INTERACCIÓN CON EL MUNDO (CLIC IZQUIERDO) ---
func gestionar_clic_izquierdo():
	var res = _lanzar_raycast_a_edificios()
	if not res: return
	
	var edificio = res.collider
	
	# Desregistrar de GridManager (todas las celdas si es multi-celda como el merger)
	if GridManager:
		GridManager.unregister_building_all(edificio)
	var map = get_parent().get_node_or_null("GridMap")
	
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
	
	if not pos_mundo or not map:
		return
	
	if pos_mundo and map:
		var map_pos = map.local_to_map(pos_mundo)
		fantasma.global_position = map.map_to_local(map_pos)
		fantasma.global_position.y = 0.5 # Altura visual de construcción
		
		var pos_2d = Vector2i(map_pos.x, map_pos.z)
		var celdas_a_validar: Array[Vector2i] = [pos_2d]
		if fantasma.has_method("get_footprint_offsets"):
			celdas_a_validar.clear()
			for off in fantasma.get_footprint_offsets():
				celdas_a_validar.append(pos_2d + off)
		
		# Validación 1: ¿Es el suelo correcto en todas las celdas?
		var suelo_ok = true
		for cell_2d in celdas_a_validar:
			var map_cell = Vector3i(cell_2d.x, 0, cell_2d.y)
			var id_tile = map.get_cell_item(map_cell)
			if fantasma.has_method("es_suelo_valido"):
				suelo_ok = suelo_ok and fantasma.es_suelo_valido(id_tile)
		
		# Validación 2: ¿Están las celdas libres?
		var ocupado = false
		if GridManager:
			for cell_2d in celdas_a_validar:
				if GridManager.is_cell_occupied(cell_2d):
					ocupado = true
					break
		else:
			var radio = fantasma.get("radio_ocupacion") if fantasma.get("radio_ocupacion") != null else 0
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

func _feedback_colocacion_invalida():
	if not fantasma: return
	var orig = fantasma.global_position
	var t = fantasma.create_tween()
	t.tween_property(fantasma, "global_position", orig + Vector3(0.08, 0, 0.08), 0.03)
	t.tween_property(fantasma, "global_position", orig + Vector3(-0.08, 0, -0.08), 0.03)
	t.tween_property(fantasma, "global_position", orig + Vector3(0.04, 0, 0.04), 0.03)
	t.tween_property(fantasma, "global_position", orig, 0.03)

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
				if posicion_valida_actual:
					confirmar_colocacion()
				else:
					_feedback_colocacion_invalida()
			else:
				gestionar_clic_izquierdo()
		
		elif event.button_index == MOUSE_BUTTON_MIDDLE:
			var res = _lanzar_raycast_a_edificios()
			if res:
				# Clic central en edificio puesto: obtener uno igual en mano con la misma orientación
				var edificio = res.collider
				var nombre = _identificar_item_por_ruta(edificio.scene_file_path)
				if nombre == "":
					pass
				elif nombre == "GodSiphon" and GameConstants.DEBUG_MODE:
					seleccionar_para_construir(god_siphon_escena, "GodSiphon")
					if fantasma:
						fantasma.rotation.y = edificio.rotation.y
				elif GlobalInventory.get_amount(nombre) > 0:
					var receta = GameConstants.RECETAS.get(nombre)
					if receta and receta.has("output_scene"):
						var escena = load(receta["output_scene"])
						if escena:
							seleccionar_para_construir(escena, nombre)
							if fantasma:
								fantasma.rotation.y = edificio.rotation.y
			else:
				# Sin edificio bajo el cursor: colocar el que tengo en mano y quedarse con otro (si hay en inventario)
				if fantasma and posicion_valida_actual:
					var nombre = nombre_item_en_mano
					var rot_y = fantasma.rotation.y
					var escena: PackedScene = null
					if nombre == "GodSiphon":
						escena = god_siphon_escena
					elif GameConstants.RECETAS.has(nombre):
						escena = load(GameConstants.RECETAS[nombre]["output_scene"]) as PackedScene
					if escena:
						confirmar_colocacion()
						if (nombre == "GodSiphon" and GameConstants.DEBUG_MODE) or GlobalInventory.get_amount(nombre) > 0:
							seleccionar_para_construir(escena, nombre)
							if fantasma:
								fantasma.rotation.y = rot_y
		
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
