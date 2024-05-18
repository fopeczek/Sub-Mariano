extends RigidBody2D

signal grounded
signal jetpack_used
signal ungrounded

@export_category("Movement variables")
@export_group("Horizontal movement")
@export var max_speed: float = 450.0
@export var movement_force: float = 1700.0
@export var air_movement_force: float = 650.0

var floor_friction: float = 0.0
var is_on_floor = false

@export_group("Vertical movement")
@export var jump_force: float = 1100.0
@export var jetpack_max_charges: int = 3

var jetpack_charges: int

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
const STEP_FACTOR = 250.0

var velocity: Vector2
var default_friciton: float

func _ready():
	default_friciton = physics_material_override.friction
	movement_force *= mass
	air_movement_force *= mass
	jump_force *= mass

func manage_floor_state(state: PhysicsDirectBodyState2D):
	floor_friction = 0.0
	is_on_floor = false
	for contact_index in state.get_contact_count():
		var collision_normal = state.get_contact_local_normal(contact_index)
		var body = state.get_contact_collider_object(contact_index)
		if collision_normal.dot(Vector2(0, -1)) > 0.6:
			is_on_floor = true
			if body.physics_material_override:
				floor_friction = max(floor_friction, body.physics_material_override.friction)
			else:
				floor_friction = PhysicsMaterial.new().friction # default friction

func manage_movement(step: float):
	if Input.is_action_pressed("Right"):
		if velocity.x < max_speed:
			if is_on_floor:
				apply_central_force(Vector2.RIGHT * movement_force * step)
				physics_material_override.friction = 0.0
			else:
				apply_central_force(Vector2.RIGHT * air_movement_force * step)
		$Sprite.flip_v = false
	elif Input.is_action_pressed("Left"):
		if velocity.x > -max_speed:
			if is_on_floor:
				apply_central_force(Vector2.LEFT * movement_force * step)
				physics_material_override.friction = 0.0
			else:
				apply_central_force(Vector2.LEFT * air_movement_force * step)
		$Sprite.flip_v = true
	else:
		physics_material_override.friction = default_friciton

func manage_jumping():
	if Input.is_action_just_pressed("Up"):
		if is_on_floor: 
			apply_central_impulse(Vector2.UP * jump_force)
			ungrounded.emit()
		elif jetpack_charges > 0: 
			apply_central_impulse(Vector2.UP * jump_force * 1.7)
			jetpack_charges -= 1
			jetpack_used.emit()

func _integrate_forces(state: PhysicsDirectBodyState2D):
	manage_floor_state(state)
	var step = state.step * STEP_FACTOR
	velocity = state.linear_velocity

	if is_on_floor: 
		jetpack_charges = jetpack_max_charges
		grounded.emit()
	
	manage_movement(step)
	manage_jumping()


func _on_death():
	pass # Replace with function body.
