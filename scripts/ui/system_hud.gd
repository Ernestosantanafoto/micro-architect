extends Node

const SAVE_PATH = "user://mundo_persistente.save"

# Orden fijo para menú RECURSOS (recipe_name -> label en mayúsculas)
const RECURSOS_ORDEN: Array[String] = [
	"Sifón", "Sifón T2",
	"Prisma Angular", "Prisma Angular T2", "Prisma Recto", "Prisma Recto T2",
	"Compresor", "Compresor T2", "Fusionador", "Constructor", "Void Generator", "Fabricador Hadrón"
]
const RECURSOS_LABELS: Dictionary = {
	"Sifón": "SIFONES T1", "Sifón T2": "SIFONES T2",
	"Prisma Angular": "PRISMAS ANGULARES T1", "Prisma Angular T2": "PRISMAS ANGULARES T2",
	"Prisma Recto": "PRISMAS RECTOS T1", "Prisma Recto T2": "PRISMAS RECTOS T2",
	"Compresor": "COMPRESORES T1", "Compresor T2": "COMPRESORES T2",
	"Fusionador": "FUSIONADORES T1", "Constructor": "CONSTRUCTORES",
	"Void Generator": "VOID GENERATORS T1", "Fabricador Hadrón": "HADRON"
}

var _recursos_highlight_recipe: String = ""
var _menu_edificios_abierto: bool = false  # menú categorías (barra inferior) abierto: oscurecer todo y ocultar red/tiles
var _recursos_panel_abierto: bool = false  # panel RECURSOS (BtnRecursos) abierto: mismo efecto
var _building_dark_materials: Dictionary = {}
var _surface_dark_materials: Dictionary = {}  # MeshInstance3D -> Material (surface 0, para restaurar bolas)
var _grid_original_surface: Variant = null  # material de la grilla para restaurar
var _grid_plane_visible: bool = true  # para restaurar visibility del plano de la grilla
var _gridmap_visible: bool = true  # para restaurar visibility del GridMap (tiles)
var _beam_dim_material: StandardMaterial3D = null  # material oscuro reutilizable para beams (se recrean cada frame)
var _volatile_dim_material: StandardMaterial3D = null  # para tiles void y otros que se sobrescriben cada frame
# Oscurecimiento ~80%: solo ~20% de brillo (0.12 = 12%)
const DIM_ALBEDO: float = 0.12
const DIM_GRID_COLOR: float = 0.06

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	_ocultar_barra_superior()
	_estilizar_botones_paneles()
	_conectar_menu_dropdown()
	_conectar_recursos_dropdown()
	_crear_materiales_dim_volatiles()

func _crear_materiales_dim_volatiles():
	_beam_dim_material = StandardMaterial3D.new()
	_beam_dim_material.albedo_color = Color(DIM_ALBEDO, DIM_ALBEDO, DIM_ALBEDO)
	_beam_dim_material.albedo_color.a = 0.4
	_beam_dim_material.emission_enabled = false
	_beam_dim_material.metallic = 0.0
	_beam_dim_material.roughness = 1.0
	_beam_dim_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_volatile_dim_material = StandardMaterial3D.new()
	_volatile_dim_material.albedo_color = Color(DIM_ALBEDO, DIM_ALBEDO, DIM_ALBEDO)
	_volatile_dim_material.emission_enabled = false
	_volatile_dim_material.metallic = 0.0
	_volatile_dim_material.roughness = 1.0

func _process(_delta: float) -> void:
	# Beams y tiles del void se redibujan/actualizan cada frame; re-aplicar dim para que sigan oscuros
	if _recursos_highlight_recipe.is_empty() and not _menu_edificios_abierto and not _recursos_panel_abierto:
		return
	_reaplicar_dim_elementos_volatiles()

func _unhandled_input(event: InputEvent) -> void:
	# P: pausar/reanudar (misma lógica que el botón PAUSA)
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_P:
		get_tree().paused = not get_tree().paused
		var vbox = get_node_or_null("MenuDropdownPanel/MenuDropdown")
		if vbox:
			var btn_pausa = vbox.get_node_or_null("BtnPausa") as Button
			if btn_pausa:
				_actualizar_texto_pausa(btn_pausa)
		get_viewport().set_input_as_handled()
		return

