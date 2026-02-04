# Visual opcional para flujos de energía (NO afecta lógica)
# Si source_origen está definido y rota, este visual se destruye para no flotar en el aire
# Apariencia base: edita assets/pulse_visual_material.tres en el Inspector (color/emisión se aplican por tipo en runtime).
class_name PulseVisual
extends Node3D

const MATERIAL_BASE_PATH := "res://assets/pulse_visual_material.tres"

var from_pos: Vector3
var to_pos: Vector3
var duration: float = 0.5
var timer: float = 0.0
var color: Color = Color.WHITE
var source_origen: Node = null  # Si rota, nos destruimos
var _rotacion_inicial: float = 0.0
var _path_waypoints: Array = []  # Si no vacío, la bola recorre estos puntos (path del haz)
var _trail_positions: Array[Vector3] = []  # Posiciones recientes para estela (solo si TRAIL_PULSO_HABILITADO)
var _trail_mesh_instance: MeshInstance3D = null  # Hijo: línea de la estela

var _mesh: MeshInstance3D

func _ready():
	add_to_group("PulseVisual")
	_mesh = MeshInstance3D.new()
	_mesh.mesh = SphereMesh.new()
	add_child(_mesh)
	_actualizar_material()
	if GameConstants.TRAIL_PULSO_HABILITADO:
		_trail_mesh_instance = MeshInstance3D.new()
		add_child(_trail_mesh_instance)

func setup(from: Vector3, to: Vector3, dur: float, col: Color, origen: Node = null, tipo_recurso: String = "", path_waypoints: Array = []):
	from_pos = from
	to_pos = to
	_path_waypoints = path_waypoints.duplicate() if path_waypoints.size() > 0 else []
	# Si hay waypoints, duración = longitud total del path / velocidad (bola recorre el path a velocidad constante)
	if _path_waypoints.size() >= 2:
		var path_len: float = 0.0
		for i in range(_path_waypoints.size() - 1):
			path_len += (Vector3(_path_waypoints[i]) - Vector3(_path_waypoints[i + 1])).length()
		duration = path_len / GameConstants.PULSO_VELOCIDAD_VISUAL if path_len > 0.01 else dur
	else:
		duration = dur
	color = col
	source_origen = origen
	_rotacion_inicial = origen.global_rotation.y if origen else 0.0
	global_position = from_pos
	# Escala por tipo: elemental (1/3), condensada (2/3), resto (1)
	var scale_factor := 1.0
	if tipo_recurso == "Stability" or tipo_recurso == "Charge":
		scale_factor = 1.0 / 3.0
	elif tipo_recurso.begins_with("Compressed-"):
		scale_factor = 2.0 / 3.0
	scale = Vector3(scale_factor, scale_factor, scale_factor)
	_actualizar_material()

func _actualizar_material():
	if not _mesh:
		return
	var mat: StandardMaterial3D
	var base_mat: StandardMaterial3D = load(MATERIAL_BASE_PATH) as StandardMaterial3D if ResourceLoader.exists(MATERIAL_BASE_PATH) else null
	if base_mat:
		mat = base_mat.duplicate()
	else:
		mat = StandardMaterial3D.new()
		mat.emission_enabled = true
		mat.emission_energy_multiplier = 3.0
	mat.albedo_color = color
	mat.emission = color
	_mesh.set_surface_override_material(0, mat)

## Dado progress en [0, 1], devuelve la posición interpolada a lo largo de _path_waypoints (por distancia).
func _posicion_en_path(progress: float) -> Vector3:
	if _path_waypoints.size() < 2:
		return from_pos.lerp(to_pos, progress)
	var points = _path_waypoints
	var total_len: float = 0.0
	for i in range(points.size() - 1):
		total_len += (Vector3(points[i]) - Vector3(points[i + 1])).length()
	if total_len < 0.001:
		return Vector3(points[0])
	var target_dist = progress * total_len
	var acc: float = 0.0
	for i in range(points.size() - 1):
		var a = Vector3(points[i])
		var b = Vector3(points[i + 1])
		var seg_len = a.distance_to(b)
		if acc + seg_len >= target_dist:
			var t = (target_dist - acc) / seg_len if seg_len > 0.001 else 1.0
			return a.lerp(b, t)
		acc += seg_len
	return Vector3(points[points.size() - 1])

## Construye la malla de la estela (segmentos en espacio local: más reciente = posición actual).
func _actualizar_trail_mesh() -> void:
	if not _trail_mesh_instance or _trail_positions.size() < 2:
		if _trail_mesh_instance:
			_trail_mesh_instance.mesh = null
		return
	var trail_color := Color(color.r, color.g, color.b, 0.5)
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = trail_color
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	var im := ImmediateMesh.new()
	im.surface_begin(Mesh.PRIMITIVE_LINE_STRIP, mat)
	for i in range(_trail_positions.size()):
		var w: Vector3 = _trail_positions[i]
		var local_p := w - global_position
		im.surface_add_vertex(local_p)
	im.surface_end()
	_trail_mesh_instance.mesh = im

## Recarga el material desde el .tres (ignorando caché) y lo reaplica. Llamar desde botón "Actualizar visual" para ver cambios sin reiniciar.
func refresh_material_from_resource() -> void:
	if not _mesh:
		return
	var base_mat: StandardMaterial3D = ResourceLoader.load(MATERIAL_BASE_PATH, "StandardMaterial3D", ResourceLoader.CACHE_MODE_IGNORE) as StandardMaterial3D
	if base_mat:
		var mat := base_mat.duplicate()
		mat.albedo_color = color
		mat.emission = color
		_mesh.set_surface_override_material(0, mat)

func _process(delta: float) -> void:
	# Si el edificio origen fue destruido, la bola desaparece
	if source_origen != null and not is_instance_valid(source_origen):
		queue_free()
		return
	# Si el edificio origen rotó, eliminamos este visual para no flotar en el aire
	if source_origen and is_instance_valid(source_origen):
		if abs(source_origen.global_rotation.y - _rotacion_inicial) > 0.01:
			queue_free()
			return
		# Si ya no hay haz activo en el origen, la bola no debería existir (red de seguridad)
		if PulseValidator and source_origen not in PulseValidator.haces_activos:
			queue_free()
			return
	timer += delta
	var progress = clampf(timer / duration, 0.0, 1.0)
	if _path_waypoints.size() >= 2:
		global_position = _posicion_en_path(progress)
	else:
		global_position = from_pos.lerp(to_pos, progress)
	# Estela opcional: guardar posición y dibujar línea detrás
	if GameConstants.TRAIL_PULSO_HABILITADO and _trail_mesh_instance:
		_trail_positions.append(global_position)
		var n := GameConstants.TRAIL_PULSO_NUM_PUNTOS
		while _trail_positions.size() > n:
			_trail_positions.remove_at(0)
		_actualizar_trail_mesh()
	if progress >= 1.0:
		queue_free()
