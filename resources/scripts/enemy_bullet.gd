extends Node3D

var despawn_timer
var despawn_time: float = 3.0
@onready var light: Light3D = $Bullet_Lamp
@onready var bullet_mesh = $Bullet_Mesh
@onready var one_shot_part = preload("res://resources/prefabs/burst_part.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	despawn_timer = Globals.createTimer(despawn_time, true, queue_free, true)


func _on_hurtbox_area_body_entered(body):
	Globals.oneshot_part(one_shot_part,body.position)
	if body.is_in_group("Player"):
		var enemy_pos = body.get_transform().origin
		var dir = enemy_pos - self.position
		body.damage(dir)
	if body.is_in_group("Enviro"):
		queue_free()
