extends Node

# singleton for lobby management

const port = 443
const max_players = 4
const url = "wss://a-hoy.club:" + str(port)

const map_size := 15
const wall_length = 200.0

signal player_info_updated

var server: WebSocketServer = null
var client: WebSocketClient = null

remotesync var start_game_countdown := 3.0

# have to wait for players to load in main scene
var players_done_configuring = []
# Player info, associate ID to data
var player_info = {}
# Info we send to other players
var my_info = { username = "creikey", color = Color8(255, 0, 255), ready = false }

var game_active := false
var printed_polling := false
# Connect all functions

func _ready():
	var args := OS.get_cmdline_args()
	if args.size() > 0:
		server = WebSocketServer.new()
#		server.bind_ip = bind_ip
		server.private_key = load("res://privkey.key")
		server.ssl_certificate = load("res://fullchain.crt")
		server.ca_chain = load("res://ca-certificates.crt")
		
# warning-ignore:return_value_discarded
		server.listen(port, PoolStringArray(), true)
		get_tree().set_network_peer(server)
		print("Serving on port ", port, "...")
	var _err := get_tree().connect("network_peer_connected", self, "_player_connected")
	_err = get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	_err = get_tree().connect("connected_to_server", self, "_connected_ok")
	_err = get_tree().connect("connection_failed", self, "_connected_fail")
	_err = get_tree().connect("server_disconnected", self, "_server_disconnected")


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
			if not printed_polling:
				print("polling!")
				printed_polling = true
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
#		match client.get_connection_status():
#			NetworkedMultiplayerPeer.CONNECTION_CONNECTED, \
#			NetworkedMultiplayerPeer.CONNECTION_CONNECTING:
#				client.poll()

func _player_connected(id):
	# Called on both clients and server when a peer connects. Send my info to it.
	print("Player connected: ", id)
	rpc_id(id, "register_player", my_info)

func _player_disconnected(id):
	player_info.erase(id) # Erase player from info.
	emit_signal("player_info_updated")

func _connected_ok():
	pass # Only called on clients, not server. Will go unused; not useful here.

func _server_disconnected():
	pass # Server kicked us; show error and abort.

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


	
#	get_node("/root/Main/SpawnPoints").add_player(my_player, spawnpoint_name)
#	get_node("/root/Main/Players").add_child(my_player)

remotesync func pre_configure_game():
	get_tree().set_pause(true)
	var self_peer_id = get_tree().get_network_unique_id()
	
	get_tree().change_scene("res://Main.tscn")
#	yield(get_tree().create_timer(0.2), "timeout")
	
#	if self_peer_id != 1:
#		spawn_player(self_peer_id, my_info, true, "test")
	
#	for p in player_info:
#		spawn_player(p, player_info[p], false, "test")
	
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

func my_info_changed():
	rpc("register_player", my_info)
#	for id in player_info.keys():
#		rpc_id(id, "register_player", my_info)
#	rpc_id(1, "register_player", my_info)
