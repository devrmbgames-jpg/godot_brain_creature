class_name GameActionGiveBirth
extends GameAction

func _init() -> void:
	action_type = GameEnums.ActionType.GIVE_BIRTH
	duration    = 3.0

func _can_execute(_target: Node3D) -> bool:
	var attrs := _attrs()
	if attrs == null:
		return false
	return attrs.get_value(GameEnums.AttributeID.PREGNANCY) >= 1.0

func _on_finish(_target: Node3D) -> void:
	if _character and _character.has_method("spawn_offspring"):
		_character.spawn_offspring()
	var attrs := _attrs()
	if attrs:
		attrs.set_val(GameEnums.AttributeID.PREGNANCY, 0.0)
		attrs.set_val(GameEnums.AttributeID.GESTATION_TIMER, 0.0)
		attrs.add(GameEnums.AttributeID.HEALTH, -0.15)
		attrs.add(GameEnums.AttributeID.ENERGY, -0.2)
	var brain := _brain()
	if brain:
		brain.chemistry.on_mating()  # oxytocin burst after birth
