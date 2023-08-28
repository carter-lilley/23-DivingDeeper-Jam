extends Node3D

var despawn_timer
var despawn_time: float = 2.0
@onready var light: Light3D = $Bullet_Lamp
@onready var bullet_mesh = $Bullet_Mesh


# Called when the node enters the scene tree for the first time.
func _ready():
	despawn_timer = Globals.createTimer(despawn_time, true, queue_free, true)
