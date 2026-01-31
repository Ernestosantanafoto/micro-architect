extends Node3D
class_name BeamEmitter

var beam_segment_scene = preload("res://scenes/world/beam_segment.tscn")
var contenedor: Node3D

func _ready():
	contenedor = Node3D.new()
	add_child(contenedor)

func dibujar_haz(origen: Vector3, direccion: Vector3, longitud: int, color: Color, map: GridMap, world: PhysicsDirectSpaceState3D):
	_limpiar()
	var cursor_mapa = map.local_to_map(origen)
	var dir_mapa = Vector3i(round(direccion.x), 0, round(direccion.z))
	
	# SOLUCIÓN: Empezar un poco más adelante para no chocarse consigo mismo
	var inicio = map.map_to_local(cursor_mapa) + (direccion * 0.6)
	_crear_segmento(inicio, direccion, color, 0.5)
	
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
		
		# SOLUCIÓN: Filtrar fantasmas
		if colisiones.size() > 0:
			for col in colisiones:
				var obj = col.collider
				# Si no está construido, la luz lo atraviesa (es un fantasma)
				if obj.get("esta_construido") == false:
					continue
				
				bloqueado = true
				objeto_colision = obj
				break
		
		var escala = 0.5 if bloqueado else 1.0
		var offset = -direccion * GameConstants.HAZ_SEGMENTO_OFFSET if bloqueado else Vector3.ZERO
		
		_crear_segmento(pos_mundo + offset, direccion, color, escala)
		
		if bloqueado:
			if objeto_colision and objeto_colision.has_method("recibir_luz_instantanea"):
				objeto_colision.recibir_luz_instantanea(color, "Energy", direccion)
			break # El haz se detiene

func _crear_segmento(pos, dir, col, esc):
	var seg = beam_segment_scene.instantiate()
	contenedor.add_child(seg)
	seg.global_position = pos
	seg.scale.z = esc
	if dir.length() > 0.1: seg.look_at(pos + dir, Vector3.UP)
	
	var mesh = seg.get_node("MeshInstance3D")
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
