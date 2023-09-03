extends Node
#
#@onready var default_curve = preload("res://input_options/default_curve.tres")
@export var l_stick_response: Curve = preload("res://input_options/default_curve.tres")
@export var r_stick_response: Curve = preload("res://input_options/default_curve.tres")
@export var l_stick_deadzone: Vector2 = Vector2(0.4,0.95)
@export var r_stick_deadzone: Vector2 = Vector2(0.4,0.95)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
