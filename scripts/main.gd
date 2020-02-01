extends Node

export (PackedScene) var rock
var screensize = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	screensize = get_viewport().get_visible_rect().size
	$player.screen_size = screensize
	for i in range(3):
		spawn_rocks(.5)


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
	if size <= .125:
		return
	for offset in [-1, 1]:
		var dir = (pos - $player.position).normalized().tangent() * offset
		var newpos = pos + dir * radius
		var newvel = dir * vel.length() * 1.1
		spawn_rocks(size * .5, newpos, newvel) 
