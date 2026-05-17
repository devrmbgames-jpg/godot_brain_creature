class_name GameBrainLobe
## A region of the brain — an array of neurons of the same type.

var lobe_type: int
var neurons: Array[GameBrainNeuron] = []
var leaky: float = 0.05  ## per-lobe leaky coefficient

func _init(p_type: int, p_size: int, p_leaky: float = 0.05) -> void:
	lobe_type = p_type
	leaky = p_leaky
	neurons.resize(p_size)
	for i in p_size:
		neurons[i] = GameBrainNeuron.new(p_type, i)

func size() -> int:
	return neurons.size()

## Update all neurons in order (forward pass).
func update() -> void:
	for n in neurons:
		if n.dendrites.size() > 0:
			n.update(leaky)

## Force-set neuron by index (input lobes).
func stimulate(index: int, v: float) -> void:
	if index < neurons.size():
		neurons[index].stimulate(v)

## Returns the index of the neuron with the highest activation.
func argmax() -> int:
	var best := 0
	var best_val := -INF
	for i in neurons.size():
		if neurons[i].activation > best_val:
			best_val = neurons[i].activation
			best = i
	return best

## Fully connect every neuron in this lobe to every neuron in target_lobe.
## Initial weights are small random values from DNA range.
func connect_full(target_lobe: GameBrainLobe, weight_range: float = 0.1) -> void:
	for src in neurons:
		for tgt in target_lobe.neurons:
			var w := (randf() * 2.0 - 1.0) * weight_range
			var d := GameBrainDendrite.new(src, tgt, w)
			tgt.dendrites.append(d)

## Sparse random connection: each target neuron connects to k random sources.
func connect_sparse(target_lobe: GameBrainLobe, k: int, weight_range: float = 0.1) -> void:
	for tgt in target_lobe.neurons:
		var src_pool := neurons.duplicate()
		src_pool.shuffle()
		for i in mini(k, src_pool.size()):
			var w := (randf() * 2.0 - 1.0) * weight_range
			var d := GameBrainDendrite.new(src_pool[i], tgt, w)
			tgt.dendrites.append(d)

## Collect all dendrites belonging to neurons of this lobe (for learning pass).
func all_dendrites() -> Array:
	var result: Array = []
	for n in neurons:
		result.append_array(n.dendrites)
	return result
