extends Node

@onready var game_handler = $".."

@onready var gridmap : GridMap = $"Ground-Zone/Ground-Gridmap"
@onready var flight_mesh : MeshInstance3D = $"Flight-Zone/Flight-Mesh"
@onready var nav_region : NavigationRegion3D = $"Ground-Zone"
@onready var flight_region : NavigationRegion3D = $"Flight-Zone"

@export var floor_size: int = 15
var half_size

@export var enemy_max:int = 12
@export var light_num:int = 12
@export var ammo_num:int = 12
var enemy_num

@onready var new_floor = preload("res://resources/prefabs/floor_gen_root.tscn")
@onready var enemy = preload("res://resources/prefabs/enemy.tscn")
@onready var lantern = preload("res://resources/prefabs/lantern.tscn")
@onready var goal = preload("res://resources/prefabs/goal.tscn")
@onready var ammo_pickup = preload("res://resources/prefabs/ammo_pickup.tscn")

@onready var sfx_newfloor = preload("res://resources/audio/sfx/sfx_next_floor.wav")
var noise := FastNoiseLite.new()

var weightedRange := [
	{"value": 0, "weight": 145}, # Blank
	{"value": 1, "weight": 50},  # Wall
	{"value": 2, "weight": 25},  # Corner
	{"value": 3, "weight": 4},  # Para
	{"value": 4, "weight": 7},   # Door
	{"value": 5, "weight": 12},   # Window
	{"value": 6, "weight": 8},  # Box
	{"value": 7, "weight": 8}, # Cover
]

# Called when the node enters the scene tree for the first time.
func _ready():
	game_handler.change_current_floor(self)
	for i in range(weightedRange.size()):
		var random_weight = randi_range(0.0,weightedRange[i]["weight"]) # Generate a random number within the total weight
		weightedRange[i]["weight"] = random_weight
	
	enemy_num = randi_range(0.0,enemy_max*2)
	
	half_size = floor_size/2
	flight_mesh.mesh.size = Vector2(floor_size*2,floor_size*2)
	flight_region.bake_navigation_mesh(true)
	
	noise.noise_type = 0
	for x in range(-half_size,half_size):
		for y in range(1):
			for z in range(-half_size,half_size):
					var cell_pos: Vector3i = Vector3i(x,1,z)
					var selectedValue = selectRandomWeightedValue(weightedRange)
					gridmap.set_cell_item(cell_pos, selectedValue, gridmap.get_orthogonal_index_from_basis(randomBasis()))
	
	nav_region.bake_navigation_mesh(true)
	
	populate()
	pass # Replace with function body.

func populate():
	for i in range(enemy_num):
		# Generate random positions within the bounds
		var random_x = randi_range(-half_size, half_size)
		var random_z = randi_range(-half_size, half_size)
		var cell_pos = Vector3i(random_x, 1, random_z)
		# Check if the cell is empty
		if gridmap.get_cell_item(cell_pos) == 0:
			# The cell is empty, so spawn an enemy at this position
			spawn_at_pos(enemy, cell_pos, Vector3(0,0,0), true)
	for i in range(light_num):
		# Generate random positions within the bounds
		var random_x = randi_range(-half_size, half_size)
		var random_z = randi_range(-half_size, half_size)
		var cell_pos = Vector3i(random_x, 1, random_z)
		# Check if the cell is empty
		if gridmap.get_cell_item(cell_pos) == 0:
			# The cell is empty, so spawn an enemy at this position
			spawn_at_pos(lantern, cell_pos, Vector3(0,1,0), false)
	for i in range(ammo_num):
		# Generate random positions within the bounds
		var random_x = randi_range(-half_size, half_size)
		var random_z = randi_range(-half_size, half_size)
		var cell_pos = Vector3i(random_x, 1, random_z)
		# Check if the cell is empty
		if gridmap.get_cell_item(cell_pos) == 0:
			# The cell is empty, so spawn an enemy at this position
			spawn_at_pos(ammo_pickup, cell_pos, Vector3(0,1,0), true)
	var random_x = randi_range(-half_size+3, half_size-3)
	var random_z = randi_range(-half_size+3, half_size-3)
	var cell_pos = Vector3i(random_x, 1, random_z)
	var goal_inst = spawn_at_pos(goal, cell_pos, Vector3(0,1,0), false)
	var goal_area = goal_inst.get_child(0)
	goal_area.connect("body_entered",_on_goal_area_body_entered)

func _on_goal_area_body_entered(body):
	Globals.oneshot_sound(sfx_newfloor, body.position, 1.0,1.0)
	var new_floor_instance = new_floor.instantiate()
	new_floor_instance.global_transform.origin = self.position - Vector3(0,10,0)
	add_sibling(new_floor_instance)
	Globals.stween_to(new_floor_instance, "position", self.position, 2.0, Globals.null_call,Tween.TRANS_LINEAR, Tween.EASE_OUT_IN, false, false)
	queue_free()

func spawn_at_pos(prefab : PackedScene, pos : Vector3, offset : Vector3, is_sibling: bool) -> Node:
	# Create and place an enemy at the specified position
	var instance = prefab.instantiate()
	instance.global_transform.origin = gridmap.map_to_local(pos) + offset
	if instance is enemy_class:
		instance.my_type = randi_range(0,2)
	if is_sibling:
		add_sibling(instance)
	else: add_child(instance)
#	instance.global_transform.origin = gridmap.map_to_local(pos) + offset
	return instance

func delete_rand_cell():
	var random_x = randi_range(-half_size, half_size)
	var random_z = randi_range(-half_size, half_size)
	var cell_pos = Vector3i(random_x, 1, random_z)
	gridmap.set_cell_item(cell_pos, -1)  # -1 represents an empty cell.

func rand_cell_pos() -> Vector3:
	var random_x = randi_range(-half_size, half_size)
	var random_z = randi_range(-half_size, half_size)
	var cell_pos = Vector3i(random_x, 1, random_z)
	return gridmap.map_to_local(cell_pos)

func randomBasis():
	# Generate a random rotation in increments of 90 degrees on the Y-axis
	var random_yaw = randi() % 4  # 0, 1, 2, or 3 (representing 0, 90, 180, or 270 degrees)

	# Create a rotation matrix for the Y-axis
	var new_rot: Basis = Basis.from_euler(Vector3(0, deg_to_rad(random_yaw * 90), 0))

	return new_rot

# Function to select a random value from the weighted range
func selectRandomWeightedValue(_range):
	var totalWeight = 0

	# Calculate the total weight of all items in the range
	for item in _range:
		totalWeight += item["weight"]

	# Generate a random number within the total weight
	var randomValue = randi() % totalWeight

	# Iterate through the range to find the selected value
	var cumulativeWeight = 0
	for item in _range:
		cumulativeWeight += item["weight"]
		if randomValue < cumulativeWeight:
			return item["value"]

	# This should not happen, but if it does, return the last value as a fallback
	return _range[-1]["value"]
