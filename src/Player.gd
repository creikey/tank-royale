extends KinematicBody2D

const speed = 500.0

signal die

export (PackedScene) var bullet_pack

var username := "" setget set_username
var number_of_bullets := 0 # for unique names

remote var target_transform := Transform2D()
#remotesync var horizontal_input := 0.0
#remotesync var vertical_input := 0.0

func _ready():
	target_transform = global_transform

func set_username(new_username):
	username = new_username
	if has_node("UsernameLabel"):
		$UsernameLabel.text = username

remotesync func fire_bullet(bullet_transform: Transform2D, direction: Vector2, bullet_name: String, owner_id: int):
	var cur_bullet = bullet_pack.instance()
	get_node("/root/Main/Bullets").add_child(cur_bullet)
	cur_bullet.my_owner_id = owner_id
	cur_bullet.global_transform = bullet_transform
	cur_bullet.movement_vector = direction
	cur_bullet.global_position += direction*105.0
	cur_bullet.name = bullet_name
	cur_bullet.set_network_master(1)

func _input(event):
	if is_network_master() and event.is_action_pressed("g_fire"):
		number_of_bullets += 1
		rpc("fire_bullet", global_transform, Vector2(1, 0).rotated(rotation), str(name,"_",number_of_bullets), get_tree().get_network_unique_id())

func _physics_process(delta):
	if is_network_master():
		var horizontal := float(Input.is_action_pressed("g_right")) - float(Input.is_action_pressed("g_left"))
		var vertical := float(Input.is_action_pressed("g_down")) - float(Input.is_action_pressed("g_up"))
		rotation += deg2rad(horizontal*360.0*delta)
		var _vel := move_and_slide(Vector2(speed*vertical, 0.0).rotated(rotation + PI))
		rset_unreliable("target_transform", global_transform)
	else:
		global_transform = target_transform
	$UsernameLabel.rect_rotation = -rad2deg(rotation)
#	$UsernameLabel.rect_rotation = -rotation/2.0
#		var _vel := move_and_slide((target_position - global_position)/delta)

#puppet func delete_myself():
#	emit_signal("die")
#	queue_free()

remotesync func die():
#	rpc("delete_myself")
	emit_signal("die")
	queue_free()
	
