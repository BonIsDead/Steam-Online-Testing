extends Node3D

## A reference to the player scene
@onready var playerScene:PackedScene = preload("res://objects/Player.tscn")


func _ready() -> void:
	if not multiplayer.is_server():
		return
	
	# Connect signals
	multiplayer.peer_connected.connect(_playerAdd)
	multiplayer.peer_disconnected.connect(_playerRemove)
	
	# Add other players to the scene
	for id in SteamNetwork.playerList:
		_playerAdd(id)
	
	_playerAdd(1)
	
	# Temporary for debugging
	print("Player List: ", SteamNetwork.playerList)
	print("Lobby Member Info: ", SteamNetwork.lobbyMembersInfo)


## Instantiates a player and adds them to the scene
func _playerAdd(id:int) -> Player:
	print("Added player: %s" % id)
	var _player:Player = playerScene.instantiate()
	_player.set_name(str(id) )
	
	%MultiplayerObjects.add_child(_player, true)
	return _player


## Removes an existing player from the scene
func _playerRemove(id:int) -> void:
	if not %MultiplayerObjects.has_node(str(id) ):
		return
	
	%MultiplayerObjects.get_node(str(id) ).queue_free()
