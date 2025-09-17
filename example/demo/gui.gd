extends CanvasLayer
class_name GUI

@onready var cards: Array[Card] = _get_cards()


func _get_cards():
	var children = $MarginContainer/VBoxContainer/HBoxContainer.get_children()
	var result: Array[Card] = []
	for child in children:
		result.append(child as Card)
	return result
