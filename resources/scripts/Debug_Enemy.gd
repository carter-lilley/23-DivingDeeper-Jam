extends enemy_class

@onready var player: CharacterBody3D =  $"../../Character"
@onready var camera: Camera3D = $"../../Character/Head/Camera3D"
@onready var alert_area: Area3D = $Interact_Radius
@onready var debug_label = $"3D-Label/SubViewport/Label"

#@onready var col: CollisionShape3D = $"../../CollisionShape3D"

var model_lib = preload("res://resources/models/model-lib.tscn")

var height_offset = 0.0
var model_lib_i

enum w_states {
	SEARCHING,
	ARRIVED,
	ALERT
}
var behavior_state: w_states = w_states.ARRIVED
var jump_timer: Timer

func _ready():
	model_lib_i = model_lib.instantiate()
	var new_col_shape = SphereShape3D.new()
	var my_model
	var my_col
	match my_type:
		ENEMY_TYPE.GROUNDED:
			height_offset = 1.2
			#create enemy model
			my_model = model_lib_i.get_node("Bug")
			my_col = model_lib_i.get_node("Ground-Col")
			#set its conditions
			alert_radius = 25.0
			speed = 1.6
			accel = 5.0
			my_nav.navigation_layers = enable_bitmask_inx(my_nav.navigation_layers, 0)
			my_nav.navigation_layers = disable_bitmask_inx(my_nav.navigation_layers, 1)
			health = 2.0
			name = "Grounded"
		
		ENEMY_TYPE.FLYING:
			height_offset = 0.0
			#create enemy model
			my_model = model_lib_i.get_node("Eye-Main")
			my_col = model_lib_i.get_node("Flying-Col")
			#set its conditions
			alert_radius = 7.0
			speed = 2.5
			accel = 5.0
			my_nav.navigation_layers = enable_bitmask_inx(my_nav.navigation_layers, 1)
			my_nav.navigation_layers = disable_bitmask_inx(my_nav.navigation_layers, 0)
			health = 3.0
			name = "Flying"
			
		ENEMY_TYPE.ALERT:
			height_offset = 1.2
			#create enemy model
			my_model = model_lib_i.get_node("Slime")
			my_col = model_lib_i.get_node("Ground-Col")
			#set its conditions
			alert_radius = 5.6
			speed = 5.0
			accel = 4.0
			my_nav.navigation_layers = enable_bitmask_inx(my_nav.navigation_layers, 0)
			my_nav.navigation_layers = disable_bitmask_inx(my_nav.navigation_layers, 1)
			health = 4.0
			name = "Alert"
	my_nav.path_height_offset = height_offset
	var lib_root = my_model.get_parent()
	lib_root.remove_child(my_model)
	lib_root.remove_child(my_col)
	my_model.visible = true
	add_child(my_model)
	add_child(my_col)
	new_col_shape.radius = alert_radius
	alert_area.get_child(0).shape = new_col_shape

func _physics_process(delta):
	debug_label.text = str(behavior_state)
	if behavior_state == w_states.ALERT:
		match my_type:
			ENEMY_TYPE.GROUNDED:
				behavior_bug(delta)
			ENEMY_TYPE.FLYING:
				behavior_eye(delta)
			ENEMY_TYPE.ALERT:
				behavior_slime(delta)
	if behavior_state == w_states.ARRIVED:
		my_nav.target_position = get_parent().rand_cell_pos()
		behavior_state = w_states.SEARCHING
	if behavior_state == w_states.SEARCHING:
		behavior_wander(delta)
	move_and_slide()
	
func behavior_wander(delta):
	if !is_destination_reached():
		var target_dir = (my_nav.target_position - self.global_transform.origin).normalized()
		look_at(self.global_transform.origin + -target_dir, Vector3(0, 1, 0))
		var dir: Vector3
		dir = my_nav.get_next_path_position() - global_position
		dir = dir.normalized()
		velocity = velocity.lerp(dir * speed, accel * delta)
	else: behavior_state = w_states.ARRIVED

func behavior_slime(delta):
	if jump_timer == null:
		jump_timer = Globals.createTimer(randf_range(0.5,2.75), true, jump_timeout, true)
	var target_dir = (player.position - self.global_transform.origin).normalized()
	look_at(self.global_transform.origin + -target_dir, Vector3(0, 1, 0))
	self.rotation.x = 0.0
	self.rotation.z = 0.0
	my_nav.target_position = camera.global_position - camera.global_transform.basis.z * .3
	var dir = (my_nav.get_next_path_position() - global_position).normalized()
	velocity = velocity.lerp(dir * speed, accel * delta)

func jump_timeout():
	velocity += Vector3(0,8.5,0)
	jump_timer = Globals.createTimer(randf_range(0.5,2.75), true, jump_timeout, true)
	
func behavior_bug(delta):
	var target_dir = (player.position - self.global_transform.origin).normalized()
	look_at(self.global_transform.origin + -target_dir, Vector3(0, 1, 0))
	self.rotation.x = 0.0
	self.rotation.z = 0.0
	my_nav.target_position = camera.global_position - camera.global_transform.basis.z * -1
	var dir: Vector3 = (my_nav.get_next_path_position() - global_position).normalized()
	velocity = velocity.lerp(dir * speed, accel * delta)

func behavior_eye(delta):
	var target_dir = (player.position - self.global_transform.origin).normalized()
	look_at(self.global_transform.origin + -target_dir, Vector3(0, 1, 0))
	my_nav.target_position = camera.global_position - camera.global_transform.basis.z * 1.5
	var dir: Vector3 = (my_nav.get_next_path_position() - global_position).normalized()	
	velocity = velocity.lerp(dir * speed, accel * delta)

func is_destination_reached():
	return my_nav.distance_to_target() < 10.0  # Adjust the threshold as needed
	
###function called from raycast collision
func hit(hit_dir):
	velocity += hit_dir * 4.0
	health = health - 1.0
	if health == 0.0:
		queue_free()

#GODOT doc helper functions for disabling bitmasks
static func enable_bitmask_inx(_bitmask: int, _index: int) -> int:
	return _bitmask | (1 << _index)

static func disable_bitmask_inx(_bitmask: int, _index: int) -> int:
	return _bitmask & ~(1 << _index)

#signal for when player enters alert radius
func _on_interact_radius_body_entered(_body):
	behavior_state = w_states.ALERT
	pass # Replace with function body.
	

