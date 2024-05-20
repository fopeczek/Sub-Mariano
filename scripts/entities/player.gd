extends RigidBody2D

const DELTA_FACTOR = 250.0

@export_category("Movement")
@export var max_speed: float = 450.0
@export var movement_force: float = 1700.0
@export var air_movement_force: float = 250.0

var velocity: Vector2

var default_friciton: float
var floor_friction: float = 0.0

var is_on_floor = false
var floor_body

@export_category("Jumping")
@export var jump_force: float = 800.0
@export var jetpack: JetpackComponent

var input = Vector2.ZERO

func update_floor_state(state: PhysicsDirectBodyState2D):
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

func update_movement(delta):
	
	if abs(linear_velocity.x) < max_speed:
		if is_on_floor:
			constant_force = input * movement_force * floor_friction * delta
			physics_material_override.friction = 0.0
		else:
			constant_force = input * air_movement_force
	
	if input.x == 0:
		constant_force = Vector2(0, 0)
		physics_material_override.friction = default_friciton

func jump():
	if is_on_floor: #do normal floor jump
		apply_central_impulse(Vector2.UP * jump_force + input * 500)
	else: #do jetpack jump if available
		if jetpack:
			jetpack.jump(self, input)

func _integrate_forces(state: PhysicsDirectBodyState2D):
	update_floor_state(state)
	if is_on_floor:
		if jetpack:
			jetpack.update_charges(jetpack.max_charges)

func _physics_process(delta):
	delta *= DELTA_FACTOR
	update_movement(delta)

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

func _ready():
	default_friciton = physics_material_override.friction
	movement_force *= mass
	air_movement_force *= mass
	jump_force *= mass
