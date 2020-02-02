extends Area2D

export (int) var speed = 500

var velocity = Vector2()


func start(_position, _direction):
	position = _position
	velocity = Vector2(speed, 0).rotated(_direction)
	rotation = _direction


func _process(delta):
	position += velocity * delta


func _on_enemy_bullet_body_entered(body):
	queue_free()


func _on_enemy_bullet_visibilty_screen_exited():
	queue_free()
