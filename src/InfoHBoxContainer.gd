extends HBoxContainer

class_name InfoHBoxContainer

var username := "test_username" setget set_username
var color := Color() setget set_color

func set_username(new_username):
	username = new_username
	if has_node("Username"):
		$Username.text = username

func set_color(new_color):
	color = new_color
	if has_node("Color"):
		$Color.color = color
