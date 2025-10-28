class_name VictorySequence extends Node2D

signal done
signal play_again
signal main_menu

@onready var credits_music: AudioStreamPlayer2D = $CreditsMusic

@onready var eyes_background: EyesBackground = $EyesBackground

@onready var screen_1: SequenceScreen = $Screen1
@onready var screen_2: SequenceScreen = $Screen2
@onready var screen_3: SequenceScreen = $Screen3
@onready var screen_4: SequenceScreen = $Screen4
@onready var victory_menu: SequenceScreen = $VictoryMenu
@onready var black_screen: ColorRect = $BlackScreen

func play_outro_sequence(previous_screen:Node, linger_time:float = 3.0):
	
	# Null safety
	if previous_screen == null:
		previous_screen = black_screen
	
	# Play the intro track if required
	if !Global.music_muted:
		credits_music.volume_db = 0
		credits_music.play()
	
	# Transition smoothly
	TransitionFade.transition()
	await TransitionFade.fully_black
	previous_screen.hide()
	
	# Begin the background animation
	show()
	hide_all_screens()
	eyes_background.deploy_eyes()
	
	# Execute the sequence
	await get_tree().create_timer(linger_time).timeout
	await screen_1.fade_in(linger_time)
	await screen_2.fade_in(linger_time)
	await screen_3.fade_in(linger_time)
	await screen_4.fade_in(linger_time)
	await victory_menu.fade_in(linger_time, false)
	
	## Transition to the next scene
	#TransitionFade.transition()
	#await TransitionFade.fully_black
	#eyes_background.hide()
	#title_screen.hide()
	#final_screen.show()
	#
	## Fade out the intro music
	#if include_music && !Global.music_muted:
		#var tween = create_tween()
		#tween.tween_property(spooky_intro_music, "volume_db", -80, 2)
		#tween.tween_callback(spooky_intro_music.stop)
	
	# Done
	done.emit()

func hide_all_screens():
	screen_1.hide()
	screen_2.hide()
	screen_3.hide()
	screen_4.hide()
	victory_menu.hide()
	black_screen.hide()

#func fade_in(screen:ColorRect, linger_time:float, also_fade_out:bool = true):
	#
	## Find the animation player
	#var animation_player:AnimationPlayer = screen.find_child("AnimationPlayer")
	#
	## Fade the screen in
	#screen.show()
	#animation_player.play("fade_in")
	#await get_tree().create_timer(linger_time).timeout
	#
	## Optionally fade the screen out
	#if also_fade_out:
		#animation_player.play("fade_out")
		#await animation_player.animation_finished
		#screen.hide()


func _on_play_again_pressed() -> void:
	fade_out_music()
	play_again.emit()

func _on_main_menu_pressed() -> void:
	fade_out_music()
	main_menu.emit()

# TODO: Move this
func fade_out_music() -> void:
	var tween = create_tween()
	tween.tween_property(credits_music, "volume_db", -80, 2)
	tween.tween_callback(credits_music.stop)

# TODO: Move this
func fade_in_music() -> void:
	credits_music.volume_db = -80
	credits_music.play()
	var tween = create_tween()
	tween.tween_property(credits_music, "volume_db", 0, 1)
	credits_music.play()
