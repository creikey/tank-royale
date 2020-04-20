extends Node2D

export (NodePath) var connect_button_path
export (NodePath) var status_label_path
export (NodePath) var force_global_checkbox_path

onready var connect_button = get_node(connect_button_path)
onready var status_label = get_node(status_label_path)
onready var force_global_checkbox = get_node(force_global_checkbox_path)


func _on_ConnectButton_pressed():
	connect_button.visible = false
	status_label.text = "Connecting..."
	status_label.visible = true
	
	LobbySingleton.client = WebSocketClient.new()
# warning-ignore:return_value_discarded
	LobbySingleton.client.connect("connection_error", self, "_on_connection_error")

	# choose local url if in editor
	var my_url: String = LobbySingleton.local_url
	if OS.has_feature("standalone") or force_global_checkbox.pressed:
		my_url = LobbySingleton.global_url

	var err: int = LobbySingleton.client.connect_to_url(my_url, PoolStringArray(), true)
	if err != OK:
		status_label.text = str("Error connecting: ", str(err))
		connect_button.visible = true
		return
	get_tree().set_network_peer(LobbySingleton.client)
	LobbySingleton.connect_client_signals()
# warning-ignore:return_value_discarded
	get_tree().connect("connection_failed", self, "_on_connection_error")
# warning-ignore:return_value_discarded
	get_tree().connect("connected_to_server", self, "_on_connected")

func _on_connected():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://Lobby.tscn")

func _on_connection_error():
	status_label.text = str("Error connecting: Could not connect to server")
	connect_button.visible = true
	return

# func _process(_delta):
	# if LobbySingleton.client != null and LobbySingleton.client.get_connection_status() == WebSocketClient.CONNECTION_CONNECTED:
		# status_label.text = "Connected!"
#		yield(get_tree().create_timer(0.5), "timeout")
	# warning-ignore:return_value_discarded
		# get_tree().change_scene("res://Lobby.tscn")
	


func _on_HostLocalServerButton_pressed():
	LobbySingleton.server = WebSocketServer.new()
	LobbySingleton.activate_server(LobbySingleton.local_port)
	get_tree().change_scene("res://Lobby.tscn")
