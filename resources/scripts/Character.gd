extends CharacterBody3D

var speed 
const WALK_SPEED = 5.0
const SPRINT_SPEED = 7.25
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.005

#headbob variables
const BOB_FREQ = 2.0 #Essentially, how often your character takes a 'step' -- Frequency
const BOB_AMP = 0.08 #How high up your camera goes (or how hard/high the bob is) -- Amplitude
var t_bob = 0.0 #Variable to pass to the sin function to tell it how far along we are at any given moment

#fov variables
const BASE_FOV = 75.0 #This can be changed to a variable later, if we want players to set this
const FOV_CHANGE = 1.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 9.8

#Referencing variables for head/camera, node objects have to be saved in onready variables
@onready var head = $Head
@onready var camera = $Head/Camera3D

#Camera functionality
#Capture the mouse cursor when you enter the game (i.e. make disappear, restrict to window)
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

#Handle rotation of the mouse (looking around
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY) #rotate up and down (thru the XZ plane)
		camera.rotate_x(-event.relative.y * SENSITIVITY) #rotate left and right (thru the YZ plane)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60)) #Slowdown rotation

#Movement functionality
#Handle gravity
func _physics_process(delta):
	# Apply gravity -- If the player isnt on the floor, subtract the velocity by gravity * the time between frames (delta).
	if not is_on_floor():
		velocity.y -= gravity * delta

# Handle jumping
	# When player presses space, set velocity.y to the jump velocity. Conditioned on you being on the floor.
	if Input.is_action_just_pressed("jump_button") and is_on_floor():
		velocity.y = JUMP_VELOCITY

#handle sprinting
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED

#handle movement
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	# Takes in vector2 inputs (input_dir) and changes it into vector3 based on where our character is facing (direction)
	var input_dir = Input.get_vector("char_left", "char_right", "char_fwd", "char_back")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		#If the direction input is NOT zero, we multiply our x and z velocity (left right, forward back respectively) by the speed variable
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)

#Head Bob functionality
	t_bob += delta * velocity.length() * float(is_on_floor()) #is_on_floor() converted to a float is 1 or 0, IE, yes or no as to whether youre on the floor or not
	camera.transform.origin = _headbob(t_bob) #lift camera up and down (simulate bobbing)

#FOV
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)

	move_and_slide()

#I am unsure why, but this function MUST go under the move_and_slide() function... I don't grasp why. 
#I guess your head can't bob unless youre moving and sliding around?
func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos

