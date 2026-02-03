extends Control

var sifon_activo: Node3D = null

# #region agent log
const _DEBUG_LOG = "res://.cursor/debug.log"
func _agent_log(hypothesis_id: String, location: String, message: String, data: Dictionary) -> void:
	var payload = {"hypothesisId": hypothesis_id, "location": location, "message": message, "data": data, "timestamp": Time.get_ticks_msec(), "sessionId": "god_siphon_ui"}
	var j = JSON.stringify(payload)
	var d = DirAccess.open("res://")
	if d and not d.dir_exists(".cursor"):
		d.make_dir_recursive(".cursor")
	var f = FileAccess.open(_DEBUG_LOG, FileAccess.READ_WRITE)
	if f:
		f.seek_end()
		f.store_line(j)
		f.close()
	else:
		print("[agent log] ", hypothesis_id, " ", location, " ", data)
# #endregion

# --- REFERENCIAS CON ACCESO ÚNICO (%) ---
@onready var ventana = %VentanaFlotante

@onready var opt_color = %OptionColor
@onready var opt_tipo = %OptionTipo
@onready var slider_energia = %SliderEnergia
@onready var lbl_energia_valor = %LblEnergiaValor
@onready var slider_freq = %SliderFrecuencia
@onready var lbl_freq_valor = %LblFreqValor
@onready var lbl_preview = %LblPreview
@onready var btn_aplicar = %BtnAplicar
@onready var btn_resetear = %BtnResetear
@onready var btn_cerrar = %BtnCerrar

# Valores por defecto
var default_energia = 10.0
var default_freq = 5
var _agent_logged_process = false

func _ready():
	visible = false
	add_to_group("VentanasUI")
	add_to_group("UIsEdificios") 
	
	# 1. Configuración de los Dropdowns
	if opt_color:
		opt_color.clear()
		opt_color.add_item("E - Estabilidad", 0)
		opt_color.add_item("C - Carga", 1)
		
	if opt_tipo:
		opt_tipo.clear()
		opt_tipo.add_item("Energía Base", 0)
		opt_tipo.add_item("Comprimida", 1)
		opt_tipo.add_item("UP", 2)
		opt_tipo.add_item("DOWN", 3)
	
	# 2. Configurar sliders
	if slider_energia:
		slider_energia.min_value = 1.0
		slider_energia.max_value = 100.0
		slider_energia.value = default_energia
		slider_energia.value_changed.connect(_on_energia_changed)
	
	if slider_freq:
		slider_freq.min_value = 1
		slider_freq.max_value = 20
		slider_freq.value = default_freq
		slider_freq.value_changed.connect(_on_freq_changed)
	
	# 3. Conexiones de Señales
	if opt_color: opt_color.item_selected.connect(func(_idx): _actualizar_preview())
	if opt_tipo: opt_tipo.item_selected.connect(_al_cambiar_tipo)
	if btn_aplicar: btn_aplicar.pressed.connect(_aplicar_cambios)
	if btn_resetear: btn_resetear.pressed.connect(_resetear_valores)
	if btn_cerrar: btn_cerrar.pressed.connect(cerrar)
	
	set_process_input(true)

func _input(event):
	# Cerrar con LMB o RMB fuera de la ventana
	if not visible or not ventana: return
	if event is InputEventMouseButton and event.pressed:
		var viewport_h = get_viewport().get_visible_rect().size.y
		if get_viewport().get_mouse_position().y > viewport_h - 140:
			return
		if not ventana.get_global_rect().has_point(get_viewport().get_mouse_position()):
			cerrar()
			get_viewport().set_input_as_handled()

