extends MeshInstance3D

func _process(delta: float):
	# Get the camera transform and basis
	var camera_transform = get_parent().get_transform()
	var camera_basis = camera_transform.basis
	
	# Calculate the size of the viewport at the camera's depth
	var viewport_size = get_viewport().get_visible_rect().size
	var viewport_size_at_depth = Vector3(viewport_size.x, viewport_size.y, 0)
	
	# Set the quad's scale to match the viewport size at camera's depth
	scale = viewport_size_at_depth
	
	# Calculate the position of the quad based on camera transform
	var camera_pos = camera_transform.origin
	var camera_normal = -camera_transform.basis.z.normalized()
	var distance = camera_normal.dot(camera_pos - global_transform.origin)
	var quad_position = camera_pos + camera_normal * distance
	
	# Set the quad's position
	global_transform.origin = quad_position
