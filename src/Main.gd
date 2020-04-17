extends Node2D

func _process(delta):
	if get_tree().get_network_unique_id() != 1: # only check on the server
		return
	if LobbySingleton.player_info.keys().size() + 1 > 1: # must add one, excludes my info
		if $Players.get_children().size() <= 1:
			var player_nodes: Array = $Players.get_children()
			if $CameraTarget.cur_target != player_nodes[0]:
				$CameraTarget.cur_target = player_nodes[0]
			if $ReloadGameTimer.is_stopped():
				$ReloadGameTimer.start()
	elif $Players.get_children().size() <= 0:
		reload_game()
#	if ($Players.get_children().size() <= 1 and LobbySingleton.player_info.keys().size > 1) or :
#		rpc_id(1, "reload_game")

func reload_game():
	LobbySingleton.rpc("clear_players_done")
	LobbySingleton.rpc("pre_configure_game")
#	get_tree().reload_current_scene()


func _on_ReloadGameTimer_timeout():
	reload_game()
