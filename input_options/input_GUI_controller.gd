extends Control

@onready var player_options = $player_options

@onready var r_stick_response: Panel = $"CenterContainer/HBoxContainer/R-Stick-Module/R-Stick-Response-Graph"
@onready var r_stick_panel: Panel = $"CenterContainer/HBoxContainer/R-Stick-Module/R-Stick-Visualizer"
@onready var l_stick_panel: Panel = $"CenterContainer/HBoxContainer/L-Stick-Module/L-Stick-Visualizer"
@onready var l_stick_response: Panel = $"CenterContainer/HBoxContainer/L-Stick-Module/L-Stick-Response-Graph"
@onready var button_panel: Panel = $"CenterContainer/HBoxContainer/Right-Module/Button-Visualizer"
@onready var d_pad_panel: Panel = $"CenterContainer/HBoxContainer/Left-Module/DPad-Visualizer"
@onready var l_trigger_panel: Panel = $"CenterContainer/HBoxContainer/Left-Module/L-Trigger-Visualizer"
@onready var r_trigger_panel: Panel = $"CenterContainer/HBoxContainer/Right-Module/R-Trigger-Visualizer"

var btn_num = 25
var btn_boolarr = []

var r_stick_arr : PackedVector2Array = [Vector2(0, 0), Vector2(0, 0)]
var r_stick_response_arr : PackedVector2Array = [Vector2(0, 0), Vector2(0, 0)]
var r_curve_points: PackedVector2Array

var l_stick_arr : PackedVector2Array = [Vector2(0, 0), Vector2(0, 0)]
var l_stick_response_arr : PackedVector2Array = [Vector2(0, 0), Vector2(0, 0)]
var l_curve_points: PackedVector2Array

var panel_size: Vector2=Vector2.ZERO
var padding: float = 15.0

func _ready():
	btn_boolarr.resize(btn_num)
	btn_boolarr.fill(false)

func _draw():
	r_stick_module()
	l_stick_module()
	draw_face_buttons(button_panel, padding, 2.0, Color(.6,.6,.6))
	draw_dpad(d_pad_panel, padding, 2.0, Color(.6,.6,.6))
	
	draw_trigger(l_trigger_panel,2.0,Color(.6,.6,.6),9)
	
	draw_trigger(r_trigger_panel,2.0,Color(.6,.6,.6),10)

func l_stick_module():
	#left curve graph
	l_curve_points = draw_curve(l_stick_response, player_options.l_stick_response, padding, 2.0, Color(.6,.6,.6), 100.0)
	draw_cross(l_stick_response_arr[0], 10.0, 2.0, Color.RED)
	draw_cross(l_stick_response_arr[1], 10.0, 2.0, Color.BLUE)
	#right & left deadzones
	draw_stick(l_stick_panel, padding, 2.0, Color(.6,.6,.6), Color(.1,.1,.1), Color(.3,.3,.3),true)
	#left stick positions
	var l_cross_offsets = l_stick_panel.global_position + l_stick_panel.custom_minimum_size/2
	draw_cross(l_stick_arr[0]+l_cross_offsets, 10.0, 2.0, Color.RED)
	draw_cross(l_stick_arr[1]+l_cross_offsets, 10.0, 2.0, Color.BLUE)

func r_stick_module():
	#right curve graph
	r_curve_points = draw_curve(r_stick_response, player_options.r_stick_response, padding, 2.0, Color(.6,.6,.6), 100.0)
	draw_cross(r_stick_response_arr[0], 10.0, 2.0, Color.RED)
	draw_cross(r_stick_response_arr[1], 10.0, 2.0, Color.BLUE)
	
	draw_stick(r_stick_panel, padding, 2.0, Color(.6,.6,.6), Color(.1,.1,.1), Color(.3,.3,.3),false)
	#right stick positions
	var r_cross_offsets = r_stick_panel.global_position + r_stick_panel.custom_minimum_size/2
	draw_cross(r_stick_arr[0]+r_cross_offsets, 10.0, 2.0, Color.RED)
	draw_cross(r_stick_arr[1]+r_cross_offsets, 10.0, 2.0, Color.BLUE)

