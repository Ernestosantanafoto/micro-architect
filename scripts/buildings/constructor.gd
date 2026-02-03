extends Area3D

# --- CONFIGURACIÓN ---
const CAPACIDAD_MAXIMA = 5000 
var radio_ocupacion = GameConstants.CONSTRUCTOR_RADIO

# --- REFERENCIAS VISUALES ---
@onready var mesh = $MeshInstance3D
@onready var pivot_holograma = $PivotHolograma 

# --- ESTADO ---
var esta_construido: bool = false
var inventario_interno = {} 
var inventario_salida = []  
var total_almacenado = 0    

# --- CRAFTEO ---
var receta_seleccionada: String = ""
var tiempo_progreso: float = 0.0
var crafteando: bool = false
var receta_actual_datos = null

func _ready():
	add_to_group("AbreUIClicDerecho")
	# Configuración de colisión según estado
	var shape = find_child("CollisionShape3D", true, false)
	if not shape:
		shape = find_child("CollisionPolygon3D", true, false)
	
	if esta_construido:
		collision_layer = GameConstants.LAYER_EDIFICIOS
		collision_mask = GameConstants.LAYER_PULSOS
		monitorable = true
		monitoring = true
		if shape: shape.disabled = false
	else:
		collision_layer = 0
		collision_mask = 0
		monitorable = false
		monitoring = false
		if shape: shape.disabled = true

	input_ray_pickable = true 
	
	if not input_event.is_connected(_on_input_event):
		input_event.connect(_on_input_event)
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)
	
	_actualizar_holograma()

func _process(delta):
	# Rotar holograma
	if pivot_holograma and pivot_holograma.get_child_count() > 0:
		pivot_holograma.rotate_y(1.0 * delta)

	if not esta_construido: return 

	if not crafteando or receta_seleccionada == "": 
		return

	tiempo_progreso += delta
	_actualizar_mi_estado_global()
	
	if tiempo_progreso >= receta_actual_datos["tiempo"]:
		_terminar_fabricacion()

# --- INPUT (Abrir Menú) ---
func abrir_ui():
	var ui = get_tree().get_first_node_in_group("VentanaConstructor")
	if ui and ui.has_method("abrir_menu"):
		ui.abrir_menu(self)

func _on_input_event(_camera, event, _pos, _normal, _idx):
	if not esta_construido: return

	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			# Debug: rellenar inventario con Shift+Click
			if GameConstants.DEBUG_MODE and Input.is_key_pressed(KEY_SHIFT):
				_debug_rellenar_todo()
				get_viewport().set_input_as_handled()
				return
			
			var ui = get_tree().get_first_node_in_group("VentanaConstructor")
			if ui:
				ui.abrir_menu(self)
				get_viewport().set_input_as_handled()

func _debug_rellenar_todo():
	if receta_seleccionada != "" and receta_actual_datos:
		var inputs = receta_actual_datos["inputs"]
		for r in inputs: 
			inventario_interno[r] = inputs[r] + 50
			total_almacenado += inputs[r] + 50
	_animar_input()
	_notificar_ui()
	_intentar_iniciar_crafteo()

# --- ENERGÍA ---
func recibir_energia_numerica(cantidad: int, tipo_recurso: String, _origen: Node = null) -> void:
	if not esta_construido: return
	if total_almacenado + cantidad > CAPACIDAD_MAXIMA:
		return
	if inventario_interno.has(tipo_recurso):
		inventario_interno[tipo_recurso] += cantidad
	else:
		inventario_interno[tipo_recurso] = cantidad
	total_almacenado += cantidad
	_animar_input()
	_intentar_iniciar_crafteo()
	_actualizar_mi_estado_global()
	_notificar_ui()

func _on_area_entered(area):
	if not esta_construido: return
	if area.is_in_group("Pulsos"):
		recibir_energia_numerica(area.cantidad_energia, area.tipo_recurso, null)
		area.queue_free()

# --- CRAFTEO ---
func cambiar_receta(nombre_receta):
	receta_seleccionada = nombre_receta
	crafteando = false
	tiempo_progreso = 0.0
	
	if nombre_receta != "":
		receta_actual_datos = GameConstants.RECETAS[nombre_receta]
		_intentar_iniciar_crafteo()
	else:
		receta_actual_datos = null
	
	_actualizar_holograma()
	_actualizar_mi_estado_global()
	_notificar_ui()

func _intentar_iniciar_crafteo():
	if crafteando or receta_seleccionada == "": 
		return
	
	if not receta_actual_datos:
		return
	
	var inputs = receta_actual_datos["inputs"]
	
	# Verificar si tenemos todos los recursos necesarios
	for recurso in inputs:
		if inventario_interno.get(recurso, 0) < inputs[recurso]:
			return  # No hay suficiente de este recurso
	
	# Consumir recursos
	for recurso in inputs:
		var coste = inputs[recurso]
		inventario_interno[recurso] -= coste
		total_almacenado -= coste
		
		# Limpiar entradas vacías
		if inventario_interno[recurso] <= 0:
			inventario_interno.erase(recurso)
	
	# Iniciar crafteo
	crafteando = true
	tiempo_progreso = 0.0
	_actualizar_mi_estado_global()
	_notificar_ui()

func _terminar_fabricacion():
	crafteando = false
	tiempo_progreso = 0.0
	
	# Añadir producto a la salida
	inventario_salida.append(receta_seleccionada)
	
	_animar_exito()
	_intentar_iniciar_crafteo()  # Intentar craftear otro
	_actualizar_mi_estado_global()
	_notificar_ui()

