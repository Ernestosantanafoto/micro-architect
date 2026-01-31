extends Area3D

enum TipoPrisma { RECTO, ANGULO }
@export var tipo: TipoPrisma = TipoPrisma.RECTO
@export var alcance_maximo: int = GameConstants.ALCANCE_PRISMA
@export var es_tier2: bool = false

var beam_emitter: BeamEmitter 
var pulse_scene = preload("res://scenes/world/energy_pulse.tscn")
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
		if area.distancia_recorrida < GameConstants.UMBRAL_ESCALA_MINIMA: return
		
		var dir_salida = _calcular_rebote(area.direccion)
		if dir_salida != Vector3.ZERO:
			_procesar_secuencia_rebote(area, dir_salida)
		else:
			area.queue_free()

func _procesar_secuencia_rebote(bola, dir_salida):
	bola.set_process(false) 
	var velocidad = GameConstants.PULSO_VELOCIDAD_BASE
	
	while is_instance_valid(bola) and bola.global_position.distance_to(global_position) > GameConstants.PRISMA_DISTANCIA_CENTRO_MIN:
		var direccion_al_centro = (global_position - bola.global_position).normalized()
		bola.global_position += direccion_al_centro * velocidad * get_process_delta_time()
		await get_tree().process_frame
	
	if not is_instance_valid(bola): return
	bola.global_position = global_position
	
	await get_tree().create_timer(GameConstants.TIEMPO_REBOTE_PRISMA).timeout
	
	if is_instance_valid(bola): 
		_generar_bola_salida(bola, dir_salida)

func _generar_bola_salida(original, nueva_dir):
	var p = pulse_scene.instantiate()
	get_tree().current_scene.add_child(p)
	p.global_position = global_position + (nueva_dir * GameConstants.OFFSET_SPAWN_PULSO)
	p.direccion = nueva_dir
	
	if p.has_method("configurar_pulso"):
		var col = Color.WHITE
		if original.mesh and original.mesh.get_active_material(0):
			col = original.mesh.get_active_material(0).albedo_color
		p.configurar_pulso(original.tipo_recurso, col, original.scale.x)
		p.cantidad_energia = original.cantidad_energia
		
		# SOLUCIÓN: Reiniciar distancia y ampliar si es T2
		p.distancia_recorrida = 0.0
		p.distancia_max = 20.0 if es_tier2 else GameConstants.PULSO_RANGO_MAXIMO

	if PulseValidator: PulseValidator.registrar_pulso(p, self)
	original.queue_free()

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
func desconectar_sifon(): 
	if beam_emitter: beam_emitter.apagar()
	collision_layer = 0
	esta_construido = false
func es_suelo_valido(id): 
	return id == GameConstants.TILE_VACIO
