extends Node

const SAVE_PATH = "user://mundo_persistente.save"

func _ready():
	_estilizar_botones_paneles()
	var btn_debug = get_node_or_null("PanelSistema/HBoxContainer/BtnDebug")
	if btn_debug and btn_debug is BaseButton:
		btn_debug.pressed.connect(_on_btn_debug_pressed)
		_actualizar_texto_debug(btn_debug)

func _estilizar_botones_paneles():
	var estilo_normal = _crear_estilo_boton(Color(0.12, 0.15, 0.2, 0.95))
	var estilo_hover = _crear_estilo_boton(Color(0.18, 0.22, 0.3, 0.98))
	var estilo_pressed = _crear_estilo_boton(Color(0.08, 0.1, 0.14, 1.0))
	for btn in [get_node_or_null("PanelSistema/HBoxContainer/BtnGuardar"),
		get_node_or_null("PanelSistema/HBoxContainer/BtnModoSeleccion"),
		get_node_or_null("PanelSistema/HBoxContainer/BtnMenu"),
		get_node_or_null("PanelSistema/HBoxContainer/BtnDebug"),
		get_node_or_null("PanelEliminar/HBoxContainer/BtnEliminar")]:
		if btn and btn is BaseButton:
			btn.custom_minimum_size = Vector2(90, 56)
			btn.add_theme_stylebox_override("normal", estilo_normal.duplicate())
			btn.add_theme_stylebox_override("hover", estilo_hover.duplicate())
			btn.add_theme_stylebox_override("pressed", estilo_pressed.duplicate())
			if btn is Button and btn.toggle_mode:
				btn.add_theme_stylebox_override("hover_pressed", estilo_hover.duplicate())
			btn.add_theme_font_size_override("font_size", 14)

func _crear_estilo_boton(bg: Color) -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	s.bg_color = bg
	s.corner_radius_top_left = 6
	s.corner_radius_top_right = 6
	s.corner_radius_bottom_left = 6
	s.corner_radius_bottom_right = 6
	s.border_width_left = 1
	s.border_width_top = 1
	s.border_width_right = 1
	s.border_width_bottom = 1
	s.border_color = Color(0.25, 0.4, 0.55, 0.8)
	s.content_margin_left = 12.0
	s.content_margin_top = 8.0
	s.content_margin_right = 12.0
	s.content_margin_bottom = 8.0
	return s

func _actualizar_texto_debug(btn: Button) -> void:
	if btn:
		btn.text = "DEBUG ON" if GameConstants.DEBUG_MODE else "DEBUG OFF"

func _on_btn_debug_pressed() -> void:
	GameConstants.DEBUG_MODE = not GameConstants.DEBUG_MODE
	var btn_debug = get_node_or_null("PanelSistema/HBoxContainer/BtnDebug")
	_actualizar_texto_debug(btn_debug as Button)
	if GameConstants.DEBUG_MODE:
		GlobalInventory.add_item("GodSiphon", 3)
	var inventory_hud = get_parent().get_node_or_null("InventoryHUD/MainContainer")
	if inventory_hud and inventory_hud.has_method("refresh_debug_menu"):
		inventory_hud.refresh_debug_menu()

func guardar_partida():
	print("[DEBUG-SAVE] Iniciando volcado total...")
	var gm = get_tree().get_first_node_in_group("MapaPrincipal")
	var lista_entidades = []
	
	if gm:
		for cell in gm.get_used_cells():
			var id = gm.get_cell_item(cell)
			if id > 2: # Solo guardamos edificios
				var rot = gm.get_cell_item_orientation(cell)
				# 1. Obtenemos estado interno (si el edificio existe en memoria)
				var estado = GlobalInventory.obtener_estado_edificio(cell)
				
				lista_entidades.append({
					"pos": {"x": cell.x, "y": cell.y, "z": cell.z},
					"id": id,
					"rot": rot,
					"estado": estado
				})

	var paquete = {
		"semilla": GlobalInventory.semilla_mundo,
		"inventario": GlobalInventory.stock,
		"entidades": lista_entidades
	}

	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_line(JSON.stringify(paquete))
	file.close()
	print("[DEBUG-SAVE] Guardado con éxito: ", lista_entidades.size(), " edificios.")

func cargar_partida() -> bool:
	if not FileAccess.file_exists(SAVE_PATH): return false
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var datos = JSON.parse_string(file.get_as_text())
	file.close()
	
	if datos:
		GlobalInventory.semilla_mundo = datos["semilla"]
		GlobalInventory.stock = datos["inventario"]
		GlobalInventory.edificios_para_reconstruir = datos["entidades"]
		return true
	return false
