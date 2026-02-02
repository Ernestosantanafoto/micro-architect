extends Area3D

# #region agent log
func _void_dbg(hypothesis_id: String, message: String, data: Dictionary) -> void:
	var payload = {sessionId = "debug-session", runId = "run1", hypothesisId = hypothesis_id, location = "void_generator.gd", message = message, data = data, timestamp = Time.get_ticks_msec()}
	var dir = DirAccess.open("res://")
	if dir:
		dir.make_dir_recursive(".cursor")
	var path = "res://.cursor/debug.log"
	var f = FileAccess.open(path, FileAccess.READ_WRITE)
	if not f:
		f = FileAccess.open(path, FileAccess.WRITE)
	if f:
		f.seek_end(0)
		f.store_line(JSON.stringify(payload))
		f.close()
# #endregion agent log

var esta_construido: bool = false
var esta_activado: bool = false  # Latente hasta clic derecho
var radio = GameConstants.VOID_GEN_RADIO
var tiles_a_limpiar: Array[Vector3i] = []
var tiempo_acumulado: float = 0.0

# Posición fija donde se realizó el clic (alineada a cuadrícula)
var centro_operativo: Vector3 = Vector3.ZERO

# Misma altura que la grilla azul del shader (plano del suelo en y=0). Offset mínimo para evitar z-fight.
const VOID_ALTURA_SUELO_MUNDO := 0.001

@onready var grid_visual = $GridVisual
var perimeter_visual: Node3D = null
# Colisión de huella (círculo en suelo) para que clic en el área roja dispare activar/recoger
var _footprint_collision: CollisionShape3D = null
# Pulso visual: de color/material colocado al color/material fantasma (mismos valores que construction_manager)
var _body_meshes: Array[MeshInstance3D] = []
var _body_pulse_materials: Array[StandardMaterial3D] = []
var _body_colocado_colors: Array[Color] = []  # color original por malla
# Mismos valores que construction_manager._aplicar_color_validacion (fantasma válido)
const COLOR_FANTASMA := Color(0.4, 0.6, 1.0, 0.5)
# Pulso del suelo (casillas + borde) cuando está latente: rojo <-> azul fantasma
const COLOR_FANTASMA_SUELO := Color(0.4, 0.6, 1.0, 0.12)
const COLOR_FANTASMA_BORDE := Color(0.4, 0.6, 1.0, 0.35)

func _ready():
	if esta_construido and esta_activado:
		collision_layer = GameConstants.LAYER_EDIFICIOS
		collision_mask = GameConstants.LAYER_EDIFICIOS
	elif esta_construido:
		# Latente: colisiones para poder clic derecho (activar) e izquierdo (recoger)
		collision_layer = GameConstants.LAYER_EDIFICIOS
		collision_mask = GameConstants.LAYER_EDIFICIOS
	else:
		collision_layer = 0
		collision_mask = 0

	perimeter_visual = Node3D.new()
	add_child(perimeter_visual)
	
	if not esta_construido:
		set_process(true)
	else:
		grid_visual.visible = false
		perimeter_visual.visible = false
		set_process(false)
	
	_preparar_datos_limpieza()
	_generar_perimetro_visual_inteligente()
	
	if esta_construido and esta_activado:
		# Carga de partida: ya estaba activado
		pass  # check_ground ya se llamó al guardar
	elif esta_construido:
		_mostrar_visual_latente()
	_recoger_mallas_cuerpo()

# --- FUNCIÓN DE ACTIVACIÓN (Llamada por ConstructionManager o al activar desde latente) ---
func activar_modo_activo():
	grid_visual.visible = true
	perimeter_visual.visible = true
	grid_visual.set_as_top_level(true)
	perimeter_visual.set_as_top_level(true)
	set_process(true)

