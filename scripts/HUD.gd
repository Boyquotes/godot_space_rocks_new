extends CanvasLayer

signal start_game

onready var shield_bar = $MarginContainer/HBoxContainer/shield_bar
onready var lives_counter = [$MarginContainer/HBoxContainer/lives_counter/L1,
	$MarginContainer/HBoxContainer/lives_counter/L2,
	$MarginContainer/HBoxContainer/lives_counter/L3]
	
var red_bar = preload("res://assets/img/barHorizontal_red_mid 200.png")
var green_bar = preload("res://assets/img/barHorizontal_green_mid 200.png")
var yellow_bar = preload("res://assets/img/barHorizontal_yellow_mid 200.png")
	
const LIVES_COUNTER_MIN_WIDTH = 155
const LIVES_COUNTER_MIN_HEIGHT = 72


func _ready():
	# this is to kee aligned the shield counter
	var lives_counter_rect_min_size = Vector2(LIVES_COUNTER_MIN_WIDTH,
		LIVES_COUNTER_MIN_HEIGHT)
	$MarginContainer/HBoxContainer/lives_counter.set_custom_minimum_size(lives_counter_rect_min_size)

func update_shield(value):
	shield_bar.texture_progress = green_bar
	if value < 40:
		shield_bar.texture_progress = red_bar
	elif value < 70:
		shield_bar.texture_progress = yellow_bar
	shield_bar.value = value


func show_message(message):
	$message_label.text = message
	$message_label.show()
	$message_timer.start()


func update_score(value):
	$MarginContainer/HBoxContainer/score_label.text = str(value)

func update_lives(value):
	for item in range(3):
		lives_counter[item].visible = value > item


func game_over():
	show_message('Game Over')
	yield($message_timer, 'timeout')
	$start_button.show()


func _on_message_timer_timeout():
	$message_label.hide()
	$message_label.text = ''


func _on_start_button_pressed():
	$start_button.hide()
	emit_signal("start_game")
