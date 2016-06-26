extends Control

var touch_id;
var pressed;

func _ready():
	if !OS.has_touchscreen_ui_hint():
		hide();
		return;
	
	touch_id = -1;
	pressed = false;
	set_process_input(true);

func _input(ie):
	if ie.type == InputEvent.SCREEN_TOUCH:
		if ie.pressed && touch_id == -1:
			touch_id = ie.index;
			
			if get_global_rect().has_point(ie.pos):
				pressed = true;
			else:
				pressed = false;
		elif !ie.pressed && ie.index == touch_id:
			touch_id = -1;
			pressed = false;
	
	if ie.type == InputEvent.SCREEN_DRAG:
		if ie.index == touch_id:
			if get_global_rect().has_point(ie.pos):
				pressed = true;
			else:
				pressed = false;