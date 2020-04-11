extends Node

# singleton for lobby management

const port = 443
const url = "wss://a-hoy.club:" + str(port)

signal player_info_updated

var server: WebSocketServer = null
var client: WebSocketClient = null

# Player info, associate ID to data
var player_info = {}
# Info we send to other players
var my_info = { username = "creikey", color = Color8(255, 0, 255), ready = false }

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

var printed_polling := false

func _process(_delta):
	if server != null:
		if server.is_listening():
			if not printed_polling:
				print("polling!")
				printed_polling = true
			server.poll()
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
	if id == 1:
		return
	# Store the info
	player_info[id] = info

	# Call function to update lobby UI here
	emit_signal("player_info_updated")

func my_info_changed():
	for id in player_info.keys():
		rpc_id(id, "register_player", my_info)
