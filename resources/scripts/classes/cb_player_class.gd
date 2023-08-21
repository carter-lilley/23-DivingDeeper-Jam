extends CharacterBody3D
class_name cb_player_class

var prev_vel: Vector3

@export var dot_factor: Curve

@export_category("Turning")
@export var turn_speed: float = .1  # Adjust the desired turn speed as needed
@export var turn_damp: float = 0.02  # Adjust the base proportional gain as needed

@export var pID: int
@onready var cam: Node = $"../Camera3D"
@onready var model: Node = $guy_import
@export var collision_impulse: float = 1.0

@export var ACCEL: float = 10.0
@export var MAX_SPEED: float = 5.0
@export var JUMP_VELOCITY = 4.5
