class_name GameActionSleep
extends GameAction

var _sleep_rate: float = 0.3

func _init() -> void:
	action_type = GameEnums.ActionType.SLEEP
	duration    = 8.0

func _on_start(target: Node3D) -> void:
	# Sleeping on a bed is more restorative
	_sleep_rate = 0.3
	if target != null and target.has_method("get_comfort_bonus"):
		_sleep_rate += target.get_comfort_bonus()

func _on_tick(delta: float) -> void:
	var brain := _brain()
	if brain:
		brain.on_slept(_sleep_rate * delta)
	var attrs := _attrs()
	if attrs:
		attrs.add(GameEnums.AttributeID.HEALTH,  0.005 * delta)
		attrs.add(GameEnums.AttributeID.ENERGY,  0.02 * delta)
		attrs.add(GameEnums.AttributeID.TOXIN_LEVEL, -0.01 * delta)

func _can_execute(_target: Node3D) -> bool:
	var attrs := _attrs()
	if attrs == null:
		return true
	return attrs.get_value(GameEnums.AttributeID.DRIVE_TIREDNESS) > 0.2
