extends KinematicBody

# Member variables
var g = -19.6;
var vel = Vector3();

# Constants
const MOVE_SPEED = 5.0;
const MAX_SPEED = 8.0;
const ACCEL = 10;
const DEACCEL = 16;
const MAX_SLOPE_ANGLE = 30;
const JUMP_FORCE = 10;
const JUMP_MAX = 12;
const ATTACK_DELAY = 0.5;
const FALLATTACK_FORCE = 20.0;

var dir = Vector3();
var on_floor = false;
var can_doublejump = false;
var next_idle = 0.0;
var next_move = 0.0;
var next_attack = 0.0;
var spawn_pos = Vector3();

var tomato = "res://scenes/tomato.tscn";

func _ready():
	spawn_pos = get_translation();
	tomato = load(tomato);
	
	globals.gui.get_node("controller_up").connect("pressed", self, "on_ctrlup_pressed");
	
	set_process_input(true);
	set_fixed_process(true);

func _input(ie):
	if ie.type == InputEvent.KEY:
		if ie.scancode == KEY_SPACE && ie.pressed:
			jump();
		
		if ie.scancode == KEY_X && ie.pressed && !on_floor:
			vel.y = -FALLATTACK_FORCE;

func on_ctrlup_pressed():
	jump();

func jump():
	if on_floor:
		vel.y = JUMP_FORCE+(JUMP_MAX-JUMP_FORCE)*globals.skill_jump;
		can_doublejump = true;
	elif !on_floor && can_doublejump:
		vel.y = JUMP_FORCE+(JUMP_MAX-JUMP_FORCE)*globals.skill_jump;
		can_doublejump = false;

func _fixed_process(delta):
	dir = Vector3();
	
	if Input.is_key_pressed(KEY_LEFT):
		dir.x += -1;
	if Input.is_key_pressed(KEY_RIGHT):
		dir.x += 1;
	if Input.is_key_pressed(KEY_UP):
		dir.z += -1;
	if Input.is_key_pressed(KEY_DOWN):
		dir.z += 1;
	
	var joy_dir = globals.gui.get_node("controller_joystick").direction;
	if joy_dir.length() > 0:
		dir.x = joy_dir.x;
		dir.z = joy_dir.y;
	
	dir.y = 0;
	
	dir = dir.normalized()
	
	vel.y += g*delta
	
	var hvel = vel
	hvel.y = 0
	
	var move_speed = MOVE_SPEED+((MAX_SPEED-MOVE_SPEED)*globals.skill_run);
	var target = dir*move_speed;
	var accel
	if (dir.dot(hvel) > 0):
		accel = ACCEL
	else:
		accel = DEACCEL
	
	hvel = hvel.linear_interpolate(target, accel*delta)
	
	vel.x = hvel.x
	vel.z = hvel.z
	if globals.game.time < next_move:
		vel *= 0;
	
	var motion = move(vel*delta)
	
	on_floor = false
	var original_vel = vel
	var floor_velocity = Vector3()
	var attempts = 4
	
	while(is_colliding() and attempts):
		var n = get_collision_normal();
		var p = get_collision_pos();
		var collider = get_collider();
		
		if collider extends RigidBody:
			collider.apply_impulse(p-collider.get_global_transform().origin, -n*collider.get_mass());
		
		if vel.y <= -FALLATTACK_FORCE:
			get_node("sfx").play("jumpland");
			
			if collider extends preload("res://scripts/box.gd"):
				collider.destroy();
			if collider extends preload("res://scripts/zombie.gd"):
				collider.kill();
				globals.game.player_give_exp(40);
		
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
	
	attack();
	
	if globals.game.time > next_idle:
		next_idle = globals.game.time + 0.1;
		
		if dir.length() >= 0.5 && on_floor:
			set_animation("run", false, move_speed/float(MOVE_SPEED));
		elif vel.y > 0 && !on_floor:
			set_animation("jump");
		elif vel.y < 0 && !on_floor:
			set_animation("fall");
		else:
			set_animation("idle");
	
	if vel.y < -100.0:
		vel.y = 0;
		set_translation(spawn_pos);
	
	globals.player_pos = get_global_transform().origin;

func set_animation(ani, force = false, speed = 1.0):
	var ap = get_node("models/AnimationPlayer");
	if ap.get_current_animation() != ani || force:
		ap.play(ani);
		ap.set_speed(speed);

func attack():
	if globals.game.time < next_attack || (!Input.is_key_pressed(KEY_Z) && !globals.gui.get_node("controller_attack").is_pressed):
		return;
	
	next_attack = globals.game.time+ATTACK_DELAY;
	
	if (dir.x == 0 && dir.z == 0) || globals.player_tomato <= 0:
		return;
	
	globals.player_tomato -= 1;
	globals.game.player_give_exp(5);
	
	var inst = tomato.instance();
	inst.owner = self;
	inst.set_translation(get_translation()+dir+Vector3(0,1.5,0));
	inst.apply_impulse(Vector3(), dir*(25+5*globals.skill_throw));
	inst.set_angular_velocity(Vector3(1,1,1)*deg2rad(360));
	globals.env.add_child(inst, true);