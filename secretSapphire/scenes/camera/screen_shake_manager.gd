extends Node

signal shake(float)

@onready var screen_shake_strength:float = 0.0
@onready var screen_shake_fade:float     = 5.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func shake_screen(strength:float, fade:float):
	shake.emit(strength)
	screen_shake_strength = strength
	if fade != 0:
		screen_shake_fade = fade
