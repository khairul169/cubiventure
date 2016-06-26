extends Area

func _ready():
	connect("body_enter", self, "on_body_enter");
	connect("body_exit", self, "on_body_exit");

func on_body_enter(body):
	if body != null && body.has_method("on_obj_enter"):
		body.call("on_obj_enter", self);

func on_body_exit(body):
	if body != null && body.has_method("on_obj_exit"):
		body.call("on_obj_exit", self);