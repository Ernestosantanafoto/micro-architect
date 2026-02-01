extends Control

@onready var vertical_stack = $VerticalStack
@onready var category_box = $BottomBar/CategoryBox
@onready var construction_manager = get_tree().get_first_node_in_group("ConstructionManager")

var menu_data = {
	"SIFONES": [
		{"inv_name": "Sifón", "label": "Sifón T1", "scene": "res://scenes/buildings/siphon_t1.tscn"},
		{"inv_name": "Sifón T2", "label": "Sifón T2", "scene": "res://scenes/buildings/siphon_t2.tscn"}
	],
	"PRISMAS": [
		{"inv_name": "Prisma Recto", "label": "Recto T1", "scene": "res://scenes/buildings/prism_straight.tscn"},
		{"inv_name": "Prisma Angular", "label": "Ang. T1", "scene": "res://scenes/buildings/prism_angle.tscn"},
		{"inv_name": "Prisma Recto T2", "label": "Recto T2", "scene": "res://scenes/buildings/prism_straight_t2.tscn"},
		{"inv_name": "Prisma Angular T2","label": "Ang. T2", "scene": "res://scenes/buildings/prism_angle_t2.tscn"}
	],
	"MANIPULA": [
		{"inv_name": "Compresor", "label": "Compr. T1", "scene": "res://scenes/buildings/compressor.tscn"},
		{"inv_name": "Compresor T2", "label": "Compr. T2", "scene": "res://scenes/buildings/compressor_t2.tscn"},
		{"inv_name": "Fusionador", "label": "Fusión", "scene": "res://scenes/buildings/merger.tscn"},
		{"inv_name": "Void Generator", "label": "Void Gen", "scene": "res://scenes/buildings/void_generator.tscn"}
	],
	"CONSTR": [
		{"inv_name": "Constructor", "label": "Maker", "scene": "res://scenes/buildings/constructor.tscn"}
	]
}

func _ready():
	vertical_stack.visible = false
	
	# Configurar botones con tooltips
	for child in category_box.get_children():
		if child is Button:
			child.pressed.connect(_on_category_pressed.bind(child))
			_setup_tooltip(child)

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
	
	if not menu_data.has(txt):
		return
	
	# Toggle: si el menú ya está abierto, cerrarlo
	if vertical_stack.visible and vertical_stack.get_meta("cat_activa", "") == txt:
		_cerrar_menu()
		return
	
	_construir_items_verticales(txt, boton)

func _ejecutar_devolucion():
	print("[HUD] Solicitando devolución de elemento al inventario...")
	if construction_manager:
		construction_manager.devolver_a_inventario()

func _construir_items_verticales(categoria: String, boton_origen: Button):
	for child in vertical_stack.get_children(): child.queue_free()
	
	var items = menu_data[categoria]
	var botones_creados = 0
	
	for item in items:
		var cantidad = GlobalInventory.get_amount(item["inv_name"])
		if cantidad <= 0 and not GameConstants.DEBUG_MODE: continue
		
		botones_creados += 1
		var btn = Button.new()
		btn.text = "%s\nx%d" % [item["label"], cantidad]
		btn.custom_minimum_size = Vector2(90, 90)
		
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.1, 0.1, 0.1, 0.9)
		style.set_border_width_all(2)
		style.border_color = Color.CYAN if "T2" not in item["label"] else Color.GOLD
		btn.add_theme_stylebox_override("normal", style)
		
		btn.pressed.connect(_on_item_seleccionado.bind(item["scene"], item["inv_name"]))
		vertical_stack.add_child(btn)
	
	if botones_creados == 0:
		_cerrar_menu()
		return

	vertical_stack.visible = true
	vertical_stack.set_meta("cat_activa", categoria)
	
	await get_tree().process_frame
	var pos_x = boton_origen.global_position.x + (boton_origen.size.x / 2) - (vertical_stack.size.x / 2)
	var pos_y = $BottomBar.global_position.y - vertical_stack.size.y - 15
	vertical_stack.global_position = Vector2(pos_x, pos_y)

func _on_item_seleccionado(ruta_escena, nombre_inventario):
	# Cerrar menús de edificios (Constructor, God Siphon) para que el clic sirva directo
	_cerrar_menus_edificios()
	if construction_manager:
		var escena = load(ruta_escena)
		construction_manager.seleccionar_para_construir(escena, nombre_inventario)
	_cerrar_menu()

func _cerrar_menu():
	vertical_stack.visible = false
	vertical_stack.set_meta("cat_activa", "")

func _cerrar_menus_edificios():
	for n in get_tree().get_nodes_in_group("UIsEdificios"):
		if n.has_method("cerrar") and n.visible:
			n.cerrar()

func _setup_tooltip(boton: Button):
	var txt = boton.text.to_upper().strip_edges()
	var tooltips = {
		"SIFONES": "Extractores de energía (Siphons)",
		"PRISMAS": "Redirigen haces de energía",
		"MANIPULA": "Compresores, Fusionadores, Void Generators",
		"CONSTR": "Constructores de edificios",
		"SOLTAR": "Devolver edificio al inventario",
		"ELIMINAR": "Destruir edificio en mano"
	}
	
	if tooltips.has(txt):
		boton.tooltip_text = tooltips[txt]
