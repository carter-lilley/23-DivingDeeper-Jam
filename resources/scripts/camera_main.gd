extends orbit_cam_class

func _process(_delta) -> void:
	var input_raw = MultiplayerInput.get_stick(-1, "cam_left", "cam_right", "cam_up", "cam_down")
#	var input_adjusted = MultiplayerInput.response_curve(input_raw,stick_response)
