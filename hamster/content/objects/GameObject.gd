class_name GameObject
extends CharacterBody3D
## Base class for all interactive world objects.
## Extend this and override the virtual methods to create new object types.

signal object_destroyed(object: Node)
signal object_interacted(object: Node, interactor: Node)

## Unique type identifier — must be set by each subclass.
@export var object_type: GameEnums.ObjectType = GameEnums.ObjectType.UNKNOWN
@export var display_name: String = "Object"

## Health of the object itself (0 = destroyed, normalised 0-1).
@export var durability: float = 1.0

## Whether this object blocks character movement.
@export var blocks_movement: bool = false

var is_held: bool = false
var holder: Node = null

class EatProperty :
	var edible: bool
	var nutrition: float
	var toxicity: float
	var bite_damage: float
	func _init(
		p_edible: bool = false,
		p_nutrition: float = 0.0,
		p_toxicity: float = 0.2,
		p_bite_damage: float = 0.1) -> void:
			edible = p_edible
			nutrition = p_nutrition
			toxicity = p_toxicity
			bite_damage = p_bite_damage

class DrinkProperty :
	var amount: float
	var force: float
	var toxicity: float
	
	func _init(
		p_amount : float = 0.0,
		p_force : float = 0.0,
		p_tixucuty : float = 0.0) -> void:
			amount = p_amount
			force = p_force
			toxicity = p_tixucuty
	



func _ready() -> void:
	_on_init()

## Override in subclasses for setup.
func _on_init() -> void:
	pass

func get_object_type() -> int:
	return object_type

# ── Interaction interface ─────────────────────────────────────────────────────
## All methods below return false / empty by default.
## Override the ones that apply to the specific object type.

func can_be_picked_up() -> bool:
	return false

func can_be_pushed() -> bool:
	return false

func get_eat_properties() -> EatProperty:
	return EatProperty.new(
		false,
		0.0,
		0.2,
		0.1
	)

func get_drink_properties() -> DrinkProperty:
	return DrinkProperty.new(
		0.0,
		0.0,
		0.0
	)

func get_comfort_bonus() -> float:
	return 0.0

func on_bitten(damage: float) -> void:
	_damage(damage)

func on_pushed(direction: Vector3, force: float) -> void:
	pass

func on_picked_up(who: Node) -> void:
	is_held = true
	holder  = who
	hide()

func on_dropped(drop_position: Vector3) -> void:
	is_held = false
	holder  = null
	if not drop_position.is_zero_approx():
		global_position = drop_position
	show()

func on_used(who: Node) -> void:
	object_interacted.emit(self, who)

func on_use_started(_who: Node) -> void:
	pass

func on_use_tick(_delta: float, _who: Node) -> void:
	pass

func receive_communication(_sender: Node, _payload: Dictionary) -> void:
	pass

# ── Durability ────────────────────────────────────────────────────────────────

func _damage(amount: float) -> void:
	durability = clampf(durability - amount, 0.0, 1.0)
	if durability <= 0.0:
		_on_destroyed()

func _on_destroyed() -> void:
	object_destroyed.emit(self)
	queue_free()
