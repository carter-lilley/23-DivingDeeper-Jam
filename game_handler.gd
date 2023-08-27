extends Node3D

@onready var floor_gen = preload("res://resources/prefabs/floor_gen_root.tscn")
var game_time
var floor_instance 

# Called when the node enters the scene tree for the first time.

func _ready():
	game_time = Globals.createTimer(180.0, true, gameover, true)
	start_floor(game_time.time_left)

func start_floor(curr_time : float):
	floor_instance = floor_gen.instantiate()
	add_child(floor_instance)
	
	var cell_time = curr_time / 30
	Globals.createTimer(cell_time, true, delete_cell, false)

func delete_cell():
	floor_instance.delete_rand_cell()

func gameover():
	print("game over!")
