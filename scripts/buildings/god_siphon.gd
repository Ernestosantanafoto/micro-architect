extends Area3D

# --- CONFIGURACIÓN DIVINA (Editables desde UI) ---
var recurso_actual = GameConstants.RECURSO_STABILITY
var color_elegido = GameConstants.COLOR_STABILITY
var escala_elegida = 1.0
var valor_energia = 1
var ticks_por_disparo = 5

# --- ESTADO ---
var contador_ticks = 0
var esta_construido: bool = false

# --- COMPONENTES ---
var beam_emitter: BeamEmitter 
var pulse_scene = preload("res://scenes/world/energy_pulse.tscn")

func _ready():
	beam_emitter = BeamEmitter.new()
	add_child(beam_emitter)
	
	# Conectarse al reloj global
	var main = get_tree().current_scene
	if main.has_signal("game_tick"):
		main.game_tick.connect(_on_game_tick)
	
	# Configuración de colisión e input
	collision_layer = GameConstants.LAYER_EDIFICIOS
	input_ray_pickable = true
	input_event.connect(_on_input_event)
	
	esta_construido = false

func _process(_delta):
	if esta_construido:
		var map = get_tree().current_scene.find_child("GridMap")
		var space = get_world_3d().direct_space_state
		if map:
			var dir = -global_transform.basis.z
			beam_emitter.dibujar_haz(global_position, dir, 10, color_elegido, map, space)
			if PulseValidator: PulseValidator.registrar_haz_activo(self)
	else:
		beam_emitter.apagar()
		if PulseValidator: PulseValidator.desregistrar_haz_activo(self)

# --- LÓGICA DE DISPARO AUTOMÁTICO ---
func _on_game_tick(_c):
	if not esta_construido: return
	
	contador_ticks += 1
	if contador_ticks >= ticks_por_disparo:
		disparar()
		contador_ticks = 0

func disparar():
	var p = pulse_scene.instantiate()
	get_tree().current_scene.add_child(p)
	
	p.global_position = global_position + Vector3(0, 0.5, 0)
	p.direccion = -global_transform.basis.z
	
	if p.has_method("configurar_pulso"):
		p.configurar_pulso(recurso_actual, color_elegido, escala_elegida)
		p.cantidad_energia = valor_energia
	
	if PulseValidator: PulseValidator.registrar_pulso(p, self)

# --- INTERACCIÓN CON EL MENÚ ---
func _on_input_event(_camera, event, _position, _normal, _shape_idx):
	if not esta_construido: return
	
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			_gestionar_clic_derecho()
			get_viewport().set_input_as_handled()

func _gestionar_clic_derecho():
	# Buscar la UI específica del GodSiphon
	# Opción 1: Por nombre directo
	var menu = get_tree().current_scene.find_child("GodSiphonUI", true, false)
	
	# Opción 2: Buscar en el grupo VentanasUI la que tiene sifon_activo
	if not menu:
		var menus = get_tree().get_nodes_in_group("VentanasUI")
		for m in menus:
			# La UI del GodSiphon tiene la variable sifon_activo
			if m.get("sifon_activo") != null or "GodSiphon" in m.name or "Siphon" in m.name:
				menu = m
				break
	
	if menu and menu.has_method("abrir"):
		# Evitar parpadeo si ya está abierto para este sifón
		if menu.visible and menu.get("sifon_activo") == self:
			return
		menu.abrir(self)
	else:
		print("ERROR: No encuentro 'GodSiphonUI' en la escena.")

# --- CONFIGURACIÓN DESDE LA UI ---
func configurar_dios(recurso, color, escala, valor, freq):
	recurso_actual = recurso
	color_elegido = color
	escala_elegida = escala
	valor_energia = valor
	ticks_por_disparo = max(1, freq)
	
	_actualizar_visuales()

func _actualizar_visuales():
	var mesh_visuals = find_children("*", "GeometryInstance3D")
	for m in mesh_visuals:
		var mat = StandardMaterial3D.new()
		mat.albedo_color = color_elegido
		mat.emission_enabled = true
		mat.emission = color_elegido
		mat.emission_energy_multiplier = 3.0
		
		if m is CSGShape3D:
			m.material_override = mat
		elif m is MeshInstance3D:
			m.set_surface_override_material(0, mat)

# --- API CONSTRUCCIÓN ---
func check_ground():
	collision_layer = GameConstants.LAYER_EDIFICIOS
	esta_construido = true
	_actualizar_visuales()

func desconectar_sifon():
	collision_layer = 0
	esta_construido = false
	contador_ticks = 0
	if beam_emitter: beam_emitter.apagar()
	if PulseValidator: PulseValidator.desregistrar_haz_activo(self)

func es_suelo_valido(_id):
	return true 

func recibir_luz_instantanea(_c, _r, _d): 
	pass
