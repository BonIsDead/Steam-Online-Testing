extends Node3D

@onready var playerScene:PackedScene = preload("res://objects/Player.tscn")


func _ready() -> void:
	for _member in SteamNetwork.lobbyMembers:
		var _player:Player = playerScene.instantiate()
		
		# I don't know why I need to do this
		if multiplayer.is_server():
			_player.set_multiplayer_authority(1)
		else:
			_player.set_multiplayer_authority(_member.id)
		
		_player.set_name(str(_member.name) )
		add_child(_player)
