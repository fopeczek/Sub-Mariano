extends RigidBody2D

const STEP_FACTOR = 250.0

@export_category("Movement variables")
@export_group("Horizontal movement")
@export var max_speed: float = 450.0
@export var movement_force: float = 1700.0
@export var air_movement_force: float = 250.0

var floor_friction: float = 0.0
var is_on_floor = false
var floor_body

@export_group("Vertical movement")
@export var jump_force: float = 800.0
@export var jetpack_max_charges: int = 2

var jetpack_charges: int

var velocity: Vector2
var default_friciton: float

var input = Vector2.ZERO

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

func update_movement():
	#if abs(linear_velocity.x) < max_speed:
	if is_on_floor:
		constant_force = input * movement_force
		physics_material_override.friction = 0.0
	else:
		constant_force = input * air_movement_force
	
	if input.x == 0:
		constant_force = Vector2(0, 0)
		physics_material_override.friction = default_friciton

func jump():
	if is_on_floor: 
		apply_central_impulse(Vector2.UP * jump_force + input * 5000)
	elif jetpack_charges > 0: 
		apply_central_impulse(Vector2.UP * jump_force * 1.7 + input * 10000)
		jetpack_charges -= 1

func _integrate_forces(state: PhysicsDirectBodyState2D):
	manage_floor_state(state)
	if is_on_floor: 
		jetpack_charges = jetpack_max_charges

func _physics_process(delta):
	update_movement()

func _input(event):
	if event.is_action_pressed("Right") or event.is_action_released("Left"):
		input.x+=1
	if event.is_action_pressed("Left") or event.is_action_released("Right"):
		input.x-=1
	input = input.normalized()
	
	if event.is_action_pressed("Up"):
		jump()

func _on_death():
	pass # Replace with function body.
