extends Node

const SAVE_PATH = "user://vaciado_save.json"

func guardar_partida():
	print("[SAVE] Iniciando guardado...")
	
	var lista_edificios = []
	
	# MÉTODO CORRECTO: Buscar todos los edificios por grupos
	# Los edificios están en grupos como "Sifones", "Prismas", "Compresores", etc.
	var grupos_edificios = [
		"Sifones", "Prismas", "Compresores", "CompresoresT2",
		"Fusionadores", "Constructores", "VoidGenerators"
	]
	
	# También buscar por el layer de colisión de edificios
	var edificios_encontrados = []
	
	# Buscar todos los Area3D que estén en la capa de edificios
	var raiz = get_tree().current_scene
	if raiz:
		_buscar_edificios_recursivo(raiz, edificios_encontrados)
	
	print("[SAVE] Edificios encontrados: ", edificios_encontrados.size())
	
	for edificio in edificios_encontrados:
		# Verificar que esté construido (no sea fantasma)
		var esta_construido = true
		if edificio.get("esta_construido") != null:
			esta_construido = edificio.esta_construido
		
		if not esta_construido:
			continue
		
		# Obtener datos del edificio
		var datos_edificio = {
			"scene": edificio.scene_file_path,
			"pos": {
				"x": edificio.global_position.x,
				"y": edificio.global_position.y,
				"z": edificio.global_position.z
			},
			"rot": {
				"x": edificio.global_rotation.x,
				"y": edificio.global_rotation.y,
				"z": edificio.global_rotation.z
			}
		}
		
		# Guardar estado interno si tiene
		var map = get_tree().get_first_node_in_group("MapaPrincipal")
		if map:
			var celda = map.local_to_map(edificio.global_position)
			var estado = GlobalInventory.obtener_estado(celda)
			if estado.size() > 0:
				datos_edificio["estado"] = estado
		
		lista_edificios.append(datos_edificio)
		print("[SAVE] - ", edificio.name, " en ", edificio.global_position)
	
	# Obtener datos de cámara
	var cam_pivot = get_tree().current_scene.find_child("CameraPivot", true, false)
	var c_pos = Vector3.ZERO
	var c_size = 100.0
	if cam_pivot:
		c_pos = cam_pivot.global_position
		var cam_node = cam_pivot.find_child("Camera3D", true, false)
		if cam_node and cam_node.get("size") != null:
			c_size = cam_node.size
	
	# Construir paquete de datos
	var data = {
		"semilla": GlobalInventory.semilla_mundo,
		"stock": GlobalInventory.stock,
		"mundo": lista_edificios,
		"estados_vivos": GlobalInventory.estados_edificios,
		"cam": {
			"x": c_pos.x, 
			"y": c_pos.y, 
			"z": c_pos.z, 
			"s": c_size
		}
	}
	
	# Guardar archivo
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_line(JSON.stringify(data))
		file.close()
		print("[SAVE] ¡Guardado exitoso! ", lista_edificios.size(), " edificios.")
	else:
		print("[SAVE] ERROR: No se pudo abrir el archivo para escritura.")

func _buscar_edificios_recursivo(nodo: Node, lista: Array):
	# Verificar si este nodo es un edificio
	if nodo is Area3D:
		# Verificar si tiene collision_layer de edificios (4) o métodos de edificio
		var es_edificio = false
		
		# Método 1: Por collision_layer
		if nodo.collision_layer == GameConstants.LAYER_EDIFICIOS:
			es_edificio = true
		
		# Método 2: Por tener métodos típicos de edificios
		if nodo.has_method("check_ground") or nodo.has_method("es_suelo_valido"):
			es_edificio = true
		
		# Método 3: Por tener scene_file_path que contenga "buildings"
		if nodo.scene_file_path and "buildings" in nodo.scene_file_path:
			es_edificio = true
		
		if es_edificio and nodo.scene_file_path != "":
			lista.append(nodo)
	
	# Buscar en hijos
	for hijo in nodo.get_children():
		_buscar_edificios_recursivo(hijo, lista)

func cargar_partida() -> bool:
	print("[SAVE] Intentando cargar partida...")
	
	if not FileAccess.file_exists(SAVE_PATH):
		print("[SAVE] No existe archivo de guardado.")
		return false
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		print("[SAVE] ERROR: No se pudo abrir el archivo.")
		return false
	
	var texto = file.get_as_text()
	file.close()
	
	var data = JSON.parse_string(texto)
	if not data:
		print("[SAVE] ERROR: JSON inválido.")
		return false
	
	# Restaurar datos básicos
	GlobalInventory.semilla_mundo = data.get("semilla", 0)
	GlobalInventory.stock = data.get("stock", {})
	
	# Restaurar estados de edificios
	if data.has("estados_vivos"):
		GlobalInventory.estados_edificios = data["estados_vivos"]
	
	# Guardar lista de edificios para reconstruir después del cambio de escena
	if data.has("mundo"):
		GlobalInventory.edificios_para_reconstruir = data["mundo"]
		print("[SAVE] Edificios a reconstruir: ", GlobalInventory.edificios_para_reconstruir.size())
	
	# Guardar datos de cámara
	if data.has("cam"):
		var c = data["cam"]
		GlobalInventory.datos_camara = {
			"pos": Vector3(c.get("x", 0), c.get("y", 0), c.get("z", 0)),
			"size": c.get("s", 100.0)
		}
	
	print("[SAVE] Partida cargada correctamente.")
	return true

