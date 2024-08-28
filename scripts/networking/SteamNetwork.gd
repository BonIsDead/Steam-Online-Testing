extends Node

## Emitted when the player list has changed
signal playerListChanged
## Emitted to help debug
signal log(who:String, what:String)

enum VoiceDataType {
	LOCAL,
	NETWORK,
}

## Game app ID
const STEAM_APP_ID:int = 480
## The maximum amount of members per-lobby
const LOBBY_MEMBERS_MAX:int = 4
## Default sample rate used for voice chat
const VOICE_SAMPLE_RATE:int = 22050

var steamIsOnline:bool
## The Steam ID for the current player
var steamId:int
## The Steam name for the current player
var steamName:String

## The current lobby ID
var lobbyId:int
## Information on the current lobbies members
var lobbyMembersInfo:Dictionary
## The type of lobby to be created
var lobbyType:Steam.LobbyType = Steam.LobbyType.LOBBY_TYPE_PUBLIC

## If voice chat is enabled
var voiceEnabled:bool = true
## If the local voice is muted
var voiceMuted:bool
## If the local voice can be heard locally
var voiceLoopbackEnabled:bool = true

# Temporary variables for testing voice chat
var voiceLocalPlayback:AudioStreamGeneratorPlayback
var voiceLocalBuffer:PackedByteArray
var voiceNetworkPlayback:AudioStreamGeneratorPlayback
var voiceNetworkBuffer:PackedByteArray

## The current multiplayer peer
var peer:SteamMultiplayerPeer

## A list of currently connected players
var playerList:Dictionary:
	set(value):
		playerList = value
		playerListChanged.emit()


func _init() -> void:
	# Initializing Steam
	var _response := Steam.steamInitEx(true, STEAM_APP_ID)
	
	# Check initialization status
	match _response.status:
		Steam.STEAM_API_INIT_RESULT_OK:
			log.emit("Steam initialized successfully")
			
			# Set local information
			steamIsOnline = Steam.loggedOn()
			steamId = Steam.getSteamID()
			steamName = Steam.getPersonaName()
		
		Steam.STEAM_API_INIT_RESULT_FAILED_GENERIC:
			push_error("Failed to initialize Steam: %s" % _response)
		
		Steam.STEAM_API_INIT_RESULT_NO_STEAM_CLIENT:
			push_error("Failed to initialize Steam: %s" % _response)
		
		Steam.STEAM_API_INIT_RESULT_VERSION_MISMATCH:
			push_error("Steam version mismatch: %s" % _response)


func _ready() -> void:
	# Connect signals
	multiplayer.peer_connected.connect(_onPeerConnected)
	multiplayer.peer_disconnected.connect(_onPeerDisconnected)
	Steam.lobby_created.connect(_onLobbyCreated)
	Steam.lobby_joined.connect(_onLobbyJoined)
	log.connect(_onLog)


func _process(delta:float) -> void:
	Steam.run_callbacks()
	voiceProcess()


#region Socket Functions
## Creates a host socket
func socketCreate() -> void:
	log.emit("socketCreate")
	
	# Create new multiplayer peer
	peer = SteamMultiplayerPeer.new()
	var _error := peer.create_host(0)
	
	# Check if there was an issue
	if (_error == OK):
		multiplayer.set_multiplayer_peer(peer)
		return
	
	# An error has occured
	push_error("Issue creating socket: %s" % _error)


## Creates a client socket
func socketConnect(clientSteamId:int) -> void:
	log.emit("socketConnect")
	
	# Create new multiplayer peer
	peer = SteamMultiplayerPeer.new()
	var _error := peer.create_client(clientSteamId, 0)
	
	# Check if there was an issue
	if (_error == OK):
		multiplayer.set_multiplayer_peer(peer)
		return
	
	# An error has occured
	push_error("Issue connecting socket: %s" % _error)
#endregion


#region Lobby Functions
## Create a new lobby
func lobbyCreate() -> void:
	log.emit("lobbyCreate")
	Steam.createLobby(lobbyType, LOBBY_MEMBERS_MAX)


## Join a created lobby
func lobbyJoin(newLobbyId:int) -> void:
	log.emit("lobbyJoin", newLobbyId)
	Steam.joinLobby(newLobbyId)


## Updates avaliable lobbies
func lobbyListRequest() -> void:
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	Steam.addRequestLobbyListStringFilter("gleeby", "deeby", Steam.LOBBY_COMPARISON_EQUAL)
	Steam.requestLobbyList()


## Updates current lobby members information
func lobbyGetMemberInfo(newLobbyId:int) -> Dictionary:
	# Clear previous member information
	lobbyMembersInfo.clear()
	
	for _member in Steam.getNumLobbyMembers(newLobbyId):
		# Get Steam ID and name
		var _steamId:int = Steam.getLobbyMemberByIndex(newLobbyId, _member)
		var _steamName:String = Steam.getFriendPersonaName(_steamId)
		
		# Load the players avatar
		Steam.getPlayerAvatar(Steam.AVATAR_SMALL, _steamId)
		var _avatarData = await Steam.avatar_loaded
		var _avatarImage := Image.create_from_data(_avatarData[1], _avatarData[1], false, Image.FORMAT_RGBA8, _avatarData[2] )
		var _avatarTexture := ImageTexture.create_from_image(_avatarImage)
		
		# Add member info into the dictionary
		lobbyMembersInfo[_steamId] = {
			"name": _steamName,
			"avatar": _avatarTexture,
		}
	
	# Return lobby member information
	return lobbyMembersInfo
