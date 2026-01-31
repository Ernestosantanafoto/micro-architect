extends CanvasLayer

var sifon_activo: Node3D = null

# --- REFERENCIAS CON ACCESO ÚNICO (%) ---
@onready var ventana = %VentanaFlotante
@onready var fondo_detector = %FondoDetector

@onready var opt_color = %OptionColor
@onready var opt_tipo = %OptionTipo
@onready var spin_valor = %SpinValor
@onready var spin_freq = %SpinFrecuencia
@onready var btn_cerrar = %BtnCerrar

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
	
	# 2. Conexiones de Señales
	# Usamos una función anónima para que cualquier cambio en el color dispare la actualización
	if opt_color: opt_color.item_selected.connect(func(_idx): _al_cambiar_dato(0))
	if opt_tipo: opt_tipo.item_selected.connect(_al_cambiar_tipo)
	if spin_valor: spin_valor.value_changed.connect(_al_cambiar_dato)
	if spin_freq: spin_freq.value_changed.connect(_al_cambiar_dato)
	if btn_cerrar: btn_cerrar.pressed.connect(cerrar)
	
	# 3. Cierre al clicar en el fondo
	if fondo_detector:
		fondo_detector.gui_input.connect(_on_fondo_input)

func _process(_delta):
	if not visible or not is_instance_valid(sifon_activo):
		if visible: cerrar()
		return

	# --- ESTABILIZACIÓN DEL MENÚ ---
	# Si estamos interactuando con la UI, congelamos el movimiento para que no se cierre el desplegable
	if (opt_color and opt_color.get_popup().visible) or (opt_tipo and opt_tipo.get_popup().visible):
		return
	
	if ventana and ventana.get_global_rect().has_point(ventana.get_global_mouse_position()):
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
	if spin_valor: spin_valor.set_value_no_signal(sifon.valor_energia)
	if spin_freq: spin_freq.set_value_no_signal(sifon.ticks_por_disparo)
	
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

func _al_cambiar_tipo(index):
	# Ajustes automáticos por comodidad del usuario
	if spin_valor:
		match index:
			0: spin_valor.value = 1
			1: spin_valor.value = 10
			2, 3: spin_valor.value = 100
	_al_cambiar_dato(0)

func _al_cambiar_dato(_val):
	if not is_instance_valid(sifon_activo): return
	
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
		int(spin_valor.value) if spin_valor else 1, 
		int(spin_freq.value) if spin_freq else 5
	)
