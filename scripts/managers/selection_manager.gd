extends Node
## Sistema de selección múltiple por arrastre sobre la cuadrícula.
## Solo sobre casillas vacías; hold threshold para evitar selecciones accidentales.
## Visualización fantasma (azul semitransparente); acciones extensibles (refund, delete).

const HOLD_THRESHOLD := 0.25
const SELECTION_COLOR := Color(0.2, 0.4, 0.9, 0.35)

var _hold_timer := 0.0
var _start_cell := Vector2i.ZERO
var _current_cell := Vector2i.ZERO
var _is_holding := false
var _is_dragging := false
var _confirmed := false
var _selected_cells: Array[Vector2i] = []

var _grid_map: GridMap
var _visual_node: MeshInstance3D
var _immediate_mesh: ImmediateMesh
var _material: StandardMaterial3D
var _camera_pivot: Node3D
## Si false, la selección por arrastre y las acciones sobre área no están disponibles.
var selection_mode_enabled := false

func _ready():
	_camera_pivot = get_parent().get_node_or_null("CameraPivot")
	_grid_map = get_parent().get_node_or_null("GridMap")
	_setup_visual()

func _setup_visual():
	_immediate_mesh = ImmediateMesh.new()
	_material = StandardMaterial3D.new()
	_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_material.albedo_color = SELECTION_COLOR
	_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	
	_visual_node = MeshInstance3D.new()
	_visual_node.mesh = _immediate_mesh
	_visual_node.material_override = _material
	add_child(_visual_node)
	_visual_node.visible = false

func _process(delta: float):
	if _is_holding and not _is_dragging:
		_hold_timer += delta
		if _hold_timer >= HOLD_THRESHOLD:
			_is_dragging = true
			_current_cell = _start_cell
			_recompute_selection_rect()
			_update_visual()
			_fit_selection_in_view()

func get_cell_under_mouse() -> Variant:
	if not _grid_map:
		return null
	var cam = get_viewport().get_camera_3d()
	if not cam:
		return null
	var mouse = get_viewport().get_mouse_position()
	var from = cam.project_ray_origin(mouse)
	var dir = cam.project_ray_normal(mouse)
	var plane = Plane(Vector3.UP, 0.0)
	var intersection = plane.intersects_ray(from, dir)
	if intersection == null:
		return null
	var local_pos = _grid_map.to_local(intersection)
	var map_pos = _grid_map.local_to_map(local_pos)
	return Vector2i(map_pos.x, map_pos.z)

func start_hold(cell: Vector2i) -> void:
	_start_cell = cell
	_current_cell = cell
	_hold_timer = 0.0
	_is_holding = true
	_is_dragging = false
	_confirmed = false
	_selected_cells.clear()
	_selected_cells.append(cell)
	_update_visual()
	_visual_node.visible = true

func update_drag(cell: Variant) -> void:
	if not _is_dragging:
		return
	if cell == null:
		return
	_current_cell = Vector2i(int(cell.x), int(cell.y))
	_recompute_selection_rect()
	_update_visual()
	_fit_selection_in_view()

func confirm() -> void:
	_is_holding = false
	_is_dragging = false
	_confirmed = true
	_update_visual()
	_fit_selection_in_view()

func cancel() -> void:
	_is_holding = false
	_is_dragging = false
	_confirmed = false
	_selected_cells.clear()
	_visual_node.visible = false
	_immediate_mesh.clear_surfaces()

func set_selection_mode_enabled(enabled: bool) -> void:
	if selection_mode_enabled == enabled:
		return
	selection_mode_enabled = enabled
	if not enabled:
		cancel()

func is_selection_mode_enabled() -> bool:
	return selection_mode_enabled

func is_selecting() -> bool:
	return _is_holding or _is_dragging

func is_confirmed() -> bool:
	return _confirmed and _selected_cells.size() > 0

func get_selected_cells() -> Array[Vector2i]:
	return _selected_cells.duplicate()

func clear_selection() -> void:
	_confirmed = false
	_selected_cells.clear()
	_visual_node.visible = false
	_immediate_mesh.clear_surfaces()

func apply_action(action_name: String) -> bool:
	if not is_confirmed():
		return false
	var cells = get_selected_cells()
	var ok = _execute_action(action_name, cells)
	if ok:
		clear_selection()
	return ok

func _recompute_selection_rect() -> void:
	var min_x = mini(_start_cell.x, _current_cell.x)
	var max_x = maxi(_start_cell.x, _current_cell.x)
	var min_z = mini(_start_cell.y, _current_cell.y)
	var max_z = maxi(_start_cell.y, _current_cell.y)
	_selected_cells.clear()
	for x in range(min_x, max_x + 1):
		for z in range(min_z, max_z + 1):
			_selected_cells.append(Vector2i(x, z))

