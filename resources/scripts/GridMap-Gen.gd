extends Node

@onready var gridmap : GridMap = $"Ground-Zone/Ground-Gridmap"
@onready var flight_mesh : MeshInstance3D = $"Flight-Zone/Flight-Mesh"
@onready var nav_region : NavigationRegion3D = $"Ground-Zone"
@onready var flight_region : NavigationRegion3D = $"Flight-Zone"

@export var floor_size: int = 15
@export var enemy_num:int = 12
@export var light_num:int = 12

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
	flight_mesh.mesh.size = Vector2(floor_size*2,floor_size*2)
	flight_region.bake_navigation_mesh(true)
	
	noise.noise_type = 0
	for x in range(-floor_size/2,floor_size/2):
		for y in range(1):
			for z in range(-floor_size/2,floor_size/2):
					var cell_pos: Vector3i = Vector3i(x,1,z)
					var selectedValue = selectRandomWeightedValue(weightedRange)
					gridmap.set_cell_item(cell_pos, selectedValue, gridmap.get_orthogonal_index_from_basis(randomBasis()))
	
	nav_region.bake_navigation_mesh(true)
	
	spawnEnemies()
	pass # Replace with function body.

func spawnEnemies():
	for i in range(enemy_num):
		# Generate random positions within the bounds
		var random_x = randi_range(-floor_size / 2, floor_size / 2)
		var random_z = randi_range(-floor_size / 2, floor_size / 2)
		var cell_pos = Vector3i(random_x, 1, random_z)
		# Check if the cell is empty
		if gridmap.get_cell_item(cell_pos) == 0:
			# The cell is empty, so spawn an enemy at this position
			spawnEnemyAtPosition(cell_pos)
	for i in range(light_num):
		# Generate random positions within the bounds
		var random_x = randi_range(-floor_size / 2, floor_size / 2)
		var random_z = randi_range(-floor_size / 2, floor_size / 2)
		var cell_pos = Vector3i(random_x, 1, random_z)
		# Check if the cell is empty
		if gridmap.get_cell_item(cell_pos) == 0:
			# The cell is empty, so spawn an enemy at this position
			spawnLanternAtPosition(cell_pos)

func spawnEnemyAtPosition(_pos):
	# Create and place an enemy at the specified position
	var enemy = preload("res://resources/prefabs/enemy.tscn").instantiate()
	enemy.global_transform.origin = gridmap.map_to_local(_pos)
	enemy.my_type = randi_range(0,2)
	add_child(enemy)
	
func spawnLanternAtPosition(_pos):
	# Create and place an enemy at the specified position
	var lantern = preload("res://resources/prefabs/lantern.tscn").instantiate()
	lantern.global_transform.origin = gridmap.map_to_local(_pos) + Vector3(0,1,0)
	add_child(lantern)

func randomBasis():
	# Generate a random rotation in increments of 90 degrees on the Y-axis
	var random_yaw = randi() % 4  # 0, 1, 2, or 3 (representing 0, 90, 180, or 270 degrees)

	# Create a rotation matrix for the Y-axis
	var new_rot: Basis = Basis.from_euler(Vector3(0, deg_to_rad(random_yaw * 90), 0))

	return new_rot

# Function to select a random value from the weighted range
func selectRandomWeightedValue(range):
	var totalWeight = 0

	# Calculate the total weight of all items in the range
	for item in range:
		totalWeight += item["weight"]

	# Generate a random number within the total weight
	var randomValue = randi() % totalWeight

	# Iterate through the range to find the selected value
	var cumulativeWeight = 0
	for item in range:
		cumulativeWeight += item["weight"]
		if randomValue < cumulativeWeight:
			return item["value"]

	# This should not happen, but if it does, return the last value as a fallback
	return range[-1]["value"]
