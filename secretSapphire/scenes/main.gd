extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Menus.play()
	$SearchForTheSecretSapphire.stop()


func _on_menus_start_game() -> void:
	$Menus.stop()
	$SearchForTheSecretSapphire.reset()
	$SearchForTheSecretSapphire.play()