func _process(_delta):
	if not visible or not is_instance_valid(sifon_activo):
		if visible: cerrar()
		return

	# #region agent log
	if not _agent_logged_process and ventana:
		_agent_logged_process = true
		var vbox = ventana.get_node_or_null("MarginContainer/VBoxContainer")
		var lbl_rect = vbox.get_child(0).get_global_rect() if vbox and vbox.get_child_count() > 0 else Rect2()
		_agent_log("H3", "god_siphon_ui.gd:_process", "first frame visible layout", {
			"ventana_global": {"x": ventana.global_position.x, "y": ventana.global_position.y},
			"ventana_size": {"x": ventana.size.x, "y": ventana.size.y},
			"first_child_global_rect": {"x": lbl_rect.position.x, "y": lbl_rect.position.y, "w": lbl_rect.size.x, "h": lbl_rect.size.y}
		})
	# #endregion

	# --- ESTABILIZACIÓN: no mover la ventana al sacar el cursor (evitar que se amplíe/desaparezca) ---
	if (opt_color and opt_color.get_popup().visible) or (opt_tipo and opt_tipo.get_popup().visible):
		return
	
	var cam = get_viewport().get_camera_3d()
	if not cam:
		return
	# Forzar posición y tamaño 280x260 cada frame (el layout del padre full-rect estira el panel)
	var world_pos = sifon_activo.global_position + Vector3(0, 1.5, 0)
	var pos_2d = cam.unproject_position(world_pos) - Vector2(140, 130)
	if ventana:
		# Side: 0=LEFT, 1=TOP, 2=RIGHT, 3=BOTTOM
		ventana.set_offset(0, int(pos_2d.x))
		ventana.set_offset(1, int(pos_2d.y))
		ventana.set_offset(2, int(pos_2d.x) + 280)
		ventana.set_offset(3, int(pos_2d.y) + 260)
	# Solo atenuar si el edificio queda detrás de cámara; la ventana permanece fija en pantalla
	if ventana:
		if cam.is_position_behind(world_pos):
			ventana.modulate.a = 0
		else:
			ventana.modulate.a = 1

# --- FUNCIONES DE CONTROL ---

func abrir(sifon):
	if visible and sifon_activo == sifon: return
	
	# Cerrar otros menús de edificios (Constructor, etc.)
	for n in get_tree().get_nodes_in_group("UIsEdificios"):
		if n != self and n.has_method("cerrar") and n.visible:
			n.cerrar()
	
	sifon_activo = sifon
	
	# Posicionar la ventana (PanelContainer hijo directo del root) ANTES de visible = true
	var cam = get_viewport().get_camera_3d()
	if cam and ventana:
		var world_pos = sifon.global_position + Vector3(0, 1.5, 0)
		var pos_2d = cam.unproject_position(world_pos)
		ventana.position = pos_2d - Vector2(140, 130)
		# #region agent log
		_agent_log("H1", "god_siphon_ui.gd:abrir", "after set position", {
			"ventana_pos": {"x": ventana.position.x, "y": ventana.position.y},
			"ventana_size": {"x": ventana.size.x, "y": ventana.size.y}
		})
		# #endregion
		call_deferred("_reposicionar_ventana_sifon")
		if ventana is Container:
			ventana.queue_sort()
	
	visible = true
	
	# Sincronizar UI con los valores actuales del sifón
	if slider_energia: slider_energia.set_value_no_signal(sifon.valor_energia)
	if slider_freq: slider_freq.set_value_no_signal(sifon.ticks_por_disparo)
	
	_actualizar_preview()
	
	# Animación de aparición elegante (igual que Constructor)
	if ventana:
		ventana.scale = Vector2(0.88, 0.88)
		ventana.modulate.a = 0.0
		var t = create_tween()
		t.set_parallel(true)
		t.set_ease(Tween.EASE_OUT)
		t.set_trans(Tween.TRANS_BACK)
		t.tween_property(ventana, "scale", Vector2.ONE, 0.22)
		t.tween_property(ventana, "modulate:a", 1.0, 0.18)

