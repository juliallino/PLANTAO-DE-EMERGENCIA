extends Control

@onready var stats_label = $UIIayer/StatsContainer/StatsText
@onready var title_label = $UIIayer/CenterContainer/VBoxContainer/Title
@onready var message_label = $UIIayer/CenterContainer/VBoxContainer/Message
@onready var back_button = $UIIayer/CenterContainer/VBoxContainer/HBoxContainer/BackButton
@onready var new_shift_button = $UIIayer/CenterContainer/VBoxContainer/HBoxContainer/NewShiftButton

func _ready() -> void:
	print("[FinalPlantao] _ready chamado.")
	GameManager.set_state(GameManager.GameState.GAME_OVER)
	_calculate_and_display_stats()
	_save_total_completion()
	
	if back_button:
		print("[FinalPlantao] Conectando back_button.")
		back_button.pressed.connect(_on_back_pressed)
	else:
		print("[FinalPlantao] ERRO: back_button não encontrado!")
		
	if new_shift_button:
		print("[FinalPlantao] Conectando new_shift_button.")
		new_shift_button.pressed.connect(_on_new_shift_pressed)
	else:
		print("[FinalPlantao] ERRO: new_shift_button não encontrado!")
	
	# Efeitos sonoros de encerramento
	# AudioManager.play_ambient("res://assets/audio/chuva_suave_fim.ogg")
	# AudioManager.play_sfx("res://assets/audio/sirene_longe.wav")

func _calculate_and_display_stats() -> void:
	# Buscar dados reais acumulados no GameManager
	var phases_done = GameManager.completed_phases_count
	var total_errors = GameManager.total_errors
	var total_fails = GameManager.total_failures
	
	var stats_text = "ESTATÍSTICAS DO PLANTÃO\n\n"
	stats_text += "Fases Concluídas: %d / 4\n" % phases_done
	stats_text += "Erros Cometidos: %d\n" % total_errors
	stats_text += "Falhas de Missão: %d\n" % total_fails
	
	stats_label.text = stats_text

func _save_total_completion() -> void:
	SaveManager.game_data["game_finished"] = true
	SaveManager.save_game()

func _on_back_pressed() -> void:
	print("[FinalPlantao] Botão VOLTAR AO MENU pressionado.")
	UIManager.return_to_main_menu()

func _on_new_shift_pressed() -> void:
	# Reiniciar progresso e ir para a primeira fase
	SaveManager.game_data["completed_phases"] = []
	SaveManager.save_game()
	GameManager.reset_stats()
	EventBus.transition_started.emit("res://scenes/phases/Asfixia_Intro.tscn")