func _process(delta):
	# 1. POSICIÓN VISUAL: misma que la cuadrícula (centro de celda del GridMap en mundo)
	var target_x = 0.0
	var target_z = 0.0
	var map_node = get_tree().current_scene.find_child("GridMap", true, false) if get_tree() else null

	if not esta_construido:
		grid_visual.visible = true
		perimeter_visual.visible = true
		if not grid_visual.is_set_as_top_level():
			grid_visual.set_as_top_level(true)
			perimeter_visual.set_as_top_level(true)
		if map_node:
			var map_pos = map_node.local_to_map(global_position)
			var local_center = map_node.map_to_local(map_pos)
			var world_center = map_node.global_transform * local_center
			target_x = world_center.x
			target_z = world_center.z
		else:
			target_x = floor(global_position.x) + 0.5
			target_z = floor(global_position.z) + 0.5
	else:
		if map_node:
			var map_pos = map_node.local_to_map(centro_operativo)
			var local_center = map_node.map_to_local(map_pos)
			var world_center = map_node.global_transform * local_center
			target_x = world_center.x
			target_z = world_center.z
		else:
			target_x = centro_operativo.x
			target_z = centro_operativo.z
	
	# #region agent log
	if grid_visual and Engine.get_process_frames() % 60 == 1:
		_void_dbg("A", "target_and_origin", {"target_x": target_x, "target_z": target_z, "centro_x": centro_operativo.x, "centro_z": centro_operativo.z, "global_x": global_position.x, "global_z": global_position.z, "esta_construido": esta_construido})
	# #endregion agent log
	
	# 2. FIJAR AL SUELO: misma Y que la grilla azul; escala 1:1 (evitar herencia 1.2 del Void al colocar)
	if grid_visual:
		grid_visual.global_position = Vector3(target_x, VOID_ALTURA_SUELO_MUNDO, target_z)
		grid_visual.scale = Vector3.ONE
	if perimeter_visual:
		perimeter_visual.global_position = Vector3(target_x, VOID_ALTURA_SUELO_MUNDO, target_z)
		perimeter_visual.scale = Vector3.ONE
	
	# #region agent log
	if grid_visual and Engine.get_process_frames() % 60 == 1:
		var s = grid_visual.global_transform.basis.get_scale()
		_void_dbg("B", "grid_visual_after_set", {"gv_global_x": grid_visual.global_position.x, "gv_global_z": grid_visual.global_position.z, "scale_x": s.x, "scale_z": s.z})
	# #endregion agent log

	# 3. Pulso del edificio (cuerpo) cuando está latente
	if esta_construido and not esta_activado:
		_actualizar_pulso_cuerpo(delta)
	
	# 4. LÓGICA DE TRABAJO (solo si está construido y activado)
	if not esta_construido or not esta_activado:
		return
	
	tiempo_acumulado += delta
	if tiempo_acumulado >= GameConstants.VOID_GEN_TIEMPO_TILE:
		tiempo_acumulado = 0.0
		_limpiar_siguiente_tile()
		_actualizar_mi_estado_global()
	else:
		_actualizar_mi_estado_global()

func _preparar_datos_limpieza():
	tiles_a_limpiar.clear()
	for x in range(-radio, radio + 1):
		for z in range(-radio, radio + 1):
			if Vector2(x, z).length() <= radio:
				tiles_a_limpiar.append(Vector3i(x, 0, z))
	
	# Ordenamos para borrar desde el centro hacia afuera
	tiles_a_limpiar.sort_custom(func(a, b): return a.length_squared() < b.length_squared())
	
	if not esta_construido:
		_dibujar_relleno_fantasma()

# --- VISUALES (plano rojo: 1 unidad = 1 celda de la grilla, radio exacto 7) ---