# Esta función debe llamarse desde la escena principal después de cargar
func reconstruir_edificios():
	print("[SAVE] Reconstruyendo edificios...")
	
	if GridManager:
		GridManager.limpiar()
	
	var edificios = GlobalInventory.edificios_para_reconstruir
	if edificios.size() == 0:
		print("[SAVE] No hay edificios para reconstruir.")
		return
	
	var raiz = get_tree().current_scene
	
	for datos in edificios:
		var ruta_escena = datos.get("scene", "")
		if ruta_escena == "" or not ResourceLoader.exists(ruta_escena):
			print("[SAVE] ADVERTENCIA: Escena no encontrada: ", ruta_escena)
			continue
		
		var escena = load(ruta_escena)
		var instancia = escena.instantiate()
		raiz.add_child(instancia)
		
		# Posición
		var pos = datos.get("pos", {})
		instancia.global_position = Vector3(
			pos.get("x", 0),
			pos.get("y", 0),
			pos.get("z", 0)
		)
		
		# Rotación
		var rot = datos.get("rot", {})
		instancia.global_rotation = Vector3(
			rot.get("x", 0),
			rot.get("y", 0),
			rot.get("z", 0)
		)
		
		# Restaurar estado interno ANTES de check_ground
		if datos.has("estado"):
			var map = get_tree().get_first_node_in_group("MapaPrincipal")
			if map:
				var celda = map.local_to_map(instancia.global_position)
				GlobalInventory.registrar_estado(celda, datos["estado"])
		
		# Activar el edificio - debe hacerse DESPUÉS de posicionar y rotar
		# Esperamos un frame para que el nodo esté completamente en el árbol
		instancia.set_meta("necesita_activacion", true)
		
		if GameConstants.DEBUG_MODE: print("[SAVE] - Reconstruido: ", instancia.name, " en ", instancia.global_position)
	
	# Limpiar lista
	GlobalInventory.edificios_para_reconstruir = []
	
	# Activar todos los edificios después de un frame
	await get_tree().process_frame
	_activar_edificios_reconstruidos(raiz)
	
	print("[SAVE] Reconstrucción completada.")

