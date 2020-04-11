extends Label


func _process(delta):
	if LobbySingleton.start_game_countdown < 3.0:
		visible = true
		text = str("Game starting in: ", LobbySingleton.start_game_countdown)
	else:
		visible = false
