extends CanvasLayer

@onready var panel = $Panel
@onready var dimming = $Dimming
@onready var backdrop = $Backdrop
@onready var tech_container = $Panel/MarginContainer/VBoxContainer/ScrollContainer/TechContainer
@onready var btn_close = $Panel/MarginContainer/VBoxContainer/BtnClose

const DURACION_OSCURECER = 0.2

func _ready():
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("VentanasUI")
	add_to_group("PanelesAyuda")
	
	if btn_close:
		btn_close.pressed.connect(hide_panel)
	if backdrop:
		backdrop.gui_input.connect(_on_backdrop_input)
	
	if TechTree.has_signal("tech_unlocked"):
		TechTree.tech_unlocked.connect(_on_tech_unlocked)
	
	set_process_input(true)

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_F2:
		toggle_panel()
		get_viewport().set_input_as_handled()
		return
	# Cerrar al clic fuera (izq o der)
	if visible and event is InputEventMouseButton and event.pressed:
		var mp = get_viewport().get_mouse_position()
		if panel and not panel.get_global_rect().has_point(mp):
			hide_panel()
			get_viewport().set_input_as_handled()

func toggle_panel():
	if visible:
		hide_panel()
	else:
		show_panel()

func show_panel():
	for n in get_tree().get_nodes_in_group("PanelesAyuda"):
		if n != self and n.has_method("hide_panel") and n.visible:
			n.hide_panel()
	visible = true
	if dimming:
		dimming.modulate.a = 0
		var t = create_tween()
		t.set_ease(Tween.EASE_OUT)
		t.set_trans(Tween.TRANS_SINE)
		t.tween_property(dimming, "modulate:a", 1.0, DURACION_OSCURECER)
	_populate_recipes()

func hide_panel():
	if dimming:
		var t = create_tween()
		t.set_ease(Tween.EASE_IN)
		t.set_trans(Tween.TRANS_SINE)
		t.tween_property(dimming, "modulate:a", 0.0, DURACION_OSCURECER)
		t.finished.connect(_cerrar_panel_definitivo, CONNECT_ONE_SHOT)
	else:
		_cerrar_panel_definitivo()

func _cerrar_panel_definitivo():
	visible = false

func _on_backdrop_input(event):
	if event is InputEventMouseButton and event.pressed:
		hide_panel()
		get_viewport().set_input_as_handled()

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
		tier_label.add_theme_font_size_override("font_size", 20)
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
	
	name_label.add_theme_font_size_override("normal_font_size", 18)
	name_label.text = "[color=%s]%s %s %s[/color]" % [color, status_icon, icon, tech_info["name"]]
	vbox.add_child(name_label)
	
	# Requisitos (RichTextLabel para colores Stability/Charge/quarks)
	if not tech_info["unlocked"]:
		var req_rtl = RichTextLabel.new()
		req_rtl.bbcode_enabled = true
		req_rtl.fit_content = true
		req_rtl.scroll_active = false
		req_rtl.add_theme_font_size_override("normal_font_size", 16)
		req_rtl.add_theme_color_override("default_color", Color(0.8, 0.8, 0.8))
		
		var txt = ""
		if tech_info["requires"].size() > 0:
			txt = "Requiere: " + ", ".join(tech_info["requires"])
		else:
			txt = "Disponible desde el inicio"
		
		if tech_info.has("unlock_condition"):
			var cond = tech_info["unlock_condition"]
			if cond["type"] == "resource":
				var current = GlobalInventory.get_amount(cond["resource"])
				var needed = cond["amount"]
				var res_name = cond["resource"]
				var res_colored = _color_nombre_recurso(res_name)
				txt += "\nNecesita: %d %s (%d/%d)" % [needed, res_colored, current, needed]
		
		req_rtl.text = txt
		vbox.add_child(req_rtl)
	else:
		# Receta (si está en GameConstants.RECETAS)
		if GameConstants.RECETAS.has(tech_info["name"]):
			var receta = GameConstants.RECETAS[tech_info["name"]]
			if receta.has("coste"):
				var recipe_rtl = RichTextLabel.new()
				recipe_rtl.bbcode_enabled = true
				recipe_rtl.fit_content = true
				recipe_rtl.scroll_active = false
				recipe_rtl.add_theme_font_size_override("normal_font_size", 16)
				
				var parts = []
				for item in receta["coste"]:
					parts.append("%dx %s" % [receta["coste"][item], _color_nombre_recurso(item)])
				recipe_rtl.text = "Receta: " + ", ".join(parts)
				recipe_rtl.add_theme_color_override("default_color", Color(0.4, 1.0, 0.4))
				vbox.add_child(recipe_rtl)
	
	tech_container.add_child(entry)

func _color_nombre_recurso(nombre: String) -> String:
	var colores = {
		"Stability": "[color=#66ff66]Stability[/color]",
		"Charge": "[color=#aa66ff]Charge[/color]",
		"Compressed-Stability": "[color=#66ffff]Compressed-Stability[/color]",
		"Compressed-Charge": "[color=#aa66ff]Compressed-Charge[/color]",
		"Up-Quark": "[color=#ffff66]Up-Quark[/color]",
		"Down-Quark": "[color=#ffaa44]Down-Quark[/color]"
	}
	return colores.get(nombre, nombre)

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
