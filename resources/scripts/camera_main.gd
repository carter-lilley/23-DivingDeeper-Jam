extends orbit_cam_class

var input_raw
var input_adj

func _process(_delta) -> void:
	input_raw = MultiplayerInput.get_stick(0, "cam_left", "cam_right", "cam_up", "cam_down")
	input_adj = MultiplayerInput.response_curve(input_raw,stick_response)
