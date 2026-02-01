extends Area3D

# Variables de Estado (Estas cambian dinámicamente, se quedan aquí)
var tipo_recurso: String = ""
var cantidad_energia: int = 1
var direccion = Vector3.ZERO
var distancia_recorrida = 0.0

# Referencias
@onready var mesh = $MeshInstance3D

# Configuración (Tomada de Constantes Globales por defecto)
# Usamos @export para permitir cambios manuales en el editor si fuera necesario en un caso raro
var velocidad: float = GameConstants.PULSO_VELOCIDAD_BASE
var distancia_max: float = GameConstants.PULSO_RANGO_MAXIMO

func _process(delta):
	# Si no hay dirección, no calculamos nada (Ahorro de CPU)
	if direccion == Vector3.ZERO: return
	
	# Movimiento
	var movimiento = direccion * velocidad * delta
	global_position += movimiento
	distancia_recorrida += movimiento.length()
	
	# Validación de seguridad
	if distancia_recorrida >= distancia_max:
		_morir()

func configurar_pulso(nuevo_tipo: String, nuevo_color: Color, multiplicador_escala: float = 1.0):
	tipo_recurso = nuevo_tipo
	
	# Esperar si el nodo no está listo (Seguridad)
	if not is_inside_tree(): await ready
	
	# 1. ESCALA
	scale = Vector3.ONE * multiplicador_escala
	
	# 2. MATERIAL VISUAL
	var mat = StandardMaterial3D.new()
	mat.albedo_color = nuevo_color
	mat.emission_enabled = true
	mat.emission = nuevo_color
	# Usamos la constante de brillo
	mat.emission_energy_multiplier = GameConstants.PULSO_INTENSIDAD_BRILLO
	
	if mesh:
		mesh.set_surface_override_material(0, mat)

func _morir():
	# Animación de salida usando la constante de tiempo
	var t = create_tween()
	t.tween_property(self, "scale", Vector3.ZERO, GameConstants.PULSO_TIEMPO_DESAPARECER)
	t.finished.connect(queue_free)
