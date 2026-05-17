class_name GameActionWalk
extends GameAction

var _target_position: Vector3 = Vector3.ZERO
var _target_node: Node3D = null

func _init() -> void:
	action_type = GameEnums.ActionType.WALK
	duration    = 2.0

func _on_start(target: Node3D) -> void:
	_target_node = target
	
	if target :
		_target_position = (target as Node3D).global_position
	elif _character :
		# Walk toward remembered position or random offset
		var brain := _brain()
		if brain:
			var mem_pos := brain.memory.recall_position(GameEnums.ObjectType.UNKNOWN)
			if mem_pos != Vector3.ZERO:
				_target_position = mem_pos
			else:
				var dir := Vector3(randf_range(-1, 1), 0, 0).normalized()
				_target_position = _character.global_position + dir * randf_range(1.0, 4.0)

func _on_tick(delta: float) -> void:
	var attrs := _attrs()
	if attrs == null:
		return
	_move_toward(_target_position, 0.5)
	attrs.add(GameEnums.AttributeID.ENERGY, -0.001 * delta)

func _can_execute(_target: Node3D) -> bool:
	var attrs := _attrs()
	if attrs == null:
		return true
	return attrs.get_value(GameEnums.AttributeID.HEALTH) > 0.0

func _on_finish(_target: Node) -> void:
	if _character:
		_character.motion = Vector3.ZERO
