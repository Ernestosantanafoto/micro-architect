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
	call_deferred("_mostrar_tutorial_si_nueva_partida")

func _mostrar_tutorial_si_nueva_partida() -> void:
	if GlobalInventory.edificios_para_reconstruir.size() > 0:
		return
	if not SaveSystem or SaveSystem.get_value("tutorial_completed", false):
		return
	var tut = load("res://scenes/ui/tutorial_system.tscn").instantiate()
	add_child(tut)

func _conectar_botones():
	# Conectar botón GUARDAR del menú desplegable (MENU → GUARDAR). El de la barra inferior es BtnSoltar (SOLTAR).
	var btns_save = _find_all_children_by_name(self, "BtnGuardar")
	for btn_save in btns_save:
		if btn_save is BaseButton and not btn_save.pressed.is_connected(_on_btn_guardar_pressed):
			btn_save.pressed.connect(_on_btn_guardar_pressed)
			if GameConstants.DEBUG_MODE:
				print("[MAIN] Botón GUARDAR conectado: ", btn_save.get_path())
	
	# Salir al menú principal: solo BtnSalir (dentro del dropdown MENU)
	var btn_salir = _buscar_boton("BtnSalir")
	if btn_salir and not btn_salir.pressed.is_connected(_on_btn_menu_pressed):
		btn_salir.pressed.connect(_on_btn_menu_pressed)
		if GameConstants.DEBUG_MODE:
			print("[MAIN] Botón SALIR conectado.")
	
	# Cargar partida (entre SALIR y SELECCIÓN)
	var btn_cargar = _buscar_boton("BtnCargar")
	if btn_cargar and not btn_cargar.pressed.is_connected(_on_btn_cargar_pressed):
		btn_cargar.pressed.connect(_on_btn_cargar_pressed)
		if GameConstants.DEBUG_MODE:
			print("[MAIN] Botón CARGAR conectado.")
	
	# Opciones (volumen, SFX, pantalla completa) — popup mismo estilo que Guardar/Cargar
	var btn_opciones = _buscar_boton("BtnOpciones")
	if btn_opciones and not btn_opciones.pressed.is_connected(_on_btn_opciones_pressed):
		btn_opciones.pressed.connect(_on_btn_opciones_pressed)
		if GameConstants.DEBUG_MODE:
			print("[MAIN] Botón OPCIONES conectado.")
	
	# Modo selección (Button toggle_mode): mismo aspecto que GUARDAR/MENÚ
	var btn_modo_sel = find_child("BtnModoSeleccion", true, false)
	if btn_modo_sel and btn_modo_sel is BaseButton and btn_modo_sel.has_signal("toggled"):
		if not btn_modo_sel.toggled.is_connected(_on_btn_modo_seleccion_toggled):
			btn_modo_sel.toggled.connect(_on_btn_modo_seleccion_toggled)
		var sm = find_child("SelectionManager", true, false)
		if sm and sm.has_method("set_selection_mode_enabled"):
			sm.selection_mode_enabled = btn_modo_sel.button_pressed
		if GameConstants.DEBUG_MODE:
			print("[MAIN] Botón SELECCIÓN conectado.")
	

func _on_btn_modo_seleccion_toggled(button_pressed: bool) -> void:
	var sm = find_child("SelectionManager", true, false)
	if sm and sm.has_method("set_selection_mode_enabled"):
		sm.set_selection_mode_enabled(button_pressed)

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

func _input(event):
	# Clic central: máxima prioridad para clonar / poner en mano (no lo consume la UI)
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_MIDDLE:
		var cm = find_child("ConstructionManager", true, false)
		if cm and cm.has_method("ejecutar_accion_clic_central"):
			if cm.ejecutar_accion_clic_central():
				get_viewport().set_input_as_handled()

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
	if SaveSystem:
		_mostrar_popup_guardar()
	else:
		push_error("[MAIN] SaveSystem no encontrado")

