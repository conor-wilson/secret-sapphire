extends Node

var screen_shake_strength:float = 0.0
var screen_shake_fade:float     = 5.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	apply_screen_shake(delta)

func apply_screen_shake(delta: float):
	
	# No shake required if the strength is below the shake threshold
	if screen_shake_strength <= 0.001:
		screen_shake_strength = 0
		return
	
	# Shake the screen
	$Camera2D.offset = Vector2(
		randf_range(-screen_shake_strength, screen_shake_strength), 
		randf_range(-screen_shake_strength, screen_shake_strength),
	)
	
	# Fade the screen shake for the next time
	screen_shake_strength = lerpf(screen_shake_strength, 0, screen_shake_fade*delta)


func _on_main_menu_shake_screen(strength:float, fade:float) -> void:
	screen_shake_strength = strength
	if fade != 0:
		screen_shake_fade = fade
