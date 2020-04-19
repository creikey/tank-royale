extends CanvasLayer


func _process(_delta):
	$Sprite.region_rect.size = get_viewport().size
#	$Sprite.region_rect.position = get_parent().get_parent().get_viewport().get_final_transform().origin
#	print(get_parent().name)
#	print()
	$Sprite.region_rect.position = -get_parent().get_viewport_transform().origin
