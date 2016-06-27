extends Camera

var pitch;
var yaw;
var dist;

func _ready():
	pitch = 20.0;
	yaw = 0.0;
	dist = 8.0;
	
	set_fixed_process(true);

func _fixed_process(delta):
	if !has_node("../player"):
		return;
	
	var player = get_node("../player");
	var p = Vector3();
	p.x = dist*sin(deg2rad(yaw))*cos(deg2rad(pitch));
	p.y = dist*sin(deg2rad(pitch));
	p.z = dist*cos(deg2rad(yaw))*cos(deg2rad(pitch));
	var pos = get_global_transform().origin.linear_interpolate(player.get_global_transform().origin+p, 5*delta);
	var target = player.get_global_transform().origin;
	
	look_at_from_pos(pos, target, Vector3(0,1,0));
