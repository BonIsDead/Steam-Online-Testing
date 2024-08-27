extends Node3D

@export var distance:float = 16.0

@onready var camera:Camera3D = $Camera3D


func _ready() -> void:
	camera.position.z = distance


func _process(delta:float) -> void:
	var _camera := get_tree().get_root().get_viewport().get_camera_3d()
	transform.basis = _camera.transform.basis
	
	if PlayerManager.playerLocal:
		global_position = PlayerManager.playerLocal.global_position
