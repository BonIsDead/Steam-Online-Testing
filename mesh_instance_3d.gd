extends Node3D


func _process(delta:float) -> void:
	var _camera := get_tree().get_root().get_viewport().get_camera_3d()
	transform.basis = _camera.transform.basis
