extends Node
class_name CardRotator

@export var gui: GUI

var _rot_deg: Vector2 = Vector2(50, 35)
var _offset: Vector2i = Vector2i(25, 15)
var _speed: Vector2i = Vector2i(60, 30)


func _process(delta):
	_rot_deg += delta * _speed
	for i in range(gui.cards.size()):
		var card: Card = gui.cards[i]
		card.rotation_x = _rot_deg.x + i * _offset.x
		card.rotation_y = _rot_deg.y + i * _offset.y
