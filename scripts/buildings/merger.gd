extends Area3D

var buffer = { "Compressed-Stability": 0, "Compressed-Charge": 0 }
var esta_construido: bool = false
var ha_disparado_una_vez: bool = false
var procesando: bool = false
var tiempo_restante_proceso: float = 0.0
var producto_pendiente = ""
var color_pendiente = Color.WHITE
## Objetivo de fusión elegido por el jugador: "Up-Quark" o "Down-Quark"
var producto_objetivo: String = "Down-Quark"

var beam_emitter: BeamEmitter

var ui_root: Node3D = null
var label: Node = null
var label_e: Label3D = null  # E (Estabilidad) en verde
var label_sep: Label3D = null  # " - " en blanco entre E y C
var label_c: Label3D = null  # C (Carga) en magenta
var barra_visual: Node3D = null 

func _ready():
	beam_emitter = BeamEmitter.new()
	add_child(beam_emitter)
	if not area_entered.is_connected(_on_area_entered): area_entered.connect(_on_area_entered)
	add_to_group("AbreUIClicDerecho")
	
	collision_layer = GameConstants.LAYER_EDIFICIOS
	collision_mask = GameConstants.LAYER_PULSOS
	esta_construido = false 
	ha_disparado_una_vez = false
	
	ui_root = find_child("UI_Root", true, false)
	if ui_root:
		ui_root.set_as_top_level(true)
		barra_visual = ui_root.find_child("BarraVisual", true, false)
		label = ui_root.find_child("TextoInfo", true, false)
		if label and label is Label3D:
			_crear_labels_e_c(label as Label3D)
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

func recibir_energia_numerica(cantidad: int, tipo_recurso: String, _origen: Node = null) -> void:
	if not esta_construido or procesando: return
	if not tipo_recurso.begins_with(GameConstants.PREFIJO_COMPRIMIDO):
		return
	var key_stab = GameConstants.PREFIJO_COMPRIMIDO + GameConstants.RECURSO_STABILITY
	var key_charg = GameConstants.PREFIJO_COMPRIMIDO + GameConstants.RECURSO_CHARGE
	var total_actual = buffer.get(key_stab, 0) + buffer.get(key_charg, 0)
	var espacio = GameConstants.MERGER_MAX_ALMACEN - total_actual
	if espacio <= 0: return
	var a_aceptar = mini(cantidad, espacio)
	animar_recepcion()
	if buffer.has(tipo_recurso): buffer[tipo_recurso] += a_aceptar
	else: buffer[tipo_recurso] = a_aceptar
	actualizar_ui()
	actualizar_barra()
	_actualizar_mi_estado_global()
	verificar_recetas()

func recibir_input(pulso):
	var tipo = pulso.tipo_recurso
	if not tipo.begins_with(GameConstants.PREFIJO_COMPRIMIDO): return
	pulso.queue_free()
	recibir_energia_numerica(pulso.cantidad_energia, tipo, null)

func verificar_recetas():
	if procesando: return
	var key_stab = GameConstants.PREFIJO_COMPRIMIDO + GameConstants.RECURSO_STABILITY
	var key_charg = GameConstants.PREFIJO_COMPRIMIDO + GameConstants.RECURSO_CHARGE
	var v = buffer.get(key_stab, 0)
	var a = buffer.get(key_charg, 0)
	# Solo fusionar el producto elegido por el jugador (UP o DOWN)
	if producto_objetivo == GameConstants.RECURSO_DOWN_QUARK:
		if v >= GameConstants.MERGER_COSTO_STABILITY and a >= GameConstants.MERGER_COSTO_CHARGE:
			iniciar_fusion(GameConstants.RECURSO_DOWN_QUARK, GameConstants.MERGER_COSTO_STABILITY, GameConstants.MERGER_COSTO_CHARGE, GameConstants.COLOR_DOWN_QUARK)
	elif producto_objetivo == GameConstants.RECURSO_UP_QUARK:
		if v >= GameConstants.MERGER_COSTO_CHARGE and a >= GameConstants.MERGER_COSTO_STABILITY:
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
	_actualizar_mi_estado_global()

