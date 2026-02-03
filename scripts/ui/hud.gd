extends Control

# Sistema dinámico de recursos ORGANIZADO POR CATEGORÍAS
@onready var resource_container = $PanelRecursos/MarginContainer/HBoxContainer
@onready var panel_recursos = $PanelRecursos

# Categorías de recursos
var resource_categories = {
	"ENERGÍA": ["Stability", "Charge", "Compressed-Stability", "Compressed-Charge"],
	"QUARKS": ["Up-Quark", "Down-Quark"],
	"PARTÍCULAS": ["Electron", "Proton", "Neutron"],
	"EDIFICIOS": ["Sifón", "Sifón T2", "Prisma Recto", "Prisma Angular", 
				  "Prisma Recto T2", "Prisma Angular T2", "Compresor", 
				  "Compresor T2", "Fusionador", "Fabricador Hadrón", "Constructor", "Void Generator"]
}

# Iconos y colores para cada tipo de recurso
var resource_icons = {
	"Stability": "🔋",
	"Charge": "⚡",
	"Compressed-Stability": "💠",
	"Compressed-Charge": "⚗️",
	"Up-Quark": "🟡",
	"Down-Quark": "🟠",
	"Sifón": "🏗️",
	"Sifón T2": "🏗️+",
	"Prisma Recto": "◆",
	"Prisma Angular": "◇",
	"Prisma Recto T2": "◆+",
	"Prisma Angular T2": "◇+",
	"Compresor": "🔧",
	"Compresor T2": "🔧+",
	"Fusionador": "🔀",
	"Constructor": "🏭",
	"Void Generator": "🌀",
	"Fabricador Hadrón": "⚛"
}

# Colores semánticos: E (Estabilidad), C (Carga) — alineados con GameConstants
var resource_colors = {
	"Stability": GameConstants.COLOR_STABILITY,
	"Charge": GameConstants.COLOR_CHARGE,
	"Compressed-Stability": GameConstants.COLOR_STABILITY,
	"Compressed-Charge": GameConstants.COLOR_CHARGE,
	"Up-Quark": Color(1.0, 1.0, 0.4),   # Amarillo
	"Down-Quark": Color(1.0, 0.65, 0.3), # Naranja
	"Electron": Color(0.2, 0.85, 1.0),   # Cyan
	"Proton": Color(0.9, 0.35, 0.35),    # Rojo suave
	"Neutron": Color(0.7, 0.7, 0.75)     # Gris neutro
}

# Colores por categoría
var category_colors = {
	"ENERGÍA": Color(0.4, 1.0, 0.4),  # Verde
	"QUARKS": Color(1.0, 0.8, 0.2),   # Amarillo
	"PARTÍCULAS": Color(0.2, 0.85, 1.0), # Cyan (electrones)
	"EDIFICIOS": Color(0.6, 0.8, 1.0) # Azul claro
}

func _ready():
	# HUD ocupa todo el viewport para que el centrado del panel funcione
	set_anchors_preset(Control.PRESET_FULL_RECT)

	
	# Centrar barra de recursos en la parte superior (y al redimensionar ventana si la señal existe)
	var vp = get_viewport()
	if vp.has_signal("size_changed"):
		vp.size_changed.connect(_centrar_panel_recursos)
	_centrar_panel_recursos()
	
	# Conectar a señal de cambio de inventario si existe
	if GlobalInventory.has_signal("inventory_changed"):
		GlobalInventory.inventory_changed.connect(_update_resources)
	
	# Actualizar cada segundo como fallback
	var timer = Timer.new()
	timer.wait_time = 1.0
	timer.timeout.connect(_update_resources)
	timer.autostart = true
	add_child(timer)
	
	_update_resources()

func _centrar_panel_recursos() -> void:
	if not panel_recursos:
		return
	var vp_size = get_viewport().get_visible_rect().size
	var ancho_panel := 720.0
	var alto_panel := 70.0
	panel_recursos.set_anchors_preset(Control.PRESET_TOP_LEFT)
	panel_recursos.offset_left = (vp_size.x - ancho_panel) / 2.0
	panel_recursos.offset_top = 0.0
	panel_recursos.offset_right = panel_recursos.offset_left + ancho_panel
	panel_recursos.offset_bottom = alto_panel

func _update_resources():
	# Limpiar contenedor
	for child in resource_container.get_children():
		child.queue_free()
	
	# Crear secciones por categoría (siempre mostrar ENERGÍA, QUARKS y PARTÍCULAS para ver producción)
	for category in ["ENERGÍA", "QUARKS", "PARTÍCULAS", "EDIFICIOS"]:
		var has_items = false
		
		for resource_name in resource_categories[category]:
			if GlobalInventory.stock.has(resource_name) and GlobalInventory.stock[resource_name] > 0:
				has_items = true
				break
		
		# EDIFICIOS: solo si hay al menos uno; ENERGÍA, QUARKS y PARTÍCULAS: siempre mostrar
		var always_show = (category == "ENERGÍA" or category == "QUARKS" or category == "PARTÍCULAS")
		if not has_items and not always_show:
			continue
		
		# Título de categoría con color semántico (ENERGÍA = Estabilidad/Carga)
		var category_label = Label.new()
		category_label.text = category + ":"
		category_label.add_theme_font_size_override("font_size", 15)
		category_label.add_theme_color_override("font_color", category_colors[category])
		category_label.tooltip_text = "Estabilidad E y Carga C" if category == "ENERGÍA" else ""
		category_label.custom_minimum_size.x = 95
		resource_container.add_child(category_label)
		
		# Items de la categoría (mostrar 0 para ENERGÍA/QUARKS)
		for resource_name in resource_categories[category]:
			if not GlobalInventory.stock.has(resource_name):
				continue
			
			var amount = GlobalInventory.stock[resource_name]
			if amount <= 0 and category == "EDIFICIOS":
				continue
			
			var label = Label.new()
			var icon = resource_icons.get(resource_name, "📦")
			label.text = "%s %s" % [icon, GameConstants.format_cantidad_recurso(resource_name, amount)]
			label.add_theme_font_size_override("font_size", 16)
			label.tooltip_text = _nombre_visible_recurso(resource_name)
			# Ancho suficiente para texto comprimido (ej. "1 Quark (Estabilidad)")
			label.custom_minimum_size.x = 120
			
			if resource_colors.has(resource_name):
				label.add_theme_color_override("font_color", resource_colors[resource_name])
			
			resource_container.add_child(label)
		
		# Separador visual entre categorías
		var separator = VSeparator.new()
		separator.custom_minimum_size = Vector2(2, 0)
		resource_container.add_child(separator)

func _nombre_visible_recurso(clave: String) -> String:
	return GameConstants.get_nombre_visible_recurso(clave)
