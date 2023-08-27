extends Control

#Restart button
func _on_button_pressed():
	get_tree().reload_current_scene()

#Quit Button
func _on_button_2_pressed():
	get_tree().quit()
