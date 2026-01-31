extends Node

# --- PRECARGAS ---
var sifon_t1_escena = preload("res://scenes/buildings/siphon_t1.tscn")
var sifon_t2_escena = preload("res://scenes/buildings/siphon_t2.tscn")
var prisma_recto_escena = preload("res://scenes/buildings/prism_straight.tscn")
var prisma_recto_t2_escena = preload("res://scenes/buildings/prism_straight_t2.tscn")
var prisma_angulo_escena = preload("res://scenes/buildings/prism_angle.tscn")
var prisma_angulo_t2_escena = preload("res://scenes/buildings/prism_angle_t2.tscn")
var compressor_escena = preload("res://scenes/buildings/compressor.tscn")
var fusionador_escena = preload("res://scenes/buildings/merger.tscn")
var constructor_escena = preload("res://scenes/buildings/constructor.tscn")
var god_siphon_escena = preload("res://scenes/buildings/god_siphon.tscn")
var void_generator_escena = preload("res://scenes/buildings/void_generator.tscn")

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
	
	# Eliminamos la apertura de menú de aquí para que solo sea para recoger
	nombre_item_en_mano = _identificar_item_por_ruta(edificio.scene_file_path)
	
	var map = get_parent().get_node_or_null("GridMap")
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
		
		# Validación 2: ¿Está el hueco libre?
		var espacio = get_parent().get_world_3d().direct_space_state
		var radio = fantasma.get("radio_ocupacion") if fantasma.get("radio_ocupacion") != null else 0
		var ocupado = PlacementLogic.esta_celda_ocupada(fantasma.global_position, espacio, fantasma, radio)
		
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
func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if fantasma:
				if posicion_valida_actual: confirmar_colocacion()
			else:
				gestionar_clic_izquierdo() # Solo para recoger
		
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			if fantasma:
				# Rotar el objeto en mano
				fantasma.rotate_y(deg_to_rad(-90))
			else:
				# NUEVO: Intentar rotar edificio en el suelo
				_intentar_rotar_edificio_suelo()
				
func _intentar_rotar_edificio_suelo():
	var res = _lanzar_raycast_a_edificios()
	if res:
		var edificio = res.collider
		edificio.rotate_y(deg_to_rad(-90))
		if edificio.has_method("_actualizar_mi_estado_global"):
			edificio._actualizar_mi_estado_global()
		print("[CM] Edificio rotado en suelo.")
