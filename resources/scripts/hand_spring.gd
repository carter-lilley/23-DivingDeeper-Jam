extends Node3D

# Adjustable parameters
@export var damping = 0.1
@export var stiffness = 2.0
@export var delay = 0.0

@onready var cam = $"../Head/Camera3D"
# Internal variables
var target_rotation = Vector3.ZERO
var velocity = Vector3.ZERO
var offset = Vector3.ZERO
@export var offset_distance :float = 0.0
func _physics_process(delta):
	
#	var offset = cam.global_transform.basis.z * offset_distance # offset_distance is the desired distance from the camera
#	self.position = cam.global_transform.origin + offset
	
	# Calculate the desired rotation based on the parent's rotation
	var cam_rot = cam.global_transform.basis.get_euler()
	target_rotation = cam_rot

	# Calculate the error (difference) between the current rotation and the target rotation
	var error = target_rotation - self.rotation

	# Apply damping and stiffness to create a springy motion
	var damping_force = -damping * velocity
	var spring_force = stiffness * error

	# Calculate the total force
	var total_force = spring_force + damping_force

	# Calculate acceleration (F = ma)
	var acceleration = total_force

	# Update velocity (integrate acceleration)
	velocity += acceleration * delta

	# Update rotation (integrate velocity)
	self.rotation += velocity * delta

	# Apply a delay effect by lerping towards the target rotation
	self.rotation = self.rotation.lerp(target_rotation, 1.0 - exp(-delay * delta))
