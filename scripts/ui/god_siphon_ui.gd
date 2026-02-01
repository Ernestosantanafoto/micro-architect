extends CanvasLayer

var sifon_activo: Node3D = null

# --- REFERENCIAS CON ACCESO ÚNICO (%) ---
@onready var ventana = %VentanaFlotante
@onready var fondo_detector = %FondoDetector

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

func _ready():
	visible = false
	add_to_group("VentanasUI") 
	
	# 1. Configuración de los Dropdowns
	if opt_color:
		opt_color.clear()
		opt_color.add_item("Verde (Estabilidad)", 0)
		opt_color.add_item("Azul (Carga)", 1)
		
	if opt_tipo:
		opt_tipo.clear()
		opt_tipo.add_item("Energía Base", 0)
		opt_tipo.add_item("Comprimida", 1)
		opt_tipo.add_item("Quark Up", 2)
		opt_tipo.add_item("Quark Down", 3)
	
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
	
	# 3. Cierre al clicar en el fondo
	if fondo_detector:
		fondo_detector.gui_input.connect(_on_fondo_input)

func _process(_delta):
	if not visible or not is_instance_valid(sifon_activo):
		if visible: cerrar()
		return

	# --- ESTABILIZACIÓN DEL MENÚ ---
	if (opt_color and opt_color.get_popup().visible) or (opt_tipo and opt_tipo.get_popup().visible):
		return
	
	if ventana and ventana.get_global_rect().has_point(get_viewport().get_mouse_position()):
		return

	# --- SEGUIMIENTO AL OBJETO 3D ---
	var cam = get_viewport().get_camera_3d()
	if cam and ventana:
		var world_pos = sifon_activo.global_position + Vector3(0, 1.5, 0)
		if not cam.is_position_behind(world_pos):
			ventana.modulate.a = 1
			var target_pos = cam.unproject_position(world_pos) - (ventana.size / 2)
			ventana.position = ventana.position.lerp(target_pos, 0.2)
		else:
			ventana.modulate.a = 0

# --- FUNCIONES DE CONTROL ---

func abrir(sifon):
	if visible and sifon_activo == sifon: return
	
	sifon_activo = sifon
	visible = true
	
	# Sincronizar UI con los valores actuales del sifón
	if slider_energia: slider_energia.set_value_no_signal(sifon.valor_energia)
	if slider_freq: slider_freq.set_value_no_signal(sifon.ticks_por_disparo)
	
	_actualizar_preview()
	
	# Animación de aparición
	if ventana:
		ventana.scale = Vector2.ONE * 0.1
		var t = create_tween()
		t.tween_property(ventana, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK)

func cerrar():
	# Bloqueo de seguridad si el desplegable está abierto
	if opt_color and opt_color.get_popup().visible: return
	if opt_tipo and opt_tipo.get_popup().visible: return
	
	sifon_activo = null
	visible = false

func _on_fondo_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		cerrar()

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
	
	var tipo_texto = ["Energía básica", "Comprimida", "Quark Up", "Quark Down"][idx_tipo]
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
	if idx_color == 0: # VERDE
		recurso = GameConstants.RECURSO_STABILITY
		color = GameConstants.COLOR_STABILITY
	else: # AZUL
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
