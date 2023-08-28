extends Node3D

@onready var menu_rect = $"Control/UI-Menu-Rect"
@onready var player = $Character
@onready var floor_gen = preload("res://resources/prefabs/floor_gen_root.tscn")
@onready var sfx_player_death = preload("res://resources/audio/sfx/PlayerDeath.wav")

enum gstates {
	PLAYING,
	PAUSED,
	GAME_OVER,
}
var game_state: gstates = gstates.PLAYING

var game_time
var floor_instance 

# Called when the node enters the scene tree for the first time.

func _ready():
	game_time = Globals.createTimer(180.0, true, game_over, true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	start_floor(game_time.time_left)

func _process(delta):
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
	floor_instance = floor_gen.instantiate()
	add_child(floor_instance)
	
	var cell_time = curr_time / 30
	Globals.createTimer(cell_time, true, delete_cell, false)

func delete_cell():
	floor_instance.delete_rand_cell()

func game_over():
	Globals.oneshot_sound(sfx_player_death, player.position, -12.0)
	game_state = gstates.GAME_OVER
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	menu_rect.visible = true
	menu_rect.color = Color(1.0, 0.0, 0.0, 0.5)
	player.rotation.z = 90.0

func _on_ui_restart_btn_pressed():
	get_tree().reload_current_scene()

func _on_ui_quit_btn_pressed():
	get_tree().quit()