func finalizar_fusion():
	procesando = false
	scale = Vector3.ONE
	var t_final = create_tween()
	t_final.tween_property(self, "scale", Vector3(0.5, 1.5, 0.5), 0.1) 
	t_final.tween_property(self, "scale", Vector3.ONE, 0.2).set_trans(Tween.TRANS_ELASTIC)
	emitir_producto(producto_pendiente, color_pendiente)
	verificar_recetas()

func emitir_producto(nombre: String, color: Color):
	var scene = GameConstants.get_scene_root_for(self)
	var map = scene.find_child("GridMap") if scene else null
	var space = get_world_3d().direct_space_state
	var dir = -global_transform.basis.z
	var dir_flat = Vector3(dir.x, 0, dir.z).normalized()
	var longitud = GameConstants.HAZ_LONGITUD_MAXIMA
	const CANTIDAD_QUARKS = 100
	# Salida en la cara del merger (mesh 3x1x1 → cara -Z a 0.5 del centro)
	var from_pos = global_position + Vector3(0, 0.5, 0) + (dir * 0.5)
	
	if map and space and EnergyManager:
		# Solo crear pulso/flujo si hay haz activo
		if PulseValidator and not PulseValidator.haces_activos.has(self):
			pass
		else:
			var ruta_y_objetivo = beam_emitter.obtener_ruta_y_objetivo(global_position, dir, longitud, map, space, self)
			var path: Array = ruta_y_objetivo.get("path", [])
			var resultado_target = ruta_y_objetivo.get("target", null)
			var impact_pos = ruta_y_objetivo.get("impact_pos", from_pos + dir_flat * longitud)
			if EnergyManager.MOSTRAR_VISUAL_PULSO and path.size() >= 2:
				EnergyManager.spawn_pulse_visual(from_pos, impact_pos, color, self, nombre, path)
			if resultado_target != null:
				EnergyManager.register_flow(self, resultado_target, CANTIDAD_QUARKS, nombre, color)
	# Contabilizar producción en inventario global para desbloqueos (F2)
	if GlobalInventory:
		GlobalInventory.add_item(nombre, 1)
	_actualizar_mi_estado_global()

func _crear_labels_e_c(original: Label3D) -> void:
	# E y C en unidades condensadas (1, 2, 3...); E verde, " - " blanco, C magenta
	label_e = Label3D.new()
	label_e.pixel_size = original.pixel_size
	label_e.font_size = original.font_size
	label_e.billboard = original.billboard
	label_e.position = original.position + Vector3(-0.35, 0, 0)
	label_e.text = "E:0"
	label_e.modulate = GameConstants.COLOR_STABILITY
	ui_root.add_child(label_e)
	label_sep = Label3D.new()
	label_sep.pixel_size = original.pixel_size
	label_sep.font_size = original.font_size
	label_sep.billboard = original.billboard
	label_sep.position = original.position
	label_sep.text = " - "
	label_sep.modulate = Color.WHITE
	ui_root.add_child(label_sep)
	label_c = Label3D.new()
	label_c.pixel_size = original.pixel_size
	label_c.font_size = original.font_size
	label_c.billboard = original.billboard
	label_c.position = original.position + Vector3(0.35, 0, 0)
	label_c.text = "C:0"
	label_c.modulate = GameConstants.COLOR_CHARGE
	ui_root.add_child(label_c)
	original.visible = false
	label = null

func actualizar_ui():
	var key_stab = GameConstants.PREFIJO_COMPRIMIDO + GameConstants.RECURSO_STABILITY
	var key_charg = GameConstants.PREFIJO_COMPRIMIDO + GameConstants.RECURSO_CHARGE
	var v = buffer.get(key_stab, 0)
	var a = buffer.get(key_charg, 0)
	# Mostrar en unidades condensadas (1, 2, 3...) no 10, 20, 30
	var v_cond = v / GameConstants.UNIDADES_COMPRIMIDAS_POR_UNIDAD
	var a_cond = a / GameConstants.UNIDADES_COMPRIMIDAS_POR_UNIDAD
	if label_e and is_instance_valid(label_e):
		label_e.text = "E:%d" % v_cond
		label_e.modulate = GameConstants.COLOR_STABILITY
	if label_c and is_instance_valid(label_c):
		label_c.text = "C:%d" % a_cond
		label_c.modulate = GameConstants.COLOR_CHARGE
	if label and is_instance_valid(label):
		label.text = "E:%d C:%d" % [v_cond, a_cond]
		label.modulate = GameConstants.COLOR_STABILITY

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
			if EnergyManager: EnergyManager.remove_flows_from_source(self)
	var scene = GameConstants.get_scene_root_for(self)
	var map = scene.find_child("GridMap") if scene else null
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
func check_ground(): 
	collision_layer = GameConstants.LAYER_EDIFICIOS
	esta_construido = true
	_recuperar_estado_guardado()
	if BuildingManager: BuildingManager.register_building(self)
	if ui_root: ui_root.visible = true
