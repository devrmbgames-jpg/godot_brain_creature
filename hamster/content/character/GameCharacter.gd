class_name GameCharacter
extends CharacterBody3D
## Base character class. The brain is a child node; actions are child nodes too.
## Motion and direction follow the 2D (X/Y) convention; Z is always 0.

signal character_died(character: Node)
signal action_started(action_type: int)

## Direction the character is facing: normalised, Z is always 0.
@export var direction: Vector3 = Vector3.RIGHT
## Motion vector: length encodes speed fraction [0,1].
@export var motion: Vector3 = Vector3.ZERO

@export var attributes: GameAttributeContainer
@export var brain: GameBrain

@export_subgroup("Motion")
@export var motion_speed := 10.0
@export var motion_acceleration := 80.0
@export var motion_friction := 100.0
@export var motion_jump_up_force := 5.0
@export var motion_jumo_forward_force := 7.0


@export_subgroup("Sensors")
@export var sensor_vision: Area3D
@export var sensor_forward_wall: RayCast3D
@export var sensor_forward_floor: RayCast3D
@export var sensor_forward_platform: RayCast3D


# ── Internal state ────────────────────────────────────────────────────────────
var _held_object:   Node    = null
var _current_action: GameAction = null
var _alive:         bool    = true
var _actions:       Dictionary[GameEnums.ActionType, GameAction] = {}  ## ActionType -> GameAction
var _mate_partner:  Node = null
var _start_jump_up := false
var _start_jump_forward := false

class NearbyObject :
	var object: Node3D
	var type: GameEnums.ObjectType
	var distance: float
	var position: Vector3
	
	func _init(
		p_object: Node3D,
		p_type: GameEnums.ObjectType,
		p_distance: float,
		p_position: Vector3) -> void :
			object = p_object
			type = p_type
			distance = p_distance
			position = p_position





func _ready() -> void:
	attributes = GameAttributeContainer.new()
	_apply_dna_to_attrs()
	brain = GameBrain.new()
	add_child(brain)
	brain.chosen_action.connect(_on_brain_chose_action)
	_register_actions()
	_on_character_ready()

func _apply_dna_to_attrs() -> void:
	pass  ## override in subclasses to apply DNA before brain starts

func _on_character_ready() -> void:
	pass  ## override hook

func _physics_process(delta: float) -> void:
	if not _alive:
		return
	_motion_process(delta)
	_enforce_2d_plane()
	_check_death()
	_tick_age(delta)
	_tick_pregnancy(delta)

func _enforce_2d_plane() -> void:
	global_position.z = 0.0

func _check_death() -> void:
	if attributes.get_value(GameEnums.AttributeID.HEALTH) <= 0.0:
		_die()

func _die() -> void:
	if not _alive:
		return
	_alive = false
	character_died.emit(self)

func _tick_age(delta: float) -> void:
	var age_rate := delta / (attributes.get_value(GameEnums.AttributeID.MAX_AGE) * 600.0)  ## 600s lifetime base
	attributes.add(GameEnums.AttributeID.AGE, age_rate)
	if attributes.get_value(GameEnums.AttributeID.AGE) >= 1.0:
		_die()

func _tick_pregnancy(delta: float) -> void:
	if attributes.get_value(GameEnums.AttributeID.PREGNANCY) <= 0.0:
		return
	if attributes.get_value(GameEnums.AttributeID.SEX_ATTR) > 0.5:  # only females
		return
	var rate := delta / (attributes.get_value(GameEnums.AttributeID.GESTATION_TIME) * 60.0)
	attributes.add(GameEnums.AttributeID.GESTATION_TIMER, rate)
	if attributes.get_value(GameEnums.AttributeID.GESTATION_TIMER) >= 1.0:
		attributes.set_val(GameEnums.AttributeID.PREGNANCY, 1.0)
		_trigger_give_birth()

func _trigger_give_birth() -> void:
	var action: GameAction = _actions.get(GameEnums.ActionType.GIVE_BIRTH)
	if action:
		action.execute(null)

# ── Action registry ───────────────────────────────────────────────────────────

func _register_actions() -> void:
	pass  ## override in subclass to add GameAction children

func _add_action(action: GameAction) -> void:
	add_child(action)
	_actions[action.action_type] = action
	action.action_completed.connect(_on_action_completed.bind(action.action_type))

# ── Brain callback ────────────────────────────────────────────────────────────

func _on_brain_chose_action(action_type: int, target_type: int, _target: Node) -> void:
	if not _alive:
		return
	if _current_action and _current_action.is_running():
		return  ## don't interrupt mid-action (brain ticks frequently)

	var action: GameAction = _actions.get(action_type)
	if action == null:
		return

	# Find best target node for this noun type
	var target_node := _find_nearest_of_type(target_type)
	if action.execute(target_node):
		_current_action = action
		action_started.emit(action_type)

func _on_action_completed(action_type: int) -> void:
	if brain:
		brain.on_action_completed(action_type)
	_current_action = null

# ── Perception update (called from world or self) ─────────────────────────────

## Call this each frame or on a timer to feed nearby objects into the brain.
func update_perception(nearby: Array[NearbyObject]) -> void:
	if brain:
		brain.perceive(nearby)