func _input(event: InputEvent) -> void:
	# Clic fuera del menú RECURSOS (dropdown BtnRecursos): cerrar y quitar dim
	var panel = get_node_or_null("RecursosDropdownPanel")
	if not panel or not panel.visible:
		return
	if event is InputEventMouseButton and event.pressed:
		var btn = get_node_or_null("PanelMusica/HBoxContainer/BtnRecursos")
		if panel and btn and panel is Control and btn is Control:
			var pos = (panel as Control).get_global_mouse_position()
			if not (panel as Control).get_global_rect().has_point(pos) and not (btn as Control).get_global_rect().has_point(pos):
				panel.visible = false
				_recursos_panel_abierto = false
				_quitar_aislamiento_visual()
				get_viewport().set_input_as_handled()
		return

func _ocultar_barra_superior():
	var hud = get_parent().get_node_or_null("HUD")
	if hud:
		var barra = hud.get_node_or_null("PanelRecursos")
		if barra:
			barra.visible = false

func _estilizar_botones_paneles():
	var estilo_normal = _crear_estilo_boton(Color(0.12, 0.15, 0.2, 0.95))
	var estilo_hover = _crear_estilo_boton(Color(0.18, 0.22, 0.3, 0.98))
	var estilo_pressed = _crear_estilo_boton(Color(0.08, 0.1, 0.14, 1.0))
	var botones: Array[Node] = []
	botones.append(get_node_or_null("PanelSistema/HBoxContainer/BtnMenu"))
	botones.append(get_node_or_null("PanelMusica/HBoxContainer/BtnRecursos"))
	var menu_drop = get_node_or_null("MenuDropdownPanel/MenuDropdown")
	if menu_drop:
		for c in menu_drop.get_children():
			if c is BaseButton:
				botones.append(c)
	for btn in botones:
		if btn and btn is BaseButton:
			(btn as Control).custom_minimum_size = Vector2(90, 56)
			(btn as BaseButton).add_theme_stylebox_override("normal", estilo_normal.duplicate())
			(btn as BaseButton).add_theme_stylebox_override("hover", estilo_hover.duplicate())
			(btn as BaseButton).add_theme_stylebox_override("pressed", estilo_pressed.duplicate())
			if btn is Button and (btn as Button).toggle_mode:
				(btn as BaseButton).add_theme_stylebox_override("hover_pressed", estilo_hover.duplicate())
			var font_sz = 14
			(btn as BaseButton).add_theme_font_size_override("font_size", font_sz)

func _crear_estilo_boton(bg: Color) -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	s.bg_color = bg
	s.corner_radius_top_left = 6
	s.corner_radius_top_right = 6
	s.corner_radius_bottom_left = 6
	s.corner_radius_bottom_right = 6
	s.border_width_left = 1
	s.border_width_top = 1
	s.border_width_right = 1
	s.border_width_bottom = 1
	s.border_color = Color(0.25, 0.4, 0.55, 0.8)
	s.content_margin_left = 12.0
	s.content_margin_top = 8.0
	s.content_margin_right = 12.0
	s.content_margin_bottom = 8.0
	return s

func _conectar_menu_dropdown():
	var btn_menu = get_node_or_null("PanelSistema/HBoxContainer/BtnMenu")
	if btn_menu and btn_menu is BaseButton:
		(btn_menu as BaseButton).pressed.connect(_on_btn_menu_toggle)
	var panel = get_node_or_null("MenuDropdownPanel")
	if not panel:
		return
	var vbox = panel.get_node_or_null("MenuDropdown")
	if not vbox:
		return
	var btn_pausa = vbox.get_node_or_null("BtnPausa")
	if btn_pausa and btn_pausa is BaseButton:
		(btn_pausa as BaseButton).pressed.connect(_on_btn_pausa_pressed)
		_actualizar_texto_pausa(btn_pausa as Button)
	var btn_recetas = vbox.get_node_or_null("BtnRecetas")
	if btn_recetas and btn_recetas is BaseButton:
		(btn_recetas as BaseButton).pressed.connect(_on_btn_recetas_pressed)
	var btn_musica = vbox.get_node_or_null("BtnMúsica")
	if btn_musica and btn_musica is BaseButton:
		(btn_musica as BaseButton).pressed.connect(_on_btn_mute_pressed)
		_actualizar_texto_mute(btn_musica as Button)
	var btn_debug = vbox.get_node_or_null("BtnDebug")
	if btn_debug and btn_debug is BaseButton:
		(btn_debug as BaseButton).pressed.connect(_on_btn_debug_pressed)
		_actualizar_texto_debug(btn_debug as Button)
	var btn_actualizar_visual = vbox.get_node_or_null("BtnActualizarVisual")
	if btn_actualizar_visual and btn_actualizar_visual is BaseButton:
		(btn_actualizar_visual as BaseButton).pressed.connect(_on_btn_actualizar_visual_pressed)

