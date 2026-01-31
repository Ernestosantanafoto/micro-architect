class_name PlacementLogic

static func es_posicion_valida(grupo_o_nombre: String, id_suelo: int) -> bool:
	var tipo = grupo_o_nombre.to_lower()
	
	if "godsiphon" in tipo: return true
	if "constructor" in tipo: return true 
	
	if "sif" in tipo: 
		return id_suelo == GameConstants.TILE_ESTABILIDAD or id_suelo == GameConstants.TILE_CARGA
	
	if "compresor" in tipo:
		# SOLUCIÓN: T2 permite vacío o rojo
		if "t2" in tipo: 
			return id_suelo == GameConstants.TILE_ROJO or id_suelo == GameConstants.TILE_VACIO
		else: 
			return id_suelo == GameConstants.TILE_ROJO
			
	if "prisma" in tipo or "fusionador" in tipo:
		return id_suelo == GameConstants.TILE_VACIO
	
	if "void" in tipo: return true
		
	return false

static func esta_celda_ocupada(centro: Vector3, espacio: PhysicsDirectSpaceState3D, ignorar_objeto: Object = null, radio: int = 0) -> bool:
	for x in range(-radio, radio + 1):
		for z in range(-radio, radio + 1):
			var offset = Vector3(x, 0, z)
			var pos_check = centro + offset
			
			var query = PhysicsPointQueryParameters3D.new()
			query.position = pos_check
			query.collision_mask = GameConstants.LAYER_EDIFICIOS
			query.collide_with_areas = true
			
			var hits = espacio.intersect_point(query)
			if hits.size() > 0:
				for hit in hits:
					if hit.collider != ignorar_objeto:
						return true
	return false
