extends Area3D

var esta_construido: bool = false
var radio = GameConstants.VOID_GEN_RADIO
var tiles_a_limpiar: Array[Vector3i] = []
var tiempo_acumulado: float = 0.0

# Posición fija donde se realizó el clic (para evitar que la caída afecte al borrado)
var centro_operativo: Vector3 = Vector3.ZERO 

@onready var grid_visual = $GridVisual
var perimeter_visual: Node3D = null

func _ready():
	# --- CORRECCIÓN CRÍTICA DE COLOCACIÓN ---
	# Si nace como fantasma, desactivamos colisiones para que no estorbe al Raycast de colocación.
	if esta_construido:
		collision_layer = GameConstants.LAYER_EDIFICIOS
		collision_mask = GameConstants.LAYER_EDIFICIOS
	else:
		collision_layer = 0
		collision_mask = 0
	# ----------------------------------------

	perimeter_visual = Node3D.new()
	add_child(perimeter_visual)
	
	# MODO DORMIDO: Nace invisible y con el proceso apagado para no molestar en los menús
	grid_visual.visible = false
	perimeter_visual.visible = false
	set_process(false)
	
	_preparar_datos_limpieza()
	_generar_perimetro_visual_inteligente()
	
	# Si cargamos una partida y ya existe, se activa solo
	if esta_construido:
		check_ground()

# --- FUNCIÓN DE ACTIVACIÓN (Llamada por ConstructionManager) ---
func activar_modo_activo():
	if grid_visual.visible: return 
	
	grid_visual.visible = true
	perimeter_visual.visible = true
	
	# CORRECCIÓN DE PERSPECTIVA:
	# Despegamos los visuales del padre para controlarlos manualmente y pegarlos al suelo
	grid_visual.set_as_top_level(true)
	perimeter_visual.set_as_top_level(true)
	
	set_process(true)

func _process(delta):
	# 1. CÁLCULO DE POSICIÓN VISUAL (PROYECCIÓN LÁSER)
	var target_x = 0.0
	var target_z = 0.0
	
	if not esta_construido:
		# Si está en la mano, sigue la X y Z del fantasma actual
		target_x = global_position.x
		target_z = global_position.z
	else:
		# Si ya está construido, se queda clavado donde hicimos clic (centro operativo)
		target_x = centro_operativo.x
		target_z = centro_operativo.z
	
	# 2. FIJAR AL SUELO ABSOLUTO
	# Esto corrige el paralaje. La rejilla siempre está en Y = 0.05
	var altura_suelo = 0.05 
	
	if grid_visual:
		grid_visual.global_position = Vector3(target_x, altura_suelo, target_z)
		
	if perimeter_visual:
		perimeter_visual.global_position = Vector3(target_x, altura_suelo + GameConstants.VOID_GEN_PERIMETRO_OFFSET_Y, target_z)

	# 3. LÓGICA DE TRABAJO (Solo si está construido)
	if not esta_construido: return
	
	tiempo_acumulado += delta
	if tiempo_acumulado >= GameConstants.VOID_GEN_TIEMPO_TILE:
		tiempo_acumulado = 0.0
		_limpiar_siguiente_tile()

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

# --- VISUALES ---

func _generar_perimetro_visual_inteligente():
	for c in perimeter_visual.get_children(): c.queue_free()
	
	var grosor = GameConstants.VOID_GEN_PERIMETRO_GROSOR
	var altura_y = GameConstants.VOID_GEN_ALTURA_VISUAL + GameConstants.VOID_GEN_PERIMETRO_OFFSET_Y
	
	var mesh_h = BoxMesh.new(); mesh_h.size = Vector3(1.0, grosor, grosor)
	var mesh_v = BoxMesh.new(); mesh_v.size = Vector3(grosor, grosor, 1.0)
	
	var mat = StandardMaterial3D.new()
	mat.albedo_color = GameConstants.VOID_GEN_COLOR_BORDE
	mat.emission_enabled = true
	mat.emission = GameConstants.VOID_GEN_COLOR_BORDE
	mat.emission_energy_multiplier = GameConstants.VOID_GEN_PERIMETRO_BRILLO
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	
	for x in range(-radio - 1, radio + 2):
		for z in range(-radio - 1, radio + 2):
			if _es_tile_valido(x, z):
				# Dibujamos línea solo si el vecino NO es válido (Borde exterior)
				if not _es_tile_valido(x, z - 1): _crear_tira(mesh_h, mat, Vector3(x, altura_y, z - 0.5))
				if not _es_tile_valido(x, z + 1): _crear_tira(mesh_h, mat, Vector3(x, altura_y, z + 0.5))
				if not _es_tile_valido(x - 1, z): _crear_tira(mesh_v, mat, Vector3(x - 0.5, altura_y, z))
				if not _es_tile_valido(x + 1, z): _crear_tira(mesh_v, mat, Vector3(x + 0.5, altura_y, z))

func _es_tile_valido(x, z) -> bool:
	return Vector2(x, z).length() <= radio

func _crear_tira(mesh_ref, mat_ref, pos):
	var mi = MeshInstance3D.new()
	mi.mesh = mesh_ref
	mi.material_override = mat_ref
	mi.position = pos
	perimeter_visual.add_child(mi)

func _dibujar_relleno_fantasma():
	_limpiar_visuales_internas()
	for t in tiles_a_limpiar:
		_añadir_cuadrito_rojo(t)

func _limpiar_visuales_internas():
	for child in grid_visual.get_children():
		child.queue_free()

func _añadir_cuadrito_rojo(pos_local: Vector3i):
	var box_mesh = BoxMesh.new()
	box_mesh.size = GameConstants.VOID_GEN_BOX_SIZE * GameConstants.VOID_GEN_FACTOR_RELLENO 
	
	var mat = StandardMaterial3D.new()
	mat.albedo_color = GameConstants.VOID_GEN_COLOR_AREA
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	
	var mesh_inst = MeshInstance3D.new()
	mesh_inst.mesh = box_mesh
	mesh_inst.material_override = mat
	mesh_inst.position = Vector3(pos_local.x, GameConstants.VOID_GEN_ALTURA_VISUAL, pos_local.z)
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
func check_ground():
	esta_construido = true
	
	# AHORA SÍ activamos colisiones para que se pueda seleccionar o borrar
	collision_layer = GameConstants.LAYER_EDIFICIOS
	collision_mask = GameConstants.LAYER_EDIFICIOS
	
	# Guardamos el centro y activamos visuales
	centro_operativo = global_position
	activar_modo_activo()
	_limpiar_visuales_internas()

func es_suelo_valido(_id): return true 
func desconectar_sifon(): esta_construido = false
