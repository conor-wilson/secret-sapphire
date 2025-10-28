class_name SequenceScreen extends ColorRect

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func fade_in(linger_time:float, also_fade_out:bool = true):
	
	# Fade the screen in
	show()
	animation_player.play("fade_in")
	await get_tree().create_timer(linger_time).timeout
	
	# Optionally fade the screen out
	if also_fade_out:
		animation_player.play("fade_out")
		await animation_player.animation_finished
		hide()
