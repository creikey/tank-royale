extends Node2D

#remotesync var player_id_to_spawnpoint = {}

#func _ready():
#	if get_tree().get_network_unique_id() == 1:
#		print("I'M TH SERVER")
#		randomize()
#		var non_taken_spawn_points := get_children().duplicate()
#		var cur_player_id_to_spawnpoint = {}
#		for id in LobbySingleton.player_info.keys():
#			var spawn_point_index := randi()%non_taken_spawn_points.size()
#			cur_player_id_to_spawnpoint[str(id)] = non_taken_spawn_points[spawn_point_index]
#			non_taken_spawn_points.remove(spawn_point_index)
#		print("Setting spawnpoints: ", cur_player_id_to_spawnpoint)
#		rset("player_id_to_spawnpoint", cur_player_id_to_spawnpoint.duplicate())
#	else:
#		yield(get_tree().create_timer(0.1), "timeout") # wait for spawn points to be chosen

#func _process(delta):
#	print("I'm in the main scene!")
#	for c in get_children():
#		print(c.get_children())

func add_player(player_node: Node2D, point_name: String):
	get_node(point_name).add_child(player_node)
#	if non_taken_spawn_points.size() == 0:
#		printerr("No more spawn points left for ", player_node, "!")
#		return
#
#	.add_child(player_node)
	
