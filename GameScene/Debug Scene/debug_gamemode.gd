extends Node2D

func _process(_delta: float) -> void:
	pass

func spawnBall():
	var ball = load("res://Objects/Balls/1.tscn").instantiate()
	get_child(1).add_child(ball)
	ball.position.x = randi_range(60, get_viewport().size.x - 60)
	var mesh = ball.get_child(0).get_child(0).get_child(0)
	mesh.texture.gradient.set_color(0, Color(randf(), randf(), randf()))


func _on_ball_cooldown_timeout() -> void:
	spawnBall()
