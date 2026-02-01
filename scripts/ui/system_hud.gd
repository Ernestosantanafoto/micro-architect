extends Node

const SAVE_PATH = "user://mundo_persistente.save"

func guardar_partida():
	print("[DEBUG-SAVE] Iniciando volcado total...")
	var gm = get_tree().get_first_node_in_group("MapaPrincipal")
	var lista_entidades = []
	
	if gm:
		for cell in gm.get_used_cells():
			var id = gm.get_cell_item(cell)
			if id > 2: # Solo guardamos edificios
				var rot = gm.get_cell_item_orientation(cell)
				# 1. Obtenemos estado interno (si el edificio existe en memoria)
				var estado = GlobalInventory.obtener_estado_edificio(cell)
				
				lista_entidades.append({
					"pos": {"x": cell.x, "y": cell.y, "z": cell.z},
					"id": id,
					"rot": rot,
					"estado": estado
				})

	var paquete = {
		"semilla": GlobalInventory.semilla_mundo,
		"inventario": GlobalInventory.stock,
		"entidades": lista_entidades
	}

	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_line(JSON.stringify(paquete))
	file.close()
	print("[DEBUG-SAVE] Guardado con éxito: ", lista_entidades.size(), " edificios.")

func cargar_partida() -> bool:
	if not FileAccess.file_exists(SAVE_PATH): return false
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var datos = JSON.parse_string(file.get_as_text())
	file.close()
	
	if datos:
		GlobalInventory.semilla_mundo = datos["semilla"]
		GlobalInventory.stock = datos["inventario"]
		GlobalInventory.edificios_para_reconstruir = datos["entidades"]
		return true
	return false
