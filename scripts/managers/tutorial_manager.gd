extends Node

signal step_completed(step_number: int)
signal tutorial_finished()

enum TutorialStep {
	INTRO,
	PLACE_SIPHON,
	UNDERSTAND_BEAMS,
	PLACE_COMPRESSOR,
	FIRST_PRODUCTION,
	FINAL_MESSAGE
}

var current_step: TutorialStep = TutorialStep.INTRO
var tutorial_active: bool = false

# Referencias a UI
@onready var overlay = $Overlay
@onready var instruction_panel = $Overlay/InstructionPanel
@onready var step_label = $Overlay/InstructionPanel/MarginContainer/VBoxContainer/StepLabel
@onready var text_label = $Overlay/InstructionPanel/MarginContainer/VBoxContainer/TextLabel
@onready var btn_next = $Overlay/InstructionPanel/MarginContainer/VBoxContainer/HBoxButtons/BtnNext
@onready var btn_skip = $Overlay/InstructionPanel/MarginContainer/VBoxContainer/HBoxButtons/BtnSkip
@onready var checkbox_no_show = $Overlay/InstructionPanel/MarginContainer/VBoxContainer/HBoxButtons/CheckBoxNoShow

# Tracking de edificios colocados
var siphon_placed: bool = false
var compressor_placed: bool = false
var compressor_connected: bool = false

func _ready():
	# Verificar si tutorial ya fue completado
	if SaveSystem.has_method("get_value"):
		if SaveSystem.get_value("tutorial_completed", false):
			queue_free()
			return
	
	# Conectar botones
	btn_next.pressed.connect(_on_next_pressed)
	btn_skip.pressed.connect(_on_skip_pressed)
	
	# Esperar a que la escena esté lista
	await get_tree().process_frame
	
	# Conectar señales de construcción
	var construction_manager = get_tree().get_first_node_in_group("ConstructionManager")
	if construction_manager and construction_manager.has_signal("building_placed"):
		construction_manager.building_placed.connect(_on_building_placed)
	
	# Iniciar tutorial
	start_tutorial()

func start_tutorial():
	tutorial_active = true
	show_step(TutorialStep.INTRO)

func show_step(step: TutorialStep):
	current_step = step
	
	if not is_instance_valid(instruction_panel):
		return
	
	match step:
		TutorialStep.INTRO:
			_show_intro()
		TutorialStep.PLACE_SIPHON:
			_show_place_siphon()
		TutorialStep.UNDERSTAND_BEAMS:
			_show_understand_beams()
		TutorialStep.PLACE_COMPRESSOR:
			_show_place_compressor()
		TutorialStep.FIRST_PRODUCTION:
			_show_first_production()
		TutorialStep.FINAL_MESSAGE:
			_show_final_message()

func _show_intro():
	step_label.text = "¡Bienvenido a Micro Architect!"
	text_label.text = "[center]Construye materia desde energía básica hasta crear una cadena de ADN.

¿Quieres hacer el tutorial?[/center]"
	
	btn_next.text = "Sí, enséñame"
	btn_next.visible = true
	btn_skip.text = "No, ya sé jugar"
	btn_skip.visible = true
	checkbox_no_show.visible = false

func _show_place_siphon():
	step_label.text = "Paso 1/5: Coloca un SIPHON"
	text_label.text = "[center]Los siphons extraen energía del vacío.
Deben colocarse en losetas AZULES (energía).

Selecciona el Siphon y colócalo en una loseta azul.[/center]"
	
	btn_next.visible = false
	btn_skip.text = "Saltar tutorial"
	btn_skip.visible = true
	# TODO: Añadir highlight al icono de Siphon en HUD

func _show_understand_beams():
	step_label.text = "Paso 2/5: ¡Bien hecho!"
	text_label.text = "[center]Observa el haz de luz que emite el siphon.
Los haces conectan edificios automáticamente cuando están cerca.

