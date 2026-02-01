# Clase de datos para flujo de energía numérico (sin nodos físicos)
class_name EnergyFlow
extends RefCounted

var from_building: Node
var to_building: Node
var amount: int
var tipo_recurso: String
var color: Color
var duration: float
var timer: float = 0.0

func _init(from: Node, to: Node, amt: int, tipo: String, col: Color, dur: float):
	from_building = from
	to_building = to
	amount = amt
	tipo_recurso = tipo
	color = col
	duration = dur

func update(delta: float) -> bool:
	"""Retorna true si el flujo sigue activo, false si ya entregó o debe eliminarse"""
	timer += delta
	if timer >= duration:
		_entregar()
		return false
	return true

func _entregar():
	if not is_instance_valid(to_building):
		return
	if to_building.has_method("recibir_energia_numerica"):
		to_building.recibir_energia_numerica(amount, tipo_recurso, from_building)
