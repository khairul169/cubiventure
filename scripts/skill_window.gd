extends Patch9Frame

var touch_idx = -1;

func _ready():
	set_process(true);
	set_process_input(true);

func _process(delta):
	if !is_visible():
		return;
	
	get_node("sp").set_text("SP: "+str(int(globals.skill_point)));

func _input(ie):
	if !is_visible():
		return;
	
	if ie.type == InputEvent.SCREEN_TOUCH:
		if ie.pressed && get_node("container").get_global_rect().has_point(ie.pos):
			touch_idx = ie.index;
		elif !ie.pressed && ie.index == touch_idx:
			touch_idx = -1;
	
	if ie.type == InputEvent.SCREEN_DRAG && ie.index == touch_idx:
		get_node("container").set_v_scroll(get_node("container").get_v_scroll()-ie.relative_y);