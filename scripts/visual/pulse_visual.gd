# Visual opcional para flujos de energía (NO afecta lógica)
# Si source_origen está definido y rota, este visual se destruye para no flotar en el aire
class_name PulseVisual
extends Node3D

var from_pos: Vector3
var to_pos: Vector3
var duration: float = 0.5
var timer: float = 0.0
var color: Color = Color.WHITE
var source_origen: Node = null  # Si rota, nos destruimos
var _rotacion_inicial: float = 0.0

var _mesh: MeshInstance3D

func _ready():
	add_to_group("PulseVisual")
	_mesh = MeshInstance3D.new()
	_mesh.mesh = SphereMesh.new()
	add_child(_mesh)
	_actualizar_material()

func setup(from: Vector3, to: Vector3, dur: float, col: Color, origen: Node = null, tipo_recurso: String = ""):
	from_pos = from
	to_pos = to
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
	var mat = StandardMaterial3D.new()
	mat.albedo_color = color
	mat.emission_enabled = true
	mat.emission = color
	mat.emission_energy_multiplier = 3.0
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
	global_position = from_pos.lerp(to_pos, progress)
	if progress >= 1.0:
		queue_free()
