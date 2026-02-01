extends Node

signal energy_transferred(from_building: Node, to_building: Node, amount: int)

var energy_flows: Array[EnergyFlow] = []

const FLUJO_DURACION_BASE = 0.5
const MOSTRAR_VISUAL_PULSO = true

func register_flow(from: Node, to: Node, amount: int, tipo_recurso: String, color: Color, duration: float = -1.0) -> EnergyFlow:
	if not is_instance_valid(from) or not is_instance_valid(to):
		return null
	if duration < 0:
		var dist = from.global_position.distance_to(to.global_position)
		duration = dist / GameConstants.PULSO_VELOCIDAD_VISUAL if dist > 0.01 else FLUJO_DURACION_BASE
	var flow = EnergyFlow.new(from, to, amount, tipo_recurso, color, duration)
	energy_flows.append(flow)
	return flow

## Spawnear visual de pulso (siempre, con o sin objetivo). Velocidad constante.
## tipo_recurso: "Stability"/"Charge" = elemental (bola 1/3), "Compressed-*" = condensada (2/3), resto = 1.
## source_origen: si rota, el visual se destruye para no flotar en el aire.
func spawn_pulse_visual(from_pos: Vector3, to_pos: Vector3, color: Color, source_origen: Node = null, tipo_recurso: String = "") -> void:
	if not MOSTRAR_VISUAL_PULSO:
		return
	var scene = get_tree().current_scene
	if not scene:
		return
	var dist = from_pos.distance_to(to_pos)
	var duration = dist / GameConstants.PULSO_VELOCIDAD_VISUAL if dist > 0.01 else FLUJO_DURACION_BASE
	var visual = PulseVisual.new()
	scene.add_child(visual)
	visual.setup(from_pos, to_pos, duration, color, source_origen, tipo_recurso)

func unregister_flow(flow: EnergyFlow) -> void:
	energy_flows.erase(flow)

## Cancela todos los flujos donde el edificio es origen o destino (p. ej. al destruir el edificio).
## También destruye los visuales de pulso (bolas) de ese edificio y de toda la cadena aguas abajo,
## para que no queden quarks/bolas flotando cuando desaparece el haz de luz.
func remove_flows_involving(building: Node) -> void:
	var to_remove: Array[EnergyFlow] = []
	for flow in energy_flows:
		if flow.from_building == building or flow.to_building == building:
			to_remove.append(flow)
	# Construir set de edificios "aguas abajo" (recursivo) para borrar todas sus bolas
	var downstream: Array[Node] = [building]
	var crecio = true
	while crecio:
		crecio = false
		for flow in energy_flows:
			if flow.from_building in downstream and is_instance_valid(flow.to_building):
				if flow.to_building not in downstream:
					downstream.append(flow.to_building)
					crecio = true
	for flow in to_remove:
		unregister_flow(flow)
	for b in downstream:
		if is_instance_valid(b):
			destroy_pulse_visuals_from_source(b)

## Elimina todas las bolas de energía cuyo origen es este edificio (para que no floten al quitar el edificio).
func destroy_pulse_visuals_from_source(building: Node) -> void:
	var tree = get_tree()
	if not tree:
		return
	for node in tree.get_nodes_in_group("PulseVisual"):
		if node is PulseVisual and node.source_origen == building:
			node.queue_free()

func _process(delta: float) -> void:
	var flows_to_remove: Array[EnergyFlow] = []
	for flow in energy_flows:
		if not flow.update(delta):
			flows_to_remove.append(flow)
	for flow in flows_to_remove:
		energy_transferred.emit(flow.from_building, flow.to_building, flow.amount)
		unregister_flow(flow)
