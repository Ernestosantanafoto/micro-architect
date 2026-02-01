extends Area3D

enum TipoPrisma { RECTO, ANGULO }
@export var tipo: TipoPrisma = TipoPrisma.RECTO
@export var alcance_maximo: int = GameConstants.ALCANCE_PRISMA
@export var es_tier2: bool = false

var beam_emitter: BeamEmitter
var esta_construido: bool = false
var color_haz_actual = Color.WHITE
var direccion_salida_fija = Vector3.FORWARD
var tiempo_ultima_luz = -1000.0

var mesh_visual: MeshInstance3D = null
var material_instancia: StandardMaterial3D = null

func _ready():
	beam_emitter = BeamEmitter.new()
	add_child(beam_emitter)
	
	if not area_entered.is_connected(_on_area_entered): 
		area_entered.connect(_on_area_entered)
	
	collision_layer = GameConstants.LAYER_EDIFICIOS
	collision_mask = GameConstants.LAYER_PULSOS
	esta_construido = false 
	
	if es_tier2:
		alcance_maximo = GameConstants.ALCANCE_PRISMA_T2
	
	# Configuración visual del cristal
	var mallas = find_children("*", "MeshInstance3D", true)
	if mallas.size() > 0:
		mesh_visual = mallas[0]
		var mat_original = mesh_visual.get_active_material(0)
		if not mat_original: mat_original = mesh_visual.get_surface_override_material(0)
		if mat_original:
			material_instancia = mat_original.duplicate()
			mesh_visual.set_surface_override_material(0, material_instancia)
			_animar_cristal(Color.WHITE, false)

func _process(_delta):
	if not esta_construido: 
		beam_emitter.apagar()
		return
	
	if Time.get_ticks_msec() - tiempo_ultima_luz < GameConstants.TIEMPO_PERSISTENCIA_LUZ:
		var map = get_tree().current_scene.find_child("GridMap")
		var space = get_world_3d().direct_space_state
		if map:
			beam_emitter.dibujar_haz(global_position, direccion_salida_fija, alcance_maximo, color_haz_actual, map, space)
			if PulseValidator: PulseValidator.registrar_haz_activo(self)
			_animar_cristal(color_haz_actual, true)
	else:
		beam_emitter.apagar()
		if PulseValidator: PulseValidator.desregistrar_haz_activo(self)
		_animar_cristal(Color.WHITE, false)

func recibir_energia_numerica(cantidad: int, tipo_recurso: String, origen: Node) -> void:
	if not esta_construido: return
	if not is_instance_valid(origen): return
	var dir_entrada = (global_position - origen.global_position).normalized()
	var dir_salida = _calcular_rebote(dir_entrada)
	if dir_salida != Vector3.ZERO:
		_procesar_energia_numerica(cantidad, tipo_recurso, dir_salida)

func _procesar_energia_numerica(cantidad: int, tipo_recurso: String, dir_salida: Vector3):
	var map = get_tree().current_scene.find_child("GridMap")
	var space = get_world_3d().direct_space_state
	if not map or not space or not EnergyManager:
		return
	var dir_flat = Vector3(dir_salida.x, 0, dir_salida.z).normalized()
	var color_recurso = _color_por_tipo(tipo_recurso)
	var from_pos = global_position + (dir_salida * GameConstants.OFFSET_SPAWN_PULSO)
	var resultado = beam_emitter.obtener_objetivo(global_position, dir_salida, alcance_maximo, map, space, self)
	var to_pos = resultado["impact_pos"] if resultado else from_pos + dir_flat * alcance_maximo
	if EnergyManager.MOSTRAR_VISUAL_PULSO:
		EnergyManager.spawn_pulse_visual(from_pos, to_pos, color_recurso, self)
	if resultado:
		EnergyManager.register_flow(self, resultado["target"], cantidad, tipo_recurso, color_recurso)

func recibir_luz_instantanea(color: Color, _recurso: String, dir_entrada_global: Vector3):
	if not esta_construido: return
	if scale.length_squared() < GameConstants.UMBRAL_ESCALA_MINIMA: return
	
	var dir_salida = _calcular_rebote(dir_entrada_global)
	if dir_salida != Vector3.ZERO:
		tiempo_ultima_luz = Time.get_ticks_msec()
		color_haz_actual = color
		direccion_salida_fija = dir_salida
		_animar_cristal(color, true)

func _on_area_entered(area):
	if not esta_construido: return
	if area.is_in_group("Pulsos"):
		area.queue_free()

func _color_por_tipo(tipo_recurso: String) -> Color:
	if "Stability" in tipo_recurso: return GameConstants.COLOR_STABILITY
	if "Charge" in tipo_recurso: return GameConstants.COLOR_CHARGE
	if "Up-Quark" in tipo_recurso: return GameConstants.COLOR_UP_QUARK
	if "Down-Quark" in tipo_recurso: return GameConstants.COLOR_DOWN_QUARK
	return GameConstants.COLOR_CHARGE

func _calcular_rebote(dir_entrada_global: Vector3) -> Vector3:
	var dir_local = (global_transform.basis.inverse() * dir_entrada_global).normalized()
	if tipo == TipoPrisma.RECTO:
		if abs(dir_local.z) > GameConstants.UMBRAL_ALINEACION_RECTA: return dir_entrada_global
	elif tipo == TipoPrisma.ANGULO:
		var normal = Vector3(1, 0, 1).normalized()
		if dir_local.dot(normal) < GameConstants.UMBRAL_REFLEXION_ANGULO:
			var salida_local = dir_local.bounce(normal)
			var salida_global = global_transform.basis * salida_local
			return Vector3(round(salida_global.x), 0, round(salida_global.z))
	return Vector3.ZERO

func _animar_cristal(color_objetivo: Color, encendido: bool):
	if not material_instancia: return
	var target_albedo = color_objetivo if encendido else GameConstants.PRISMA_COLOR_APAGADO
	if encendido: target_albedo.a = GameConstants.PRISMA_ALPHA_ENCENDIDO
	var t = create_tween().set_parallel(true)
	t.tween_property(material_instancia, "albedo_color", target_albedo, 0.2)
	t.tween_property(material_instancia, "emission_energy_multiplier", GameConstants.PRISMA_BRILLO_INTENSIDAD if encendido else 0.0, 0.2)

func check_ground(): 
	collision_layer = GameConstants.LAYER_EDIFICIOS
	esta_construido = true
	if BuildingManager: BuildingManager.register_building(self)
func desconectar_sifon(): 
	if BuildingManager: BuildingManager.unregister_building(self)
	if beam_emitter: beam_emitter.apagar()
	collision_layer = 0
	esta_construido = false
func es_suelo_valido(id): 
	return id == GameConstants.TILE_VACIO
