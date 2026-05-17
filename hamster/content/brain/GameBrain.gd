class_name GameBrain
extends Node
## Creatures-style neural brain.
## Architecture (lobes and data-flow):
##
##  PERCEPTION ──► STIMULUS ──► CONCEPT ──► VERB   ┐
##  DRIVE      ──►                        ► NOUN   ─┤► DECISION (verb×noun)
##                                                  ┘
##
## Every tick:
##   1. Sense world → stimulate PERCEPTION + DRIVE lobes
##   2. Forward-propagate through STIMULUS → CONCEPT → VERB / NOUN
##   3. Score every (verb, noun) pair → pick winner → emit chosen_action signal
##   4. After action executes, compute drive-delta reward → run learning pass

signal chosen_action(action_type: int, target_object_type: int, target_object: Node)
signal drive_changed(drive_type: int, new_value: float)
@warning_ignore("unused_signal")
signal hormone_emitted(hormone_type: int, level: float)

# ── Sub-systems ───────────────────────────────────────────────────────────────
var dna:       GameBrainDNA
var chemistry: GameBrainChemistry
var memory:    GameBrainMemory

# ── Lobes ─────────────────────────────────────────────────────────────────────
var lobe_perception: GameBrainLobe  ## object_type × 4 features per type
var lobe_drive:      GameBrainLobe  ## one neuron per drive
var lobe_stimulus:   GameBrainLobe  ## combined input layer
var lobe_concept:    GameBrainLobe  ## associative hidden layer
var lobe_verb:       GameBrainLobe  ## one neuron per action
var lobe_noun:       GameBrainLobe  ## one neuron per object type

# ── State ─────────────────────────────────────────────────────────────────────
var current_action: int = GameEnums.ActionType.IDLE
var current_target_type: int = GameEnums.ObjectType.UNKNOWN
var current_target: Node = null

var _drives_before:  Array[float] = []
var _time:           float = 0.0
var _tick_interval:  float = 0.2  ## brain ticks at 5 Hz by default

# Features per object in the perception lobe:
# [0] presence (0/1), [1] distance (normalised), [2] direction_x, [3] direction_y
const PERCEPTION_FEATURES: int = 4





func _init(p_dna: GameBrainDNA = null) -> void:
	dna = p_dna if p_dna else GameBrainDNA.new()
	chemistry = GameBrainChemistry.new(dna)
	memory    = GameBrainMemory.new()
	_build_lobes()
	_drives_before.resize(GameEnums.DriveType.MAX)
	_drives_before.fill(0.0)

func _build_lobes() -> void:
	var n_obj   := GameEnums.ObjectType.MAX
	var n_drive := GameEnums.DriveType.MAX
	var n_act   := GameEnums.ActionType.MAX
	
	lobe_perception = GameBrainLobe.new(GameEnums.LobeType.PERCEPTION,
		n_obj * PERCEPTION_FEATURES, 0.0)
	lobe_drive      = GameBrainLobe.new(GameEnums.LobeType.DRIVE,      n_drive,          0.0)
	lobe_stimulus   = GameBrainLobe.new(GameEnums.LobeType.STIMULUS,   n_obj + n_drive,  0.1)
	lobe_concept    = GameBrainLobe.new(GameEnums.LobeType.CONCEPT,    dna.concept_lobe_size, 0.05)
	lobe_verb       = GameBrainLobe.new(GameEnums.LobeType.VERB,       n_act,            0.05)
	lobe_noun       = GameBrainLobe.new(GameEnums.LobeType.NOUN,       n_obj,            0.05)
	
	# Wiring: perception→stimulus (full), drive→stimulus (full)
	lobe_perception.connect_full(lobe_stimulus, 0.05)
	lobe_drive.connect_full(lobe_stimulus, 0.1)
	
	# stimulus→concept sparse (k = 6)
	lobe_stimulus.connect_sparse(lobe_concept, 6, 0.05)
	
	# concept→verb and concept→noun (full)
	lobe_concept.connect_full(lobe_verb, 0.05)
	lobe_concept.connect_full(lobe_noun, 0.05)

# ── Main process ──────────────────────────────────────────────────────────────

