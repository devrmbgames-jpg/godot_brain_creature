class_name GameActionUse
extends GameAction

var _target: Node3D = null

func _init() -> void:
	action_type = GameEnums.ActionType.USE
	duration    = 3.0
	reach       = 60.0

func _can_execute(target: Node3D) -> bool:
	return target != null and target.has_method("on_used") and _distance_to(target) <= reach

func _on_start(target: Node3D) -> void:
	_target = target
	if target.has_method("on_use_started"):
		target.on_use_started(_character)

func _on_tick(delta: float) -> void:
	if _target and _target.has_method("on_use_tick"):
		_target.on_use_tick(delta, _character)

func _on_finish(_t: Node3D) -> void:
	if _target == null:
		return
	if _target.has_method("on_used"):
		_target.on_used(_character)
	var brain := _brain()
	if brain and _target.has_method("get_object_type"):
		var ot: GameEnums.ObjectType = _target.get_object_type()
		if ot == GameEnums.ObjectType.WHEEL:
			brain.on_used_wheel()
