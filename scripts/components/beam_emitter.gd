extends Node3D
class_name BeamEmitter

var beam_segment_scene = preload("res://scenes/world/beam_segment.tscn")
var contenedor: Node3D
var _debug_container: Node3D = null  # Solo usado en DEBUG_MODE para dibujar path del haz

func _ready():
	contenedor = Node3D.new()
	add_child(contenedor)

func dibujar_haz(origen: Vector3, direccion: Vector3, longitud: int, color: Color, map: GridMap, world: PhysicsDirectSpaceState3D):
	_limpiar()
	var r = _recorrer_haz(origen, direccion, longitud, map, world, null)
	var path: Array = r["path"]
	var target = r["target"]
	for i in path.size():
		var pos: Vector3 = path[i]
		var es_ultimo_y_bloqueado = (i == path.size() - 1 and target != null)
		var escala = 0.5 if es_ultimo_y_bloqueado else 1.0
		var offset = (-direccion * GameConstants.HAZ_SEGMENTO_OFFSET) if es_ultimo_y_bloqueado else Vector3.ZERO
		_crear_segmento(pos + offset, direccion, color, escala)
	if target != null and target.has_method("recibir_luz_instantanea"):
		target.recibir_luz_instantanea(color, "Energy", direccion)
	if GameConstants.DEBUG_MODE:
		_dibujar_path_debug(path)

func _crear_segmento(pos, dir, col, esc):
	var seg = beam_segment_scene.instantiate()
	contenedor.add_child(seg)
	seg.global_position = pos
	seg.scale.z = esc
	if dir.length() > 0.1: seg.look_at(pos + dir, Vector3.UP)
	
	var mesh = seg.get_node_or_null("MeshInstance3D")
	if not mesh:
		return
	var mat = StandardMaterial3D.new()
	mat.albedo_color = col
	mat.albedo_color.a = GameConstants.HAZ_ALPHA_TRANSPARENCIA
	mat.emission_enabled = true
	mat.emission = col
	mat.emission_energy_multiplier = GameConstants.HAZ_EMISION_ENERGIA
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mesh.set_surface_override_material(0, mat)

func _limpiar():
	for c in contenedor.get_children(): c.queue_free()

func apagar(): _limpiar()

## Recorrido compartido del haz por celdas del grid. Retorna path (posiciones mundo), target (primer edificio receptor) e impact_pos.
## Usado por obtener_objetivo, obtener_ruta_haz y para validar spawn de pulsos.
func _recorrer_haz(origen: Vector3, direccion: Vector3, longitud: int, map: GridMap, world: PhysicsDirectSpaceState3D, excluir: Node = null) -> Dictionary:
	var path: Array[Vector3] = []
	var cursor_mapa = map.local_to_map(origen)
	var dir_mapa = Vector3i(round(direccion.x), 0, round(direccion.z))
	# Primer punto: inicio del haz (mismo que dibujar_haz)
	var inicio = map.map_to_local(cursor_mapa) + (direccion * GameConstants.HAZ_OFFSET_ORIGEN)
	path.append(inicio)
	for i in range(longitud):
		cursor_mapa += dir_mapa
		var pos_mundo = map.map_to_local(cursor_mapa)
		var query = PhysicsPointQueryParameters3D.new()
		query.position = pos_mundo
		query.collision_mask = GameConstants.LAYER_EDIFICIOS
		query.collide_with_areas = true
		query.collide_with_bodies = true
		var colisiones = world.intersect_point(query)
		var bloqueado = false
		var objeto_colision = null
		for col in colisiones:
			var obj = col.collider
			if obj == excluir:
				continue
			if obj.get("esta_construido") == false:
				continue
			bloqueado = true
			objeto_colision = obj
			break
		path.append(pos_mundo)
		if bloqueado and objeto_colision and (objeto_colision.has_method("recibir_energia_numerica") or objeto_colision.has_method("recibir_luz_instantanea")):
			return {"path": path, "target": objeto_colision, "impact_pos": pos_mundo}
	return {"path": path, "target": null, "impact_pos": path[path.size() - 1] if path.size() > 0 else origen}

## Retorna la lista de posiciones mundo por las que pasa el haz (coincide con las celdas dibujadas).
func obtener_ruta_haz(origen: Vector3, direccion: Vector3, longitud: int, map: GridMap, world: PhysicsDirectSpaceState3D, excluir: Node = null) -> Array[Vector3]:
	var r = _recorrer_haz(origen, direccion, longitud, map, world, excluir)
	return r["path"]

## Retorna {path: Array[Vector3], target: Node, impact_pos: Vector3} en una sola pasada (evita doble recorrido).
func obtener_ruta_y_objetivo(origen: Vector3, direccion: Vector3, longitud: int, map: GridMap, world: PhysicsDirectSpaceState3D, excluir: Node = null) -> Dictionary:
	return _recorrer_haz(origen, direccion, longitud, map, world, excluir)

## Retorna {target: Node, impact_pos: Vector3} del primer edificio en el haz, o null. impact_pos = celda donde impacta (no centro del edificio).
func obtener_objetivo(origen: Vector3, direccion: Vector3, longitud: int, map: GridMap, world: PhysicsDirectSpaceState3D, excluir: Node = null):
	var r = _recorrer_haz(origen, direccion, longitud, map, world, excluir)
	if r["target"] != null:
		return {"target": r["target"], "impact_pos": r["impact_pos"]}
	return null

## Solo en DEBUG_MODE: dibuja el path del haz como línea (verificación de coincidencia con segmentos y con ruta del pulso).
func _dibujar_path_debug(path: Array) -> void:
	if path.size() < 2:
		return
	if _debug_container == null:
		_debug_container = Node3D.new()
		add_child(_debug_container)
	for c in _debug_container.get_children():
		c.queue_free()
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color(1.0, 1.0, 0.0, 0.8)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	var im := ImmediateMesh.new()
	im.surface_begin(Mesh.PRIMITIVE_LINE_STRIP, mat)
	var origin_global := global_position
	for i in range(path.size()):
		var local_p: Vector3 = Vector3(path[i]) - origin_global
		im.surface_add_vertex(local_p)
	im.surface_end()
	var mi := MeshInstance3D.new()
	mi.mesh = im
	_debug_container.add_child(mi)
