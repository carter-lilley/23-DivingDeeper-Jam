extends Camera3D

# Camera movement speed
@export var speed = 10.0
@export var pos_smooth = 5

# Sensitivity for mouse movement
@export var mouse_sensitivity = 0.1
@export var stick_sensitivity = 75.0
@export var cam_smooth = 5

# internal variables to track camera rotation and position
var tar_rot: Vector3 = Vector3.ZERO
var tar_pos : Vector3 = Vector3.ZERO

#internal variables to monitor inputs
var device_id: int = -1
var move_input: Vector2 = Vector2.ZERO
var cam_input: Vector2 = Vector2.ZERO

func _ready():
	# Hide the mouse cursor and capture input
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	set_process_input(true)

func _process(delta):
	if device_id == -1:
		move_input = MultiplayerInput.key_stick("char_left", "char_right", "char_fwd", "char_back")
	else: 
		cam_input = MultiplayerInput.get_stick(device_id, "cam_left", "cam_right", "cam_up", "cam_down")
		move_input = MultiplayerInput.get_stick(device_id, "char_left", "char_right", "char_fwd", "char_back")
	
	if move_input:
		var move_vec : Vector3 = Globals.vec3_vec2(move_input, 1, 0)
		move_vec = move_vec.rotated(Vector3.UP, rotation.y)
		move_vec = move_vec.normalized()
		tar_pos += move_vec*speed*delta
	
	if MultiplayerInput.is_action_pressed(device_id,"jump_button"):
		var upvec: Vector3 = Vector3(0,1,0)
		tar_pos += upvec*speed*delta
	
	if MultiplayerInput.is_action_pressed(device_id,"crouch_button"):
		var downvec: Vector3 = Vector3(0,-1,0)
		tar_pos += downvec*speed*delta
	
	if MultiplayerInput.is_action_just_pressed(device_id,"pause_button"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		set_process_input(false)
	
	if cam_input:
		var remap_vec : Vector2 = Vector2(cam_input.y,cam_input.x)
		var cam_vec : Vector3 = Globals.vec3_vec2(remap_vec, 2, 0)
		tar_rot -= cam_vec*stick_sensitivity*delta

	tar_rot.x = clamp(tar_rot.x, -90, 90)
	tar_rot.y = Globals.normalize_rot_deg(tar_rot.y)
	
	global_transform.origin = global_transform.origin.lerp(tar_pos,delta*pos_smooth)
	rotation.y = lerp_angle(rotation.y, deg_to_rad(tar_rot.y), delta * cam_smooth)
	rotation.x = lerp_angle(rotation.x, deg_to_rad(tar_rot.x), delta * cam_smooth)

#this bit of code effectively passes any input from any keymapped device 
#to our input script; so both kb&m and controllers do the same thing
func _input(event):
	device_id = event.get_device()
	if event is InputEventKey:
		device_id = -1
	# Process mouse input for camera rotation
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		device_id = -1
		var remap_vec : Vector2 = Vector2(event.relative.y,event.relative.x)
		var cam_vec : Vector3 = Globals.vec3_vec2(remap_vec, 2, 0)
		tar_rot -= cam_vec * mouse_sensitivity
