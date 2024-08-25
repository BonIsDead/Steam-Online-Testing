class_name Player extends CharacterBody3D

const ACCELERATION:float = 12.0
const DECELERATION:float = 24.0
const SPEED:float = 4.0

var movement:Vector2

var playerId:int = 1


func _process(delta:float) -> void:
	if not is_multiplayer_authority():
		return
	
	movement = Input.get_vector("strafe_left", "strafe_right", "move_forward", "move_backward")


func _physics_process(delta:float) -> void:
	if not is_multiplayer_authority():
		return
	
	var _cameraAngle:float = get_viewport().get_camera_3d().global_basis.get_euler().y
	var _direction:Vector3 = Vector3(movement.x, 0.0, movement.y).rotated(Vector3.UP, _cameraAngle)
	
	var _isAccelerating:bool = _direction.dot(Vector3(velocity.x, 0.0, velocity.z) ) > 0.0
	var _accel:float = ACCELERATION if _isAccelerating else DECELERATION
	
	var _velocityGoal:Vector3 = _direction * SPEED
	var _velocityTemp:Vector3 = velocity
	
	if movement:
		_velocityTemp = _velocityTemp.move_toward(_velocityGoal, _accel * delta)
	else:
		_velocityTemp = _velocityTemp.move_toward(Vector3.ZERO, DECELERATION * delta)
	
	velocity.x = _velocityTemp.x
	velocity.z = _velocityTemp.z
	
	move_and_slide()
