extends Node2D
class_name JetpackComponent

@export_category("Jetpack")
@export var jump_force: float = 20000.0
@export var max_charges: int = 2
@export var UI_charges: Range

var charges: int = max_charges

func _ready():
	if UI_charges:
		UI_charges.max_value = max_charges
		UI_charges.value = charges

func jump(body: RigidBody2D, input: Vector2 = Vector2.ZERO):
	if charges > 0:
		body.apply_central_impulse(Vector2.UP * jump_force + input * 7000)
		charges -= 1
		if UI_charges:
			UI_charges.value = charges

func update_charges(new_charges: int):
	charges = clamp(new_charges, 0, max_charges)
	if UI_charges:
		UI_charges.value = charges
