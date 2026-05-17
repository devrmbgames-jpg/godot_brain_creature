class_name GameBrainDNA
## Encodes heritable parameters that shape brain behaviour, drive rates, and hormone curves.
## All values are normalised to [0,1] so they can be stored and mutated uniformly.

# ── Learning ──────────────────────────────────────────────────────────────────
var learning_rate:      float = 0.15  ## how fast dendrite weights grow
var forget_rate:        float = 0.01  ## weight decay per tick
var concept_lobe_size:  int   = 16    ## number of concept neurons

# ── Drive drift rates (per second, normalised) ────────────────────────────────
var drive_rates: Array[float] = []

# ── Hormone weights: how much each hormone affects each drive ─────────────────
## [hormone][drive] matrix, values in [-1, 1]
var hormone_drive_matrix: Array = []

# ── Biochemistry curves (shape parameters 0-1) ───────────────────────────────
var hormone_decay_rates: Array[float] = []

# ── Physical defaults ─────────────────────────────────────────────────────────
var walk_speed:    float = 0.4
var run_speed:     float = 0.8
var jump_force:    float = 0.6
var sight_range:   float = 1.0
var max_age:       float = 1.0

func _init() -> void:
	_init_drive_rates()
	_init_hormone_matrix()
	_init_hormone_decay()

func _init_drive_rates() -> void:
	drive_rates.resize(GameEnums.DriveType.MAX)
	drive_rates[GameEnums.DriveType.HUNGER]     = 0.008
	drive_rates[GameEnums.DriveType.THIRST]     = 0.010
	drive_rates[GameEnums.DriveType.TIREDNESS]  = 0.006
	drive_rates[GameEnums.DriveType.LONELINESS] = 0.004
	drive_rates[GameEnums.DriveType.PAIN]       = 0.000
	drive_rates[GameEnums.DriveType.BOREDOM]    = 0.005
	drive_rates[GameEnums.DriveType.FEAR]       = 0.000
	drive_rates[GameEnums.DriveType.ANGER]      = 0.002
	drive_rates[GameEnums.DriveType.SEX_DRIVE]  = 0.003
	drive_rates[GameEnums.DriveType.BOWEL_FULL] = 0.000

func _init_hormone_matrix() -> void:
	hormone_drive_matrix.resize(GameEnums.HormoneType.MAX)
	for h in GameEnums.HormoneType.MAX:
		var row: Array[float] = []
		row.resize(GameEnums.DriveType.MAX)
		row.fill(0.0)
		hormone_drive_matrix[h] = row
	# Adrenaline raises fear, suppresses tiredness
	hormone_drive_matrix[GameEnums.HormoneType.ADRENALINE][GameEnums.DriveType.FEAR]      =  0.3
	hormone_drive_matrix[GameEnums.HormoneType.ADRENALINE][GameEnums.DriveType.TIREDNESS] = -0.1
	# Testosterone raises sex drive and anger
	hormone_drive_matrix[GameEnums.HormoneType.TESTOSTERONE][GameEnums.DriveType.SEX_DRIVE] =  0.4
	hormone_drive_matrix[GameEnums.HormoneType.TESTOSTERONE][GameEnums.DriveType.ANGER]     =  0.2
	# Serotonin reduces loneliness, boredom, anger
	hormone_drive_matrix[GameEnums.HormoneType.SEROTONIN][GameEnums.DriveType.LONELINESS] = -0.3
	hormone_drive_matrix[GameEnums.HormoneType.SEROTONIN][GameEnums.DriveType.BOREDOM]    = -0.2
	hormone_drive_matrix[GameEnums.HormoneType.SEROTONIN][GameEnums.DriveType.ANGER]      = -0.2
	# Cortisol raises pain sensitivity, fear
	hormone_drive_matrix[GameEnums.HormoneType.CORTISOL][GameEnums.DriveType.PAIN]  =  0.3
	hormone_drive_matrix[GameEnums.HormoneType.CORTISOL][GameEnums.DriveType.FEAR]  =  0.2
	# Melatonin raises tiredness
	hormone_drive_matrix[GameEnums.HormoneType.MELATONIN][GameEnums.DriveType.TIREDNESS] =  0.5
	# Oxytocin reduces loneliness
	hormone_drive_matrix[GameEnums.HormoneType.OXYTOCIN][GameEnums.DriveType.LONELINESS] = -0.4
	# Endorphin reduces pain, anger
	hormone_drive_matrix[GameEnums.HormoneType.ENDORPHIN][GameEnums.DriveType.PAIN]  = -0.4
	hormone_drive_matrix[GameEnums.HormoneType.ENDORPHIN][GameEnums.DriveType.ANGER] = -0.2
	# Insulin reduces hunger (glucose metabolism)
	hormone_drive_matrix[GameEnums.HormoneType.INSULIN][GameEnums.DriveType.HUNGER] = -0.2

func _init_hormone_decay() -> void:
	hormone_decay_rates.resize(GameEnums.HormoneType.MAX)
	hormone_decay_rates[GameEnums.HormoneType.ADRENALINE]   = 0.15
	hormone_decay_rates[GameEnums.HormoneType.TESTOSTERONE]  = 0.02
	hormone_decay_rates[GameEnums.HormoneType.ESTROGEN]      = 0.02
	hormone_decay_rates[GameEnums.HormoneType.SEROTONIN]     = 0.05
	hormone_decay_rates[GameEnums.HormoneType.CORTISOL]      = 0.04
	hormone_decay_rates[GameEnums.HormoneType.INSULIN]       = 0.08
	hormone_decay_rates[GameEnums.HormoneType.MELATONIN]     = 0.03
	hormone_decay_rates[GameEnums.HormoneType.OXYTOCIN]      = 0.06
	hormone_decay_rates[GameEnums.HormoneType.ENDORPHIN]     = 0.07

## Crossover two parents' DNA with mutation. Returns new child DNA.
static func crossover(a: GameBrainDNA, b: GameBrainDNA, mutation: float = 0.05) -> GameBrainDNA:
	var child := GameBrainDNA.new()
	child.learning_rate     = _mix(a.learning_rate,     b.learning_rate,     mutation)
	child.forget_rate       = _mix(a.forget_rate,       b.forget_rate,       mutation)
	child.concept_lobe_size = roundi(_mix(a.concept_lobe_size, b.concept_lobe_size, mutation))
	child.walk_speed        = _mix(a.walk_speed,        b.walk_speed,        mutation)
	child.run_speed         = _mix(a.run_speed,         b.run_speed,         mutation)
	child.jump_force        = _mix(a.jump_force,        b.jump_force,        mutation)
	child.sight_range       = _mix(a.sight_range,       b.sight_range,       mutation)
	child.max_age           = _mix(a.max_age,           b.max_age,           mutation)
	for d in GameEnums.DriveType.MAX:
		child.drive_rates[d] = _mix(a.drive_rates[d], b.drive_rates[d], mutation)
	for h in GameEnums.HormoneType.MAX:
		child.hormone_decay_rates[h] = _mix(a.hormone_decay_rates[h], b.hormone_decay_rates[h], mutation)
		for d in GameEnums.DriveType.MAX:
			child.hormone_drive_matrix[h][d] = _mix(
				a.hormone_drive_matrix[h][d], b.hormone_drive_matrix[h][d], mutation, -1.0, 1.0)
	return child

static func _mix(av: float, bv: float, mutation: float, mn: float = 0.0, mx: float = 1.0) -> float:
	var base := lerpf(av, bv, randf())
	var noise := (randf() * 2.0 - 1.0) * mutation
	return clampf(base + noise, mn, mx)
