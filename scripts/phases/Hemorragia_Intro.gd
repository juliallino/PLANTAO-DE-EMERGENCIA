extends Control

@onready var dialogue_text = $UILayer/DialogueBox/Text
@onready var dialogue_speaker = $UILayer/DialogueBox/Speaker
@onready var anim_player = $AnimationPlayer

var briefing_scene = preload("res://scenes/ui/HemorragiaBriefing.tscn")

func _ready() -> void:
	EventBus.intro_started.emit("hemorragia")
	# Efeitos sonoros de tensão e chuva
	pass

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
	print("[Hemorragia_Intro] Mostrando briefing médico (Hemorragia).")
	var briefing = briefing_scene.instantiate()
	add_child(briefing)
	briefing.briefing_completed.connect(_on_briefing_completed)

func _on_briefing_completed() -> void:
	print("Transição para Gameplay: Estancar Sangramento")
	EventBus.transition_started.emit("res://scenes/phases/Hemorragia_Gameplay.tscn")
