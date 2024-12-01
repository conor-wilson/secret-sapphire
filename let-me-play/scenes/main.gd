extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Menus.show()
	$Menus.active = true
	$SearchForTheSecretSapphire.hide()
	$SearchForTheSecretSapphire.active = false


func _on_menus_start_game() -> void:
	$Menus.hide()
	$Menus.active = false
	$SearchForTheSecretSapphire.show()
	$SearchForTheSecretSapphire.reset()
	$SearchForTheSecretSapphire.active = true
