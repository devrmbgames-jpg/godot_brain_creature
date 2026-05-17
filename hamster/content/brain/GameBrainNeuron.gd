class_name GameBrainNeuron
## Single neuron in a brain lobe. Activation is normalised to [-1, 1].

var activation: float = 0.0       ## current output value
var prev_activation: float = 0.0  ## last tick's value (for Hebbian)
var lobe_type: int = 0
var index: int = 0                 ## position within the lobe

## Dendrites entering this neuron (type: Array[GameBrainDendrite])
var dendrites: Array[GameBrainDendrite] = []

func _init(p_lobe: int, p_index: int) -> void:
	lobe_type = p_lobe
	index = p_index

## Compute activation from incoming dendrites, then apply leaky decay.
func update(leaky: float = 0.05) -> void:
	prev_activation = activation
	var total: float = 0.0
	for d in dendrites:
		total += d.source.activation * d.weight
	activation = _sigmoid(total)
	# Small leak keeps unused neurons near 0 faster.
	activation = lerpf(activation, 0.0, leaky)

## Clamp-based sigmoid, fast and continuous on [-1,1].
static func _sigmoid(x: float) -> float:
	return clampf(x / (1.0 + absf(x)), -1.0, 1.0)

## Force an external activation (used for perception / drive input neurons).
func stimulate(v: float) -> void:
	prev_activation = activation
	activation = clampf(v, -1.0, 1.0)

func reset() -> void:
	prev_activation = activation
	activation = 0.0
