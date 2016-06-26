extends KinematicBody

# Member variables
var g = -19.6;
var vel = Vector3();
var dir = Vector3();

# Constants
const MAX_SLOPE_ANGLE = 30;
const ATTACK_DELAY = 1.0;

var on_floor = false;
var next_idle = 0.0;
var next_attack = 0.0;

var tomato = "res://scenes/tomato.tscn";

func _ready():
	tomato = load(tomato);
	
	set_fixed_process(true);

func _fixed_process(delta):
	vel.y += g*delta
	
	var motion = move(vel*delta)
	
	on_floor = false
	var original_vel = vel
	var floor_velocity = Vector3()
	var attempts = 4
	
	while(is_colliding() and attempts):
		var n = get_collision_normal();
		var p = get_collision_pos();
		var collider = get_collider();
		
		if (rad2deg(acos(n.dot(Vector3(0, 1, 0)))) < MAX_SLOPE_ANGLE):
				# If angle to the "up" vectors is < angle tolerance,
				# char is on floor
				floor_velocity = get_collider_velocity()
				on_floor = true
		
		motion = n.slide(motion)
		vel = n.slide(vel)
		if (original_vel.dot(vel) > 0):
			# Do not allow to slide towads the opposite direction we were coming from
			motion=move(motion)
			if (motion.length() < 0.001):
				break
		attempts -= 1
	
	if (on_floor and floor_velocity != Vector3()):
		move(floor_velocity*delta)
	
	var trans = get_transform();
	trans.basis = Matrix3(Quat(trans.basis).slerp(Quat(Vector3(0,1,0), -atan2(dir.x, dir.z)), 10*delta));
	set_transform(trans);
	
	if globals.game.time > next_idle:
		next_idle = globals.game.time + 0.5;
		set_animation("idle");
		
		if globals.env.has_node("player"):
			var player = globals.env.get_node("player");
			var dist = globals.env.get_node("player").get_global_transform().origin-get_global_transform().origin;
			var eyesight = 10.0;
			if globals.world_time >= 18 || globals.world_time < 5.5:
				eyesight = 15.0;
			
			if dist.length() < eyesight:
				dir.x = dist.x;
				dir.z = dist.z;
				dir = dir.normalized();
				attack();

func set_animation(ani, force = false, speed = 1.0):
	var ap = get_node("models/AnimationPlayer");
	if ap.get_current_animation() != ani || force:
		ap.play(ani);
		ap.set_speed(speed);

func attack():
	if globals.game.time < next_attack:
		return;
	
	next_idle = globals.game.time+ATTACK_DELAY;
	next_attack = next_idle;
	
	set_animation("shoot", true);
	
	var inst = tomato.instance();
	inst.owner = self;
	inst.set_translation(get_translation()+dir+Vector3(0,1.5,0));
	inst.apply_impulse(Vector3(), dir*20);
	inst.set_angular_velocity(Vector3(1,1,1)*deg2rad(360));
	get_node("../").add_child(inst, true);