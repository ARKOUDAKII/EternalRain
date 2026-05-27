extends Button
@export var skill : String
@onready var skill_tree: Node2D = $"../.."
@onready var label_2: Label = $"../Label2"

func _on_pressed() -> void:
	if skill_tree.unlock_skill(skill):
		disabled = true
		label_2.text = "Unlocked!"
	else:
		label_2.text = "Not enough Skill Points!"
