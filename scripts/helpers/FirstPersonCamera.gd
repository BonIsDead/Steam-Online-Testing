class_name FirstPersonCamera extends Camera3D

var mouseSensitivity:float
var mouseSmoothing:float
var mouseSmoothed:bool
var mouseReversed:bool

## Mouse input
var motion:Vector2


func _ready() -> void:
	# Set up mouse settings
	Input.set_use_accumulated_input(false)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# Connect to GameManager signals
	GameManager.configUpdated.connect(_configUpdated)
	_configUpdated()


func _input(event:InputEvent) -> void:
	# Get mouse input
	if event is InputEventMouseMotion:
		# Keeps motion the same regardless of resolution
		var _viewportTransform := get_viewport().get_final_transform()
		motion -= event.xformed_by(_viewportTransform).relative * mouseSensitivity


func _process(delta:float) -> void:
	# Limit input values
	motion.x = wrapf(motion.x, -180.0, 180.0)
	motion.y = clampf(motion.y, -90.0, 90.0)
	
	# Convert values
	var _yaw:float = deg_to_rad(motion.x)
	var _pitch:float = deg_to_rad(motion.y)
	
	if mouseReversed:
		_pitch *= -1.0
	
	# Update rotation
	rotation.y = lerp_angle(rotation.y, _yaw, mouseSmoothing * delta) if mouseSmoothed else _yaw
	rotation.x = lerp_angle(rotation.x, _pitch, mouseSmoothing * delta) if mouseSmoothed else _pitch


## Called by GameManager's "configUpdated" signal
func _configUpdated() -> void:
	var _config := GameManager.config
	mouseSensitivity = _config.get_value("mouse", "mouseSensitivity")
	mouseSmoothing = _config.get_value("mouse", "mouseSmoothing")
	mouseSmoothed = _config.get_value("mouse", "mouseSmoothed")
	mouseReversed = _config.get_value("mouse", "mouseReversed")
