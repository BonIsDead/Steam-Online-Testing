extends VBoxContainer

@onready var title:Label = $LobbyTitle
@onready var playerList:VBoxContainer = $LobbyPlayerList
@onready var buttonLeaveLobby:Button = %LobbyLeaveLobby
@onready var buttonStartGame:Button = %LobbyStartGame
@onready var playerDefault:PackedScene = preload("res://lobby/PlayerDefault.tscn")


func _ready() -> void:
	# Connect Steam signals
	Steam.lobby_joined.connect(_onLobbyJoined)
	Steam.lobby_chat_update.connect(_onLobbyChatUpdate)
	SteamNetwork.playerListChanged.connect(_onLobbyChatUpdate)
	#Steam.relay_network_status.connect(_onRelayNetworkStatus)
	
	# Connect signals for adding and removing members from the lobby
	multiplayer.peer_connected.connect(_onPeerConnected)
	multiplayer.peer_disconnected.connect(_onPeerDisconnected)
	
	buttonLeaveLobby.pressed.connect(func():
		if (SteamNetwork.lobbyId != 0):
			Steam.leaveLobby(SteamNetwork.lobbyId)
			SteamNetwork.peer.close()
		
		for node in playerList.get_children():
			node.queue_free()
		
		%MenuTabs.set_current_tab(0)
	)
	
	buttonStartGame.pressed.connect(_onGameStart)


## Adds a member display to the player list
func lobbyListMemberAdd(steamId:int) -> void:
	# Check if the steam ID is in the lobby members information
	if (not steamId in SteamNetwork.lobbyMembersInfo):
		return
	
	# Get the member information
	var _member:Dictionary = SteamNetwork.lobbyMembersInfo[steamId]
	
	# Instance an icon and name for each member in the lobby
	var _display := playerDefault.instantiate()
	_display.get_node("Name").set_text(_member.name)
	_display.get_node("Icon").set_texture(_member.avatar)
	_display.set_name(_member.name)
	playerList.add_child(_display)


## Removes a member display from the player list
func lobbyListMemberRemove(steamId:int) -> void:
	# Check if the steam ID is in the lobby members information
	if (not steamId in SteamNetwork.lobbyMembersInfo):
		return
	
	# Get the member information
	var _member:Dictionary = SteamNetwork.lobbyMembersInfo[steamId]
	
	# Remove the player display from the list
	if playerList.has_node(_member.name):
		playerList.get_node(_member.name).queue_free()


## Called by "buttonStartGame.pressed"
func _onGameStart() -> void:
	GameManager.gameStart.rpc()


## Called by "Steam.lobby_joined"
func _onLobbyJoined(lobbyId:int, _permissions:int, _locked:bool, response:int) -> void:
	# Update the lobbies name
	var _ownerName:String = Steam.getFriendPersonaName(Steam.getLobbyOwner(lobbyId) )
	title.set_text(_ownerName + "'s Lobby")
	
	# Wait for the lobbies member information
	await SteamNetwork.lobbyGetMemberInfo(lobbyId)
	
	# Add members to the player list
	for _steamId in SteamNetwork.lobbyMembersInfo:
		lobbyListMemberAdd(_steamId)


# Not quite sure what this one does yet
func _onLobbyChatUpdate(lobbyId:int, changedId:int, makingChangeId:int, chatState:int) -> void:
	print(lobbyId, " ", changedId, " ", makingChangeId, " ", chatState)


## Called by "Steam.relay_network_status"
#func _onRelayNetworkStatus(avaliable:int, pingMeasurement:int, _avaliableConfig:int, _avaliableRelay:int, debugMessage:String) -> void:
	#pass


## Called by "multiplayer.peer_connected"
func _onPeerConnected(id:int) -> void:
	print("Peer %s added to lobby" % id)
	
	lobbyListMemberAdd(id)


## Called by "multiplayer.peer_disconnected"
func _onPeerDisconnected(id:int) -> void:
	print("Peer %s removed from lobby" % id)
	
	lobbyListMemberRemove(id)
