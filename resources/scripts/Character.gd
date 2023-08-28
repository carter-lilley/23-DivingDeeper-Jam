extends player_class

var alive: bool = true
var speed 
var space_state
var step_timer
var ammo: int = 50.0
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

#Referencing variables for head/camera, node objects have to be saved in onready variables
@onready var game_handler = $".."
@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var col: CollisionShape3D = $CollisionShape3D
@onready var gun = $Head/Hands/Gun

@onready var one_shot_part = preload("res://resources/prefabs/burst_part.tscn")

@onready var bullet_prefab = preload("res://resources/prefabs/bullet.tscn")

@onready var sfx_player_dmg = preload("res://resources/audio/sfx/PlayerTakeDamage.wav")
@onready var sfx_player_shoot = preload("res://resources/audio/sfx/ShootFireball.wav")
@onready var sfx_player_step = preload("res://resources/audio/sfx/Step.wav")

#Camera functionality
#Capture the mouse cursor when you enter the game (i.e. make disappear, restrict to window)
func _ready():
	col.shape.height = COLLISION_HEIGHT
	space_state = get_world_3d().direct_space_state
#	step_timer = Globals.createTimer(randf_range(0.1,0.3), true, step_sound, true)
	
func _process(_delta):
	if self.position.y < -20 and alive:	
		alive = false
		game_handler.game_over()
	if CURRENT_HEALTH <= 0 and alive:
		alive = false
		game_handler.game_over()

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
		if Input.is_action_just_pressed("shoot_button") and ammo > 0.0:
			var ray_dir: Vector3 = +camera.global_transform.basis.z
			velocity += ray_dir*5.0
	
	if game_handler.game_state == game_handler.gstates.PLAYING:
		# Handle jumping
		# When player presses space, set velocity.y to the jump velocity. 
		# Conditioned on you being on the floor.
		if Input.is_action_just_pressed("jump_button") and is_on_floor():
			velocity.y = JUMP_VELOCITY
		
		#Handle shooting
		if Input.is_action_just_pressed("shoot_button") and ammo > 0.0:
			ammo -= 1
			shake(.01,.15)
			Globals.oneshot_sound(sfx_player_shoot, self.position, -25.0,randf_range(0.5,2.0))
			var ray_dir: Vector3 = -camera.global_transform.basis.z
			var shoot_ray_col: Dictionary = Globals.fire_ray(space_state, head.global_position, ray_dir, 100,0b00000000000000010101)
			
			var bullet_instance = bullet_prefab.instantiate()
			add_sibling(bullet_instance)
			bullet_instance.global_transform.origin = gun.global_transform.origin
			
			var rayspeed = 8.0
			if shoot_ray_col:
				var ray_distance = (shoot_ray_col.position - self.position).length()
				var ray_unit_dur = ray_distance / rayspeed
				Globals.stween_to(bullet_instance, "position", shoot_ray_col.position, ray_unit_dur, Globals.null_call,Tween.TRANS_BOUNCE, Tween.EASE_OUT, false, false)
				Globals.oneshot_part(one_shot_part,shoot_ray_col.position)
				var col_layer = shoot_ray_col.collider.collision_layer
				if col_layer == 4: 
					shoot_ray_col.collider.call("hit",ray_dir)
			else: 
				var ray_distance = 15.0
				var ray_unit_dur = ray_distance / rayspeed
				Globals.stween_to(bullet_instance, "position", ray_dir*ray_distance, ray_unit_dur,Globals.null_call,Tween.TRANS_CIRC, Tween.EASE_OUT, true, false)
			
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
	else: velocity = velocity.lerp(Vector3(0,0,0),delta*12.0)
	move_and_slide()

# Handle rotation of the mouse (looking around
func _unhandled_input(event):
	if game_handler.game_state == game_handler.gstates.PLAYING:
		if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			head.rotate_y(-event.relative.x * MOUSE_SENS) #rotate up and down (thru the XZ plane)
			camera.rotate_x(-event.relative.y * MOUSE_SENS) #rotate left and right (thru the YZ plane)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60)) #Slowdown rotation

#func step_sound():
#	Globals.oneshot_sound(sfx_player_step, self.position, 310.0, randf_range(0.5,2.0))
#	step_timer = Globals.createTimer(randf_range(0.1,0.3), true, step_sound, true)
	
func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	
#	if pos.y <= -BOB_AMP+.005 and is_on_floor():
#		Globals.oneshot_sound(sfx_player_step, self.position, -20.0)
		
	return pos

# Function to shake the camera.
func shake(intensity: float, duration: float):
	var original_offset = camera.position
	var shake_time = Globals.createTimer(duration, true, Globals.null_call, true)
	while shake_time.time_left > 0.0:
		# Calculate a random offset based on the intensity.
		var random_offset = Vector3(randf() * intensity - intensity / 2, randf() * intensity - intensity / 2,randf() * intensity - intensity / 2)
		# Apply the random offset to the camera's position.
		camera.position = original_offset + random_offset
		await get_tree().process_frame
	shake_time.queue_free()
	camera.position = original_offset

func damage(dmg_dir : Vector3):
	shake(.05,.2)
	velocity += dmg_dir * 8.0
	Globals.oneshot_sound(sfx_player_dmg, self.position, -25.0,randf_range(0.5,2.0))
	CURRENT_HEALTH = CURRENT_HEALTH - 1.0

func _on_hitbox_body_entered(body):
	if body.is_in_group("Enemy"):
		var enemy_pos = body.get_transform().origin
		var dir = self.position - enemy_pos
		damage(dir)