func _process(delta: float) -> void:
	_time += delta
	chemistry.tick(delta, _get_attrs())
	_tick_drives(delta)
	_tick_digestion(delta)

	_tick_interval -= delta
	if _tick_interval <= 0.0:
		_tick_interval = 0.2
		_brain_tick()

func _brain_tick() -> void:
	_snapshot_drives()
	_perceive()
	_forward_pass()
	var action: int  = 0
	var noun_idx: int = 0
	var r := _decide(action, noun_idx)
	action = r[0]
	noun_idx = r[1]
	_execute_decision(action, noun_idx)

# ── Attribute helpers ─────────────────────────────────────────────────────────

func _get_attrs() -> GameAttributeContainer:
	var owner_node: Node = get_parent()
	if owner_node and owner_node.has_method("get_attrs"):
		return owner_node.get_attrs()
	return null

func _get_drive(d: int) -> float:
	var attrs := _get_attrs()
	if attrs == null:
		return 0.0
	var attr_id: int = GameEnums.DRIVE_TO_ATTRIBUTE.get(d, -1)
	return attrs.get_value(attr_id) if attr_id >= 0 else 0.0

func _set_drive(d: int, v: float) -> void:
	var attrs := _get_attrs()
	if attrs == null:
		return
	var attr_id: int = GameEnums.DRIVE_TO_ATTRIBUTE.get(d, -1)
	if attr_id >= 0:
		var old := attrs.get_value(attr_id)
		attrs.set_val(attr_id, v)
		if not is_equal_approx(old, v):
			drive_changed.emit(d, v)

func _add_drive(d: int, delta: float) -> void:
	_set_drive(d, _get_drive(d) + delta)

# ── Drives tick ───────────────────────────────────────────────────────────────

func _tick_drives(delta: float) -> void:
	for d in GameEnums.DriveType.MAX:
		var rate: float = dna.drive_rates[d]
		if rate > 0.0:
			_add_drive(d, rate * delta)
	# Derived: if very hungry and food in stomach, reduce hunger via digestion
	var attrs := _get_attrs()
	if attrs:
		var stomach := attrs.get_value(GameEnums.AttributeID.STOMACH_FULLNESS)
		if stomach > 0.01:
			_add_drive(GameEnums.DriveType.HUNGER, -stomach * 0.05 * delta)
		# Trigger melatonin when tiredness is high
		if _get_drive(GameEnums.DriveType.TIREDNESS) > 0.7:
			chemistry.on_tired()

func _tick_digestion(delta: float) -> void:
	var attrs := _get_attrs()
	if attrs == null:
		return
	var stomach := attrs.get_value(GameEnums.AttributeID.STOMACH_FULLNESS)
	if stomach > 0.0:
		var rate: float = attrs.get_value(GameEnums.AttributeID.DIGESTION_RATE) * delta * 0.1
		attrs.add(GameEnums.AttributeID.STOMACH_FULLNESS, -rate)
		attrs.add(GameEnums.AttributeID.INTESTINE_FULLNESS, rate * 0.7)
	var intestine := attrs.get_value(GameEnums.AttributeID.INTESTINE_FULLNESS)
	if intestine >= attrs.get_value(GameEnums.AttributeID.INTESTINE_MAX) * 0.9:
		_add_drive(GameEnums.DriveType.BOWEL_FULL, 0.01 * delta)
	# Toxin gradually damages health
	var toxin := attrs.get_value(GameEnums.AttributeID.TOXIN_LEVEL)
	if toxin > 0.01:
		attrs.add(GameEnums.AttributeID.HEALTH, -toxin * 0.02 * delta)
		attrs.add(GameEnums.AttributeID.TOXIN_LEVEL, -0.005 * delta)

# ── Perception ────────────────────────────────────────────────────────────────

