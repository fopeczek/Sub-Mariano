extends CharacterBody2D

@export_category("Physics")
@export_range(10.0, 100.0) var push_force: float = 50.0

@export_category("Movement variables")
@export_group("Horizontal movement")
@export_range(100.0, 1000.0) var max_speed: float = 400.0
@export_range(10.0, 100.0) var acceleration: float = 25.0
@export_range(0.0, 5.0) var air_acceleration: float = 2.0

var floor_friction: float = 0.0
@export var floor_friction_factor: float = 2000.0

@export_group("Vertical movement")
@export_range(100.0, 1000.0) var jump_velocity: float = 600.0

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity") # get gravity value from settings
const DELTA_FACTOR = 100.0

func get_floor_friction():
	var new_floor_fricion = 0.0
	for i in get_slide_collision_count():
		var body = get_slide_collision(i).get_collider()
		if body.physics_material_override:
			new_floor_fricion = max(body.physics_material_override.friction, new_floor_fricion)
	floor_friction = new_floor_fricion

func apply_friction(delta):
	if is_on_floor():
		var friction = floor_friction * floor_friction_factor * delta
		if velocity.length() >= friction:
			velocity.x -= velocity.normalized().x * friction
		else:
			velocity.x = 0

func apply_push_forces():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var body = collision.get_collider()
		if body is RigidBody2D:
			body.apply_central_impulse(-collision.get_normal() * push_force)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta # Apply the gravity.
		floor_friction = 0.0
	else:
		get_floor_friction()

	if Input.is_action_pressed("Right"):
		if is_on_floor():
			velocity.x += acceleration * floor_friction * delta * DELTA_FACTOR
		else:
			velocity.x += air_acceleration * delta * DELTA_FACTOR
		$Sprite.flip_v = false
	elif Input.is_action_pressed("Left"):
		if is_on_floor():
			velocity.x -= acceleration * floor_friction * delta * DELTA_FACTOR
		else:
			velocity.x -= air_acceleration * delta * DELTA_FACTOR
		$Sprite.flip_v = true
	else:
		apply_friction(delta)
	
	velocity.x = clamp(velocity.x, -max_speed, max_speed)
	
	if Input.is_action_just_pressed("Up"):
		velocity.y -= jump_velocity
	
	move_and_slide()
	
	apply_push_forces()


func _on_death():
	pass # Replace with function body.
