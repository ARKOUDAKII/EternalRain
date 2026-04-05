extends RigidBody2D

#Global Variables
@export var spells = 5
var type = "Hat"
var body: Node2D

#Nodes
@onready var label: Label = $Label

#Flags
var pick_up = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pick_up") and pick_up:
		body.pick_up($".")
		queue_free()


func _on_detect_area_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		body = body
		pick_up = true
		label.visible = true
			


func _on_detect_area_body_exited(body: Node2D) -> void:
	if body == CharacterBody2D:
		pick_up = false
		label.visible = false
