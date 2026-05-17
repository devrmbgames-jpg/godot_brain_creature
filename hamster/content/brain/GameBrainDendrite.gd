class_name GameBrainDendrite
## Weighted directed connection between two neurons (synapse).

var source: GameBrainNeuron
var target: GameBrainNeuron
var weight: float = 0.0
var susceptibility: float = 1.0  ## from DNA, scales how fast this dendrite learns

func _init(p_source: GameBrainNeuron, p_target: GameBrainNeuron, p_weight: float = 0.0, p_suscep: float = 1.0) -> void:
	source        = p_source
	target        = p_target
	weight        = p_weight
	susceptibility = p_suscep

## Hebbian update: fire-together-wire-together.
## reward in [-1,1]: positive = reinforce, negative = punish.
func learn(lr: float, reward: float) -> void:
	var delta := lr * susceptibility * source.activation * target.activation * reward
	weight = clampf(weight + delta, -1.0, 1.0)

## Passive weight decay (forgetting unused connections).
func decay(rate: float) -> void:
	weight = lerpf(weight, 0.0, rate)
