class_name GameActionWalk
extends GameAction

var _target_position: Vector3 = Vector3.ZERO
var _target_node: Node = null

func _init() -> void:
	action_type = GameEnums.ActionType.WALK
	duration    = 2.0

func _on_start(target: Node) -> void:
	_target_node = target
	if target is Node3D:
		_target_position = (target as Node3D).global_position
	elif _character is Node3D:
		# Walk toward remembered position or random offset
		var brain := _brain()
		if brain:
			var mem_pos := brain.memory.recall_position(GameEnums.ObjectType.UNKNOWN)
			if mem_pos != Vector3.ZERO:
				_target_position = mem_pos
			else:
				var rng := Vector3(randf_range(-100, 100), randf_range(-50, 50), 0)
				_target_position = (_character as Node3D).global_position + rng

func _on_tick(delta: float) -> void:
	var attrs := _attrs()
	if attrs == null:
		return
	_move_toward(_target_position, 0.5)
	attrs.add(GameEnums.AttributeID.ENERGY, -0.001 * delta)

func _can_execute(_target: Node) -> bool:
	var attrs := _attrs()
	if attrs == null:
		return true
	return attrs.get_value(GameEnums.AttributeID.HEALTH) > 0.0