## Fill perception lobe from nearby objects.
## nearby_objects: Array of { "object": Node, "type": int, "distance": float, "position": Vector3 }
func perceive(nearby_objects: Array[GameCharacter.NearbyObject]) -> void:
	# Clear all perception neurons first
	for i in lobe_perception.size():
		lobe_perception.stimulate(i, 0.0)

	var attrs := _get_attrs()
	var sight := (attrs.get_value(GameEnums.AttributeID.SIGHT_RANGE) if attrs else 1.0) * 300.0  # world units

	for entry in nearby_objects:
		var ot: int      = entry.type
		var dist: float  = entry.distance
		var pos: Vector3 = entry.position
		var obj: Node    = entry.object
		
		if ot <= 0 or ot >= GameEnums.ObjectType.MAX:
			continue
		var base := ot * PERCEPTION_FEATURES
		var dist_norm := clampf(1.0 - dist / sight, 0.0, 1.0)  # closer = higher
		var owner_pos := _owner_position()
		var dir := (pos - owner_pos).normalized()
		lobe_perception.stimulate(base + 0, 1.0)                   # presence
		lobe_perception.stimulate(base + 1, dist_norm)             # distance
		lobe_perception.stimulate(base + 2, clampf(dir.x, -1.0, 1.0))  # dir_x
		lobe_perception.stimulate(base + 3, clampf(dir.y, -1.0, 1.0))  # dir_y
		memory.remember_object(ot, pos)
		if obj:
			memory.remember_object(ot, pos)

func _perceive() -> void:
	# Drive lobe: directly reflect normalised drive values
	for d in GameEnums.DriveType.MAX:
		lobe_drive.stimulate(d, _get_drive(d))

func _owner_position() -> Vector3:
	var p := get_parent()
	if p and p is Node3D:
		return (p as Node3D).global_position
	return Vector3.ZERO

# ── Forward pass ──────────────────────────────────────────────────────────────

func _forward_pass() -> void:
	lobe_stimulus.update()
	lobe_concept.update()
	lobe_verb.update()
	lobe_noun.update()

# ── Decision ──────────────────────────────────────────────────────────────────

func _decide(out_action: int, out_noun: int) -> Array[int]:
	# Score every (verb, noun) combination: score = verb_act × noun_act
	# Bias score by how much that action would reduce the top drive.
	var best_score := -INF
	var best_verb  := GameEnums.ActionType.IDLE
	var best_noun  := GameEnums.ObjectType.UNKNOWN

	for v in lobe_verb.size():
		for n in lobe_noun.size():
			var score := lobe_verb.neurons[v].activation * lobe_noun.neurons[n].activation
			score += _drive_bias(v, n)
			if score > best_score:
				best_score = score
				best_verb  = v as GameEnums.ActionType
				best_noun  = n as GameEnums.ObjectType

	current_action      = best_verb
	current_target_type = best_noun
	out_action = best_verb
	out_noun   = best_noun
	
	return [out_action, out_noun]

func _execute_decision(action: int, noun: int) -> void:
	current_action      = action
	current_target_type = noun
	# Find the closest matching object in memory as the target
	current_target = _find_target(noun)
	chosen_action.emit(action, noun, current_target)

## Hard-coded bias table: certain actions relieve certain drives.
func _drive_bias(action: int, noun: int) -> float:
	var hunger    := _get_drive(GameEnums.DriveType.HUNGER)
	var thirst    := _get_drive(GameEnums.DriveType.THIRST)
	var tiredness := _get_drive(GameEnums.DriveType.TIREDNESS)
	var bowel     := _get_drive(GameEnums.DriveType.BOWEL_FULL)
	var lonely    := _get_drive(GameEnums.DriveType.LONELINESS)
	var boredom   := _get_drive(GameEnums.DriveType.BOREDOM)
	var sex       := _get_drive(GameEnums.DriveType.SEX_DRIVE)
	var bias := 0.0

	match action:
		GameEnums.ActionType.EAT:
			if noun == GameEnums.ObjectType.FOOD:
				bias += hunger * 2.0
			else:
				bias += hunger * 0.2  # might try eating anything when starving
		GameEnums.ActionType.DRINK:
			if noun == GameEnums.ObjectType.WATER_BOWL:
				bias += thirst * 2.0
		GameEnums.ActionType.SLEEP:
			bias += tiredness * 1.8
			if noun == GameEnums.ObjectType.BED:
				bias += 0.3  # extra comfort bonus
		GameEnums.ActionType.DEFECATE:
			bias += bowel * 2.5
		GameEnums.ActionType.COMMUNICATE, GameEnums.ActionType.MATE:
			if noun == GameEnums.ObjectType.HAMSTER:
				bias += lonely * 1.5
				if action == GameEnums.ActionType.MATE:
					bias += sex * 2.0
		GameEnums.ActionType.USE:
			if noun == GameEnums.ObjectType.WHEEL:
				bias += boredom * 1.5
		GameEnums.ActionType.WALK, GameEnums.ActionType.RUN:
			bias += boredom * 0.5
	return bias

