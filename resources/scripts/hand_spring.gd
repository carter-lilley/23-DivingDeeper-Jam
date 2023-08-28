extends Node3D

# Adjustable parameters
@export var damping = 0.1
@export var stiffness = 2.0
@export var delay = 0.0

@onready var cam = $"../Camera3D"
# Internal variables

var velocity = Vector3.ZERO
@export var offset = Vector3.ZERO

func _physics_process(delta):
	var direction = cam.global_position - global_position
	# Calculate the desired rotation based on the cam rotation
	var cam_rot = cam.global_transform.basis.get_euler()
	# Calculate the error (difference) between the current rotation and the target rotation
	var error = cam_rot - self.rotation
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
	var target_rot = self.rotation + velocity * delta
	rotation.x = target_rot.x
#	# Apply a delay effect by lerping towards the target rotation
#	self.rotation = self.rotation.lerp(target_rotation, 1.0 - exp(-delay * delta))
