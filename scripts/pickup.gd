extends Node2D

@export_category("Statistics")
@export var pickup: String
@export_category("Child Nodes")
@export var label: Label
@export var sprite_2d: Sprite2D 

var conbody;

var SpriteDictionary = {
	"TORCH": [Rect2(0, 0, 16, 16), 0],
	"FIREORB": [Rect2(16, 0, 16, 16), 1],
	"HAMMER": [Rect2(0, 16, 16, 16), 2],
	"SEW": [Rect2(16, 16, 16, 16), 3],
}

func _ready() -> void:
	if !pickup:
		pickup = "TORCH"
		
	sprite_2d.region_rect = SpriteDictionary[pickup][0]
	set_process(false)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interaction"):
		conbody.pickup_handler.apply_effect(SpriteDictionary[pickup][1])
		queue_free()

func _on_area_2d_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	set_process(true)
	conbody = body;
	label.visible = true

func _on_area_2d_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	set_process(false)
	conbody = false;
	label.visible = false

func save() -> Dictionary:
	return {
			"scene" : get_scene_file_path(),
			"pickup" : pickup,
			"x" : position.x,
			"y" : position.y
		}
