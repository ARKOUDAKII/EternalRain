extends Node2D

@export var transitions: Array
@export var path: String;
@export var current_save_file: String;

func _ready() -> void: # on ready load the level
	pass

func save_to_file() -> bool: #save current level to JSON file
	
	var dict = {
		"enemies" : [],
		"pickups" : [],
		"equipment" : [],
		"environment" : []
	}
	
	for c in get_children():
		match c.type:
			"enemy" :
				dict["enemy"].append({
					"type" : c.type,
					"hp" : c.hp,
					"x" : c.position.x,
					"y" : c.position.y
				})
			"pickup" :
				dict["pickups"].append({
					"type" : c.type,
					"x" : c.position.x,
					"y" : c.position.y
				})
			"equipment" :
				dict["equipment"].append({
					"type" : c.type,
					"boon" : c.boon,
					"x" : c.position.x,
					"y" : c.position.y
				})
			"environment" :
				dict["environment"].append({
					"type" : c.type,
					"height" : c.height,
					"x" : c.position.x,
					"y" : c.position.y
				})
			_:
				pass
	
	var json_string = JSON.stringify(dict, "\t")
	dict = null
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		print("failed to open file!")
		return false;
	file.store_string(json_string)
	file.close()
	
	return true

func load_to_file() -> bool: # load current level to JSON file
	
	if not FileAccess.file_exists(path):
		print("ERROR IN skill_tree, FILES NOT FOUND!")
		return false
	
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		print("Failed to open file!")
		return false
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(json_string)
	
	if error == OK:
		return json.data
	else:
		print("JSON parse error!")
		return false
