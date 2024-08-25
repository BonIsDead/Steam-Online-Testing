extends Node3D

@export var targetPath:NodePath
var target

@export var speed:float = 8.0


func _enter_tree() -> void:
	target = get_node_or_null(targetPath)
	if (not target): set_process(false)


func _process(delta:float) -> void:
	var _a = target.basis
	var _b = transform.basis
	var _c = _b.slerp(_a, speed * delta)
	transform.basis = _c.orthonormalized()
