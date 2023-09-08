extends Node

var game_ctrl = []
	
# Called when the node enters the scene tree for the first time.
func _ready():
	key_gen_base_actions()
	mouse_gen_actions()
	# Check if joypads are already connected at the beginning
	check_connected_joypads()
	# Connect the signal for joystick connection events
	Input.connect("joy_connection_changed", _on_joy_connection_changed)
	#generate the base game action dictionary
	for action in game_actns:
		var key = InputEventKey.new()
		var joy = InputEventJoypadButton.new()
		var _name = action["name"]

		var key_actn = action["key"]
		var joy_actn = action["joy"]
		
		match typeof(key_actn):
			TYPE_INT:
				key.set_keycode(action["key"])
				InputMap.add_action(_name, 0.0)
				InputMap.action_add_event(_name, key)
			TYPE_ARRAY:
				four_axis_gen(action["key"],action["joy"],_name)
#			TYPE_VECTOR2:
		match typeof(joy_actn):
			TYPE_INT:
				joy.button_index = action["joy"]
				InputMap.add_action(_name, 0.0)
				InputMap.action_add_event(_name, key)
#		joy.button_index = action["joy"]
#		InputMap.action_add_event(_name, joy)

func _on_joy_connection_changed(device_id, connected):
	if connected:
		joy_gen_base_actions(device_id)
		print("Joypad", device_id, "is connected.")
		# Do something when a joypad is connected
	else:
		print("Joypad", device_id, "is disconnected.")
		# Do something when a joypad is disconnected

func check_connected_joypads():
	var joypads = Input.get_connected_joypads()
	for joy_id in joypads:
		joy_gen_base_actions(joy_id)
		print("Joypad", joy_id, "is already connected.")
		# Do something when a joypad is already connected at the beginning

func four_axis_gen(key_axis_array: Array, joy_axis_array: Array,_name: String):
	InputMap.add_action(_name + "_LEFT", 0.0)
	InputMap.add_action(_name + "_RIGHT", 0.0)
	InputMap.add_action(_name + "_UP", 0.0)
	InputMap.add_action(_name + "_DOWN", 0.0)
	var joy_axis_x = joy_axis_array[0]
	var joy_axis_y = joy_axis_array[1]
	var key_axis_x = key_axis_array[0]
	var key_axis_y = key_axis_array[1]
	#make joy actions
	var joy_x_axis = abs(joy_axis_x.x)
	var joy_y_axis = abs(joy_axis_y.x)
	var joy_event_left = InputEventJoypadMotion.new()
	joy_event_left.axis = joy_x_axis
	joy_event_left.axis_value = -1.0
	InputMap.action_add_event(_name + "_LEFT", joy_event_left)
	var joy_event_right = InputEventJoypadMotion.new()
	joy_event_right.axis = joy_x_axis
	joy_event_right.axis_value = 1.0
	InputMap.action_add_event(_name + "_RIGHT", joy_event_right)
	var joy_event_up = InputEventJoypadMotion.new()
	joy_event_up.axis = joy_y_axis
	joy_event_up.axis_value = -1.0
	InputMap.action_add_event(_name + "_UP", joy_event_up)
	var joy_event_down = InputEventJoypadMotion.new()
	joy_event_down.axis = joy_y_axis
	joy_event_down.axis_value = 1.0
	InputMap.action_add_event(_name + "_DOWN", joy_event_down)
	
	#make key actions
	var key_event_left = InputEventKey.new()
	key_event_left.set_keycode(key_axis_x.x)
	print(key_axis_x.x)
	InputMap.action_add_event(_name + "_LEFT", key_event_left)
	var key_event_right = InputEventKey.new()
	key_event_right.set_keycode(key_axis_x.y)
	print(key_axis_x.y)
	InputMap.action_add_event(_name + "_RIGHT", key_event_right)
	var key_event_up = InputEventKey.new()
	key_event_up.set_keycode(key_axis_y.y)
	InputMap.action_add_event(_name + "_UP", key_event_up)
	var key_event_down = InputEventKey.new()
	key_event_down.set_keycode(key_axis_y.x)
	InputMap.action_add_event(_name + "_DOWN", key_event_down)
	
func key_gen_base_actions():
	for keycode in range(32, 126+1):  # Iterate through keycodes for all standard letters (94)
		var key_action_name = "key_" + str(keycode)  # Create a unique action name
		InputMap.add_action(key_action_name, 0.0)  # Add the action
		var event = InputEventKey.new()  # Create a key event
		event.set_keycode(keycode)  # Set the keycode
		InputMap.action_add_event(key_action_name, event)  # Add the event to the action
	for keycode in range(4194305, 4194343+1):  # Iterate through keycodes for all standard mods (38)
		var key_action_name = "key_" + str(keycode)  
		InputMap.add_action(key_action_name, 0.0)  
		var event = InputEventKey.new() 
		event.set_keycode(keycode) 
		InputMap.action_add_event(key_action_name, event)
	#132 key inputs

func mouse_gen_actions():
	var m_btn_num = 3
	for mbutton_index in range(m_btn_num+1):
		var m_action_name = "mbtn_" + str(mbutton_index)
		print(m_action_name)
		InputMap.add_action(m_action_name,0.0)
		var m_event = InputEventMouseButton.new()
		m_event.button_index = mbutton_index
		InputMap.action_add_event(m_action_name, m_event)

func joy_gen_base_actions(joy_id):
	var btn_num = 16
	for button_index in range(btn_num):
		var btn_action_name = "joy" + str(joy_id) + "_btn_" + str(button_index)
		InputMap.add_action(btn_action_name,0.0)
		var event = InputEventJoypadButton.new()
		event.button_index = button_index
		InputMap.action_add_event(btn_action_name, event)
	var axis_num = 6
	for axis_index in range(axis_num):
		var axis_action_name = "joy" + str(joy_id) + "_axis_"
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
#func _process(delta):
#	var test = Input.get_vector("MOVE_LEFT", "MOVE_RIGHT", "MOVE_UP", "MOVE_DOWN")
#	var actions = InputMap.get_actions()
#	print(actions)

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
	return response_trigger
	
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
		remapped_value = remap(_input, dz_range.x, dz_range.y, dz_range.x, 1.0)
	else:
		remapped_value = 0.0
	remapped_value = clamp(remapped_value,0.0,1.0)
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

var game_actns = [
	{"name":"MOVE" , "key":[Vector2(65,68),Vector2(83,87)], "joy":[Vector2(-0,0),Vector2(-1,1)] }, #vector array for all axis'
	{"name":"CAM" , "key":-1 , "joy":[Vector2(-3,3),Vector2(-2,2)] },
	{"name":"JUMP" , "key":32 , "joy":0 },
	{"name":"SHOOT" , "key":0 , "joy":Vector2(-5,1) }, #range, axis num and range
	{"name":"CROUCH" , "key":4194326 , "joy":1 },
	{"name":"SPRINT" , "key":4194325 , "joy":7 },
	{"name":"PAUSE" , "key":4194305 , "joy":6 }
]
