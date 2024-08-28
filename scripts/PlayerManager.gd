extends Node

signal playerSet
## Emitted when the player has died
signal playerDied
## Emitted when the active item has changed
signal itemActiveChanged
## Emitted when an item is picked up
signal itemPickedUp
## Emitted when an item has been dropped
signal itemDropped

## Maximum amount of health
const HEALTH_MAX:int = 100
## Maximum amount of stamina
const STAMINA_MAX:int = 100
## Maximum amount of items that can be held
const ITEM_MAX:int = 4

var playerLocal:Player:
	set(value):
		playerLocal = value
		playerSet.emit()

## The current health
var health:int = HEALTH_MAX:
	set(value):
		# Clamp the health value
		health = clampi(value, 0, HEALTH_MAX)
		
		# Check if the player is alive
		if (health == 0):
			playerDied.emit()
## The current stamina
var stamina:int = STAMINA_MAX:
	set(value):
		# Clamp the stamina value
		stamina = clampi(value, 0, STAMINA_MAX)

## The currently held items
var items:Array[Item]
## The currently active item
var itemActive:int:
	set(value):
		# Wrap the active item value
		itemActive = wrapi(value, 0, ITEM_MAX)
		itemActiveChanged.emit()

## Status on if parts of the body are damaged
var damageStatus:Dictionary = {
	Constants.Bodypart.HEAD: false,
	Constants.Bodypart.ARM_RIGHT: false,
	Constants.Bodypart.ARM_LEFT: false,
	Constants.Bodypart.TORSO: false,
	Constants.Bodypart.STOMACH: false,
	Constants.Bodypart.LEG_RIGHT: false,
	Constants.Bodypart.LEG_LEFT: false,
	Constants.Bodypart.FOOT_RIGHT: false,
	Constants.Bodypart.FOOT_LEFT: false,
}


func _process(delta:float) -> void:
	# Temporary inputs
	if Input.is_action_just_pressed("item_next"):
		itemActive += 1
	
	if Input.is_action_just_pressed("item_previous"):
		itemActive -= 1
	
	# Update held items
	itemsProcess(delta)


## Picks up an item in the next avaliable slot
func itemPickup(item:Item) -> void:
	# If slots are full, item replaces the active item
	pass


## Drops an item from the given slot
func itemDrop(slot:int) -> void:
	# Check if an item exists in the slot
	if (items[slot] == null):
		return
	
	# Remove and deactivate the item
	var _item:Item = items[slot]
	_item.isActive = false


## Drops all held items
func itemDropAll() -> void:
	if items.is_empty():
		return
	
	# Remove and deactivate all items
	for _slot in range(items.size() ):
		var _item:Item = items[_slot]
		_item.isActive = false
		
		# TODO! Drop the item here
		# Instantiate item before removing it
	
	# Clear all held items
	items.clear()


## Called to process held items
func itemsProcess(delta:float) -> void:
	for _slot in range(items.size() ):
		var _item:Item = items[_slot]
		
		# Set the items active state
		var _activeState:bool = (itemActive == _slot)
		if (_item.isActive != _activeState):
			_item.isActive = _activeState
		
		# Use the item
		_item.use(delta)
