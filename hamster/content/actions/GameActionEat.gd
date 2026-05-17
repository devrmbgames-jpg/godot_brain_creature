class_name GameActionEat
extends GameAction
## Universal bite/gnaw/eat action.
## The hamster can bite ANYTHING — edible or not.
## Non-edible objects may injure or poison the hamster.

var _target: Node3D = null

func _init() -> void:
	action_type = GameEnums.ActionType.EAT
	duration    = 1.2
	reach       = 50.0

func _can_execute(target: Node3D) -> bool:
	if target == null:
		return false
	return _distance_to(target) <= reach

func _on_start(target: Node3D) -> void:
	_target = target
	# Move toward target while there's still time on the clock
	if _character and target :
		_character.global_position = _character.global_position.lerp(target.global_position, 0.5)
		_character.global_position.z = 0.0

func _on_finish(_t: Node3D) -> void:
	if _target == null:
		return
	if not _target.has_method("get_eat_properties"):
		# Non-interactive object: gnaw it, might break or cause harm
		_apply_gnaw_non_edible()
		return
	var props: GameObject.EatProperty = _target.get_eat_properties()
	var nutrition: float  = props.nutrition
	var toxicity: float   = props.toxicity
	var is_edible: bool   = props.edible
	var damage_object: float = props.bite_damage

	var brain := _brain()
	if brain:
		brain.on_ate(nutrition, toxicity)

	if not is_edible:
		# Gnawing non-food may damage teeth, cause pain
		var attrs := _attrs()
		if attrs:
			attrs.add(GameEnums.AttributeID.DRIVE_PAIN, 0.1)
			attrs.add(GameEnums.AttributeID.HEALTH, -0.05)

	# Notify the object it was bitten
	if _target.has_method("on_bitten"):
		_target.on_bitten(damage_object)

func _apply_gnaw_non_edible() -> void:
	var attrs := _attrs()
	if attrs:
		attrs.add(GameEnums.AttributeID.DRIVE_PAIN, 0.15)
		attrs.add(GameEnums.AttributeID.HEALTH, -0.03)
		attrs.add(GameEnums.AttributeID.TOXIN_LEVEL, 0.05)
