extends Control

@onready var vertical_stack = $VerticalStack
@onready var category_box = $BottomBar/CategoryBox
@onready var construction_manager = get_tree().get_first_node_in_group("ConstructionManager")

## Ignorar el siguiente "clic fuera": el mismo clic que abre el menú llega a _input y cerraría el menú al instante.
var _ignorar_siguiente_clic_fuera := false

## Menú derivado de GameConstants.RECETAS + HUD_CATEGORIAS + HUD_LABELS (fuente única).
func _get_menu_data() -> Dictionary:
	var data = {}
	for cat in GameConstants.HUD_CATEGORIAS:
		data[cat] = []
		for inv_name in GameConstants.HUD_CATEGORIAS[cat]:
			if GameConstants.RECETAS.has(inv_name):
				var receta = GameConstants.RECETAS[inv_name]
				if receta.has("output_scene"):
					data[cat].append({
						"inv_name": inv_name,
						"label": GameConstants.HUD_LABELS.get(inv_name, inv_name),
						"scene": receta["output_scene"]
					})
	return data

func _ready():
	vertical_stack.visible = false
	_estilizar_botones_categoria()
	for child in category_box.get_children():
		if child is Button:
			child.pressed.connect(_on_category_pressed.bind(child))
			_setup_tooltip(child)
	set_process_input(true)

func _avisar_dim_menu_edificios(abierto: bool) -> void:
	# MainContainer -> InventoryHUD -> HUD -> MainGame3D (raíz). CanvasLayer es hijo de la raíz.
	var raiz = get_parent().get_parent().get_parent() if get_parent() else null
	var canvas = raiz.get_node_or_null("CanvasLayer") if raiz else null
	if canvas and canvas.has_method("aplicar_dim_menu_edificios"):
		canvas.aplicar_dim_menu_edificios(abierto)

func _input(event):
	if not vertical_stack.visible: return
	if event is InputEventMouseButton and event.pressed:
		var pos = vertical_stack.get_global_mouse_position()
		var dentro = vertical_stack.get_global_rect().has_point(pos)
		var cat_activa := vertical_stack.get_meta("cat_activa", "") as String
		var en_boton_que_abrio := false
		for child in category_box.get_children():
			if child is Button and (child as Button).text.to_upper().strip_edges() == cat_activa:
				if (child as Control).get_global_rect().has_point(pos):
					en_boton_que_abrio = true
					break
		var en_barra_categorias = category_box.get_global_rect().has_point(pos)
		# Raíz de la escena (MainGame3D): MainContainer -> InventoryHUD -> HUD -> raíz
		var raiz = get_parent().get_parent().get_parent() if get_parent() else null
		var panel_sistema = raiz.get_node_or_null("CanvasLayer/PanelSistema") as Control if raiz else null
		var panel_infra = raiz.get_node_or_null("CanvasLayer/PanelInfraestructura") as Control if raiz else null
		var en_menu_o_infra = (panel_sistema and panel_sistema.get_global_rect().has_point(pos)) or (panel_infra and panel_infra.get_global_rect().has_point(pos))
		# Regla única: cerrar si picas fuera del menú O en el botón que lo abrió. Consumir solo si mismo botón o clic fuera de toda la UI.
		if _ignorar_siguiente_clic_fuera:
			_ignorar_siguiente_clic_fuera = false
			if dentro and not en_boton_que_abrio:
				return
			_cerrar_menu()
			if en_boton_que_abrio or (not en_barra_categorias and not en_menu_o_infra):
				get_viewport().set_input_as_handled()
			return
		if not dentro or en_boton_que_abrio:
			_cerrar_menu()
			if en_boton_que_abrio or (not en_barra_categorias and not en_menu_o_infra):
				get_viewport().set_input_as_handled()

func _estilizar_botones_categoria():
	var estilo = StyleBoxFlat.new()
	estilo.bg_color = Color(0.12, 0.14, 0.18, 0.9)
	estilo.corner_radius_top_left = 6
	estilo.corner_radius_top_right = 6
	estilo.corner_radius_bottom_left = 6
	estilo.corner_radius_bottom_right = 6
	estilo.border_width_left = 1
	estilo.border_width_top = 1
	estilo.border_width_right = 1
	estilo.border_width_bottom = 1
	estilo.border_color = Color(0.2, 0.35, 0.5, 0.6)
	estilo.content_margin_left = 14.0
	estilo.content_margin_top = 6.0
	estilo.content_margin_right = 14.0
	estilo.content_margin_bottom = 6.0
	const ANCHO_BOTON_CATEGORIA := 125
	const ALTO_BOTON_CATEGORIA := 60
	for child in category_box.get_children():
		if child is Button:
			(child as Control).custom_minimum_size = Vector2(ANCHO_BOTON_CATEGORIA, ALTO_BOTON_CATEGORIA)
			child.add_theme_stylebox_override("normal", estilo.duplicate())
			child.add_theme_stylebox_override("hover", _estilo_hover(estilo))
			child.add_theme_stylebox_override("pressed", _estilo_pressed(estilo))
			child.add_theme_font_size_override("font_size", 13)

