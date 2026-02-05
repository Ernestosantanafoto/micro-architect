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
	
	# Nivel 3 - Avanzado (T2 por cantidad de T1 colocados)
	"Sifón T2": {"requires": ["Sifón"], "unlocks": []},
	"Compresor T2": {"requires": ["Compresor"], "unlocks": []},
	"Prisma Recto T2": {"requires": ["Prisma Recto"], "unlocks": []},
	"Prisma Angular T2": {"requires": ["Prisma Angular"], "unlocks": []},
	
	# Nivel 4 - Producción avanzada
	# Fabricador Hadrón NO va en unlocks de Fusionador: se desbloquea solo por condición (4 Constructores)
	"Fusionador": {"requires": ["Compresor"], "unlocks": ["Constructor"]},
	"Constructor": {"requires": ["Fusionador"], "unlocks": []},
	"Fabricador Hadrón": {"requires": ["Fusionador"], "unlocks": []},
	
	# Especiales: Void Generator requiere 3 Constructores colocados (independiente de Hadrón)
	"Void Generator": {"requires": [], "unlocks": []},
}

# Condiciones de desbloqueo: recursos en inventario O cantidad de edificios colocados.
var unlock_conditions = {
	"Compresor": {},  # Solo requisito tech (Sifón)
	"Fusionador": {"type": "resource", "resource": "Compressed-Stability", "amount": 5},
	"Constructor": {"type": "resource", "resource": "Up-Quark", "amount": 1},
	"Sifón T2": {"type": "building_count", "building": "Sifón", "amount": 12},
	"Prisma Recto T2": {"type": "building_count", "building": "Prisma Recto", "amount": 48},
	"Prisma Angular T2": {"type": "building_count", "building": "Prisma Angular", "amount": 48},
	"Compresor T2": {"type": "building_count", "building": "Compresor", "amount": 9},
	"Void Generator": {"type": "building_count", "building": "Constructor", "amount": 3},
	# Fabricador Hadrón: Fusionador (tech) + 4 Constructores colocados
	"Fabricador Hadrón": {"type": "building_count", "building": "Constructor", "amount": 4},
}

# Texto para el jugador: cómo conseguir cada objetivo (F2).
var goal_hints = {
	"Compresor": "",
	"Fusionador": "Producir 5 Estabilidad condensada: coloca Compresores conectados a Sifones; cada 10 pulsos un Compresor añade 1 al inventario.",
	"Constructor": "Producir 1 Up-Quark: desbloquea primero Fusionador, luego Fabricador Hadrón; el Hadrón produce Up-Quark.",
	"Fabricador Hadrón": "Requiere Fusionador (tech). Además: coloca 4 Constructores en el mundo.",
	"Sifón T2": "Coloca 12 Sifones T1 en el mundo.",
	"Prisma Recto T2": "Coloca 48 Prismas Rectos T1 en el mundo.",
	"Prisma Angular T2": "Coloca 48 Prismas Angulares T1 en el mundo.",
	"Compresor T2": "Coloca 9 Compresores T1 en el mundo.",
	"Void Generator": "Coloca 3 Constructores en el mundo.",
}

func _ready():
	# Desbloquear tecnologías iniciales
	_unlock_initial_techs()
	
	# Conectar señal de inventario para detectar desbloqueos automáticos
	if GlobalInventory.has_signal("inventory_changed"):
		GlobalInventory.inventory_changed.connect(_check_unlock_conditions)

func _unlock_initial_techs():
	# Tecnologías disponibles desde el inicio. Constructor en starter pack → desbloqueado para aparecer en lista infraestructura.
	var initial = ["Sifón", "Prisma Recto", "Prisma Angular", "Constructor"]
	for tech in initial:
		unlock_tech(tech, true)

func unlock_tech(tech_name: String, silent: bool = false):
	if tech_name in unlocked_techs:
		return  # Ya desbloqueado
	
	unlocked_techs.append(tech_name)
	unlocked_recipes.append(tech_name)
	
	if not silent:
		emit_signal("tech_unlocked", tech_name)
		if GameConstants.DEBUG_MODE:
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
	
	# Verificar condiciones adicionales
	if unlock_conditions.has(tech_name):
		var condition = unlock_conditions[tech_name]
		var ctype = condition.get("type", "")
		if ctype == "resource":
			var amount = GlobalInventory.get_amount(condition["resource"])
			if amount < condition["amount"]:
				return false
		elif ctype == "building_count":
			var count = get_placed_building_count(condition["building"])
			if count < condition["amount"]:
				return false
	
	return true

