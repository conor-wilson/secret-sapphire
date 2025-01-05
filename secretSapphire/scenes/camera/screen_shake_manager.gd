extends Node

signal shake(float, bool)

@onready var screen_shake_strength:float = 0.0
@onready var screen_shake_fade:float     = 5.0

# shake_screen applies a shake to the screen_shake_strength var with the provided strength and fade.
# Any Camera2D node that is making use of this var will shake accordingly. If supress_noise is true,
# the usual vibration noise will not play (assuming the Camera2D nodes have used the shake signal
# correctly). 
func shake_screen(strength:float, fade:float, supress_noise:bool=false):
	shake.emit(strength, supress_noise)
	screen_shake_strength = strength
	if fade != 0:
		screen_shake_fade = fade
