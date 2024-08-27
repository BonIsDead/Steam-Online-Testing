extends Control

@onready var healthDisplay:Label = %HealthDisplay
@onready var oxygenDisplay:Label = %OxygenDisplay
@onready var playerAvatar:TextureRect = %PlayerAvatar

var numbers:Array[String] = ["1", "2", "3", "4", "5", "6", '7', '8', '9', '0']


func _ready() -> void:
	playerAvatar.set_texture(SteamNetwork.lobbyMembersInfo[SteamNetwork.steamId].avatar)
	
	# Connect signals
	PlayerManager.itemActiveChanged.connect(_itemActiveChanged)


func _process(delta:float) -> void:
	var _randomNumber:String = numbers.pick_random() + numbers.pick_random() + numbers.pick_random()
	healthDisplay.set_text(_randomNumber)


func _itemActiveChanged() -> void:
	%ItemActive.position.x = 176 + (PlayerManager.itemActive * 32)
