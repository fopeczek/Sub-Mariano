extends RigidBody2D

#@export_category("Physics")
#@export_range(10.0, 100.0) var push_force: float = 50.0

@export_category("Movement variables")
@export_group("Horizontal movement")
@export var max_speed: float = 450.0
@export var movement_force: float = 1700.0
@export var air_movement_force: float = 650.0

var floor_friction: float = 0.0
var is_on_floor = false

@export_group("Vertical movement")
@export var jump_force: float = 1100.0
@export var jetpack_max_ammo: int = 1

var jetpack_ammo: int
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity") # get gravity value from settings
const STEP_FACTOR = 250.0

var default_friciton

func _ready():
	default_friciton = physics_material_override.friction
	movement_force *= mass
	air_movement_force *= mass
	jump_force *= mass

func get_floor(state: PhysicsDirectBodyState2D):
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

#func apply_push_forces():
	#for i in get_slide_collision_count():
		#var collision = get_slide_collision(i)
		#var body = collision.get_collider()
		#if body is RigidBody2D:
			#body.apply_central_impulse(-collision.get_normal() * push_force)

func _integrate_forces(state: PhysicsDirectBodyState2D):
	get_floor(state)
	var step = state.step * STEP_FACTOR
	var velocity = state.linear_velocity
#
	if is_on_floor: jetpack_ammo = jetpack_max_ammo
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
	
	if Input.is_action_just_pressed("Up"):
		if is_on_floor: apply_central_impulse(Vector2.UP * jump_force)
		elif jetpack_ammo: 
			apply_central_impulse(Vector2.UP * jump_force * 1.7)
			jetpack_ammo -= 1
	
	state.angular_velocity = 0.0 # lock rotation
	rotation = 0.0


func _on_death():
	pass # Replace with function body.
