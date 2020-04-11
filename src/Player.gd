extends KinematicBody2D

var username := "" setget set_username

func set_username(new_username):
	username = new_username
	if has_node("UsernameLabel"):
		$UsernameLabel.text = username
