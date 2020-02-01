extends Area2D

export (int) var speed
var velocity = Vector2()


func start(pos, dir):
	position = pos
	rotation = dir
	velocity = Vector2(speed, 0).rotated(rotation)


func _process(delta):
	position += velocity * delta


func _on_bullet_visibilty_screen_exited():
	queue_free()


func _on_bullet_body_entered(body):
	if body.is_in_group('rocks'):
		body.explode()
		queue_free()
