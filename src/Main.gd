extends Node2D

func _get_enabled_players() -> Array:
	var to_return: Array = []
	for c in $Players.get_children():
		if c.visible:
			to_return.append(c)
	return to_return

func _process(_delta):
	if get_tree().get_network_unique_id() != 1: # only check on the server
		return
#	print(LobbySingleton.player_info.keys())
	if LobbySingleton.player_info.keys().size() > 1: # more than one player
		var player_nodes: Array = _get_enabled_players()
		if player_nodes.size() == 1: # only one player left, winner!
			
			if $CameraTarget.cur_target != player_nodes[0]:
				rpc("focus_on_remaining_player")
#			if player_nodes.size() == 0:
#				$CameraTarget.cur_target = null
#			elif $CameraTarget.cur_target != player_nodes[0]:
#				$CameraTarget.cur_target = player_nodes[0]
			if $ReloadGameTimer.is_stopped():
				$ReloadGameTimer.start()
		elif player_nodes.size() == 0: # nobody left, immediately restart
			$ReloadGameTimer.stop()
			reload_game()
	elif _get_enabled_players().size() <= 0:
		reload_game()
#	if ($Players.get_children().size() <= 1 and LobbySingleton.player_info.keys().size > 1) or :
#		rpc_id(1, "reload_game")

remotesync func focus_on_remaining_player():
	var player_nodes: Array = _get_enabled_players()
#	if $CameraTarget.cur_target != player_nodes[0]:
	$CameraTarget.cur_target = player_nodes[0]

func reload_game():
	LobbySingleton.rpc("clear_players_done")
	LobbySingleton.rpc("pre_configure_game")
#	get_tree().reload_current_scene()


func _on_ReloadGameTimer_timeout():
	reload_game()
