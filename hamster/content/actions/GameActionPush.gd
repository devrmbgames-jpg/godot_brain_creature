class_name GameActionPush
extends GameAction

var _target: Node = null

func _init() -> void:
	action_type = GameEnums.ActionType.PUSH
	duration    = 0.5
	reach       = 55.0

func _can_execute(target: Node) -> bool:
	if target == null:
		return false
	if not target.has_method("can_be_pushed"):
		return false
	return _distance_to(target) <= reach

func _on_start(target: Node) -> void:
	_target = target

func _on_finish(_t: Node) -> void:
	if _target == null or not _target.has_method("on_pushed"):
		return
	var dir := Vector3.RIGHT
	if _character is Node3D and _target is Node3D:
		dir = ((_target as Node3D).global_position - (_character as Node3D).global_position).normalized()
		dir.z = 0.0
	var attrs := _attrs()
	var strength := (attrs.get_value(GameEnums.AttributeID.SIZE) * 300.0 if attrs else 150.0)
	_target.on_pushed(dir, strength)
	if attrs:
		attrs.add(GameEnums.AttributeID.ENERGY, -0.02)
