class_name Player extends CharacterBody3D

## How quickly the current speed is reached
const ACCELERATION:float = 12.0
## How quickly friction is applied
const DECELERATION:float = 24.0
## How fast the player moves while walking
const SPEED_WALK:float = 2.4
## How fast the player moves while running
const SPEED_RUN:float = 3.4

## The currnent player ID
var playerId:int = 1
## The current speed
var speed:float = SPEED_WALK

## Input vector for movement
var movement:Vector2


func _process(delta:float) -> void:
	if not is_multiplayer_authority():
		return
	
	# Get the players movement input
	movement = Input.get_vector("strafe_left", "strafe_right", "move_forward", "move_backward")


func _physics_process(delta:float) -> void:
	if not is_multiplayer_authority():
		return
	
	# Get the angle of the current camera
	var _cameraAngle:float = get_viewport().get_camera_3d().global_basis.get_euler().y
	var _direction:Vector3 = Vector3(movement.x, 0.0, movement.y).rotated(Vector3.UP, _cameraAngle)
	
	# Switch between accelerating and decelerating
	var _isAccelerating:bool = _direction.dot(Vector3(velocity.x, 0.0, velocity.z) ) > 0.0
	var _accel:float = ACCELERATION if _isAccelerating else DECELERATION
	
	# Smoothly move towards the velocity goal
	var _velocityGoal:Vector3 = _direction * speed
	var _velocityTemp:Vector3 = velocity
	
	if movement:
		# Move to the velocity goal
		_velocityTemp = _velocityTemp.move_toward(_velocityGoal, _accel * delta)
	else:
		# Apply friction
		_velocityTemp = _velocityTemp.move_toward(Vector3.ZERO, DECELERATION * delta)
	
	# Apply the temporary velocity to the actual velocity
	velocity.x = _velocityTemp.x
	velocity.z = _velocityTemp.z
	move_and_slide()
