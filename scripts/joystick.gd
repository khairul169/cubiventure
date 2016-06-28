extends Control

var active = false;
var joystick;
var touch_id;

var margin = Vector2(-32,-32);
var direction = Vector2(0, 0);

func reset():
	touch_id = -1
	active = false
	direction = Vector2(0, 0)
	joystick.set_pos(margin)

func is_inside(pos):
	var t = joystick.get_global_transform()
	t = t.inverse()
	var p = t.xform(pos)
	var r = joystick.get_item_rect()
	
	return r.has_point(p)

func move_joystick(pos):
	if get_tree().is_paused():
		return;
	
	var t = self.get_global_transform()
	t = t.inverse()
	var p = t.xform(pos)
	
	var r = get_node("bg").get_item_rect()
	var max_len = min(r.size.width/2, r.size.height/2)
	
	var len = clamp(p.length(), 0, max_len)
	
	direction = p.normalized()
	
	p = direction * len;
	p += margin;
	joystick.set_pos(p)

func _input(e):
	if !is_visible():
		return;
	
	if OS.has_touchscreen_ui_hint():
		if e.type == InputEvent.SCREEN_TOUCH:
			if e.pressed:
				if is_inside(e.pos):
					active = true;
					touch_id = e.index;
			elif e.index == touch_id:
				reset();
		
		elif e.type == InputEvent.SCREEN_DRAG:
			if active && e.index == touch_id:
				move_joystick(e.pos);
	else:
		if e.type == InputEvent.MOUSE_BUTTON:
			if e.pressed:
				if is_inside(e.pos):
					active = true;
			else:
				reset();
		
		elif e.type == InputEvent.MOUSE_MOTION && active:
			move_joystick(e.pos)

func _ready():
	#if !OS.has_touchscreen_ui_hint():
		#hide();
		#return;
	
	joystick = get_node("joy");
	set_process_input(true);