func reclamar_todo():
	for item in inventario_salida:
		GlobalInventory.add_item(item, 1)
	inventario_salida.clear()
	_actualizar_mi_estado_global()
	_notificar_ui()

func purgar_recurso(tipo_recurso):
	if inventario_interno.has(tipo_recurso):
		var cantidad = inventario_interno[tipo_recurso]
		inventario_interno.erase(tipo_recurso)
		total_almacenado -= cantidad
		_actualizar_mi_estado_global()
		_notificar_ui()

# --- PERSISTENCIA ---
func _actualizar_mi_estado_global():
	var map = get_tree().get_first_node_in_group("MapaPrincipal")
	if map and esta_construido:
		var mi_celda = map.local_to_map(global_position)
		var datos = {
			"inv": inventario_interno.duplicate(),
			"rec": receta_seleccionada,
			"prg": tiempo_progreso,
			"out": inventario_salida.duplicate(),
			"tot": total_almacenado
		}
		GlobalInventory.registrar_estado(mi_celda, datos)

func _recuperar_estado_guardado():
	if not is_inside_tree():
		return
	var map = get_tree().get_first_node_in_group("MapaPrincipal")
	if map:
		var mi_celda = map.local_to_map(global_position)
		var e = GlobalInventory.obtener_estado(mi_celda)
		if e.size() > 0:
			inventario_interno = e.get("inv", {})
			receta_seleccionada = e.get("rec", "")
			tiempo_progreso = e.get("prg", 0.0)
			inventario_salida = e.get("out", [])
			total_almacenado = e.get("tot", 0)
			
			if receta_seleccionada != "":
				receta_actual_datos = GameConstants.RECETAS[receta_seleccionada]
				crafteando = tiempo_progreso > 0
			
			_actualizar_holograma()
			_notificar_ui()

func _notificar_ui():
	var ui = get_tree().get_first_node_in_group("VentanaConstructor")
	if ui and ui.visible and ui.constructor_activo == self:
		ui.actualizar_vista()

# --- VISUALES ---
func _actualizar_holograma():
	if not pivot_holograma: return
	
	for c in pivot_holograma.get_children(): 
		c.queue_free()
	
	if receta_seleccionada == "": return
	
	var datos = GameConstants.RECETAS.get(receta_seleccionada)
	if not datos or not datos.has("output_scene"): return
	
	var ruta_escena = datos["output_scene"]
	var escena = load(ruta_escena)
	
	if escena:
		var visual = escena.instantiate()
		pivot_holograma.add_child(visual)
		visual.process_mode = Node.PROCESS_MODE_DISABLED
		_desactivar_colisiones_recursivo(visual)
		_limpiar_ui_holograma(visual)
		
		var escala_target = 1.0 
		match receta_seleccionada:
			"Constructor": escala_target = 0.33
			"Fusionador": escala_target = 0.4 
			_: escala_target = 0.9 
		
		var escala_final = Vector3.ONE * escala_target
		visual.scale = Vector3.ZERO
		visual.position = Vector3.ZERO
		var t = create_tween()
		t.tween_property(visual, "scale", escala_final, 0.4).set_trans(Tween.TRANS_BACK)

func _desactivar_colisiones_recursivo(nodo):
	if nodo is CollisionShape3D or nodo is CollisionPolygon3D: 
		nodo.disabled = true
	for hijo in nodo.get_children(): 
		_desactivar_colisiones_recursivo(hijo)

func _limpiar_ui_holograma(nodo):
	var ui_root = nodo.find_child("UI_Root", true, false)
	if ui_root: ui_root.queue_free()
	for hijo in nodo.find_children("*", "Label3D", true): hijo.queue_free()
	for hijo in nodo.find_children("*", "Control", true): hijo.queue_free()

func _animar_input():
	if mesh:
		var t = create_tween()
		t.tween_property(mesh, "scale", GameConstants.CONSTRUCTOR_ANIM_EAT_SCALE, 0.1)
		t.tween_property(mesh, "scale", Vector3.ONE, 0.1)

func _animar_exito():
	if mesh:
		var t = create_tween()
		t.tween_property(mesh, "scale", Vector3(1.2, 1.2, 1.2), 0.1)
		t.tween_property(mesh, "scale", Vector3.ONE, 0.1)

# --- API PLACEMENT ---
func get_footprint_offsets() -> Array[Vector2i]:
	var r = int(radio_ocupacion)
	var out: Array[Vector2i] = []
	for x in range(-r, r + 1):
		for z in range(-r, r + 1):
			out.append(Vector2i(x, z))
	return out

func check_ground():
	esta_construido = true
	if BuildingManager: BuildingManager.register_building(self)
	collision_layer = GameConstants.LAYER_EDIFICIOS
	collision_mask = GameConstants.LAYER_PULSOS
	monitorable = true
	monitoring = true
	
	var shape = find_child("CollisionShape3D", true, false)
	if not shape: shape = find_child("CollisionPolygon3D", true, false)
	if shape: shape.disabled = false
	
	_recuperar_estado_guardado()

func desconectar_sifon():
	if BuildingManager: BuildingManager.unregister_building(self)
	esta_construido = false
	collision_layer = 0
	collision_mask = 0
	monitorable = false
	monitoring = false
	
	var shape = find_child("CollisionShape3D", true, false)
	if not shape: shape = find_child("CollisionPolygon3D", true, false)
	if shape: shape.disabled = true

func es_suelo_valido(id_tile):
	# Constructor solo en casilla vacía (no verde/azul/rojo ni ocupada)
	return id_tile == GameConstants.TILE_VACIO 

func recibir_luz_instantanea(_c, _r, _d): 
	pass
