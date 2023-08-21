extends cb_player_class

var input_raw
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _process(delta):
	input_raw = MultiplayerInput.get_stick(pID, "move_left", "move_right", "move_forward", "move_back")
	
func _physics_process(delta):
	var ground_vel: Vector3 = Vector3(velocity.x,0,velocity.z)
	var ground_accel: Vector3 = ground_vel - prev_vel
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if MultiplayerInput.is_action_pressed(pID,"jump_button") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if input_raw:
		move(delta)

#	check_and_apply_force()
	prev_vel = ground_vel
			
func move(delta: float):
# Get the input direction and handle the movement/deceleration.
	var input_dir = input_raw.normalized()
	var input_mag = input_dir.length()