func _on_btn_actualizar_visual_pressed() -> void:
	# Recarga pulse_visual_material.tres y reaplica a todas las bolas en escena (ver cambios sin reiniciar)
	for node in get_tree().get_nodes_in_group("PulseVisual"):
		if node is PulseVisual and node.has_method("refresh_material_from_resource"):
			node.refresh_material_from_resource()

func _conectar_recursos_dropdown():
	var btn_recursos = get_node_or_null("PanelMusica/HBoxContainer/BtnRecursos")
	if btn_recursos and btn_recursos is BaseButton:
		(btn_recursos as BaseButton).pressed.connect(_on_btn_recursos_toggle)

func _on_btn_menu_toggle():
	var panel = get_node_or_null("MenuDropdownPanel")
	if not panel:
		return
	panel.visible = not panel.visible
	if panel.visible:
		var p_sistema = get_node_or_null("PanelSistema")
		if p_sistema:
			await get_tree().process_frame
			panel.global_position.x = p_sistema.global_position.x
			panel.global_position.y = p_sistema.global_position.y - panel.size.y - 8
		_sincronizar_estado_menu_dropdown()

func _sincronizar_estado_menu_dropdown():
	var vbox = get_node_or_null("MenuDropdownPanel/MenuDropdown")
	if not vbox:
		return
	var btn_pausa = vbox.get_node_or_null("BtnPausa") as Button
	if btn_pausa:
		_actualizar_texto_pausa(btn_pausa)
	var btn_modo = vbox.get_node_or_null("BtnModoSeleccion") as Button
	if btn_modo:
		var sm = get_parent().find_child("SelectionManager", true, false)
		if sm and sm.has_method("set_selection_mode_enabled"):
			btn_modo.button_pressed = sm.selection_mode_enabled
	var btn_musica = vbox.get_node_or_null("BtnMúsica") as Button
	if btn_musica:
		_actualizar_texto_mute(btn_musica)
	var btn_debug = vbox.get_node_or_null("BtnDebug") as Button
	if btn_debug:
		_actualizar_texto_debug(btn_debug)

func _actualizar_texto_pausa(btn: Button) -> void:
	if btn:
		btn.text = "REANUDAR" if get_tree().paused else "PAUSA"

func _actualizar_texto_debug(btn: Button) -> void:
	if btn:
		btn.text = "DEBUG ON" if GameConstants.DEBUG_MODE else "DEBUG OFF"

func _actualizar_texto_mute(btn: Button) -> void:
	if btn:
		btn.text = "🔇 MÚSICA" if (MusicManager and MusicManager.is_muted()) else "MÚSICA"

func _on_btn_pausa_pressed() -> void:
	get_tree().paused = not get_tree().paused
	var vbox = get_node_or_null("MenuDropdownPanel/MenuDropdown")
	if vbox:
		var btn_pausa = vbox.get_node_or_null("BtnPausa") as Button
		if btn_pausa:
			_actualizar_texto_pausa(btn_pausa)

func _on_btn_recetas_pressed() -> void:
	var recipe_book = get_parent().get_node_or_null("RecipeBook")
	if recipe_book and recipe_book.has_method("toggle_panel"):
		recipe_book.toggle_panel()

func _on_btn_mute_pressed() -> void:
	if MusicManager:
		MusicManager.toggle_muted()
	var vbox = get_node_or_null("MenuDropdownPanel/MenuDropdown")
	if vbox:
		var btn_musica = vbox.get_node_or_null("BtnMúsica") as Button
		if btn_musica:
			_actualizar_texto_mute(btn_musica)

