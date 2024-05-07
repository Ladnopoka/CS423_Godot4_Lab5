extends CharacterBody3D

var speed
const SPEED = 5.0
const ACCELERATION = 20
const FRICTION = .5
const JUMP_VELOCITY = 6
const MOUSE_SENSITIVITY = 0.3 	# advanced lab task -- tweak mouse sensitivity
const WALK_SPEED = 5.0
const SPRINT_SPEED = 11.0

@onready var body = $Rig
@onready var head = $Rig/Head
@onready var camera_3d = $Rig/Head/Camera3D
#@onready var camera_3d = $Rig/Head/XRPlayer

var angleX = 0 	# current vertical angle of players head
@export var maxAngle = 90 # maximum degree for looking down/up (positive is down, negative is up)
@export var headAngleLocomotionTrigger = 20 # degrees when player start moving (positive is forward, negative is backward) 
@export var headAngleStopTrigger = 10  # Degrees to stop moving (should be less than locomotion trigger)
var isMoving = false

var camera_x_rotation = 0 # keeps track of how much we move the camera along the x-axis (so to not overturn)
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") # gravity from project settings

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta):
	apply_gravity(delta)
	#movement_keyboard(delta) # disabled
	movement_headtilt(delta) # enabled (since we want to move with head tilt
	apply_jump()
	move_and_slide()

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

# Locomotion with keys and mouse (for direction)
func movement_keyboard(delta):
	# Handle Sprint for extra cool movement
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

# Locomotion with mouse for headtilt with constant move (forward and backward)		
func movement_headtilt(delta):
	var basis = body.get_global_transform().basis
	var direction = Vector3()
	print ("Angle:" , angleX )
	if angleX > headAngleLocomotionTrigger and not isMoving:
		isMoving = true
	elif angleX < -headAngleLocomotionTrigger and not isMoving:
		isMoving = true
	elif abs(angleX) < headAngleStopTrigger:
		isMoving = false

	if isMoving:
		if angleX > 0:
			direction -= basis.z  # Move forward
			apply_velocity(direction, delta)  # Ensure this is within the if block
		else:
			direction += basis.z  # Move backward
			apply_velocity(direction, delta)
	else:
		apply_friction(direction, delta)
		
# velocity with acceleration
func apply_velocity(direction, delta):
	velocity.x = move_toward(velocity.x, direction.x * SPEED, ACCELERATION * delta)
	velocity.z = move_toward(velocity.z, direction.z * SPEED, ACCELERATION * delta)
	print ("v: ", velocity )

# deceleration through friction
func apply_friction(direction, delta):
	velocity.x = move_toward(velocity.x, 0, FRICTION)
	velocity.z = move_toward(velocity.z, 0, FRICTION)

func apply_jump():
	if is_on_floor():
		if Input.is_action_just_pressed("ui_accept"):
			velocity.y = JUMP_VELOCITY

func _input(event):
	# Advanced -- recapture the mouse by pressing any mouse key
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# mouse movement to position head (direction and tilt)
	if event is InputEventMouseMotion:
		body.rotate_y(deg_to_rad(-event.relative.x * MOUSE_SENSITIVITY))
		# only move camera up or down if it is within the 90 degree boundary (so to not overturn)
		var x_delta = event.relative.y * MOUSE_SENSITIVITY
		# absolute X angle
		angleX = camera_x_rotation + x_delta
		#print ("Angle X: ", angleX)		
		if camera_x_rotation + x_delta > -maxAngle and camera_x_rotation + x_delta < maxAngle:
			camera_3d.rotate_x(deg_to_rad(-x_delta))
			camera_x_rotation += x_delta
