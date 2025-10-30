class_name EyesBackground extends AnimatedSprite2D

func deploy_eyes():
	show()
	play("black_screen")
	await get_tree().create_timer(1).timeout
	play("intro")

func _on_animation_finished() -> void:
	if animation == "intro":
		play("loop")
