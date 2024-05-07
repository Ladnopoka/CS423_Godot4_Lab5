extends CharacterBody3D

var speed = 5.0
const WALK_SPEED = 5.0
const SPRINT_SPEED = 11.0
const SPEED = 20.0 
const ACCELERATION = 20 
const FRICTION = .5 
const JUMP_VELOCITY = 6 
const MOUSE_SENSITIVITY = 0.3  # advanced lab task -- tweak mouse sensitivity @onready var body = $"."  
@onready var body = $"."  # advanced lab task -- reference to character body 

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") # gravity from project settings 
func _physics_process(delta): 
	apply_gravity(delta) 
	movement(delta)
	apply_jump()
	move_and_slide()
	
func apply_gravity(delta): 
	if not is_on_floor():
		velocity.y -= gravity * delta 
		
func movement(delta):
	# Handle Sprint
	if Input.is_key_pressed(KEY_SHIFT):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED
	
	var input_dir = Vector2(
		int(Input.is_key_pressed(KEY_D)) - int(Input.is_key_pressed(KEY_A)),
		int(Input.is_key_pressed(KEY_S)) - int(Input.is_key_pressed(KEY_W))
	)
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		apply_velocity(direction, delta) 
	else:
		apply_friction(direction, delta) 
		
# velocity with acceleration
func apply_velocity(direction, delta):
	velocity.x = move_toward(velocity.x, direction.x * SPEED, ACCELERATION * delta)
	velocity.z = move_toward(velocity.z, direction.z * SPEED, ACCELERATION * delta) 
	
# deceleration through friction
func apply_friction(direction, delta):
	velocity.x = move_toward(velocity.x, 0, FRICTION)
	velocity.z = move_toward(velocity.z, 0, FRICTION)
	
func apply_jump():
	if is_on_floor():
		if Input.is_action_just_pressed("ui_accept"):
			velocity.y = JUMP_VELOCITY
			
func _input(event):
	if event is InputEventMouseMotion:
		body.rotate_y(deg_to_rad(-event.relative.x * MOUSE_SENSITIVITY)) 
