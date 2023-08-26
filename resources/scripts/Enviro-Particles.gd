extends GPUParticles3D

@onready var player = $"../Character"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.position = player.position
