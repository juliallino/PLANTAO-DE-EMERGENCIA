extends Control

@onready var dialogue_text = $UILayer/DialogueBox/Text
@onready var dialogue_speaker = $UILayer/DialogueBox/Speaker
@onready var anim_player = $AnimationPlayer

var briefing_scene = preload("res://scenes/ui/MassagemCardiacaBriefing.tscn")

func _ready() -> void:
	EventBus.intro_started.emit("parada_cardiaca")
	EventBus.story_skip_requested.connect(_on_skip_requested)
	
	# Se o skip foi solicitado durante a transição anterior, pular imediatamente
	if TransitionManager.skip_transition:
		_on_skip_requested()
	
	# Iniciar efeitos sonoros e monitor
	# ...
	pass

func _on_skip_requested() -> void:
	print("[ParadaCardiaca_Intro] História pulada pelo jogador.")
	if anim_player:
		anim_player.stop()
	AudioServer.set_bus_effect_enabled(AudioServer.get_bus_index("Master"), 0, false)
	_on_briefing_completed()

func update_dialogue(speaker: String, text: String) -> void:
	dialogue_speaker.text = speaker
	_type_text(text)

func _type_text(full_text: String) -> void:
	dialogue_text.text = full_text
	dialogue_text.visible_characters = 0
	for i in range(full_text.length()):
		dialogue_text.visible_characters += 1
		await get_tree().create_timer(0.03).timeout

func _start_mission() -> void:
	print("[ParadaCardiaca_Intro] Mostrando briefing médico (RCP).")
	if has_node("UILayer/DialogueBox"):
		$UILayer/DialogueBox.hide()
	var briefing = briefing_scene.instantiate()
	add_child(briefing)
	briefing.briefing_completed.connect(_on_briefing_completed)

func _on_briefing_completed() -> void:
	print("Transição para Gameplay: Massagem Cardíaca")
	EventBus.transition_started.emit("res://scenes/phases/MassagemCardiaca_Gameplay.tscn")
