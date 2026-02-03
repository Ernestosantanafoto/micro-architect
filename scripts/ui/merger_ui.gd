extends CanvasLayer

var merger_activo: Node3D = null

@onready var ventana = $VentanaFlotante
@onready var opt_producto = %OptProducto
@onready var lbl_e = %LblE
@onready var lbl_c = %LblC
@onready var btn_purga_e = %BtnPurgaE
@onready var btn_purga_c = %BtnPurgaC

func _ready():
	visible = false
	if not is_in_group("VentanasUI"): add_to_group("VentanasUI")
	if not is_in_group("VentanaMerger"): add_to_group("VentanaMerger")
	if not is_in_group("UIsEdificios"): add_to_group("UIsEdificios")
	set_process_input(true)
	if opt_producto:
		opt_producto.item_selected.connect(_on_producto_cambiado)
	if btn_purga_e:
		btn_purga_e.pressed.connect(_on_purgar_e)
	if btn_purga_c:
		btn_purga_c.pressed.connect(_on_purgar_c)

func _input(event):
	if not visible or not ventana: return
	if event is InputEventMouseButton and event.pressed:
		var viewport_h = get_viewport().get_visible_rect().size.y
		if get_viewport().get_mouse_position().y > viewport_h - 140:
			return
		if not ventana.get_global_rect().has_point(get_viewport().get_mouse_position()):
			cerrar()
			get_viewport().set_input_as_handled()

func _process(_delta):
	if not visible or not is_instance_valid(merger_activo):
		if visible: cerrar()
		return
	actualizar_vista()
	var cam = get_viewport().get_camera_3d()
	if cam and ventana:
		var pos_3d = merger_activo.global_position + Vector3(0, GameConstants.UI_OFFSET_3D_Y, 0)
		if not cam.is_position_behind(pos_3d):
			ventana.modulate.a = 1
			var target_pos = cam.unproject_position(pos_3d) - (ventana.size / 2)
			ventana.position = ventana.position.lerp(target_pos, 0.2)
		else:
			ventana.modulate.a = 0

func abrir_menu(edificio):
	if visible and merger_activo == edificio: return
	for n in get_tree().get_nodes_in_group("UIsEdificios"):
		if n != self and n.has_method("cerrar") and n.visible:
			n.cerrar()
	merger_activo = edificio
	visible = true
	_rellenar_opcion_producto()
	actualizar_vista()
	var cam = get_viewport().get_camera_3d()
	if cam and ventana:
		var pos_3d = edificio.global_position + Vector3(0, GameConstants.UI_OFFSET_3D_Y, 0)
		ventana.position = cam.unproject_position(pos_3d) - (ventana.size / 2)
	if ventana:
		ventana.scale = Vector2(0.88, 0.88)
		ventana.modulate.a = 0.0
		var t = create_tween()
		t.set_parallel(true)
		t.set_ease(Tween.EASE_OUT)
		t.set_trans(Tween.TRANS_BACK)
		t.tween_property(ventana, "scale", Vector2.ONE, 0.22)
		t.tween_property(ventana, "modulate:a", 1.0, 0.18)

func cerrar():
	merger_activo = null
	visible = false

func _rellenar_opcion_producto():
	if not opt_producto: return
	opt_producto.clear()
	opt_producto.add_item("DOWN", 0)
	opt_producto.add_item("UP", 1)
	if merger_activo and merger_activo.get("producto_objetivo") == GameConstants.RECURSO_UP_QUARK:
		opt_producto.select(1)
	else:
		opt_producto.select(0)

func actualizar_vista():
	if not is_instance_valid(merger_activo): return
	var key_stab = GameConstants.PREFIJO_COMPRIMIDO + GameConstants.RECURSO_STABILITY
	var key_charg = GameConstants.PREFIJO_COMPRIMIDO + GameConstants.RECURSO_CHARGE
	var v = merger_activo.buffer.get(key_stab, 0)
	var a = merger_activo.buffer.get(key_charg, 0)
	var v_cond = v / GameConstants.UNIDADES_COMPRIMIDAS_POR_UNIDAD
	var a_cond = a / GameConstants.UNIDADES_COMPRIMIDAS_POR_UNIDAD
	if lbl_e:
		lbl_e.text = "E: %d" % v_cond
		lbl_e.add_theme_color_override("font_color", GameConstants.COLOR_STABILITY)
	if lbl_c:
		lbl_c.text = "C: %d" % a_cond
		lbl_c.add_theme_color_override("font_color", GameConstants.COLOR_CHARGE)
	# Sincronizar OptionButton
	if opt_producto and merger_activo:
		var obj = merger_activo.producto_objetivo
		opt_producto.select(1 if obj == GameConstants.RECURSO_UP_QUARK else 0)
	# Deshabilitar controles mientras fusiona
	var procesando = merger_activo.get("procesando") == true
	if opt_producto: opt_producto.disabled = procesando
	if btn_purga_e: btn_purga_e.disabled = procesando
	if btn_purga_c: btn_purga_c.disabled = procesando

func _on_producto_cambiado(index: int):
	if not merger_activo: return
	var quark = GameConstants.RECURSO_UP_QUARK if index == 1 else GameConstants.RECURSO_DOWN_QUARK
	merger_activo.set_producto_objetivo(quark)
	actualizar_vista()

func _on_purgar_e():
	if merger_activo:
		var key = GameConstants.PREFIJO_COMPRIMIDO + GameConstants.RECURSO_STABILITY
		merger_activo.purgar_recurso(key)
		actualizar_vista()

func _on_purgar_c():
	if merger_activo:
		var key = GameConstants.PREFIJO_COMPRIMIDO + GameConstants.RECURSO_CHARGE
		merger_activo.purgar_recurso(key)
		actualizar_vista()