func draw_trigger(trg_panel : Panel, trg_width: float, trg_color: Color, bumperbtn:int):
	var panel_size = trg_panel.custom_minimum_size
	panel_size.y = panel_size.y/2
	var panel_pos = trg_panel.global_position
	var bumper_pos = panel_pos
	bumper_pos.y += panel_size.y
	var trigger_rect = Rect2(panel_pos, panel_size)
	var bumper_rect = Rect2(bumper_pos, panel_size)
	#outline
	draw_rect(trigger_rect, trg_color, false, trg_width)
	#bumper
	if btn_boolarr[bumperbtn]:
		draw_rect(bumper_rect, trg_color, true, trg_width)
	else: 
		draw_rect(bumper_rect, trg_color, false, trg_width)

func draw_dpad(chv_panel : Panel, chv_pad : float, chv_width: float, chv_color: Color):
	var chv_radius = chv_panel.custom_minimum_size.x/8
	chv_pad += chv_radius
	var panel_size = chv_panel.custom_minimum_size/2
	var panel_pos = chv_panel.global_position + panel_size
	
	# Calculate positions for the four buttons
	var button_positions = [
		Vector2(0, -panel_size.y+chv_pad),  # Up button
		Vector2(0, panel_size.y-chv_pad),   # Down button
		Vector2(-panel_size.x+chv_pad, 0),  # Left button
		Vector2(+panel_size.x-chv_pad, 0)  # Right button
	]

	# Draw the four buttons as circles
	for i in button_positions.size():
		var orientation = i  # Change this multiplier as needed
		match i:
			0: orientation =i-2
			1: orientation =i-1
			2: orientation =i-1
			3: orientation =i
		var btn_num = i+11
		if btn_boolarr[btn_num]:
			draw_chevron(button_positions[i]+panel_pos, chv_radius+8.0, chv_width, chv_color, orientation,true)
		else:
			draw_chevron(button_positions[i]+panel_pos, chv_radius+8.0, chv_width, chv_color, orientation,false)

func draw_face_buttons(btn_panel : Panel, btn_pad : float, btn_width: float, btn_color: Color):
	var btn_radius = btn_panel.custom_minimum_size.x/10
	btn_pad += btn_radius
	var panel_size = btn_panel.custom_minimum_size/2
	var panel_pos = btn_panel.global_position + panel_size
	
	# Calculate positions for the four buttons
	var button_positions = [
		Vector2(0, panel_size.y-btn_pad),
		Vector2(+panel_size.x-btn_pad, 0),
		Vector2(-panel_size.x+btn_pad, 0),  # Left button
		Vector2(0, -panel_size.y+btn_pad)  # Up button
	]

	# Draw the four buttons as circles
	for i in button_positions.size():
		var _pos = button_positions[i]+panel_pos
		if btn_boolarr[i]:
			draw_circle(_pos, btn_radius, btn_color)
		else:
			draw_arc(_pos, btn_radius, 0, 360, 64, btn_color, btn_width)
	
func draw_stick(s_panel : Panel, s_pad : float, s_width: float, s_main_color: Color,s_inner_color: Color,s_outer_color: Color, left: bool):
	var panel_size = s_panel.custom_minimum_size
	var panel_pos = s_panel.global_position + panel_size/2
	var main_radius = (min(panel_size.x, panel_size.y) / 2 ) - s_pad
	
	var dz_lower_rad
	var dz_upper_rad
	if left:
		dz_lower_rad = remap(player_options.l_stick_deadzone.x,0.0,1.0,0.0,main_radius)
		dz_upper_rad = remap(player_options.l_stick_deadzone.y,0.0,1.0,0.0,main_radius)
	else:
		dz_lower_rad = remap(player_options.r_stick_deadzone.x,0.0,1.0,0.0,main_radius)
		dz_upper_rad = remap(player_options.r_stick_deadzone.y,0.0,1.0,0.0,main_radius)
		
	draw_arc(panel_pos, main_radius, 0, 360, 64, s_main_color, s_width)
	draw_circle(panel_pos,dz_lower_rad,s_inner_color)
	draw_arc(panel_pos, dz_upper_rad, 0, 360, 64, s_outer_color, s_width)

