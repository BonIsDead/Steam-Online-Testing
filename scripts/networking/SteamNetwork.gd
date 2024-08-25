extends Node

signal log(who:String, what:String)

## Game app ID
const STEAM_APP_ID:int = 480

## The Steam ID for the current player
var steamId:int
## The Steam name for the current player
var steamName:String

## The current lobby ID
var lobbyId:int
## The members in the current lobby
var lobbyMembers:Array
## The maximum amount of members in a lobby
var lobbyMembersMax:int = 4
## The type of lobby to be created
var lobbyType:Steam.LobbyType = Steam.LobbyType.LOBBY_TYPE_PUBLIC

# The current multiplayer peer
var peer:SteamMultiplayerPeer


func _init() -> void:
	# Initializing Steam
	var _response := Steam.steamInitEx(false, STEAM_APP_ID)
	print(_response)
	
	# Check initialization status
	match _response.status:
		Steam.STEAM_API_INIT_RESULT_OK:
			print("Steam initialized successfully.")
			
			steamId = Steam.getSteamID()
			steamName = Steam.getPersonaName()
		
		Steam.STEAM_API_INIT_RESULT_FAILED_GENERIC, Steam.STEAM_API_INIT_RESULT_NO_STEAM_CLIENT, Steam.STEAM_API_INIT_RESULT_VERSION_MISMATCH:
			push_error("Failed to initialize Steam: %s" % _response)


func _ready() -> void:
	# Connect signals
	log.connect(_log)
	Steam.lobby_created.connect(_lobbyCreated)


func _process(delta:float) -> void:
	Steam.run_callbacks()


## Create a new lobby
func lobbyCreate() -> void:
	log.emit("lobbyCreate")
	
	# Connect signals
	if not multiplayer.peer_connected.is_connected(_peerConnected):
		multiplayer.peer_connected.connect(_peerConnected)
	if not multiplayer.peer_disconnected.is_connected(_peerDisconnected):
		multiplayer.peer_disconnected.connect(_peerDisconnected)
	if not Steam.lobby_joined.is_connected(_lobbyJoined):
		Steam.lobby_joined.connect(_lobbyJoined)
	
	# Create the lobby
	Steam.createLobby(lobbyType, lobbyMembersMax)


## Join a created lobby
func lobbyJoin(id:int) -> void:
	log.emit("lobbyJoin")
	
	if not Steam.lobby_joined.is_connected(_lobbyJoined):
		Steam.lobby_joined.connect(_lobbyJoined)
	
	Steam.joinLobby(id)


## Updates avaliable lobbies
func lobbyListRequest() -> void:
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	Steam.addRequestLobbyListStringFilter("gleeby", "deeby", Steam.LOBBY_COMPARISON_EQUAL)
	Steam.requestLobbyList()


## Sets lobby member information inside the lobby members array (id, name, avatar)
func lobbyGetMembers(id:int) -> void:
	lobbyMembers.clear()
	
	var _members:int = Steam.getNumLobbyMembers(id)
	
	for _member in _members:
		var _steamId:int = Steam.getLobbyMemberByIndex(id, _member)
		var _name:String = Steam.getFriendPersonaName(_steamId)
		
		Steam.getPlayerAvatar(Steam.AVATAR_SMALL, _steamId)
		var _avatarData = await Steam.avatar_loaded
		
		var _image := Image.create_from_data(_avatarData[1], _avatarData[1], false, Image.FORMAT_RGBA8, _avatarData[2] )
		var _icon := ImageTexture.create_from_image(_image)
		
		var _info := {
			"id": id,
			"name": _name,
			"icon": _icon,
		}
		
		lobbyMembers.append(_info)


## Creates a host peer
func peerCreateHost() -> void:
	log.emit("peerCreateHost")
	
	peer = SteamMultiplayerPeer.new()
	var _error := peer.create_host(0)
	
	match _error:
		OK:
			log.emit("Status", "OK")
			multiplayer.set_multiplayer_peer(peer)
			_peerConnected(1)
		
		_:
			# An error has occured
			push_error("Issue creating host: %s" % _error)


