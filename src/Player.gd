extends KinematicBody2D

const speed = 500.0

var username := "" setget set_username

remote var target_transform := Transform2D()
#remotesync var horizontal_input := 0.0
#remotesync var vertical_input := 0.0

func _ready():
	target_transform = global_transform

func set_username(new_username):
	username = new_username
	if has_node("UsernameLabel"):
		$UsernameLabel.text = username

func _physics_process(delta):
	if is_network_master():
		var horizontal := float(Input.is_action_pressed("g_right")) - float(Input.is_action_pressed("g_left"))
		var vertical := float(Input.is_action_pressed("g_down")) - float(Input.is_action_pressed("g_up"))
		rotation += deg2rad(horizontal*360.0*delta)
		var _vel := move_and_slide(Vector2(speed*vertical, 0.0).rotated(rotation + PI))
		rset("target_transform", global_transform)
	else:
		global_transform = target_transform
	$UsernameLabel.rect_rotation = -rad2deg(rotation)
#	$UsernameLabel.rect_rotation = -rotation/2.0
#		var _vel := move_and_slide((target_position - global_position)/delta)
