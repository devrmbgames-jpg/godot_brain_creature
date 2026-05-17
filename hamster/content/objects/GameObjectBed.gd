class_name GameObjectBed
extends GameObject

## Sleeping here gives a comfort bonus over sleeping on the floor.
@export var comfort_bonus: float = 0.2

func _on_init() -> void:
	object_type  = GameEnums.ObjectType.BED
	display_name = "Bed"

## The hamster doesn't HAVE to sleep here, but it's more restoring.
func get_comfort_bonus() -> float:
	return comfort_bonus
