extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Menus.play()
	$SearchForTheSecretSapphire.stop()


func _on_menus_start_game() -> void:
	$Menus.stop()
	$SearchForTheSecretSapphire.reset()
	$SearchForTheSecretSapphire.play()


func _on_menus_mute_music_toggled() -> void:
	if Global.music_muted:
		$SearchForTheSecretSapphire/Music.volume_db = -80
	else:
		$SearchForTheSecretSapphire/Music.volume_db = 0