#primitives:

func draw_chevron(chv_pos : Vector2, chv_size: float, chv_width: float, chv_color: Color, orientation: int, filled: bool):
	chv_size = chv_size/2
	var chevron_points = PackedVector2Array()
	var base_points = [
		Vector2(-chv_size, chv_size),
		Vector2(chv_size, chv_size),
		Vector2(chv_size, 0),
		Vector2(0, -chv_size),
		Vector2(-chv_size, 0),
		Vector2(-chv_size, chv_size)
	]
	for point in base_points:
		# Rotate the point by the specified orientation
		var rotated_point = point.rotated(orientation * PI / 2)
		# Offset the rotated point by the position (chv_pos)
		chevron_points.append(rotated_point + chv_pos)
	if !filled:
		draw_polyline(chevron_points,chv_color,chv_width)
	else:
		draw_colored_polygon(chevron_points, chv_color)

func draw_cross(c_pos : Vector2, c_size: float, c_width: float, c_color: Color):
	draw_line(c_pos - Vector2(c_size, 0), c_pos + Vector2(c_size, 0), c_color, c_width)
	draw_line(c_pos - Vector2(0, c_size), c_pos + Vector2(0, c_size), c_color, c_width)

func draw_curve(crv_panel: Panel, curve: Curve, crv_pad : float, crv_width: float, crv_color: Color, res: float):
	var panel_size = crv_panel.custom_minimum_size/2
	var panel_pos = crv_panel.global_position + panel_size
	# Calculate the number of segments for the curve
	var point_arr = PackedVector2Array()
	for i in range(res):
		var curr_x = i/res
		var curr_y = curve.sample(curr_x)
		var curr_x_remap = remap(curr_x,0,1,-panel_size.x+crv_pad,panel_size.x-crv_pad)
		var curr_y_remap = remap(curr_y,curve.min_value,curve.max_value,panel_size.y-crv_pad,-panel_size.y+crv_pad)
		var i_point = Vector2(curr_x_remap,curr_y_remap) + panel_pos
		point_arr.append_array([i_point])
	# Draw the curve using draw_multiline
	draw_polyline(point_arr, crv_color, crv_width, false)
	return point_arr

#positional updates:
func gui_monitor_trigger(gui_trigger_panel: Panel, raw_trigger:float, prc_trigger:float):
	var position_array : PackedVector2Array = [Vector2(0, 0), Vector2(0, 0)]
	var panel_size = gui_trigger_panel.custom_minimum_size/2
	position_array[0].x = panel_size
	return position_array
	
func gui_monitor_stick(gui_stick_panel: Panel, raw_stick:Vector2, processed_stick:Vector2):
	var position_array : PackedVector2Array = [Vector2(0, 0), Vector2(0, 0)]
	var panel_size = gui_stick_panel.custom_minimum_size/2
	position_array[0].x = remap(raw_stick.x,-1,1,-panel_size.x+padding,panel_size.x-padding)
	position_array[0].y = remap(raw_stick.y,-1,1,-panel_size.y+padding,panel_size.y-padding)
	position_array[1].x = remap(processed_stick.x,-1,1,-panel_size.x+padding,panel_size.x-padding)
	position_array[1].y = remap(processed_stick.y,-1,1,-panel_size.x+padding,panel_size.x-padding)
	return position_array

