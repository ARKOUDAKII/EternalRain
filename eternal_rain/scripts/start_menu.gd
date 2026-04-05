extends VBoxContainer

var Level_1 = "res://scenes/game.tscn"

func _on_button_button_up() -> void:
	get_tree().change_scene_to_file(Level_1)


func _on_quit_button_up() -> void:
	get_tree().quit()
