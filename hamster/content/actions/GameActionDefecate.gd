class_name GameActionDefecate
extends GameAction

func _init() -> void:
	action_type = GameEnums.ActionType.DEFECATE
	duration    = 0.8

func _can_execute(_target: Node) -> bool:
	var attrs := _attrs()
	if attrs == null:
		return false
	return attrs.get_value(GameEnums.AttributeID.INTESTINE_FULLNESS) > 0.05

func _on_finish(_target: Node) -> void:
	var brain := _brain()
	if brain:
		brain.on_defecated()
	# Spawn a poop object in the world
	if _character and _character.has_method("spawn_poop"):
		_character.spawn_poop()
