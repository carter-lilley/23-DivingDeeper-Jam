extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	pass

#INPUT UTILS-------------------------------------------------------

func get_stick(negative_x: StringName, positive_x: StringName, negative_y: StringName, positive_y: StringName, deadzone_range:Vector2, response_curve: Curve) -> Vector2:
	var _vec = Input.get_vector(negative_x, positive_x, negative_y, positive_y)
	var _vec_dz = stick_deadzone(_vec,deadzone_range)
	var _vec_response = response_curve(_vec_dz,response_curve)
	return _vec_response

func stick_deadzone(_input:Vector2, dz_range:Vector2):
	var input_mag = _input.length()
	var remapped_range
	if input_mag >= dz_range.x:
		remapped_range = remap(input_mag, dz_range.x, dz_range.y, dz_range.x, 1)
	else: remapped_range = Vector2.ZERO
	remapped_range = remapped_range * _input.normalized()
	return remapped_range

func response_curve(input: Vector2, curve: Curve) -> Vector2:
	var dir = input.normalized()
	var length = input.length()
	var adjusted = curve.sample(length)
	var value = dir * adjusted
	return value

#depreciated, get_vector already has a circular deadzone
func sqr2cirlce(input: Vector2) -> Vector2:
	if input.length() != 0:
		var x = sign(input.x)
		var y = sign(input.y)
		var strength
		input = Vector2(abs(input.x),abs(input.y))
		if input.x > input.y:
			strength = input.x
		else:
			strength = input.y
		input += input.normalized() * (strength-input.length())
		input *= Vector2(x,y)
	return input
