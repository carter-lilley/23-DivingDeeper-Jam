extends CharacterBody3D
class_name player_class

# Cam variables
@export var MOUSE_SENS = 0.005
@export var STICK_SENS = 75.0
@export var CAM_ACCEL = 5
@export var BASE_FOV: float = 75.0 
@export var FOV_CHANGE: float = 1.5
@export var HEAD_HEIGHT: float = 0.32 #relative to parent

# Move variables
@export var COLLISION_HEIGHT: float = 1.3
@export var WALK_SPEED: float = 5.0
@export var SPRINT_SPEED: float = 7.25
@export var CROUCH_SPEED: float = 3.0
@export var ACCEL: float = 7.0
@export var JUMP_VELOCITY: float = 4.5

# Headbob variables
@export var BOB_FREQ: float = 2.0 #Essentially, how often your character takes a 'step' -- Frequency
@export var BOB_AMP: float = 0.08 #How high up your camera goes (or how hard/high the bob is) -- Amplitude
@export var t_bob: float = 0.0 #Variable to pass to the sin function to tell it how far along we are at any given moment

#Player Variables
@export var CURRENT_HEALTH = 3.0
@export var MAX_HEALTH = 3.0
