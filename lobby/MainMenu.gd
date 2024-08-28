extends VBoxContainer

@onready var mainMenuNote:Label = %MainMenuNote
@onready var buttonLobbyHost:Button = %MainLobbyHost
@onready var buttonLobbyJoin:Button = %MainLobbyJoin


func _ready() -> void:
	if not SteamNetwork.steamIsOnline:
		buttonLobbyHost.set_disabled(true)
		buttonLobbyJoin.set_disabled(true)
		mainMenuNote.set_text("Steam isn't open, is it?")
	
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
