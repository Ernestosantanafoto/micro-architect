extends Node

# Sistema de árbol tecnológico y desbloqueos
signal tech_unlocked(tech_name: String)
signal recipe_unlocked(recipe_name: String)

# Tecnologías desbloqueadas
var unlocked_techs: Array[String] = []
var unlocked_recipes: Array[String] = []

# Árbol de tecnologías (requisitos)
var tech_tree = {
	# Nivel 1 - Básicos (desbloqueados desde el inicio)
	"Sifón": {"requires": [], "unlocks": ["Sifón T2"]},
	"Prisma Recto": {"requires": [], "unlocks": ["Prisma Recto T2"]},
	"Prisma Angular": {"requires": [], "unlocks": ["Prisma Angular T2"]},
	
	# Nivel 2 - Manipulación básica
	"Compresor": {"requires": ["Sifón"], "unlocks": ["Compresor T2", "Fusionador"]},
	
	# Nivel 3 - Avanzado
	"Sifón T2": {"requires": ["Sifón", "Compresor"], "unlocks": []},
	"Compresor T2": {"requires": ["Compresor"], "unlocks": []},
	"Prisma Recto T2": {"requires": ["Prisma Recto", "Compresor"], "unlocks": []},
	"Prisma Angular T2": {"requires": ["Prisma Angular", "Compresor"], "unlocks": []},
	
	# Nivel 4 - Producción avanzada
	"Fusionador": {"requires": ["Compresor"], "unlocks": ["Constructor", "Fabricador Hadrón"]},
	"Constructor": {"requires": ["Fusionador"], "unlocks": []},
	"Fabricador Hadrón": {"requires": ["Fusionador"], "unlocks": []},
	
	# Especiales
	"Void Generator": {"requires": [], "unlocks": []},  # Siempre disponible (debug)
}

# Condiciones de desbloqueo (además de requisitos tecnológicos)
var unlock_conditions = {
	"Compresor": {"type": "resource", "resource": "Stability", "amount": 10},
	"Fusionador": {"type": "resource", "resource": "Compressed-Stability", "amount": 5},
	"Constructor": {"type": "resource", "resource": "Up-Quark", "amount": 1},
}

func _ready():
	# Desbloquear tecnologías iniciales
	_unlock_initial_techs()
	
	# Conectar señal de inventario para detectar desbloqueos automáticos
	if GlobalInventory.has_signal("inventory_changed"):
		GlobalInventory.inventory_changed.connect(_check_unlock_conditions)

func _unlock_initial_techs():
	# Tecnologías disponibles desde el inicio
	var initial = ["Sifón", "Prisma Recto", "Prisma Angular", "Void Generator"]
	for tech in initial:
		unlock_tech(tech, true)

func unlock_tech(tech_name: String, silent: bool = false):
	if tech_name in unlocked_techs:
		return  # Ya desbloqueado
	
	unlocked_techs.append(tech_name)
	unlocked_recipes.append(tech_name)
	
	if not silent:
		emit_signal("tech_unlocked", tech_name)
		print("[TECH] 🔓 Desbloqueado: ", tech_name)
	
	# Verificar si esto desbloquea otras tecnologías
	_check_cascade_unlocks(tech_name)

func _check_cascade_unlocks(unlocked_tech: String):
	if not tech_tree.has(unlocked_tech):
		return
	
	var unlocks = tech_tree[unlocked_tech].get("unlocks", [])
	for tech in unlocks:
		if can_unlock(tech):
			unlock_tech(tech)

func can_unlock(tech_name: String) -> bool:
	if tech_name in unlocked_techs:
		return false  # Ya desbloqueado
	
	if not tech_tree.has(tech_name):
		return false  # No existe
	
	# Verificar requisitos tecnológicos
	var requires = tech_tree[tech_name].get("requires", [])
	for req in requires:
		if req not in unlocked_techs:
			return false
	
	# Verificar condiciones adicionales (recursos, etc.)
	if unlock_conditions.has(tech_name):
		var condition = unlock_conditions[tech_name]
		match condition["type"]:
			"resource":
				var amount = GlobalInventory.get_amount(condition["resource"])
				if amount < condition["amount"]:
					return false
	
	return true

func _check_unlock_conditions(_item_name: String = "", _new_amount: int = 0):
	# Revisar todas las tecnologías para ver si se pueden desbloquear (argumentos de inventory_changed)
	for tech in tech_tree:
		if can_unlock(tech):
			unlock_tech(tech)

func is_unlocked(tech_name: String) -> bool:
	return tech_name in unlocked_techs

func get_tech_info(tech_name: String) -> Dictionary:
	if not tech_tree.has(tech_name):
		return {}
	
	var info = tech_tree[tech_name].duplicate()
	info["name"] = tech_name
	info["unlocked"] = is_unlocked(tech_name)
	info["can_unlock"] = can_unlock(tech_name)
	
	# Añadir condición de desbloqueo si existe
	if unlock_conditions.has(tech_name):
		info["unlock_condition"] = unlock_conditions[tech_name]
	
	return info

func get_all_techs_by_tier() -> Dictionary:
	var tiers = {
		"Básico": ["Sifón", "Prisma Recto", "Prisma Angular", "Void Generator"],
		"Manipulación": ["Compresor"],
		"Avanzado": ["Sifón T2", "Compresor T2", "Prisma Recto T2", "Prisma Angular T2"],
		"Producción": ["Fusionador", "Constructor", "Fabricador Hadrón"]
	}
	
	var result = {}
	for tier in tiers:
		result[tier] = []
		for tech in tiers[tier]:
			result[tier].append(get_tech_info(tech))
	
	return result

# Guardar/cargar progreso
func save_progress() -> Dictionary:
	return {
		"unlocked_techs": unlocked_techs,
		"unlocked_recipes": unlocked_recipes
	}

func load_progress(data: Dictionary):
	if data.has("unlocked_techs"):
		unlocked_techs = data["unlocked_techs"]
	if data.has("unlocked_recipes"):
		unlocked_recipes = data["unlocked_recipes"]
