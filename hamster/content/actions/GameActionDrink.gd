class_name GameActionDrink
extends GameAction

var _target: Node3D = null

func _init() -> void:
	action_type = GameEnums.ActionType.DRINK
	duration    = 1.0
	reach       = 55.0

func _can_execute(target: Node3D) -> bool:
	return target != null and _distance_to(target) <= reach

func _on_start(target: Node3D) -> void:
	_target = target

func _on_finish(_t: Node3D) -> void:
	if _target == null or not _target.has_method("get_drink_properties"):
		return
	var props: GameObject.DrinkProperty = _target.get_drink_properties()
	var amount: float  = props.amount
	var quality: float = props.quality
	var toxicity: float = props.toxicity
	var brain := _brain()
	if brain:
		brain.on_drank(amount * quality, toxicity)
	if _target.has_method("on_drunk"):
		_target.on_drunk(amount)
