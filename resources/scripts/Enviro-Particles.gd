extends GPUParticles3D

@onready var player = $"../Character"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	self.position = player.position


func _on_button_pressed():
	pass # Replace with function body.
