class_name GameActionPush
extends GameAction

var _target: Node3D = null

func _init() -> void:
	action_type = GameEnums.ActionType.PUSH
	duration    = 0.5
	reach       = 55.0

func _can_execute(target: Node3D) -> bool:
	if target == null:
		return false
	if not target.has_method("can_be_pushed"):
		return false
	return _distance_to(target) <= reach

func _on_start(target: Node3D) -> void:
	_target = target

func _on_finish(_t: Node3D) -> void:
	if _target == null or not _target.has_method("on_pushed"):
		return
	var dir := Vector3.RIGHT
	if _character and _target :
		dir = _character.global_position.direction_to(_target.global_position).normalized()
		dir.z = 0.0
	var attrs := _attrs()
	var strength := (attrs.get_value(GameEnums.AttributeID.SIZE) * 10.0 if attrs else 5.0)
	_target.on_pushed(dir, strength)
	if attrs:
		attrs.add(GameEnums.AttributeID.ENERGY, -0.02)
