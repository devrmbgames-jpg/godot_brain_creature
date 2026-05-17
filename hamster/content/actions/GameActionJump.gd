class_name GameActionJump
extends GameAction

## Jump straight up.
var _jump_velocity: Vector3 = Vector3.ZERO
var _elapsed: float = 0.0

func _init() -> void:
	action_type = GameEnums.ActionType.JUMP_UP
	duration    = 0.6

func _on_start(_target: Node) -> void:
	_elapsed = 0.0
	var attrs := _attrs()
	var force := (attrs.get_value(GameEnums.AttributeID.JUMP_FORCE) if attrs else 0.6) * 200.0
	_jump_velocity = Vector3(0.0, force, 0.0)

func _on_tick(delta: float) -> void:
	_elapsed += delta
	if not _character is Node3D:
		return
	var c := _character as Node3D
	_jump_velocity.y -= 400.0 * delta   ## gravity
	c.global_position += _jump_velocity * delta
	c.global_position.z = 0.0           ## enforce 2D plane
	var attrs := _attrs()
	if attrs:
		attrs.add(GameEnums.AttributeID.ENERGY, -0.005 * delta)