# ── Object interaction helpers ────────────────────────────────────────────────

func get_attrs() -> GameAttributeContainer:
	return attributes

func get_brain() -> GameBrain:
	return brain

func get_held_object() -> Node:
	return _held_object

func set_held_object(obj: Node) -> void:
	_held_object = obj

func get_facing() -> float:
	return sign(direction.x) if not is_zero_approx(direction.x) else 1.0

func is_alive() -> bool:
	return _alive

## Returns a perception-entry dict for use in update_perception.
func as_perception_entry() -> Dictionary:
	return {
		"object": self,
		"type":   GameEnums.ObjectType.HAMSTER,
		"distance": 0.0,
		"position": global_position,
	}

# ── Mating interface ─────────────────────────────────────────────────────────

func can_mate(requester: Node) -> bool:
	if not _alive:
		return false
	var attrs := attributes
	if attrs.get_value(GameEnums.AttributeID.AGE) < 0.2:
		return false
	# Opposite sex only (basic)
	if requester.has_method("get_attrs"):
		var r_attrs: GameAttributeContainer = requester.get_attrs()
		if r_attrs.get_value(GameEnums.AttributeID.SEX_ATTR) == attrs.get_value(GameEnums.AttributeID.SEX_ATTR):
			return false
	return attrs.get_value(GameEnums.AttributeID.DRIVE_SEX_DRIVE) > 0.1

func on_mated_with(partner: Node) -> void:
	_mate_partner = partner
	if brain:
		brain.on_mated()
	# Female gets pregnant
	if attributes.get_value(GameEnums.AttributeID.SEX_ATTR) < 0.5:
		attributes.set_val(GameEnums.AttributeID.PREGNANCY, 0.01)

## Receive communication from another character.
func receive_communication(sender: Node, _payload: Dictionary) -> void:
	if brain:
		brain.on_social_contact(sender)

# ── World lookups (override in subclass with scene-tree knowledge) ─────────────

## Find the nearest GameObject of a given ObjectType in the world.
func _find_nearest_of_type(_type: int) -> Node:
	return null  ## override in GameHamster or via signal/world reference

## Spawn a poop object at current position.
func spawn_poop() -> void:
	pass  ## override in subclass

## Spawn offspring using combined DNA.
func spawn_offspring() -> void:
	pass  ## override in subclass


func jump_up() -> void :
	if is_on_floor() :
		_start_jump_up = true


func jump_forward() -> void :
	if is_on_floor() :
		_start_jump_forward = true




# ---- SENSORS ---------

## есть ли впереди стена
func is_sensor_wall_ahead() -> bool :
	if sensor_forward_wall :
		return sensor_forward_wall.is_colliding()
	return false


## есть ли впереди обрыв
func is_sensor_cliff_ahead() -> bool :
	# если впереди нету стены и нету пола, значит впереди обрыв
	if sensor_forward_wall and sensor_forward_floor :
		return not sensor_forward_floor.is_colliding() and not sensor_forward_wall.is_colliding()
	return false

## есть ли впереди небольшая платформа, на которую можно запрыгнуть
func is_sensor_platform_ahead() -> bool :
	# если впереди нет стены и есть платформа
	if sensor_forward_wall and sensor_forward_platform :
		return not sensor_forward_wall.is_colliding() and sensor_forward_platform.is_colliding()
	return false


func get_visible_all_objects() -> Array[Node3D] :
	var res: Array[Node3D] = []
	
	if sensor_vision :
		# делаем каст от текущего местоположения головы до обьектов
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(
			global_position + Vector3.UP * 0.8, 
			global_position,
			1, 
			[self]
			) #создаем рейкаст с маской мира, игнорируем хомяков и интерактивные малые обьекты
		
		var detected_objects := sensor_vision.get_overlapping_bodies()
		for body in detected_objects :
			query.to = body.global_position + (Vector3.UP * 0.1)
			var result_cast = space_state.intersect_ray(query)
			# если каст не встретил преград или искомый обьект - все ОК
			if not result_cast or result_cast.collider == body or result_cast.collider == null:
				res.append(body)
	return res

# --- Motion Process ----------

func _motion_process(delta: float) -> void :
	if not is_on_floor() :
		velocity += get_gravity() * delta
	
	look_at(global_position + direction)
	var attr := get_attrs()
	var target_velocity := Vector3.ZERO
	if attr :
		target_velocity = motion * motion_speed * attr.get_value(GameEnums.AttributeID.SPEED)
	
	if is_on_floor() :
		if motion.length() > 0.01 :
			velocity.x = move_toward(velocity.x, target_velocity.x, motion_acceleration * delta)
			velocity.z = move_toward(velocity.z, target_velocity.z, motion_acceleration * delta)
		else :
			velocity.x = move_toward(velocity.x, target_velocity.x, motion_friction * delta)
			velocity.z = move_toward(velocity.z, target_velocity.z, motion_friction * delta)
		
		if _start_jump_up :
			velocity.y += motion_jump_up_force
		elif _start_jump_forward :
			velocity.y += motion_jump_up_force
			velocity.x += motion_jumo_forward_force if direction.x > 0 else -motion_jumo_forward_force
	
		_start_jump_up = false
		_start_jump_forward = false
	move_and_slide()
