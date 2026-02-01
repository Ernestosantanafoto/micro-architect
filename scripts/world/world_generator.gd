@tool
extends Node

# --- CONTROLES DE EDITOR ---
@export_group("Controles de Editor")
@export var REGENERAR_MAPA: bool = false:
	set(val):
		REGENERAR_MAPA = false
		if val: _forzar_generacion_editor()

# --- CONFIGURACIÓN DE GENERACIÓN ---
@export_group("Generación")
@export var tamano_sector: int = 16
@export var radio_vision: int = 2
@export var espacio_inicial: float = 8.0
@export var factor_expansion: float = 0.005 # Cuanto más lejos, más espacio entre islas

@export_subgroup("Ruido Terreno")
@export_range(0.01, 0.2) var frecuencia_islas: float = 0.05
@export_range(0.1, 0.9) var umbral_mar: float = 0.4

@export_subgroup("Ruido Recursos")
@export_range(0.01, 0.3) var frecuencia_recursos: float = 0.1
@export_range(0.0, 1.0) var rareza_roja: float = 0.94

# --- ESTADO INTERNO ---
var ruido_forma = FastNoiseLite.new()
var ruido_tipo = FastNoiseLite.new()
var ruido_raro = FastNoiseLite.new()
var sectores_cargados = []

func _ready():
	_inicializar_ruidos()
	if not Engine.is_editor_hint():
		# Limpiar managers al cargar escena (nueva partida o antes de reconstruir)
		if GridManager:
			GridManager.limpiar()
		if BuildingManager:
			BuildingManager.limpiar()
		var gm = _get_grid_map()
		if gm: 
			gm.add_to_group("MapaPrincipal")
			gm.clear()
		_posicionar_camara()
		call_deferred("_reconstruir_mundo")

func _process(_delta):
	if not Engine.is_editor_hint():
		_cargar_sectores_cercanos()

func _inicializar_ruidos():
	# Obtener semilla del inventario global o generar una
	var semilla = 12345
	if not Engine.is_editor_hint() and GlobalInventory and "semilla_mundo" in GlobalInventory:
		if GlobalInventory.semilla_mundo == 0: GlobalInventory.semilla_mundo = randi()
		semilla = GlobalInventory.semilla_mundo

	ruido_forma.seed = semilla
	ruido_forma.frequency = frecuencia_islas
	ruido_forma.fractal_type = FastNoiseLite.FRACTAL_FBM
	
	ruido_tipo.seed = semilla + 100
	ruido_tipo.frequency = frecuencia_recursos
	
	ruido_raro.seed = semilla + 200
	ruido_raro.frequency = 0.2 # Frecuencia alta para puntos rojos definidos

func _forzar_generacion_editor():
	var gm = _get_grid_map()
	if not gm: return
	gm.clear()
	sectores_cargados.clear()
	_inicializar_ruidos()
	for x in range(-2, 3):
		for z in range(-2, 3):
			_generar_sector(x, z, gm)

func _generar_sector(sx: int, sz: int, gm: GridMap):
	var start_x = sx * tamano_sector
	var start_z = sz * tamano_sector
	
	for x in range(start_x, start_x + tamano_sector):
		for z in range(start_z, start_z + tamano_sector):
			var dist = Vector2(x, z).length()
			if dist < espacio_inicial: continue
			
			# APLICAR EXPANSIÓN INFINITA
			# Estiramos las coordenadas del ruido a medida que nos alejamos
			var escala = 1.0 / (1.0 + (dist * factor_expansion))
			var x_mod = x * escala
			var z_mod = z * escala
			
			var id_celda = _determinar_tipo_celda(x, z, x_mod, z_mod)
			
			if id_celda != -1:
				gm.set_cell_item(Vector3i(x, 0, z), id_celda)

func _determinar_tipo_celda(x_real: int, z_real: int, x_m: float, z_m: float) -> int:
	# Usamos las coordenadas MODIFICADAS para la forma de las islas (se estiran)
	var altura = ruido_forma.get_noise_2d(x_m, z_m)
	
	if altura <= umbral_mar:
		return -1
	
	# Usamos las coordenadas REALES para los recursos (para que no se estiren los puntos rojos)
	var val_raro = ruido_raro.get_noise_2d(x_real, z_real)
	if val_raro > (rareza_roja * 2.0 - 1.0): # Ajuste para rango FastNoiseLite (-1 a 1)
		return 2 # Rojo
	
	var val_tipo = ruido_tipo.get_noise_2d(x_m, z_m)
	
	# Tu lógica original de mezcla Azul/Verde
	if val_tipo > 0.4:
		return 1 # Azul
	elif val_tipo < -0.4:
		return 0 # Verde
	else:
		# Mezcla aleatoria en los bordes para naturalidad
		return 0 if ruido_raro.get_noise_2d(z_real, x_real) > 0 else 1

# --- FUNCIONES DE PERSISTENCIA Y CARGA ---

func _cargar_sectores_cercanos():
	var cam = get_viewport().get_camera_3d()
	var gm = _get_grid_map()
	if not cam or not gm: return
	var sx = int(floor(cam.global_position.x / tamano_sector))
	var sz = int(floor(cam.global_position.z / tamano_sector))
	for x in range(sx - radio_vision, sx + radio_vision + 1):
		for z in range(sz - radio_vision, sz + radio_vision + 1):
			var clave = Vector2i(x, z)
			if not sectores_cargados.has(clave):
				_generar_sector(x, z, gm)
				sectores_cargados.append(clave)

func _get_grid_map():
	return get_parent().get_node_or_null("GridMap")

## Fuerza la generación de sectores en un rango (para herramientas como generador de partida test)
func forzar_generar_rango(sector_min_x: int, sector_max_x: int, sector_min_z: int, sector_max_z: int) -> void:
	var gm = _get_grid_map()
	if not gm: return
	for sx in range(sector_min_x, sector_max_x + 1):
		for sz in range(sector_min_z, sector_max_z + 1):
			var clave = Vector2i(sx, sz)
			if not sectores_cargados.has(clave):
				_generar_sector(sx, sz, gm)
				sectores_cargados.append(clave)

func _reconstruir_mundo():
	await get_tree().process_frame
	# Asegurar que el centro del mapa tiene tiles ANTES de reconstruir (caso F9 / carga)
	if GlobalInventory.edificios_para_reconstruir.size() > 0:
		forzar_generar_rango(-6, 6, -6, 6)
	if GlobalInventory.edificios_para_reconstruir.size() > 0:
		if SaveSystem: SaveSystem.reconstruir_edificios()

func _posicionar_camara():
	var cam_pivot = get_tree().current_scene.find_child("CameraPivot", true, false)
	if cam_pivot and GlobalInventory.datos_camara["pos"] != Vector3.ZERO:
		cam_pivot.global_position = GlobalInventory.datos_camara["pos"]
		var cam_node = cam_pivot.find_child("Camera3D", true, false)
		if cam_node: cam_node.size = GlobalInventory.datos_camara.get("size", 100.0)
