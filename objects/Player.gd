class_name Player extends CharacterBody3D

## How quickly the current speed is reached
const ACCELERATION:float = 8.0
## How quickly friction is applied
const DECELERATION:float = 4.0
## How fast the player moves while walking
const SPEED_WALK:float = 3.4
## How fast the player moves while running
const SPEED_RUN:float = 3.4

## The currnent player ID
var playerId:int
## The current speed
var speed:float = SPEED_WALK

## Input vector for movement
var movement:Vector2

@onready var voiceAudioPlayer:AudioStreamPlayer3D = $VoiceAudioPlayer


func _ready() -> void:
	if name.is_valid_int():
		set_multiplayer_authority(str(name).to_int() )
	
	# Disable if not the multiplayer authority
	if not is_multiplayer_authority():
		set_process(false)
		set_physics_process(false)
		return
	
	# Update the player manager and hide the player mesh
	PlayerManager.playerLocal = self
	%TemporaryMesh.hide()
	
	if SteamNetwork.voiceEnabled and SteamNetwork.voiceLoopbackEnabled:
		voiceAudioPlayer.get_stream().set_mix_rate(SteamNetwork.VOICE_SAMPLE_RATE)
		voiceAudioPlayer.play()
		SteamNetwork.voiceLocalPlayback = voiceAudioPlayer.get_stream_playback()


func _process(delta:float) -> void:
	# Get the movement input
	movement = Input.get_vector("strafe_left", "strafe_right", "move_forward", "move_backward")


func _physics_process(delta:float) -> void:
	# Align input direction to the camera
	var _cameraBasis := get_viewport().get_camera_3d().global_basis
	var _direction := (_cameraBasis * Vector3(movement.x, 0.0, movement.y) ).normalized()
	
	if movement:
		# Smoothly move towards the velocity goal
		var _velocityGoal:Vector3 = _direction * speed
		velocity = velocity.lerp(_velocityGoal, ACCELERATION * delta)
	else:
		# Apply friction
		velocity = velocity.lerp(Vector3.ZERO, DECELERATION * delta)
	
	# Store pre-collision velocity
	var _velocityPrevious := velocity
	move_and_slide()
	
	# Handle collisions
	for _index in get_slide_collision_count():
		var _collision := get_slide_collision(_index)
		velocity = _velocityPrevious.slide(_collision.get_normal() )
		
