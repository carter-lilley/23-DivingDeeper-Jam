extends GridMap

var noise := FastNoiseLite.new()
var weightedRange := [
	{"value": 0, "weight": 120}, # Blank
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
	noise.noise_type = 0
	for x in range(10):
		for y in range(1):
			for z in range(10):
					var cell_pos: Vector3i = Vector3i(x,1,z)
					var selectedValue = selectRandomWeightedValue(weightedRange)
					set_cell_item(cell_pos, selectedValue, 0)
					
	pass # Replace with function body.

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
