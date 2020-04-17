extends StaticBody2D

const line_thickness = 8.0

export var line_color = Color()

var cell_data = null setget set_cell_data

func set_cell_data(new_cell_data):
	cell_data = new_cell_data
	update()

func _ready():
	var wall_length := LobbySingleton.wall_length
	$LeftWall.shape.b.y = wall_length
	$RightWall.position.x = wall_length
	$TopWall.shape.b.x = wall_length
	$BottomWall.position.y = wall_length
	update()

func _draw():
	var wall_length := LobbySingleton.wall_length
	if cell_data == null:
		return
	if not has_node("LeftWall"):
		return
	for c in get_children():
		c.disabled = true
	if cell_data["top_barrier"]:
		draw_line(Vector2(), Vector2(wall_length, 0), line_color, line_thickness)
		$TopWall.disabled = false
	if cell_data["bottom_barrier"]:
		draw_line(Vector2(0, wall_length), Vector2(wall_length, wall_length), line_color, line_thickness)
		$BottomWall.disabled = false
	if cell_data["left_barrier"]:
		draw_line(Vector2(), Vector2(0, wall_length), line_color, line_thickness)
		$LeftWall.disabled = false
	if cell_data["right_barrier"]:
		draw_line(Vector2(wall_length, 0), Vector2(wall_length, wall_length), line_color, line_thickness)
		$RightWall.disabled = false
