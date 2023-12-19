extends Node2D

var distance_to_mouse
var mouse_position
var LeftHandItem
var speed = 10
var velocity = Vector2()
var radius = 15

func _process(delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	var player_pos = get_parent().global_transform.origin 
	var distance = player_pos.distance_to(mouse_pos) 
	var mouse_dir = (mouse_pos-player_pos).normalized()
	if distance > radius:
		mouse_pos = player_pos + (mouse_dir * radius)
	self.global_transform.origin = mouse_pos
