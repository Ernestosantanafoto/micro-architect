extends Area3D

## Fabricador Hadrón: convierte quarks en nucleones.
## Recetas: Protón = 2 Up-Quark + 1 Down-Quark; Neutrón = 1 Up-Quark + 2 Down-Quark.
## El producto se añade al inventario global (no emite haz).

var buffer = { GameConstants.RECURSO_UP_QUARK: 0, GameConstants.RECURSO_DOWN_QUARK: 0 }
var esta_construido: bool = false
var procesando: bool = false
var tiempo_restante_proceso: float = 0.0
var producto_pendiente: String = ""
var color_pendiente: Color = Color.WHITE

var ui_root: Node3D = null
var label: Node = null
var barra_visual: Node3D = null

func _ready():
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)

	collision_layer = GameConstants.LAYER_EDIFICIOS
	collision_mask = GameConstants.LAYER_PULSOS
	esta_construido = false

	ui_root = find_child("UI_Root", true, false)
	if ui_root:
		ui_root.set_as_top_level(true)
		barra_visual = ui_root.find_child("BarraVisual", true, false)
		label = ui_root.find_child("TextoInfo", true, false)
		if barra_visual:
			var mat = _get_material_seguro(barra_visual)
			if mat:
				mat.albedo_color = Color.WHITE

	actualizar_ui()

func _process(delta):
	if ui_root and is_instance_valid(ui_root):
		ui_root.global_position = global_position + Vector3(0, GameConstants.UI_OFFSET_3D_Y, 0)
		ui_root.global_rotation = Vector3.ZERO

	if procesando:
		tiempo_restante_proceso -= delta
		var oscilacion = sin(Time.get_ticks_msec() * 0.005) * 0.05
		scale = Vector3.ONE + Vector3(oscilacion, -oscilacion, oscilacion)
		actualizar_barra()
		if tiempo_restante_proceso <= 0:
			finalizar_produccion()

func _on_area_entered(area):
	if not esta_construido:
		return
	if procesando:
		if area.is_in_group("Pulsos"):
			area.queue_free()
		return
	if area.is_in_group("Pulsos"):
		recibir_energia_numerica(area.cantidad_energia, area.tipo_recurso, null)
		area.queue_free()

func recibir_energia_numerica(cantidad: int, tipo_recurso: String, _origen: Node = null) -> void:
	if not esta_construido or procesando:
		return
	if tipo_recurso != GameConstants.RECURSO_UP_QUARK and tipo_recurso != GameConstants.RECURSO_DOWN_QUARK:
		return
	animar_recepcion()
	if buffer.has(tipo_recurso):
		buffer[tipo_recurso] += cantidad
	else:
		buffer[tipo_recurso] = cantidad
	actualizar_ui()
	actualizar_barra()
	_actualizar_mi_estado_global()
	verificar_recetas()

func verificar_recetas():
	if procesando:
		return
	var u = buffer.get(GameConstants.RECURSO_UP_QUARK, 0)
	var d = buffer.get(GameConstants.RECURSO_DOWN_QUARK, 0)

	# Prioridad: Protón (2U+1D) si hay recursos; si no, Neutrón (1U+2D)
	if u >= GameConstants.HADRON_COSTO_PROTON_UP and d >= GameConstants.HADRON_COSTO_PROTON_DOWN:
		iniciar_produccion(
			GameConstants.RECURSO_PROTON,
			GameConstants.HADRON_COSTO_PROTON_UP,
			GameConstants.HADRON_COSTO_PROTON_DOWN,
			GameConstants.COLOR_PROTON
		)
	elif u >= GameConstants.HADRON_COSTO_NEUTRON_UP and d >= GameConstants.HADRON_COSTO_NEUTRON_DOWN:
		iniciar_produccion(
			GameConstants.RECURSO_NEUTRON,
			GameConstants.HADRON_COSTO_NEUTRON_UP,
			GameConstants.HADRON_COSTO_NEUTRON_DOWN,
			GameConstants.COLOR_NEUTRON
		)

func iniciar_produccion(producto: String, costo_u: int, costo_d: int, color: Color):
	procesando = true
	buffer[GameConstants.RECURSO_UP_QUARK] -= costo_u
	buffer[GameConstants.RECURSO_DOWN_QUARK] -= costo_d
	tiempo_restante_proceso = GameConstants.HADRON_TIEMPO_PROCESO
	producto_pendiente = producto
	color_pendiente = color
	actualizar_ui()
	actualizar_barra()
	_actualizar_mi_estado_global()

