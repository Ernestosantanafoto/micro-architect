extends CanvasLayer

@onready var manager = get_tree().current_scene.find_child("ConstructionManager", true, false)

# --- 1. REFERENCIAS A LOS CONTENEDORES (GRIDS) ---
@onready var menu_sifones = $Panel/HBox/GrupoSifones/ItemsGrid
@onready var menu_prismas = $Panel/HBox/GrupoPrismas/ItemsGrid
@onready var menu_manipuladores = $Panel/HBox/GrupoManipuladores/ItemsGrid
@onready var menu_constructores = $Panel/HBox/GrupoConstructores/ItemsGrid

# --- 2. REFERENCIAS A LOS BOTONES DE CATEGORÍA ---
@onready var btn_sifones = $Panel/HBox/GrupoSifones/BtnCategoriaSifones
@onready var btn_prismas = $Panel/HBox/GrupoPrismas/BtnCategoriaPrismas
@onready var btn_manipuladores = $Panel/HBox/GrupoManipuladores/BtnCategoriaManipuladores
@onready var btn_constructores = $Panel/HBox/GrupoConstructores/BtnCategoriaConstructores

# --- BOTONES DE ACCIÓN ---
@onready var btn_guardar = $Panel/HBox/BtnGuardar
@onready var btn_basura = $Panel/HBox/BtnBasura

# --- PRELOAD DEL BOTÓN ---
var button_scene = preload("res://scenes/ui/inventory_button.tscn")

func _ready():
	add_to_group("VentanasUI")
	
	# A. CONFIGURAR MODO "POP-UP"
	_hacer_flotante(menu_sifones)
	_hacer_flotante(menu_prismas)
	_hacer_flotante(menu_manipuladores)
	_hacer_flotante(menu_constructores)
	
	# B. CONEXIONES
	btn_sifones.pressed.connect(_on_categoria_pressed.bind(menu_sifones, btn_sifones))
	btn_prismas.pressed.connect(_on_categoria_pressed.bind(menu_prismas, btn_prismas))
	btn_manipuladores.pressed.connect(_on_categoria_pressed.bind(menu_manipuladores, btn_manipuladores))
	btn_constructores.pressed.connect(_on_categoria_pressed.bind(menu_constructores, btn_constructores))
	
	btn_guardar.pressed.connect(_on_btn_guardar_pressed)
	btn_basura.pressed.connect(_on_btn_basura_pressed)
	
	# C. LLENAR LOS MENÚS AUTOMÁTICAMENTE (¡NUEVO!)
	_poblar_menus()
	
	_cerrar_todos()

# --- LÓGICA DE POBLADO AUTOMÁTICO ---
func _poblar_menus():
	# 1. Limpiar cualquier botón de ejemplo que hubiera en el editor
	_limpiar_grid(menu_sifones)
	_limpiar_grid(menu_prismas)
	_limpiar_grid(menu_manipuladores)
	_limpiar_grid(menu_constructores)
	
	# 2. Recorrer todas las recetas y clasificar
	for nombre_receta in GameConstants.RECETAS:
		var btn = button_scene.instantiate()
		var grid_destino = null
		
		# Clasificación por nombre
		if "Sifón" in nombre_receta:
			grid_destino = menu_sifones
		elif "Prisma" in nombre_receta:
			grid_destino = menu_prismas
		# AÑADIMOS "Void Generator" AQUÍ:
		elif "Compresor" in nombre_receta or "Fusionador" in nombre_receta or "Void Generator" in nombre_receta:
			grid_destino = menu_manipuladores
		elif "Constructor" in nombre_receta:
			grid_destino = menu_constructores
		
		# Si encontramos categoría, añadimos y configuramos
		if grid_destino:
			grid_destino.add_child(btn)
			btn.setup(nombre_receta)

func _limpiar_grid(grid):
	for child in grid.get_children():
		child.queue_free()

# --- LÓGICA CORE VISUAL ---

func _hacer_flotante(menu):
	menu.visible = false
	menu.set_as_top_level(true)
	menu.z_index = 10

func _on_categoria_pressed(menu_objetivo, boton_activador):
	var estaba_abierto = menu_objetivo.visible
	_cerrar_todos()
	if not estaba_abierto:
		_abrir_menu_encima(menu_objetivo, boton_activador)

func _abrir_menu_encima(menu, boton):
	menu.visible = true
	menu.reset_size() 
	
	var pos_final = boton.global_position
	pos_final.y -= (menu.size.y + 15) 
	
	# Centrado horizontal respecto al botón
	pos_final.x += (boton.size.x / 2) - (menu.size.x / 2)
	
	menu.global_position = pos_final
	
	menu.modulate.a = 0
	menu.position.y += 20
	var t = create_tween()
	t.set_parallel(true)
	t.tween_property(menu, "modulate:a", 1.0, 0.15)
	t.tween_property(menu, "position:y", pos_final.y, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _cerrar_todos():
	menu_sifones.visible = false
	menu_prismas.visible = false
	menu_manipuladores.visible = false
	menu_constructores.visible = false

# --- ACCIONES ---

func _on_btn_guardar_pressed():
	if manager: manager.cancelar_construccion_y_guardar()

func _on_btn_basura_pressed():
	if manager: manager.destruir_item_en_mano()
