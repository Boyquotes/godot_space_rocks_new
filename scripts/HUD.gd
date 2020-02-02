extends CanvasLayer

signal start_game

onready var lives_counter = [$MarginContainer/HBoxContainer/lives_counter/L1,
	$MarginContainer/HBoxContainer/lives_counter/L2,
	$MarginContainer/HBoxContainer/lives_counter/L3]

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
	
	
func _on_start_button_pressed():
	$start_button.hide()
	emit_signal("start_game")


func _on_message_timer_timeout():
	$message_label.hide()
	$message_label.text = ''
