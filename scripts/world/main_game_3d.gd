extends Node

signal game_tick(tick_count)

var current_tick = 0
var tiempo_acumulado = 0.0
var TIEMPO_ENTRE_TICS = GameConstants.GAME_TICK_DURATION

# Pop-up de desbloqueo de tecnología (F2)
var _tech_notification_layer: CanvasLayer = null
var _tech_notification_panel: PanelContainer = null
var _tech_notification_label: Label = null
var _tech_notification_timer: Timer = null

const TECH_NOTIFICATION_DURATION := 4.5

func _ready():
	# Buscar y conectar botones automáticamente
	_conectar_botones()
	_crear_popup_desbloqueo()
	if TechTree and TechTree.has_signal("tech_unlocked"):
		TechTree.tech_unlocked.connect(_on_tech_unlocked)

func _conectar_botones():
	# Conectar todos los botones GUARDAR (PanelSistema y BottomBar) para que guardar siempre funcione
	var btns_save = _find_all_children_by_name(self, "BtnGuardar")
	for btn_save in btns_save:
		if btn_save is BaseButton and not btn_save.pressed.is_connected(_on_btn_guardar_pressed):
			btn_save.pressed.connect(_on_btn_guardar_pressed)
			print("[MAIN] Botón GUARDAR conectado: ", btn_save.get_path())
	
	# Buscar botón de menú (puede llamarse BtnMenu, ButtonMenu, etc.)
	var nombres_menu = ["BtnMenu", "ButtonMenu", "Menu", "MenuButton", "BtnSalir"]
	for nombre in nombres_menu:
		var btn = _buscar_boton(nombre)
		if btn:
			if not btn.pressed.is_connected(_on_btn_menu_pressed):
				btn.pressed.connect(_on_btn_menu_pressed)
			print("[MAIN] Botón MENÚ conectado: ", nombre)
			break
	
	# Modo selección (Button toggle_mode): mismo aspecto que GUARDAR/MENÚ
	var btn_modo_sel = find_child("BtnModoSeleccion", true, false)
	if btn_modo_sel and btn_modo_sel is BaseButton and btn_modo_sel.has_signal("toggled"):
		if not btn_modo_sel.toggled.is_connected(_on_btn_modo_seleccion_toggled):
			btn_modo_sel.toggled.connect(_on_btn_modo_seleccion_toggled)
		var sm = find_child("SelectionManager", true, false)
		if sm and sm.has_method("set_selection_mode_enabled"):
			sm.selection_mode_enabled = btn_modo_sel.button_pressed
		print("[MAIN] Botón SELECCIÓN conectado.")
	
	# ELIMINAR (esquina inferior derecha): borra el contenido de la selección confirmada
	var btn_eliminar = find_child("BtnEliminar", true, false)
	if btn_eliminar and btn_eliminar is Button:
		if not btn_eliminar.pressed.is_connected(_on_btn_eliminar_pressed):
			btn_eliminar.pressed.connect(_on_btn_eliminar_pressed)
		print("[MAIN] Botón ELIMINAR conectado.")

func _on_btn_modo_seleccion_toggled(button_pressed: bool) -> void:
	var sm = find_child("SelectionManager", true, false)
	if sm and sm.has_method("set_selection_mode_enabled"):
		sm.set_selection_mode_enabled(button_pressed)

func _on_btn_eliminar_pressed() -> void:
	var sm = find_child("SelectionManager", true, false)
	if sm and sm.is_selection_mode_enabled() and sm.is_confirmed():
		sm.apply_action("delete")

func _cerrar_cualquier_ui_abierta() -> bool:
	# F1/F2 (PanelesAyuda)
	for n in get_tree().get_nodes_in_group("PanelesAyuda"):
		if n.visible and n.has_method("hide_panel"):
			n.hide_panel()
			return true
	# Menús de edificios (God Siphon, Constructor)
	for n in get_tree().get_nodes_in_group("UIsEdificios"):
		if n.visible and n.has_method("cerrar"):
			n.cerrar()
			return true
	return false

