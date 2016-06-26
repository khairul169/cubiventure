extends Control

signal pressed();

var is_pressed = false;
var touch_id = -1;

func _ready():
	if !OS.has_touchscreen_ui_hint():
		hide();
		return;
	
	touch_id = -1;
	set_process_input(true);

func _input(ie):
	if !is_visible():
		return;
	
	if ie.type == InputEvent.SCREEN_TOUCH:
		if ie.pressed && touch_id == -1:
			if get_global_rect().has_point(ie.pos):
				emit_signal("pressed");
				is_pressed = true;
				touch_id = ie.index;
		elif !ie.pressed && ie.index == touch_id:
			is_pressed = false;
			touch_id = -1;
