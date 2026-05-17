class_name GameActionDrop
extends GameAction

func _init() -> void:
	action_type = GameEnums.ActionType.DROP
	duration    = 0.2

func _can_execute(_target: Node3D) -> bool:
	if not _character.has_method("get_held_object"):
		return false
	return _character.get_held_object() != null

func _on_finish(_target: Node3D) -> void:
	if not _character.has_method("get_held_object"):
		return
	var held: Node3D = _character.get_held_object()
	if held == null:
		return
	_character.set_held_object(null)
	if held.has_method("on_dropped"):
		var drop_pos := Vector3.ZERO
		if _character:
			drop_pos = _character.to_global(Vector3.FORWARD)
		held.on_dropped(drop_pos)