func _cerrar_popups_overlay() -> void:
	for n in get_tree().get_nodes_in_group(GameConstants.POPUP_OVERLAY_GROUP):
		if is_instance_valid(n):
			n.queue_free()

func _on_popup_backdrop_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_cerrar_popups_overlay()
		get_viewport().set_input_as_handled()

func _mostrar_popup_guardar() -> void:
	_cerrar_popups_overlay()
	var layer = CanvasLayer.new()
	layer.layer = 100
	layer.add_to_group(GameConstants.POPUP_OVERLAY_GROUP)
	add_child(layer)
	# Fondo transparente: clic fuera cierra el popup
	var backdrop = ColorRect.new()
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color(0, 0, 0, 0.01)
	backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	backdrop.gui_input.connect(_on_popup_backdrop_input)
	layer.add_child(backdrop)
	var panel = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = GameConstants.POPUP_OFFSET_LEFT
	panel.offset_top = GameConstants.POPUP_OFFSET_TOP
	panel.offset_right = GameConstants.POPUP_OFFSET_RIGHT
	panel.offset_bottom = GameConstants.POPUP_OFFSET_BOTTOM
	panel.add_theme_stylebox_override("panel", _panel_estilo_guardar())
	layer.add_child(panel)
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	panel.add_child(vbox)
	var lbl = Label.new()
	lbl.text = "Guardar partida"
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(lbl)
	var slots_info = SaveSystem.get_slots_info()
	var slot_buttons: Array[Button] = []
	for i in range(3):
		var info = slots_info[i]
		var btn = Button.new()
		btn.toggle_mode = true
		var nm = info.get("name", "")
		btn.text = "Slot %d: %s" % [info["slot"], nm if nm else "(vacío)"]
		btn.custom_minimum_size.y = 36
		btn.pressed.connect(_on_popup_slot_seleccionado.bind(info["slot"], slot_buttons, btn))
		slot_buttons.append(btn)
		vbox.add_child(btn)
	var nombre_edit = LineEdit.new()
	nombre_edit.placeholder_text = "Nombre (opcional)"
	nombre_edit.custom_minimum_size.y = 32
	vbox.add_child(nombre_edit)
	var spacer = Control.new()
	spacer.custom_minimum_size.y = 12
	vbox.add_child(spacer)
	var center_btns = CenterContainer.new()
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	var btn_guardar = Button.new()
	btn_guardar.text = "Guardar"
	btn_guardar.pressed.connect(func():
		var slot = _popup_slot_guardar
		var nombre = nombre_edit.text.strip_edges()
		SaveSystem.guardar_partida(slot, nombre)
		_cerrar_popups_overlay()
		if GameConstants.DEBUG_MODE:
			print("[MAIN] ¡Partida guardada en slot ", slot, "!")
	)
	var btn_cancelar = Button.new()
	btn_cancelar.text = "Cancelar"
	btn_cancelar.pressed.connect(_cerrar_popups_overlay)
	hbox.add_child(btn_guardar)
	hbox.add_child(btn_cancelar)
	center_btns.add_child(hbox)
	vbox.add_child(center_btns)
	_popup_slot_guardar = 1
	slot_buttons[0].emit_signal("pressed")

func _on_popup_slot_seleccionado(slot: int, todos: Array, btn_actual: Button) -> void:
	_popup_slot_guardar = slot
	for b in todos:
		b.button_pressed = (b == btn_actual)

var _popup_slot_guardar := 1

func _panel_estilo_guardar() -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	s.bg_color = Color(0.08, 0.1, 0.14, 0.98)
	s.border_width_left = 2
	s.border_width_top = 2
	s.border_width_right = 2
	s.border_width_bottom = 2
	s.border_color = Color(0.25, 0.4, 0.55, 0.8)
	s.corner_radius_top_left = 8
	s.corner_radius_top_right = 8
	s.corner_radius_bottom_left = 8
	s.corner_radius_bottom_right = 8
	s.content_margin_left = 20.0
	s.content_margin_top = 20.0
	s.content_margin_right = 20.0
	s.content_margin_bottom = 20.0
	return s

