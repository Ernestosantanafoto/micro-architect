extends CanvasLayer

var merger_activo: Node3D = null

@onready var ventana = $VentanaFlotante
@onready var btn_down_quark = %BtnDownQuark
@onready var btn_up_quark = %BtnUpQuark
@onready var lbl_buffer = %LblBuffer
@onready var lbl_e = %LblE
@onready var lbl_c = %LblC
@onready var btn_purga_e = %BtnPurgaE
@onready var btn_purga_c = %BtnPurgaC
@onready var btn_purga_todo = %BtnPurgaTodo

func _ready():
	visible = false
	if not is_in_group("VentanasUI"): add_to_group("VentanasUI")
	if not is_in_group("VentanaMerger"): add_to_group("VentanaMerger")
	if not is_in_group("UIsEdificios"): add_to_group("UIsEdificios")
	set_process_input(true)
	if btn_down_quark:
		btn_down_quark.pressed.connect(_on_down_quark_pressed)
	if btn_up_quark:
		btn_up_quark.pressed.connect(_on_up_quark_pressed)
	if btn_purga_e:
		btn_purga_e.pressed.connect(_on_purgar_e)
	if btn_purga_c:
		btn_purga_c.pressed.connect(_on_purgar_c)
	if btn_purga_todo:
		btn_purga_todo.pressed.connect(_on_purgar_todo)
	_estilo_botones_quark()

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
	_estilo_botones_quark()
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

const GRIS_NO_SELECCIONADO = Color(0.5, 0.5, 0.55)

func _estilo_botones_quark():
	_actualizar_seleccion_quark()

func _actualizar_seleccion_quark():
	if not btn_down_quark or not btn_up_quark: return
	var es_up = merger_activo and merger_activo.get("producto_objetivo") == GameConstants.RECURSO_UP_QUARK
	btn_down_quark.button_pressed = not es_up
	btn_up_quark.button_pressed = es_up
	# Seleccionado: color del quark (font_color + font_pressed_color para estado toggle); no seleccionado: gris
	var color_down = GameConstants.COLOR_DOWN_QUARK if not es_up else GRIS_NO_SELECCIONADO
	var color_up = GameConstants.COLOR_UP_QUARK if es_up else GRIS_NO_SELECCIONADO
	btn_down_quark.add_theme_color_override("font_color", color_down)
	btn_down_quark.add_theme_color_override("font_pressed_color", color_down)
	btn_up_quark.add_theme_color_override("font_color", color_up)
	btn_up_quark.add_theme_color_override("font_pressed_color", color_up)

func actualizar_vista():
	if not is_instance_valid(merger_activo): return
	var key_stab = GameConstants.PREFIJO_COMPRIMIDO + GameConstants.RECURSO_STABILITY
	var key_charg = GameConstants.PREFIJO_COMPRIMIDO + GameConstants.RECURSO_CHARGE
	var v = merger_activo.buffer.get(key_stab, 0)
	var a = merger_activo.buffer.get(key_charg, 0)
	var v_cond = v / GameConstants.UNIDADES_COMPRIMIDAS_POR_UNIDAD
	var a_cond = a / GameConstants.UNIDADES_COMPRIMIDAS_POR_UNIDAD
	var total = v + a
	var max_almacen = GameConstants.MERGER_MAX_ALMACEN
	var total_cond = total / GameConstants.UNIDADES_COMPRIMIDAS_POR_UNIDAD
	var max_cond = max_almacen / GameConstants.UNIDADES_COMPRIMIDAS_POR_UNIDAD
	if lbl_buffer:
		lbl_buffer.text = "Buffer: %d / %d" % [total_cond, max_cond]
		lbl_buffer.add_theme_color_override("font_color", Color(0.85, 0.85, 0.9))
	# Requisitos de la receta seleccionada (en unidades condensadas, como v_cond/a_cond)
	var es_up = merger_activo.get("producto_objetivo") == GameConstants.RECURSO_UP_QUARK
	var req_e_cond: int
	var req_c_cond: int
	if es_up:
		req_e_cond = GameConstants.MERGER_COSTO_CHARGE / GameConstants.UNIDADES_COMPRIMIDAS_POR_UNIDAD
		req_c_cond = GameConstants.MERGER_COSTO_STABILITY / GameConstants.UNIDADES_COMPRIMIDAS_POR_UNIDAD
	else:
		req_e_cond = GameConstants.MERGER_COSTO_STABILITY / GameConstants.UNIDADES_COMPRIMIDAS_POR_UNIDAD
		req_c_cond = GameConstants.MERGER_COSTO_CHARGE / GameConstants.UNIDADES_COMPRIMIDAS_POR_UNIDAD
	if lbl_e:
		lbl_e.text = "E: %d / %d" % [v_cond, req_e_cond]
		lbl_e.add_theme_color_override("font_color", GameConstants.COLOR_STABILITY)
	if lbl_c:
		lbl_c.text = "C: %d / %d" % [a_cond, req_c_cond]
		lbl_c.add_theme_color_override("font_color", GameConstants.COLOR_CHARGE)
	_actualizar_seleccion_quark()
	# Deshabilitar controles mientras fusiona
	var procesando = merger_activo.get("procesando") == true
	if btn_down_quark: btn_down_quark.disabled = procesando
	if btn_up_quark: btn_up_quark.disabled = procesando
	if btn_purga_e: btn_purga_e.disabled = procesando
	if btn_purga_c: btn_purga_c.disabled = procesando
	if btn_purga_todo: btn_purga_todo.disabled = procesando

func _on_down_quark_pressed():
	if merger_activo:
		merger_activo.set_producto_objetivo(GameConstants.RECURSO_DOWN_QUARK)
		actualizar_vista()

func _on_up_quark_pressed():
	if merger_activo:
		merger_activo.set_producto_objetivo(GameConstants.RECURSO_UP_QUARK)
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

func _on_purgar_todo():
	if merger_activo and merger_activo.has_method("purgar_buffer"):
		merger_activo.purgar_buffer()
		actualizar_vista()