## Try to find the actual Node that matches the noun type via nearby cache.
func _find_target(noun: int) -> Node:
	# The character's action handler will search the scene tree;
	# the brain just remembers the type and remembered position.
	return null  # actual lookup deferred to GameCharacter

# ── Learning ──────────────────────────────────────────────────────────────────

func _snapshot_drives() -> void:
	for d in GameEnums.DriveType.MAX:
		_drives_before[d] = _get_drive(d)

## Call this after an action completes.
## Computes a scalar reward from drive delta and runs Hebbian learning.
func on_action_completed(action_type: int) -> void:
	var reward := _compute_reward()
	_learn(reward)
	memory.record_episode(_time, current_target_type, action_type,
		_owner_position(), reward)
	if reward > 0.2:
		chemistry.on_reward()

func _compute_reward() -> float:
	var total := 0.0
	for d in GameEnums.DriveType.MAX:
		var delta := _drives_before[d] - _get_drive(d)  # positive when drive went down
		total += delta
	return clampf(total * 2.0, -1.0, 1.0)

func _learn(reward: float) -> void:
	var lr := dna.learning_rate
	var fr := dna.forget_rate
	for lobe in [lobe_concept, lobe_verb, lobe_noun, lobe_stimulus]:
		for d in lobe.all_dendrites():
			d.learn(lr, reward)
			d.decay(fr)

# ── External event hooks ──────────────────────────────────────────────────────

func on_perceived_threat(severity: float) -> void:
	chemistry.on_threatened()
	_add_drive(GameEnums.DriveType.FEAR, severity * 0.3)

func on_social_contact(other: Node) -> void:
	chemistry.on_social_contact()
	_add_drive(GameEnums.DriveType.LONELINESS, -0.3)

func on_pain(severity: float) -> void:
	chemistry.on_pain(severity)
	_add_drive(GameEnums.DriveType.PAIN, severity)

func on_ate(nutrition: float, toxicity: float) -> void:
	chemistry.on_ate(nutrition)
	var attrs := _get_attrs()
	if attrs:
		attrs.add(GameEnums.AttributeID.STOMACH_FULLNESS, nutrition * 0.4)
		attrs.add(GameEnums.AttributeID.TOXIN_LEVEL, toxicity)
	_add_drive(GameEnums.DriveType.HUNGER, -nutrition * 0.5)

func on_drank(amount: float, toxicity: float) -> void:
	var attrs := _get_attrs()
	if attrs:
		attrs.add(GameEnums.AttributeID.TOXIN_LEVEL, toxicity)
	_add_drive(GameEnums.DriveType.THIRST, -amount * 0.6)

func on_slept(duration: float) -> void:
	_add_drive(GameEnums.DriveType.TIREDNESS, -duration * 0.4)

func on_defecated() -> void:
	var attrs := _get_attrs()
	if attrs:
		attrs.set_val(GameEnums.AttributeID.INTESTINE_FULLNESS, 0.0)
	_add_drive(GameEnums.DriveType.BOWEL_FULL, -1.0)

func on_mated() -> void:
	chemistry.on_mating()
	_add_drive(GameEnums.DriveType.SEX_DRIVE, -0.8)
	_add_drive(GameEnums.DriveType.LONELINESS, -0.5)

func on_used_wheel() -> void:
	chemistry.on_exercise()
	_add_drive(GameEnums.DriveType.BOREDOM, -0.4)
	_add_drive(GameEnums.DriveType.TIREDNESS, 0.05)

## Debug: returns a snapshot of current brain state.
func debug_state() -> Dictionary:
	var drives := {}
	for d in GameEnums.DriveType.MAX:
		drives[d] = _get_drive(d)
	return {
		"action":   current_action,
		"target":   current_target_type,
		"drives":   drives,
		"hormones": chemistry.levels.duplicate(),
		"memory_spatial": memory.spatial.keys(),
	}
