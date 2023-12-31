extends Node

#TWEEN UTILS-------------------------------------------------------

func stween_to(node: Node, property: String, target: Variant, duration: float, method: Callable,_trans: Tween.TransitionType, _ease: Tween.EaseType, relative: bool, parallel: bool):
	var tween = node.create_tween()
	tween.set_parallel(parallel)
	tween.connect("finished", method)
	if relative:
#		print("relative")
		tween.tween_property(node, property, target, duration).set_trans(_trans).set_ease(_ease).as_relative()
	else:
#		print("not relative")
		tween.tween_property(node, property, target, duration).set_trans(_trans).set_ease(_ease)

#RAY UTILS-------------------------------------------------------
func fire_ray_circle(space_state: Object, from: Vector3, radius: float, mask_bit: int,  step: float) -> Array:
	var rays = []
	for i in range(8):
		var angle = deg_to_rad(i * 45) + deg_to_rad(step)  # Angle in radians, spaced evenly at 45 degrees
		var dir = Vector3(cos(angle), sin(angle), 0)  # Direction vector on the Z/Y plane
		var to = from + dir * radius
		var query = PhysicsRayQueryParameters3D.create(from, to, mask_bit)
		var col = space_state.intersect_ray(query)
		DrawLine3d.DrawLine(from,to,Color(0, 1, 1))
		rays.append(col)
	return rays

func fire_ray(space_state : Object,from : Vector3, dir : Vector3,length: float,mask_bit : int) -> Dictionary:
	var to = (from + (dir.normalized() * length))
	var query = PhysicsRayQueryParameters3D.create(from, to, mask_bit)
	var col = space_state.intersect_ray(query)
	if col:
		return col
	return {}

func get_child_by_type(node: Node, type_name: String) -> Node:
	for child in node.get_children():
		if child.is_class(type_name):
			return child
	return null

#ONE SHOTS-------------------------------------------------------

func oneshot_sound(sfx: AudioStream, position: Vector3, volume: float = 1.0, pitch_scale: float = 1.0, delay : float =0.0):
	await get_tree().create_timer(delay).timeout
	var audioPlayer = AudioStreamPlayer3D.new()
	audioPlayer.pitch_scale = pitch_scale 
	audioPlayer.stream = sfx
	audioPlayer.transform.origin = position
	audioPlayer.volume_db = 20 * log10(volume / 100.0) # Convert volume to dB
	audioPlayer.finished.connect(free_node.bind(audioPlayer))
	get_tree().get_root().add_child(audioPlayer)
	audioPlayer.play()

func free_node(free: Node):
	free.queue_free()

func oneshot_part(particleSystem: PackedScene, position: Vector3):
	var instance = particleSystem.instantiate()
	instance.transform.origin = position
	createTimer(2.0, true, free_node.bind(instance), true)
	get_parent().add_child(instance)
	instance.restart()

#MATH UTILS-------------------------------------------------------
func vec2_vec3(vec3, axis):
	var array = [vec3.x, vec3.y, vec3.z]
	array.remove(axis)
	return Vector2(array[0], array[1])

func vec3_vec2(vec2, axis, value):
	var array = [vec2.x, vec2.y]
	array.insert(axis, value)
	return Vector3(array[0], array[1], array[2])

func normalize_rot_deg(rot_deg: float) -> float:
	# Calculate the full rotations (in multiples of 360 degrees)
	var full_rotations = int(rot_deg / 360)
	
	# Normalize the Y-axis to -180 to 180 degrees
	rot_deg = fmod(rot_deg, 360.0)
	if rot_deg < -180.0:
		rot_deg += 360.0
	elif rot_deg > 180.0:
		rot_deg -= 360.0
	
	# Add back the full rotations
	rot_deg += full_rotations * 360.0
	return (rot_deg)

func normalize_rot_rad(rot_rad: float) -> float:
	# Calculate the full rotations (in multiples of 2π radians)
	var full_rotations = int(rot_rad / (2 * PI))
	
	# Normalize the Y-axis to -π to π radians
	rot_rad = fmod(rot_rad, 2 * PI)
	if rot_rad < -PI:
		rot_rad += 2 * PI
	elif rot_rad > PI:
		rot_rad -= 2 * PI
	
	# Add back the full rotations
	rot_rad += full_rotations * 2 * PI
	return rot_rad

func ShortestRot(q1:Quaternion,q2:Quaternion) -> Quaternion:
	if q1.dot(q2) < 0:
		return q1 * QuatMultiply(q2,-1).inverse()
	else: return q1*q2.inverse()

func QuatMultiply(input:Quaternion,scalar:float) -> Quaternion:
	return Quaternion(input.x * scalar, input.y * scalar, input.z * scalar, input.w * scalar);

func variant_diff(initial_value: Variant, target_value: Variant) -> float:
	var result: float = 0.0

	match typeof(initial_value):
		TYPE_FLOAT:
			result = (target_value - initial_value)
		TYPE_VECTOR3:
			result = (target_value - initial_value).length()
		# Add more cases for other variant types as needed
	return result

func log10(x: float) -> float:
	return log(x) / log(10)
# Function to select a random value from the weighted range
func weightedValue(_range):
	var totalWeight = 0

	# Calculate the total weight of all items in the range
	for item in _range:
		totalWeight += item["weight"]

	# Generate a random number within the total weight
	var randomValue = randi() % totalWeight

	# Iterate through the range to find the selected value
	var cumulativeWeight = 0
	for item in _range:
		cumulativeWeight += item["weight"]
		if randomValue < cumulativeWeight:
			return item["value"]

	# This should not happen, but if it does, return the last value as a fallback
	return _range[-1]["value"]
#TIMER UTILS-------------------------------------------------------
func createTimer(wait_time: float, one_shot: bool, method: Callable, start: bool = false) -> Timer:
	var timer = Timer.new()
	timer.wait_time = wait_time
	timer.one_shot = one_shot
	timer.connect("timeout", method)
	add_child(timer)
	if start:
		timer.start()
	return timer
	
func formatTime(seconds: float, includeMilliseconds: bool) -> String:
	var minutes = int(seconds / 60)
	var remainingSeconds = int(seconds) % 60
	var milliseconds = int((seconds - floor(seconds)) * 1000)
	var formattedTime = pad_zero(minutes) + ":" + pad_zero(remainingSeconds)
	if includeMilliseconds:
		formattedTime += "." + padMilliseconds(milliseconds)
	return formattedTime

func pad_zero(number: int) -> String:
	var strNumber = str(number)
	if number < 10:
		strNumber = "0" + strNumber
	return strNumber

func padMilliseconds(value: int) -> String:
	if value < 10:
		return "00" + str(value)
	elif value < 100:
		return "0" + str(value)
	else:
		return str(value)
#SPRITE UTILS-------------------------------------------------------
func random_tint(_sprite: Sprite2D):
	var red = randf_range(0, 1)
	var green = randf_range(0, 1)
	var blue = randf_range(0, 1)
	# Set the random color as the sprite's modulate color
	_sprite.modulate = Color(red, green, blue)
	return

#RANDOM-------------------------------------------------------
func null_call():
	return
