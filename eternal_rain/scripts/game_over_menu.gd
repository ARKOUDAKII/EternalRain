extends VBoxContainer

func _on_try_again_button_up() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_quit_button_up() -> void:
	get_tree().quit()
