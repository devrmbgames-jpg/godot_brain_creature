class_name GameObjectBigRock
extends GameObject

@export var mass: float = 5.0   ## multiplier on push force needed

func _on_init() -> void:
	object_type     = GameEnums.ObjectType.BIG_ROCK
	display_name    = "Big Rock"
	blocks_movement = true

func can_be_pushed() -> bool:
	return true

func on_pushed(direction: Vector3, force: float) -> void:
	# Only move if force exceeds mass threshold
	if force / mass < 100.0:
		return
	var distance := (force / mass) * 0.5
	global_position += direction.normalized() * distance
	global_position.z = 0.0

func get_eat_properties() -> EatProperty:
	return EatProperty.new(
		false,
		0.0,
		0.1,
		0.1
	)
