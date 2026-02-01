extends Node

var active_buildings: Array[Node] = []

func limpiar() -> void:
	"""Limpia el registro. Llamar al iniciar/cargar nueva partida."""
	active_buildings.clear()

func register_building(building: Node) -> void:
	if building and not active_buildings.has(building):
		active_buildings.append(building)

func unregister_building(building: Node) -> void:
	active_buildings.erase(building)
	if EnergyManager:
		EnergyManager.remove_flows_involving(building)

func get_buildings_in_radius(pos: Vector3, radius: float) -> Array:
	var result: Array[Node] = []
	for b in active_buildings:
		if is_instance_valid(b) and b.global_position.distance_to(pos) <= radius:
			result.append(b)
	return result
