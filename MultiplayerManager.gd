extends Node

var lobbyId:int = 0
var lobbyMembers:Array
var lobbyMembersMax:int = 4
var lobbyVoteKick:bool
var lobbies:Array

var steamId:int
var steamUsername:String


func _ready() -> void:
	var _response := Steam.steamInitEx(false, 480)
	print("Did Steam initialize? %s" % _response)
	
	if (_response.status > 0):
		print("Failed to initialize Steam, shutting down: %s" %_response)
		get_tree().quit()
	
	# Update local variables
	steamId = Steam.getSteamID()
	steamUsername = Steam.getPersonaName()


func _process(delta:float) -> void:
	Steam.run_callbacks()


func lobbyMembersGet() -> void:
	lobbyMembers.clear()
	
	var _memberCount:int = Steam.getNumLobbyMembers(lobbyId)
	
	for member in _memberCount:
		var _steamId:int = Steam.getLobbyMemberByIndex(lobbyId, member)
		var _steamName:String = Steam.getFriendPersonaName(_steamId)
		
		var _member := {
			"steamId": _steamId,
			"steamName": _steamName,
		}
		
		lobbyMembers.append(_member)
