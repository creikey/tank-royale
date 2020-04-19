extends PanelContainer

export (PackedScene) var score_hbox_container_pack

onready var information_vbox = $V

func _ready():
# warning-ignore:return_value_discarded
	LobbySingleton.connect("player_info_updated", self, "_on_player_info_updated")
	_on_player_info_updated()

func _add_player(id: int, username: String, score: int):
	var cur_score_hbox: HBoxContainer = score_hbox_container_pack.instance()
	cur_score_hbox.name = str(id)
	information_vbox.add_child(cur_score_hbox)
	cur_score_hbox.username = username
	cur_score_hbox.score = score

func _on_player_info_updated():
	for c in information_vbox.get_children():
		if c is Label:
			continue
		c.queue_free()
	
	if not get_tree().is_network_server():
		_add_player(get_tree().get_network_unique_id(), LobbySingleton.my_info["username"], LobbySingleton.my_info["score"])
	for id in LobbySingleton.player_info.keys():
		_add_player(id, LobbySingleton.player_info[id]["username"], LobbySingleton.player_info[id]["score"])
