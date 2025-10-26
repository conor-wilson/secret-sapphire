extends CanvasLayer

signal fully_black
signal done

@onready var color_rect: ColorRect = $ColorRect
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	color_rect.hide()

func fade_in():
	color_rect.show()
	animation_player.play("fade_in")

func transition():
	color_rect.show()
	animation_player.play("fade_out")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_out":
		fully_black.emit()
		animation_player.play("fade_in")
	else:
		color_rect.hide()
		done.emit()
