extends TextureFrame

func _ready():
	pass

func popup_notification(txt):
	get_node("txt").set_text(txt);
	get_node("AnimationPlayer").play("fade");
