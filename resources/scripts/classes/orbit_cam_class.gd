extends Camera3D
class_name orbit_cam_class

@export var cam_tar: Node

@export var Hsense:=0.045
@export var Vsense:=0.025

@export var follow_smooth:=8
@export var follow_damp:= 0.2

@export var stick_response: Curve