func _on_btn_debug_pressed() -> void:
	GameConstants.DEBUG_MODE = not GameConstants.DEBUG_MODE
	var vbox = get_node_or_null("MenuDropdownPanel/MenuDropdown")
	if vbox:
		_actualizar_texto_debug(vbox.get_node_or_null("BtnDebug") as Button)
	if GameConstants.DEBUG_MODE:
		if TechTree:
			TechTree.unlock_all_for_debug()
		GlobalInventory.add_item("GodSiphon", 3)
	else:
		GlobalInventory.restaurar_starter_pack_inventario()
		for n in get_tree().get_nodes_in_group("BeamEmitter"):
			if n.has_method("limpiar_debug_visual"):
				n.limpiar_debug_visual()
	var inventory_hud = get_parent().get_node_or_null("InventoryHUD/MainContainer")
	if inventory_hud and inventory_hud.has_method("refresh_debug_menu"):
		inventory_hud.refresh_debug_menu()

func _on_btn_recursos_toggle():
	var panel = get_node_or_null("RecursosDropdownPanel")
	var drop = get_node_or_null("RecursosDropdownPanel/RecursosDropdown")
	if not panel or not drop:
		return
	if panel.visible:
		panel.visible = false
		_recursos_panel_abierto = false
		_quitar_aislamiento_visual()
		return
	_rellenar_recursos_dropdown()
	panel.visible = true
	_recursos_panel_abierto = true
	# Oscurecer todo y ocultar red + tiles al abrir el menú RECURSOS (mismo efecto que menú categorías)
	_aplicar_dim_completo_sin_highlight()
	var btn = get_node_or_null("PanelMusica/HBoxContainer/BtnRecursos")
	if btn:
		await get_tree().process_frame
		panel.global_position.x = (btn as Control).global_position.x - panel.size.x + (btn as Control).size.x
		panel.global_position.y = (btn as Control).global_position.y - panel.size.y - 8

func _rellenar_recursos_dropdown():
	var drop = get_node_or_null("RecursosDropdownPanel/RecursosDropdown")
	if not drop:
		return
	for c in drop.get_children():
		c.queue_free()
	var estilo = _crear_estilo_boton(Color(0.1, 0.12, 0.16, 0.95))
	for recipe_name in RECURSOS_ORDEN:
		if not GameConstants.RECETAS.has(recipe_name):
			continue
		if not TechTree or not TechTree.is_unlocked(recipe_name):
			continue
		var count = TechTree.get_placed_building_count(recipe_name) if TechTree else 0
		var label = RECURSOS_LABELS.get(recipe_name, recipe_name)
		var btn = Button.new()
		btn.text = "%s: %d" % [label, count]
		btn.custom_minimum_size = Vector2(160, 36)
		btn.add_theme_stylebox_override("normal", estilo.duplicate())
		btn.pressed.connect(_on_recursos_item_pressed.bind(recipe_name))
		drop.add_child(btn)

func _on_recursos_item_pressed(recipe_name: String):
	# Misma categoría: quitar resaltado. Otra categoría: solo la nueva queda brillante.
	if _recursos_highlight_recipe == recipe_name:
		_quitar_aislamiento_visual()
		_recursos_highlight_recipe = ""
		return
	_recursos_highlight_recipe = recipe_name
	_aplicar_aislamiento_visual()

func _aplicar_dim_completo_sin_highlight() -> void:
	_recursos_highlight_recipe = ""
	var root = get_parent()
	_oscurecer_edificios_recursivo(root, "")
	_oscurecer_y_ocultar_grilla_y_tiles(true)

## Llamar cuando se abre/cierra el menú de edificios (SIFONES, PRISMAS, etc.) en la barra inferior.
## abierto = true: oscurece todo el mundo, hace invisible la red y los tiles del suelo.
func aplicar_dim_menu_edificios(abierto: bool) -> void:
	_menu_edificios_abierto = abierto
	if abierto:
		_aplicar_dim_completo_sin_highlight()
	else:
		_quitar_aislamiento_visual()

func _aplicar_aislamiento_visual():
	# Oscurecer todo lo que no sea la categoría seleccionada: edificios, grilla, haces, partículas
	var recipe = _recursos_highlight_recipe
	_quitar_aislamiento_visual(false)  # restaura solo materiales; no mostrar grid/tiles (panel sigue abierto)
	_recursos_highlight_recipe = recipe
	var scene_path = ""
	if GameConstants.RECETAS.has(_recursos_highlight_recipe):
		scene_path = GameConstants.RECETAS[_recursos_highlight_recipe].get("output_scene", "")
	var root = get_parent()
	_oscurecer_edificios_recursivo(root, scene_path)
	_oscurecer_grilla()
	# Si el panel INFRAESTRUCTURA sigue abierto, mantener red y tiles ocultos (no mostrarlos al resaltar categoría)
	if _recursos_panel_abierto:
		_oscurecer_y_ocultar_grilla_y_tiles(true)
	_oscurecer_particulas_y_haces(root, scene_path)

