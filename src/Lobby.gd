extends Node2D

export (NodePath) var my_username_edit_path
export (NodePath) var my_color_edit_path
export (NodePath) var users_vbox_path
export (PackedScene) var player_info_hbox_pack

onready var my_username_edit: LineEdit = get_node(my_username_edit_path)
onready var my_color_edit: ColorPickerButton = get_node(my_color_edit_path)
onready var users_vbox: VBoxContainer = get_node(users_vbox_path)

func _ready():
	my_username_edit.text = LobbySingleton.my_info["username"]
	my_color_edit.color = LobbySingleton.my_info["color"]
# warning-ignore:return_value_discarded
	LobbySingleton.connect("player_info_updated", self, "_on_player_info_update")
	_on_player_info_update()

func _on_player_info_update():
	for c in users_vbox.get_children():
		c.queue_free()
	for player_id in LobbySingleton.player_info.keys():
		var cur_player_info_hbox: InfoHBoxContainer = player_info_hbox_pack.instance()
		cur_player_info_hbox.name = str(player_id)
		users_vbox.add_child(cur_player_info_hbox)
		cur_player_info_hbox.username = LobbySingleton.player_info[player_id]["username"]
		cur_player_info_hbox.color = LobbySingleton.player_info[player_id]["color"]
		cur_player_info_hbox.ready = LobbySingleton.player_info[player_id]["ready"]

func _on_UsernameEdit_text_changed(new_text):
	LobbySingleton.my_info["username"] = new_text
	LobbySingleton.my_info_changed()

func _on_ColorEdit_color_changed(color):
	LobbySingleton.my_info["color"] = color
	LobbySingleton.my_info_changed()


func _on_CheckBox_toggled(button_pressed):
	LobbySingleton.my_info["ready"] = button_pressed
	LobbySingleton.my_info_changed()
