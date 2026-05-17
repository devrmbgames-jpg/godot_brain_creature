class_name GameObjectWheel
extends GameObject

var _spin_speed: float  = 0.0
var _is_in_use:  bool   = false

func _on_init() -> void:
	object_type  = GameEnums.ObjectType.WHEEL
	display_name = "Exercise Wheel"

func _process(delta: float) -> void:
	if _spin_speed > 0.001:
		_spin_speed = lerpf(_spin_speed, 0.0, 0.5 * delta)
		rotate_y(_spin_speed * delta)

func on_use_started(_who: Node) -> void:
	_is_in_use = true

func on_use_tick(delta: float, who: Node) -> void:
	_spin_speed = lerpf(_spin_speed, 10.0, 2.0 * delta)
	# Notify brain tick by tick
	if who and who.has_method("get_brain"):
		var brain: GameBrain = who.get_brain()
		if brain:
			brain.chemistry.on_exercise()

func on_used(_who: Node) -> void:
	_is_in_use = false

func get_object_type() -> int:
	return object_type
