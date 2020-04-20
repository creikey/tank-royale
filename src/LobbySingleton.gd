extends Node

# singleton for lobby management

const global_port = 443
const global_url = "wss://a-hoy.club:" + str(global_port)
const local_port = 8885
const local_url = "ws://127.0.0.1:" + str(local_port)

const map_size := 7
const wall_length = 200.0

signal player_info_updated

var server: WebSocketServer = null
var client: WebSocketClient = null

remotesync var start_game_countdown := 3.0

# have to wait for players to load in main scene
var players_done_configuring = []
var players_done_disconnecting = []
# Player info, associate ID to data
remote var player_info = {}
# Info we send to other players
var my_info = { username = "creikey", color = Color8(255, 0, 255), ready = false, score = 0 }

var server_closing := false
var game_active := false
var client_connected_once_before := false # see if connection status was equal to 1 or 2 at some point

func _get_adjacent_file(filename: String):
	return load(ProjectSettings.globalize_path(str("res://", filename)))

func _ready():

	# cli loading of certs and game start
	var args := OS.get_cmdline_args()
	if args.size() > 0:
		var processed_args = args

		for i in processed_args.size():
			processed_args[i] = processed_args[i].trim_prefix("--")

		server = WebSocketServer.new()
		
		server.private_key = _get_adjacent_file(processed_args[0])
		server.ssl_certificate = _get_adjacent_file(processed_args[1])
		server.ca_chain = _get_adjacent_file(processed_args[2])

		activate_server(global_port)
		
# warning-ignore:return_value_discarded
	var _err := get_tree().connect("network_peer_connected", self, "_player_connected")
	_err = get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	_err = get_tree().connect("connected_to_server", self, "_connected_ok")
	_err = get_tree().connect("connection_failed", self, "_connected_fail")
	_err = get_tree().connect("server_disconnected", self, "_server_disconnected")

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST and server != null:
		print("Safely quitting server...")
		server_closing = true
		server.refuse_new_connections = true
		for id in player_info.keys():
			server.disconnect_peer(id)
#		server.stop()

func connect_client_signals():
	client.connect("server_close_request", self, "_on_server_close_request")
	client.connect("connection_closed", self, "_on_server_hard_closed")
#	client.connect("connection_closed", self, "_on_client_connection_closed")

func activate_server(port: int):
	get_tree().set_auto_accept_quit(false)
	server.listen(port, PoolStringArray(), true)
	get_tree().set_network_peer(server)
#	server.connect("client_disconnected", self, "_on_client_disconnected")
	print("Serving on port ", port, "...")

func _on_server_close_request(_code, _reason):
	_on_server_hard_closed(true)
	

func _on_server_hard_closed(_was_clean: bool):
	client_connected_once_before = false
	player_info.clear()
	players_done_configuring.clear()
	client.disconnect_from_host()
	client = null
	get_tree().change_scene("res://ServerDisconnectedScreen.tscn")

#func _on_client_connection_closed(clean_close):
#

#func _on_client_disconnected(id, was_clean_close):
#	

func _everybody_ready() -> bool:
	assert(get_tree().get_network_unique_id() == 1)
	if player_info.size() == 0:
#		print("player info size is 0")
		return false
#	if not my_info["ready"]:
#		return false
	for p in player_info:
		if p == 1:
			continue
		if player_info[p]["ready"] == false:
#			print("Player ", p, "Is not ready")
			return false
#	print("Everybody's ready")
	return true

func _process(delta):
	if server != null:
		if server.is_listening():
			server.poll()
			if game_active:
				return
			if _everybody_ready():
				rset("start_game_countdown", start_game_countdown - delta)
				if start_game_countdown <= 0.0:
					game_active = true
