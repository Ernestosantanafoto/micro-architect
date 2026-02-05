extends CanvasLayer

@onready var panel = $Panel
@onready var dimming = $Dimming
@onready var backdrop = $Backdrop
@onready var tab_container = $Panel/MarginContainer/VBoxContainer/TabContainer
@onready var btn_close = $Panel/MarginContainer/VBoxContainer/BtnClose

const DURACION_OSCURECER = 0.2

static func _color_hex(c: Color) -> String:
	return "#%02x%02x%02x" % [int(c.r * 255), int(c.g * 255), int(c.b * 255)]

# Contenido de ayuda (colores Estabilidad/Carga desde GameConstants)
var help_content: Dictionary:
	get:
		var h_est = _color_hex(GameConstants.COLOR_STABILITY)
		var h_car = _color_hex(GameConstants.COLOR_CHARGE)
		return {
	"Recursos": """[b]RECURSOS DE ENERGÍA[/b]

[color=%s]🔋 Estabilidad[/color] — Energía base
   • Se extrae de losetas con Sifones
   • Velocidad: 1 unidad cada 5 ticks

[color=%s]⚡ Carga[/color] — Energía base
   • Se extrae de losetas con Sifones
   • Velocidad: 1 unidad cada 5 ticks

[color=%s]💠 Estabilidad Condensada[/color] — Energía condensada
   • Se crea con Compresores (10:1 ratio)
   • Más valiosa para producción avanzada

[color=%s]⚗️ Carga Condensada[/color] — Energía condensada
   • Se crea con Compresores (10:1 ratio)
   • Más valiosa para producción avanzada
""" % [h_est, h_car, h_est, h_car] +
"""[b]QUARKS[/b]

[color=#ffff66]UP[/color]
   • Se crea fusionando energías comprimidas
   • Necesario para crear protones

[color=#ffaa44]DOWN[/color]
   • Se crea fusionando energías comprimidas
   • Necesario para crear neutrones

[b]NUCLEONES[/b]

[color=#e65959]Proton[/color] — Partícula nuclear
   • Se crea en Fabricador Hadrón: 2 [color=#ffff66]UP[/color] + 1 [color=#ffaa44]DOWN[/color]
   • Base de los átomos

[color=#b3b3bf]Neutron[/color] — Partícula nuclear
   • Se crea en Fabricador Hadrón: 1 [color=#ffff66]UP[/color] + 2 [color=#ffaa44]DOWN[/color]
   • Junto con protones forman núcleos
""",
	"Edificios": """[b]EXTRACTORES[/b]

🏗️ [b]Sifón T1[/b]
   • Extrae energía de losetas de color
   • Debe colocarse en loseta [color=%s]E[/color] o [color=%s]C[/color]
   • Producción: 1 energía/5 ticks

🏗️+ [b]Sifón T2[/b]
   • Versión mejorada del Sifón
   • Mayor velocidad de extracción
   • Puede colocarse en cualquier loseta

[b]MANIPULADORES[/b]

◆ [b]Prisma Recto[/b]
   • Redirige haces de energía en línea recta
   • No modifica el tipo de energía
   • Útil para organizar el layout

◇ [b]Prisma Angular[/b]
   • Redirige haces en ángulo de 90°
   • Permite crear esquinas en la red
   • Rotable con R

🔧 [b]Compresor T1[/b]
   • Convierte 10 energía básica → 1 comprimida
   • Debe colocarse en loseta roja
   • Almacena hasta 100 unidades

🔧+ [b]Compresor T2[/b]
   • Versión mejorada del Compresor
   • Puede colocarse en cualquier loseta
   • Mayor velocidad de procesamiento

🔀 [b]Fusionador (Merger)[/b]
   • Combina 2 energías comprimidas → 1 [color=#ffff66]UP[/color] o [color=#ffaa44]DOWN[/color]
   • Debe colocarse en loseta roja

⚛ [b]Fabricador Hadrón[/b]
   • Convierte [color=#ffff66]UP[/color] y [color=#ffaa44]DOWN[/color] en nucleones
   • Protón: 2 [color=#ffff66]UP[/color] + 1 [color=#ffaa44]DOWN[/color]
   • Neutrón: 1 [color=#ffff66]UP[/color] + 2 [color=#ffaa44]DOWN[/color]
   • Colocar en celda vacía; recibe [color=#ffff66]UP[/color] y [color=#ffaa44]DOWN[/color] por pulsos

[b]ESPECIALES[/b]

🏭 [b]Constructor[/b]
   • Crea nuevos edificios usando recursos
   • Abre menú de crafting al hacer clic
   • Necesita recetas específicas

🌀 [b]Void Generator[/b]
   • Genera recursos del vacío (modo creativo)
   • No requiere entrada de energía
   • Solo para testing
""" % [h_est, h_car],
	"Controles": """[b]CONTROLES DEL JUEGO[/b]

[b]Cámara:[/b]
• Clic izquierdo + arrastrar: Mover cámara
• Rueda del ratón: Zoom in/out

[b]Construcción:[/b]
• Clic izquierdo: Colocar edificio
• R: Rotar edificio antes de colocar
• ESC: Cancelar construcción
• Teclas 1-7: Acceso rápido (1=Sifón, 2=Prisma Recto, 3=Prisma Angular, 4=Compresor, 5=Fusionador, 6=Constructor, 7=Void Generator). 8-9 reservados.
• Tecla 0: God Siphon (solo modo desarrollo / DEV)
• Clic central en edificio puesto: Obtener uno igual en mano (misma orientación; si tienes en inventario)
• Clic central en suelo válido con objeto en mano: Colocar y quedarte con otro en mano (si te queda en inventario)

[b]Interacción:[/b]
• Clic en edificio: Abrir UI (si tiene)
• SOLTAR: Devolver edificio al inventario
• ELIMINAR: Destruir edificio en mano

[b]Sistema:[/b]
• F1: Abrir/cerrar esta ayuda
• ESC: Abrir menú de pausa
• P: Pausar/reanudar
• GUARDAR: Guardar partida actual
""",
	
	"Objetivos": """[b]OBJETIVO DEL JUEGO[/b]

Construir una cadena de producción completa desde energía básica hasta crear una molécula de ADN.

[b]CADENA DE PRODUCCIÓN:[/b]

1. Energía básica: [color=%s]E[/color] y [color=%s]C[/color]
   ↓ [Sifones en losetas de color]

2. Energía condensada: [color=%s]E[/color] y [color=%s]C[/color]
   ↓ [Compresores: 10→1 ratio]
""" % [h_est, h_car, h_est, h_car] +
"""

3. [color=#ffff66]UP[/color] / [color=#ffaa44]DOWN[/color]
   ↓ [Fusionadores: 2 comprimidas→1 [color=#ffff66]UP[/color] o [color=#ffaa44]DOWN[/color]]

4. [color=#ff6666]Protones/Neutrones[/color]
   ↓ [Fabricador Hadrón: 2U+1D→Protón, 1U+2D→Neutrón]

5. [color=#6666ff]Átomos[/color] (próximamente)
   ↓ [Protones+Neutrones+Electrones]

6. [color=#ff66ff]Moléculas[/color] (próximamente)
   ↓ [Múltiples átomos]

7. [color=#66ffff]ADN[/color] (objetivo final)
   ↓ [Secuencia compleja de moléculas]

[b]CONSEJOS:[/b]
• Planifica tu layout antes de construir
• Los haces se conectan automáticamente si están cerca
• Las losetas rojas son para manipuladores
• Usa prismas para organizar el flujo de energía
• El Constructor te permite crear más edificios
"""
}

