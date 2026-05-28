extends CanvasLayer

# Este Manager controlará telas sobrepostas e notificações
@onready var pause_menu_scene = preload("res://scenes/ui/PauseMenu.tscn")
@onready var pause_button_scene = preload("res://scenes/ui/PauseButton.tscn")
@onready var skip_button_scene = preload("res://scenes/ui/SkipButton.tscn")
@onready var restart_button_scene = preload("res://scenes/ui/RestartButton.tscn")

var pause_menu_instance = null
var pause_button = null
var skip_button = null
var restart_button = null

func _ready() -> void:
	layer = 130 # Garantir que está acima do TransitionManager (128)
	EventBus.notification_triggered.connect(show_notification)
	_setup_ui_elements()
	
	print("[UIManager] Inicializado. Botões criados.")

func _setup_ui_elements() -> void:
	# Menu de pause
	pause_menu_instance = pause_menu_scene.instantiate()
	add_child(pause_menu_instance)
	
	# Botão de pause
	pause_button = pause_button_scene.instantiate()
	add_child(pause_button)
	pause_button.process_mode = Node.PROCESS_MODE_ALWAYS
	pause_button.hide()
	
	pause_button.pressed.connect(func():
		if pause_button.has_node("AnimationPlayer"):
			pause_button.get_node("AnimationPlayer").play("press")
		open_pause_menu()
	)
	
	# Botão Skip Story
	skip_button = skip_button_scene.instantiate()
	add_child(skip_button)
	skip_button.process_mode = Node.PROCESS_MODE_ALWAYS
	skip_button.hide()
	
	skip_button.pressed.connect(func():
		print("[UIManager] Botão PULAR HISTÓRIA pressionado.")
		EventBus.story_skip_requested.emit()
		toggle_skip_button(false)
	)
	
	# Botão Reiniciar Fase
	restart_button = restart_button_scene.instantiate()
	add_child(restart_button)
	restart_button.process_mode = Node.PROCESS_MODE_ALWAYS
	restart_button.hide()
	
	restart_button.pressed.connect(func():
		print("[UIManager] Botão REINICIAR FASE pressionado.")
		EventBus.phase_restart_requested.emit()
	)

func show_notification(message: String, _type: String) -> void:
	print("NOTIFICAÇÃO: ", message)

func open_pause_menu() -> void:
	if pause_menu_instance:
		pause_menu_instance.open()

func close_pause_menu() -> void:
	if pause_menu_instance:
		pause_menu_instance.force_close()

func return_to_main_menu() -> void:
	print("[UIManager] Iniciando retorno limpo ao menu principal.")
	close_pause_menu()
	get_tree().paused = false
	toggle_pause_button(false)
	toggle_skip_button(false)
	toggle_restart_button(false)
	GameManager.set_state(GameManager.GameState.MENU)
	EventBus.transition_started.emit("res://scenes/ui/MainMenu.tscn")

func toggle_pause_button(is_visible: bool) -> void:
	if pause_button:
		pause_button.visible = is_visible
		if is_visible:
			pause_button.show()
			if pause_button.has_node("AnimationPlayer"):
				pause_button.get_node("AnimationPlayer").play("idle")
		else:
			pause_button.hide()

func toggle_skip_button(is_visible: bool) -> void:
	if skip_button:
		if is_visible:
			skip_button.show()
			skip_button.modulate.a = 0
			var tween = create_tween()
			tween.tween_property(skip_button, "modulate:a", 1.0, 0.5)
		else:
			skip_button.hide()

func toggle_restart_button(is_visible: bool) -> void:
	if restart_button:
		if is_visible:
			restart_button.show()
			restart_button.modulate.a = 0
			var tween = create_tween()
			tween.tween_property(restart_button, "modulate:a", 1.0, 0.5)
		else:
			restart_button.hide()

func show_restart_button() -> void:
	toggle_restart_button(true)

func hide_restart_button() -> void:
	toggle_restart_button(false)
