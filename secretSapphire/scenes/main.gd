extends Node


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
