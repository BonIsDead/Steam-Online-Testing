extends Node

signal configUpdated

var config:ConfigFile = ConfigFile.new()


func _enter_tree() -> void:
	_onConfigUpdate()


func _input(event:InputEvent) -> void:
	if event is InputEventKey:
		if Input.is_action_just_pressed("ui_cancel"):
			get_tree().quit()


@rpc("call_local")
func gameStart() -> void:
	get_tree().change_scene_to_file("res://scenes/TestScene.tscn")


func _onConfigUpdate() -> void:
	config.load("res://settings.cfg")
	configUpdated.emit()
