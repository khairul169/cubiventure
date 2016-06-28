extends Camera

var player = null;
var pitch = 20.0;
var yaw = 0.0;
var cpitch = pitch;
var cyaw = yaw;
var dist = 8.0;
var cdist = dist;
var active = false;
var sensitivity = 0.5;
var ray_res = {};
var excl = [];
var pos = Vector3();
var target = Vector3();

func _ready():
	player = get_node("../");
	
	set_process(true);
	set_process_input(true);
	set_fixed_process(true);

func set_active(t = true):
	if t:
		active = true;
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
	else:
		active = false;
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);

func _input(ie):
	if !active:
		return;
	
	if ie.type == InputEvent.MOUSE_MOTION:
		pitch = clamp(pitch+ie.relative_y*sensitivity, -80.0, 80.0);
		yaw = fmod(yaw-ie.relative_x*sensitivity, 360.0);

func _process(delta):
	cpitch = lerp(cpitch, pitch, 10*delta);
	cyaw += (abs(cyaw-yaw)>180)*sign(cyaw)*-360.0;
	cyaw = lerp(cyaw, yaw, 10*delta);
	
	if player.aiming:
		cdist = lerp(cdist, 4.0, 10*delta);
	else:
		cdist = lerp(cdist, dist, 10*delta);
	
	pos = player.get_global_transform().origin;
	pos.x += cdist*sin(deg2rad(cyaw))*cos(deg2rad(cpitch));
	pos.y += cdist*sin(deg2rad(cpitch));
	pos.z += cdist*cos(deg2rad(cyaw))*cos(deg2rad(cpitch));
	target = player.get_global_transform().origin+Vector3(0,1.5,0);
	
	if player.aiming:
		var m = Vector3(2.0*cos(deg2rad(cyaw)),0,2.0*-sin(deg2rad(cyaw)));
		pos += m;
		target += m;
	
	var from = pos;
	if !ray_res.empty():
		from = ray_res.position;
	
	look_at_from_pos(from, target, Vector3(0,1,0));

func _fixed_process(delta):
	ray_res = get_world().get_direct_space_state().intersect_ray(target, pos, excl);
