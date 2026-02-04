extends CanvasLayer

var constructor_activo: Node3D = null

# --- REFERENCIAS CON ACCESO ÚNICO (%) ---
# Ya no importa si usas MarginContainer o no, esto los encontrará.
@onready var ventana = $VentanaFlotante

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
	if not is_in_group("UIsEdificios"): add_to_group("UIsEdificios")
	
	set_process_input(true)
	
	# Rellenar lista solo con recetas desbloqueadas
	if opt_recetas:
		_rellenar_recetas_desbloqueadas()
		if not opt_recetas.item_selected.is_connected(_on_receta_cambiada):
			opt_recetas.item_selected.connect(_on_receta_cambiada)

	if btn_reclamar and not btn_reclamar.pressed.is_connected(_on_reclamar_pressed):
		btn_reclamar.pressed.connect(_on_reclamar_pressed)

func _input(event):
	# Cerrar con LMB o RMB fuera de la ventana (sin FondoDetector = sin recuadro gris)
	if not visible or not ventana: return
	if event is InputEventMouseButton and event.pressed:
		var viewport_h = get_viewport().get_visible_rect().size.y
		if get_viewport().get_mouse_position().y > viewport_h - 140:
			return
		if not ventana.get_global_rect().has_point(get_viewport().get_mouse_position()):
			cerrar()
			get_viewport().set_input_as_handled()

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
	
	# Cerrar otros menús de edificios (God Siphon, etc.)
	for n in get_tree().get_nodes_in_group("UIsEdificios"):
		if n != self and n.has_method("cerrar") and n.visible:
			n.cerrar()
	
	constructor_activo = edificio
	visible = true
	
	var cam = get_viewport().get_camera_3d()
	if cam and ventana:
		var pos_3d = edificio.global_position + Vector3(0, GameConstants.UI_OFFSET_3D_Y, 0)
		ventana.position = cam.unproject_position(pos_3d) - (ventana.size / 2)
		call_deferred("_reposicionar_ventana_constructor")
	
	# Animación de aparición elegante (igual que God Siphon)
	if ventana:
		ventana.scale = Vector2(0.88, 0.88)
		ventana.modulate.a = 0.0
		var t = create_tween()
		t.set_parallel(true)
		t.set_ease(Tween.EASE_OUT)
		t.set_trans(Tween.TRANS_BACK)
		t.tween_property(ventana, "scale", Vector2.ONE, 0.22)
		t.tween_property(ventana, "modulate:a", 1.0, 0.18)
	
	_rellenar_recetas_desbloqueadas()
	actualizar_vista()
	
	if opt_recetas:
		var index = 0
		for i in range(opt_recetas.item_count):
			if opt_recetas.get_item_text(i) == edificio.receta_seleccionada:
				index = i
				break
		opt_recetas.selected = index
	
func _reposicionar_ventana_constructor():
	if not is_instance_valid(constructor_activo) or not ventana: return
	var cam = get_viewport().get_camera_3d()
	if cam:
		var pos_3d = constructor_activo.global_position + Vector3(0, GameConstants.UI_OFFSET_3D_Y, 0)
		ventana.position = cam.unproject_position(pos_3d) - (ventana.size / 2)

