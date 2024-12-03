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


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#$BlackScreen.show()
	#$TransitionScreen.transition()
	#await $TransitionScreen.transitioned
	#$BlackScreen.hide()
	$Menus.play()
	$SearchForTheSecretSapphire.stop()
	$CreditScreen.hide()
	$TitleScreen.hide()
	$VictoryScreen.hide()

func _process(delta):
	
	# TODO: This is my ad-hoc fix for a gamebreaking bug that can cause the
	# desktop to be un-interactable. It's definitely an inefficient solution
	# that doesn't really address the actual problem, but it 
	if !Input.is_action_pressed("click"):
		Global.is_dragging = false


func _on_menus_start_game() -> void:
	#$TransitionScreen.transition()
	#await $TransitionScreen.transitioned
	$Menus.stop()
	$CreditScreen.show()
	await get_tree().create_timer(3).timeout
	$CreditScreen.hide()
	$TitleScreen.show()
	await get_tree().create_timer(3).timeout
	$TitleScreen.hide()
	$SearchForTheSecretSapphire.reset()
	$SearchForTheSecretSapphire.play()


func _on_menus_mute_music_toggled() -> void:
	if Global.music_muted:
		$SearchForTheSecretSapphire/Music.volume_db = -80
	else:
		$SearchForTheSecretSapphire/Music.volume_db = 0


func _on_search_for_the_secret_sapphire_victory() -> void:
	await get_tree().create_timer(3).timeout
	$SearchForTheSecretSapphire.stop()
	$VictoryScreen.show()


func _on_play_again_pressed() -> void:
	$VictoryScreen.hide()
	_on_menus_start_game()


func _on_main_menu_pressed() -> void:
	_ready()