func _ready():
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("VentanasUI")
	add_to_group("PanelesAyuda")
	
	if btn_close:
		btn_close.pressed.connect(hide_panel)
	if backdrop:
		backdrop.gui_input.connect(_on_backdrop_input)
	
	_populate_tabs()
	
	set_process_input(true)

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_F1:
		toggle_panel()
		get_viewport().set_input_as_handled()
		return
	# Cerrar al clic fuera (izq o der): si el clic no está sobre el Panel, cerrar
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
	# Cerrar popups Guardar/Cargar/Opciones al abrir F1
	var main = get_tree().current_scene
	if main and main.has_method("_cerrar_popups_overlay"):
		main._cerrar_popups_overlay()
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
	if tab_container:
		tab_container.current_tab = 0
	call_deferred("_populate_tabs")

func hide_panel():
	if dimming:
		var t = create_tween()
		t.set_ease(Tween.EASE_IN)
		t.set_trans(Tween.TRANS_SINE)
		t.tween_property(dimming, "modulate:a", 0.0, DURACION_OSCURECER)
		t.finished.connect(_on_dimming_cerrado, CONNECT_ONE_SHOT)
	else:
		_cerrar_panel_definitivo()

func _on_dimming_cerrado():
	_cerrar_panel_definitivo()

func _cerrar_panel_definitivo():
	visible = false
	get_tree().paused = false

func _on_backdrop_input(event):
	# Cerrar F1 al clic izquierdo o derecho fuera del panel
	if event is InputEventMouseButton and event.pressed:
		hide_panel()
		get_viewport().set_input_as_handled()

func _populate_tabs():
	# Obtener los tabs (cada tab puede ser ScrollContainer > RichTextLabel)
	var tabs = ["Recursos", "Edificios", "Controles", "Objetivos"]
	
	for i in range(tab_container.get_tab_count()):
		var tab_name = tabs[i] if i < tabs.size() else "Tab"
		var tab_page = tab_container.get_child(i)
		var content_node = tab_page
		if tab_page.get_child_count() > 0:
			var first = tab_page.get_child(0)
			# Puede ser ContentMargin > RichTextLabel o directamente RichTextLabel
			content_node = first.get_child(0) if first is MarginContainer and first.get_child_count() > 0 else first
		
		if content_node is RichTextLabel:
			content_node.bbcode_enabled = true
			content_node.fit_content = false
			content_node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			content_node.add_theme_color_override("default_color", Color(0.95, 0.95, 0.95))
			content_node.add_theme_font_size_override("normal_font_size", 18)
			content_node.add_theme_font_size_override("bold_font_size", 20)
			content_node.text = help_content.get(tab_name, "[center]Contenido no disponible[/center]")
