extends Node2D
class_name FlashlightComponent

func _process(delta):
	look_at(get_global_mouse_position())
