extends Control

@onready var game_handler = $".."
@onready var timer_label = $Timer/Timer_Label

func _process(delta):
	var time_left = game_handler.game_time.time_left
	timer_label.text = Globals.formatTime(time_left, true)
	
#Restart button
func _on_button_pressed():
	get_tree().reload_current_scene()

#Quit Button
func _on_button_2_pressed():
	get_tree().quit()
