# scripts/managers/grid_manager.gd
extends Node

const GRID_SIZE = 1.0
var occupied_cells: Dictionary = {}  # Vector2i → Building

func limpiar() -> void:
	"""Limpia el registro. Llamar al iniciar/cargar nueva partida."""
	occupied_cells.clear()

func register_building(pos: Vector2i, building) -> void:
	"""Registra un edificio en una posición del grid"""
	occupied_cells[pos] = building

func unregister_building(pos: Vector2i) -> void:
	"""Elimina un edificio de una posición del grid"""
	occupied_cells.erase(pos)

func is_cell_occupied(pos: Vector2i) -> bool:
	"""Verifica si una celda está ocupada"""
	return occupied_cells.has(pos)

func get_building_at(pos: Vector2i):
	"""Obtiene el edificio en una posición, o null si no hay"""
	return occupied_cells.get(pos, null)

func hay_edificio_en_radio(centro: Vector2i, radio: int) -> bool:
	"""Comprueba si hay algún edificio en el cuadrado (centro ± radio). Para validación de colocación."""
	for x in range(-radio, radio + 1):
		for z in range(-radio, radio + 1):
			var pos = centro + Vector2i(x, z)
			if occupied_cells.has(pos):
				return true
	return false