func finalizar_produccion():
	procesando = false
	scale = Vector3.ONE
	var t_final = create_tween()
	t_final.tween_property(self, "scale", Vector3(0.5, 1.5, 0.5), 0.1)
	t_final.tween_property(self, "scale", Vector3.ONE, 0.2).set_trans(Tween.TRANS_ELASTIC)
	if GlobalInventory:
		GlobalInventory.add_item(producto_pendiente, 1)
	_actualizar_mi_estado_global()
	verificar_recetas()

func actualizar_ui():
	if not label:
		return
	var u = buffer.get(GameConstants.RECURSO_UP_QUARK, 0)
	var d = buffer.get(GameConstants.RECURSO_DOWN_QUARK, 0)
	label.text = "U:%d D:%d" % [u, d]
	label.modulate = GameConstants.COLOR_UP_QUARK if u >= d else GameConstants.COLOR_DOWN_QUARK

func actualizar_barra():
	if not barra_visual:
		return
	var porcentaje = 0.0
	if procesando:
		porcentaje = 1.0 - (tiempo_restante_proceso / GameConstants.HADRON_TIEMPO_PROCESO)
	else:
		var u = buffer.get(GameConstants.RECURSO_UP_QUARK, 0)
		var d = buffer.get(GameConstants.RECURSO_DOWN_QUARK, 0)
		var max_costo = 6.0
		porcentaje = (min(u, 3) + min(d, 3)) / max_costo
	barra_visual.scale.x = clamp(porcentaje, 0.0, 1.0)

func _get_material_seguro(nodo):
	if nodo is MeshInstance3D:
		return nodo.get_active_material(0)
	if nodo is CSGShape3D:
		return nodo.material_override
	return null

func _exit_tree():
	if ui_root and is_instance_valid(ui_root):
		ui_root.queue_free()

func animar_recepcion():
	if ui_root:
		var t = create_tween()
		t.tween_property(ui_root, "scale", Vector3(1.1, 1.1, 1.1), 0.1)
		t.tween_property(ui_root, "scale", Vector3(1.0, 1.0, 1.0), 0.1)

func check_ground():
	collision_layer = GameConstants.LAYER_EDIFICIOS
	esta_construido = true
	_recuperar_estado_guardado()
	if BuildingManager:
		BuildingManager.register_building(self)
	if ui_root:
		ui_root.visible = true

func desconectar_sifon():
	if BuildingManager:
		BuildingManager.unregister_building(self)
	collision_layer = 0
	esta_construido = false
	procesando = false
	if ui_root:
		ui_root.visible = false
	actualizar_ui()

func es_suelo_valido(id: int) -> bool:
	return id == GameConstants.TILE_VACIO

func get_footprint_offsets() -> Array[Vector2i]:
	# Edificio 12×12: ocupa celdas desde (-6,-6) hasta (5,5) respecto al centro
	var out: Array[Vector2i] = []
	for x in range(-6, 6):
		for z in range(-6, 6):
			out.append(Vector2i(x, z))
	return out

func recibir_luz_instantanea(_c, _r, _d):
	pass

func _actualizar_mi_estado_global():
	var map = get_tree().current_scene.find_child("GridMap", true, false) if get_tree().current_scene else null
	if not map:
		map = get_tree().get_first_node_in_group("MapaPrincipal")
	if map and esta_construido:
		var datos = {
			"buf_u": buffer.get(GameConstants.RECURSO_UP_QUARK, 0),
			"buf_d": buffer.get(GameConstants.RECURSO_DOWN_QUARK, 0),
			"proc": procesando,
			"tiempo": tiempo_restante_proceso,
			"producto": producto_pendiente
		}
		GlobalInventory.registrar_estado(map.local_to_map(global_position), datos)

func _recuperar_estado_guardado():
	var map = get_tree().get_first_node_in_group("MapaPrincipal")
	if not map:
		map = get_tree().current_scene.find_child("GridMap", true, false) if get_tree().current_scene else null
	if map:
		var e = GlobalInventory.obtener_estado(map.local_to_map(global_position))
		if e.size() > 0:
			buffer[GameConstants.RECURSO_UP_QUARK] = e.get("buf_u", 0)
			buffer[GameConstants.RECURSO_DOWN_QUARK] = e.get("buf_d", 0)
			procesando = e.get("proc", false)
			tiempo_restante_proceso = e.get("tiempo", 0.0)
			producto_pendiente = e.get("producto", "")
			if producto_pendiente == GameConstants.RECURSO_PROTON:
				color_pendiente = GameConstants.COLOR_PROTON
			elif producto_pendiente == GameConstants.RECURSO_NEUTRON:
				color_pendiente = GameConstants.COLOR_NEUTRON
			actualizar_ui()
			actualizar_barra()
