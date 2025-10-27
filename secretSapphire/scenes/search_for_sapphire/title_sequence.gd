class_name TitleSequence extends Node2D

signal done

@onready var credit_screen: ColorRect = $CreditScreen
@onready var title_screen: ColorRect = $TitleScreen
@onready var black_screen: ColorRect = $BlackScreen

@onready var spooky_intro_music: AudioStreamPlayer2D = $SpookyIntroMusic

func play_title_sequence(previous_screen:Node, final_screen:Node, linger_time:float = 3.0, hard_cut:bool=false, include_music:bool = false):
	
	if previous_screen == null:
		previous_screen = black_screen
	
	if include_music:
		spooky_intro_music.play()
	
	if hard_cut:
		previous_screen.hide()
		cut_to_black()
		await transition_screen(black_screen, credit_screen, linger_time)
	else:
		await transition_screen(previous_screen, credit_screen, linger_time)
	
	await transition_screen(credit_screen, title_screen, linger_time)
	done.emit()
	spooky_intro_music.stop()
	transition_screen(title_screen, final_screen, linger_time)


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