func _on_btn_cargar_pressed() -> void:
	if not SaveSystem:
		push_error("[MAIN] SaveSystem no encontrado")
		return
	_mostrar_popup_cargar_ingame()

func _on_btn_opciones_pressed() -> void:
	_mostrar_popup_opciones()

func _asegurar_bus_sfx() -> void:
	for i in range(AudioServer.bus_count):
		if AudioServer.get_bus_name(i) == "SFX":
			return
	AudioServer.add_bus(AudioServer.bus_count)
	AudioServer.set_bus_name(AudioServer.bus_count - 1, "SFX")

func _mostrar_popup_opciones() -> void:
	_cerrar_popups_overlay()
	_asegurar_bus_sfx()
	var cfg = ConfigFile.new()
	var load_ok = cfg.load(GameConstants.PREFERENCIAS_PATH) == OK
	var vol = clampf(cfg.get_value(GameConstants.PREF_SECTION_AUDIO, GameConstants.PREF_KEY_MUSIC_VOLUME, 1.0), 0.0, 1.0) if load_ok else 1.0
	var sfx_val = clampf(cfg.get_value(GameConstants.PREF_SECTION_AUDIO, GameConstants.PREF_KEY_SFX, 1.0), 0.0, 1.0) if load_ok else 1.0
	var full = cfg.get_value(GameConstants.PREF_SECTION_DISPLAY, GameConstants.PREF_KEY_FULLSCREEN, false) if load_ok else false
	var mute = cfg.get_value(GameConstants.PREF_SECTION_AUDIO, GameConstants.PREF_KEY_MUTE, false) if load_ok else false

	var layer = CanvasLayer.new()
	layer.layer = 100
	layer.add_to_group(GameConstants.POPUP_OVERLAY_GROUP)
	add_child(layer)
	var backdrop = ColorRect.new()
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color(0, 0, 0, 0.01)
	backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	backdrop.gui_input.connect(_on_popup_backdrop_input)
	layer.add_child(backdrop)
	var panel = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = GameConstants.POPUP_OFFSET_LEFT
	panel.offset_top = GameConstants.POPUP_OFFSET_TOP
	panel.offset_right = GameConstants.POPUP_OFFSET_RIGHT
	panel.offset_bottom = GameConstants.POPUP_OFFSET_BOTTOM
	panel.add_theme_stylebox_override("panel", _panel_estilo_guardar())
	layer.add_child(panel)
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	panel.add_child(vbox)
	var lbl_titulo = Label.new()
	lbl_titulo.text = "Opciones"
	lbl_titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(lbl_titulo)

	var lbl_vol = Label.new()
	lbl_vol.text = "Música"
	vbox.add_child(lbl_vol)
	var slider_vol = HSlider.new()
	slider_vol.min_value = 0.0
	slider_vol.max_value = 1.0
	slider_vol.step = 0.05
	slider_vol.value = vol
	slider_vol.custom_minimum_size.y = 24
	vbox.add_child(slider_vol)
	var check_mute = CheckButton.new()
	check_mute.text = "Silenciar música"
	check_mute.button_pressed = mute
	vbox.add_child(check_mute)
	var lbl_sfx = Label.new()
	lbl_sfx.text = "Efectos"
	vbox.add_child(lbl_sfx)
	var slider_sfx = HSlider.new()
	slider_sfx.min_value = 0.0
	slider_sfx.max_value = 1.0
	slider_sfx.step = 0.05
	slider_sfx.value = sfx_val
	slider_sfx.custom_minimum_size.y = 24
	vbox.add_child(slider_sfx)
	var check_full = CheckButton.new()
	check_full.text = "Pantalla completa"
	check_full.button_pressed = full
	vbox.add_child(check_full)

	# Aplicar valores iniciales (música vía MusicManager, efectos vía bus SFX)
	if MusicManager:
		MusicManager.set_volume(vol)
		MusicManager.set_muted(mute)
	_aplicar_sfx_ingame(sfx_val)
	_aplicar_fullscreen_ingame(full)

	slider_vol.value_changed.connect(func(v: float):
		if MusicManager:
			MusicManager.set_volume(v)
		_guardar_preferencias_ingame(slider_vol.value, slider_sfx.value, check_full.button_pressed, check_mute.button_pressed)
	)
	check_mute.toggled.connect(func(p: bool):
		if MusicManager:
			MusicManager.set_muted(p)
		_guardar_preferencias_ingame(slider_vol.value, slider_sfx.value, check_full.button_pressed, p)
	)
	slider_sfx.value_changed.connect(func(v: float):
		_aplicar_sfx_ingame(v)
		_guardar_preferencias_ingame(slider_vol.value, slider_sfx.value, check_full.button_pressed, check_mute.button_pressed)
	)
	check_full.toggled.connect(func(p: bool):
		_aplicar_fullscreen_ingame(p)
		_guardar_preferencias_ingame(slider_vol.value, slider_sfx.value, p, check_mute.button_pressed)
	)

	var btn_cerrar = Button.new()
	btn_cerrar.text = "Cerrar"
	btn_cerrar.pressed.connect(_cerrar_popups_overlay)
	vbox.add_child(btn_cerrar)