#endregion


#region Player Functions
## Registers a player to the player list
@rpc("any_peer")
func playerRegister(playerName:String) -> void:
	var _id := multiplayer.get_remote_sender_id()
	playerList[_id] = playerName


## Unregisters a player from the player list
func playerUnregister(id:int) -> void:
	playerList.erase(id)
#endregion


#region Voice Functions
## Handles processing available Steam voices
func voiceProcess() -> void:
	# Check if voice chat is enabled
	if not voiceEnabled:
		return
	
	# Get available voices
	var _available := Steam.getAvailableVoice()
	
	# If voice buffers were found
	if (_available.result == Steam.VOICE_RESULT_OK) and (_available.buffer > 0):
		# Get Steam voice data
		var _voiceData := Steam.getVoice()
		
		# Check the result and see if there is anything
		if (_voiceData.result == Steam.VOICE_RESULT_OK):
			# Process local voice
			if voiceLoopbackEnabled:
				voiceBufferRead(_voiceData.buffer, VoiceDataType.LOCAL)
			
			# Process network voice
			# TODO!
	return


## Reads and converts voice buffers
func voiceBufferRead(buffer:PackedByteArray, dataType:VoiceDataType) -> void:
	# Skip if there's no local voice playback
	if (voiceLocalPlayback == null):
		return
	
	# Get the decompressed voices
	var _voiceDecompressed := Steam.decompressVoice(buffer, VOICE_SAMPLE_RATE)
	
	# Check if conditions are met to continue
	if (_voiceDecompressed.result != Steam.VOICE_RESULT_OK) \
	or (_voiceDecompressed.size() <= 0):
		return
	
	match dataType:
		VoiceDataType.LOCAL:
			# Adjust the local voice buffer
			voiceLocalBuffer = _voiceDecompressed.uncompressed
			voiceLocalBuffer.resize(_voiceDecompressed.size() )
			
			var _bufferRange:int = mini(voiceLocalPlayback.get_frames_available() * 2, voiceLocalBuffer.size() )
			for i:int in range(0, _bufferRange, 2):
				# Convert Steam's 16-bit PCM buffer into amplitude
				var _valueRaw:int = voiceLocalBuffer[0] | (voiceLocalBuffer[1] << 8)
				_valueRaw = (_valueRaw + 32768) & 0xffff
				var _amplitude:float = float(_valueRaw - 32768) / 32768.0
				
				# Update the local voice playback
				voiceLocalPlayback.push_frame(Vector2(_amplitude, _amplitude) )
				voiceLocalBuffer.clear()
		
		VoiceDataType.NETWORK:
			# TODO! Networking stuff goes here
			pass


## Enables and disables Steam voice recording
func voiceRecord(speaking:bool) -> void:
	# Lets Steam duck UI audio when the user is speaking
	Steam.setInGameVoiceSpeaking(steamId, speaking)
	
	# Starts or stops voice recording
	if speaking:
		Steam.startVoiceRecording()
	else:
		Steam.stopVoiceRecording()
#endregion


#region Signal Functions
## Called by "Steam.lobby_created"
func _onLobbyCreated(connect:int, newLobbyId:int) -> void:
	log.emit("Signal", "onLobbyCreated")
	
	# Check if there was an issue
	if (connect != 1):
		printerr("Issue creating lobby: %s" % connect)
		return
	
	# Create a new lobby
	lobbyId = newLobbyId
	var _lobbyName:String = Steam.getPersonaName() + "'s Lobby"
	Steam.setLobbyData(newLobbyId, "name", _lobbyName)
	Steam.setLobbyData(newLobbyId, "gleeby", "deeby")
	socketCreate()


## Called by "Steam.lobby_joined"
func _onLobbyJoined(newLobbyId:int, _permissions:int, _locked:bool, response:int) -> void:
	log.emit("Signal", "onLobbyJoined")
	
	# if joining the lobby was successful
	if (response == Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS):
		var _ownerSteamId := Steam.getLobbyOwner(newLobbyId)
		if (_ownerSteamId != Steam.getSteamID() ):
			lobbyId = newLobbyId
			socketConnect(_ownerSteamId)
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


## Called by "multiplayer.peer_connected"
func _onPeerConnected(id:int) -> void:
	log.emit("Signal", "onPeerConnected")
	
	# Add ourselves to the joining peers player list
	playerRegister.rpc_id(id, steamName)


## Called by "multiplayer.peer_disconnected"
func _onPeerDisconnected(id:int) -> void:
	log.emit("Signal", "onPeerDisconnected")
	
	# Remove the peer from the player list
	playerUnregister(id)


## Called by "log"
func _onLog(who:String, what:String = "") -> void:
	print_rich("[color=orange]%s[/color]\t%s" % [who, what] )
#endregion
