extends RigidBody2D

@export_category("Statistics")
@export var ImportedEquipment: String;
@export var ImportedBoon: float;
@export_category("Child Nodes")
@export var sprite_2d: Sprite2D
@export var label: Label

var SpriteDictionary = {
	"NONE": Rect2(0, 0, 0, 0),
	"HELM": Rect2(0, 0, 39, 32),
	"HAT": Rect2(40, 0, 32, 32)
}

var Data: Dictionary;
var conbody;

func _ready() -> void:
	set_process(false)
	Data = {
		"Type": ImportedEquipment,
		"Boon": ImportedBoon
	}
	if !ImportedEquipment:
		Data = {
			"Type": "NONE",
			"Boon": 0.0
		}
	sprite_2d.region_rect = SpriteDictionary[Data["Type"]]
	
func _process(delta: float) -> void:
	if conbody and Input.is_action_just_pressed("interaction"):
		conbody.equipment_handler.equip_d(Data)
		queue_free() 

func _on_area_2d_body_shape_entered(body_rid: RID, body: CharacterBody2D, body_shape_index: int, local_shape_index: int) -> void:
	label.visible = true
	conbody = body
	set_process(true)


func _on_area_2d_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	label.visible = false
	conbody = null
	set_process(false)


func save() -> Dictionary:
	return {
		"scene" : get_scene_file_path(),
		"ImportedEquipment" : ImportedEquipment,
		"ImportedBoon" : ImportedBoon,
		"x" : position.x,
		"y" : position.y
	}
