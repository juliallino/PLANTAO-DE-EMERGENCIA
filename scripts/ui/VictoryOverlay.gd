extends Control

@onready var main_message = %MainMessage
@onready var sub_message = %SubMessage
@onready var heart_line = %HeartLine

var success_messages = [
	"Paciente estabilizado.",
	"Procedimento realizado com sucesso.",
	"Boa resposta, socorrista.",
	"Sinais vitais estabilizados.",
	"A vítima foi salva.",
	"Excelente trabalho.",
	"Atendimento concluído.",
	"Você agiu rápido.",
	"A equipe conseguiu salvar o paciente.",
	"Missão concluída com sucesso."
]

func _ready() -> void:
	modulate.a = 0
	visible = false

func show_victory() -> void:
	# Selecionar mensagem aleatória
	sub_message.text = success_messages.pick_random()
	
	visible = true
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Fade in suave
	tween.tween_property(self, "modulate:a", 1.0, 1.0).set_trans(Tween.TRANS_SINE)
	
	# Animação leve do batimento cardíaco (ícone)
	_animate_heart_line()
	
	# Áudio de sucesso
	EventBus.sfx_played.emit("res://assets/audio/sfx/medical_success.wav")
	
	await get_tree().create_timer(4.0).timeout
	
	# Fade out
	var fade_out = create_tween()
	fade_out.tween_property(self, "modulate:a", 0.0, 1.0).set_trans(Tween.TRANS_SINE)
	await fade_out.finished
	visible = false

func _animate_heart_line() -> void:
	var tween = create_tween().set_loops()
	tween.tween_property(heart_line, "scale", Vector2(1.2, 1.5), 0.2).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(heart_line, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_SINE)
	tween.tween_interval(0.8)