func desconectar_sifon(): 
	if BuildingManager: BuildingManager.unregister_building(self)
	collision_layer = 0
	esta_construido = false
	ha_disparado_una_vez = false
	procesando = false
	if ui_root: ui_root.visible = false
	# No resetear buffer al levantar para mover: al soltar se mantiene (mejor jugable).
	# buffer solo se pierde si se devuelve al inventario o se destruye.
	actualizar_ui()
func es_suelo_valido(id): return id == GameConstants.TILE_VACIO

## Devuelve los offsets de celdas (2D) que ocupa el merger (3x1) respecto al centro, según su rotación Y.
func get_footprint_offsets() -> Array[Vector2i]:
	var c = cos(rotation.y)
	var s = sin(rotation.y)
	return [
		Vector2i(int(round(-c)), int(round(-s))),
		Vector2i(0, 0),
		Vector2i(int(round(c)), int(round(s)))
	]
func recibir_luz_instantanea(_c, _r, _d): pass

func _actualizar_mi_estado_global():
	var scene = GameConstants.get_scene_root_for(self)
	var map = scene.find_child("GridMap", true, false) if scene else null
	if not map: map = get_tree().get_first_node_in_group("MapaPrincipal")
	if map and esta_construido:
		var datos = {
			"buf_stab": buffer.get("Compressed-Stability", 0),
			"buf_charg": buffer.get("Compressed-Charge", 0),
			"producto_objetivo": producto_objetivo
		}
		GlobalInventory.registrar_estado(map.local_to_map(global_position), datos)

func _recuperar_estado_guardado():
	var scene = GameConstants.get_scene_root_for(self)
	var map = get_tree().get_first_node_in_group("MapaPrincipal")
	if not map and scene: map = scene.find_child("GridMap", true, false)
	if map:
		var e = GlobalInventory.obtener_estado(map.local_to_map(global_position))
		if e.size() > 0:
			buffer["Compressed-Stability"] = e.get("buf_stab", 0)
			buffer["Compressed-Charge"] = e.get("buf_charg", 0)
			var obj = e.get("producto_objetivo", "")
			if obj == GameConstants.RECURSO_UP_QUARK or obj == GameConstants.RECURSO_DOWN_QUARK:
				producto_objetivo = obj
			actualizar_ui()
			actualizar_barra()

func abrir_ui():
	var ui = get_tree().get_first_node_in_group("VentanaMerger")
	if ui and ui.has_method("abrir_menu"):
		ui.abrir_menu(self)

func set_producto_objetivo(quark: String) -> void:
	if quark != GameConstants.RECURSO_UP_QUARK and quark != GameConstants.RECURSO_DOWN_QUARK:
		return
	producto_objetivo = quark
	_actualizar_mi_estado_global()
	verificar_recetas()

func purgar_recurso(tipo_recurso: String) -> void:
	if not buffer.has(tipo_recurso): return
	buffer[tipo_recurso] = 0
	actualizar_ui()
	actualizar_barra()
	_actualizar_mi_estado_global()
	_notificar_ui_merger()

## Vacía todo el buffer (E y C). Útil para resetear el fusionador.
func purgar_buffer() -> void:
	var key_stab = GameConstants.PREFIJO_COMPRIMIDO + GameConstants.RECURSO_STABILITY
	var key_charg = GameConstants.PREFIJO_COMPRIMIDO + GameConstants.RECURSO_CHARGE
	buffer[key_stab] = 0
	buffer[key_charg] = 0
	actualizar_ui()
	actualizar_barra()
	_actualizar_mi_estado_global()
	_notificar_ui_merger()

func _notificar_ui_merger():
	var ui = get_tree().get_first_node_in_group("VentanaMerger")
	if ui and ui.has_method("actualizar_vista") and ui.visible and ui.get("merger_activo") == self:
		ui.actualizar_vista()