## Cuenta cuántos edificios del tipo dado hay colocados en la partida.
## Usa BuildingManager.active_buildings (fuente fiable); fallback a búsqueda en escena.
func get_placed_building_count(building_name: String) -> int:
	var scene_path = ""
	if GameConstants.RECETAS.has(building_name):
		scene_path = GameConstants.RECETAS[building_name].get("output_scene", "")
	if scene_path.is_empty():
		return 0
	var target = _normalizar_ruta_escena(scene_path)
	if target.is_empty():
		return 0
	if BuildingManager and BuildingManager.active_buildings.size() > 0:
		var count := 0
		for b in BuildingManager.active_buildings:
			if is_instance_valid(b) and b.get("scene_file_path") != null:
				if _normalizar_ruta_escena(b.scene_file_path) == target:
					count += 1
		return count
	var root = get_tree().current_scene if get_tree() else null
	if not root:
		return 0
	return _count_buildings_recursive(root, target)

func _normalizar_ruta_escena(path: String) -> String:
	return str(path).replace("\\", "/").strip_edges()

func _count_buildings_recursive(nodo: Node, scene_path_normalizado: String) -> int:
	var nodo_path = ""
	if nodo.get("scene_file_path") != null:
		nodo_path = _normalizar_ruta_escena(nodo.scene_file_path)
	var n = 1 if (nodo_path == scene_path_normalizado and nodo_path.length() > 0) else 0
	for c in nodo.get_children():
		n += _count_buildings_recursive(c, scene_path_normalizado)
	return n

func _check_unlock_conditions(_item_name: String = "", _new_amount: int = 0):
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
	
	# Pista de objetivo para la UI (cómo desbloquear)
	info["goal_hint"] = goal_hints.get(tech_name, "")
	
	# Qué requisitos tech están cumplidos (para mostrar ✓/✗)
	var requires_ok: Dictionary = {}
	for req in info.get("requires", []):
		requires_ok[req] = req in unlocked_techs
	info["requires_ok"] = requires_ok
	
	return info

func get_all_techs_by_tier() -> Dictionary:
	var tiers = {
		"Básico": ["Sifón", "Prisma Recto", "Prisma Angular"],
		"Manipulación": ["Compresor"],
		"Avanzado": ["Sifón T2", "Compresor T2", "Prisma Recto T2", "Prisma Angular T2"],
		"Producción": ["Fusionador", "Constructor", "Fabricador Hadrón"],
		"Especial": ["Void Generator"]
	}
	
	var result = {}
	for tier in tiers:
		result[tier] = []
		for tech in tiers[tier]:
			result[tier].append(get_tech_info(tech))
	
	return result

## Llamado al activar DEBUG_MODE: desbloquea todas las tecnologías/recetas sin revertir al desactivar.
func unlock_all_for_debug():
	for tech_name in tech_tree:
		if tech_name not in unlocked_techs:
			unlock_tech(tech_name, true)

# Reiniciar a estado inicial (nueva partida)
func reset_to_initial():
	unlocked_techs.clear()
	unlocked_recipes.clear()
	_unlock_initial_techs()
	if GameConstants.DEBUG_MODE:
		print("[TECH] Progreso reiniciado para nueva partida.")

# Guardar/cargar progreso
func save_progress() -> Dictionary:
	return {
		"unlocked_techs": unlocked_techs,
		"unlocked_recipes": unlocked_recipes
	}

func load_progress(data: Dictionary):
	if data.has("unlocked_techs"):
		unlocked_techs.clear()
		for s in data["unlocked_techs"]:
			unlocked_techs.append(str(s))
	if data.has("unlocked_recipes"):
		unlocked_recipes.clear()
		for s in data["unlocked_recipes"]:
			unlocked_recipes.append(str(s))
