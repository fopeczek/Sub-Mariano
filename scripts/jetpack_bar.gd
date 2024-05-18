extends TextureProgressBar

func _ready():
	var player = get_node("/root/TestLevel/Player")
	player.grounded.connect(on_grounded)
	player.jetpack_used.connect(on_used)
	player.ungrounded.connect(on_ungrounded)

func _process(delta):
	pass

func on_grounded():
	visible = 0
	value = 3

func on_used():
	value -= 1

func on_ungrounded():
	visible = 1
