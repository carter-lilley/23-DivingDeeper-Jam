#extends MeshInstance3D
#
#func _ready():
#	var camera  = self.get_parent()
#	# Get the camera's projection matrix.
#	var projection_matrix = cam.projection
#
#	# Calculate the position of the quad mesh in camera space.
#	var position = Vector3(0, 0, -cam.znear)
#
#	# Transform the position to world space.
#	position = cam.global_transform.xform(position)
#
#	# Set the position of the QuadMesh.
#	transform.origin = position
#
#	# Calculate the size of the quad based on the camera's frustum.
#	var scale_x = tan(cam.fov * 0.5) * -position.z * 2
#	var scale_y = scale_x / cam.aspect
#
#	# Set the size of the QuadMesh.
#	scale = Vector3(scale_x, scale_y, 1)
