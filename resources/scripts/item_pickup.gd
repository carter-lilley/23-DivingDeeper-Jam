extends item_class

var sfx_pickup = preload("res://resources/audio/sfx/sfx_pickup.wav")
var sfx_heart_pickup = preload("res://resources/audio/sfx/sfx_heart_get.wav")

@export var float_height: float = 0.4
@export var float_speed: float = 0.6

var model_lib = preload("res://resources/models/model-lib.tscn")
var model_lib_i

var tween: Tween
var tween_direction: int = 1  # 1 for up, -1 for down

func _process(delta):
	self.rotation.y += delta * 2.0

func _ready():
	Globals.stween_to(self, "position", Vector3(0, float_height * tween_direction, 0),float_speed, flip_dir, Tween.TRANS_SINE, Tween.EASE_IN_OUT, true, false)
	
	model_lib_i = model_lib.instantiate()
	var my_model
	match my_type:
		ITEM_TYPE.AMMO:
			my_model = model_lib_i.get_node("Ammo-Pickup")
		ITEM_TYPE.AMMO_PACK:
			my_model = model_lib_i.get_node("Ammo-Pack-Pickup")
		ITEM_TYPE.HEART:
			my_model = model_lib_i.get_node("Heart-Pickup")
	var lib_root = my_model.get_parent()
	lib_root.remove_child(my_model)
	my_model.visible = true
	add_child(my_model)

func flip_dir():
	tween_direction *= -1
	Globals.stween_to(self, "position", Vector3(0, float_height * tween_direction, 0),float_speed, flip_dir, Tween.TRANS_SINE, Tween.EASE_IN_OUT, true, false)

func _on_pickup_area_body_entered(body):
	if body.is_in_group("Player"):
		queue_free()
		match my_type:
			ITEM_TYPE.AMMO:
				Globals.oneshot_sound(sfx_pickup, self.position, 1.0,randf_range(0.5,2.0))
				body.ammo += 1
			ITEM_TYPE.AMMO_PACK:
				Globals.oneshot_sound(sfx_pickup, self.position, 1.0,randf_range(0.5,2.0))
				body.ammo += 10
			ITEM_TYPE.HEART:
				Globals.oneshot_sound(sfx_heart_pickup, self.position, 1.0,randf_range(0.5,2.0))
				body.CURRENT_HEALTH += 1
