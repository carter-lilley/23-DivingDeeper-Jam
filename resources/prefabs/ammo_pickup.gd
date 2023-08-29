extends MeshInstance3D

var sfx_pickup = preload("res://resources/audio/sfx/sfx_pickup.wav")

@export var float_height: float = 2.0
@export var float_speed: float = 1.0

var tween: Tween
var tween_direction: int = 1  # 1 for up, -1 for down

func _process(delta):
	self.rotation.y += delta * 2.0

func _ready():
	Globals.stween_to(self, "position", Vector3(0, float_height * tween_direction, 0),float_speed, flip_dir, Tween.TRANS_SINE, Tween.EASE_IN_OUT, true, false)

func flip_dir():
	tween_direction *= -1
	Globals.stween_to(self, "position", Vector3(0, float_height * tween_direction, 0),float_speed, flip_dir, Tween.TRANS_SINE, Tween.EASE_IN_OUT, true, false)

func _on_pickup_area_body_entered(body):
	Globals.oneshot_sound(sfx_pickup, self.position, -25.0,randf_range(0.5,2.0))
	if body.is_in_group("Player"):
		body.ammo += 1
		queue_free()
