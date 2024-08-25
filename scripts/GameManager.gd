extends Node

signal configUpdated

var config:ConfigFile = ConfigFile.new()


func _enter_tree() -> void:
	_configUpdate()


func _input(event:InputEvent) -> void:
	if event is InputEventKey:
		if Input.is_action_just_pressed("ui_cancel"):
			get_tree().quit()


func _configUpdate() -> void:
	config.load("res://settings.cfg")
	configUpdated.emit()
