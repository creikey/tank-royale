extends Node2D

func _ready():
	LobbySingleton.client.disconnect_from_host()
