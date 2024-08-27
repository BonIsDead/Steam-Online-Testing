class_name FirstPersonCamera extends Camera3D

var mouseSensitivity:float
var mouseSmoothing:float
var mouseSmoothed:bool
var mouseReversed:bool

## Mouse input
var motion:Vector2
var roll:float

var basisOriginal:Basis


func _ready() -> void:
	# Set up mouse settings
	Input.set_use_accumulated_input(false)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	basisOriginal = transform.basis
	
	# Connect to GameManager signals
	GameManager.configUpdated.connect(_onConfigUpdated)
	_onConfigUpdated()


func _input(event:InputEvent) -> void:
	# Get mouse input
	if event is InputEventMouseMotion:
		# Keeps motion the same regardless of resolution
		var _viewportTransform := get_viewport().get_final_transform()
		motion -= event.xformed_by(_viewportTransform).relative * mouseSensitivity


func _process(delta:float) -> void:
	var _rollInput := Input.get_axis("roll_left", "roll_right")
	roll = lerp(roll, _rollInput * 2.0, 4.0 * delta)
	
	# Limit input values
	motion.x = wrapf(motion.x, -180.0, 180.0)
	motion.y = wrapf(motion.y, -180.0, 180.0)
	roll = wrapf(roll, -180.0, 180.0)
	
	# Convert values
	var _yaw:float = deg_to_rad(motion.x)
	var _pitch:float = deg_to_rad(motion.y)
	var _roll := deg_to_rad(roll)
	
	# Flip pitch if mouse is reversed
	if mouseReversed:
		_pitch *= -1.0
	
	# Magic rotation code
	var _basisGoal := basisOriginal * Basis(Vector3.FORWARD, _roll) * Basis(Vector3.UP, _yaw) * Basis(Vector3.RIGHT, _pitch)
	basisOriginal = _basisGoal.orthonormalized()
	
	if mouseSmoothed:
		# Smoothly align to the goal transform
		transform.basis = transform.basis.slerp(_basisGoal, mouseSmoothing * delta).orthonormalized()
	else:
		# Instantly align to the goal transform
		transform.basis = _basisGoal
	
	# Reset motion vector
	motion = Vector2.ZERO


## Called by GameManager's "configUpdated" signal
func _onConfigUpdated() -> void:
	var _config := GameManager.config
	mouseSensitivity = _config.get_value("mouse", "mouseSensitivity")
	mouseSmoothing = _config.get_value("mouse", "mouseSmoothing")
	mouseSmoothed = _config.get_value("mouse", "mouseSmoothed")
	mouseReversed = _config.get_value("mouse", "mouseReversed")
