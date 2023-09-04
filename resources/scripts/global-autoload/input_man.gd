extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	# Check if joypads are already connected at the beginning
	check_connected_joypads()
	# Connect the signal for joystick connection events
#	button.button_down.connect(_on_button_down)
	Input.connect("joy_connection_changed", _on_joy_connection_changed)

func _on_joy_connection_changed(device_id, connected):
	if connected:
		generate_base_actions(device_id)
		print("Joypad", device_id, "is connected.")
		# Do something when a joypad is connected
	else:
		print("Joypad", device_id, "is disconnected.")
		# Do something when a joypad is disconnected

func check_connected_joypads():
	var joypads = Input.get_connected_joypads()
	for joy_id in joypads:
		generate_base_actions(joy_id)
		print("Joypad", joy_id, "is already connected.")
		# Do something when a joypad is already connected at the beginning

func generate_base_actions(joy_id):
	var btn_num = 25
	for button_index in range(btn_num):
		var btn_action_name = "joy" + str(joy_id) + "_btn" + str(button_index)
		InputMap.add_action(btn_action_name,0.0)
		var event = InputEventJoypadButton.new()
		event.button_index = button_index
		InputMap.action_add_event(btn_action_name, event)
	var axis_num = 10
	for axis_index in range(axis_num):
		var axis_action_name = "joy" + str(joy_id) + "_axis"
		var axis_pos_action_name = axis_action_name + "+" + str(axis_index)
		var axis_neg_action_name = axis_action_name + "-" + str(axis_index)
		InputMap.add_action(axis_pos_action_name, 0.0)
		InputMap.add_action(axis_neg_action_name, 0.0)
		
		var event_pos = InputEventJoypadMotion.new()
		event_pos.axis = axis_index
		event_pos.axis_value = 1.0
		InputMap.action_add_event(axis_pos_action_name, event_pos)
		
		var event_neg = InputEventJoypadMotion.new()
		event_neg.axis = axis_index
		event_neg.axis_value = -1.0
		InputMap.action_add_event(axis_neg_action_name, event_neg)
		
func _input(event):
	var actions = InputMap.get_actions()
	for action_name in actions:
		if Input.is_action_just_pressed(action_name):
			print(action_name)	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	pass

#INPUT UTILS-------------------------------------------------------

func prc_stick(negative_x: StringName, positive_x: StringName, negative_y: StringName, positive_y: StringName, deadzone_range:Vector2, response_curve: Curve) -> Vector2:
	var _vec = Input.get_vector(negative_x, positive_x, negative_y, positive_y)
	var _vec_dz = stick_deadzone(_vec,deadzone_range)
	var _vec_response = response_curve(_vec_dz,response_curve)
	return _vec_response

func prc_trigger(axis: StringName,deadzone_range:Vector2,response_curve: Curve) -> float:
	var raw_trigger = Input.get_action_strength(axis)
	var dz_trigger = trigger_deadzone(raw_trigger,deadzone_range)
	var response_trigger = float_response_curve(dz_trigger,response_curve)
	return dz_trigger
	
func stick_deadzone(_input:Vector2, dz_range:Vector2):
	var input_mag = _input.length()
	var remapped_range
	if input_mag >= dz_range.x:
		remapped_range = remap(input_mag, dz_range.x, dz_range.y, dz_range.x, 1)
	else: remapped_range = Vector2.ZERO
	remapped_range = remapped_range * _input.normalized()
	return remapped_range

func trigger_deadzone(_input: float, dz_range: Vector2):
	var remapped_value
	if _input >= dz_range.x:
		remapped_value = remap(_input, dz_range.x, dz_range.y, 0.0, 1.0)
	else:
		remapped_value = 0.0
	return remapped_value

func response_curve(input: Vector2, curve: Curve) -> Vector2:
	var dir = input.normalized()
	var length = input.length()
	var adjusted = curve.sample(length)
	var value = dir * adjusted
	return value

func float_response_curve(input: float, curve: Curve) -> float:
	var response = curve.sample(input)
	return response

#depreciated, get_vector already has a circular deadzone
func sqr2cirlce(input: Vector2) -> Vector2:
	if input.length() != 0:
		var x = sign(input.x)
		var y = sign(input.y)
		var strength
		input = Vector2(abs(input.x),abs(input.y))
		if input.x > input.y:
			strength = input.x
		else:
			strength = input.y
		input += input.normalized() * (strength-input.length())
		input *= Vector2(x,y)
	return input
