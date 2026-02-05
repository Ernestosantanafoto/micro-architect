extends CanvasLayer

## Viñeta radial que depende del zoom: cercano = casi inexistente (solo márgenes); lejano = un poco más amplia.
@onready var vignette_rect: ColorRect = $VignetteRect

var _camera: Camera3D
var _material: ShaderMaterial

# Zoom cercano (suelo): solo márgenes, casi invisible
const RADIUS_INNER_ZOOM_CLOSE := 0.88
const RADIUS_OUTER_ZOOM_CLOSE := 1.35
# Zoom lejano (alto): un poco más amplia que antes
const RADIUS_INNER_ZOOM_FAR := 0.26
const RADIUS_OUTER_ZOOM_FAR := 0.92

func _ready() -> void:
	_camera = get_viewport().get_camera_3d()
	if vignette_rect and vignette_rect.material is ShaderMaterial:
		_material = vignette_rect.material as ShaderMaterial

func _process(_delta: float) -> void:
	if not _material or not is_instance_valid(_camera):
		if not _camera:
			_camera = get_viewport().get_camera_3d()
		return
	var size := _camera.size
	var t := clampf((size - GameConstants.CAMARA_ZOOM_MIN) / (GameConstants.CAMARA_ZOOM_MAX - GameConstants.CAMARA_ZOOM_MIN), 0.0, 1.0)
	t = t * t * (3.0 - 2.0 * t)
	_material.set_shader_parameter("radius_inner", lerpf(RADIUS_INNER_ZOOM_CLOSE, RADIUS_INNER_ZOOM_FAR, t))
	_material.set_shader_parameter("radius_outer", lerpf(RADIUS_OUTER_ZOOM_CLOSE, RADIUS_OUTER_ZOOM_FAR, t))