## Creates a client peer
func peerCreateClient(id:int) -> void:
	log.emit("peerCreateClient")
	
	if not Steam.lobby_joined.is_connected(_lobbyJoined):
		Steam.lobby_joined.connect(_lobbyJoined)
	
	peer = SteamMultiplayerPeer.new()
	var _error := peer.create_client(id)
	
	match _error:
		OK:
			log.emit("Status", "OK")
			multiplayer.set_multiplayer_peer(peer)
			_peerConnected(id) # NOTICE! This seems... incorrect
		
		_:
			# An error has occured
			push_error("Issue creating host: %s" % _error)
	
	Steam.joinLobby(id)


## Temporarily creates a game
@rpc("call_local", "any_peer", "reliable")
func gameStart() -> void:
	get_tree().change_scene_to_file("res://scenes/TestScene.tscn")
	print("Members: %s" % lobbyMembers)


## Signal function for a lobby being created
func _lobbyCreated(connect:int, id:int) -> void:
	log.emit("Signal", "_lobbyCreated")
	
	if (not connect == 1):
		return
	
	lobbyId = id
	log.emit("Lobby ID", str(id) )
	
	Steam.setLobbyJoinable(id, true)
	
	var _lobbyName:String = Steam.getPersonaName() + "'s Lobby"
	Steam.setLobbyData(id, "name", _lobbyName)
	Steam.setLobbyData(id, "gleeby", "deeby")
	peerCreateHost()


## Signal function for a lobby being joined
func _lobbyJoined(id:int, _permissions:int, _locked:bool, response:int) -> void:
	log.emit("Signal", "_lobbyJoined")
	
	# if joining the lobby was successful
	if (response == Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS):
		var _steamId := Steam.getLobbyOwner(id)
		if (_steamId != Steam.getSteamID() ):
			lobbyId = id
			peerCreateClient(id)
		return
	
	# If joining the lobby failed
	match response:
		Steam.CHAT_ROOM_ENTER_RESPONSE_DOESNT_EXIST:
			log.emit("The lobby doesn't exist.")
		Steam.CHAT_ROOM_ENTER_RESPONSE_NOT_ALLOWED:
			printerr("You don't have permission to join this lobby.")
		Steam.CHAT_ROOM_ENTER_RESPONSE_FULL:
			printerr("The lobby you're trying to join is full.")
		Steam.CHAT_ROOM_ENTER_RESPONSE_LIMITED:
			printerr("You can't join due to having a limited account.")
		Steam.CHAT_ROOM_ENTER_RESPONSE_MEMBER_BLOCKED_YOU:
			printerr("A user in the lobby has blocked you from entering.")
		Steam.CHAT_ROOM_ENTER_RESPONSE_YOU_BLOCKED_MEMBER:
			printerr("A user you've blocked is in the lobby.")
		Steam.CHAT_ROOM_ENTER_RESPONSE_COMMUNITY_BAN:
			printerr("The lobby is community blocked.")
		Steam.CHAT_ROOM_ENTER_RESPONSE_CLAN_DISABLED:
			printerr("The lobby is locked or disabled.")
		Steam.CHAT_ROOM_ENTER_RESPONSE_BANNED:
			printerr("You're banned from this lobby.")
		Steam.CHAT_ROOM_ENTER_RESPONSE_ERROR:
			printerr("An unknown issue has occured.")


## Signal function for when a peer has connected
func _peerConnected(id:int) -> void:
	log.emit("Signal", "_peerConnected")


## Signal function for when a peer has disconnected
func _peerDisconnected(id:int) -> void:
	log.emit("Signal", "_peerDisconnected")


## Signal function for debug logging
func _log(who:String, what:String = "") -> void:
	print_rich("[color=orange]%s[/color]\t%s" % [who, what] )