func _oscurecer_edificios_recursivo(nodo: Node, scene_path_highlight: String):
	# Incluir MeshInstance3D y CSG (Constructor usa CSGBox3D con nombre "MeshInstance3D")
	if nodo is GeometryInstance3D:
		var building = _get_edificio_raiz(nodo)
		if building and building.scene_file_path != "" and "buildings" in building.scene_file_path:
			if building.scene_file_path != scene_path_highlight:
				var mat_oscuro = StandardMaterial3D.new()
				mat_oscuro.albedo_color = Color(DIM_ALBEDO, DIM_ALBEDO, DIM_ALBEDO)
				mat_oscuro.metallic = 0.0
				mat_oscuro.roughness = 1.0
				_building_dark_materials[nodo] = nodo.material_override
				nodo.material_override = mat_oscuro
	for c in nodo.get_children():
		_oscurecer_edificios_recursivo(c, scene_path_highlight)

func _get_edificio_raiz(nodo: Node) -> Node:
	var n = nodo
	while n:
		if n is Area3D and n.get("scene_file_path") != null:
			return n
		n = n.get_parent()
	return null

func _oscurecer_grilla():
	var root = get_parent()
	var camera_pivot = root.get_node_or_null("CameraPivot")
	if not camera_pivot:
		return
	var grid_plane = camera_pivot.get_node_or_null("MeshInstance3D")
	if not grid_plane or not (grid_plane is MeshInstance3D):
		return
	var mat = grid_plane.get_surface_override_material(0)
	if not mat or not (mat is ShaderMaterial):
		return
	_grid_original_surface = mat
	var mat_oscuro = mat.duplicate()
	mat_oscuro.set_shader_parameter("grid_color", Color(DIM_GRID_COLOR, DIM_GRID_COLOR, DIM_GRID_COLOR + 0.02))
	grid_plane.set_surface_override_material(0, mat_oscuro)

func _oscurecer_y_ocultar_grilla_y_tiles(ocultar: bool) -> void:
	var root = get_parent()
	var camera_pivot = root.get_node_or_null("CameraPivot")
	if camera_pivot:
		var grid_plane = camera_pivot.get_node_or_null("MeshInstance3D")
		if grid_plane and grid_plane is MeshInstance3D and ocultar:
			if grid_plane.visible:
				_grid_plane_visible = true
			grid_plane.visible = false
	var gridmap = get_tree().get_first_node_in_group("MapaPrincipal")
	if gridmap and gridmap is Node3D and ocultar:
		if gridmap.visible:
			_gridmap_visible = true
		gridmap.visible = false

func _restaurar_visibilidad_grilla_y_tiles() -> void:
	var root = get_parent()
	var camera_pivot = root.get_node_or_null("CameraPivot")
	if camera_pivot:
		var grid_plane = camera_pivot.get_node_or_null("MeshInstance3D")
		if grid_plane and grid_plane is MeshInstance3D:
			grid_plane.visible = true
	var gridmap = get_tree().get_first_node_in_group("MapaPrincipal")
	if gridmap and gridmap is Node3D:
		gridmap.visible = true
	_grid_plane_visible = true
	_gridmap_visible = true

func _oscurecer_particulas_y_haces(_root: Node, _scene_path_highlight: String):
	# PulseVisual y Beams se actualizan cada frame en _reaplicar_dim_elementos_volatiles
	# porque se crean/recrean constantemente durante el juego
	pass