func _estilo_hover(base: StyleBoxFlat) -> StyleBoxFlat:
	var s = base.duplicate()
	s.bg_color = Color(0.18, 0.22, 0.28, 0.95)
	return s

func _estilo_pressed(base: StyleBoxFlat) -> StyleBoxFlat:
	var s = base.duplicate()
	s.bg_color = Color(0.08, 0.1, 0.14, 1.0)
	return s

func _on_category_pressed(boton: Button):
	var txt = boton.text.to_upper().strip_edges()
	
	# Acciones especiales (no son categorías de construcción)
	match txt:
		"SOLTAR":
			_cerrar_menus_edificios()
			_ejecutar_devolucion()
			return
		"ELIMINAR":
			_cerrar_menus_edificios()
			if construction_manager: 
				construction_manager.destruir_item_en_mano()
			return
	
	# Categorías de construcción: cerrar menús de edificios para quitar fricción
	_cerrar_menus_edificios()
	
	var menu_data = _get_menu_data()
	if not menu_data.has(txt):
		return
	
	# Toggle: si el menú ya está abierto, cerrarlo
	if vertical_stack.visible and vertical_stack.get_meta("cat_activa", "") == txt:
		_cerrar_menu()
		return
	
	_construir_items_verticales(txt, boton)

func _ejecutar_devolucion():
	if GameConstants.DEBUG_MODE:
		print("[HUD] Solicitando devolución de elemento al inventario...")
	if construction_manager:
		construction_manager.devolver_a_inventario()

func _construir_items_verticales(categoria: String, boton_origen: Button):
	for child in vertical_stack.get_children(): child.queue_free()
	
	var menu_data = _get_menu_data()
	var items = menu_data[categoria]
	var botones_creados = 0
	
	for item in items:
		# Solo mostrar edificios desbloqueados (inventario se comprueba al colocar)
		if TechTree and not TechTree.is_unlocked(item["inv_name"]):
			continue
		var cantidad = GlobalInventory.get_amount(item["inv_name"])
		botones_creados += 1
		var btn = Button.new()
		btn.text = "%s\nx%d" % [item["label"], cantidad]
		btn.custom_minimum_size = Vector2(125, 90)
		
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.1, 0.1, 0.1, 0.9)
		style.corner_radius_top_left = 6
		style.corner_radius_top_right = 6
		style.corner_radius_bottom_left = 6
		style.corner_radius_bottom_right = 6
		style.set_border_width_all(2)
		style.border_color = Color.CYAN if "T2" not in item["label"] else Color.GOLD
		btn.add_theme_stylebox_override("normal", style)
		
		btn.pressed.connect(_on_item_seleccionado.bind(item["scene"], item["inv_name"]))
		vertical_stack.add_child(btn)
	
	if botones_creados == 0:
		_cerrar_menu()
		return

	_ignorar_siguiente_clic_fuera = true
	vertical_stack.visible = true
	vertical_stack.set_meta("cat_activa", categoria)
	# No aplicar DIM al menú del HUD central (solo INFRAESTRUCTURA/Recursos lo usa)
	await get_tree().process_frame
	var pos_x = boton_origen.global_position.x + (boton_origen.size.x / 2) - (vertical_stack.size.x / 2)
	var pos_y = $BottomBar.global_position.y - vertical_stack.size.y - 15
	vertical_stack.global_position = Vector2(pos_x, pos_y)

func _on_item_seleccionado(ruta_escena, nombre_inventario):
	# Cerrar menús de edificios (Constructor, God Siphon) para que el clic sirva directo
	_cerrar_menus_edificios()
	if construction_manager:
		var escena = load(ruta_escena)
		if escena:
			construction_manager.seleccionar_para_construir(escena, nombre_inventario)
	_cerrar_menu()

func _cerrar_menu():
	vertical_stack.visible = false
	vertical_stack.set_meta("cat_activa", "")
	# No quitar DIM aquí (el HUD central no aplica DIM)

## Llamado al cambiar DEBUG_MODE desde el botón del panel sistema; refresca el menú abierto si hay uno.
func refresh_debug_menu():
	if not vertical_stack.visible:
		return
	var cat = vertical_stack.get_meta("cat_activa", "")
	if cat.is_empty():
		return
	for child in category_box.get_children():
		if child is Button and child.text.to_upper().strip_edges() == cat:
			_construir_items_verticales(cat, child)
			return

func _cerrar_menus_edificios():
	for n in get_tree().get_nodes_in_group("UIsEdificios"):
		if n.has_method("cerrar") and n.visible:
			n.cerrar()

func _setup_tooltip(boton: Button):
	var txt = boton.text.to_upper().strip_edges()
	var tooltips = {
		"SIFONES": "Extractores de energía (Siphons T1 y T2)",
		"PRISMAS": "Redirigen haces de energía (Rectos y Angulares)",
		"GESTION": "Compresores, Fusionador, Fabricador Hadrón, Void Generator",
		"CREACION": "Constructor de edificios (consume quarks)",
		"SOLTAR": "Devolver edificio al inventario",
		"ELIMINAR": "Destruir edificio en mano"
	}
	if tooltips.has(txt):
		boton.tooltip_text = tooltips[txt]
