extends Node

# Hello to anyone viewing the code during the jam!
#
# I ended up being a lot more ambitious with this project, so at a certain
# point, good code practices went completely out the window in favour of
# getting the game finished. As a result, the code in this project is a
# complete and utter mess. It's got commented code, debug print messages and
# duplicated functionality absolutely everywhere. 
# 
# I'll fix up the code and make it nice and pretty once the jam is over, but
# I thought that I'd leave it this way for the most part during the jam to
# preserve the energy of the mid-jam code for this project.
#
# Also, if you're here to find the answer to the password puzzle, you can
# certainly find it in here, but you should probably try to find any TOOLs at
# your disposal in the game that might help you find a clue to the puzzle, as
# well as CLICKING on anything and everything in the game, be it moving or
# STATIC. 
# 
# Thanks for reading! 
# 
# - Conor (aka QuietLantern)

var menus_scene := preload("res://scenes/menus/menus.tscn")
@onready var menus: Menus = $Menus
@onready var search_for_the_secret_sapphire: SearchForTheSecretSapphire = $SearchForTheSecretSapphire
@onready var title_sequence: TitleSequence = $TitleSequence
@onready var victory_sequence: VictorySequence = $VictorySequence

var first_victory:bool = true

####################
## INITIALISATION ##
####################

func _ready() -> void:
	reset()

func reset():
	
	# Hide everything (except for the black screen)
	hide_all()
	search_for_the_secret_sapphire.stop()
	
	# Play the intro sequence
	title_sequence.play_title_sequence(null, menus, 2, false, false, true)
	
	# Start the game (which starts the music)
	await get_tree().create_timer(2).timeout
	menus.play()


#######################
## SCENE TRANSITIONS ##
#######################

func transition_screen(from_screen:Node, to_screen:Node, linger_time:float = 3.0):
	TransitionFade.transition()
	await TransitionFade.fully_black
	from_screen.hide()
	to_screen.show()
	await get_tree().create_timer(linger_time).timeout

func hide_all():
	menus.hide()
	search_for_the_secret_sapphire.hide()

func play_secret_sapphire():
	
	# Stop the main game
	menus.stop(!first_victory)
	search_for_the_secret_sapphire.reset()
	
	# Start of game should be more abrupt the first time (for dramatic effect)
	if first_victory:
		first_victory = false
		title_sequence.play_title_sequence(menus, search_for_the_secret_sapphire, 5, true, true)
	else:
		title_sequence.play_title_sequence(menus, search_for_the_secret_sapphire, 5, false, true)
	
	# Start the "actual" game
	await title_sequence.done
	search_for_the_secret_sapphire.play()

func secret_sapphire_victory():
	search_for_the_secret_sapphire.stop()
	victory_sequence.play_outro_sequence(search_for_the_secret_sapphire, 3)


#################################
## INTERACTIONS FROM THE MENUS ##
#################################

func _on_menus_mute_music_toggled() -> void:
	if Global.music_muted:
		$SearchForTheSecretSapphire/Music.volume_db = -80
	else:
		$SearchForTheSecretSapphire/Music.volume_db = -8

func _on_menus_start_game() -> void:
	play_secret_sapphire()


##########################################################
## INTERACTIONS FROM THE SEARCH FOR THE SECRET SAPPHIRE ##
##########################################################

func _on_search_for_the_secret_sapphire_victory() -> void:
	secret_sapphire_victory()

func _on_victory_sequence_play_again() -> void:
	search_for_the_secret_sapphire.reset()
	transition_screen(victory_sequence, search_for_the_secret_sapphire, 1.5)
	search_for_the_secret_sapphire.play()

func _on_victory_sequence_main_menu() -> void:
	menus.play()
	# NOTE: This could not be more jankey, but it works perfectly fine.
	if $Menus/Menus/MainMenu/Desktop/DesktopWindows/HammerManEXE.visible:
		HammerManManager.hammer_man.active = true
	await transition_screen(victory_sequence, menus, 1.5)



###########
## DEBUG ##
###########

func _input(event: InputEvent) -> void:
	#pass
	
	if event.is_action_pressed("debugbutton"):
		_on_menus_start_game()
	
	# NOTE: Uncomment if you want a dodgy reset mechanic...
	#if event.is_action_pressed("reset"):
		#menus.queue_free()
		#var new_menus:Menus = menus_scene.instantiate()
		#add_child(new_menus)
		#menus = new_menus
		#menus.mute_music_toggled.connect(_on_menus_mute_music_toggled)
		#menus.start_game.connect(_on_menus_start_game)
		#reset()
