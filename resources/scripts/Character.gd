extends player_class

var speed 
var space_state
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

#Referencing variables for head/camera, node objects have to be saved in onready variables
@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var col: CollisionShape3D = $CollisionShape3D
@onready var healthbar = $"../Control/ColorRect"
@onready var speaker = $AudioStreamPlayer

@onready var shoot_noise = AudioStreamWAV("res://resources/audio/ShootFireball.wav")
@onready var player_take_damage = AudioStreamWAV("res://resources/audio/ShootFireball.wav")
@onready var death_noise = AudioStreamWAV("res://resources/audio/ShootFireball.wav")
@onready var walking_noise = AudioStreamWAV("res://resources/audio/ShootFireball.wav")

#Camera functionality
#Capture the mouse cursor when you enter the game (i.e. make disappear, restrict to window)
func _ready():
	col.shape.height = COLLISION_HEIGHT
	space_state = get_world_3d().direct_space_state
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	# Apply gravity If the player isnt on the floor, 
	# subtract the velocity by gravity * the time between frames (delta).
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jumping
	# When player presses space, set velocity.y to the jump velocity. 
	# Conditioned on you being on the floor.
	if Input.is_action_just_pressed("jump_button") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_just_pressed("start_button"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		set_process_input(false)
	
	if Input.is_action_just_pressed("select_button"):
		get_tree().reload_current_scene()

#Handle shooting
	if Input.is_action_just_pressed("shoot_button"):
		var shoot_ray_col: Dictionary = Globals.fire_ray(space_state, head.global_position, -camera.global_transform.basis.z, 100,0b00000000000000010101)
		play_noise(shoot_noise)
		if shoot_ray_col:
			var col_layer = shoot_ray_col.collider.collision_layer
			print("Collision layer is " + str(col_layer))
			if col_layer == 4: 
				shoot_ray_col.collider.call("hit")
			DrawLine3d.DrawCube(shoot_ray_col.position, 0.05, Color(1, 0, 0))

	if Input.is_action_pressed("crouch_button"):
		speed = CROUCH_SPEED
		var new_head_height: Vector3 = Vector3(0,HEAD_HEIGHT/2,0)
		head.position = head.position.lerp(new_head_height, delta * 5.0)
		col.shape.height = lerp(col.shape.height,COLLISION_HEIGHT/2,delta * 5.0)
	else:
		var new_head_height: Vector3 = Vector3(0,HEAD_HEIGHT,0)
		head.position = head.position.lerp(new_head_height, delta * 5.0)
		col.shape.height = lerp(col.shape.height,COLLISION_HEIGHT,delta * 5.0)
		if Input.is_action_pressed("sprint_button"):
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

	# Head Bob functionality
	t_bob += delta * velocity.length() * float(is_on_floor()) #is_on_floor() converted to a float is 1 or 0, IE, yes or no as to whether youre on the floor or not
	camera.transform.origin = _headbob(t_bob) #lift camera up and down (simulate bobbing)

	# FOV
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)

	move_and_slide()

# Handle rotation of the mouse (looking around
func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		head.rotate_y(-event.relative.x * MOUSE_SENS) #rotate up and down (thru the XZ plane)
		camera.rotate_x(-event.relative.y * MOUSE_SENS) #rotate left and right (thru the YZ plane)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60)) #Slowdown rotation

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos

#Handle Player Damage
func _on_area_3d_area_entered(area):
	print(area)
	if area.is_in_group("Enemy"):
		CURRENT_HEALTH = CURRENT_HEALTH - 1.0
		print(CURRENT_HEALTH)
		_update_UI_healthbar()
	

func _playerDeath(CURRENT_HEALTH):
	if CURRENT_HEALTH == 0:
		queue_free()
		

#Handle UI Updating 
func _update_UI_healthbar():
	healthbar.scale.x = CURRENT_HEALTH / MAX_HEALTH
	
func play_noise(sfx):
	speaker.stream = sfx
