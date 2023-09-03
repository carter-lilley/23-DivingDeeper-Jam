extends Control

@onready var player_options = $player_options
@onready var stick_response: Panel = $"CenterContainer/VBoxContainer/Stick-Response-Graph"
@onready var stick_panel: Panel = $"CenterContainer/VBoxContainer/Stick-Visualizer"
@onready var center_cont = $CenterContainer

var raw_stick_pos: Vector2=Vector2.ZERO
var processed_stick_pos: Vector2=Vector2.ZERO
var curve_graph_raw_pos: Vector2=Vector2.ZERO
var curve_graph_processed_pos: Vector2=Vector2.ZERO

var curve_points: PackedVector2Array

var panel_size: Vector2=Vector2.ZERO
var padding: float = 15.0

func _draw():
	var screen_center := Vector2(center_cont.size.x/2,center_cont.size.y/2)
	var panel2 :Vector2 = Vector2(screen_center.x,screen_center.y+panel_size.y/2)
	var panel1 :Vector2 = Vector2(screen_center.x,screen_center.y-panel_size.y/2)
	curve_points = draw_curve(panel2, player_options.r_stick_response, padding, panel_size/2, 2.0, Color(.6,.6,.6), 100.0)
	draw_cross(curve_graph_raw_pos, 10.0, 2.0, Color.RED)
	draw_cross(curve_graph_processed_pos, 10.0, 2.0, Color.BLUE)
	
	draw_stick(panel1, padding, 2.0, Color(.6,.6,.6), Color(.1,.1,.1), Color(.3,.3,.3))
	draw_cross(raw_stick_pos+panel1, 10.0, 2.0, Color.RED)
	draw_cross(processed_stick_pos+panel1, 10.0, 2.0, Color.BLUE)

func draw_stick(s_pos : Vector2, s_pad : float, s_width: float, s_main_color: Color,s_inner_color: Color,s_outer_color: Color):
	var main_radius = (min(panel_size.x, panel_size.y) / 2 ) - s_pad
	var dz_lower_rad = remap(player_options.l_stick_deadzone.x,0.0,1.0,0.0,main_radius)
	var dz_upper_rad = remap(player_options.l_stick_deadzone.y,0.0,1.0,0.0,main_radius)
	draw_arc(s_pos, main_radius, 0, 360, 64, s_main_color, s_width)
	draw_circle(s_pos,dz_lower_rad,s_inner_color)
	draw_arc(s_pos, dz_upper_rad, 0, 360, 64, s_outer_color, s_width)

func draw_cross(c_pos : Vector2, c_size: float, c_width: float, c_color: Color):
	draw_line(c_pos - Vector2(c_size, 0), c_pos + Vector2(c_size, 0), c_color, c_width)
	draw_line(c_pos - Vector2(0, c_size), c_pos + Vector2(0, c_size), c_color, c_width)

func draw_curve(crv_pos: Vector2, curve: Curve, crv_pad : float, crv_size: Vector2, crv_width: float, crv_color: Color, res: float):
	# Calculate the number of segments for the curve
	var point_arr = PackedVector2Array()
	for i in range(res):
		var curr_x = i/res
		var curr_y = curve.sample(curr_x)
		var curr_x_remap = remap(curr_x,0,1,-crv_size.x+crv_pad,crv_size.x-crv_pad)
		var curr_y_remap = remap(curr_y,curve.min_value,curve.max_value,crv_size.y-crv_pad,-crv_size.y+crv_pad)
		var i_point = Vector2(curr_x_remap,curr_y_remap) + crv_pos
		point_arr.append_array([i_point])
	# Draw the curve using draw_multiline
	draw_polyline(point_arr, crv_color, crv_width, false)
	return point_arr

func _process(delta):
	panel_size = stick_panel.custom_minimum_size
	var pnl_half = panel_size/2
	
	var raw_stick = Input.get_vector("cam_left", "cam_right", "cam_up", "cam_down")
	raw_stick_pos.x = remap(raw_stick.x,-1,1,-pnl_half.x+padding,pnl_half.x-padding)
	raw_stick_pos.y = remap(raw_stick.y,-1,1,-pnl_half.y+padding,pnl_half.y-padding)
	
	var processed_stick = input_man.get_stick("cam_left", "cam_right", "cam_up", "cam_down", player_options.l_stick_deadzone,player_options.l_stick_response)
	processed_stick_pos.x = remap(processed_stick.x,-1,1,-pnl_half.x+padding,pnl_half.x-padding)
	processed_stick_pos.y = remap(processed_stick.y,-1,1,-pnl_half.x+padding,pnl_half.x-padding)
	
	var curve_domain_raw = remap(raw_stick.length(),0,1,0,curve_points.size()-1)
	curve_graph_raw_pos.x = curve_points[curve_domain_raw].x
	curve_graph_raw_pos.y = curve_points[curve_domain_raw].y

	var curve_domain_remap = remap(processed_stick.length(),0,1,0,curve_points.size()-1)
	curve_graph_processed_pos.x = curve_points[curve_domain_remap].x
	curve_graph_processed_pos.y = curve_points[curve_domain_remap].y
	queue_redraw()
