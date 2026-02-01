extends Control

# Sistema dinámico de recursos ORGANIZADO POR CATEGORÍAS
@onready var resource_container = $MarginContainer/HBoxContainer

# Categorías de recursos
var resource_categories = {
	"ENERGÍA": ["Stability", "Charge", "Compressed-Stability", "Compressed-Charge"],
	"QUARKS": ["Up-Quark", "Down-Quark"],
	"EDIFICIOS": ["Sifón", "Sifón T2", "Prisma Recto", "Prisma Angular", 
				  "Prisma Recto T2", "Prisma Angular T2", "Compresor", 
				  "Compresor T2", "Fusionador", "Constructor", "Void Generator"]
}

# Iconos para cada tipo de recurso
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
	"Void Generator": "🌀"
}

# Colores por categoría
var category_colors = {
	"ENERGÍA": Color(0.4, 1.0, 0.4),  # Verde
	"QUARKS": Color(1.0, 0.8, 0.2),   # Amarillo
	"EDIFICIOS": Color(0.6, 0.8, 1.0) # Azul claro
}

func _ready():
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

func _update_resources():
	# Limpiar contenedor
	for child in resource_container.get_children():
		child.queue_free()
	
	# Crear secciones por categoría
	for category in ["ENERGÍA", "QUARKS", "EDIFICIOS"]:
		var has_items = false
		
		# Verificar si hay items en esta categoría
		for resource_name in resource_categories[category]:
			if GlobalInventory.stock.has(resource_name) and GlobalInventory.stock[resource_name] > 0:
				has_items = true
				break
		
		if not has_items:
			continue
		
		# Título de categoría
		var category_label = Label.new()
		category_label.text = category + ":"
		category_label.add_theme_font_size_override("font_size", 14)
		category_label.add_theme_color_override("font_color", category_colors[category])
		resource_container.add_child(category_label)
		
		# Items de la categoría
		for resource_name in resource_categories[category]:
			if not GlobalInventory.stock.has(resource_name):
				continue
			
			var amount = GlobalInventory.stock[resource_name]
			if amount <= 0:
				continue
			
			var label = Label.new()
			var icon = resource_icons.get(resource_name, "📦")
			label.text = "%s %d" % [icon, amount]
			label.add_theme_font_size_override("font_size", 16)
			label.tooltip_text = resource_name
			
			resource_container.add_child(label)
		
		# Separador visual entre categorías
		var separator = VSeparator.new()
		separator.custom_minimum_size = Vector2(2, 0)
		resource_container.add_child(separator)