func _buscar_boton(nombre: String) -> Button:
	# Buscar en toda la escena
	var btn = find_child(nombre, true, false)
	if btn and btn is Button:
		return btn
	return null

func _find_all_children_by_name(nodo: Node, nombre: String) -> Array:
	var out: Array = []
	if nodo.name == nombre:
		out.append(nodo)
	for c in nodo.get_children():
		out.append_array(_find_all_children_by_name(c, nombre))
	return out

func _crear_popup_desbloqueo():
	_tech_notification_layer = CanvasLayer.new()
	_tech_notification_layer.name = "TechNotificationLayer"
	add_child(_tech_notification_layer)
	
	_tech_notification_panel = PanelContainer.new()
	_tech_notification_panel.name = "TechNotificationPanel"
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.12, 0.2, 0.92)
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.4, 0.7, 1.0, 0.8)
	style.content_margin_left = 24.0
	style.content_margin_top = 16.0
	style.content_margin_right = 24.0
	style.content_margin_bottom = 16.0
	_tech_notification_panel.add_theme_stylebox_override("panel", style)
	_tech_notification_panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_tech_notification_panel.offset_left = 80.0
	_tech_notification_panel.offset_right = -80.0
	_tech_notification_panel.offset_top = 80.0
	_tech_notification_panel.offset_bottom = 120.0
	_tech_notification_panel.visible = false
	_tech_notification_layer.add_child(_tech_notification_panel)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	_tech_notification_panel.add_child(margin)
	
	_tech_notification_label = Label.new()
	_tech_notification_label.name = "TechNotificationLabel"
	_tech_notification_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_tech_notification_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_tech_notification_label.add_theme_font_size_override("font_size", 20)
	_tech_notification_label.add_theme_color_override("font_color", Color.WHITE)
	_tech_notification_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_tech_notification_label.text = ""
	margin.add_child(_tech_notification_label)
	
	_tech_notification_timer = Timer.new()
	_tech_notification_timer.one_shot = true
	_tech_notification_timer.timeout.connect(_hide_tech_notification)
	add_child(_tech_notification_timer)

func _on_tech_unlocked(tech_name: String) -> void:
	_tech_notification_label.text = "Has desbloqueado %s. Pulsa F2 para más información." % tech_name
	_tech_notification_panel.visible = true
	if _tech_notification_timer.time_left > 0:
		_tech_notification_timer.stop()
	_tech_notification_timer.start(TECH_NOTIFICATION_DURATION)

func _hide_tech_notification() -> void:
	if _tech_notification_panel:
		_tech_notification_panel.visible = false

func _process(delta):
	tiempo_acumulado += delta
	if tiempo_acumulado >= TIEMPO_ENTRE_TICS:
		tiempo_acumulado -= TIEMPO_ENTRE_TICS
		current_tick += 1
		game_tick.emit(current_tick)

