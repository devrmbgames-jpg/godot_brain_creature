class_name GameActionPickUp
extends GameAction

var _target: Node3D = null

func _init() -> void:
	action_type = GameEnums.ActionType.PICK_UP
	duration    = 0.4
	reach       = 50.0

func _can_execute(target: Node3D) -> bool:
	if target == null or not target.has_method("can_be_picked_up"):
		return false
	if not target.can_be_picked_up():
		return false
	if _distance_to(target) > reach:
		return false
	# Check carry capacity
	var attrs := _attrs()
	if attrs and _character.has_method("get_held_object"):
		if _character.get_held_object() != null:
			return false  # already holding something
	return true

func _on_start(target: Node3D) -> void:
	_target = target

func _on_finish(_t: Node3D) -> void:
	if _target == null:
		return
	if _character.has_method("set_held_object"):
		_character.set_held_object(_target)
	if _target.has_method("on_picked_up"):
		_target.on_picked_up(_character)