func _aplicar_sfx_ingame(val: float) -> void:
	var idx = AudioServer.get_bus_index("SFX")
	if idx >= 0:
		AudioServer.set_bus_volume_db(idx, linear_to_db(pow(clampf(val, 0.0, 1.0), 2)))

func _aplicar_fullscreen_ingame(enabled: bool) -> void:
	if enabled:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _guardar_preferencias_ingame(vol: float, sfx: float, full: bool, mute: bool = false) -> void:
	var cfg = ConfigFile.new()
	var _err = cfg.load(GameConstants.PREFERENCIAS_PATH)
	cfg.set_value(GameConstants.PREF_SECTION_AUDIO, GameConstants.PREF_KEY_MUSIC_VOLUME, clampf(vol, 0.0, 1.0))
	cfg.set_value(GameConstants.PREF_SECTION_AUDIO, GameConstants.PREF_KEY_SFX, clampf(sfx, 0.0, 1.0))
	cfg.set_value(GameConstants.PREF_SECTION_AUDIO, GameConstants.PREF_KEY_MUTE, mute)
	cfg.set_value(GameConstants.PREF_SECTION_DISPLAY, GameConstants.PREF_KEY_FULLSCREEN, full)
	cfg.save(GameConstants.PREFERENCIAS_PATH)

