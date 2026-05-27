extends Control

signal briefing_completed

@onready var anim_player = $AnimationPlayer
@onready var content_label = $Tablet/VBoxContainer/ContentLabel
@onready var extra_label = $Tablet/VBoxContainer/ExtraLabel
@onready var start_button = $Tablet/VBoxContainer/StartButton

func _ready() -> void:
	visible = true
	modulate.a = 0
	_play_briefing_in()
	
	# Efeitos sonoros "abafados" e rádio
	# AudioManager.play_sfx("res://assets/audio/radio_noise.wav")
	# LowPass no Master para abafar sons de fundo (chuva/sirene)
	AudioServer.set_bus_effect_enabled(AudioServer.get_bus_index("Master"), 0, true)

func _play_briefing_in() -> void:
	anim_player.play("fade_in")

func _on_start_button_pressed() -> void:
	start_button.disabled = true
	# Restaurar áudio
	AudioServer.set_bus_effect_enabled(AudioServer.get_bus_index("Master"), 0, false)
	
	anim_player.play("fade_out")
	await anim_player.animation_finished
	briefing_completed.emit()
	queue_free()
