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

## Spawnear visual de pulso (solo donde hay beam si se pasa path_waypoints). Velocidad constante.
## path_waypoints: si no vacío y size >= 2, se usan path[0] y path[-1] como from/to (garantiza pulso sobre el haz).
## tipo_recurso: "Stability"/"Charge" = elemental (bola 1/3), "Compressed-*" = condensada (2/3), resto = 1.
## source_origen: si rota, el visual se destruye para no flotar en el aire.
func spawn_pulse_visual(from_pos: Vector3, to_pos: Vector3, color: Color, source_origen: Node = null, tipo_recurso: String = "", path_waypoints: Array = []) -> void:
	if not MOSTRAR_VISUAL_PULSO:
		return
	# Validación path: solo spawnear si hay ruta válida del haz (pulsos solo donde hay beam)
	if path_waypoints.size() > 0 and path_waypoints.size() < 2:
		return
	var use_from := from_pos
	var use_to := to_pos
	if path_waypoints.size() >= 2:
		use_from = path_waypoints[0]
		use_to = path_waypoints[path_waypoints.size() - 1]
	var scene = GameConstants.get_scene_root_for(source_origen) if source_origen else get_tree().current_scene
	if not scene:
		scene = get_tree().root.get_child(0) if get_tree().root.get_child_count() > 0 else null
	if not scene:
		return
	var dist = use_from.distance_to(use_to)
	var duration = dist / GameConstants.PULSO_VELOCIDAD_VISUAL if dist > 0.01 else FLUJO_DURACION_BASE
	var visual = PulseVisual.new()
	scene.add_child(visual)
	visual.setup(use_from, use_to, duration, color, source_origen, tipo_recurso, path_waypoints)

func unregister_flow(flow: EnergyFlow) -> void:
	energy_flows.erase(flow)

## Cancela todos los flujos donde el edificio es origen o destino (p. ej. al destruir el edificio).
## También cancela flujos de toda la cadena aguas abajo (ej. prisma2→X) para que el segundo prisma
## no siga "emitiendo" partículas que ya no tienen haz de origen.
## Destruye los visuales de pulso de ese edificio y de toda la cadena aguas abajo.
func remove_flows_involving(building: Node) -> void:
	# Construir set de edificios "aguas abajo" (recursivo)
	var downstream: Array[Node] = [building]
	var crecio = true
	while crecio:
		crecio = false
		for flow in energy_flows:
			if flow.from_building in downstream and is_instance_valid(flow.to_building):
				if flow.to_building not in downstream:
					downstream.append(flow.to_building)
					crecio = true
	# Quitar cualquier flujo que tenga origen o destino en la cadena (no solo el edificio desconectado)
	var to_remove: Array[EnergyFlow] = []
	for flow in energy_flows:
		if flow.from_building in downstream or flow.to_building in downstream:
			to_remove.append(flow)
	for flow in to_remove:
		unregister_flow(flow)
	for b in downstream:
		if is_instance_valid(b):
			destroy_pulse_visuals_from_source(b)

## Cancela solo los flujos cuyo origen es este edificio (y destruye sus bolas). Útil cuando un prisma apaga su haz (p. ej. deja de recibir luz).
func remove_flows_from_source(building: Node) -> void:
	var to_remove: Array[EnergyFlow] = []
	for flow in energy_flows:
		if flow.from_building == building:
			to_remove.append(flow)
	for flow in to_remove:
		unregister_flow(flow)
	if is_instance_valid(building):
		destroy_pulse_visuals_from_source(building)

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