## Genera una partida de test con ~100 edificios en tiles válidos. F9 en partida.
func generar_partida_test(cantidad_objetivo: int = 100) -> bool:
	var wg = get_tree().current_scene.find_child("WorldGenerator", true, false)
	var map = get_tree().get_first_node_in_group("MapaPrincipal")
	if not map or not (map is GridMap):
		print("[SAVE] ERROR: No se encontró GridMap.")
		return false
	if wg and wg.has_method("forzar_generar_rango"):
		wg.forzar_generar_rango(-5, 5, -5, 5)
	var celdas_sifon: Array[Vector3i] = []
	var celdas_compresor: Array[Vector3i] = []
	var celdas_compresor_t2: Array[Vector3i] = []
	var celdas_prisma: Array[Vector3i] = []
	var celdas_constructor: Array[Vector3i] = []
	for x in range(-70, 71):
		for z in range(-70, 71):
			var celda = Vector3i(x, 0, z)
			var id_tile = map.get_cell_item(celda)
			if id_tile == GameConstants.TILE_ESTABILIDAD or id_tile == GameConstants.TILE_CARGA:
				celdas_sifon.append(celda)
			elif id_tile == GameConstants.TILE_ROJO:
				celdas_compresor.append(celda)
				celdas_compresor_t2.append(celda)
			elif id_tile == GameConstants.TILE_VACIO or id_tile == -1:
				celdas_prisma.append(celda)
				celdas_compresor_t2.append(celda)
			if id_tile >= 0:
				celdas_constructor.append(celda)
	var lista_edificios: Array = []
	var usado: Dictionary = {}
	var _agregar = func(escena: String, celda: Vector3i) -> bool:
		if usado.has(Vector2i(celda.x, celda.z)) or not ResourceLoader.exists(escena): return false
		_agregar_edificio(lista_edificios, map, escena, celda, usado)
		return true
	var escenas_sifon = ["res://scenes/buildings/siphon_t1.tscn", "res://scenes/buildings/siphon_t2.tscn"]
	var escenas_prisma = ["res://scenes/buildings/prism_straight.tscn", "res://scenes/buildings/prism_angle.tscn", "res://scenes/buildings/prism_straight_t2.tscn", "res://scenes/buildings/prism_angle_t2.tscn"]
	var idx = 0
	for celda in celdas_sifon:
		if lista_edificios.size() >= cantidad_objetivo: break
		_agregar.call(escenas_sifon[idx % 2], celda)
		idx += 1
	for celda in celdas_compresor:
		if lista_edificios.size() >= cantidad_objetivo: break
		_agregar.call("res://scenes/buildings/compressor.tscn", celda)
	for celda in celdas_compresor_t2:
		if lista_edificios.size() >= cantidad_objetivo: break
		_agregar.call("res://scenes/buildings/compressor_t2.tscn", celda)
	idx = 0
	for celda in celdas_prisma:
		if lista_edificios.size() >= cantidad_objetivo: break
		_agregar.call(escenas_prisma[idx % 4], celda)
		idx += 1
	for celda in celdas_prisma:
		if lista_edificios.size() >= cantidad_objetivo: break
		_agregar.call("res://scenes/buildings/merger.tscn", celda)
	for celda in celdas_constructor:
		if lista_edificios.size() >= cantidad_objetivo: break
		_agregar.call("res://scenes/buildings/constructor.tscn", celda)
	var stock_test = {
		"Stability": 500, "Charge": 500,
		"Sifón": 100, "Sifón T2": 100, "Prisma Recto": 100, "Prisma Angular": 100,
		"Prisma Recto T2": 100, "Prisma Angular T2": 100, "Compresor": 100, "Compresor T2": 100,
		"Fusionador": 100, "Constructor": 100, "GodSiphon": 10, "Void Generator": 10
	}
	var centro_x = 0.0
	var centro_z = 0.0
	for d in lista_edificios:
		centro_x += d["pos"]["x"]
		centro_z += d["pos"]["z"]
	if lista_edificios.size() > 0:
		centro_x /= lista_edificios.size()
		centro_z /= lista_edificios.size()
	var data = {
		"semilla": GlobalInventory.semilla_mundo if GlobalInventory.semilla_mundo != 0 else randi(),
		"stock": stock_test,
		"mundo": lista_edificios,
		"estados_vivos": {},
		"cam": {"x": centro_x, "y": 0, "z": centro_z, "s": 100.0}
	}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if not file:
		print("[SAVE] ERROR al escribir partida test.")
		return false
	file.store_line(JSON.stringify(data))
	file.close()
	GlobalInventory.semilla_mundo = data["semilla"]
	GlobalInventory.stock = stock_test
	GlobalInventory.edificios_para_reconstruir = lista_edificios
	GlobalInventory.estados_edificios = {}
	GlobalInventory.datos_camara = {"pos": Vector3(centro_x, 0, centro_z), "size": 100.0}
	print("[SAVE] Partida test generada: ", lista_edificios.size(), " edificios. Recarga o carga desde menú.")
	return true

func _agregar_edificio(lista: Array, map: GridMap, escena: String, celda: Vector3i, usado: Dictionary) -> void:
	if not ResourceLoader.exists(escena): return
	var wpos = map.map_to_local(celda)
	wpos.y = 0.5
	var datos = {
		"scene": escena,
		"pos": {"x": wpos.x, "y": wpos.y, "z": wpos.z},
		"rot": {"x": 0, "y": 0, "z": 0}
	}
	lista.append(datos)
	usado[Vector2i(celda.x, celda.z)] = true

func _activar_edificios_reconstruidos(raiz: Node):
	var edificios = []
	_buscar_edificios_recursivo(raiz, edificios)
	
	var map = get_tree().get_first_node_in_group("MapaPrincipal")
	
	for edificio in edificios:
		if edificio.has_meta("necesita_activacion") and edificio.get_meta("necesita_activacion"):
			edificio.remove_meta("necesita_activacion")
			
			# Forzar activación completa
			if edificio.has_method("check_ground"):
				edificio.check_ground()
			
			# Asegurar que collision_layer está activo
			if edificio.get("collision_layer") != null:
				edificio.collision_layer = GameConstants.LAYER_EDIFICIOS
			
			# Marcar como construido
			if edificio.get("esta_construido") != null:
				edificio.esta_construido = true
			
			# Registrar en GridManager
			if map and GridManager:
				var celda = map.local_to_map(edificio.global_position)
				var pos_2d = Vector2i(celda.x, celda.z)
				GridManager.register_building(pos_2d, edificio)
			
			if GameConstants.DEBUG_MODE: print("[SAVE] Activado: ", edificio.name)
