extends Node

signal inventory_changed(item_name, new_amount)

# --- PERSISTENCIA MAESTRA ---
var semilla_mundo : int = 0
var edificios_para_reconstruir : Array = []
var estados_edificios : Dictionary = {}
var datos_camara : Dictionary = {"pos": Vector3.ZERO, "size": 100.0}

# Valores por defecto = STARTER_PACK. God Siphon = 0 (solo DEV). Constructor = 1 para poder craftear.
var stock = {
	"Stability": 0,
	"Charge": 0,
	"Sifón": 4,
	"Sifón T2": 0,
	"Prisma Recto": 8,
	"Prisma Angular": 4,
	"Prisma Recto T2": 0,
	"Prisma Angular T2": 0,
	"Compresor": 1,
	"Compresor T2": 0,
	"Fusionador": 0,
	"Constructor": 1,
	"GodSiphon": 0,
	"Void Generator": 0,
	"Electron": 0,
	"Fabricador Hadrón": 0,
	"Proton": 0,
	"Neutron": 0
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
	for item in GameConstants.STARTER_PACK:
		set_amount(item, GameConstants.STARTER_PACK[item])

## Solo restaura cantidades del inventario al STARTER_PACK (sin borrar mundo). Usado al desactivar DEBUG.
func restaurar_starter_pack_inventario():
	for item in GameConstants.STARTER_PACK:
		set_amount(item, GameConstants.STARTER_PACK[item])
