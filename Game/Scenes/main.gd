extends Node2D

func _on_play_btn_pressed():
	get_tree().change_scene_to_file("res://Scenes/World.tscn")

func _on_exit_btn_pressed():
	get_tree().quit()

func hover_on(node) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(node, "scale", Vector2(1.2, 1.2), 0.1)

func hover_off(node) -> void:
	var tweens = get_tree().get_processed_tweens()
	for tween in tweens:
		tween.kill()
	node.scale = Vector2(1, 1)

func _on_play_btn_mouse_entered():
	hover_on(get_node("PlayBtn"))

func _on_play_btn_mouse_exited():
	hover_off(get_node("PlayBtn"))

func _on_exit_btn_mouse_entered():
	hover_on(get_node("ExitBtn"))

func _on_exit_btn_mouse_exited():
	hover_off(get_node("ExitBtn"))

func _on_test_btn_mouse_entered():
	hover_on(get_node("TestBtn"))

func _on_test_btn_mouse_exited():
	hover_off(get_node("TestBtn"))

func _on_test_btn_2_mouse_entered():
	hover_on(get_node("TestBtn2"))

func _on_test_btn_2_mouse_exited():
	hover_off(get_node("TestBtn2"))

func _on_test_btn_3_mouse_entered():
	hover_on(get_node("TestBtn3"))

func _on_test_btn_3_mouse_exited():
	hover_off(get_node("TestBtn3"))
