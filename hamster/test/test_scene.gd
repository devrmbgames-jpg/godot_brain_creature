extends Node3D

@onready var _hamster := %TestHamster as GameHamster
@onready var _label := %Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if _hamster and _label :
		_label.text = var_to_str(_hamster.get_brain().debug_state())
