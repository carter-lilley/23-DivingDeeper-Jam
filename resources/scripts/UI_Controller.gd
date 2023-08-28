extends Control

@onready var game_handler = $".."
@onready var timer_label = $"UI-Top-Container/Timer_Label"
@onready var ui_menu = $"UI-Menu-Rect"
@onready var healthbar = $"UI-Health-Bar"
@onready var player = $"../Character"

var isPaused = false

func _process(delta):
	var time_left = game_handler.game_time.time_left
	timer_label.text = Globals.formatTime(time_left, true)
	
	healthbar.scale.x = player.CURRENT_HEALTH / player.MAX_HEALTH
	
	if game_handler.game_state == game_handler.gstates.PAUSED and !isPaused:
		isPaused = true
		pause()
	elif game_handler.game_state != game_handler.gstates.PAUSED and isPaused:
		if game_handler.game_state != game_handler.gstates.GAME_OVER:
			isPaused = false
			unpause()

func pause():
	ui_menu.visible = true

func unpause():
	ui_menu.visible = false