func cerrar():
	if opt_recetas and opt_recetas.get_popup().visible: return
	constructor_activo = null
	visible = false

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
			if lbl_requisitos is RichTextLabel:
				lbl_requisitos.bbcode_enabled = true
			var lineas: Array[String] = ["Requiere:"]
			for r in info["inputs"]:
				var nec = info["inputs"][r]
				var act = constructor_activo.inventario_interno.get(r, 0)
				var etiqueta_col = _requisito_etiqueta_bbcode(r)
				var act_show: int
				var nec_show: int
				if r == "Compressed-Stability" or r == "Compressed-Charge":
					act_show = act / GameConstants.UNIDADES_COMPRIMIDAS_POR_UNIDAD
					nec_show = nec / GameConstants.UNIDADES_COMPRIMIDAS_POR_UNIDAD
				else:
					act_show = act
					nec_show = nec
				lineas.append("%s %d/%d" % [etiqueta_col, act_show, nec_show])
			lbl_requisitos.text = "\n".join(lineas)
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

	# 3. Lista Recursos (cifra sin duplicar nombre; colores por tipo)
	if lista_recursos:
		for c in lista_recursos.get_children(): c.queue_free()
		
		for tipo in constructor_activo.inventario_interno:
			var cant = constructor_activo.inventario_interno[tipo]
			var fila = HBoxContainer.new()
			var lbl = Label.new()
			lbl.text = "%s: %s" % [GameConstants.get_nombre_visible_recurso(tipo), GameConstants.format_cantidad_solo_cifra(tipo, cant)]
			lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			if tipo == "Stability" or tipo == "Compressed-Stability":
				lbl.add_theme_color_override("font_color", GameConstants.COLOR_STABILITY)
			elif tipo == "Charge" or tipo == "Compressed-Charge":
				lbl.add_theme_color_override("font_color", GameConstants.COLOR_CHARGE)
			elif tipo == "Up-Quark":
				lbl.add_theme_color_override("font_color", GameConstants.COLOR_UP_QUARK)
			elif tipo == "Down-Quark":
				lbl.add_theme_color_override("font_color", GameConstants.COLOR_DOWN_QUARK)
			
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

## Para requisitos compactos: etiqueta corta con color (E:, C:, UP:, DOWN:).
func _requisito_etiqueta_bbcode(nombre: String) -> String:
	var c_est = GameConstants.COLOR_STABILITY
	var c_car = GameConstants.COLOR_CHARGE
	var h_est = "#%02x%02x%02x" % [int(c_est.r * 255), int(c_est.g * 255), int(c_est.b * 255)]
	var h_car = "#%02x%02x%02x" % [int(c_car.r * 255), int(c_car.g * 255), int(c_car.b * 255)]
	var etiquetas = {
		"Stability": "[color=%s]E:[/color]" % h_est,
		"Charge": "[color=%s]C:[/color]" % h_car,
		"Compressed-Stability": "[color=%s]E. Condensada:[/color]" % h_est,
		"Compressed-Charge": "[color=%s]C. Condensada:[/color]" % h_car,
		"Up-Quark": "[color=#ffff00]UP:[/color]",
		"Down-Quark": "[color=#ff8000]DOWN:[/color]"
	}
	return etiquetas.get(nombre, nombre + ":")

## Nombre del recurso con BBCode de color (alineado con recipe_book y reglas UI).
func _color_nombre_recurso_bbcode(nombre: String) -> String:
	var c_est = GameConstants.COLOR_STABILITY
	var c_car = GameConstants.COLOR_CHARGE
	var h_est = "#%02x%02x%02x" % [int(c_est.r * 255), int(c_est.g * 255), int(c_est.b * 255)]
	var h_car = "#%02x%02x%02x" % [int(c_car.r * 255), int(c_car.g * 255), int(c_car.b * 255)]
	var colores = {
		"Stability": "[color=%s]Estabilidad E[/color]" % h_est,
		"Charge": "[color=%s]Carga C[/color]" % h_car,
		"Compressed-Stability": "[color=%s]Estabilidad Condensada E[/color]" % h_est,
		"Compressed-Charge": "[color=%s]Carga Condensada C[/color]" % h_car,
		"Up-Quark": "[color=#ffff00]UP[/color]",
		"Down-Quark": "[color=#ff8000]DOWN[/color]"
	}
	return colores.get(nombre, nombre)

func _rellenar_recetas_desbloqueadas():
	if not opt_recetas: return
	opt_recetas.clear()
	opt_recetas.add_item("--- Seleccionar Receta ---", 0)
	var id = 1
	for nombre in GameConstants.RECETAS:
		if TechTree and TechTree.is_unlocked(nombre):
			opt_recetas.add_item(nombre, id)
			id += 1

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
