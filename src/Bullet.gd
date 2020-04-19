extends KinematicBody2D

const speed = 300.0

remote var target_transform: Transform2D = Transform2D()

var movement_vector: Vector2 = Vector2(1, 0)
var my_owner_id := 1

func _ready():
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")

func _player_disconnected(id):
	if my_owner_id == id:
		queue_free()

func _physics_process(delta):
	if not is_network_master():
		global_transform = target_transform
		return
	
	var collision: KinematicCollision2D = move_and_collide(movement_vector*speed*delta)
	
	if collision != null:
		if collision.collider.is_in_group("players"):
			if collision.collider.get_network_master() == my_owner_id: # you hit yourself
				pass
			else:
				LobbySingleton.rpc_id(my_owner_id, "increment_my_score")
			collision.collider.rpc("die")
		else:
			movement_vector = -movement_vector.reflect(collision.normal)
	
	rset_unreliable("target_transform", global_transform)

func _draw():
	draw_circle(Vector2(), $CollisionShape2D.shape.radius, Color())
