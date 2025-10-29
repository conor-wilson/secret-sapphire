class_name SequenceScreen extends ColorRect

signal done

@onready var fade_animator: AnimationPlayer = $FadeAnimator

func fade_in(linger_time:float, also_fade_out:bool = true):
	
	# Fade the screen in
	show()
	fade_animator.play("fade_in")
	await get_tree().create_timer(linger_time).timeout
	
	# Optionally fade the screen out
	if also_fade_out:
		fade_animator.play("fade_out")
		await fade_animator.animation_finished
		hide()
	
	done.emit()
