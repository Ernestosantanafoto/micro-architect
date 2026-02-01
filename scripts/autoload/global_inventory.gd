extends Node

signal inventory_changed(item_name, new_amount)

# --- PERSISTENCIA MAESTRA ---
var semilla_mundo : int = 0
var edificios_para_reconstruir : Array = []
var estados_edificios : Dictionary = {}
var datos_camara : Dictionary = {"pos": Vector3.ZERO, "size": 100.0}

var stock = {
	# Recursos
	"Stability": 0, 
	"Charge": 0, 
	
	# Sifones
	"Sifón": 5, 
	"Sifón T2": 2,
	
	# Prismas T1
	"Prisma Recto": 20, 
	"Prisma Angular": 10,
	
	# Prismas T2
	"Prisma Recto T2": 2, 
	"Prisma Angular T2": 2,
	
	# Compresores
	"Compresor": 2, 
	"Compresor T2": 0,
	
	# Otros
	"Fusionador": 1, 
	"Constructor": 1,
	"GodSiphon": 3, 
	"Void Generator": 1
}

# --- GESTIÓN DE ESTADOS DE EDIFICIOS ---
func registrar_estado(pos: Vector3i, datos: Dictionary):
	var clave = "%d,%d,%d" % [pos.x, pos.y, pos.z]
	estados_edificios[clave] = datos

func obtener_estado(pos: Vector3i) -> Dictionary:
	var clave = "%d,%d,%d" % [pos.x, pos.y, pos.z]
	return estados_edificios.get(clave, {})

# Alias para compatibilidad con system_hud.gd
func obtener_estado_edificio(pos: Vector3i) -> Dictionary:
	return obtener_estado(pos)

func borrar_estado(pos: Vector3i):
	var clave = "%d,%d,%d" % [pos.x, pos.y, pos.z]
	estados_edificios.erase(clave)

# --- GESTIÓN DE INVENTARIO ---
func get_amount(item: String) -> int:
	return stock.get(item, 0)

func set_amount(item: String, amt: int): 
	if stock.has(item):
		stock[item] = amt
		inventory_changed.emit(item, amt)
	else:
		stock[item] = amt
		inventory_changed.emit(item, amt)

func add_item(item: String, amt: int): 
	set_amount(item, get_amount(item) + amt)

func consume_item(item: String, amt: int) -> bool:
	if get_amount(item) >= amt:
		add_item(item, -amt)
		return true
	return false

func refund_item(item: String, amt: int = 1): 
	add_item(item, amt)

# --- RESET Y STARTER PACK ---
func limpiar_inventario():
	for item in stock.keys(): 
		stock[item] = 0
	estados_edificios.clear()
	edificios_para_reconstruir.clear()
	semilla_mundo = 0
	datos_camara = {"pos": Vector3.ZERO, "size": 100.0}

func cargar_starter_pack():
	limpiar_inventario()
	# 100 edificios de cada tipo
	add_item("Sifón", 100)
	add_item("Sifón T2", 100)
	add_item("Prisma Recto", 100)
	add_item("Prisma Angular", 100)
	add_item("Prisma Recto T2", 100)
	add_item("Prisma Angular T2", 100)
	add_item("Compresor", 100)
	add_item("Compresor T2", 100)
	add_item("Fusionador", 100)
	add_item("Constructor", 100)
	add_item("GodSiphon", 100)
	add_item("Void Generator", 100)
