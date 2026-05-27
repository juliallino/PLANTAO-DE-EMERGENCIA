extends CanvasLayer

# Este Manager controlará telas sobrepostas e notificações
# Pode ser expandido para carregar cenas de UI dinamicamente

@onready var pause_menu_scene = preload("res://scenes/ui/PauseMenu.tscn")
@onready var pause_button_scene = preload("res://scenes/ui/PauseButton.tscn")
var pause_menu_instance = null
var pause_button = null

func _ready() -> void:
	layer = 130 # Garantir que está acima do TransitionManager (128)
	EventBus.notification_triggered.connect(show_notification)
	_setup_pause_system()
	
	print("[UIManager] Inicializado. Botão de pause criado.")
	
	# Ocultar botão de pause no início
	if pause_button:
		pause_button.hide()

func _setup_pause_system() -> void:
	# Criar menu de pause
	pause_menu_instance = pause_menu_scene.instantiate()
	add_child(pause_menu_instance)
	
	# Instanciar botão de pause cinematográfico
	pause_button = pause_button_scene.instantiate()
	add_child(pause_button)
	
	# Garantir que o botão processa mesmo pausado
	pause_button.process_mode = Node.PROCESS_MODE_ALWAYS
	
	pause_button.pressed.connect(func():
		print("[UIManager] Botão de pause pressionado.")
		if pause_button.has_node("AnimationPlayer"):
			pause_button.get_node("AnimationPlayer").play("press")
		open_pause_menu()
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
	
	# 1. Fechar menu de pause e despausar árvore
	close_pause_menu()
	get_tree().paused = false
	
	# 2. Esconder botão de pause
	toggle_pause_button(false)
	
	# 3. Resetar estado no GameManager
	GameManager.set_state(GameManager.GameState.MENU)
	
	# 4. Disparar transição
	EventBus.transition_started.emit("res://scenes/ui/MainMenu.tscn")

func toggle_pause_button(is_visible: bool) -> void:
	if pause_button:
		pause_button.visible = is_visible
		print("[UIManager] Toggle pause button: ", is_visible, " (Button is at: ", pause_button.global_position, ")")
		if is_visible:
			pause_button.show()
			if pause_button.has_node("AnimationPlayer"):
				pause_button.get_node("AnimationPlayer").play("idle")
		else:
			pause_button.hide()
			# Se o botão de pause sumir, e o menu estiver aberto, talvez queiramos fechar o menu?
			# Depende se é transição. GameManager cuida disso.
