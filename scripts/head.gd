extends AnimatedSprite2D

var HeadSetting  = {
	"NONE" : Vector2(0.45, 0.45),
	"HELM" : Vector2(.6, .6),
	"HAT" : Vector2(.6, .6)
}

func _ready() -> void:
	change_head("NONE")

func change_head(head: String) -> void:
	play(head)
	scale = HeadSetting[head]
