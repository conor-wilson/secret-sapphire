class_name Credits extends Node2D

signal done

@onready var black_background: SequenceScreen = $BlackBackground
@onready var credits: SequenceScreen = $Credits
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func play_credits():
	
	credits.position = Vector2.ZERO
	credits.fade_in(17)
	await get_tree().create_timer(3).timeout
	black_background.fade_in(14.5)
	
	animation_player.play("scroll")
	await credits.done
	
	done.emit()
