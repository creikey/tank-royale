extends Control

func _ready():
	visible = not OS.has_feature("standalone")
