extends CanvasLayer

const VERSION_TEXTO := "v0.4-alpha"
const DURACION_TRANSICION := 0.2

@export var ESCENA_JUEGO : String = "res://scenes/world/main_game_3d.tscn"

# Referencias (rutas explícitas)
@onready var main_container: Control = $ColorRect/CenterContainer/MainMenuContainer
@onready var options_container: Control = $ColorRect/CenterContainer/OptionsMenuContainer
@onready var volume_slider: HSlider = $ColorRect/CenterContainer/OptionsMenuContainer/VolumeSlider

func _ready():
	# Estado inicial (opciones ocultas por defecto en .tscn)
	main_container.visible = true
	options_container.visible = false
	main_container.modulate.a = 1.0
	options_container.modulate.a = 1.0
	
	# Versión bajo el título (si hay un Label primero en MainMenuContainer)
	_anadir_version_al_menu()
	
	# Configurar Audio
	if volume_slider:
		var master_bus = AudioServer.get_bus_index("Master")
		var current_vol_linear = db_to_linear(AudioServer.get_bus_volume_db(master_bus))
		volume_slider.value = AudioServer.get_bus_volume_linear(master_bus)
		if not volume_slider.value_changed.is_connected(_on_volume_changed):
			volume_slider.value_changed.connect(_on_volume_changed)

	# --- CONEXIONES DE BOTONES ---
	_conectar_boton("ButtonNueva", _on_nueva_pressed)
	_conectar_boton("ButtonCargar", _on_cargar_pressed)
	_conectar_boton("ButtonOpciones", _on_options_pressed)
	_conectar_boton("ButtonBack", _on_back_pressed)
	_conectar_boton("ButtonSalir", func(): get_tree().quit())
	
	# Feedback hover/pressed en todos los botones
	_aplicar_feedback_botones()

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

func _on_volume_changed(value: float):
	var master_bus = AudioServer.get_bus_index("Master")
	
	# Usamos una curva de potencia (valor al cuadrado) 
	# Esto hace que el inicio del slider sea mucho más sutil.
	var progressive_volume = pow(value, 2) 
	
	# Pasamos de valor lineal (0 a 1) a decibelios
	AudioServer.set_bus_volume_db(master_bus, linear_to_db(progressive_volume))
	
	print("[DEBUG-MENU] Valor Slider: ", value, " | Vol Real: ", int(progressive_volume * 100), "%")
# --- LÓGICA DE PARTIDAS ---

func _on_nueva_pressed():
	GlobalInventory.limpiar_inventario()
	GlobalInventory.semilla_mundo = 0
	GlobalInventory.cargar_starter_pack()
	_intentar_cambio_escena()

func _on_cargar_pressed():
	if SaveSystem.cargar_partida():
		_intentar_cambio_escena()
	else:
		print("[DEBUG-MENU] No hay partida guardada para cargar.")

# --- UTILIDADES ---

func _anadir_version_al_menu():
	var label_ver = Label.new()
	label_ver.name = "LabelVersion"
	label_ver.text = VERSION_TEXTO
	label_ver.add_theme_font_size_override("font_size", 24)
	label_ver.add_theme_color_override("font_color", Color(0.7, 0.7, 0.8))
	main_container.add_child(label_ver)
	main_container.move_child(label_ver, 1)  # Justo después del título (Label)

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

func _conectar_boton(nombre: String, metodo: Callable):
	var btn = find_child(nombre, true, false)
	if btn:
		if not btn.pressed.is_connected(metodo):
			btn.pressed.connect(metodo)
	else:
		print("[ADVERTENCIA] No se encontró el botón: ", nombre)

func _intentar_cambio_escena():
	if ResourceLoader.exists(ESCENA_JUEGO):
		get_tree().change_scene_to_file(ESCENA_JUEGO)
	else:
		print("[ERROR CRÍTICO] Escena no encontrada en: ", ESCENA_JUEGO)
