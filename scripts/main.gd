extends Node

export (PackedScene) var rock
export (PackedScene) var enemy

var screensize = Vector2()
var level = 0
var score = 0
var playing = false
var asteroid_relation = {.5:'big',
							.25:'medium',
							.125:'small'}
var asteroid_points = {'big':10,
						'medium':20,
						'small':40}
var enemy_destroyed_score = 50

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	screensize = get_viewport().get_visible_rect().size
	$player.screen_size = screensize


func _input(event):
	if event.is_action_pressed("pause"):
		if not playing:
			return
		get_tree().paused = not get_tree().paused
	if get_tree().paused:
		$HUD/message_label.text = 'Game Paused'
		$HUD/message_label.show()
	else:
		$HUD/message_label.text = ''
		$HUD/message_label.hide()


func new_game():
	$music_sound.play()
	for rock in $rocks.get_children():
		rock.queue_free()
	level = 0
	score = 0
	$HUD.update_score(score)
	$player.start()
	$HUD.show_message('Get Ready!')
	yield($HUD/message_timer, "timeout")
	playing = true
	new_level()


func new_level():
	level += 1
	$HUD.show_message('Level %s' % level)
	for i in range(level):
		spawn_rocks(.5)
	$enemy_timer.wait_time = rand_range(5, 10)
	$enemy_timer.start()	


func _process(delta):
	if not playing:
		return
	if $rocks.get_child_count() == 0:
		new_level()


func game_over():
	$music_sound.stop()
	playing = false
	$HUD.game_over()


func spawn_rocks(size, pos=null, vel=null):
	if !pos:
		$rocks_path/rocks_spawn.set_offset(randi())
		pos = $rocks_path/rocks_spawn.position
	if !vel:
		vel = Vector2(1,0).rotated(rand_range(0, 2*PI)) * rand_range(100, 150)
	var r = rock.instance()
	r.screensize = screensize
	r.start(pos, vel, size)
	$rocks.add_child(r)
	r.connect("explode", self, "_on_rock_exploded")


func _on_player_shoot(bullet, pos, dir):
	var b = bullet.instance()
	b.start(pos, dir)
	add_child(b)


func _on_rock_exploded(size, radius, pos, vel):
	# we compute the score
	score += asteroid_points[asteroid_relation[size]]
	$HUD.update_score(score)
	if size <= .125:
		return
	for offset in [-1, 1]:
		var dir = (pos - $player.position).normalized().tangent() * offset
		var newpos = pos + dir * radius
		var newvel = dir * vel.length() * 1.1
		spawn_rocks(size * .5, newpos, newvel) 


func _on_enemy_destroyed():
	score += enemy_destroyed_score
	$HUD.update_score(score)

func _on_player_dead():
	game_over()


func _on_enemy_timer_timeout():
	var e = enemy.instance()
	add_child(e)
	e.target = $player
	e.connect('shoot', self, '_on_player_shoot')
	e.connect('update_score_on_enemy_destroyed', self, "_on_enemy_destroyed")
	$enemy_timer.wait_time = rand_range(20, 40)
	$enemy_timer.start()
