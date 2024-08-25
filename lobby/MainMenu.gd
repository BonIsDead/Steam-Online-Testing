extends VBoxContainer

@onready var buttonLobbyHost:Button = %MainLobbyHost
@onready var buttonLobbyJoin:Button = %MainLobbyJoin


func _ready() -> void:
	buttonLobbyHost.pressed.connect(func():
		SteamNetwork.lobbyCreate()
		await Steam.lobby_created
		
		%MenuTabs.set_current_tab(2)
	)
	
	buttonLobbyJoin.pressed.connect(func():
		SteamNetwork.lobbyListRequest()
		await Steam.lobby_match_list
		
		%MenuTabs.set_current_tab(1)
	)
