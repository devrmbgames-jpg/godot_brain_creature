class_name GameActionMate
extends GameAction

var _target: Node = null

func _init() -> void:
	action_type = GameEnums.ActionType.MATE
	duration    = 2.0
	reach       = 50.0

func _can_execute(target: Node) -> bool:
	if target == null or not target.has_method("can_mate"):
		return false
	if _distance_to(target) > reach:
		return false
	var attrs := _attrs()
	if attrs == null:
		return false
	# Only adults can mate
	if attrs.get_value(GameEnums.AttributeID.AGE) < 0.2:
		return false
	if attrs.get_value(GameEnums.AttributeID.DRIVE_SEX_DRIVE) < 0.3:
		return false
	return target.can_mate(_character)

func _on_start(target: Node) -> void:
	_target = target

func _on_finish(_t: Node) -> void:
	if _target == null:
		return
	var brain := _brain()
	if brain:
		brain.on_mated()
	if _target.has_method("on_mated_with"):
		_target.on_mated_with(_character)
