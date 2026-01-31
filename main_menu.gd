extends CanvasLayer

@export var ESCENA_JUEGO : String = "res://scenes/world/main_game_3d.tscn"

# Referencias
var main_container : Control
var options_container : Control
var volume_slider : HSlider

func _ready():
	print("[DEBUG-MENU] === INICIANDO MENÚ PRINCIPAL ===")
	
	# Localizamos los contenedores
	main_container = find_child("MainMenuContainer", true, false)
	options_container = find_child("OptionsMenuContainer", true, false)
	volume_slider = find_child("VolumeSlider", true, false)
	
	# Estado inicial
	if main_container: main_container.visible = true
	if options_container: options_container.visible = false
	
	# Configurar Audio
	if volume_slider:
		var master_bus = AudioServer.get_bus_index("Master")
		var current_vol_linear = db_to_linear(AudioServer.get_bus_volume_db(master_bus))
		volume_slider.value = AudioServer.get_bus_volume_linear(master_bus)
		if not volume_slider.value_changed.is_connected(_on_volume_changed):
			volume_slider.value_changed.connect(_on_volume_changed)

	# --- CONEXIONES DE BOTONES ---
	# Buscamos y conectamos cada botón por su nombre en el árbol de nodos
	_conectar_boton("ButtonNueva", _on_nueva_pressed)
	_conectar_boton("ButtonCargar", _on_cargar_pressed)
	_conectar_boton("ButtonOpciones", _on_options_pressed) # El que acabas de crear
	_conectar_boton("ButtonBack", _on_back_pressed)
	_conectar_boton("ButtonSalir", func(): get_tree().quit())

# --- LÓGICA DE NAVEGACIÓN ---

func _on_options_pressed():
	print("[DEBUG-MENU] Entrando a opciones...")
	if main_container and options_container:
		main_container.visible = false
		options_container.visible = true

func _on_back_pressed():
	print("[DEBUG-MENU] Volviendo al menú principal...")
	if main_container and options_container:
		main_container.visible = true
		options_container.visible = false

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
