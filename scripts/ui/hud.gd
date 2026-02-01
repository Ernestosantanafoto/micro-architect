extends Control

# Sistema dinámico de recursos
@onready var resource_container = $MarginContainer/HBoxContainer

# Iconos para cada tipo de recurso
var resource_icons = {
	"Stability": "🔋",
	"Charge": "⚡",
	"Compressed-Stability": "💠",
	"Compressed-Charge": "⚗️",
	"Up-Quark": "🟡",
	"Down-Quark": "🟠",
	"Sifón": "🏗️",
	"Sifón T2": "🏗️",
	"Prisma Recto": "◆",
	"Prisma Angular": "◆",
	"Prisma Recto T2": "◆",
	"Prisma Angular T2": "◆",
	"Compresor": "🔧",
	"Compresor T2": "🔧",
	"Fusionador": "🔀",
	"Constructor": "🏭",
	"Void Generator": "🌀"
}

var resource_labels = {}

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
	# Limpiar labels antiguos
	for child in resource_container.get_children():
		if child is Label and child.name.begins_with("Resource_"):
			child.queue_free()
	
	resource_labels.clear()
	
	# Crear label para cada recurso en inventario
	for resource_name in GlobalInventory.stock:
		var amount = GlobalInventory.stock[resource_name]
		if amount <= 0:
			continue  # No mostrar recursos vacíos
		
		var label = Label.new()
		label.name = "Resource_" + resource_name.replace(" ", "_")
		
		# Icono + cantidad
		var icon = resource_icons.get(resource_name, "📦")
		label.text = "%s %d" % [icon, amount]
		label.add_theme_font_size_override("font_size", 16)
		
		resource_container.add_child(label)
		resource_labels[resource_name] = label