#					var main_scene: Node2D = preload("res://Main.tscn").instance()
#					var available_spawn_points = main_scene.get_node("SpawnPoints").get_children().duplicate()
#					var id_to_spawnpoint_name = {}
#					randomize()
#					for id in player_info:
#						var cur_index = randi()%available_spawn_points.size()
#						id_to_spawnpoint_name[id] = available_spawn_points[cur_index].name
#						available_spawn_points.remove(cur_index)
					rpc("pre_configure_game")
			else:
				rset("start_game_countdown", 3.0)
	if client != null:
		client.poll()
		if client_connected_once_before and client.get_connection_status() == 0:
			_on_server_hard_closed(false)
		elif client.get_connection_status() == WebSocketMultiplayerPeer.CONNECTION_CONNECTED:
			client_connected_once_before = true
#		print(client.get_connection_status())
#		match client.get_connection_status():
#			NetworkedMultiplayerPeer.CONNECTION_CONNECTED, \
#			NetworkedMultiplayerPeer.CONNECTION_CONNECTING:
#				client.poll()

func _player_connected(id):
	# Called on both clients and server when a peer connects. Send my info to it.
	if get_tree().is_network_server() and game_active:
		rpc_id(id, "goto_midgame_lobby")
		return
#		rset_id(id, "player_info", player_info)
#		rpc_id(id, "pre_configure_game")
	
	print("Player connected: ", id)
	rpc_id(id, "register_player", my_info)

remote func goto_midgame_lobby():
	get_tree().change_scene("res://MidjoinLobby.tscn")

func _player_disconnected(id):
	if get_tree().is_network_server() and server_closing:
		players_done_disconnecting.append(id)
		print("Players disconnected: ", players_done_disconnecting.size(), " / ", player_info.keys().size())
		if players_done_disconnecting.size() == player_info.keys().size():
			server.stop()
			get_tree().quit()
	if id == 1:
		client.disconnect_from_host()
		get_tree().change_scene("res://ServerDisconnectedScreen.tscn")
	player_info.erase(id) # Erase player from info.
	emit_signal("player_info_updated")

func _connected_ok():
	pass # Only called on clients, not server. Will go unused; not useful here.

func _server_disconnected():
	get_tree().change_scene("res://ServerDisconnectedScreen.tscn")

func _connected_fail():
	pass # Could not even connect to server; abort.

remote func register_player(info):
	print("info received: ", info)
	# Get the id of the RPC sender.
	var id = get_tree().get_rpc_sender_id()
	
	# Store the info
	if id != 1:
		player_info[id] = info

	# Call function to update lobby UI here
	emit_signal("player_info_updated")

remotesync func clear_players_done():
	players_done_configuring.clear()
#	get_node("/root/Main/SpawnPoints").add_player(my_player, spawnpoint_name)
#	get_node("/root/Main/Players").add_child(my_player)

remotesync func pre_configure_game():
	get_tree().set_pause(true)
	var self_peer_id = get_tree().get_network_unique_id()
	
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://Main.tscn")
#	yield(get_tree().create_timer(0.2), "timeout")
	
#	if self_peer_id != 1:
#		spawn_player(self_peer_id, my_info, true, "test")
	
#	for p in player_info:
#		spawn_player(p, player_info[p], false, "test")
	if self_peer_id != 1:
		rpc_id(1, "done_preconfiguring", self_peer_id)

remote func done_preconfiguring(who):
	# Here are some checks you can do, for example
	assert(get_tree().is_network_server())
	assert(who in player_info) # Exists
	assert(not who in players_done_configuring) # Was not added yet

	players_done_configuring.append(who)

	if players_done_configuring.size() == player_info.size():
		get_node("/root/Main/GeneratedMap").generate_map()
		rpc("post_configure_game")

remotesync func post_configure_game():
	get_tree().set_pause(false)
	# Game starts now!

remote func increment_my_score():
	my_info["score"] += 1
	my_info_changed()

func my_info_changed():
	rpc("register_player", my_info)
	emit_signal("player_info_updated")
#	for id in player_info.keys():
#		rpc_id(id, "register_player", my_info)
#	rpc_id(1, "register_player", my_info)
