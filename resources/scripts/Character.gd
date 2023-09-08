extends player_class

@export var cam_stick_curve: Curve
# internal variables to track camera rotation and position
var tar_rot: Vector3 = Vector3.ZERO

var alive: bool = true
var curr_speed: float = 0.0 
var space_state
var ammo: int = 50.0

#Referencing variables for head/camera, node objects have to be saved in onready variables
@onready var game_handler = $".."
@onready var player_options = $"../player_options"
@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var col: CollisionShape3D = $CollisionShape3D
@onready var gun = $Head/Hands/Gun

#Camera functionality
#Capture the mouse cursor when you enter the game (i.e. make disappear, restrict to window)
func _ready():
	col.shape.height = COLLISION_HEIGHT
	space_state = get_world_3d().direct_space_state
	
func _process(delta):
	var floor = game_handler.curr_stage_height - game_handler.stage_offset
	if self.position.y < floor and alive:	
		alive = false
		game_handler.game_over()
	if CURRENT_HEALTH <= 0 and alive:
		alive = false
		game_handler.game_over()
			
		# Head Bob functionality
		t_bob += delta * velocity.length() * float(is_on_floor()) #is_on_floor() converted to a float is 1 or 0, IE, yes or no as to whether youre on the floor or not 
		camera.transform.origin = _headbob(t_bob) #lift camera up and down (simulate bobbing)
			
		# FOV
		var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
		var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
		camera.fov = lerp(camera.fov, target_fov, delta * 8.0)

	tar_rot.x = clamp(tar_rot.x, -60, 60)
	tar_rot.y = Globals.normalize_rot_deg(tar_rot.y)
	head.rotation.y = lerp_angle(head.rotation.y, deg_to_rad(tar_rot.y), delta * CAM_ACCEL)
	camera.rotation.x = lerp_angle(camera.rotation.x, deg_to_rad(tar_rot.x), delta * CAM_ACCEL)
	
func _physics_process(delta):
	if !is_on_floor():
		velocity.y -= game_handler.gravity * delta

	if game_handler.game_state == game_handler.gstates.PLAYING:
		if Input.is_action_just_pressed("JUMP") and is_on_floor():
			velocity.y = JUMP_VELOCITY
		
		if Input.is_action_just_pressed("SHOOT") and ammo > 0.0:
			if !is_on_floor():
				var ray_dir: Vector3 = +camera.global_transform.basis.z
				velocity += ray_dir*3.75
			ammo -= 1
			shake(25,.5)
			Globals.oneshot_sound(Preloads.sfx_player_shoot, self.position, 2.0,randf_range(0.5,2.0))
			
			var ray_dir: Vector3 = -camera.global_transform.basis.z
			var shoot_ray_col: Dictionary = Globals.fire_ray(space_state, head.global_position, ray_dir, 100,0b00000000000000010101)
			
			var bullet_instance = Preloads.pre_player_bullet.instantiate()
			add_sibling(bullet_instance)
			bullet_instance.global_transform.origin = gun.global_transform.origin
			
			var rayspeed = 8.0
			if shoot_ray_col:
				var ray_distance = (shoot_ray_col.position - self.position).length()
				var ray_unit_dur = ray_distance / rayspeed
				var col_layer = shoot_ray_col.collider.collision_layer
				if col_layer == 4: 
					Globals.oneshot_part(Preloads.pre_blood_part,shoot_ray_col.position)
					Globals.stween_to(bullet_instance, "position", shoot_ray_col.position, ray_unit_dur, Globals.null_call,Tween.TRANS_QUINT, Tween.EASE_OUT, false, false)
					shoot_ray_col.collider.call("hit",ray_dir)
				elif col_layer != 4:
					Globals.stween_to(bullet_instance, "position", shoot_ray_col.position, ray_unit_dur, Globals.null_call,Tween.TRANS_QUINT, Tween.EASE_OUT, false, false)
					Globals.oneshot_part(Preloads.pre_burst_part,shoot_ray_col.position)
			elif !shoot_ray_col: 
				var ray_distance = 15.0
				var ray_unit_dur = ray_distance / rayspeed
				Globals.stween_to(bullet_instance, "position", ray_dir*ray_distance, ray_unit_dur,Globals.null_call,Tween.TRANS_QUINT, Tween.EASE_OUT, true, false)

		if Input.is_action_pressed("CROUCH"):
			curr_speed = CROUCH_SPEED
			var new_head_height: Vector3 = Vector3(0,HEAD_HEIGHT/2,0)
			head.position = head.position.lerp(new_head_height, delta * 5.0)
			col.shape.height = lerp(col.shape.height,COLLISION_HEIGHT/2,delta * 5.0)
		else:
			var new_head_height: Vector3 = Vector3(0,HEAD_HEIGHT,0)
			head.position = head.position.lerp(new_head_height, delta * 5.0)
			col.shape.height = lerp(col.shape.height,COLLISION_HEIGHT,delta * 5.0)
			if Input.is_action_pressed("sprint_button"):
				curr_speed = SPRINT_SPEED
			else:
				curr_speed = WALK_SPEED
				
		var input_dir = input_man.prc_stick("MOVE_LEFT", "MOVE_RIGHT", "MOVE_UP", "MOVE_DOWN", player_options.l_stick_deadzone, player_options.l_stick_response)
		var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if is_on_floor():
			#If the direction input is NOT zero, we multiply our x and z velocity (left right, forward back respectively) by the speed variable
			if direction:
				velocity.x = direction.x * curr_speed
				velocity.z = direction.z * curr_speed
			else:
				velocity.x = lerp(velocity.x, direction.x * curr_speed, delta * 7.0)
				velocity.z = lerp(velocity.z, direction.z * curr_speed, delta * 7.0)
		else:
			velocity.x = lerp(velocity.x, direction.x * curr_speed, delta * 3.0)
			velocity.z = lerp(velocity.z, direction.z * curr_speed, delta * 3.0)
		
