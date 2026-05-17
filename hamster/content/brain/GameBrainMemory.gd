class_name GameBrainMemory
## Episodic + spatial memory for the brain.

class Episode :
	var time: float
	var object_type: int
	var action: int
	var position: Vector3
	var reward: float
	func _init(
		p_time: float = 0.0, 
		p_object_type: int = 0, 
		p_action: int = 0, 
		p_position: Vector3 = Vector3.ZERO, 
		p_reward: float = 0) -> void :
			time = p_time
			object_type = p_object_type
			action = p_action
			position = p_position
			reward = p_reward
	
	func is_empty() -> bool :
		return time == 0.0



const MAX_EPISODES: int = 32

## Spatial memory: object_type -> last known world position.
var spatial: Dictionary = {}  # int(ObjectType) -> Vector3

## Short-term episodic memory: ring-buffer of recent events.
## Each entry: { "time": float, "object_type": int, "action": int, "position": Vector3, "reward": float }
var episodes: Array[Episode] = []
var _ep_index: int = 0

## Long-term familiarity counters per object type: how many times encountered.
var familiarity: Dictionary = {}  # int(ObjectType) -> int

func _init() -> void:
	episodes.resize(MAX_EPISODES)
	for i in MAX_EPISODES:
		episodes[i] = null

## Record a perception event (object seen / interacted with).
func remember_object(object_type: int, position: Vector3) -> void:
	spatial[object_type] = position
	familiarity[object_type] = familiarity.get(object_type, 0) + 1

## Record an action-outcome episode.
func record_episode(time: float, object_type: int, action: int, position: Vector3, reward: float) -> void:
	var ep := Episode.new(
		time,
		object_type,
		action,
		position,
		reward
	)
	episodes[_ep_index] = ep
	_ep_index = (_ep_index + 1) % MAX_EPISODES

## Returns last known position of an object type, or Vector3.ZERO if unknown.
func recall_position(object_type: int) -> Vector3:
	return spatial.get(object_type, Vector3.ZERO)

## True if the creature has ever encountered this object type.
func knows_object(object_type: int) -> bool:
	return familiarity.has(object_type)

## Familiarity score 0-1 (saturates at 100 encounters).
func familiarity_score(object_type: int) -> float:
	return clampf(familiarity.get(object_type, 0) / 100.0, 0.0, 1.0)

## Returns the most recent positive episode position for a given action (or Vector3.ZERO).
func best_episode_position(action: int) -> Vector3:
	var best_reward := -INF
	var best_pos := Vector3.ZERO
	for ep in episodes:
		if ep == null :
			continue
		if ep.is_empty():
			continue
		if ep.action == action and ep.reward > best_reward:
			best_reward = ep.reward
			best_pos = ep.position
	return best_pos

## Forget older spatial entries for objects not seen in a while.
func decay_spatial(current_time: float, half_life: float = 60.0) -> void:
	var to_remove: Array = []
	for ep in episodes:
		if ep.is_empty():
			continue
		if current_time - ep.time > half_life * 2.0:
			to_remove.append(ep.object_type)
	for ot in to_remove:
		spatial.erase(ot)
