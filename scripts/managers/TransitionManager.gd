extends CanvasLayer

@onready var animation_player = AnimationPlayer.new()
@onready var color_rect = ColorRect.new()

const AMBULANCE_SCENE_PATH = "res://scenes/phases/AmbulanceTransition.tscn"
var current_ambulance_scene: Control = null
var target_scene_path: String = ""
var is_loading: bool = false

func _ready() -> void:
	layer = 128
	
	# Configurar ColorRect para o fade global
	color_rect.color = Color.BLACK
	color_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	color_rect.modulate.a = 0
	add_child(color_rect)
	
	# Configurar AnimationPlayer para fades
	add_child(animation_player)
	var library = AnimationLibrary.new()
	animation_player.add_animation_library("", library)
	_create_fade_animations(library)
	
	EventBus.transition_started.connect(start_simple_transition)
	EventBus.cinematic_transition_requested.connect(start_cinematic_transition)

func _create_fade_animations(library: AnimationLibrary) -> void:
	var fade_out = Animation.new()
	var track = fade_out.add_track(Animation.TYPE_VALUE)
	fade_out.track_set_path(track, "color_rect:modulate:a")
	fade_out.track_insert_key(track, 0.0, 0.0)
	fade_out.track_insert_key(track, 0.3, 1.0) # Fade mais rápido
	library.add_animation("fade_out", fade_out)
	
	var fade_in = Animation.new()
	track = fade_in.add_track(Animation.TYPE_VALUE)
	fade_in.track_set_path(track, "color_rect:modulate:a")
	fade_in.track_insert_key(track, 0.0, 1.0)
	fade_in.track_insert_key(track, 0.3, 0.0) # Fade mais rápido
	library.add_animation("fade_in", fade_in)

func start_simple_transition(target_path: String) -> void:
	if is_loading: return
	is_loading = true
	
	color_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	animation_player.play("fade_out")
	await animation_player.animation_finished
	
	get_tree().change_scene_to_file(target_path)
	
	animation_player.play("fade_in")
	await animation_player.animation_finished
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	is_loading = false
	EventBus.transition_finished.emit()

func start_cinematic_transition(target_path: String) -> void:
	if is_loading: return
	is_loading = true
	target_scene_path = target_path
	
	color_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# 1. Fade Rápido
	animation_player.play("fade_out")
	await animation_player.animation_finished
	
	# 2. Mostrar Cena da Ambulância
	_show_ambulance_scene()
	
	# 3. Carregamento assíncrono
	ResourceLoader.load_threaded_request(target_scene_path)
	
	# 4. Efeito de ligar monitor na ambulância
	animation_player.play("fade_in")
	if current_ambulance_scene and current_ambulance_scene.has_node("AnimationPlayer"):
		current_ambulance_scene.get_node("AnimationPlayer").play("monitor_on")
	
	# 5. Duração exata de 6 segundos (para maior imersão e legibilidade)
	await get_tree().create_timer(6.0).timeout
	
	# 6. Garantir que carregou
	while ResourceLoader.load_threaded_get_status(target_scene_path) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		await get_tree().process_frame
	
	var next_scene_resource = ResourceLoader.load_threaded_get(target_scene_path)
	
	# 7. Fade Out Final
	animation_player.play("fade_out")
	await animation_player.animation_finished
	
	# 8. Limpeza
	if current_ambulance_scene:
		current_ambulance_scene.queue_free()
		current_ambulance_scene = null
	
	get_tree().change_scene_to_packed(next_scene_resource)
	
	# 9. Fade In da Nova Cena
	animation_player.play("fade_in")
	await animation_player.animation_finished
	
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	is_loading = false
	EventBus.transition_finished.emit()

func _show_ambulance_scene() -> void:
	var scene_res = load(AMBULANCE_SCENE_PATH)
	if scene_res:
		current_ambulance_scene = scene_res.instantiate()
		add_child(current_ambulance_scene)
		move_child(current_ambulance_scene, 0) # Fica atrás do ColorRect de fade
		
		# Tocar sons de ambiente via EventBus
		EventBus.sfx_played.emit("res://assets/audio/sfx/ambulance_engine.wav")
		EventBus.sfx_played.emit("res://assets/audio/sfx/rain_loop.wav")
		EventBus.sfx_played.emit("res://assets/audio/sfx/siren_distant.wav")
