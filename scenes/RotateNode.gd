extends Node3D

## Speed for each axis to rotate
@export var speed:Vector3


func _physics_process(delta:float) -> void:
	rotate_x(deg_to_rad(speed.x) * delta)
	rotate_y(deg_to_rad(speed.y) * delta)
	rotate_z(deg_to_rad(speed.z) * delta)
