extends VBoxContainer

@onready var title:Label = $LobbyTitle
@onready var playerList:VBoxContainer = $LobbyPlayerList
@onready var buttonLeaveLobby:Button = %LobbyLeaveLobby
@onready var buttonStartGame:Button = %LobbyStartGame

@onready var playerDefault:PackedScene = preload("res://lobby/PlayerDefault.tscn")


func _ready() -> void:
	Steam.lobby_joined.connect(_lobbyJoined)
	Steam.lobby_chat_update.connect(_lobbyChatUpdate)
	#Steam.relay_network_status.connect(_relayNetworkStatus)
	
	buttonLeaveLobby.pressed.connect(func():
		if (SteamNetwork.lobbyId != 0):
			Steam.leaveLobby(SteamNetwork.lobbyId)
			SteamNetwork.peer.close()
		
		for node in playerList.get_children():
			node.queue_free()
		
		%MenuTabs.set_current_tab(0)
	)
	
	buttonStartGame.pressed.connect(_gameStart)


func _gameStart() -> void:
	SteamNetwork.gameStart.rpc()


func _lobbyJoined(id:int, _permissions:int, _locked:bool, response:int) -> void:
	var _ownerName:String = Steam.getFriendPersonaName(Steam.getLobbyOwner(id) )
	title.set_text(_ownerName + "'s Lobby")
	
	await SteamNetwork.lobbyGetMembers(id)
	
	for _member in SteamNetwork.lobbyMembers:
		var _player := playerDefault.instantiate()
		_player.get_node("Name").set_text(_member.name)
		_player.get_node("Icon").set_texture(_member.icon)
		playerList.add_child(_player)
		
		#SteamNetwork.playerRegister.rpc(id)


func _lobbyChatUpdate(id:int, changedId:int, makingChangeId:int, chatState:int) -> void:
	print(id, " ", changedId, " ", makingChangeId, " ", chatState)


func _relayNetworkStatus(avaliable:int, pingMeasurement:int, _avaliableConfig:int, _avaliableRelay:int, debugMessage:String) -> void:
	print(avaliable)
	print(pingMeasurement)
	print(debugMessage)
