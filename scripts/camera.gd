extends Camera

var yaw;
var dist;

func _ready():
	yaw = 0.0;
	dist = 8.0;
	
	set_fixed_process(true);

func _fixed_process(delta):
	if !has_node("../player"):
		return;
	
	var player = get_node("../player");
	var pos = get_global_transform().origin.linear_interpolate(player.get_global_transform().origin+Vector3(dist*sin(deg2rad(yaw)), 3, dist*cos(deg2rad(yaw))), 5*delta);
	var target = player.get_global_transform().origin;
	
	look_at_from_pos(pos, target, Vector3(0,1,0));