Esto transporta energía de un edificio a otro.[/center]"
	
	btn_next.text = "Siguiente"
	btn_next.visible = true
	
	# Auto-avanzar después de 3 segundos
	await get_tree().create_timer(3.0).timeout
	if current_step == TutorialStep.UNDERSTAND_BEAMS:
		complete_current_step()

func _show_place_compressor():
	step_label.text = "Paso 3/5: Ahora coloca un COMPRESSOR"
	text_label.text = "[center]Los compressors transforman 10 energía básica en 1 energía comprimida.

Colócalo CERCA del siphon para que se conecten.[/center]"
	
	btn_next.visible = false
	# TODO: Añadir highlight al icono de Compressor en HUD

func _show_first_production():
	step_label.text = "Paso 4/5: ¡Conexión establecida!"
	text_label.text = "[center]Los pulsos de energía viajarán del siphon al compressor automáticamente.

Espera a que se cree energía comprimida...[/center]"
	
	btn_next.visible = false
	
	# TODO: Detectar cuando se crea la primera energía comprimida
	# Por ahora, auto-avanzar después de 10 segundos
	await get_tree().create_timer(10.0).timeout
	if current_step == TutorialStep.FIRST_PRODUCTION:
		complete_current_step()

func _show_final_message():
	step_label.text = "Paso 5/5: ¡Primera energía comprimida creada!"
	text_label.text = "[center]OBJETIVO DEL JUEGO:
Sigue la cadena de producción hasta crear ADN:

Energía → Quarks → Protones → Átomos → Moléculas → ADN

Usa más edificios (Mergers, Constructors) para avanzar en la cadena.

Presiona F1 en cualquier momento para ayuda.[/center]"
	
	btn_next.text = "¡Entendido, a construir!"
	btn_next.visible = true
	checkbox_no_show.visible = true

func _on_building_placed(building_type: String, building_node: Node):
	if not tutorial_active:
		return
	
	match current_step:
		TutorialStep.PLACE_SIPHON:
			if "siphon" in building_type.to_lower():
				siphon_placed = true
				complete_current_step()
		
		TutorialStep.PLACE_COMPRESSOR:
			if "compressor" in building_type.to_lower():
				compressor_placed = true
				# TODO: Verificar si está conectado al siphon
				compressor_connected = true  # Por ahora asumimos que sí
				if compressor_connected:
					complete_current_step()

func complete_current_step():
	emit_signal("step_completed", current_step)
	
	# Avanzar al siguiente paso
	match current_step:
		TutorialStep.INTRO:
			show_step(TutorialStep.PLACE_SIPHON)
		TutorialStep.PLACE_SIPHON:
			show_step(TutorialStep.UNDERSTAND_BEAMS)
		TutorialStep.UNDERSTAND_BEAMS:
			show_step(TutorialStep.PLACE_COMPRESSOR)
		TutorialStep.PLACE_COMPRESSOR:
			show_step(TutorialStep.FIRST_PRODUCTION)
		TutorialStep.FIRST_PRODUCTION:
			show_step(TutorialStep.FINAL_MESSAGE)
		TutorialStep.FINAL_MESSAGE:
			finish_tutorial()

func finish_tutorial():
	tutorial_active = false
	
	# Guardar que tutorial fue completado (si checkbox marcado)
	if checkbox_no_show and checkbox_no_show.button_pressed:
		if SaveSystem.has_method("set_value"):
			SaveSystem.set_value("tutorial_completed", true)
	
	emit_signal("tutorial_finished")
	
	if overlay:
		overlay.hide()
	
	queue_free()

func skip_tutorial():
	if SaveSystem.has_method("set_value"):
		SaveSystem.set_value("tutorial_completed", true)
	finish_tutorial()

func _on_next_pressed():
	match current_step:
		TutorialStep.INTRO:
			complete_current_step()
		TutorialStep.UNDERSTAND_BEAMS:
			complete_current_step()
		TutorialStep.FINAL_MESSAGE:
			finish_tutorial()

func _on_skip_pressed():
	skip_tutorial()
