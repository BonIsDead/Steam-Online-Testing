extends VBoxContainer

## Stored array of found lobbies
var lobbiesAvaliable:Array

@onready var lobbyList:ItemList = %LobbiesList
@onready var buttonRefreshList:Button = %LobbiesRefreshList
@onready var buttonBackToMenu:Button = %LobbiesBackToMenu
@onready var buttonJoinLobby:Button = %LobbiesJoinLobby


func _ready() -> void:
	lobbyList.item_activated.connect(func(item:int):
		print(item)
	)
	
	buttonBackToMenu.pressed.connect(func():
		%MenuTabs.set_current_tab(0)
		
		if (SteamNetwork.peer != null):
			SteamNetwork.peer.close()
		
		lobbyList.clear()
	)
	
	buttonRefreshList.pressed.connect(func():
		SteamNetwork.lobbyListRequest()
		lobbyList.clear()
	)
	
	buttonJoinLobby.pressed.connect(func():
		var _selected := lobbyList.get_selected_items()[0]
		SteamNetwork.lobbyJoin(lobbiesAvaliable[_selected] )
		await Steam.lobby_joined
		
		%MenuTabs.set_current_tab(2)
	)
	
	Steam.lobby_match_list.connect(_onLobbyMatchList)


func _process(delta:float) -> void:
	# Disable the button to join a lobby if nothing is selected
	buttonJoinLobby.set_disabled(not lobbyList.is_anything_selected() )


## Called by "Steam.lobby_match_list"
func _onLobbyMatchList(lobbies:Array) -> void:
	for lobby in lobbies:
		# Get the lobby information
		var _name:String = Steam.getLobbyData(lobby, "name")
		var _members:String = str(Steam.getNumLobbyMembers(lobby) )
		var _memberLimit:String = str(Steam.getLobbyMemberLimit(lobby) )
		
		# Keep empty names from appearing blank
		if (_name == ""):
			_name = "???"
		
		# Add it to the lobby list
		lobbyList.add_item(_name + " : " + _members + "/" + _memberLimit)
	
	# Update the avaliable lobbies
	lobbiesAvaliable = lobbies
