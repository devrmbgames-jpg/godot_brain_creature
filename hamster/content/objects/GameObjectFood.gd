class_name GameObjectFood
extends GameObject

@export var nutrition:  float = 0.6
@export var toxicity:   float = 0.0
@export var servings:   int   = 3   ## how many bites before depleted

var _remaining_servings: int = 0

func _on_init() -> void:
	object_type = GameEnums.ObjectType.FOOD
	display_name = "Food"
	_remaining_servings = servings

func can_be_picked_up() -> bool:
	return true

func get_eat_properties() -> EatProperty:
	return EatProperty.new(
		true,
		nutrition,
		toxicity,
		0.0
	)


func on_bitten(_damage: float) -> void:
	_remaining_servings -= 1
	if _remaining_servings <= 0:
		object_destroyed.emit(self)
		queue_free()
