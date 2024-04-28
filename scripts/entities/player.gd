extends RigidBody2D

#@export_category("Physics")
#@export_range(10.0, 100.0) var push_force: float = 50.0

@export_category("Movement variables")
@export_group("Horizontal movement")
#@export var max_speed: float = 400.0
@export var movement_force: float = 2500.0
@export var air_movement_force: float = 500.0

var floor_objects: Array[PhysicsBody2D] = []
var is_on_floor = false

@export_group("Vertical movement")
@export var jump_force: float = 1200.0

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity") # get gravity value from settings
const STEP_FACTOR = 250.0

func _ready():
	movement_force *= mass
	air_movement_force *= mass
	jump_force *= mass

func get_floor(state: PhysicsDirectBodyState2D):
	floor_objects = []
	is_on_floor = false
	for contact_index in state.get_contact_count():
		var collision_normal = state.get_contact_local_normal(contact_index)
		var body = state.get_contact_collider_object(contact_index)
		if collision_normal.dot(Vector2(0, -1)) > 0.6:
			floor_objects.append(body)
	if floor_objects.size() > 0:
		is_on_floor = true

#func apply_push_forces():
	#for i in get_slide_collision_count():
		#var collision = get_slide_collision(i)
		#var body = collision.get_collider()
		#if body is RigidBody2D:
			#body.apply_central_impulse(-collision.get_normal() * push_force)

func _integrate_forces(state: PhysicsDirectBodyState2D):
	get_floor(state)
	var step = state.step * STEP_FACTOR
#
	if Input.is_action_pressed("Right"):
		if is_on_floor:
			apply_central_force(Vector2.RIGHT * movement_force * step)
		else:
			apply_central_force(Vector2.RIGHT * air_movement_force * step)
		$Sprite.flip_v = false
	elif Input.is_action_pressed("Left"):
		if is_on_floor:
			apply_central_force(Vector2.LEFT * movement_force * step)
		else:
			apply_central_force(Vector2.LEFT * air_movement_force * step)
		$Sprite.flip_v = true

	##velocity.x = clamp(velocity.x, -max_speed, max_speed)
	
	if Input.is_action_just_pressed("Up"):
		apply_central_impulse(Vector2.UP * jump_force)
		
	#apply_push_forces()
	#state.linear_velocity = velocity
	state.angular_velocity = 0.0 # lock rotation
	rotation = 0.0


func _on_death():
	pass # Replace with function body.
