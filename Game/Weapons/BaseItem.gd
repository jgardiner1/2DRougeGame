extends StaticBody2D

var player
	
func _physics_process(delta):
	for body in get_child(1).get_node("PickupRadius").get_overlapping_bodies():
		if body is CharacterBody2D:
			player = body
			body.collided_item = self
		
		if player:
			if player.collided_item == self and not (player in get_child(1).get_node("PickupRadius").get_overlapping_bodies()):
				player.collided_item = null