func _mostrar_popup_cargar_ingame() -> void:
	var slots_info = SaveSystem.get_slots_info()
	var has_any = false
	for s in slots_info:
		if not (s.get("name", "") as String).is_empty():
			has_any = true
			break
	if not has_any:
		if GameConstants.DEBUG_MODE:
			print("[MAIN] No hay partida guardada para cargar.")
		return
	_cerrar_popups_overlay()
	var layer = CanvasLayer.new()
	layer.layer = 100
	layer.add_to_group(GameConstants.POPUP_OVERLAY_GROUP)
	add_child(layer)
	# Fondo transparente: clic fuera cierra el popup
	var backdrop = ColorRect.new()
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color(0, 0, 0, 0.01)
	backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	backdrop.gui_input.connect(_on_popup_backdrop_input)
	layer.add_child(backdrop)
	var panel = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = GameConstants.POPUP_OFFSET_LEFT
	panel.offset_top = GameConstants.POPUP_OFFSET_TOP
	panel.offset_right = GameConstants.POPUP_OFFSET_RIGHT
	panel.offset_bottom = GameConstants.POPUP_OFFSET_BOTTOM
	panel.add_theme_stylebox_override("panel", _panel_estilo_guardar())
	layer.add_child(panel)
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	panel.add_child(vbox)
	var lbl = Label.new()
	lbl.text = "Cargar partida"
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(lbl)
	for info in slots_info:
		var nm = info.get("name", "")
		var tiene_datos = not (nm as String).is_empty()
		var btn = Button.new()
		if tiene_datos:
			var ts = info.get("timestamp", 0)
			var fecha = ""
			if ts > 0:
				var dt_str = Time.get_datetime_string_from_unix_time(ts)
				fecha = " (%s)" % dt_str.substr(0, 16) if dt_str.length() >= 16 else ""
			btn.text = "Slot %d: %s%s" % [info["slot"], nm, fecha]
		else:
			btn.text = "Slot %d: (vacío)" % info["slot"]
			btn.disabled = true
		btn.custom_minimum_size.y = 40
		var slot = info["slot"]
		if tiene_datos:
			btn.pressed.connect(func():
				_cerrar_popups_overlay()
				_aplicar_carga_ingame(slot)
			)
		vbox.add_child(btn)
	var btn_cancelar = Button.new()
	btn_cancelar.text = "Cancelar"
	btn_cancelar.pressed.connect(_cerrar_popups_overlay)
	vbox.add_child(btn_cancelar)

func _aplicar_carga_ingame(slot: int) -> void:
	if not SaveSystem or not SaveSystem.cargar_partida(slot):
		var msg: String = SaveSystem.last_load_error if SaveSystem else ""
		if msg.is_empty():
			msg = "No se pudo cargar la partida."
		_mostrar_popup_error_carga_ingame(msg)
		return
	# Quitar edificios actuales del mundo
	if BuildingManager:
		for b in BuildingManager.active_buildings.duplicate():
			if is_instance_valid(b):
				if GridManager:
					GridManager.unregister_building_all(b)
				b.queue_free()
		BuildingManager.limpiar()
	if GridManager:
		GridManager.limpiar()
	# Restaurar mapa guardado (terreno) o generar rango si partida antigua sin mapa
	var wg = find_child("WorldGenerator", true, false)
	if wg and GlobalInventory.mapa_guardado.size() > 0 and wg.has_method("restaurar_mapa_desde_inventario"):
		wg.restaurar_mapa_desde_inventario()
	elif wg and wg.has_method("forzar_generar_rango") and GlobalInventory.edificios_para_reconstruir.size() > 0:
		wg.forzar_generar_rango(-6, 6, -6, 6)
	if GlobalInventory.edificios_para_reconstruir.size() > 0:
		await SaveSystem.reconstruir_edificios()
	# Restaurar cámara
	var cam_pivot = find_child("CameraPivot", true, false)
	if cam_pivot and GlobalInventory.datos_camara["pos"] != Vector3.ZERO:
		cam_pivot.global_position = GlobalInventory.datos_camara["pos"]
		var cam_node = cam_pivot.find_child("Camera3D", true, false)
		if cam_node and cam_node.get("size") != null:
			cam_node.size = GlobalInventory.datos_camara.get("size", 100.0)
	# Cerrar dropdown MENU si está abierto
	var menu_drop = get_node_or_null("CanvasLayer/MenuDropdownPanel")
	if menu_drop and menu_drop.visible:
		menu_drop.visible = false
	if GameConstants.DEBUG_MODE:
		print("[MAIN] Partida cargada en slot ", slot)

