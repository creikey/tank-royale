extends Node2D

export (NodePath) var connect_button_path
export (NodePath) var status_label_path

onready var connect_button = get_node(connect_button_path)
onready var status_label = get_node(status_label_path)



func _on_ConnectButton_pressed():
	connect_button.visible = false
	status_label.text = "Connecting..."
	status_label.visible = true
	
	LobbySingleton.client = WebSocketClient.new()
	var err: int = LobbySingleton.client.connect_to_url(LobbySingleton.url, PoolStringArray(), true)
	if err != OK:
		status_label.text = str("Error connecting: ", str(err))
		connect_button.visible = true
		return
	get_tree().set_network_peer(LobbySingleton.client)
	status_label.text = "Connected!"
	yield(get_tree().create_timer(0.5), "timeout")
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://Lobby.tscn")
	
