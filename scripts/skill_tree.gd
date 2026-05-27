extends Node2D

@export var player: CharacterBody2D;
@export var menu: Node2D;
@onready var label: Label = $menu/Label

var skill_tree_path = "res://files/skill_tree.JSON"
var reset_path = "res://files/reset_sktree.JSON"

var dash_bonus: float;
var fireball_bonus: float;

var UnlockedSkills: Dictionary;
var LockedSkills: Dictionary;

func _ready() -> void:
	var SkillTree = load_unlocked_from_JSON(skill_tree_path)
	UnlockedSkills = SkillTree["unlocked"]
	LockedSkills = SkillTree["locked"]
	SkillTree = null
	innit_buttons()
	update_label()
	
func innit_buttons() -> void:
	var buttons = menu.find_children("*", "Button")
	for b in buttons:
		if UnlockedSkills.has(b.skill):
			b.disabled = true

func update_label() -> void:
	label.text = "Skill Points:"+str(player.SPOINTS)

func toggle_menu(open: bool) -> void:
	if open:
		menu.visible = true
		position = Vector2(0,0)
	else:
		menu.visible = false;
		position = Vector2(0, 500)
	
func unlock_skill(skill: String) -> bool:
	if UnlockedSkills.has(skill):
		return false
		
	var cost = LockedSkills[skill]["cost"]
	var pre = LockedSkills[skill]["pre"]
	if player.SPOINTS < cost:
		print("Not Enough Skill Points!")
		return false;
	elif not UnlockedSkills.has_all(pre):
		print("Not necessary pre")
		return false;
	else:
		player.SPOINTS -= cost
		var merge_dict = {skill: ""}
		merge_dict[skill] = LockedSkills[skill]
		LockedSkills.erase(skill)
		UnlockedSkills.merge(merge_dict)
		merge_dict = null
		update_label()
		innit_buttons()
		store_unlocked_to_JSON()
		player.update_stats()
		return true;
		
func is_unlocked(skill: String) -> bool:
	return UnlockedSkills.has(skill)

func load_unlocked_from_JSON(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		print("ERROR IN skill_tree, FILES NOT FOUND!")
		return {}
	
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		print("Failed to open file!")
		return {}
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(json_string)
	
	if error == OK:
		return json.data
	else:
		print("JSON parse error!")
		return {}

func store_unlocked_to_JSON() -> bool:
	var SkillTree = {
		"locked": {},
		"unlocked": {}
	}
	SkillTree["locked"] = LockedSkills
	SkillTree["unlocked"] = UnlockedSkills
	var json_string = JSON.stringify(SkillTree, "\t")
	SkillTree = null
	var file = FileAccess.open(skill_tree_path, FileAccess.WRITE)
	if file == null:
		print("failed to open file!")
		return false;
	file.store_string(json_string)
	file.close()
	return true
	
func reset_skill_tree_JSON() -> bool:	
	var file = FileAccess.open(reset_path, FileAccess.READ);
	if file==null:
		print('reset_skill_tree_JSON, file read failed')
		return false
	var loaded_string = file.get_as_text()
	file.close()
	file = FileAccess.open(skill_tree_path, FileAccess.WRITE);
	if file==null:
		print('reset_skill_tree_JSON, file write failed')
		return false
	file.store_string(loaded_string)
	file.close()
	
	return true
