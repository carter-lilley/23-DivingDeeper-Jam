extends enemy_class

@onready var player: CharacterBody3D =  $"../../Character"
@onready var camera: Camera3D = $"../../Character/Head/Camera3D"
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var alert_area: Area3D = $Interact_Radius
@onready var enemy_body: CollisionShape3D = $"../../CollisionShape3D"


var alert: bool = false

func _ready():
	var new_material = StandardMaterial3D.new()
	var new_col_shape = SphereShape3D.new()
	#set_collision_layer_value(4,true) #I was hopign to set to 4 but doesnt work as I expect...
	add_to_group("enemies")
	
	match my_type:
		ENEMY_TYPE.GROUNDED:
			alert_radius = 25.0
			speed = 1.0
			accel = 0.5
			new_material.albedo_color = Color.DARK_BLUE
			my_nav.navigation_layers = enable_bitmask_inx(my_nav.navigation_layers, 0)
			my_nav.navigation_layers = disable_bitmask_inx(my_nav.navigation_layers, 1)
			health = 4.0
			name = "Grounded"
		
		ENEMY_TYPE.FLYING:
			alert_radius = 5.0
			speed = 5.0
			accel = 0.1
			new_material.albedo_color = Color.RED
			my_nav.navigation_layers = enable_bitmask_inx(my_nav.navigation_layers, 1)
			my_nav.navigation_layers = disable_bitmask_inx(my_nav.navigation_layers, 0)
			health = 3.0
			name = "Flying"
			
		ENEMY_TYPE.ALERT:
			alert_radius = 1.0
			speed = 6.0
			accel = 5.0
			new_material.albedo_color = Color.WEB_GREEN
			my_nav.navigation_layers = enable_bitmask_inx(my_nav.navigation_layers, 0)
			my_nav.navigation_layers = disable_bitmask_inx(my_nav.navigation_layers, 1)
			health = 2.0
			name = "Alert"
	
	new_col_shape.radius = alert_radius
	alert_area.get_child(0).shape = new_col_shape
	mesh_instance.set_surface_override_material(0,new_material)

func _physics_process(delta):
	match my_type:
		ENEMY_TYPE.GROUNDED:
			behavior(delta)
		ENEMY_TYPE.FLYING:
			behavior(delta)
		ENEMY_TYPE.ALERT:
			behavior(delta)
			

func behavior(delta):
	if alert:
		var dir: Vector3
		my_nav.target_position = camera.global_position - camera.global_transform.basis.z * 1.5

		dir = my_nav.get_next_path_position() - global_position
		dir = dir.normalized()
			
		velocity = velocity.lerp(dir * speed, accel * delta)
		move_and_slide()
		return

###function called from raycast collision
func hit():
	health = health - 1.0
	print(name + " took damage, health is " + str(health))
	if health == 0.0:
		queue_free()

#GODOT doc helper functions for disabling bitmasks
static func enable_bitmask_inx(_bitmask: int, _index: int) -> int:
	return _bitmask | (1 << _index)

static func disable_bitmask_inx(_bitmask: int, _index: int) -> int:
	return _bitmask & ~(1 << _index)

#signal for when player enters alert radius
func _on_interact_radius_body_entered(_body):
	alert = true
	pass # Replace with function body.
	
#func _detect_damage():
#	if enemy_body
#		health = health - 1.0
#		return
