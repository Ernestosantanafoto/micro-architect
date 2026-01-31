extends CanvasLayer

var constructor_activo: Node3D = null

# --- REFERENCIAS CON ACCESO ÚNICO (%) ---
# Ya no importa si usas MarginContainer o no, esto los encontrará.
@onready var ventana = $VentanaFlotante
@onready var fondo_detector = $FondoDetector

# Nodos de Datos (Asegúrate de haberles puesto el % en el editor)
@onready var opt_recetas = %OptionButton
@onready var bar_progreso = %BarraProgreso
@onready var lbl_requisitos = %LabelRequisitos
@onready var bar_almacen = %BarraAlmacen
@onready var lbl_almacen = %LabelAlmacen
@onready var lista_recursos = %ListaRecursos
@onready var btn_reclamar = %BotonReclamar

func _ready():
	visible = false
	
	# Grupos
	if not is_in_group("VentanasUI"): add_to_group("VentanasUI")
	if not is_in_group("VentanaConstructor"): add_to_group("VentanaConstructor")
	
	# Filtros de ratón
	if fondo_detector: fondo_detector.gui_input.connect(_on_fondo_input)
	
	# Rellenar lista
	if opt_recetas:
		opt_recetas.clear()
		opt_recetas.add_item("--- Seleccionar Receta ---", 0)
		var id = 1
		for nombre in GameConstants.RECETAS:
			opt_recetas.add_item(nombre, id)
			id += 1
		
		# Conexión segura
		if not opt_recetas.item_selected.is_connected(_on_receta_cambiada):
			opt_recetas.item_selected.connect(_on_receta_cambiada)

	if btn_reclamar and not btn_reclamar.pressed.is_connected(_on_reclamar_pressed):
		btn_reclamar.pressed.connect(_on_reclamar_pressed)

func _process(_delta):
	if not visible or not is_instance_valid(constructor_activo):
		if visible: cerrar()
		return

	# --- ESTABILIZACIÓN ---
	if opt_recetas and opt_recetas.get_popup().visible: return
	if ventana and ventana.get_global_rect().has_point(ventana.get_global_mouse_position()): return

	# --- SEGUIMIENTO ---
	var cam = get_viewport().get_camera_3d()
	if cam and ventana:
		var pos_3d = constructor_activo.global_position + Vector3(0, GameConstants.UI_OFFSET_3D_Y, 0)
		if not cam.is_position_behind(pos_3d):
			ventana.modulate.a = 1
			var target_pos = cam.unproject_position(pos_3d) - (ventana.size / 2)
			ventana.position = ventana.position.lerp(target_pos, 0.2)
		else:
			ventana.modulate.a = 0

# --- API ---
func abrir_menu(edificio):
	if visible and constructor_activo == edificio: return
	
	constructor_activo = edificio
	visible = true
	actualizar_vista()
	
	if opt_recetas:
		var index = 0
		for i in range(opt_recetas.item_count):
			if opt_recetas.get_item_text(i) == edificio.receta_seleccionada:
				index = i
				break
		opt_recetas.selected = index
	
	if ventana:
		ventana.scale = Vector2.ONE * 0.1
		var t = create_tween()
		t.tween_property(ventana, "scale", Vector2.ONE, GameConstants.UI_POP_TIME).set_trans(Tween.TRANS_BACK)

func cerrar():
	if opt_recetas and opt_recetas.get_popup().visible: return
	constructor_activo = null
	visible = false

func _on_fondo_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		cerrar()

# --- VISTA ---
func actualizar_vista():
	if not is_instance_valid(constructor_activo): return
	
	# 1. Progreso
	var receta = constructor_activo.receta_seleccionada
	if receta != "":
		var info = GameConstants.RECETAS[receta]
		if bar_progreso:
			bar_progreso.max_value = info["tiempo"]
			bar_progreso.value = constructor_activo.tiempo_progreso
		
		if lbl_requisitos:
			var txt = "Requiere: "
			for r in info["inputs"]:
				var nec = info["inputs"][r]
				var act = constructor_activo.inventario_interno.get(r, 0)
				txt += "%s (%d/%d) " % [r, act, nec]
			lbl_requisitos.text = txt
	else:
		if bar_progreso: bar_progreso.value = 0
		if lbl_requisitos: lbl_requisitos.text = "Selecciona receta..."

	# 2. Almacén
	var total = constructor_activo.total_almacenado
	var maximo = constructor_activo.CAPACIDAD_MAXIMA
	
	if bar_almacen:
		bar_almacen.max_value = maximo
		bar_almacen.value = total
		var style = bar_almacen.get_theme_stylebox("fill")
		if style and style is StyleBoxFlat:
			style.bg_color = Color.RED if total >= maximo else Color.BLUE
			
	if lbl_almacen:
		lbl_almacen.text = "Almacén: %d / %d" % [total, maximo]

	# 3. Lista Recursos
	if lista_recursos:
		for c in lista_recursos.get_children(): c.queue_free()
		
		for tipo in constructor_activo.inventario_interno:
			var cant = constructor_activo.inventario_interno[tipo]
			var fila = HBoxContainer.new()
			var lbl = Label.new()
			lbl.text = "%s: %d" % [tipo, cant]
			lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			
			var btn = Button.new()
			btn.text = "X"
			btn.pressed.connect(_on_purgar.bind(tipo))
			
			fila.add_child(lbl)
			fila.add_child(btn)
			lista_recursos.add_child(fila)

	# 4. Reclamar
	if btn_reclamar:
		var pendientes = constructor_activo.inventario_salida.size()
		btn_reclamar.text = "RECLAMAR (%d)" % pendientes
		btn_reclamar.visible = pendientes > 0

# --- SEÑALES ---
func _on_receta_cambiada(index):
	if constructor_activo and opt_recetas:
		var r = ""
		if index > 0: r = opt_recetas.get_item_text(index)
		constructor_activo.cambiar_receta(r)
		actualizar_vista()

func _on_reclamar_pressed():
	if constructor_activo:
		constructor_activo.reclamar_todo()
		actualizar_vista()

func _on_purgar(tipo):
	if constructor_activo:
		constructor_activo.purgar_recurso(tipo)
		actualizar_vista()
