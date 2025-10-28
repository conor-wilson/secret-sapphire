class_name EyesBackground extends AnimatedSprite2D

func deploy_eyes():
	show()
	play("intro")

func _on_animation_finished() -> void:
	if animation == "intro":
		play("loop")