func _unhandled_input(event):
	var sm = find_child("SelectionManager", true, false)
	var cm = find_child("ConstructionManager", true, false)
	
	# --- Selección por arrastre (solo si modo selección activo; casillas vacías, hold threshold) ---
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if sm and sm.is_selection_mode_enabled() and cm and not cm.fantasma:
					var cell = sm.get_cell_under_mouse()
					if cell != null and GridManager and not GridManager.is_cell_occupied(Vector2i(int(cell.x), int(cell.y))):
						sm.start_hold(cell)
						get_viewport().set_input_as_handled()
			else:
				if sm and sm.is_selection_mode_enabled() and sm.is_selecting():
					sm.confirm()
					get_viewport().set_input_as_handled()
	
	if event is InputEventMouseMotion:
		if sm and sm.is_selection_mode_enabled() and sm.is_selecting() and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			var cell = sm.get_cell_under_mouse()
			if cell != null:
				sm.update_drag(cell)
			get_viewport().set_input_as_handled()
	
	# Atajos de teclado
	if event is InputEventKey and event.pressed:
		if not cm:
			cm = find_child("ConstructionManager", true, false)
		
		match event.keycode:
			KEY_F5:
				_on_btn_guardar_pressed()
			KEY_ESCAPE:
				if _cerrar_cualquier_ui_abierta():
					get_viewport().set_input_as_handled()
				elif sm and sm.is_selection_mode_enabled() and sm.is_confirmed():
					sm.clear_selection()
					get_viewport().set_input_as_handled()
				elif cm and cm.fantasma:
					cm.cancelar_construccion_y_guardar()
				else:
					_on_btn_menu_pressed()
			KEY_R:
				if cm and cm.fantasma:
					cm.fantasma.rotate_y(deg_to_rad(90))
				elif sm and sm.is_selection_mode_enabled() and sm.is_confirmed():
					sm.apply_action("refund")
					get_viewport().set_input_as_handled()
			KEY_DELETE:
				if sm and sm.is_selection_mode_enabled() and sm.is_confirmed():
					sm.apply_action("delete")
					get_viewport().set_input_as_handled()
			KEY_0, KEY_KP_0:
				# 0 = God Siphon solo en modo DEV (no en partida normal)
				if GameConstants.DEBUG_MODE:
					_seleccionar_god_siphon()
			KEY_1, KEY_KP_1:
				_seleccionar_edificio_por_indice(0)
			KEY_2, KEY_KP_2:
				_seleccionar_edificio_por_indice(1)
			KEY_3, KEY_KP_3:
				_seleccionar_edificio_por_indice(2)
			KEY_4, KEY_KP_4:
				_seleccionar_edificio_por_indice(3)
			KEY_5, KEY_KP_5:
				_seleccionar_edificio_por_indice(4)
			KEY_6, KEY_KP_6:
				_seleccionar_edificio_por_indice(5)
			KEY_7, KEY_KP_7:
				_seleccionar_edificio_por_indice(6)
			KEY_8, KEY_KP_8:
				_seleccionar_edificio_por_indice(7)
			KEY_9, KEY_KP_9:
				_seleccionar_edificio_por_indice(8)

func _seleccionar_god_siphon():
	var cm = find_child("ConstructionManager", true, false)
	if cm and cm.has_method("seleccionar_para_construir"):
		cm.seleccionar_para_construir(cm.god_siphon_escena, "GodSiphon")

# Orden fijo de hotkeys 1-7 (8 y 9 reservados para futuro / keybinding)
const HOTKEY_EDIFICIOS: Array[String] = [
	"Sifón", "Prisma Recto", "Prisma Angular", "Compresor", "Fusionador", "Constructor", "Void Generator"
]

func _seleccionar_edificio_por_indice(indice: int):
	if indice < 0 or indice >= HOTKEY_EDIFICIOS.size():
		return  # 8 y 9 no hacen nada por ahora
	var nombre_item = HOTKEY_EDIFICIOS[indice]
	if not GameConstants.RECETAS.has(nombre_item):
		return
	var receta = GameConstants.RECETAS[nombre_item]
	if not receta.has("output_scene") or GlobalInventory.get_amount(nombre_item) <= 0:
		return
	var cm = find_child("ConstructionManager", true, false)
	if cm and cm.has_method("seleccionar_para_construir"):
		var escena = load(receta["output_scene"])
		if escena:
			cm.seleccionar_para_construir(escena, nombre_item)

func _on_btn_guardar_pressed() -> void:
	print("[MAIN] Guardando partida...")
	if SaveSystem:
		SaveSystem.guardar_partida()
		print("[MAIN] ¡Partida guardada!")
	else:
		print("[MAIN] ERROR: SaveSystem no encontrado")

func _on_btn_menu_pressed() -> void:
	print("[MAIN] Volviendo al menú...")
	# Solo se guarda cuando el jugador pulsa GUARDAR; al salir al menú no se guarda automáticamente.
	
	# Cambiar a la escena del menú principal
	var ruta_menu = "res://scenes/ui/main_menu.tscn"
	
	if ResourceLoader.exists(ruta_menu):
		var resultado = get_tree().change_scene_to_file(ruta_menu)
		if resultado == OK:
			print("[MAIN] Cambio de escena exitoso.")
		else:
			print("[MAIN] ERROR al cambiar escena: ", resultado)
	else:
		print("[MAIN] ERROR: No existe la ruta: ", ruta_menu)
