extends HBoxContainer

class_name InfoHBoxContainer

var username := "test_username" setget set_username
var color := Color() setget set_color
var ready := false setget set_ready

func set_username(new_username):
	username = new_username
	if has_node("Username"):
		$Username.text = username

func set_color(new_color):
	color = new_color
	if has_node("Color"):
		$Color.color = color

func set_ready(new_ready):
	ready = new_ready
	if has_node("ReadyLabel"):
		if ready:
			$ReadyLabel.text = "ready"
			$ReadyLabel.add_color_override("font_color", Color(0.2, 1, 0.2))
		else:
			$ReadyLabel.text = "not ready"
			$ReadyLabel.add_color_override("font_color", Color(1, 0.2, 0.2))
