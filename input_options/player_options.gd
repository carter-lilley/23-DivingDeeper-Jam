extends Node
#
@onready var default_curve = preload("res://input_options/default_curve.tres")
@export var l_stick_response: Curve
@export var r_stick_response: Curve 
@export var l_trigger_response: Curve
@export var r_trigger_response: Curve 
@export var l_stick_deadzone: Vector2 = Vector2(0.4,0.95)
@export var r_stick_deadzone: Vector2 = Vector2(0.4,0.95)
@export var l_trigger_deadzone: Vector2 = Vector2(0.2,0.95)
@export var r_trigger_deadzone: Vector2 = Vector2(0.2,0.95)

func _ready():
	#default curves
	if l_stick_response == null:
		l_stick_response = default_curve
	if r_stick_response == null:
		r_stick_response = default_curve
	if l_trigger_response == null:
		l_trigger_response = default_curve
	if r_trigger_response == null:
		r_trigger_response = default_curve
