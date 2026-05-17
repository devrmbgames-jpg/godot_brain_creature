class_name GameAction
extends Node3D
## Base class for all hamster actions. Attach as child of GameCharacter.
## Each action is a self-contained module that knows how to execute itself
## and reports completion back to the character.

signal action_completed()
signal action_failed(action_type: GameEnums.ActionType, reason: String)

@export var action_type: GameEnums.ActionType = GameEnums.ActionType.IDLE
@export var duration:    float = 0.5  ## default execution time in seconds
@export var reach:       float = 60.0 ## interaction radius in world units

var _character: GameCharacter = null  ## owning GameCharacter
var _is_running: bool     = false
var _timer: float         = 0.0

func _ready() -> void:
	_character = get_parent() as GameCharacter

func _process(delta: float) -> void:
	if not _is_running:
		return
	_timer -= delta
	_on_tick(delta)
	if _timer <= 0.0:
		_finish()

## Start the action. target may be null if no object is needed.
func execute(target: Node3D = null) -> bool:
	if _is_running:
		return false
	if not _can_execute(target):
		action_failed.emit(action_type, "cannot execute")
		return false
	_is_running = true
	_timer = duration
	_on_start(target)
	return true

func cancel() -> void:
	if _is_running:
		_is_running = false
		_on_cancel()

func is_running() -> bool:
	return _is_running

# ── Override hooks ────────────────────────────────────────────────────────────

## Return false if preconditions are not met.
func _can_execute(_target: Node3D) -> bool:
	return true

## Called once when the action starts.
func _on_start(_target: Node3D) -> void:
	pass

## Called every frame while running.
func _on_tick(_delta: float) -> void:
	pass

## Called when the action finishes naturally.
func _on_finish(_target: Node3D) -> void:
	pass

func _on_cancel() -> void:
	pass

func _finish() -> void:
	_is_running = false
	_on_finish(null)
	action_completed.emit()

# ── Helpers ───────────────────────────────────────────────────────────────────

func _brain() -> GameBrain:
	if _character :
		return _character.get_brain()
	return null

func _attrs() -> GameAttributeContainer:
	if _character :
		return _character.get_attrs()
	return null

func _distance_to(target: Node3D) -> float:
	if _character and target:
		return _character.global_position.distance_to(target.global_position)
	return INF

func _move_toward(target_pos: Vector3, speed: float) -> void:
	if not _character:
		return
	
	var dir := _character.global_position.direction_to(target_pos)
	dir.y = 0.0
	if dir.length_squared() > 0.01:
		dir = dir.normalized()
		_character.direction = dir
		_character.motion = dir * speed
		
