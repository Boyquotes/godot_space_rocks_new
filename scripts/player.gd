extends RigidBody2D

signal shoot

export (int) var engine_thrust
export (int) var spin_thrust
export (float) var fire_rate
export (PackedScene) var bullet


enum {INIT, ALIVE, INVULNERABLE, DEAD}
var player_state =  null
var thrust = Vector2()
var rotation_dir = 0
var screen_size = Vector2()
var can_shoot = true


func _ready():
	screen_size = get_viewport().get_visible_rect().size
	change_state(ALIVE)
	$gun_timer.set_wait_time(fire_rate)


func change_state(new_state):
	match new_state:
		INIT:
			$player_coll.disabled = true
		ALIVE:
			$player_coll.disabled = false
		INVULNERABLE:
			$player_coll.disabled = true
		DEAD:
			$player_coll.disabled = true
	player_state = new_state


func _process(delta):
	get_input()


func shoot():
	if player_state == INVULNERABLE:
		return
	emit_signal("shoot", bullet, $muzzle.global_position, rotation)
	can_shoot = false
	$gun_timer.start()


func get_input():
	thrust = Vector2()
	if player_state in [DEAD, INIT]:
		return
	if Input.is_action_pressed("shoot") and can_shoot:
		shoot()
	if Input.is_action_pressed("thrust"):
		thrust = Vector2(engine_thrust, 0)
	rotation_dir = 0
	if Input.is_action_pressed("rotate_left"):
		rotation_dir -= 1
	if Input.is_action_pressed("rotate_right"):
		rotation_dir += 1


func _integrate_forces(state):
	set_applied_force(thrust.rotated(rotation))
	set_applied_torque(rotation_dir * spin_thrust)
	var xform = state.get_transform()
	if player_state == INIT:
		xform = Transform2D(0, screen_size/2)
	if xform.origin.x > screen_size.x:
		xform.origin.x = 0
	elif xform.origin.x < 0:
		xform.origin.x = screen_size.x
	elif xform.origin.y > screen_size.y:
		xform.origin.y = 0
	elif xform.origin.y < 0:
		xform.origin.y = screen_size.y
	state.set_transform(xform)


func _on_gun_timer_timeout():
	can_shoot = true
