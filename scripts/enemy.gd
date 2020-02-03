extends Area2D

signal shoot

export (PackedScene) var bullet
export (int) var speed = 150
export (int) var health = 3

var follow 
var target = null


func shoot():
	var dir = target.global_position - global_position
	dir = dir.rotated(rand_range(-.1, .1)).angle()
	emit_signal("shoot", bullet, global_position, dir)
	$enemy_shoot_sound.play()


func shoot_pulse(n, delay):
	for i in range(n):
		shoot()
		yield(get_tree().create_timer(delay), 'timeout')


func take_damage(amount):
	health -= amount
	$enemy_animation_player.play("flash")
	if health <= 0:
		explode()
	yield($enemy_animation_player, 'animation_finished')
	$enemy_animation_player.play("rotation")


func explode():
	speed = 0
	$gun_timer.stop()
	$enemy_coll.disabled = true
	$enemy_spr.hide()
	$explosion.show()
	$explosion/explosion_animation.play("explosion")
	# add explosion sound!!!
	$enemy_explosion_sound.play()


func _ready():
	$enemy_spr.frame = randi() % 3
	$enemy_animation_player.play("rotation")
	var path = $enemy_path.get_children()[randi() % $enemy_path.get_child_count()]
	follow = PathFollow2D.new()
	path.add_child(follow)
	follow.loop = false


func _process(delta):
	follow.offset += speed * delta
	position = follow.global_position
	if follow.unit_offset > 1:
		queue_free()


func _on_explosion_animation_animation_finished(anim_name):
	queue_free()


func _on_gun_timer_timeout():
	shoot_pulse(3, .15)


func _on_enemy_body_entered(body):
	# TODO see if enemy is invulnerable
	# to player and asteroid's collision
	if body.name == 'player':
		body.shield -= 50
		explode()
