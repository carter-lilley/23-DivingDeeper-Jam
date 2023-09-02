extends Node

@onready var game_handler = $".."
@onready var gridmap : GridMap = $"Ground-Zone/Ground-Gridmap"
@onready var flight_mesh : MeshInstance3D = $"Flight-Zone/Flight-Mesh"
@onready var nav_region : NavigationRegion3D = $"Ground-Zone"
@onready var flight_region : NavigationRegion3D = $"Flight-Zone"
@onready var player : CharacterBody3D = $"../Character"
var half_size

@export var item_num:int = 12
var enemy_num
var light_num
var player_buffer_radius:float = 6.0

var noise := FastNoiseLite.new()
var dissolve_timer
var cell_weight_range := [
	{"value": 0, "weight": 145}, # Blank
	{"value": 1, "weight": 50},  # Wall
	{"value": 2, "weight": 25},  # Corner
	{"value": 3, "weight": 4},  # Para
	{"value": 4, "weight": 7},   # Door
	{"value": 5, "weight": 12},   # Window
	{"value": 6, "weight": 8},  # Box
	{"value": 7, "weight": 8}, # Cover
]

var item_weight_range := [
	{"value": 0, "weight": 70}, # AMMO
	{"value": 1, "weight": 15},  # AMMO_PACK
	{"value": 2, "weight": 3},  # HEART
]
# Called when the node enters the scene tree for the first time.
func _ready():
	dissolve_timer = Globals.createTimer(25.0, true, dissolve_timeout, true)
	game_handler.change_current_floor(self)
	for i in range(cell_weight_range.size()):
		var random_weight = randi_range(0.0,cell_weight_range[i]["weight"]) # Generate a random number within the total weight
		cell_weight_range[i]["weight"] = random_weight
	
	enemy_num = randi_range(game_handler.curr_enemy_max/3,game_handler.curr_enemy_max)
	light_num = randi_range(0.0,game_handler.curr_floor_size*2)
	
	half_size = game_handler.curr_floor_size/2
	flight_mesh.mesh.size = Vector2(game_handler.curr_floor_size*2,game_handler.curr_floor_size*2)
	flight_region.bake_navigation_mesh(true)
	
	noise.noise_type = 0
	for x in range(-half_size,half_size):
		for y in range(1):
			for z in range(-half_size,half_size):
					var cell_pos: Vector3i = Vector3i(x,1,z)
					var selectedValue = Globals.weightedValue(cell_weight_range)
					gridmap.set_cell_item(cell_pos, selectedValue, gridmap.get_orthogonal_index_from_basis(randomBasis()))
	
	nav_region.bake_navigation_mesh(true)
	
	populate()
	pass # Replace with function body.

func populate():
	for i in range(enemy_num):
		var i_pos = inc_valid_pos(0)
		spawn_at_pos(Preloads.pre_enemy, i_pos, Vector3(0,0,0), true)
	
	for i in range(light_num):
		var i_pos = inc_valid_pos(0)
		spawn_at_pos(Preloads.pre_lantern, i_pos, Vector3(0,1,0), false)
	
	for i in range(item_num):
		var i_pos = inc_valid_pos(0)
		spawn_at_pos(Preloads.pre_item, i_pos, Vector3(0,1,0), true)

	var goal_pos = inc_valid_pos(0)
	var goal_inst = spawn_at_pos(Preloads.pre_goal, goal_pos, Vector3(0,1,0), false)
	var goal_area = goal_inst.get_child(0)
	goal_area.connect("body_entered",_on_goal_area_body_entered)

func _on_goal_area_body_entered(body):
	
	Globals.oneshot_sound(Preloads.sfx_newfloor, body.position, 15.0,1.0)
	
	var group_nodes = get_tree().get_nodes_in_group("Enemy")
	for node in group_nodes:
		node.alert()  # Alert all the old enemies
	
	game_handler.curr_floor_size+=.5
	game_handler.curr_enemy_max+=2.5
	
	var new_floor_instance = Preloads.pre_floor_gen.instantiate()
	new_floor_instance.global_transform.origin = self.position - Vector3(0,10,0)
	add_sibling(new_floor_instance)
	Globals.stween_to(new_floor_instance, "position", self.position, 1.0, Globals.null_call,Tween.TRANS_EXPO, Tween.EASE_OUT, false, false)
	
	var new_time = game_handler.game_time.time_left + 25.0
	game_handler.game_time.start(new_time)
	queue_free()

func spawn_at_pos(prefab : PackedScene, pos : Vector3, offset : Vector3, is_sibling: bool) -> Node:
	# Create and place an enemy at the specified position
	var instance = prefab.instantiate()
	instance.global_transform.origin = gridmap.map_to_local(pos) + offset
	if instance is enemy_class:
		instance.my_type = randi_range(0,2)
	if instance is item_class:
		instance.my_type = Globals.weightedValue(item_weight_range)
	if is_sibling:
		add_sibling(instance)
	else: add_child(instance)
	return instance

func inc_valid_pos(is_type : int) -> Vector3:
	var valid_position_found = false
	while not valid_position_found:
		# Generate random positions within the bounds
		var random_x = randi_range(-half_size, half_size)
		var random_z = randi_range(-half_size, half_size)
		var cell_pos = Vector3i(random_x, 1, random_z)
		
		# Check if the cell is empty
		var cell_pos_world = gridmap.map_to_local(cell_pos)
		var cell_player_dist = cell_pos_world.distance_to(player.transform.origin)
		if gridmap.get_cell_item(cell_pos) == is_type and cell_player_dist >= player_buffer_radius:
			valid_position_found = true
			return cell_pos
	return Vector3.ZERO

func exc_valid_pos(is_type : int) -> Vector3:
	var valid_position_found = false
	while not valid_position_found:
		# Generate random positions within the bounds
		var random_x = randi_range(-half_size, half_size)
		var random_z = randi_range(-half_size, half_size)
		var cell_pos = Vector3i(random_x, 1, random_z)
		
		# Check if the cell is empty
		var cell_pos_world = gridmap.map_to_local(cell_pos)
		var cell_player_dist = cell_pos_world.distance_to(player.transform.origin)
		if gridmap.get_cell_item(cell_pos) != is_type and cell_player_dist >= player_buffer_radius:
			valid_position_found = true
			return cell_pos
	return Vector3.ZERO

func rand_cell_pos() -> Vector3:
	var random_x = randi_range(-half_size, half_size)
	var random_z = randi_range(-half_size, half_size)
	var cell_pos = Vector3i(random_x, 1, random_z)
	return gridmap.map_to_local(cell_pos)

func dissolve_timeout():
	dissolve_timer = Globals.createTimer(0.3, true, dissolve_timeout, true)
	player.shake(25.0, 1.6)
	var cell_to_del = exc_valid_pos(-1)
	var cell_pos_world = gridmap.map_to_local(cell_to_del)
	Globals.oneshot_part(Preloads.pre_burst_part,cell_pos_world)
	Globals.oneshot_sound(Preloads.sfx_floorbreak, cell_pos_world, 1.0,1.0)
	gridmap.set_cell_item(cell_to_del, -1)  # -1 represents an empty cell.
	print('Dissolved cell', cell_to_del)
	
func randomBasis():
	# Generate a random rotation in increments of 90 degrees on the Y-axis
	var random_yaw = randi() % 4  # 0, 1, 2, or 3 (representing 0, 90, 180, or 270 degrees)

	# Create a rotation matrix for the Y-axis
	var new_rot: Basis = Basis.from_euler(Vector3(0, deg_to_rad(random_yaw * 90), 0))

	return new_rot
