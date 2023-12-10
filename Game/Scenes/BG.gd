extends ParallaxBackground

@onready var viewport_size = get_viewport().size
@onready var relative_x = 0
@onready var relative_y = 0

func _process(_delta):
	#scroll_offset.x -= scrolling_speed * delta
	pass

func _input(event):
	if event is InputEventMouseMotion:
		var mouse_x = event.position.x
		var mouse_y = event.position.y
		
		relative_x = -1 * (mouse_x - (viewport_size.x / 2)) / (viewport_size.x / 2)
		relative_y = -1 * (mouse_y - (viewport_size.y / 2)) / (viewport_size.y / 2)
		
		var multiplier = 10
		for child in self.get_children():
			child.motion_offset.x = multiplier * relative_x
			child.motion_offset.y = multiplier * relative_y
			multiplier = multiplier * 1.6
