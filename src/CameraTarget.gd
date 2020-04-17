extends Node2D

var cur_target: Node2D = null setget set_cur_target
#var map_size: Vector2 = Vector2(1000, 1000)

func set_cur_target(new_cur_target):
	cur_target = new_cur_target
	if cur_target != null:
		print("New camera target: ", new_cur_target.name)
		cur_target.connect("die", self, "_on_cur_target_dead")
	else:
		print("New camerat arget is null!")

func _on_cur_target_dead():
	print("Cur target died!")
	cur_target = null

func _process(delta):
	if cur_target != null:
		global_position = cur_target.global_position
		return
	
	var map_size := LobbySingleton.map_size
	var wall_length := LobbySingleton.wall_length
	
	var total_map_size: Vector2 = Vector2(map_size, map_size)*wall_length
	var map_center: Vector2 = total_map_size/2.0
	
	global_position = map_center
	var screen_height: float = get_viewport().size.y
	var zoom_factor: float = total_map_size.y / screen_height
	$Camera2D.zoom = Vector2(zoom_factor, zoom_factor)
