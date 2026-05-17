class_name GameObjectRock
extends GameObject

func _on_init() -> void:
	object_type   = GameEnums.ObjectType.ROCK
	display_name  = "Rock"
	blocks_movement = false

func can_be_picked_up() -> bool:
	return true

func get_eat_properties() -> EatProperty:
	return EatProperty.new(
		false,
		0.0,
		0.05,
		0.1
	)
