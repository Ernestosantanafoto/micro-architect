extends Node3D

@export var move_sensitivity = GameConstants.CAMARA_SENSIBILIDAD
@onready var elevation = $CameraElevation
@onready var camera = $CameraElevation/Camera3D

var _is_dragging = false

func _ready():
	elevation.rotation_degrees.x = GameConstants.CAMARA_INCLINACION_X
	camera.position.z = GameConstants.CAMARA_ZOOM_INICIAL

func _unhandled_input(event):
	# SOLUCIÓN: Si el ratón está sobre UI, ignoramos la rueda
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
