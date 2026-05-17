class_name GameActionRun
extends GameAction

var _target_position: Vector3 = Vector3.ZERO

func _init() -> void:
	action_type = GameEnums.ActionType.RUN
	duration    = 1.5

func _on_start(target: Node) -> void:
	if target is Node3D:
		_target_position = (target as Node3D).global_position
	elif _character is Node3D:
		var dir := Vector3(randf_range(-1, 1), randf_range(-0.5, 0.5), 0).normalized()
		_target_position = (_character as Node3D).global_position + dir * 200.0

func _on_tick(delta: float) -> void:
	var attrs := _attrs()
	if attrs == null:
		return
	
	_move_toward(_target_position, 1.0)
	attrs.add(GameEnums.AttributeID.ENERGY, -0.003 * delta)
	# Running also triggers exercise hormone
	if randf() < 0.05:
		var brain := _brain()
		if brain:
			brain.chemistry.on_exercise()

func _can_execute(_target: Node) -> bool:
	var attrs := _attrs()
	if attrs == null:
		return true
	return attrs.get_value(GameEnums.AttributeID.ENERGY) > 0.1