func _generar_perimetro_visual_inteligente():
	for c in perimeter_visual.get_children(): c.queue_free()
	var grosor = GameConstants.VOID_GEN_PERIMETRO_GROSOR
	var mesh_h = BoxMesh.new()
	mesh_h.size = Vector3(1.0, grosor, grosor)
	var mesh_v = BoxMesh.new()
	mesh_v.size = Vector3(grosor, grosor, 1.0)
	var mat = StandardMaterial3D.new()
	mat.albedo_color = GameConstants.VOID_GEN_COLOR_BORDE
	mat.emission_enabled = true
	mat.emission = GameConstants.VOID_GEN_COLOR_BORDE
	mat.emission_energy_multiplier = GameConstants.VOID_GEN_PERIMETRO_BRILLO
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# Perímetro en el BORDE de celda: borde entre (x,z) y vecino está en ±0.5. Shader/GridMap: centros n+0.5, bordes en enteros.
	var y_local := 0.0
	var seg_count := 0
	var first_pos := Vector3(-99, -99, -99)
	for x in range(-radio, radio + 1):
		for z in range(-radio, radio + 1):
			if not _es_tile_valido(x, z):
				continue
			if not _es_tile_valido(x, z - 1): _crear_tira(mesh_h, mat, Vector3(x, y_local, z - 0.5)); seg_count += 1; if first_pos.x < -90: first_pos = Vector3(x, y_local, z - 0.5)
			if not _es_tile_valido(x, z + 1): _crear_tira(mesh_h, mat, Vector3(x, y_local, z + 0.5)); seg_count += 1
			if not _es_tile_valido(x - 1, z): _crear_tira(mesh_v, mat, Vector3(x - 0.5, y_local, z)); seg_count += 1
			if not _es_tile_valido(x + 1, z): _crear_tira(mesh_v, mat, Vector3(x + 0.5, y_local, z)); seg_count += 1
	# #region agent log
	_void_dbg("D", "perimeter_build", {"radio": radio, "seg_count": seg_count, "first_x": first_pos.x, "first_z": first_pos.z})
	# #endregion agent log

func _es_tile_valido(x, z) -> bool:
	return Vector2(x, z).length() <= radio

func _crear_tira(mesh_ref, mat_ref, pos: Vector3):
	var mi = MeshInstance3D.new()
	mi.mesh = mesh_ref
	mi.material_override = mat_ref
	mi.position = pos
	perimeter_visual.add_child(mi)

func _recoger_mallas_cuerpo():
	_body_meshes.clear()
	var col = get_node_or_null("CollisionShape3D")
	if col:
		for c in col.get_children():
			if c is MeshInstance3D:
				_body_meshes.append(c)

var _pulse_time: float = 0.0

func _actualizar_pulso_cuerpo(delta: float):
	_pulse_time += delta
	if _body_meshes.is_empty():
		_recoger_mallas_cuerpo()
	# Crear materiales de pulso y guardar color "colocado" (original) la primera vez
	if _body_pulse_materials.size() != _body_meshes.size():
		_body_pulse_materials.clear()
		_body_colocado_colors.clear()
		for mi in _body_meshes:
			var colocado := Color(0.92, 0.92, 0.96, 1.0)
			var orig = mi.get_active_material(0) if mi.get_surface_override_material_count() > 0 else (mi.mesh.surface_get_material(0) if mi.mesh else null)
			if orig and orig is StandardMaterial3D:
				colocado = (orig as StandardMaterial3D).albedo_color
				colocado.a = 1.0
			_body_colocado_colors.append(colocado)
			var mat = StandardMaterial3D.new()
			mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			mi.material_override = mat
			_body_pulse_materials.append(mat)
	# t: 0 = colocado, 1 = fantasma (mismos valores que _aplicar_color_validacion)
	var t = 0.5 + 0.5 * sin(_pulse_time * 2.5)
	for i in _body_pulse_materials.size():
		var mat: StandardMaterial3D = _body_pulse_materials[i]
		var colocado: Color = _body_colocado_colors[i] if i < _body_colocado_colors.size() else Color(0.92, 0.92, 0.96, 1.0)
		mat.albedo_color = colocado.lerp(COLOR_FANTASMA, t)
	# Pulso de la malla roja (casillas + borde)
	_actualizar_pulso_suelo(t)

