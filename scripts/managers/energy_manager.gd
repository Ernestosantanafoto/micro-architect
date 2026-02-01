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
## source_origen: si rota, el visual se destruye para no flotar en el aire.
func spawn_pulse_visual(from_pos: Vector3, to_pos: Vector3, color: Color, source_origen: Node = null) -> void:
	if not MOSTRAR_VISUAL_PULSO:
		return
	var scene = get_tree().current_scene
	if not scene:
		return
	var dist = from_pos.distance_to(to_pos)
	var duration = dist / GameConstants.PULSO_VELOCIDAD_VISUAL if dist > 0.01 else FLUJO_DURACION_BASE
	var visual = PulseVisual.new()
	scene.add_child(visual)
	visual.setup(from_pos, to_pos, duration, color, source_origen)

func unregister_flow(flow: EnergyFlow) -> void:
	energy_flows.erase(flow)

func _process(delta: float) -> void:
	var flows_to_remove: Array[EnergyFlow] = []
	for flow in energy_flows:
		if not flow.update(delta):
			flows_to_remove.append(flow)
	for flow in flows_to_remove:
		energy_transferred.emit(flow.from_building, flow.to_building, flow.amount)
		unregister_flow(flow)
