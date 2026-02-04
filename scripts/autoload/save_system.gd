extends Node

const NUM_SLOTS := 3
const SAVE_PATH_PATTERN := "user://save_slot_%d.json"

# #region agent log
const _DEBUG_LOG := "res://.cursor/debug.log"
func _debug_log(hypothesis_id: String, location: String, message: String, data: Dictionary) -> void:
	if not GameConstants.DEBUG_MODE:
		return
	var payload := {"hypothesisId": hypothesis_id, "location": location, "message": message, "data": data, "timestamp": Time.get_ticks_msec(), "sessionId": "save_debug"}
	var j := JSON.stringify(payload)
	var d := DirAccess.open("res://")
	if d and not d.dir_exists(".cursor"):
		d.make_dir_recursive(".cursor")
	var f := FileAccess.open(_DEBUG_LOG, FileAccess.READ_WRITE)
	if f:
		f.seek_end()
		f.store_line(j)
		f.close()
# #endregion

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
	if GameConstants.DEBUG_MODE:
		print("[SAVE] Iniciando guardado en slot ", slot_index, " -> ", path)
	
	var lista_edificios = []
	var edificios_encontrados = []
	
	# #region agent log
	var bm_exists := BuildingManager != null
	var bm_count := BuildingManager.active_buildings.size() if BuildingManager else 0
	var first_sfp := ""
	if BuildingManager and bm_count > 0 and is_instance_valid(BuildingManager.active_buildings[0]):
		var sfp = BuildingManager.active_buildings[0].get("scene_file_path")
		first_sfp = str(sfp) if sfp != null else ""
	_debug_log("A", "save_system:_guardar_a_ruta", "BuildingManager state", {"bm_exists": bm_exists, "active_buildings_count": bm_count, "first_scene_file_path": first_sfp})
	# #endregion
	
	# 1) Usar BuildingManager.active_buildings (fuente fiable: cada edificio colocado se registra ahí)
	if BuildingManager and BuildingManager.active_buildings.size() > 0:
		for b in BuildingManager.active_buildings:
			if is_instance_valid(b) and b.get("scene_file_path"):
				var path_str = str(b.scene_file_path)
				if "buildings" in path_str:
					edificios_encontrados.append(b)
	
	# #region agent log
	_debug_log("A", "save_system:after_BM_loop", "after BuildingManager", {"edificios_encontrados": edificios_encontrados.size()})
	# #endregion
	
	# 2) Si no hay ninguno, tomar edificios únicos desde GridManager.occupied_cells (cada colocación los registra)
	var grid_cells_count := 0
	if GridManager and GridManager.get("occupied_cells"):
		grid_cells_count = GridManager.occupied_cells.size()
	if edificios_encontrados.is_empty() and GridManager and GridManager.get("occupied_cells"):
		var vistos = {}
		for pos in GridManager.occupied_cells:
			var b = GridManager.occupied_cells[pos]
			if is_instance_valid(b) and b.get("scene_file_path") and not vistos.get(b):
				var path_str = str(b.scene_file_path)
				if "buildings" in path_str:
					edificios_encontrados.append(b)
					vistos[b] = true
	
	# #region agent log
	_debug_log("B", "save_system:after_GridManager", "after GridManager", {"occupied_cells_count": grid_cells_count, "edificios_encontrados": edificios_encontrados.size()})
	if edificios_encontrados.size() > 0:
		var sample: Node = edificios_encontrados[0]
		var sfp_sample = sample.get("scene_file_path")
		var sfp_str = str(sfp_sample) if sfp_sample != null else ""
		_debug_log("C", "save_system:sample_building", "first building", {"scene_file_path": sfp_str, "has_buildings": "buildings" in sfp_str})
	# #endregion
	
	# 3) Último recurso: buscar recursivamente desde la raíz de la escena de juego
	var current_scene_val = get_tree().current_scene
	var raiz_recursive = _obtener_raiz_escena_juego()
	if edificios_encontrados.is_empty():
		var raiz = get_tree().current_scene
		if not raiz or not is_instance_valid(raiz):
			raiz = _obtener_raiz_escena_juego()
		if raiz:
			_buscar_edificios_recursivo(raiz, edificios_encontrados)
	
	# #region agent log
	_debug_log("D", "save_system:roots", "scene roots", {"current_scene_not_null": current_scene_val != null, "obtener_raiz_not_null": raiz_recursive != null, "edificios_after_recursive": edificios_encontrados.size()})
	# #endregion
	
	# Raíz para cámara (y fallback)
	var raiz = get_tree().current_scene
	if not raiz or not is_instance_valid(raiz):
		raiz = _obtener_raiz_escena_juego()
	
	if GameConstants.DEBUG_MODE:
		print("[SAVE] Edificios encontrados: ", edificios_encontrados.size())
	
	var skipped_esta_construido := 0
	for edificio in edificios_encontrados:
		# Verificar que esté construido (no sea fantasma)
		var esta_construido = true
		if edificio.get("esta_construido") != null:
			esta_construido = edificio.esta_construido
		
		if not esta_construido:
			skipped_esta_construido += 1
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
		if GameConstants.DEBUG_MODE:
			print("[SAVE] - ", edificio.name, " en ", edificio.global_position)
	
	# #region agent log
	_debug_log("E", "save_system:after_loop", "filter loop", {"skipped_esta_construido": skipped_esta_construido, "lista_edificios_final": lista_edificios.size(), "encontrados_total": edificios_encontrados.size()})
	# #endregion
	
	# Obtener datos de cámara (usar misma raíz que edificios)
	var escena_actual = raiz if raiz else get_tree().current_scene
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
		if GameConstants.DEBUG_MODE:
			print("[SAVE] ¡Guardado exitoso! Slot ", slot_index, " (", save_name, "), ", lista_edificios.size(), " edificios.")
	else:
		push_error("[SAVE] No se pudo abrir el archivo para escritura: " + path)

