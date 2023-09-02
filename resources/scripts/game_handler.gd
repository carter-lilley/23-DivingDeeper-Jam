extends Node3D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var curr_stage_height = 0.0
var stage_offset = 15.0
@onready var menu_rect = $"Control/UI-Menu-Rect"
@onready var player = $Character
@onready var restart_btn = $"Control/UI-Menu-Rect/HBoxContainer/VBoxContainer/UI-Restart-Btn"

@export var curr_floor_size: int = 12
@export var curr_enemy_max:int = 6

var current_floor: Node3D

enum gstates {
	PLAYING,
	PAUSED,
	GAME_OVER,
}
var game_state: gstates = gstates.PLAYING

var game_time
var floor_instance 
var floor_num: int = 0
# Called when the node enters the scene tree for the first time.

func _ready():
#	current_floor = get_node("floor_gen_root")
	game_time = Globals.createTimer(60.0, true, game_over, true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	start_floor(game_time.time_left)

func _process(_delta):
	if Input.is_action_just_pressed("pause"):
		match game_state:
			gstates.PLAYING:
				game_state =  gstates.PAUSED
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			gstates.PAUSED:
				game_state =  gstates.PLAYING
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			gstates.GAME_OVER:
				pass

func start_floor(curr_time : float):
	floor_instance = Preloads.pre_floor_gen.instantiate()
	add_child(floor_instance)
	
	var cell_time = curr_time / 30
	Globals.createTimer(cell_time, true, delete_cell, false)

func delete_cell():
	floor_instance.delete_rand_cell()

func change_current_floor(new_floor:Node3D):
	floor_num+=1
	current_floor = new_floor

func game_over():
	Globals.oneshot_sound(Preloads.sfx_player_death, player.position, 1.0)
	game_state = gstates.GAME_OVER
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	menu_rect.visible = true
	menu_rect.color = Color(1.0, 0.0, 0.0, 0.5)
	player.rotation.z = 90.0
	restart_btn.grab_focus()

func _on_ui_restart_btn_pressed():
	get_tree().reload_current_scene()

func _on_ui_quit_btn_pressed():
	get_tree().quit()