#		var cam_input = input_man.get_stick("cam_left", "cam_right", "cam_up", "cam_down", Vector2(0.92,.95),cam_stick_curve)
#		if cam_input:
#			var remap_vec : Vector2 = Vector2(cam_input.y,cam_input.x)
#			var cam_vec : Vector3 = Globals.vec3_vec2(remap_vec, 2, 0)
#			tar_rot.y -= cam_vec.y*STICK_H_SENS*delta
#			tar_rot.x -= cam_vec.x*STICK_V_SENS*delta
	else: velocity = velocity.lerp(Vector3(0,0,0),delta*12.0)
	move_and_slide()

func _unhandled_input(event):
	if game_handler.game_state == game_handler.gstates.PLAYING:
		if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			var remap_vec : Vector2 = Vector2(event.relative.y,event.relative.x)
			var cam_vec : Vector3 = Globals.vec3_vec2(remap_vec, 2, 0)
			tar_rot -= cam_vec * MOUSE_SENS

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
#	shake_timer = Globals.createTimer(duration, true, damage, true)
#	while shake_timer.time_left > 0.0:
#		print("SHAKE")
#		var rand_centered_int = randf() * intensity - intensity / 2
#		print(rand_centered_int)
#		# Calculate a random offset based on the intensity.
#		var random_offset = Vector3(rand_centered_int,rand_centered_int,rand_centered_int)
#		# Apply the random offset to the camera's position.
#		camera.position += random_offset
#		await get_tree().process_frame
#	shake_timer.queue_free()
#	camera.position = original_offset

func damage(dmg_dir : Vector3):
#	shake(.05,.2)
	velocity += dmg_dir * 8.0
	Globals.oneshot_sound(Preloads.sfx_player_dmg, self.position, 5.0,randf_range(0.5,2.0))
	CURRENT_HEALTH = CURRENT_HEALTH - 1.0

func _on_hitbox_body_entered(body):
	if body.is_in_group("Enemy"):
		var enemy_pos = body.get_transform().origin
		var dir = self.position - enemy_pos
		damage(dir)