## Devuelve la raíz de la escena de juego (MainGame3D) cuando current_scene no está actualizado (partida cargada con add_child).
func _obtener_raiz_escena_juego() -> Node:
	var root = get_tree().root
	for child in root.get_children():
		if child.find_child("GridMap", true, false) or child.find_child("WorldGenerator", true, false):
			return child
	return null

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
	if GameConstants.DEBUG_MODE:
		print("[SAVE] Intentando cargar partida desde ", path)
	
	if not FileAccess.file_exists(path):
		if GameConstants.DEBUG_MODE:
			print("[SAVE] No existe archivo de guardado.")
		return false
	
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("[SAVE] No se pudo abrir el archivo: " + path)
		return false
	
	var texto = file.get_as_text()
	file.close()
	
	var data = JSON.parse_string(texto)
	if not data:
		push_error("[SAVE] JSON inválido en: " + path)
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
		if GameConstants.DEBUG_MODE:
			print("[SAVE] Edificios a reconstruir: ", GlobalInventory.edificios_para_reconstruir.size())
	
	# Guardar datos de cámara
	if data.has("cam"):
		var c = data["cam"]
		GlobalInventory.datos_camara = {
			"pos": Vector3(c.get("x", 0), c.get("y", 0), c.get("z", 0)),
			"size": c.get("s", 100.0)
		}
	
	if GameConstants.DEBUG_MODE:
		print("[SAVE] Partida cargada correctamente.")
	return true

# Esta función debe llamarse desde la escena principal después de cargar
func reconstruir_edificios():
	if GameConstants.DEBUG_MODE:
		print("[SAVE] Reconstruyendo edificios...")
	
	if GridManager:
		GridManager.limpiar()
	
	var edificios = GlobalInventory.edificios_para_reconstruir
	if edificios.size() == 0:
		if GameConstants.DEBUG_MODE:
			print("[SAVE] No hay edificios para reconstruir.")
		return
	
	# Raíz de la escena de juego: current_scene puede ser null si la partida se cargó con add_child
	var raiz = get_tree().current_scene
	if not raiz or not is_instance_valid(raiz):
		raiz = _obtener_raiz_escena_juego()
	if not raiz:
		push_error("[SAVE] No se pudo obtener raíz de escena de juego, no se pueden reconstruir edificios.")
		return
	
	# Guardar referencias de las instancias para activarlas por referencia (no depender de búsqueda en árbol)
	var instancias_recien_anadidas: Array[Node] = []
	
	for datos in edificios:
		var ruta_escena = datos.get("scene", "")
		if ruta_escena == "" or not ResourceLoader.exists(ruta_escena):
			push_warning("[SAVE] Escena no encontrada: " + ruta_escena)
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
		instancia.set_meta("necesita_activacion", true)
		instancias_recien_anadidas.append(instancia)
		
		if GameConstants.DEBUG_MODE: print("[SAVE] - Reconstruido: ", instancia.name, " en ", instancia.global_position)
	
	# Limpiar lista
	GlobalInventory.edificios_para_reconstruir = []
	
	# Activar por referencia (no buscar en árbol: al cargar desde menú current_scene no es la escena de juego)
	await get_tree().process_frame
	_activar_lista_edificios(instancias_recien_anadidas)
	
	if GameConstants.DEBUG_MODE:
		print("[SAVE] Reconstrucción completada.")

