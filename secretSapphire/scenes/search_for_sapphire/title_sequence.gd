class_name TitleSequence extends Node2D

signal done

@onready var credit_screen: ColorRect = $CreditScreen
@onready var title_screen: ColorRect = $TitleScreen
@onready var black_screen: ColorRect = $BlackScreen

func play_title_sequence(previous_screen:Node, final_screen:Node, linger_time:float = 3.0, hard_cut:bool=false):
	
	if previous_screen == null:
		previous_screen = black_screen
	
	if hard_cut:
		cut_to_black()
		await transition_screen(black_screen, credit_screen, 3)
	else:
		await transition_screen(previous_screen, credit_screen, 3)
	
	await transition_screen(credit_screen, title_screen, linger_time)
	done.emit()
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
