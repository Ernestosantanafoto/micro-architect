extends Node3D

@export var move_sensitivity = GameConstants.CAMARA_SENSIBILIDAD
@onready var elevation = $CameraElevation
@onready var camera = $CameraElevation/Camera3D
@onready var grid_plane = $MeshInstance3D

var _is_dragging = false

func _ready():
	elevation.rotation_degrees.x = GameConstants.CAMARA_INCLINACION_X
	camera.position.z = GameConstants.CAMARA_ZOOM_INICIAL

func _unhandled_input(event):
	# Si el ratón está sobre UI (F1, F2, etc.), no zoom ni arrastre
	if _is_mouse_over_ui(): return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_is_dragging = event.pressed
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera.size = max(GameConstants.CAMARA_ZOOM_MIN, camera.size - GameConstants.CAMARA_ZOOM_PASO)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera.size = min(GameConstants.CAMARA_ZOOM_MAX, camera.size + GameConstants.CAMARA_ZOOM_PASO)

	if event is InputEventMouseMotion and _is_dragging:
		var movement = Vector3(-event.relative.x, 0, -event.relative.y)
		position += movement * move_sensitivity

func _process(_delta):
	_set_grid_zoom_fade(camera.size)

## Ajusta zoom (y posición) para que el rectángulo en XZ quepa en pantalla.
## Solo aleja el zoom, nunca acerca: mantiene la distancia máxima alcanzada.
## Margen extra para que la cuadrícula no toque los bordes (salvo que se supere ZOOM_MAX).
func fit_rect_in_view(center_x: float, center_z: float, size_x: float, size_z: float, margin: float = -1.0) -> void:
	if margin < 0:
		margin = GameConstants.CAMARA_SELECCION_MARGEN
	var vp = get_viewport().get_visible_rect().size
	if vp.y <= 0:
		return
	var aspect = vp.x / vp.y
	var half_w = size_x / 2.0
	var half_h = size_z / 2.0
	var size_for_width = half_w / aspect
	var size_for_height = half_h
	var required = maxf(size_for_width, size_for_height) * margin
	# Solo alejar: nunca reducir camera.size (mantener la distancia máxima hasta ese momento)
	var new_size = maxf(camera.size, required)
	new_size = clampf(new_size, GameConstants.CAMARA_ZOOM_MIN, GameConstants.CAMARA_ZOOM_MAX)
	camera.size = new_size
	position.x = center_x
	position.z = center_z

func _set_grid_zoom_fade(camera_size: float) -> void:
	if not grid_plane: return
	var mat = grid_plane.get_surface_override_material(0)
	if not mat or not (mat is ShaderMaterial): return
	# Desvanecer grid entre tamaño 70 y zoom máximo (cotas máximas = alejado)
	var fade_start = 70.0
	var fade_end = float(GameConstants.CAMARA_ZOOM_MAX)
	var t = (camera_size - fade_start) / (fade_end - fade_start)
	var zoom_fade = clampf(t, 0.0, 1.0)
	mat.set_shader_parameter("zoom_fade", zoom_fade)

func _is_mouse_over_ui() -> bool:
	var ventanas = get_tree().get_nodes_in_group("VentanasUI")
	for v in ventanas:
		if v.visible:
			# Buscamos controles hijos que estén capturando el ratón
			var controles = v.find_children("*", "Control", true, false)
			for c in controles:
				if c.is_visible_in_tree() and c.get_global_rect().has_point(c.get_global_mouse_position()):
					return true
	return false
