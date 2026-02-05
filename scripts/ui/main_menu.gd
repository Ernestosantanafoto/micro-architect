extends CanvasLayer

const VERSION_TEXTO := "v0.5-alpha"
const DURACION_TRANSICION := 0.2
const SETTINGS_PATH := GameConstants.PREFERENCIAS_PATH
const SECTION_AUDIO := GameConstants.PREF_SECTION_AUDIO
const KEY_VOLUME := GameConstants.PREF_KEY_VOLUME
const KEY_MUSIC_VOLUME := GameConstants.PREF_KEY_MUSIC_VOLUME
const KEY_SFX_VOLUME := GameConstants.PREF_KEY_SFX
const SECTION_DISPLAY := GameConstants.PREF_SECTION_DISPLAY
const KEY_FULLSCREEN := GameConstants.PREF_KEY_FULLSCREEN

@export var ESCENA_JUEGO : String = "res://scenes/world/main_game_3d.tscn"
var _escena_precargada: Variant = null

# Referencias (rutas explícitas)
@onready var main_container: Control = $ColorRect/CenterContainer/MarginContainer/MainMenuContainer
@onready var options_container: Control = $ColorRect/CenterContainer/OptionsMenuContainer
@onready var volume_slider: HSlider = $ColorRect/CenterContainer/OptionsMenuContainer/VolumeSlider
@onready var sfx_slider: HSlider = $ColorRect/CenterContainer/OptionsMenuContainer/SfxSlider
@onready var fullscreen_check: CheckButton = $ColorRect/CenterContainer/OptionsMenuContainer/FullscreenCheck

func _ready():
	# Que el fondo no intercepte clics; así CenterContainer y los botones los reciben
	$ColorRect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$ColorRect/CenterContainer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Estado inicial (opciones ocultas por defecto en .tscn)
	main_container.visible = true
	options_container.visible = false
	main_container.modulate.a = 1.0
	options_container.modulate.a = 1.0
	
	# Versión bajo el título (si hay un Label primero en MainMenuContainer)
	_anadir_version_al_menu()
	
	# Crear bus SFX si no existe (para efectos futuros)
	_asegurar_bus_sfx()
	# Cargar y aplicar preferencias guardadas
	_cargar_y_aplicar_preferencias()

	# --- CONEXIONES DE BOTONES (rutas $ desde este nodo) ---
	$ColorRect/CenterContainer/MarginContainer/MainMenuContainer/ButtonNueva.pressed.connect(_on_nueva_pressed)
	$ColorRect/CenterContainer/MarginContainer/MainMenuContainer/ButtonCargar.pressed.connect(_on_cargar_pressed)
	$ColorRect/CenterContainer/MarginContainer/MainMenuContainer/ButtonOpciones.pressed.connect(_on_options_pressed)
	$ColorRect/CenterContainer/MarginContainer/MainMenuContainer/ButtonSalir.pressed.connect(_on_btn_salir_pressed)
	$ColorRect/CenterContainer/OptionsMenuContainer/ButtonBack.pressed.connect(_on_back_pressed)
	
	# Feedback hover/pressed en todos los botones
	_aplicar_feedback_botones()
	# Aviso por si se ejecuta en ventana embebida (NUEVA/CARGAR pueden fallar)
	_anadir_aviso_f5_si_embebido()

# --- LÓGICA DE NAVEGACIÓN (con transición suave) ---

func _on_options_pressed():
	if not main_container or not options_container: return
	var t = create_tween()
	t.tween_property(main_container, "modulate:a", 0.0, DURACION_TRANSICION)
	t.tween_callback(func():
		main_container.visible = false
		options_container.modulate.a = 0.0
		options_container.visible = true
	)
	t.tween_property(options_container, "modulate:a", 1.0, DURACION_TRANSICION)

func _on_back_pressed():
	if not main_container or not options_container: return
	var t = create_tween()
	t.tween_property(options_container, "modulate:a", 0.0, DURACION_TRANSICION)
	t.tween_callback(func():
		options_container.visible = false
		main_container.modulate.a = 0.0
		main_container.visible = true
	)
	t.tween_property(main_container, "modulate:a", 1.0, DURACION_TRANSICION)

func _asegurar_bus_sfx() -> void:
	var idx = -1
	for i in range(AudioServer.bus_count):
		if AudioServer.get_bus_name(i) == "SFX":
			return
	AudioServer.add_bus(AudioServer.bus_count)
	AudioServer.set_bus_name(AudioServer.bus_count - 1, "SFX")

