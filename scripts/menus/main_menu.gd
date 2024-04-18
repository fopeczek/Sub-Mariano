extends VBoxContainer

var test_scene = preload("res://scenes/test_level.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_singleplayer_pressed():
	get_tree().change_scene_to_packed(test_scene)