func _actualizar_pulso_suelo(t: float) -> void:
	# Casillas: rojo área <-> azul fantasma
	for child in grid_visual.get_children():
		if child is MeshInstance3D and child.material_override is StandardMaterial3D:
			(child.material_override as StandardMaterial3D).albedo_color = GameConstants.VOID_GEN_COLOR_AREA.lerp(COLOR_FANTASMA_SUELO, t)
	# Borde: rojo borde <-> azul fantasma
	for child in perimeter_visual.get_children():
		if child is MeshInstance3D and child.material_override is StandardMaterial3D:
			(child.material_override as StandardMaterial3D).albedo_color = GameConstants.VOID_GEN_COLOR_BORDE.lerp(COLOR_FANTASMA_BORDE, t)

func _quitar_pulso_cuerpo():
	for i in _body_meshes.size():
		if i < _body_pulse_materials.size():
			_body_meshes[i].material_override = null
	_body_pulse_materials.clear()
	# Restaurar color del borde (las casillas se borran con _limpiar_visuales_internas al activar)
	for child in perimeter_visual.get_children():
		if child is MeshInstance3D and child.material_override is StandardMaterial3D:
			(child.material_override as StandardMaterial3D).albedo_color = GameConstants.VOID_GEN_COLOR_BORDE

func _dibujar_relleno_fantasma():
	_limpiar_visuales_internas()
	# #region agent log
	var n = tiles_a_limpiar.size()
	var ix_min := 99
	var ix_max := -99
	var iz_min := 99
	var iz_max := -99
	for t in tiles_a_limpiar:
		ix_min = mini(ix_min, t.x)
		ix_max = maxi(ix_max, t.x)
		iz_min = mini(iz_min, t.z)
		iz_max = maxi(iz_max, t.z)
	_void_dbg("D", "fill_build", {"tiles_count": n, "ix_min": ix_min, "ix_max": ix_max, "iz_min": iz_min, "iz_max": iz_max})
	# #endregion agent log
	for t in tiles_a_limpiar:
		_añadir_cuadrito_rojo(t)

func _limpiar_visuales_internas():
	for child in grid_visual.get_children():
		child.queue_free()

func _añadir_cuadrito_rojo(pos_local: Vector3i):
	# Tamaño = 1 celda del GridMap (normalmente 1,1,1); cuadrito centrado en (ix, 0, iz), inset para no solapar
	var cell_sz := Vector3(1.0, 1.0, 1.0)
	var map_node = get_tree().current_scene.find_child("GridMap", true, false) if get_tree() else null
	if map_node and map_node is GridMap:
		cell_sz = (map_node as GridMap).cell_size
	const INSET := 0.02
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(cell_sz.x - INSET, 0.02, cell_sz.z - INSET)
	var mat = StandardMaterial3D.new()
	mat.albedo_color = GameConstants.VOID_GEN_COLOR_AREA
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var mesh_inst = MeshInstance3D.new()
	mesh_inst.mesh = box_mesh
	mesh_inst.material_override = mat
	mesh_inst.position = Vector3(pos_local.x, 0.0, pos_local.z)
	grid_visual.add_child(mesh_inst)

# --- LÓGICA DE BORRADO ---

func _limpiar_siguiente_tile():
	if tiles_a_limpiar.is_empty():
		_finalizar_trabajo()
		return
	
	var map = get_tree().current_scene.find_child("GridMap")
	if map:
		var tile_local = tiles_a_limpiar.pop_front()
		
		# Usamos centro_operativo para que la vibración no afecte al cálculo
		var pos_global_tile = map.map_to_local(map.local_to_map(centro_operativo) + tile_local)
		
		_destruir_ocupantes_encima(pos_global_tile)
		
		var tile_global_coords = map.local_to_map(centro_operativo) + tile_local
		map.set_cell_item(tile_global_coords, GameConstants.TILE_VACIO)
		
		_añadir_cuadrito_rojo(tile_local)
		
		# Vibración visual del cuerpo de la máquina
		var v = GameConstants.VOID_GEN_VIBRACION_FUERZA
		var t = create_tween()
		t.tween_property(self, "position", centro_operativo + Vector3(randf()*v, 0, randf()*v), 0.05)
		t.tween_property(self, "position", centro_operativo, 0.05)
	_actualizar_mi_estado_global()

