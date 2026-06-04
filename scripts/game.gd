extends Node2D

@export var player: CharacterBody2D
var scene = preload("res://scenes/respawn.tscn")
var path = "res://files/save_file.JSON"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#save()
	var err = load_savefile()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player.dead:
		var instance = scene.instantiate()
		instance.position = player.position + Vector2(-50, -50)
		add_child(instance)

func save() -> bool:
	var nodes = get_tree().get_nodes_in_group('Persist')
	var save_file = FileAccess.open(path, FileAccess.WRITE)
	for node in nodes:
		# Check the node is an instanced scene so it can be instanced again during load.
		if node.scene_file_path.is_empty():
			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue

		# Check the node has a save function.
		if !node.has_method("save"):
			print("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue

		# Call the node's save function.
		var node_data = node.call("save")

		# JSON provides a static method to serialized JSON string.
		var json_string = JSON.stringify(node_data)
		# Store the save dictionary as a new line in the save file.
		save_file.store_line(json_string)
	return true

func load_savefile() -> bool:
	if not FileAccess.file_exists(path):
		return false# Error! We don't have a save to load.
	
	var path = FileAccess.open(path, FileAccess.READ)
	while path.get_position() < path.get_length():
		var json_string = path.get_line()

		# Creates the helper class to interact with JSON.
		var json = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure.
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue

		# Get the data from the JSON object.
		var node_data = json.data

		# Firstly, we need to create the object and add it to the tree and set its position.
		var new_object = load(node_data["scene"]).instantiate()
		new_object.position = Vector2(node_data["x"], node_data["y"])

		# Now we set the remaining variables.
		for i in node_data.keys():
			if i == "scene" or i == "x" or i == "y":
				continue
			new_object.set(i, node_data[i])
		get_tree().current_scene.add_child(new_object)
	return true
