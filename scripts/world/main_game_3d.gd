extends Node

signal game_tick(tick_count)

var current_tick = 0
var tiempo_acumulado = 0.0
var TIEMPO_ENTRE_TICS = GameConstants.GAME_TICK_DURATION 

func _ready():
	# Buscar y conectar botones automáticamente
	_conectar_botones()

func _conectar_botones():
	# Buscamos el botón de guardado de partida REAL (el de arriba)
	# Solo conectamos si el padre NO es la barra inferior (BottomBar)
	var btn_save = find_child("BtnGuardar", true, false)
	if btn_save:
		# Si el botón está en el HUD inferior, lo ignoramos aquí
		if "BottomBar" in btn_save.get_path().get_concatenated_names():
			print("[MAIN] Ignorando botón de HUD inferior en conexión global.")
		else:
			if not btn_save.pressed.is_connected(_on_btn_guardar_pressed):
				btn_save.pressed.connect(_on_btn_guardar_pressed)
				print("[MAIN] Botón GUARDAR PARTIDA (Top) conectado.")
	
	# Buscar botón de menú (puede llamarse BtnMenu, ButtonMenu, etc.)
	var nombres_menu = ["BtnMenu", "ButtonMenu", "Menu", "MenuButton", "BtnSalir"]
	for nombre in nombres_menu:
		var btn = _buscar_boton(nombre)
		if btn:
			if not btn.pressed.is_connected(_on_btn_menu_pressed):
				btn.pressed.connect(_on_btn_menu_pressed)
			print("[MAIN] Botón MENÚ conectado: ", nombre)
			break

func _buscar_boton(nombre: String) -> Button:
	# Buscar en toda la escena
	var btn = find_child(nombre, true, false)
	if btn and btn is Button:
		return btn
	return null

func _process(delta):
	tiempo_acumulado += delta
	if tiempo_acumulado >= TIEMPO_ENTRE_TICS:
		tiempo_acumulado -= TIEMPO_ENTRE_TICS
		current_tick += 1
		game_tick.emit(current_tick)

func _unhandled_input(event):
	# Atajos de teclado
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_F5:
				# F5 = Guardar rápido
				_on_btn_guardar_pressed()
			KEY_ESCAPE:
				# ESC = Volver al menú
				_on_btn_menu_pressed()
			KEY_0, KEY_KP_0:
				# 0 = Seleccionar God Siphon
				_seleccionar_god_siphon()

func _seleccionar_god_siphon():
	var cm = find_child("ConstructionManager", true, false)
	if cm and cm.has_method("seleccionar_para_construir"):
		cm.seleccionar_para_construir(cm.god_siphon_escena, "GodSiphon")

func _on_btn_guardar_pressed() -> void:
	print("[MAIN] Guardando partida...")
	if SaveSystem:
		SaveSystem.guardar_partida()
		print("[MAIN] ¡Partida guardada!")
	else:
		print("[MAIN] ERROR: SaveSystem no encontrado")

func _on_btn_menu_pressed() -> void:
	print("[MAIN] Volviendo al menú...")
	
	# Guardar antes de salir
	if SaveSystem:
		SaveSystem.guardar_partida()
		print("[MAIN] Partida guardada antes de salir.")
	
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