func _fit_selection_in_view() -> void:
	if _selected_cells.is_empty() or not _camera_pivot or not _camera_pivot.has_method("fit_rect_in_view"):
		return
	var min_x = _selected_cells[0].x
	var max_x = _selected_cells[0].x
	var min_z = _selected_cells[0].y
	var max_z = _selected_cells[0].y
	for c in _selected_cells:
		min_x = mini(min_x, c.x)
		max_x = maxi(max_x, c.x)
		min_z = mini(min_z, c.y)
		max_z = maxi(max_z, c.y)
	# Centro y tamaño en mundo (cada celda = 1 unidad; centro de celda en +0.5)
	var center_x = (min_x + max_x + 1) * 0.5
	var center_z = (min_z + max_z + 1) * 0.5
	var size_x = float(max_x - min_x + 1)
	var size_z = float(max_z - min_z + 1)
	_camera_pivot.fit_rect_in_view(center_x, center_z, size_x, size_z)

func _update_visual() -> void:
	_immediate_mesh.clear_surfaces()
	if _selected_cells.is_empty():
		return
	if not _grid_map:
		return
	_immediate_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
	var y := 0.02
	for cell in _selected_cells:
		var local_center = _grid_map.map_to_local(Vector3i(cell.x, 0, cell.y))
		var world_center = _grid_map.global_transform * local_center
		var cx = world_center.x
		var cz = world_center.z
		# Quad: two triangles, 4 vertices
		_immediate_mesh.surface_set_color(SELECTION_COLOR)
		_immediate_mesh.surface_add_vertex(Vector3(cx - 0.5, y, cz - 0.5))
		_immediate_mesh.surface_add_vertex(Vector3(cx + 0.5, y, cz - 0.5))
		_immediate_mesh.surface_add_vertex(Vector3(cx + 0.5, y, cz + 0.5))
		_immediate_mesh.surface_add_vertex(Vector3(cx - 0.5, y, cz - 0.5))
		_immediate_mesh.surface_add_vertex(Vector3(cx + 0.5, y, cz + 0.5))
		_immediate_mesh.surface_add_vertex(Vector3(cx - 0.5, y, cz + 0.5))
	_immediate_mesh.surface_end()

func _execute_action(action_name: String, cells: Array[Vector2i]) -> bool:
	if action_name == "refund":
		return _action_refund(cells)
	if action_name == "delete":
		return _action_delete(cells)
	return false

func _get_unique_buildings_in_cells(cells: Array[Vector2i]) -> Array:
	var seen := {}
	var out: Array = []
	for cell in cells:
		if not GridManager:
			continue
		var building = GridManager.get_building_at(cell)
		if building and not seen.get(building.get_instance_id(), false):
			seen[building.get_instance_id()] = true
			out.append(building)
	return out

func _identificar_item_por_ruta(ruta_archivo: String) -> String:
	if "god_siphon" in ruta_archivo.to_lower():
		return "GodSiphon"
	for nombre in GameConstants.RECETAS:
		if GameConstants.RECETAS[nombre]["output_scene"] == ruta_archivo:
			return nombre
	return ""

func _action_refund(cells: Array[Vector2i]) -> bool:
	var buildings = _get_unique_buildings_in_cells(cells)
	var map = get_parent().get_node_or_null("GridMap")
	for building in buildings:
		if not is_instance_valid(building):
			continue
		if GridManager:
			GridManager.unregister_building_all(building)
		var nombre = _identificar_item_por_ruta(building.scene_file_path)
		if nombre != "":
			GlobalInventory.refund_item(nombre, 1)
		if map:
			var celda = map.local_to_map(building.global_position)
			GlobalInventory.borrar_estado(celda)
		building.queue_free()
	if TechTree:
		TechTree.call_deferred("_check_unlock_conditions")
	return true

func _action_delete(cells: Array[Vector2i]) -> bool:
	var buildings = _get_unique_buildings_in_cells(cells)
	var map = get_parent().get_node_or_null("GridMap")
	for building in buildings:
		if not is_instance_valid(building):
			continue
		if GridManager:
			GridManager.unregister_building_all(building)
		if map:
			var celda = map.local_to_map(building.global_position)
			GlobalInventory.borrar_estado(celda)
		building.queue_free()
	if TechTree:
		TechTree.call_deferred("_check_unlock_conditions")
	return true
