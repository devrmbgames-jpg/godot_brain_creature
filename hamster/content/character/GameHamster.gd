class_name GameHamster
extends GameCharacter
## Concrete hamster character. Wires all actions, handles world lookups,
## spawns poop and offspring, and feeds perception every tick.



## DNA can be injected before _ready (e.g., from parent spawning).
var injected_dna: GameBrainDNA = null

# Poop scene path — assign a PackedScene or let it use a placeholder.
@export var poop_scene: PackedScene = null
@export var hamster_scene: PackedScene = null

# Perception scan range in world units (mirrors attribute).
const BASE_SIGHT: float = 300.0

func _on_character_ready() -> void:
	# Apply DNA-derived stats before brain runs.
	_apply_dna_to_attrs()

func _apply_dna_to_attrs() -> void:
	var dna := injected_dna if injected_dna else GameBrainDNA.new()
	if brain:
		brain.dna = dna
	attributes.set_val(GameEnums.AttributeID.WALK_SPEED,   dna.walk_speed)
	attributes.set_val(GameEnums.AttributeID.RUN_SPEED,    dna.run_speed)
	attributes.set_val(GameEnums.AttributeID.JUMP_FORCE,   dna.jump_force)
	attributes.set_val(GameEnums.AttributeID.SIGHT_RANGE,  dna.sight_range)
	attributes.set_val(GameEnums.AttributeID.MAX_AGE,      dna.max_age)
	# Random sex
	attributes.set_val(GameEnums.AttributeID.SEX_ATTR, float(randi() % 2))
	# Slight random variation in size/weight
	attributes.set_val(GameEnums.AttributeID.SIZE,   randf_range(0.4, 0.7))
	attributes.set_val(GameEnums.AttributeID.WEIGHT, randf_range(0.3, 0.6))

func _register_actions() -> void:
	_add_action(GameActionWalk.new())
	_add_action(GameActionRun.new())
	_add_action(GameActionJump.new())
	_add_action(GameActionJumpForward.new())
	_add_action(GameActionEat.new())
	_add_action(GameActionDrink.new())
	_add_action(GameActionSleep.new())
	_add_action(GameActionDefecate.new())
	_add_action(GameActionPush.new())
	_add_action(GameActionUse.new())
	_add_action(GameActionPickUp.new())
	_add_action(GameActionDrop.new())
	_add_action(GameActionCommunicate.new())
	_add_action(GameActionMate.new())
	_add_action(GameActionGiveBirth.new())

func _physics_process(delta: float) -> void:
	super(delta)
	if not _alive:
		return
	_scan_and_perceive()

func _scan_and_perceive() -> void:
	var my_pos    := global_position
	var sight     := attributes.get_value(GameEnums.AttributeID.SIGHT_RANGE) * BASE_SIGHT
	var detected_objects := get_visible_all_objects()
	var nearby:   Array[NearbyObject] = []

	for node in detected_objects:
		if node == self:
			continue
		var dist: float = my_pos.distance_to(node.global_position)
		if dist > sight:
			continue
		var ot := _resolve_object_type(node)
		if ot == GameEnums.ObjectType.UNKNOWN:
			continue
		var nearby_object := NearbyObject.new(
			node,
			ot,
			dist,
			node.global_position
		)
		nearby.append(nearby_object)

	update_perception(nearby)

func _resolve_object_type(node: Node) -> int:
	if node.has_method("get_object_type"):
		return node.get_object_type()
	if node is GameCharacter:
		return GameEnums.ObjectType.HAMSTER
	return GameEnums.ObjectType.UNKNOWN

# ── World lookups ─────────────────────────────────────────────────────────────

func _find_nearest_of_type(type: int) -> Node3D:
	var my_pos := global_position
	var best: Node3D   = null
	var best_d: float = INF
	var detected_objects := get_visible_all_objects()
	for node in detected_objects:
		if node == self:
			continue
		var ot := _resolve_object_type(node)
		if ot != type:
			continue
		var d := my_pos.distance_to(node.global_position)
		if d < best_d:
			best_d = d
			best   = node
	return best

# ── Spawning ──────────────────────────────────────────────────────────────────

func spawn_poop() -> void:
	var poop: Node3D
	if poop_scene:
		poop = poop_scene.instantiate()
	else:
		poop = GameObjectPoop.new()
	poop.position = position
	get_parent().add_child(poop)

func spawn_offspring() -> void:
	var child_hamster: GameHamster
	if hamster_scene:
		child_hamster = hamster_scene.instantiate()
	else:
		child_hamster = GameHamster.new()

	# Combine DNA with a nearby partner if found
	var partner := _find_nearest_of_type(GameEnums.ObjectType.HAMSTER)
	var child_dna: GameBrainDNA
	if partner and partner.has_method("get_brain"):
		var partner_brain: GameBrain = partner.get_brain()
		child_dna = GameBrainDNA.crossover(brain.dna, partner_brain.dna)
	else:
		child_dna = GameBrainDNA.crossover(brain.dna, GameBrainDNA.new())

	child_hamster.injected_dna  = child_dna
	child_hamster.poop_scene    = poop_scene
	child_hamster.hamster_scene = hamster_scene
	child_hamster.global_position = global_position + Vector3(randf_range(-30, 30), 0, 0)
	child_hamster.global_position.z = 0.0

	get_parent().add_child(child_hamster)

	# Mark offspring count
	attributes.add(GameEnums.AttributeID.FERTILITY, -0.1)
	if brain:
		brain.memory.familiarity[GameEnums.ObjectType.HAMSTER] = \
			brain.memory.familiarity.get(GameEnums.ObjectType.HAMSTER, 0) + 1
