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
@onready var screen_5: SequenceScreen = $Screen5
@onready var the_end: SequenceScreen = $TheEnd
@onready var question_mark: SequenceScreen = $QuestionMark
@onready var credits: Credits = $Credits

@onready var victory_menu: SequenceScreen = $VictoryMenu
@onready var black_screen: ColorRect = $BlackScreen

func play_outro_sequence(previous_screen:Node, linger_time:float = 3.0):
	
	# Null safety
	if previous_screen == null:
		previous_screen = black_screen
	
	
	# Transition smoothly
	TransitionFade.transition()
	await TransitionFade.fully_black
	previous_screen.hide()
	
	# Begin the background animation
	show()
	hide_all_screens()
	eyes_background.deploy_eyes()
	
	# Execute the sequence
	await get_tree().create_timer(linger_time/2).timeout
	if !Global.music_muted: # Play the intro track if required
		credits_music.volume_db = 0
		credits_music.play()
	await get_tree().create_timer(linger_time/2).timeout
	await screen_1.fade_in(linger_time)
	await screen_2.fade_in(linger_time)
	await screen_3.fade_in(linger_time)
	await screen_4.fade_in(linger_time)
	await screen_5.fade_in(linger_time)
	
	the_end.fade_in(linger_time*1.5)
	await get_tree().create_timer(linger_time*0.5).timeout
	await question_mark.fade_in(linger_time)
	
	credits.play_credits()
	await credits.done
	await victory_menu.fade_in(linger_time, false)
	
	# Done
	done.emit()

func hide_all_screens():
	screen_1.hide()
	screen_2.hide()
	screen_3.hide()
	screen_4.hide()
	victory_menu.hide()
	black_screen.hide()

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


func _on_cave_mouth_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		var lines:Array[String] = [
				"You have come so far and yet you won't stay to watch the ending?",
				"What a strange creature you are.",
				"What delicious secrets do you hide?"
			]
		DialogueManager.stop_all_dialogue()
		DialogueManager.new_dialogue_sequence($CaveOfSecrets/DialogueMarker.position, lines, "black", 4, $CaveOfSecrets/DialogueMarker)
