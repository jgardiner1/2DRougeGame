extends Camera2D

@export var smooth_lean := 10.0
@export var scale_lean := 0.2

func lean_camera_towards_mouse_(delta:float) -> void:
	var mouse_position := get_global_mouse_position()
	
	var direction_to_mouse := (mouse_position - position).normalized()
	var distance_to_mouse := mouse_position.distance_to(position)
	var lean := direction_to_mouse * distance_to_mouse * scale_lean
	offset = lerp(offset, lean, delta * smooth_lean)

func _process(delta) -> void:
	lean_camera_towards_mouse_(delta)
