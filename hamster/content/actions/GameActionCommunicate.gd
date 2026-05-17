class_name GameActionCommunicate
extends GameAction

var _target: Node3D = null

func _init() -> void:
	action_type = GameEnums.ActionType.COMMUNICATE
	duration    = 1.5
	reach       = 80.0

func _can_execute(target: Node3D) -> bool:
	return (target != null
		and target.has_method("receive_communication")
		and _distance_to(target) <= reach)

func _on_start(target: Node3D) -> void:
	_target = target

func _on_finish(_t: Node3D) -> void:
	if _target == null:
		return
	var brain := _brain()
	# Share a summary of own drive state so the other creature can respond
	var payload := {}
	if brain:
		payload = brain.debug_state()
		brain.on_social_contact(_target)
	if _target.has_method("receive_communication"):
		_target.receive_communication(_character, payload)
