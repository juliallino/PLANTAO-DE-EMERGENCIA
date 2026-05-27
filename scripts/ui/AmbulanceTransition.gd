extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var radio_timer: Timer = $RadioTimer
@onready var rain_particles: GPUParticles2D = $RainParticles
@onready var smoke_particles: GPUParticles2D = $SmokeParticles
@onready var siren_red: ColorRect = $SirenRed
@onready var siren_blue: ColorRect = $SirenBlue

var radio_dialogues = [
	"Central para unidade móvel. Prossigam com cautela.",
	"Nova ocorrência registrada no setor 4. Prioridade Alfa.",
	"Paciente em estado crítico. ETA de dois minutos.",
	"Equipe, mantenham foco. O trânsito está pesado à frente.",
	"Unidade 03, confirme recebimento da coordenada.",
	"Suporte avançado solicitado no local.",
	"Informações preliminares indicam parada cardiorrespiratória.",
	"Atenção equipe, tempo estimado de chegada: 3 minutos."
]

func _ready() -> void:
	# Iniciar efeitos
	animation_player.play("ambulance_loop")
	_start_radio_chatter()
	
	# Ajustar luzes para serem aditivas ou overlays
	siren_red.modulate.a = 0
	siren_blue.modulate.a = 0

func _start_radio_chatter() -> void:
	_play_random_radio()
	radio_timer.wait_time = randf_range(3.0, 5.0)
	radio_timer.timeout.connect(_play_random_radio)
	radio_timer.start()

func _play_random_radio() -> void:
	var msg = radio_dialogues.pick_random()
	print("[RADIO SAMU]: ", msg)
	# Aqui poderíamos emitir um sinal para o DialogueManager ou UIManager mostrar legenda
	# EventBus.notification_triggered.emit(msg, "radio")
	
	# Efeito sonoro de rádio (bip/estática)
	# EventBus.sfx_played.emit("res://assets/audio/sfx/radio_static.wav")

func stop_all() -> void:
	radio_timer.stop()
	animation_player.stop()
