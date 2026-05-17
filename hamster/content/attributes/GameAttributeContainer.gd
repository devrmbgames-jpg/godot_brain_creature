class_name GameAttributeContainer
extends Resource

var _attrs: Dictionary[GameEnums.AttributeID, GameAttribute] = {}

## Build the default attribute set. All values normalized to [-1,1] via GameAttribute.
func _init() -> void:
	_define(GameEnums.AttributeID.HEALTH,             1.0,  0.0,  1.0)
	_define(GameEnums.AttributeID.MAX_HEALTH,         1.0,  0.0,  1.0)
	_define(GameEnums.AttributeID.ENERGY,             1.0,  0.0,  1.0)
	_define(GameEnums.AttributeID.MAX_ENERGY,         1.0,  0.0,  1.0)
	_define(GameEnums.AttributeID.AGE,                0.0,  0.0,  1.0)
	_define(GameEnums.AttributeID.MAX_AGE,            1.0,  0.0,  1.0)
	_define(GameEnums.AttributeID.WEIGHT,             0.5,  0.0,  1.0)
	_define(GameEnums.AttributeID.SIZE,               0.5,  0.0,  1.0)
	_define(GameEnums.AttributeID.SPEED,              1.0,  0.0,  1.0)
	_define(GameEnums.AttributeID.MAX_SPEED,          1.0,  0.0,  1.0)

	# Drives – 0 = satisfied, 1 = urgent
	_define(GameEnums.AttributeID.DRIVE_HUNGER,       0.0,  0.0,  1.0)
	_define(GameEnums.AttributeID.DRIVE_THIRST,       0.0,  0.0,  1.0)
	_define(GameEnums.AttributeID.DRIVE_TIREDNESS,    0.0,  0.0,  1.0)
	_define(GameEnums.AttributeID.DRIVE_LONELINESS,   0.0,  0.0,  1.0)
	_define(GameEnums.AttributeID.DRIVE_PAIN,         0.0,  0.0,  1.0)
	_define(GameEnums.AttributeID.DRIVE_BOREDOM,      0.0,  0.0,  1.0)
	_define(GameEnums.AttributeID.DRIVE_FEAR,         0.0,  0.0,  1.0)
	_define(GameEnums.AttributeID.DRIVE_ANGER,        0.0,  0.0,  1.0)
	_define(GameEnums.AttributeID.DRIVE_SEX_DRIVE,    0.0,  0.0,  1.0)
	_define(GameEnums.AttributeID.DRIVE_BOWEL_FULL,   0.0,  0.0,  1.0)

	# Reproductive
	_define(GameEnums.AttributeID.SEX_ATTR,           0.0,  0.0,  1.0)
	_define(GameEnums.AttributeID.PREGNANCY,          0.0,  0.0,  1.0)
	_define(GameEnums.AttributeID.GESTATION_TIMER,    0.0,  0.0,  1.0)
	_define(GameEnums.AttributeID.GESTATION_TIME,     1.0,  0.0,  1.0)
	_define(GameEnums.AttributeID.FERTILITY,          1.0,  0.0,  1.0)

	# Senses
	_define(GameEnums.AttributeID.SIGHT_RANGE,        1.0,  0.0,  1.0)
	_define(GameEnums.AttributeID.SMELL_RANGE,        0.5,  0.0,  1.0)

	# Locomotion
	_define(GameEnums.AttributeID.MAX_CARRY_WEIGHT,   0.5,  0.0,  1.0)
	_define(GameEnums.AttributeID.WALK_SPEED,         0.4,  0.0,  1.0)
	_define(GameEnums.AttributeID.RUN_SPEED,          0.8,  0.0,  1.0)
	_define(GameEnums.AttributeID.JUMP_FORCE,         0.6,  0.0,  1.0)

	# Derived wellbeing
	_define(GameEnums.AttributeID.HAPPINESS,          0.5,  0.0,  1.0)
	_define(GameEnums.AttributeID.COMFORT,            0.5,  0.0,  1.0)

	# Digestive
	_define(GameEnums.AttributeID.STOMACH_FULLNESS,   0.0,  0.0,  1.0)
	_define(GameEnums.AttributeID.STOMACH_MAX,        1.0,  0.0,  1.0)
	_define(GameEnums.AttributeID.INTESTINE_FULLNESS, 0.0,  0.0,  1.0)
	_define(GameEnums.AttributeID.INTESTINE_MAX,      1.0,  0.0,  1.0)
	_define(GameEnums.AttributeID.DIGESTION_RATE,     0.3,  0.0,  1.0)

	# Toxicology
	_define(GameEnums.AttributeID.TOXIN_LEVEL,        0.0,  0.0,  1.0)

func _define(id: GameEnums.AttributeID, value: float, mn: float, mx: float) -> void:
	_attrs[id] = GameAttribute.new(id, value, mn, mx)

func get_attr(id: GameEnums.AttributeID) -> GameAttribute:
	return _attrs.get(id)

func get_value(id: GameEnums.AttributeID) -> float:
	var a: GameAttribute = _attrs.get(id)
	return a.value if a else 0.0

func set_val(id: GameEnums.AttributeID, v: float) -> void:
	var a: GameAttribute = _attrs.get(id)
	if a:
		a.set_value(v)

func add(id: GameEnums.AttributeID, delta: float) -> void:
	var a: GameAttribute = _attrs.get(id)
	if a:
		a.add(delta)

func ratio(id: GameEnums.AttributeID) -> float:
	var a: GameAttribute = _attrs.get(id)
	return a.ratio() if a else 0.0

func normalized(id: GameEnums.AttributeID) -> float:
	var a: GameAttribute = _attrs.get(id)
	return a.normalized() if a else 0.0

## Register a custom attribute at runtime (for extensibility).
func register(id: GameEnums.AttributeID, value: float, mn: float = 0.0, mx: float = 1.0) -> void:
	if not _attrs.has(id):
		_attrs[id] = GameAttribute.new(id, value, mn, mx)
