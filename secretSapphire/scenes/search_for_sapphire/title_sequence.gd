class_name TitleSequence extends Node2D

signal done

@onready var eyes_background: AnimatedSprite2D = $EyesBackground
@onready var photosensitivity_screen: ColorRect = $PhotosensitivityScreen
@onready var credit_screen: ColorRect = $CreditScreen
@onready var title_screen: ColorRect = $TitleScreen
@onready var black_screen: ColorRect = $BlackScreen

@onready var spooky_intro_music: AudioStreamPlayer2D = $SpookyIntroMusic

func play_title_sequence(previous_screen:Node, final_screen:Node, linger_time:float = 3.0, hard_cut:bool=false, include_music:bool = false, include_photo_warning:bool=false):
	
	# Null safety
	if previous_screen == null:
		previous_screen = black_screen
	
	# Play the intro track if required
	if include_music && !Global.music_muted:
		spooky_intro_music.play()
	
	# Only do a smooth fade if not hard-cutting
	if !hard_cut:
		TransitionFade.transition()
		await TransitionFade.fully_black
	previous_screen.hide()
	
	# Begin the background animation
	eyes_background.play("intro")
	eyes_background.show()
	
	# Execute the sequence
	await get_tree().create_timer(linger_time).timeout
	if include_photo_warning:
		await fade_in(photosensitivity_screen, linger_time)
	await fade_in(credit_screen, linger_time)
	await fade_in(title_screen, linger_time, false)
	
	# Transition to the next scene
	TransitionFade.transition()
	await TransitionFade.fully_black
	eyes_background.hide()
	title_screen.hide()
	final_screen.show()
	spooky_intro_music.stop()
	done.emit()


func fade_in(screen:ColorRect, linger_time:float, also_fade_out:bool = true):
	
	# Find the animation player
	var animation_player:AnimationPlayer = screen.find_child("AnimationPlayer")
	
	# Fade the screen in
	screen.show()
	animation_player.play("fade_in")
	await get_tree().create_timer(linger_time).timeout
	
	# Optionally fade the screen out
	if also_fade_out:
		animation_player.play("fade_out")
		await animation_player.animation_finished
		screen.hide()


func transition_screen(from_screen:Node, to_screen:Node, linger_time:float = 3.0):
	TransitionFade.transition()
	await TransitionFade.fully_black
	if from_screen != null:
		from_screen.hide()
	to_screen.show()
	await get_tree().create_timer(linger_time).timeout

func cut_to_black():
	credit_screen.hide()
	title_screen.hide()
	black_screen.show()


func _on_black_screen_visibility_changed() -> void:
	if black_screen != null && black_screen.visible:
		$EyesBackground.play("intro")


func _on_animated_sprite_2d_animation_finished() -> void:
	if $EyesBackground.animation == "intro":
		$EyesBackground.play("loop")
