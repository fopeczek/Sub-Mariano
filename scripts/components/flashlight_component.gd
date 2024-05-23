extends Node2D
class_name FlashlightComponent

func _process(delta):
	if get_parent().direction:
		if get_viewport().get_mouse_position().x > 975:
			look_at(get_global_mouse_position())
	else:
		if get_viewport().get_mouse_position().x < 975:
			look_at(get_global_mouse_position())
