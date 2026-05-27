extends Node2D

var target_r: float = 0.0
var external_r: float = 0.0
var main_color: Color = Color(0, 1, 1, 0.6)

func update_circles(t_r: float, e_r: float, c: Color) -> void:
	target_r = t_r
	external_r = e_r
	main_color = c
	queue_redraw()

func _draw() -> void:
	# Círculo Alvo (Fixo no centro)
	draw_arc(Vector2.ZERO, target_r, 0, TAU, 64, Color(1, 1, 1, 0.2), 3.0, true)
	draw_circle(Vector2.ZERO, target_r * 0.5, Color(main_color, 0.1))
	
	# Círculo Externo (Animado)
	draw_arc(Vector2.ZERO, external_r, 0, TAU, 64, main_color, 5.0, true)
	
	# Adicionar um pequeno glow interno se estiver perto do alvo
	if abs(external_r - target_r) < 10.0:
		draw_circle(Vector2.ZERO, target_r, Color(1, 1, 1, 0.2))