func gui_monitor_response(gui_response_panel: Panel, curve_points : PackedVector2Array, raw_stick:Vector2, processed_stick:Vector2):
	var position_array : PackedVector2Array = [Vector2(0, 0), Vector2(0, 0)]
	var panel_size = gui_response_panel.custom_minimum_size/2
	var curve_domain_raw = remap(raw_stick.length(),0,1,0,curve_points.size()-1)
	position_array[0].x = curve_points[curve_domain_raw].x
	position_array[0].y = curve_points[curve_domain_raw].y
	var curve_domain_remap = remap(processed_stick.length(),0,1,0,curve_points.size()-1)
	position_array[1].x = curve_points[curve_domain_remap].x
	position_array[1].y = curve_points[curve_domain_remap].y
	return position_array

func _process(delta):
	var joy_num = 0
	var actn_strng = "joy" + str(joy_num) + "_axis"
	
	var l_raw_trigger = Input.get_action_strength("joy0_axis+4")
	var l_proc_trigger = input_man.prc_trigger("joy0_axis+4", player_options.l_trigger_deadzone,player_options.l_trigger_response)
	
	var r_raw_trigger = Input.get_action_strength("joy0_axis+5")
	var r_proc_trigger = input_man.prc_trigger("joy0_axis+5", player_options.r_trigger_deadzone,player_options.r_trigger_response)
	
	var r_raw_stick = Input.get_vector("joy0_axis-2", "joy0_axis+2", "joy0_axis-3", "joy0_axis+3")
	var r_processed_stick = input_man.prc_stick("joy0_axis-2", "joy0_axis+2", "joy0_axis-3", "joy0_axis+3", player_options.r_stick_deadzone,player_options.r_stick_response)
	
	var l_raw_stick = Input.get_vector("joy0_axis-0", "joy0_axis+0", "joy0_axis-1", "joy0_axis+1")
	var l_processed_stick = input_man.prc_stick("joy0_axis-0", "joy0_axis+0", "joy0_axis-1", "joy0_axis+1", player_options.l_stick_deadzone,player_options.l_stick_response)
	
	l_stick_arr = gui_monitor_stick(l_stick_panel,l_raw_stick,l_processed_stick)
	r_stick_arr = gui_monitor_stick(r_stick_panel,r_raw_stick,r_processed_stick)
	
	r_stick_response_arr = gui_monitor_response(r_stick_response, r_curve_points,r_raw_stick,r_processed_stick)
	l_stick_response_arr = gui_monitor_response(l_stick_response, l_curve_points,l_raw_stick,l_processed_stick)
	
	# face buttons
	if Input.is_action_pressed("joy0_btn0"):
		btn_boolarr[0] = true
	else: btn_boolarr[0] = false
		
	if Input.is_action_pressed("joy0_btn1"):
		btn_boolarr[1] = true
	else: btn_boolarr[1] = false
	
	if Input.is_action_pressed("joy0_btn2"):
		btn_boolarr[2] = true
	else: btn_boolarr[2] = false
	
	if Input.is_action_pressed("joy0_btn3"):
		btn_boolarr[3] = true
	else: btn_boolarr[3] = false
	
	# bumpers 
	if Input.is_action_pressed("joy0_btn9"):
		btn_boolarr[9] = true
	else: btn_boolarr[9] = false
	
	if Input.is_action_pressed("joy0_btn10"):
		btn_boolarr[10] = true
	else: btn_boolarr[10] = false
	
	#dpad
	if Input.is_action_pressed("joy0_btn11"):
		btn_boolarr[11] = true
	else: btn_boolarr[11] = false
	
	if Input.is_action_pressed("joy0_btn12"):
		btn_boolarr[12] = true
	else: btn_boolarr[12] = false
	
	if Input.is_action_pressed("joy0_btn13"):
		btn_boolarr[13] = true
	else: btn_boolarr[13] = false
	
	if Input.is_action_pressed("joy0_btn14"):
		btn_boolarr[14] = true
	else: btn_boolarr[14] = false
	
	queue_redraw()
