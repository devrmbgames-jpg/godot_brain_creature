class_name GameObjectWaterBowl
extends GameObject

@export var capacity:      float = 1.0
@export var refill_rate:   float = 0.02  ## per second
@export var toxicity:      float = 0.0
@export var quality:       float = 1.0

var _current_level: float = 1.0

func _on_init() -> void:
	object_type  = GameEnums.ObjectType.WATER_BOWL
	display_name = "Water Bowl"

func _process(delta: float) -> void:
	# Slowly refills
	_current_level = minf(_current_level + refill_rate * delta, capacity)

func get_drink_properties() -> DrinkProperty:
	var available := minf(_current_level, 0.3)
	return DrinkProperty.new(
		available,
		quality,
		toxicity
	)

func on_drunk(amount: float) -> void:
	_current_level = maxf(0.0, _current_level - amount)

func water_level() -> float:
	return _current_level / capacity