func _destruir_ocupantes_encima(posicion_suelo: Vector3):
	var space_state = get_world_3d().direct_space_state
	var shape = BoxShape3D.new()
	shape.size = Vector3(0.5, 0.5, 0.5)
	var query = PhysicsShapeQueryParameters3D.new()
	query.shape = shape
	query.transform = Transform3D(Basis(), posicion_suelo + Vector3(0, 0.5, 0))
	query.collision_mask = GameConstants.LAYER_EDIFICIOS
	query.collide_with_areas = true 
	
	var resultados = space_state.intersect_shape(query)
	for res in resultados:
		var edificio = res.collider
		if edificio == self: continue
		var puede_flotar = false
		if edificio.has_method("configurar_dios"): puede_flotar = true
		if edificio.get("grupo_placement") == "CompresoresT2": puede_flotar = true
		if not puede_flotar:
			_ejecutar_destruccion_total(edificio)

func _ejecutar_destruccion_total(edificio: Node3D):
	if not is_instance_valid(edificio): return
	if edificio is Area3D:
		edificio.set_deferred("monitoring", false)
		edificio.set_deferred("monitorable", false)
	
	var t = create_tween()
	t.set_parallel(true)
	t.tween_property(edificio, "global_position:y", -3.0, GameConstants.VOID_GEN_TIEMPO_DESTRUCCION).set_trans(Tween.TRANS_SINE)
	t.tween_property(edificio, "scale", Vector3.ZERO, GameConstants.VOID_GEN_TIEMPO_DESTRUCCION)
	t.set_parallel(false)
	t.finished.connect(func(): if is_instance_valid(edificio): edificio.queue_free())
	print("DESTRUCCIÓN: Suelo eliminado bajo ", edificio.name)

# --- FINALIZACIÓN SECUENCIAL ---

func _finalizar_trabajo():
	# FASE 1: Fade out de la máquina (Materiales Únicos)
	var t_machine = create_tween()
	t_machine.set_parallel(true)
	
	var mallas_animadas = 0
	for child in find_children("*", "MeshInstance3D"):
		# Ignoramos los visuales del suelo porque son Top Level
		if child.get_parent() == grid_visual or child.get_parent() == perimeter_visual:
			continue 
		
		var mat_original = child.get_active_material(0)
		if not mat_original: mat_original = child.mesh.surface_get_material(0)
		
		if mat_original and mat_original is StandardMaterial3D:
			var mat_unique = mat_original.duplicate()
			mat_unique.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			child.set_surface_override_material(0, mat_unique)
			t_machine.tween_property(mat_unique, "albedo_color:a", 0.0, GameConstants.VOID_GEN_FADE_MACHINE)
			mallas_animadas += 1

	if mallas_animadas == 0:
		t_machine.tween_interval(0.5)

	# Esperamos a que la máquina desaparezca visualmente
	await t_machine.finished
	
	# FASE 2: Fade Out Radial del suelo
	var visuales = []
	if grid_visual: visuales.append_array(grid_visual.get_children())
	if perimeter_visual: visuales.append_array(perimeter_visual.get_children())
	
	visuales.sort_custom(func(a, b): 
		# Ordenamos por distancia al centro para el efecto de onda
		return a.global_position.distance_squared_to(centro_operativo) < b.global_position.distance_squared_to(centro_operativo)
	)
	
	var t_tiles = create_tween()
	t_tiles.set_parallel(true)
	
	for tile in visuales:
		var mat = tile.material_override
		if mat:
			var delay = tile.global_position.distance_to(centro_operativo) * GameConstants.VOID_GEN_WAVE_SPEED
			t_tiles.tween_property(mat, "albedo_color:a", 0.0, GameConstants.VOID_GEN_FADE_TILES)\
				.set_delay(delay)\
				.set_trans(Tween.TRANS_SINE)
	
	# FASE FINAL: Borrado
	t_tiles.chain().tween_callback(queue_free)

