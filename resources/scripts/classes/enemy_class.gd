extends CharacterBody3D
class_name enemy_class

@export var my_type: ENEMY_TYPE

enum ENEMY_TYPE {
	GROUNDED,
	FLYING,
	ALERT,
}

@export var speed = 3.0
@export var accel = 1.5
@export var alert_radius: float = 3.5
@export var health = 3.0

@onready var my_nav: NavigationAgent3D = $NavigationAgent3D
