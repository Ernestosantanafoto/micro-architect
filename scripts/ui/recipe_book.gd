extends CanvasLayer

@onready var panel = $Panel
@onready var tech_container = $Panel/MarginContainer/VBoxContainer/ScrollContainer/TechContainer
@onready var btn_close = $Panel/MarginContainer/VBoxContainer/BtnClose

func _ready():
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	if btn_close:
		btn_close.pressed.connect(hide_panel)
	
	# Conectar señal de desbloqueo
	if TechTree.has_signal("tech_unlocked"):
		TechTree.tech_unlocked.connect(_on_tech_unlocked)
	
	set_process_input(true)

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_F2:
		toggle_panel()
		get_viewport().set_input_as_handled()

func toggle_panel():
	if visible:
		hide_panel()
	else:
		show_panel()

func show_panel():
	visible = true
	_populate_recipes()

func hide_panel():
	visible = false

func _on_tech_unlocked(tech_name: String):
	# Mostrar notificación
	print("[RECIPE] 🔓 Nueva tecnología desbloqueada: ", tech_name)

func _populate_recipes():
	# Limpiar contenedor
	for child in tech_container.get_children():
		child.queue_free()
	
	# Obtener tecnologías por nivel
	var techs_by_tier = TechTree.get_all_techs_by_tier()
	
	for tier in ["Básico", "Manipulación", "Avanzado", "Producción"]:
		if not techs_by_tier.has(tier):
			continue
		
		# Título del tier
		var tier_label = Label.new()
		tier_label.text = "═══ " + tier.to_upper() + " ═══"
		tier_label.add_theme_font_size_override("font_size", 18)
		tier_label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.2))
		tier_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		tech_container.add_child(tier_label)
		
		# Tecnologías del tier
		for tech_info in techs_by_tier[tier]:
			_create_tech_entry(tech_info)
		
		# Separador
		var separator = HSeparator.new()
		separator.custom_minimum_size = Vector2(0, 10)
		tech_container.add_child(separator)

func _create_tech_entry(tech_info: Dictionary):
	var entry = PanelContainer.new()
	entry.custom_minimum_size = Vector2(0, 80)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	entry.add_child(margin)
	
	var vbox = VBoxContainer.new()
	margin.add_child(vbox)
	
	# Nombre de la tecnología
	var name_label = RichTextLabel.new()
	name_label.bbcode_enabled = true
	name_label.fit_content = true
	name_label.scroll_active = false
	
	var icon = _get_tech_icon(tech_info["name"])
	var status_icon = "🔓" if tech_info["unlocked"] else "🔒"
	var color = "#66ff66" if tech_info["unlocked"] else "#666666"
	
	name_label.text = "[color=%s]%s %s %s[/color]" % [color, status_icon, icon, tech_info["name"]]
	vbox.add_child(name_label)
	
	# Requisitos
	if not tech_info["unlocked"]:
		var req_label = Label.new()
		req_label.add_theme_font_size_override("font_size", 12)
		
		if tech_info["requires"].size() > 0:
			req_label.text = "Requiere: " + ", ".join(tech_info["requires"])
		else:
			req_label.text = "Disponible desde el inicio"
		
		# Condición adicional
		if tech_info.has("unlock_condition"):
			var cond = tech_info["unlock_condition"]
			if cond["type"] == "resource":
				var current = GlobalInventory.get_amount(cond["resource"])
				var needed = cond["amount"]
				req_label.text += "\nNecesita: %d %s (%d/%d)" % [needed, cond["resource"], current, needed]
		
		req_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
		vbox.add_child(req_label)
	else:
		# Receta (si está en GameConstants.RECETAS)
		if GameConstants.RECETAS.has(tech_info["name"]):
			var receta = GameConstants.RECETAS[tech_info["name"]]
			if receta.has("coste"):
				var recipe_label = Label.new()
				recipe_label.add_theme_font_size_override("font_size", 12)
				
				var ingredients = []
				for item in receta["coste"]:
					ingredients.append("%dx %s" % [receta["coste"][item], item])
				
				recipe_label.text = "Receta: " + ", ".join(ingredients)
				recipe_label.add_theme_color_override("font_color", Color(0.4, 1.0, 0.4))
				vbox.add_child(recipe_label)
	
	tech_container.add_child(entry)

func _get_tech_icon(tech_name: String) -> String:
	var icons = {
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
	return icons.get(tech_name, "📦")