# --- API ---
## Colocar en mundo en estado latente (rojo/blanco). Clic derecho = activar, clic izquierdo = recoger.
func colocar_latente():
	esta_construido = true
	esta_activado = false
	collision_layer = GameConstants.LAYER_EDIFICIOS
	collision_mask = GameConstants.LAYER_EDIFICIOS
	input_ray_pickable = true
	if not input_event.is_connected(_on_void_input_event):
		input_event.connect(_on_void_input_event)
	var map_node = get_tree().current_scene.find_child("GridMap", true, false) if get_tree() else null
	if map_node:
		var map_pos = map_node.local_to_map(global_position)
		var local_center = map_node.map_to_local(map_pos)
		var world_center = map_node.global_transform * local_center
		centro_operativo.x = world_center.x
		centro_operativo.z = world_center.z
		centro_operativo.y = world_center.y
	else:
		centro_operativo.x = floor(global_position.x) + 0.5
		centro_operativo.z = floor(global_position.z) + 0.5
		centro_operativo.y = 0.0
	global_position = Vector3(centro_operativo.x, 0.5, centro_operativo.z)
	_añadir_colision_huella()
	_mostrar_visual_latente()
	_actualizar_mi_estado_global()

func _añadir_colision_huella():
	if _footprint_collision:
		return
	var shape = CylinderShape3D.new()
	shape.radius = float(radio)
	shape.height = 0.3
	_footprint_collision = CollisionShape3D.new()
	_footprint_collision.name = "FootprintCollision"
	_footprint_collision.shape = shape
	_footprint_collision.position = Vector3(0, -0.35, 0)
	add_child(_footprint_collision)

func _quitar_colision_huella():
	if _footprint_collision:
		_footprint_collision.queue_free()
		_footprint_collision = null

func _mostrar_visual_latente():
	grid_visual.visible = true
	perimeter_visual.visible = true
	grid_visual.set_as_top_level(true)
	perimeter_visual.set_as_top_level(true)
	set_process(true)
	var map_node = get_tree().current_scene.find_child("GridMap", true, false) if get_tree() else null
	if map_node:
		var map_pos = map_node.local_to_map(global_position)
		var local_center = map_node.map_to_local(map_pos)
		var world_center = map_node.global_transform * local_center
		centro_operativo.x = world_center.x
		centro_operativo.z = world_center.z
		centro_operativo.y = world_center.y
	else:
		centro_operativo.x = floor(global_position.x) + 0.5
		centro_operativo.z = floor(global_position.z) + 0.5
		centro_operativo.y = 0.0
	grid_visual.global_position = Vector3(centro_operativo.x, VOID_ALTURA_SUELO_MUNDO, centro_operativo.z)
	perimeter_visual.global_position = Vector3(centro_operativo.x, VOID_ALTURA_SUELO_MUNDO, centro_operativo.z)
	_limpiar_visuales_internas()
	_dibujar_relleno_fantasma()

func _on_void_input_event(_camera, event, _position, _normal, _shape_idx):
	if not esta_construido or esta_activado:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		activar_void()
		get_viewport().set_input_as_handled()

