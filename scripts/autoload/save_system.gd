extends Node

const NUM_SLOTS := 3
const SAVE_PATH_PATTERN := "user://save_slot_%d.json"

func get_save_path(slot_index: int) -> String:
	return SAVE_PATH_PATTERN % clamp(slot_index, 1, NUM_SLOTS)

## Devuelve info de cada slot: { "slot": 1, "name": "Mi partida", "timestamp": 123 } o name vacío si no hay guardado.
func get_slots_info() -> Array:
	var result: Array = []
	for i in range(1, NUM_SLOTS + 1):
		var path = get_save_path(i)
		var info = { "slot": i, "name": "", "timestamp": 0 }
		if FileAccess.file_exists(path):
			var file = FileAccess.open(path, FileAccess.READ)
			if file:
				var raw = file.get_as_text()
				file.close()
				var data = JSON.parse_string(raw)
				if data:
					info["name"] = data.get("save_name", "")
					info["timestamp"] = data.get("save_timestamp", 0)
		result.append(info)
	return result

func guardar_partida(slot_index: int = 1, custom_name: String = "") -> void:
	slot_index = clamp(slot_index, 1, NUM_SLOTS)
	var path = get_save_path(slot_index)
	_guardar_a_ruta(path, slot_index, custom_name)

func _guardar_a_ruta(path: String, slot_index: int, custom_name: String) -> void:
	print("[SAVE] Iniciando guardado en slot ", slot_index, " -> ", path)
	
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
	var escena_actual = get_tree().current_scene
	var cam_pivot = escena_actual.find_child("CameraPivot", true, false) if escena_actual else null
	var c_pos = Vector3.ZERO
	var c_size = 100.0
	if cam_pivot:
		c_pos = cam_pivot.global_position
		var cam_node = cam_pivot.find_child("Camera3D", true, false)
		if cam_node and cam_node.get("size") != null:
			c_size = cam_node.size
	
	# Guardar estado del mapa (GridMap) para restaurar terreno al cargar
	var lista_mapa: Array = []
	var map = get_tree().get_first_node_in_group("MapaPrincipal")
	if map and map is GridMap:
		for cell in map.get_used_cells():
			var item = map.get_cell_item(cell)
			lista_mapa.append({"x": cell.x, "y": cell.y, "z": cell.z, "item": item})

	# Progreso del árbol tecnológico (F2)
	var tech_data = TechTree.save_progress() if TechTree else {}

	# Nombre y timestamp para el slot
	var save_name = custom_name.strip_edges()
	if save_name.is_empty():
		var slots = get_slots_info()
		for s in slots:
			if s["slot"] == slot_index and not (s["name"] as String).is_empty():
				save_name = s["name"]
				break
		if save_name.is_empty():
			save_name = "Partida %d" % slot_index

	# Construir paquete de datos
	var data = {
		"save_name": save_name,
		"save_timestamp": int(Time.get_unix_time_from_system()),
		"save_slot": slot_index,
		"semilla": GlobalInventory.semilla_mundo,
		"stock": GlobalInventory.stock,
		"mundo": lista_edificios,
		"mapa": lista_mapa,
		"estados_vivos": GlobalInventory.estados_edificios,
		"tech": tech_data,
		"cam": {
			"x": c_pos.x, 
			"y": c_pos.y, 
			"z": c_pos.z, 
			"s": c_size
		}
	}
	
	# Guardar archivo
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_line(JSON.stringify(data))
		file.close()
		print("[SAVE] ¡Guardado exitoso! Slot ", slot_index, " (", save_name, "), ", lista_edificios.size(), " edificios.")
	else:
		print("[SAVE] ERROR: No se pudo abrir el archivo para escritura.")

## Desde un nodo (p. ej. Area3D hijo), subir hasta la raíz de la escena del edificio (tiene scene_file_path con "buildings").
func _obtener_raiz_edificio(n: Node) -> Node:
	var node = n
	while node:
		var path = node.get("scene_file_path")
		if path and str(path).strip_edges().length() > 0 and "buildings" in str(path):
			return node
		node = node.get_parent()
	return null

func _buscar_edificios_recursivo(nodo: Node, lista: Array):
	if nodo is Area3D:
		var es_edificio = false
		if nodo.collision_layer == GameConstants.LAYER_EDIFICIOS:
			es_edificio = true
		if nodo.has_method("check_ground") or nodo.has_method("es_suelo_valido"):
			es_edificio = true
		var path = nodo.get("scene_file_path")
		if path and "buildings" in str(path):
			es_edificio = true
		if es_edificio:
			var raiz = _obtener_raiz_edificio(nodo)
			if raiz and raiz.scene_file_path and str(raiz.scene_file_path).strip_edges().length() > 0:
				if raiz not in lista:
					lista.append(raiz)
	# Buscar en hijos
	for hijo in nodo.get_children():
		_buscar_edificios_recursivo(hijo, lista)

## Carga la partida del slot indicado (1, 2 o 3).
func cargar_partida(slot_index: int = 1) -> bool:
	slot_index = clamp(slot_index, 1, NUM_SLOTS)
	var path = get_save_path(slot_index)
	return _cargar_desde_ruta(path)
	
func _cargar_desde_ruta(path: String) -> bool:
	print("[SAVE] Intentando cargar partida desde ", path)
	
	if not FileAccess.file_exists(path):
		print("[SAVE] No existe archivo de guardado.")
		return false
	
	var file = FileAccess.open(path, FileAccess.READ)
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
	
	# Restaurar estado del mapa (terreno) para no regenerar al cargar
	GlobalInventory.mapa_guardado = data.get("mapa", [])
	
	# Restaurar estados de edificios
	if data.has("estados_vivos"):
		GlobalInventory.estados_edificios = data["estados_vivos"]
	
	# Restaurar árbol tecnológico (desbloqueos F2)
	if data.has("tech") and TechTree:
		TechTree.load_progress(data["tech"])
	
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
	if not raiz:
		print("[SAVE] ERROR: current_scene es null, no se pueden reconstruir edificios.")
		return
	
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
	var escena = get_tree().current_scene
	var wg = escena.find_child("WorldGenerator", true, false) if escena else null
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
		"save_name": "Partida test",
		"save_timestamp": int(Time.get_unix_time_from_system()),
		"save_slot": 1,
		"semilla": GlobalInventory.semilla_mundo if GlobalInventory.semilla_mundo != 0 else randi(),
		"stock": stock_test,
		"mundo": lista_edificios,
		"estados_vivos": {},
		"cam": {"x": centro_x, "y": 0, "z": centro_z, "s": 100.0}
	}
	var file = FileAccess.open(get_save_path(1), FileAccess.WRITE)
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
			
			# Registrar en GridManager (todas las celdas del footprint si es multi-celda)
			if map and GridManager:
				var celda = map.local_to_map(edificio.global_position)
				var pos_2d = Vector2i(celda.x, celda.z)
				if edificio.has_method("get_footprint_offsets"):
					for off in edificio.get_footprint_offsets():
						GridManager.register_building(pos_2d + off, edificio)
				else:
					GridManager.register_building(pos_2d, edificio)
			
			if GameConstants.DEBUG_MODE: print("[SAVE] Activado: ", edificio.name)
