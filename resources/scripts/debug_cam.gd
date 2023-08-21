extends Camera3D

# Camera movement speed
@export var speed = 10.0
@export var pos_smooth = 5

# Sensitivity for mouse movement
var mouse_sensitivity = 0.1

# Variables to track camera rotation
var camera_rot = Vector2()

var device_id: int = -1
var input_raw: Vector2 = Vector2.ZERO
var pos : Vector3 = Vector3.ZERO

#func _ready():
	# Hide the mouse cursor and capture input
#	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
#	set_process_input(true)

func _process(delta):
	if device_id == -1:
		input_raw = MultiplayerInput.key_stick("char_left", "char_right", "char_fwd", "char_back")
	else: input_raw = MultiplayerInput.get_stick(device_id, "char_left", "char_right", "char_fwd", "char_back")
	print(input_raw)
	var vec3 : Vector3 = Vector3.ZERO
	if input_raw:
		vec3 = Globals.vec3_vec2(input_raw, 1, 0)
		pos += (vec3*speed*delta)
	self.global_transform.origin = self.global_transform.origin.lerp(pos,delta*pos_smooth)

#this bit of code effectively passes any input from any keymapped device 
#to our input script; so both keyboard and all controllers do the same thing
func _input(event):
	device_id = event.get_device()
	if event is InputEventKey:
		device_id = -1
	
	# Process mouse input for camera rotation
#	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
#		camera_rot -= event.relative * mouse_sensitivity
#		camera_rot.y = clamp(camera_rot.y, -90, 90)
#		rotation_degrees.x = camera_rot.y
#		rotation_degrees.y = camera_rot.x

	# Process keyboard input for movement
#	if event is InputEventKey:
#		var move_dir = Vector3()
#		move_dir = move_dir.normalized()
#		transform.origin += move_dir * speed * get_process_delta_time()
