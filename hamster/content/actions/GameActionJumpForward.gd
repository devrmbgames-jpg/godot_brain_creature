class_name GameActionJumpForward
extends GameAction


func _init() -> void:
	action_type = GameEnums.ActionType.JUMP_FORWARD
	duration    = 0.5

func _can_execute(_target: Node3D) -> bool:
	if _character :
		return _character.is_on_floor()
	return false

func _on_tick(delta: float) -> void:
	if not _character:
		return
	
	if _character.jump_forward() :
		var attrs := _attrs()
		if attrs:
			attrs.add(GameEnums.AttributeID.ENERGY, -0.005 * delta)
		
		_timer = 0.0