func _cargar_y_aplicar_preferencias() -> void:
	var cfg = ConfigFile.new()
	var load_ok = cfg.load(SETTINGS_PATH) == OK
	var vol = 1.0
	var sfx_val = 1.0
	var full = false
	if load_ok:
		vol = clampf(cfg.get_value(SECTION_AUDIO, KEY_MUSIC_VOLUME, 1.0), 0.0, 1.0)
		sfx_val = clampf(cfg.get_value(SECTION_AUDIO, KEY_SFX_VOLUME, 1.0), 0.0, 1.0)
		full = cfg.get_value(SECTION_DISPLAY, KEY_FULLSCREEN, false)
	if volume_slider:
		volume_slider.value = vol
		_aplicar_volumen(vol)
		if not volume_slider.value_changed.is_connected(_on_volume_changed):
			volume_slider.value_changed.connect(_on_volume_changed)
	if sfx_slider:
		sfx_slider.value = sfx_val
		_aplicar_sfx_volume(sfx_val)
		if not sfx_slider.value_changed.is_connected(_on_sfx_changed):
			sfx_slider.value_changed.connect(_on_sfx_changed)
	if fullscreen_check:
		fullscreen_check.button_pressed = full
		_aplicar_fullscreen(full)
		if not fullscreen_check.toggled.is_connected(_on_fullscreen_toggled):
			fullscreen_check.toggled.connect(_on_fullscreen_toggled)

func _aplicar_volumen(slider_value: float) -> void:
	if MusicManager:
		MusicManager.set_volume(slider_value)

func _aplicar_sfx_volume(slider_value: float) -> void:
	var idx = AudioServer.get_bus_index("SFX")
	if idx >= 0:
		var progressive = pow(slider_value, 2)
		AudioServer.set_bus_volume_db(idx, linear_to_db(progressive))

func _aplicar_fullscreen(enabled: bool) -> void:
	if enabled:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _guardar_preferencias() -> void:
	var cfg = ConfigFile.new()
	cfg.load(SETTINGS_PATH)
	if volume_slider:
		cfg.set_value(SECTION_AUDIO, KEY_MUSIC_VOLUME, clampf(volume_slider.value, 0.0, 1.0))
	if sfx_slider:
		cfg.set_value(SECTION_AUDIO, KEY_SFX_VOLUME, clampf(sfx_slider.value, 0.0, 1.0))
	if fullscreen_check:
		cfg.set_value(SECTION_DISPLAY, KEY_FULLSCREEN, fullscreen_check.button_pressed)
	cfg.save(SETTINGS_PATH)

func _on_volume_changed(value: float) -> void:
	_aplicar_volumen(value)
	_guardar_preferencias()

func _on_sfx_changed(value: float) -> void:
	_aplicar_sfx_volume(value)
	_guardar_preferencias()

func _on_fullscreen_toggled(button_pressed: bool) -> void:
	_aplicar_fullscreen(button_pressed)
	_guardar_preferencias()
# --- LÓGICA DE PARTIDAS ---

func _on_btn_salir_pressed():
	get_tree().quit()

func _on_nueva_pressed():
	GameConstants.DEBUG_MODE = false  # Nueva partida siempre con debug OFF
	GlobalInventory.semilla_mundo = 0
	GlobalInventory.preparar_nueva_partida()
	if TechTree:
		TechTree.reset_to_initial()
	_intentar_cambio_escena()

func _on_cargar_pressed():
	_mostrar_popup_cargar()

# --- UTILIDADES ---

func _anadir_version_al_menu():
	var label_ver = Label.new()
	label_ver.name = "LabelVersion"
	label_ver.text = VERSION_TEXTO
	label_ver.add_theme_font_size_override("font_size", 24)
	label_ver.add_theme_color_override("font_color", Color(0.7, 0.7, 0.8))
	label_ver.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_ver.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_container.add_child(label_ver)
	main_container.move_child(label_ver, 1)  # Justo después del título (Label)

func _anadir_aviso_f5_si_embebido():
	var hint = Label.new()
	hint.name = "LabelHintF5"
	hint.text = "Si NUEVA/CARGAR no inician: ejecuta el proyecto con F5 (ventana separada)."
	hint.add_theme_font_size_override("font_size", 14)
	hint.add_theme_color_override("font_color", Color(0.5, 0.55, 0.65))
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.custom_minimum_size.x = 400
	main_container.add_child(hint)

func _aplicar_feedback_botones():
	for c in [main_container, options_container]:
		for child in c.get_children():
			if child is Button:
				if not child.mouse_entered.is_connected(_on_boton_hover_entered):
					child.mouse_entered.connect(_on_boton_hover_entered.bind(child))
				if not child.mouse_exited.is_connected(_on_boton_hover_exited):
					child.mouse_exited.connect(_on_boton_hover_exited.bind(child))
				if not child.pressed.is_connected(_on_boton_pressed_feedback.bind(child)):
					child.pressed.connect(_on_boton_pressed_feedback.bind(child))

func _on_boton_hover_entered(btn: Button):
	var t = btn.create_tween()
	t.tween_property(btn, "scale", Vector2(1.05, 1.05), 0.1)

func _on_boton_hover_exited(btn: Button):
	var t = btn.create_tween()
	t.tween_property(btn, "scale", Vector2.ONE, 0.1)

