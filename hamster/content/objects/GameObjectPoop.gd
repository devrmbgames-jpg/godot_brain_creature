class_name GameObjectPoop
extends GameObject

var _decay_timer: float = 30.0  ## seconds until it disappears

func _on_init() -> void:
	object_type  = GameEnums.ObjectType.POOP
	display_name = "Poop"
	durability   = 0.3

func _process(delta: float) -> void:
	_decay_timer -= delta
	if _decay_timer <= 0.0:
		object_destroyed.emit(self)
		queue_free()

func get_eat_properties() -> EatProperty:
	return EatProperty.new(
		false,
		-0.1,
		0.4,
		0.0
	)


func can_be_picked_up() -> bool:
	return true
