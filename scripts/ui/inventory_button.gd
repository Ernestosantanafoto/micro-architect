extends Button

@export var item_name: String = "" 

@onready var label_count = $Label

func _ready():
	GlobalInventory.inventory_changed.connect(_on_inventory_update)
	_actualizar_texto()
	pressed.connect(_on_pressed)

func setup(nombre_del_item: String):
	item_name = nombre_del_item
	_actualizar_texto()

func _on_inventory_update(changed_item, _amount):
	if changed_item == item_name:
		_actualizar_texto()

func _actualizar_texto():
	var cantidad = GlobalInventory.get_amount(item_name)
	if label_count: label_count.text = "x" + str(cantidad)
	else: text = item_name + " x" + str(cantidad)
	
	disabled = cantidad <= 0
	modulate.a = 0.5 if disabled else 1.0

func _on_pressed():
	if not GameConstants.RECETAS.has(item_name): return
	var ruta_escena = GameConstants.RECETAS[item_name]["output_scene"]
	var manager = get_tree().current_scene.find_child("ConstructionManager", true, false)
	if manager:
		var escena = load(ruta_escena)
		if escena:
			manager.seleccionar_para_construir(escena, item_name)
		else:
			print("Error cargando escena: ", ruta_escena)