## Activar el Void (clic derecho cuando está latente).
func activar_void():
	if esta_activado:
		return
	esta_activado = true
	_quitar_colision_huella()
	_quitar_pulso_cuerpo()
	if BuildingManager:
		BuildingManager.register_building(self)
	var map_node = get_tree().current_scene.find_child("GridMap", true, false) if get_tree() else null
	if map_node:
		var map_pos = map_node.local_to_map(global_position)
		var local_center = map_node.map_to_local(map_pos)
		var world_center = map_node.global_transform * local_center
		centro_operativo.x = world_center.x
		centro_operativo.z = world_center.z
		centro_operativo.y = world_center.y
	else:
		centro_operativo.x = floor(global_position.x) + 0.5
		centro_operativo.z = floor(global_position.z) + 0.5
		centro_operativo.y = 0.0
	activar_modo_activo()
	_limpiar_visuales_internas()

func check_ground():
	esta_construido = true
	esta_activado = true
	if BuildingManager:
		BuildingManager.register_building(self)
	collision_layer = GameConstants.LAYER_EDIFICIOS
	collision_mask = GameConstants.LAYER_EDIFICIOS
	var map_node = get_tree().current_scene.find_child("GridMap", true, false) if get_tree() else null
	if map_node:
		var map_pos = map_node.local_to_map(global_position)
		var local_center = map_node.map_to_local(map_pos)
		centro_operativo = map_node.global_transform * local_center
	else:
		centro_operativo = global_position
	_recuperar_estado_guardado()
	if not esta_activado:
		_mostrar_visual_latente()
		return
	activar_modo_activo()
	_limpiar_visuales_internas()
	_aplicar_tiles_ya_limpiados_si_cargado()

func _actualizar_mi_estado_global():
	var map_node = get_tree().current_scene.find_child("GridMap", true, false) if get_tree() else null
	if not map_node or not esta_construido:
		return
	var tiles_ser: Array = []
	for t in tiles_a_limpiar:
		tiles_ser.append({"x": t.x, "y": t.y, "z": t.z})
	var datos = {
		"tiles": tiles_ser,
		"tiempo": tiempo_acumulado,
		"activado": esta_activado
	}
	GlobalInventory.registrar_estado(map_node.local_to_map(global_position), datos)

func _recuperar_estado_guardado():
	var map_node = get_tree().get_first_node_in_group("MapaPrincipal")
	if not map_node:
		return
	var celda = map_node.local_to_map(global_position)
	var e = GlobalInventory.obtener_estado(celda)
	if e.is_empty():
		return
	var tiles_ser = e.get("tiles", [])
	if tiles_ser.is_empty():
		return
	tiles_a_limpiar.clear()
	for d in tiles_ser:
		tiles_a_limpiar.append(Vector3i(d.get("x", 0), d.get("y", 0), d.get("z", 0)))
	tiempo_acumulado = float(e.get("tiempo", 0.0))
	esta_activado = e.get("activado", true)

func _aplicar_tiles_ya_limpiados_si_cargado():
	var full_list: Array[Vector3i] = []
	for x in range(-radio, radio + 1):
		for z in range(-radio, radio + 1):
			if Vector2(x, z).length() <= radio:
				full_list.append(Vector3i(x, 0, z))
	var map_node = get_tree().current_scene.find_child("GridMap", true, false) if get_tree() else null
	if not map_node:
		return
	for t in full_list:
		if t in tiles_a_limpiar:
			continue
		var tile_global = map_node.local_to_map(centro_operativo) + t
		map_node.set_cell_item(tile_global, GameConstants.TILE_VACIO)
		_añadir_cuadrito_rojo(t)

func get_footprint_offsets() -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for x in range(-radio, radio + 1):
		for z in range(-radio, radio + 1):
			if Vector2(x, z).length() <= radio:
				out.append(Vector2i(x, z))
	return out

func es_suelo_valido(_id): return true

func desconectar_sifon():
	if BuildingManager:
		BuildingManager.unregister_building(self)
	_quitar_colision_huella()
	_quitar_pulso_cuerpo()
	esta_construido = false
	esta_activado = false
	grid_visual.visible = false
	perimeter_visual.visible = false
	if input_event.is_connected(_on_void_input_event):
		input_event.disconnect(_on_void_input_event)
