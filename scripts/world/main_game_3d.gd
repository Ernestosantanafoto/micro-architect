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
		var cm = find_child("ConstructionManager", true, false)
		
		match event.keycode:
			KEY_F5:
				# F5 = Guardar rápido
				_on_btn_guardar_pressed()
			KEY_ESCAPE:
				# ESC = Cancelar construcción o volver al menú
				if cm and cm.fantasma:
					cm.cancelar_construccion_y_guardar()
				else:
					_on_btn_menu_pressed()
			KEY_R:
				# R = Rotar edificio fantasma
				if cm and cm.fantasma:
					cm.fantasma.rotate_y(deg_to_rad(90))
			KEY_0, KEY_KP_0:
				# 0 = Seleccionar God Siphon
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

func _seleccionar_edificio_por_indice(indice: int):
	# Obtener lista de edificios disponibles desde GameConstants.RECETAS
	var edificios_disponibles = []
	
	for nombre_item in GameConstants.RECETAS:
		var receta = GameConstants.RECETAS[nombre_item]
		if receta.has("escena") and GlobalInventory.get_amount(nombre_item) > 0:
			edificios_disponibles.append({"nombre": nombre_item, "escena": receta["escena"]})
	
	# Verificar si el índice es válido
	if indice >= edificios_disponibles.size():
		print("[MAIN] Hotkey ", indice + 1, ": No hay edificio disponible")
		return
	
	# Seleccionar el edificio
	var edificio = edificios_disponibles[indice]
	var cm = find_child("ConstructionManager", true, false)
	if cm and cm.has_method("seleccionar_para_construir"):
		var escena = load(edificio["escena"])
		if escena:
			cm.seleccionar_para_construir(escena, edificio["nombre"])
			print("[MAIN] Hotkey ", indice + 1, ": Seleccionado ", edificio["nombre"])

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
