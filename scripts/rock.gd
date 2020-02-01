extends RigidBody2D

signal explode

var screensize = Vector2()
var size
var radius
var scale_factor = 1


func start(pos, vel, _size):
	position = pos
	size = _size
	mass = 1.5 * size
	$rock_spr.scale = Vector2(1, 1) * scale_factor * size
	$explosion.scale = Vector2($rock_spr.scale.x * 3.5, $rock_spr.scale.y * 3)
	radius = int($rock_spr.texture.get_size().x / 2 * scale_factor * size)
	var shape = CircleShape2D.new()
	shape.radius = radius
	$rock_coll.shape = shape
	linear_velocity = vel
	angular_velocity = rand_range(-1.5, 1.5)


func _integrate_forces(state):
	var xform = state.get_transform()
	if xform.origin.x > screensize.x + radius:
		xform.origin.x = 0 - radius
	elif xform.origin.x < 0 - radius:
		xform.origin.x = screensize.x + radius
	elif xform.origin.y > screensize.y + radius:
		xform.origin.y = 0 - radius
	elif xform.origin.y < 0 - radius:
		xform.origin.y = screensize.y + radius
	state.set_transform(xform)


func explode():
	layers = 0
	$rock_spr.hide()
	$explosion.show()
	$explosion/explosion_animation.play("explosion")
	emit_signal("explode", size, radius, position, linear_velocity)
	linear_velocity = Vector2()
	angular_velocity = 0


func _on_explosion_animation_animation_finished(anim_name):
	queue_free()
