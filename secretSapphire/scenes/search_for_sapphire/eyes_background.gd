class_name EyesBackground extends AnimatedSprite2D

func deploy_eyes(delay:int = 2):
	show()
	play("black_screen")
	await get_tree().create_timer(delay).timeout
	play("intro")

func _on_animation_finished() -> void:
	if animation == "intro":
		play("loop")
