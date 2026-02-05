extends Node3D

@export var move_sensitivity = GameConstants.CAMARA_SENSIBILIDAD
@onready var elevation = $CameraElevation
@onready var camera = $CameraElevation/Camera3D
@onready var grid_plane = $MeshInstance3D
@onready var grid_macro = $GridMacro

var _is_dragging = false

func _ready():
	elevation.rotation_degrees.x = GameConstants.CAMARA_INCLINACION_X
	camera.size = GameConstants.CAMARA_ZOOM_INICIAL
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

func _process(delta: float) -> void:
	# No mover/zoom con WASD/QE si hay un popup abierto o el foco está en un campo de texto
	if _debe_ignorar_teclado_camara():
		_set_grid_zoom_fade(camera.size)
		_actualizar_visibilidad_particulas_por_zoom()
		_actualizar_musica_muffle_zoom()
		return

	# WASD: movimiento lineal por teclado (sin depender de UI del ratón)
	var dir = Vector3.ZERO
	if Input.is_key_pressed(KEY_A):
		dir.x -= 1.0
	if Input.is_key_pressed(KEY_D):
		dir.x += 1.0
	if Input.is_key_pressed(KEY_S):
		dir.z += 1.0
	if Input.is_key_pressed(KEY_W):
		dir.z -= 1.0
	if dir.length_squared() > 0.0:
		dir = dir.normalized()
		position += dir * GameConstants.CAMARA_VELOCIDAD_WASD * delta

	# Q/E: zoom lineal (sin ease in/out)
	if Input.is_key_pressed(KEY_Q):
		camera.size = maxf(GameConstants.CAMARA_ZOOM_MIN, camera.size - GameConstants.CAMARA_ZOOM_VELOCIDAD_QE * delta)
	if Input.is_key_pressed(KEY_E):
		camera.size = minf(GameConstants.CAMARA_ZOOM_MAX, camera.size + GameConstants.CAMARA_ZOOM_VELOCIDAD_QE * delta)

	_set_grid_zoom_fade(camera.size)
	_actualizar_visibilidad_particulas_por_zoom()
	_actualizar_musica_muffle_zoom()

## Zoom extremo: música se apaga de forma progresiva (low-pass + ligera bajada de volumen).
func _actualizar_musica_muffle_zoom() -> void:
	var umbral = GameConstants.CAMARA_ZOOM_UMBRAL_MUSICA_MUFFLE
	if camera.size <= umbral:
		if MusicManager:
			MusicManager.set_zoom_muffle(0.0)
		return
	var rango = float(GameConstants.CAMARA_ZOOM_MAX - umbral)
	if rango <= 0.0:
		return
	var t = clampf((camera.size - umbral) / rango, 0.0, 1.0)
	# Smoothstep: transición más progresiva (suave al inicio y al final)
	var t_smooth = t * t * (3.0 - 2.0 * t)
	if MusicManager:
		MusicManager.set_zoom_muffle(t_smooth)

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
	# Grid dual: detail (1x1 azul) y macro (9x9 dorado). Transición en el mismo umbral que partículas.
	var umbral = GameConstants.CAMARA_ZOOM_UMBRAL_GRID_MACRO
	var fade_end = GameConstants.CAMARA_ZOOM_GRID_MACRO_END
	var t = clampf((camera_size - umbral) / (fade_end - umbral), 0.0, 1.0)
	var transition_t = t * t * (3.0 - 2.0 * t)
	if grid_plane:
		var mat = grid_plane.get_surface_override_material(0)
		if mat is ShaderMaterial:
			mat.set_shader_parameter("zoom_fade", transition_t)
	if grid_macro:
		var mat_macro = grid_macro.get_surface_override_material(0)
		if mat_macro is ShaderMaterial:
			mat_macro.set_shader_parameter("zoom_fade", 1.0 - transition_t)

## Por encima del umbral (≈33% zoom out) las partículas se ocultan; al acercar reaparecen (memoria: no se destruyen).
func _actualizar_visibilidad_particulas_por_zoom() -> void:
	var mostrar = camera.size < GameConstants.CAMARA_ZOOM_UMBRAL_OCULTAR_PARTICULAS
	for node in get_tree().get_nodes_in_group("PulseVisual"):
		if is_instance_valid(node):
			node.visible = mostrar

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

## True si no debemos aplicar WASD/QE: popup de guardar/cargar/opciones abierto o foco en LineEdit/TextEdit.
func _debe_ignorar_teclado_camara() -> bool:
	# Popup overlay visible (Guardar, Cargar, Opciones)
	for n in get_tree().get_nodes_in_group(GameConstants.POPUP_OVERLAY_GROUP):
		if is_instance_valid(n) and n.is_inside_tree():
			return true
	# Foco en control de texto: al escribir nombre no mover cámara
	var focus = get_viewport().gui_get_focus_owner()
	if focus is LineEdit or focus is TextEdit:
		return true
	return false
