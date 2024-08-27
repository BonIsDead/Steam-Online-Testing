class_name Item extends Resource

enum EnergyUseageType {
	## Consumes energy when active
	ACTIVE,
	## Consumes energy when inactive
	INACTIVE,
	## Consumes energy if in use
	IN_USE,
	## Always consumes energy
	ALWAYS,
}

## The maximum amount of energy an item can have
const ENERGY_MAX:float = 100
## The maximum amount of energy that can be consumed per-second
const ENERGY_CONSUMPTION_MAX:float = 10.0
## The maximum amount an item can weigh
const WEIGHT_MAX:float = 100

## The items name
@export var name:String = "New Item"
## The items description
@export_multiline var description:String = "A new item."

@export_group("Icons", "icon")
## The items active icon
@export var iconActive:Texture2D
## The items inactive icon
@export var iconInactive:Texture2D

@export_group("Resources", "resource")
## The scene to be instantiated when the item is active
@export var resourceScene:PackedScene

@export_group("Energy", "energy")
## Current energy
@export_range(1.0, ENERGY_MAX, 1.0) var energyAmount:float = ENERGY_MAX:
	set(value):
		energyAmount = clampf(value, 0.0, ENERGY_MAX)
## How much energy is consumed during use per-second
@export_range(0.0, ENERGY_CONSUMPTION_MAX, 0.1) var energyConsumption:float
## How energy is consumed
@export var energyUsageType:EnergyUseageType = EnergyUseageType.ACTIVE

@export_group("Weight")
## How much the item weighs
@export_range(0.0, WEIGHT_MAX, 0.1) var weight:int

## if the item is currently active
var isActive:bool
## If the item is being used
var isBeingUsed:bool


## Called to update the item
func use(delta:float) -> void:
	energyUpdate(delta)


func energyUpdate(delta:float) -> void:
	match energyUsageType:
		EnergyUseageType.ACTIVE:
			# Check if item is active
			if not isActive:
				return
			
			# Consume energy
			energyAmount -= energyConsumption * delta
		
		EnergyUseageType.INACTIVE:
			# Check if item is inactive
			if isActive:
				return
			
			# Consume energy
			energyAmount -= energyConsumption * delta
		
		EnergyUseageType.IN_USE:
			# Check if item is being used
			if not isBeingUsed:
				return
			
			# Consume energy
			energyAmount -= energyConsumption * delta
		
		EnergyUseageType.ALWAYS:
			# Consume energy
			energyAmount -= energyConsumption * delta
