extends Node3D

@onready var mesh_instance = $MeshInstance3D # Asume que el haz tiene una malla hija

func actualizar_haz(origen: Vector3, direccion: Vector3, longitud_maxima: float):
	# 1. PREPARAMOS EL RAYO FÍSICO
	var space_state = get_world_3d().direct_space_state
	# Lanzamos el rayo desde un poquito adelante (0.6m) para no chocarnos con nosotros mismos
	var from = origen + (direccion * 0.6)
	var to = from + (direccion * longitud_maxima)
	
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	# IMPORTANTE: Definir qué capas bloquean la luz (Edificios, Suelo, etc.)
	# Aquí puedes poner la máscara de colisión si la sabes (ej. 1 + 4 + 8...)
	
	var result = space_state.intersect_ray(query)
	
	var distancia_final = longitud_maxima
	
	# 2. CALCULAMOS EL CHOQUE
	if result:
		# Si chocamos, la distancia es la distancia al punto de impacto
		# Le restamos 0.6 porque empezamos a contar 0.6m delante
		distancia_final = from.distance_to(result.position)
	
	# 3. ACTUALIZAMOS EL VISUAL (El Cilindro)
	# Asumiendo que el pivote del cilindro está en la base (bottom)
	# y crece hacia arriba (+Y) o hacia adelante (-Z).
	
	# OPCIÓN A: Si usas un CylinderMesh estirado en Y y rotado 90º:
	# Ajustamos la altura del cilindro (Height)
	if mesh_instance.mesh is CylinderMesh:
		mesh_instance.mesh.height = distancia_final
		# Movemos el centro del cilindro para que crezca desde la base
		mesh_instance.position.z = -distancia_final / 2.0
	
	# OPCIÓN B (MÁS FÁCIL): Escalar el nodo entero en Z
	# Si tu haz original mide 1 metro de largo en Z:
	# scale.z = distancia_final