func _on_boton_pressed_feedback(btn: Button):
	var t = btn.create_tween()
	t.tween_property(btn, "scale", Vector2(0.98, 0.98), 0.05)
	t.tween_property(btn, "scale", Vector2.ONE, 0.08)

func _mostrar_popup_cargar() -> void:
	var slots_info = SaveSystem.get_slots_info()
	var layer = CanvasLayer.new()
	layer.layer = 100
	add_child(layer)
	var panel = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -200
	panel.offset_top = -160
	panel.offset_right = 200
	panel.offset_bottom = 160
	panel.add_theme_stylebox_override("panel", _panel_estilo_cargar())
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
			btn.pressed.connect(_hacer_cargar_slot.bind(slot, layer))
		vbox.add_child(btn)
	var btn_cancelar = Button.new()
	btn_cancelar.text = "Cancelar"
	btn_cancelar.pressed.connect(func(): layer.queue_free())
	vbox.add_child(btn_cancelar)

func _hacer_cargar_slot(slot: int, layer: CanvasLayer) -> void:
	if SaveSystem.cargar_partida(slot):
		GameConstants.DEBUG_MODE = false  # Cargar partida: empezar con debug OFF
		layer.queue_free()
		_intentar_cambio_escena()
	else:
		layer.queue_free()

func _panel_estilo_cargar() -> StyleBoxFlat:
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
	s.content_margin_left = 24.0
	s.content_margin_top = 24.0
	s.content_margin_right = 24.0
	s.content_margin_bottom = 24.0
	return s

func _mostrar_aviso_ventana_embebida() -> void:
	var layer = CanvasLayer.new()
	layer.layer = 200
	add_child(layer)
	var panel = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -220
	panel.offset_top = -80
	panel.offset_right = 220
	panel.offset_bottom = 80
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.12, 0.18, 0.98)
	style.border_color = Color(0.4, 0.5, 0.7)
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	style.set_content_margin_all(20)
	panel.add_theme_stylebox_override("panel", style)
	layer.add_child(panel)
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	panel.add_child(vbox)
	var lbl = Label.new()
	lbl.text = "No se pudo iniciar la partida en esta ventana.\n\nEjecuta el proyecto en ventana separada:\nProyecto → Ejecutar (o Run Project)."
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.custom_minimum_size.x = 360
	vbox.add_child(lbl)
	var btn = Button.new()
	btn.text = "Entendido"
	btn.pressed.connect(func(): layer.queue_free())
	vbox.add_child(btn)

func _intentar_cambio_escena():
	if not ResourceLoader.exists(ESCENA_JUEGO):
		push_error("[MainMenu] Escena no encontrada: " + ESCENA_JUEGO)
		return
	_escena_precargada = ResourceLoader.load(ESCENA_JUEGO, "PackedScene", ResourceLoader.CACHE_MODE_REUSE)
	# En ventana embebida (editor) el fullscreen puede impedir que se vea la nueva escena
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	# Siempre cambiar escena en diferido para no hacerlo dentro del callback del botón
	call_deferred("_do_cambio_escena")

func _do_cambio_escena() -> void:
	# Timer para evitar error 19 (árbol ocupado) al cambiar escena
	var t = Timer.new()
	t.one_shot = true
	t.wait_time = 0.1
	t.timeout.connect(_cambio_escena_en_timeout)
	add_child(t)
	t.start()

func _cambio_escena_en_timeout() -> void:
	var pack_or_raw = _escena_precargada
	if not pack_or_raw:
		pack_or_raw = ResourceLoader.load(ESCENA_JUEGO, "PackedScene", ResourceLoader.CACHE_MODE_REUSE)
	var new_scene: Node = null
	if pack_or_raw != null and pack_or_raw.has_method("instantiate"):
		new_scene = pack_or_raw.instantiate()
	if not new_scene:
		push_error("[MainMenu] No se pudo cargar/instanciar escena: " + ESCENA_JUEGO)
		# En ventana separada (F5) el cambio directo puede funcionar
		var err = get_tree().change_scene_to_file(ESCENA_JUEGO)
		if err == OK:
			return
		# Si falla (p. ej. error 19 en embebida): autoload lo intenta desde su Timer
		GameConstants.pedir_cambio_escena(ESCENA_JUEGO)
		var t_aviso = Timer.new()
		t_aviso.one_shot = true
		t_aviso.wait_time = 0.5
		t_aviso.timeout.connect(_mostrar_aviso_ventana_embebida)
		add_child(t_aviso)
		t_aviso.start()
		return
	# Quitar esta escena (el menú) del árbol ANTES de añadir la partida. Usamos self porque
	# current_scene puede no estar actualizado cuando se cambió escena manualmente (add_child).
	var root = get_tree().root
	var old_scene = self if self.get_parent() == root else get_tree().current_scene
	if old_scene and is_instance_valid(old_scene):
		if old_scene.get_parent() == root:
			root.remove_child(old_scene)
		old_scene.queue_free()
	root.add_child(new_scene)
