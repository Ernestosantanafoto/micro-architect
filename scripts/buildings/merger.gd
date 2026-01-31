extends Area3D

var buffer = { "Compressed-Stability": 0, "Compressed-Charge": 0 }
var esta_construido: bool = false
var ha_disparado_una_vez: bool = false
var procesando: bool = false
var tiempo_restante_proceso: float = 0.0
var producto_pendiente = ""
var color_pendiente = Color.WHITE

var beam_emitter: BeamEmitter 
var pulse_scene = preload("res://scenes/world/energy_pulse.tscn")

var ui_root: Node3D = null
var label: Node = null 
var barra_visual: Node3D = null 

func _ready():
	beam_emitter = BeamEmitter.new()
	add_child(beam_emitter)
	if not area_entered.is_connected(_on_area_entered): area_entered.connect(_on_area_entered)
	
	collision_layer = GameConstants.LAYER_EDIFICIOS
	collision_mask = GameConstants.LAYER_PULSOS
	esta_construido = false 
	ha_disparado_una_vez = false
	
	ui_root = find_child("UI_Root", true, false)
	if ui_root:
		ui_root.set_as_top_level(true)
		barra_visual = ui_root.find_child("BarraVisual", true, false)
		label = ui_root.find_child("TextoInfo", true, false)
		if barra_visual:
			var mat = _get_material_seguro(barra_visual)
			if mat: mat.albedo_color = Color.WHITE
	
	actualizar_ui()

func _process(delta):
	# Estabilizar UI
	if ui_root and is_instance_valid(ui_root):
		ui_root.global_position = global_position + Vector3(0, 1.5, 0)
		ui_root.global_rotation = Vector3.ZERO
	
	if procesando:
		tiempo_restante_proceso -= delta
		var oscilacion = sin(Time.get_ticks_msec() * 0.005) * 0.05
		scale = Vector3.ONE + Vector3(oscilacion, -oscilacion, oscilacion)
		actualizar_barra()
		if tiempo_restante_proceso <= 0: finalizar_fusion()
	
	_gestionar_haz()

func _on_area_entered(area):
	if not esta_construido: return
	if procesando:
		if area.is_in_group("Pulsos"): area.queue_free()
		return
	if area.is_in_group("Pulsos"): recibir_input(area)

func recibir_input(pulso):
	var tipo = pulso.tipo_recurso
	if not tipo.begins_with(GameConstants.PREFIJO_COMPRIMIDO): return
	pulso.queue_free()
	animar_recepcion()
	var cantidad = pulso.cantidad_energia
	if buffer.has(tipo): buffer[tipo] += cantidad
	else: buffer[tipo] = cantidad
	actualizar_ui()
	actualizar_barra()
	verificar_recetas()

func verificar_recetas():
	if procesando: return
	var key_stab = GameConstants.PREFIJO_COMPRIMIDO + GameConstants.RECURSO_STABILITY
	var key_charg = GameConstants.PREFIJO_COMPRIMIDO + GameConstants.RECURSO_CHARGE
	var v = buffer.get(key_stab, 0)
	var a = buffer.get(key_charg, 0)
	
	if v >= GameConstants.MERGER_COSTO_STABILITY and a >= GameConstants.MERGER_COSTO_CHARGE:
		iniciar_fusion(GameConstants.RECURSO_DOWN_QUARK, GameConstants.MERGER_COSTO_STABILITY, GameConstants.MERGER_COSTO_CHARGE, GameConstants.COLOR_DOWN_QUARK)
	elif v >= GameConstants.MERGER_COSTO_CHARGE and a >= GameConstants.MERGER_COSTO_STABILITY:
		iniciar_fusion(GameConstants.RECURSO_UP_QUARK, GameConstants.MERGER_COSTO_CHARGE, GameConstants.MERGER_COSTO_STABILITY, GameConstants.COLOR_UP_QUARK)

func iniciar_fusion(producto: String, costo_v: int, costo_a: int, color: Color):
	procesando = true
	ha_disparado_una_vez = true 
	var key_stab = GameConstants.PREFIJO_COMPRIMIDO + GameConstants.RECURSO_STABILITY
	var key_charg = GameConstants.PREFIJO_COMPRIMIDO + GameConstants.RECURSO_CHARGE
	buffer[key_stab] -= costo_v
	buffer[key_charg] -= costo_a
	tiempo_restante_proceso = GameConstants.MERGER_TIEMPO_PROCESO
	producto_pendiente = producto
	color_pendiente = color
	actualizar_ui()
	actualizar_barra()