## Genera una partida de test con ~100 edificios en tiles válidos. F9 en partida.
func generar_partida_test(cantidad_objetivo: int = 100) -> bool:
	var escena = get_tree().current_scene
	var wg = escena.find_child("WorldGenerator", true, false) if escena else null
	var map = get_tree().get_first_node_in_group("MapaPrincipal")
	if not map or not (map is GridMap):
		push_error("[SAVE] No se encontró GridMap para generar partida test.")
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
		push_error("[SAVE] No se pudo abrir archivo para escribir partida test.")
		return false
	file.store_line(JSON.stringify(data))
	file.close()
	GlobalInventory.semilla_mundo = data["semilla"]
	GlobalInventory.stock = stock_test
	GlobalInventory.edificios_para_reconstruir = lista_edificios
	GlobalInventory.estados_edificios = {}
	GlobalInventory.datos_camara = {"pos": Vector3(centro_x, 0, centro_z), "size": 100.0}
	if GameConstants.DEBUG_MODE:
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

func _recoger_nodos_con_meta_activacion(nodo: Node, lista: Array) -> void:
	if nodo.has_meta("necesita_activacion") and nodo.get_meta("necesita_activacion"):
		lista.append(nodo)
	for hijo in nodo.get_children():
		_recoger_nodos_con_meta_activacion(hijo, lista)

## Activa una lista de nodos de edificios por referencia (evita fallos cuando current_scene no es la escena de juego).
func _activar_lista_edificios(lista: Array) -> void:
	var map = get_tree().get_first_node_in_group("MapaPrincipal")
	var activados_count := 0
	for edificio in lista:
		if not is_instance_valid(edificio):
			continue
		if edificio.has_meta("necesita_activacion"):
			edificio.remove_meta("necesita_activacion")
		activados_count += 1
		if edificio.has_method("check_ground"):
			# Diferir para que se ejecute cuando el nodo esté en el árbol (get_tree() válido)
			edificio.call_deferred("check_ground")
		if edificio.get("collision_layer") != null:
			edificio.collision_layer = GameConstants.LAYER_EDIFICIOS
		if edificio.get("esta_construido") != null:
			edificio.esta_construido = true
		if map and GridManager:
			var celda = map.local_to_map(edificio.global_position)
			var pos_2d = Vector2i(celda.x, celda.z)
			if edificio.has_method("get_footprint_offsets"):
				for off in edificio.get_footprint_offsets():
					GridManager.register_building(pos_2d + off, edificio)
			else:
				GridManager.register_building(pos_2d, edificio)
		if BuildingManager:
			BuildingManager.register_building(edificio)
	if GameConstants.DEBUG_MODE:
		print("[SAVE] Total edificios activados: ", activados_count)

func _activar_edificios_reconstruidos(raiz: Node):
	if not is_instance_valid(raiz):
		return
	var hijos_nombres: Array[String] = []
	for c in raiz.get_children():
		hijos_nombres.append(c.name)
		var has_meta = c.has_meta("necesita_activacion")
		if has_meta:
			hijos_nombres.append("  -> tiene meta!")
	if GameConstants.DEBUG_MODE:
		print("[SAVE] raiz = ", raiz.name, " hijos = ", raiz.get_child_count(), " ", hijos_nombres)
	var edificios = []
	_buscar_edificios_recursivo(raiz, edificios)
	# Si la búsqueda por scene_file_path no encuentra ninguno con meta, buscar por meta (los que acabamos de añadir)
	var con_meta_count := 0
	for e in edificios:
		if e.has_meta("necesita_activacion") and e.get_meta("necesita_activacion"):
			con_meta_count += 1
	if con_meta_count == 0:
		edificios.clear()
		_recoger_nodos_con_meta_activacion(raiz, edificios)
		if GameConstants.DEBUG_MODE:
			print("[SAVE] Fallback por meta: edificios a activar = ", edificios.size())
	else:
		if GameConstants.DEBUG_MODE:
			print("[SAVE] Por búsqueda normal: edificios a activar = ", con_meta_count)
	
	var map = get_tree().get_first_node_in_group("MapaPrincipal")
	
	var activados_count := 0
	for edificio in edificios:
		if edificio.has_meta("necesita_activacion") and edificio.get_meta("necesita_activacion"):
			edificio.remove_meta("necesita_activacion")
			activados_count += 1
			if GameConstants.DEBUG_MODE:
				print("[SAVE] Activando edificio: ", edificio.name, " en ", edificio.global_position)
			
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
			
			if GameConstants.DEBUG_MODE:
				print("[SAVE] Activado: ", edificio.name)
	if GameConstants.DEBUG_MODE:
		print("[SAVE] Total edificios activados: ", activados_count)