func _reposicionar_ventana_sifon():
	if not is_instance_valid(sifon_activo) or not ventana: return
	var cam = get_viewport().get_camera_3d()
	if cam:
		var world_pos = sifon_activo.global_position + Vector3(0, 1.5, 0)
		var pos_2d = cam.unproject_position(world_pos)
		ventana.position = pos_2d - Vector2(140, 130)
		ventana.custom_minimum_size = Vector2(280, 260)
		if ventana is Container:
			ventana.queue_sort()
		# #region agent log
		var gr = ventana.get_global_rect()
		_agent_log("H2", "god_siphon_ui.gd:_reposicionar", "deferred reposition", {
			"ventana_pos": {"x": ventana.position.x, "y": ventana.position.y},
			"ventana_size": {"x": ventana.size.x, "y": ventana.size.y},
			"ventana_global_rect": {"x": gr.position.x, "y": gr.position.y, "w": gr.size.x, "h": gr.size.y}
		})
		# #endregion

func cerrar():
	if opt_color and opt_color.get_popup().visible: return
	if opt_tipo and opt_tipo.get_popup().visible: return
	
	sifon_activo = null
	visible = false
	_agent_logged_process = false

# --- LÓGICA DE ACTUALIZACIÓN DE DATOS ---

func _on_energia_changed(value: float):
	if lbl_energia_valor:
		lbl_energia_valor.text = "%.1f" % value
	_actualizar_preview()

func _on_freq_changed(value: float):
	if lbl_freq_valor:
		lbl_freq_valor.text = "%d ticks" % int(value)
	_actualizar_preview()

func _al_cambiar_tipo(index):
	# Ajustes automáticos por comodidad del usuario
	if slider_energia:
		match index:
			0: slider_energia.value = 1
			1: slider_energia.value = 10
			2, 3: slider_energia.value = 100
	_actualizar_preview()

func _actualizar_preview():
	if not lbl_preview:
		return
	
	var idx_color = opt_color.selected if opt_color else 0
	var idx_tipo = opt_tipo.selected if opt_tipo else 0
	var energia = slider_energia.value if slider_energia else default_energia
	var freq = slider_freq.value if slider_freq else default_freq
	
	var tipo_texto = ["Energía básica", "Comprimida", "UP", "DOWN"][idx_tipo]
	var color_texto = ["Stability", "Charge"][idx_color]
	
	lbl_preview.text = "VISTA PREVIA:\nProducción: %.1f %s/seg\nTipo: %s\nFrecuencia: %d ticks" % [energia, color_texto, tipo_texto, int(freq)]

func _aplicar_cambios():
	if not is_instance_valid(sifon_activo):
		return
	
	var idx_color = opt_color.selected if opt_color else 0
	var idx_tipo = opt_tipo.selected if opt_tipo else 0
	
	var recurso = ""
	var color = Color.WHITE
	
	# 1. Definir Recurso Base y Color
	if idx_color == 0: # E - Estabilidad
		recurso = GameConstants.RECURSO_STABILITY
		color = GameConstants.COLOR_STABILITY
	else: # C - Carga
		recurso = GameConstants.RECURSO_CHARGE
		color = GameConstants.COLOR_CHARGE
	
	# 2. Modificadores de Tipo
	var escala = 1.0
	match idx_tipo:
		1: # Comprimida
			recurso = GameConstants.PREFIJO_COMPRIMIDO + recurso
			escala = 1.5
		2: # Up Quark
			recurso = GameConstants.RECURSO_UP_QUARK
			color = GameConstants.COLOR_UP_QUARK
			escala = 1.2
		3: # Down Quark
			recurso = GameConstants.RECURSO_DOWN_QUARK
			color = GameConstants.COLOR_DOWN_QUARK
			escala = 1.2

	# 3. Aplicar configuración al Sifón
	sifon_activo.configurar_dios(
		recurso, 
		color, 
		escala, 
		int(slider_energia.value) if slider_energia else 1, 
		int(slider_freq.value) if slider_freq else 5
	)
	
	cerrar()

func _resetear_valores():
	if slider_energia: slider_energia.value = default_energia
	if slider_freq: slider_freq.value = default_freq
	if opt_color: opt_color.selected = 0
	if opt_tipo: opt_tipo.selected = 0
	_actualizar_preview()
