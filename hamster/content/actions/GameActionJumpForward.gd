class_name GameActionJumpForward
extends GameAction

var _jump_velocity: Vector3 = Vector3.ZERO

func _init() -> void:
	action_type = GameEnums.ActionType.JUMP_FORWARD
	duration    = 0.5

func _on_start(_target: Node) -> void:
	var attrs := _attrs()
	var force := (attrs.get_value(GameEnums.AttributeID.JUMP_FORCE) if attrs else 0.6) * 180.0
	var dir_x := 1.0
	if _character and _character.has_method("get_facing"):
		dir_x = _character.get_facing()
	_jump_velocity = Vector3(dir_x * force * 0.7, force * 0.8, 0.0)

func _on_tick(delta: float) -> void:
	_jump_velocity.y -= 400.0 * delta
	if _character is Node3D:
		var c := _character as Node3D
		c.global_position += _jump_velocity * delta
		c.global_position.z = 0.0
	var attrs := _attrs()
	if attrs:
		attrs.add(GameEnums.AttributeID.ENERGY, -0.005 * delta)
