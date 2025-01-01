extends Button

signal box_toggled(toggled_on:bool)

# Checked and Unchecked box icon artwork
const CHECK_BOX_UNCHECKED = preload("res://assets/art/menu_components/checkBoxUnchecked.png")
const CHECK_BOX_CHECKED = preload("res://assets/art/menu_components/checkBoxChecked.png")

# TODO: Descriptor
@export var checkable : bool

func _ready(): 
	if checkable: 
		icon = CHECK_BOX_UNCHECKED

# TODO: Descriptor
# TODO: Maybe use inheritance for this instead of this...
func update_icon(checked:bool): 
	if checkable: 
		icon = get_checkbox_icon(checked)
	else:
		print_debug("update_icon() was called on non-checkable menu button:", checked)

# TODO: Descriptor
func get_checkbox_icon(checked:bool) -> Resource:
	if checked:
		return CHECK_BOX_CHECKED
	else:
		return CHECK_BOX_UNCHECKED


func _on_pressed() -> void:
	if !Global.sfx_muted: $SelectNoise.play()
	if checkable:
		
		var toggled_on:bool = icon == CHECK_BOX_UNCHECKED
		
		if toggled_on:
			icon = CHECK_BOX_CHECKED
		else:
			icon = CHECK_BOX_UNCHECKED
		
		box_toggled.emit(toggled_on)