func finalizar_fusion():
	procesando = false
	scale = Vector3.ONE
	var t_final = create_tween()
	t_final.tween_property(self, "scale", Vector3(0.5, 1.5, 0.5), 0.1) 
	t_final.tween_property(self, "scale", Vector3.ONE, 0.2).set_trans(Tween.TRANS_ELASTIC)
	emitir_producto(producto_pendiente, color_pendiente)
	verificar_recetas()

func emitir_producto(nombre: String, color: Color):
	var p = pulse_scene.instantiate()
	get_tree().current_scene.add_child(p)
	
	# SOLUCIÓN: Asegurar grupo y colisiones
	if not p.is_in_group("Pulsos"): p.add_to_group("Pulsos")
	
	var dir = -global_transform.basis.z
	# Salir más lejos para evitar colisión con el propio edificio
	p.global_position = global_position + Vector3(0, 0.5, 0) + (dir * 1.5)
	p.direccion = dir
	p.global_rotation = global_rotation
	
	if p.has_method("configurar_pulso"):
		p.configurar_pulso(nombre, color, 1.0) 
		p.cantidad_energia = 100 
		
	p.scale = Vector3(0.1, 0.1, 0.1)
	var t = create_tween()
	t.tween_property(p, "scale", GameConstants.MERGER_ANIM_BIRTH_SCALE, 0.3).set_trans(Tween.TRANS_BACK)
	
	if PulseValidator: PulseValidator.registrar_pulso(p, self)

func actualizar_ui():
	if not label: return
	var key_stab = GameConstants.PREFIJO_COMPRIMIDO + GameConstants.RECURSO_STABILITY
	var key_charg = GameConstants.PREFIJO_COMPRIMIDO + GameConstants.RECURSO_CHARGE
	var v = buffer.get(key_stab, 0)
	var a = buffer.get(key_charg, 0)
	label.text = "S:%d C:%d" % [v, a]
	label.modulate = GameConstants.COLOR_STABILITY if v > a else GameConstants.COLOR_CHARGE

func actualizar_barra():
	if not barra_visual: return
	var porcentaje = 0.0
	if procesando:
		porcentaje = tiempo_restante_proceso / GameConstants.MERGER_TIEMPO_PROCESO
	else:
		var key_stab = GameConstants.PREFIJO_COMPRIMIDO + GameConstants.RECURSO_STABILITY
		var key_charg = GameConstants.PREFIJO_COMPRIMIDO + GameConstants.RECURSO_CHARGE
		var v = buffer.get(key_stab, 0)
		var a = buffer.get(key_charg, 0)
		var max_costo = 200.0 
		var progreso_v = min(v, max_costo)
		var progreso_a = min(a, max_costo)
		porcentaje = (progreso_v + progreso_a) / (max_costo * 2)
	barra_visual.scale.x = clamp(porcentaje, 0.0, 1.0)

func _get_material_seguro(nodo):
	if nodo is MeshInstance3D: return nodo.get_active_material(0)
	elif nodo is CSGShape3D: return nodo.material_override
	return null

func _gestionar_haz():
	var longitud = 0
	var color_haz = Color(1.0, 0.7, 0.0)
	if procesando: color_haz.a = 0.5 + sin(Time.get_ticks_msec() * 0.02) * 0.5
	if not esta_construido: longitud = GameConstants.HAZ_LONGITUD_PREVIEW
	else:
		if ha_disparado_una_vez or procesando:
			longitud = GameConstants.HAZ_LONGITUD_MAXIMA
			if PulseValidator: PulseValidator.registrar_haz_activo(self)
		else:
			longitud = GameConstants.HAZ_LONGITUD_PREVIEW
			if PulseValidator: PulseValidator.desregistrar_haz_activo(self)
	var map = get_tree().current_scene.find_child("GridMap")
	var space = get_world_3d().direct_space_state
	if map:
		var dir = -global_transform.basis.z
		beam_emitter.dibujar_haz(global_position, dir, longitud, color_haz, map, space)

func _exit_tree():
	if ui_root and is_instance_valid(ui_root): ui_root.queue_free()
func animar_recepcion():
	if ui_root:
		var t = create_tween()
		t.tween_property(ui_root, "scale", Vector3(1.1, 1.1, 1.1), 0.1)
		t.tween_property(ui_root, "scale", Vector3(1.0, 1.0, 1.0), 0.1)
func check_ground(): collision_layer = GameConstants.LAYER_EDIFICIOS; esta_construido = true; if ui_root: ui_root.visible = true
func desconectar_sifon(): collision_layer = 0; esta_construido = false; ha_disparado_una_vez = false; procesando = false; if ui_root: ui_root.visible = false; buffer = {"Compressed-Stability": 0, "Compressed-Charge": 0}; actualizar_ui()
func es_suelo_valido(id): return id == GameConstants.TILE_VACIO
func recibir_luz_instantanea(_c, _r, _d): pass