func _mostrar_popup_error_carga_ingame(mensaje: String) -> void:
	var layer = CanvasLayer.new()
	layer.layer = 100
	layer.add_to_group(GameConstants.POPUP_OVERLAY_GROUP)
	add_child(layer)
	var backdrop = ColorRect.new()
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color(0, 0, 0, 0.01)
	backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	backdrop.gui_input.connect(_on_popup_backdrop_input)
	layer.add_child(backdrop)
	var panel = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = GameConstants.POPUP_OFFSET_LEFT
	panel.offset_top = GameConstants.POPUP_OFFSET_TOP
	panel.offset_right = GameConstants.POPUP_OFFSET_RIGHT
	panel.offset_bottom = GameConstants.POPUP_OFFSET_BOTTOM
	panel.add_theme_stylebox_override("panel", _panel_estilo_guardar())
	layer.add_child(panel)
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	panel.add_child(vbox)
	var lbl = Label.new()
	lbl.text = mensaje
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(lbl)
	var btn = Button.new()
	btn.text = "Cerrar"
	btn.pressed.connect(_cerrar_popups_overlay)
	vbox.add_child(btn)

## Llamado desde system_hud cuando el jugador pulsa DEBUG por primera vez en esta partida.
## on_confirmar: activar DEBUG y marcar aviso visto; on_cancelar: no hacer nada.
func mostrar_popup_aviso_debug(on_confirmar: Callable, on_cancelar: Callable) -> void:
	_cerrar_popups_overlay()
	var layer = CanvasLayer.new()
	layer.layer = 100
	layer.add_to_group(GameConstants.POPUP_OVERLAY_GROUP)
	add_child(layer)
	var backdrop = ColorRect.new()
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color(0, 0, 0, 0.01)
	backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	backdrop.gui_input.connect(_on_popup_backdrop_input)
	layer.add_child(backdrop)
	var panel = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = GameConstants.POPUP_OFFSET_LEFT
	panel.offset_top = GameConstants.POPUP_OFFSET_TOP
	panel.offset_right = GameConstants.POPUP_OFFSET_RIGHT
	panel.offset_bottom = GameConstants.POPUP_OFFSET_BOTTOM
	panel.add_theme_stylebox_override("panel", _panel_estilo_guardar())
	layer.add_child(panel)
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	panel.add_child(vbox)
	var lbl = Label.new()
	lbl.text = "El modo DEBUG es una herramienta actual para el desarrollo del juego.\nAl activarlo se desactivará toda la progresión de desbloqueos de esta partida.\n¿Seguro que quieres continuar?"
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.custom_minimum_size.x = 320
	vbox.add_child(lbl)
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	var center = CenterContainer.new()
	center.add_child(hbox)
	vbox.add_child(center)
	var btn_confirmar = Button.new()
	btn_confirmar.text = "Confirmar"
	btn_confirmar.pressed.connect(func():
		on_confirmar.call()
		_cerrar_popups_overlay()
	)
	hbox.add_child(btn_confirmar)
	var btn_cancelar = Button.new()
	btn_cancelar.text = "Cancelar"
	btn_cancelar.pressed.connect(func():
		on_cancelar.call()
		_cerrar_popups_overlay()
	)
	hbox.add_child(btn_cancelar)

func _on_btn_menu_pressed() -> void:
	if GameConstants.DEBUG_MODE:
		print("[MAIN] Volviendo al menú...")
	# Solo se guarda cuando el jugador pulsa GUARDAR; al salir al menú no se guarda automáticamente.
	# Cambio manual: quitar esta escena del árbol, liberarla y añadir el menú (evita acumular escenas y que se vea más brillante).
	var ruta_menu = "res://scenes/ui/main_menu.tscn"
	if not ResourceLoader.exists(ruta_menu):
		push_error("[MAIN] No existe la ruta: " + ruta_menu)
		return
	var pack = load(ruta_menu) as PackedScene
	var menu = pack.instantiate() if pack else null
	if not menu:
		var resultado = get_tree().change_scene_to_file(ruta_menu)
		if resultado == OK and GameConstants.DEBUG_MODE:
			print("[MAIN] Cambio de escena exitoso (fallback).")
		return
	var root = get_tree().root
	var escena_juego = self
	if escena_juego.get_parent() == root:
		root.remove_child(escena_juego)
	escena_juego.queue_free()
	root.add_child(menu)
	if GameConstants.DEBUG_MODE:
		print("[MAIN] Cambio de escena exitoso.")
