extends CanvasLayer

@onready var panel = $Panel
@onready var tab_container = $Panel/MarginContainer/VBoxContainer/TabContainer
@onready var btn_close = $Panel/MarginContainer/VBoxContainer/BtnClose

# Contenido de ayuda
var help_content = {
	"Recursos": """[b]RECURSOS DE ENERGÍA[/b]

🔋 [color=#66ff66]ESTABILIDAD (Stability)[/color] - Energía base verde
   • Se extrae de losetas verdes con Sifones
   • Velocidad: 1 unidad cada 5 ticks

⚡ [color=#aa66ff]CARGA (Charge)[/color] - Energía base violeta
   • Se extrae de losetas azules con Sifones
   • Velocidad: 1 unidad cada 5 ticks

💠 [color=#66ffff]ESTABILIDAD Comprimida[/color] - Energía comprimida verde
   • Se crea con Compresores (10:1 ratio)
   • Más valiosa para producción avanzada

⚗️ [color=#aa66ff]CARGA Comprimida[/color] - Energía comprimida violeta
   • Se crea con Compresores (10:1 ratio)
   • Más valiosa para producción avanzada

[b]QUARKS[/b]

🟡 [color=#ffff66]Up-Quark[/color] - Quark amarillo
   • Se crea fusionando energías comprimidas
   • Necesario para crear protones

🟠 [color=#ffaa44]Down-Quark[/color] - Quark naranja
   • Se crea fusionando energías comprimidas
   • Necesario para crear neutrones
""",
	
	"Edificios": """[b]EXTRACTORES[/b]

🏗️ [b]Sifón T1[/b]
   • Extrae energía de losetas de color
   • Debe colocarse en verde ([color=#66ff66]ESTABILIDAD[/color]) o azul ([color=#aa66ff]CARGA[/color])
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
   • Combina 2 energías comprimidas → 1 Quark
   • Crea Up-Quark (amarillo) o Down-Quark (naranja)
   • Debe colocarse en loseta roja

[b]ESPECIALES[/b]

🏭 [b]Constructor[/b]
   • Crea nuevos edificios usando recursos
   • Abre menú de crafting al hacer clic
   • Necesita recetas específicas

🌀 [b]Void Generator[/b]
   • Genera recursos del vacío (modo creativo)
   • No requiere entrada de energía
   • Solo para testing
""",
	
	"Controles": """[b]CONTROLES DEL JUEGO[/b]

[b]Cámara:[/b]
• Clic derecho + arrastrar: Rotar cámara
• Rueda del ratón: Zoom in/out
• Clic medio + arrastrar: Mover cámara

[b]Construcción:[/b]
• Clic izquierdo: Colocar edificio
• R: Rotar edificio antes de colocar
• ESC: Cancelar construcción
• Teclas 1-9: Acceso rápido a edificios
• Tecla 0: Seleccionar God Siphon

[b]Interacción:[/b]
• Clic en edificio: Abrir UI (si tiene)
• SOLTAR: Devolver edificio al inventario
• ELIMINAR: Destruir edificio en mano

[b]Sistema:[/b]
• F1: Abrir/cerrar esta ayuda
• ESC: Abrir menú de pausa
• GUARDAR: Guardar partida actual
""",
	
	"Objetivos": """[b]OBJETIVO DEL JUEGO[/b]

Construir una cadena de producción completa desde energía básica hasta crear una molécula de ADN.

[b]CADENA DE PRODUCCIÓN:[/b]

1. [color=#66ff66]Energía Básica[/color] ([color=#66ff66]ESTABILIDAD[/color]/[color=#aa66ff]CARGA[/color])
   ↓ [Sifones en losetas de color]

2. [color=#66ffff]Energía Comprimida[/color] ([color=#66ff66]ESTABILIDAD[/color]/[color=#aa66ff]CARGA[/color] comprimida)
   ↓ [Compresores: 10→1 ratio]

3. [color=#ffff66]Quarks[/color] (Up/Down)
   ↓ [Fusionadores: 2 comprimidas→1 quark]

4. [color=#ff6666]Protones/Neutrones[/color] (próximamente)
   ↓ [3 quarks→1 partícula]

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
	
	# Hacer que el panel funcione incluso cuando el juego está pausado
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Conectar botón de cierre
	if btn_close:
		btn_close.pressed.connect(hide_panel)
	
	# Llenar tabs con contenido
	_populate_tabs()
	
	# Conectar input para F1
	set_process_input(true)

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_F1:
		toggle_panel()
		get_viewport().set_input_as_handled()

func toggle_panel():
	if visible:
		hide_panel()
	else:
		show_panel()

func show_panel():
	visible = true
	# NO pausar el juego - permitir interacción con las pestañas
	# get_tree().paused = true

func hide_panel():
	visible = false
	# Asegurar que el juego no esté pausado
	get_tree().paused = false

func _populate_tabs():
	# Obtener los tabs
	var tabs = ["Recursos", "Edificios", "Controles", "Objetivos"]
	
	for i in range(tab_container.get_tab_count()):
		var tab_name = tabs[i] if i < tabs.size() else "Tab"
		var content_node = tab_container.get_child(i)
		
		if content_node is RichTextLabel:
			content_node.bbcode_enabled = true
			content_node.text = help_content.get(tab_name, "[center]Contenido no disponible[/center]")
