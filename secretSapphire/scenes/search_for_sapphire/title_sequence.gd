class_name TitleSequence extends Node2D

signal done

@onready var eyes_background: EyesBackground = $EyesBackground

@onready var made_with_godot_screen: SequenceScreen = $MadeWithGodot
@onready var credit_screen: SequenceScreen = $CreditScreen
@onready var title_screen: SequenceScreen = $TitleScreen
@onready var available_now_screen: SequenceScreen = $AvailableNow
@onready var itch_link: SequenceScreen = $itchLink
@onready var black_screen: ColorRect = $BlackScreen

@onready var spooky_intro_music: AudioStreamPlayer2D = $SpookyIntroMusic

var intro_cave_dialogue:bool = true

func play_title_sequence(previous_screen:Node, final_screen:Node, linger_time:float = 3.0, hard_cut:bool=false, include_music:bool = false, is_intro:bool=false, custom_transition_speed:float = 1.0):
	
	# Null safety
	if previous_screen == null:
		previous_screen = black_screen
	
	# Play the intro track if required
	if include_music && !Global.music_muted:
		spooky_intro_music.volume_db = -80
		spooky_intro_music.play()
		var tween = create_tween()
		tween.tween_property(spooky_intro_music, "volume_db", 6, 1.5)
	
	# Only do a smooth fade if not hard-cutting
	if !hard_cut:
		TransitionFade.transition(custom_transition_speed)
		await TransitionFade.fully_black
	previous_screen.hide()
	show()
	
	# Begin the background animation
	if is_intro:
		eyes_background.deploy_eyes()
	else:
		eyes_background.deploy_eyes(1)
	
	# Execute the sequence
	if is_intro:
		await get_tree().create_timer(linger_time).timeout
		await made_with_godot_screen.fade_in(linger_time)
		await credit_screen.fade_in(linger_time)
		await title_screen.fade_in(linger_time, false)
	else:
		await get_tree().create_timer(0.5).timeout
		await available_now_screen.fade_in(linger_time)
		await itch_link.fade_in(10000)
	
	# Transition to the next scene
	TransitionFade.transition()
	await TransitionFade.fully_black
	eyes_background.hide()
	title_screen.hide()
	hide()
	final_screen.show()
	
	# Fade out the intro music
	if include_music && !Global.music_muted:
		var tween = create_tween()
		tween.tween_property(spooky_intro_music, "volume_db", -80, 2)
		tween.tween_callback(spooky_intro_music.stop)
	
	# Done
	done.emit()


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


func _on_cave_mouth_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		
		var lines:Array[String] = []
		
		if intro_cave_dialogue:
			lines = [
				"You, like me, are one who knows many secrets.",
				"Although you are here too early.",
				"Come back later when you have released the HELP BOT."
			]
		else:
			lines = [
				"I see you have come back for more secrets...",
				"Your diligence is admirable, and so I will give you one...",
				"This game that you have strived so hard to start...",
				"The one that takes place within a haunted mansion...",
				"...it is very bad.",
			]
		DialogueManager.stop_all_dialogue()
		DialogueManager.new_dialogue_sequence($CaveOfSecrets/DialogueMarker.position, lines, "black", 4, $CaveOfSecrets/DialogueMarker)
