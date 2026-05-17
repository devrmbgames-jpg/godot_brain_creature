class_name GameAttribute

var id: int
var value: float
var min_value: float
var max_value: float

func _init(p_id: int, p_value: float, p_min: float = -1.0, p_max: float = 1.0) -> void:
	id = p_id
	min_value = p_min
	max_value = p_max
	value = clampf(p_value, min_value, max_value)

## Returns value normalized to [-1, 1] range.
func normalized() -> float:
	if max_value == min_value:
		return 0.0
	return (value - min_value) / (max_value - min_value) * 2.0 - 1.0

## Returns value normalized to [0, 1] range.
func ratio() -> float:
	if max_value == min_value:
		return 0.0
	return (value - min_value) / (max_value - min_value)

func set_value(v: float) -> void:
	value = clampf(v, min_value, max_value)

func add(delta: float) -> void:
	set_value(value + delta)

func is_full() -> bool:
	return value >= max_value

func is_empty() -> bool:
	return value <= min_value
