extends Node2D

export (PackedScene) var maze_cell_body_pack
export (NodePath) var players_path
export (NodePath) var camera_target_path

#class Cell:
#	var left_barrier := true
#	var right_barrier := true
#	var top_barrier := true
#	var bottom_barrier := true
#
#	var visited = false
const default_cell = {
	"left_barrier": true,
	"right_barrier": true,
	"top_barrier": true,
	"bottom_barrier": true
}

remote var id_to_spawnpoint := {}
remote var cell_data: Array = []

func _empty_map_array() -> Array:
	var map_size := LobbySingleton.map_size
	var to_return: Array = []
	to_return.resize(map_size)
	for row in to_return.size():
		to_return[row] = []
		to_return[row].resize(map_size)
		for column in to_return[row].size():
			to_return[row][column] = default_cell.duplicate(true)
	return to_return

func generate_map():
	var map_size := LobbySingleton.map_size
	var wall_length := LobbySingleton.wall_length
	randomize()

	# construct the maze
	cell_data = _empty_map_array()
	
	# carve paths
	for row in cell_data.size():
		for column in cell_data[row].size():
			var is_carving_to_top: bool = bool(randi()%2)
			if is_carving_to_top:
				if row - 1 >= 0:
					cell_data[row - 1][column]["bottom_barrier"] = false
					cell_data[row][column]["top_barrier"] = false
			else:
				if column - 1 >= 0:
					cell_data[row][column - 1]["right_barrier"] = false
					cell_data[row][column]["left_barrier"] = false
			if randi()%2 == 0 and row + 1 < cell_data.size():
				cell_data[row + 1][column]["top_barrier"] = false
				cell_data[row][column]["bottom_barrier"] = false

#	var maze_wall_length: float = maze_cell_body_pack.instance().wall_length # this is bad but idc
	
	var available_spawn_points = []
	available_spawn_points.resize(map_size)
	for row in available_spawn_points.size():
		available_spawn_points[row] = []
		available_spawn_points[row].resize(map_size)
		for column in available_spawn_points[row].size():
			available_spawn_points[row][column] = {"row":row, "column":column}
	
	# randomize row/column spawn points
	for id in LobbySingleton.player_info.keys(): # because running on the server this includes everybody
		# pick a spot in the available spawn points
		var available_spawn_point_row: int = randi()%available_spawn_points.size()
		var available_spawn_point_column: int = randi()%available_spawn_points[available_spawn_point_row].size()
		
		# get the row/column then set the spawnpoint
		var spawn_point_data = available_spawn_points[available_spawn_point_row][available_spawn_point_column]
		var row: int = spawn_point_data["row"]
		var column: int = spawn_point_data["column"]
		
#		print(id,"	",row,"	",column)
		
		id_to_spawnpoint[id] = Vector2(row, column)*wall_length + Vector2(wall_length, wall_length)/2.0
		
		# remove the spawnpoint current player is spawning on
		available_spawn_points[row].remove(column)
		if available_spawn_points[row].size() <= 0:
			available_spawn_points.remove(row)
		
#		id_to_spawnpoint[id] = Vector2(randi()%map_size, randi()%map_size)*maze_wall_length + Vector2(maze_wall_length, maze_wall_length)/2.0

	rset("id_to_spawnpoint", id_to_spawnpoint)
	rset("cell_data", cell_data)
	rpc("add_maze_bodies")
	rpc("spawn_players")

func spawn_player(peer_id: int, info: Dictionary, spawnpoint: Vector2) -> Node2D:
	var cur_player = preload("res://Player.tscn").instance()
	cur_player.set_name(str(peer_id))
#	cur_player.get_node("Camera2D").current = is_my_player
	cur_player.set_network_master(peer_id)
	
	cur_player.modulate = info["color"]
	cur_player.username = info["username"]
	
	get_node(players_path).add_child(cur_player)
	cur_player.position = spawnpoint
	cur_player.enable()
	return cur_player

remotesync func spawn_players():
	var my_id: int = get_tree().get_network_unique_id()
	if my_id != 1:
		var my_player := spawn_player(my_id, LobbySingleton.my_info, id_to_spawnpoint[my_id])
		get_node(camera_target_path).cur_target = my_player
		
	for id in LobbySingleton.player_info.keys():
		var _new_player = spawn_player(id, LobbySingleton.player_info[id], id_to_spawnpoint[id])

remotesync func add_maze_bodies():
	var wall_length := LobbySingleton.wall_length
	for row in cell_data.size():
		for column in cell_data[row].size():
			var cur_maze_cell_body = maze_cell_body_pack.instance()
			add_child(cur_maze_cell_body)
			cur_maze_cell_body.position = Vector2(column, row)*wall_length
			cur_maze_cell_body.cell_data = cell_data[row][column]