func _reaplicar_dim_elementos_volatiles():
	var scene_path = ""
	if _menu_edificios_abierto or _recursos_panel_abierto:
		scene_path = ""  # todo oscuro
	elif GameConstants.RECETAS.has(_recursos_highlight_recipe):
		scene_path = GameConstants.RECETAS[_recursos_highlight_recipe].get("output_scene", "")
	var root = get_parent()
	
	# 1. Bolas de energía (PulseVisual): se crean constantemente, oscurecer cada frame
	for node in get_tree().get_nodes_in_group("PulseVisual"):
		if not is_instance_valid(node):
			continue
		# PulseVisual crea _mesh como primer hijo
		var mesh: MeshInstance3D = null
		if node.get_child_count() > 0 and node.get_child(0) is MeshInstance3D:
			mesh = node.get_child(0) as MeshInstance3D
		if not mesh:
			continue
		# Aplicar material oscuro sin emisión
		mesh.set_surface_override_material(0, _beam_dim_material)
	
	# 2. Beams: se recrean cada frame; oscurecer por surface para que no brillen
	if _beam_dim_material:
		for node in root.find_children("BeamSegment", "Node3D", true, false):
			var mesh = node.get_node_or_null("MeshInstance3D")
			if not mesh or not (mesh is MeshInstance3D):
				continue
			var building = _get_edificio_raiz(node)
			if building and building.get("scene_file_path") != null and building.scene_file_path == scene_path:
				continue
			mesh.set_surface_override_material(0, _beam_dim_material)
	
	# 3. Tiles del Void Generator: _actualizar_pulso_suelo sobrescribe el color cada frame; re-aplicar dim
	if _volatile_dim_material:
		for building in _get_edificios_void_generator(root):
			if building.scene_file_path == scene_path:
				continue
			# GridVisual está en escena; perimeter_visual se crea en código (Node3D), ambos tienen hijos MeshInstance3D
			for contenedor in building.get_children():
				if not contenedor is Node3D:
					continue
				for child in contenedor.get_children():
					if child is GeometryInstance3D:
						(child as GeometryInstance3D).material_override = _volatile_dim_material

func _get_edificios_void_generator(root: Node) -> Array:
	var out: Array = []
	for node in root.find_children("*", "Area3D", true):
		if node.get("scene_file_path") != null and node.scene_file_path != "" and "void_generator" in node.scene_file_path.to_lower():
			out.append(node)
	return out

## restaurar_grilla_y_tiles: si false, no se restaura material ni visibilidad de red/tiles (panel INFRAESTRUCTURA sigue abierto).
func _quitar_aislamiento_visual(restaurar_grilla_y_tiles: bool = true) -> void:
	for nodo in _building_dark_materials:
		if is_instance_valid(nodo):
			nodo.material_override = _building_dark_materials[nodo]
	_building_dark_materials.clear()
	for mesh in _surface_dark_materials:
		if is_instance_valid(mesh) and mesh is MeshInstance3D:
			(mesh as MeshInstance3D).set_surface_override_material(0, _surface_dark_materials[mesh])
	_surface_dark_materials.clear()
	if restaurar_grilla_y_tiles and _grid_original_surface != null:
		var root = get_parent()
		var grid_plane = root.get_node_or_null("CameraPivot/MeshInstance3D")
		if grid_plane and grid_plane is MeshInstance3D:
			grid_plane.set_surface_override_material(0, _grid_original_surface)
		_grid_original_surface = null
	_recursos_highlight_recipe = ""
	if restaurar_grilla_y_tiles:
		_menu_edificios_abierto = false
		_recursos_panel_abierto = false
		_restaurar_visibilidad_grilla_y_tiles()

func guardar_partida():
	if GameConstants.DEBUG_MODE:
		print("[DEBUG-SAVE] Iniciando volcado total...")
	var gm = get_tree().get_first_node_in_group("MapaPrincipal")
	var lista_entidades = []
	
	if gm:
		for cell in gm.get_used_cells():
			var id = gm.get_cell_item(cell)
			if id > 2:
				var rot = gm.get_cell_item_orientation(cell)
				var estado = GlobalInventory.obtener_estado_edificio(cell)
				lista_entidades.append({
					"pos": {"x": cell.x, "y": cell.y, "z": cell.z},
					"id": id,
					"rot": rot,
					"estado": estado
				})

	var paquete = {
		"semilla": GlobalInventory.semilla_mundo,
		"inventario": GlobalInventory.stock,
		"entidades": lista_entidades
	}

	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_line(JSON.stringify(paquete))
	file.close()
	if GameConstants.DEBUG_MODE:
		print("[DEBUG-SAVE] Guardado con éxito: ", lista_entidades.size(), " edificios.")

func cargar_partida() -> bool:
	if not FileAccess.file_exists(SAVE_PATH): return false
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var datos = JSON.parse_string(file.get_as_text())
	file.close()
	
	if datos:
		GlobalInventory.semilla_mundo = datos["semilla"]
		GlobalInventory.stock = datos["inventario"]
		GlobalInventory.edificios_para_reconstruir = datos["entidades"]
		return true
	return false
