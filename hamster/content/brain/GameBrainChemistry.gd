class_name GameBrainChemistry
## Biochemistry: manages circulating hormone levels and their effects on drives.

var levels: Array[float] = []  ## current hormone concentrations [0,1]
var _dna: GameBrainDNA

func _init(dna: GameBrainDNA) -> void:
	_dna = dna
	levels.resize(GameEnums.HormoneType.MAX)
	levels.fill(0.0)

## Inject a dose of a hormone (clamped to [0,1]).
func emit(hormone: GameEnums.HormoneType, dose: float) -> void:
	if hormone < GameEnums.HormoneType.MAX:
		levels[hormone] = clampf(levels[hormone] + dose, 0.0, 1.0)

## Apply hormone effects to an attribute container and decay levels.
func tick(delta: float, attrs: GameAttributeContainer) -> void:
	for h in GameEnums.HormoneType.MAX:
		if levels[h] < 0.001:
			continue
		# Apply drive modifiers from DNA matrix
		for d in GameEnums.DriveType.MAX:
			var effect: float = _dna.hormone_drive_matrix[h][d] * levels[h] * delta
			var attr_id: int = GameEnums.DRIVE_TO_ATTRIBUTE.get(d, -1)
			if attr_id >= 0:
				attrs.add(attr_id, effect)
		# Natural decay
		levels[h] = lerpf(levels[h], 0.0, _dna.hormone_decay_rates[h] * delta)

## Convenience emitters used by the brain in specific situations.
func on_threatened() -> void:
	emit(GameEnums.HormoneType.ADRENALINE, 0.6)
	emit(GameEnums.HormoneType.CORTISOL,   0.3)

func on_social_contact() -> void:
	emit(GameEnums.HormoneType.OXYTOCIN,  0.4)
	emit(GameEnums.HormoneType.SEROTONIN, 0.2)

func on_reward() -> void:
	emit(GameEnums.HormoneType.ENDORPHIN, 0.4)
	emit(GameEnums.HormoneType.SEROTONIN, 0.2)

func on_mating() -> void:
	emit(GameEnums.HormoneType.TESTOSTERONE, 0.5)
	emit(GameEnums.HormoneType.OXYTOCIN,     0.6)
	emit(GameEnums.HormoneType.ENDORPHIN,    0.3)

func on_tired() -> void:
	emit(GameEnums.HormoneType.MELATONIN, 0.5)

func on_pain(severity: float) -> void:
	emit(GameEnums.HormoneType.CORTISOL,  severity * 0.5)
	emit(GameEnums.HormoneType.ADRENALINE, severity * 0.3)

func on_ate(nutrition: float) -> void:
	emit(GameEnums.HormoneType.INSULIN,   nutrition * 0.4)
	emit(GameEnums.HormoneType.SEROTONIN, nutrition * 0.1)

func on_exercise() -> void:
	emit(GameEnums.HormoneType.ENDORPHIN, 0.1)
