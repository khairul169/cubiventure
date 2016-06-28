extends Node

const SKILL_COST = 5;

var time = 0.0;
var spawn_point = Vector3();

var list_skill_scn = "res://scenes/skill_list.tscn";
var skill_run;
var skill_jump;
var skill_throw;
var skill_pocket;
var skill_health;
var skill_medic;

var next_tomato_reload = 0.0;

func _ready():
	globals.game = self;
	globals.gui = get_node("gui");
	globals.env = get_node("env");
	
	globals.load_config();
	globals.load_game();
	
	OS.set_target_fps(globals.cfg_fpscap);
	OS.set_low_processor_usage_mode(globals.cfg_lowprocessmode);
	
	next_tomato_reload = 8.0;
	
	init_gui();
	construct_level();
	spawn_player();
	init_skills();
	
	set_process(true);
	set_process_input(true);

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		key_escape();

func _input(ie):
	if ie.type == InputEvent.KEY && ie.pressed:
		if ie.scancode == KEY_ESCAPE:
			key_escape();

func key_escape():
	if get_node("gui/skill_window").is_visible():
		toggle_skillmenu(false);
	else:
		toggle_menu();
	
	var f = get_node("gui/fx_blur").get_focus_owner();
	if f != null:
		f.release_focus();

func init_gui():
	get_node("gui/fx_blur").hide();
	get_node("gui/fx_blood_splat").hide();
	get_node("gui/msgbox").hide();
	get_node("gui/skill_window").hide();
	get_node("gui/menu_window").hide();
	get_node("gui/notification_hud").hide();
	
	if !globals.cfg_showfps:
		get_node("gui/fps_counter").hide();
		get_node("gui/fps_counter").set_process(false);

func on_pause_btn_pressed():
	key_escape();

func toggle_menu(set = !get_node("gui/menu_window").is_visible()):
	if set:
		get_node("gui/fx_blur").show();
		get_node("gui/menu_window").show();
		globals.player.cam.set_active(false);
	else:
		get_node("gui/fx_blur").hide();
		get_node("gui/menu_window").hide()
		globals.player.cam.set_active(true);

func toggle_skillmenu(set = !get_node("gui/skill_window").is_visible()):
	if set:
		get_node("gui/fx_blur").show();
		get_node("gui/skill_window").show();
		globals.player.cam.set_active(false);
	else:
		get_node("gui/fx_blur").hide();
		get_node("gui/skill_window").hide()
		globals.player.cam.set_active(true);

func _process(delta):
	if get_tree().is_paused():
		return;
	time += delta;
	
	globals.player_health = clamp(globals.player_health+((1+9*globals.skill_medic)*delta), 0.0, 100+100*globals.skill_health);
	get_node("gui/health_hud/health_bar").set_value(globals.player_health/float(100+(100*globals.skill_health))*100.0);
	
	if time >= next_tomato_reload:
		globals.player_tomato = int(clamp(globals.player_tomato+1, 0, 8+(3*globals.skill_pocket)));
		next_tomato_reload = time+8.0-2*globals.skill_pocket;
	
	if globals.player_tomato > 0:
		get_node("gui/health_hud/tomato").show();
		get_node("gui/health_hud/tomato").set_size(Vector2(15*int(globals.player_tomato),14));
	else:
		get_node("gui/health_hud/tomato").hide();

func change_level(to):
	globals.world_level = to;
	globals.save_game();
	get_tree().reload_current_scene();

func restart_level():
	get_tree().reload_current_scene();

func construct_level():
	get_node("env").add_child(load("res://scenes/scenery.tscn").instance());
	get_node("env/levels").generate_world(globals.world_seeds);

func spawn_player():
	var inst = load("res://scenes/player.tscn").instance();
	inst.set_translation(globals.player_pos+Vector3(0,1,0));
	get_node("env").add_child(inst, true);
	globals.player = inst;

func init_skills():
	list_skill_scn = load(list_skill_scn);
	var c = get_node("gui/skill_window/container/list");
	
	skill_run = add_skill(c, "Run", "skill_run");
	skill_jump = add_skill(c, "Jump", "skill_jump");
	skill_throw = add_skill(c, "Throw", "skill_throw");
	skill_pocket = add_skill(c, "Pocket", "skill_pocket");
	skill_health = add_skill(c, "Health", "skill_health");
	skill_medic = add_skill(c, "Medic", "skill_medic");

func add_skill(container, name, global_var):
	var inst = list_skill_scn.instance();
	inst.global_var =  global_var;
	container.add_child(inst);
	set_skill_name(inst, name);
	set_skill_val(inst, globals.get(global_var));
	return inst;

func set_skill_name(inst, name):
	inst.name = name;
	inst.get_node("lbl").set_text(str(name, " (", int(inst.val*10), "/10)"));

func set_skill_val(inst, value):
	inst.val = value;
	inst.get_node("lbl").set_text(str(inst.name, " (", int(value*10), "/10)"));
	inst.get_node("progress").set_value(round(float(value)*100));

func skill_upgrade(inst, skill):
	if !skill_can_upgrade(skill):
		return;
	
	var val = globals.get(skill)+0.1;
	globals.set(skill, val);
	set_skill_val(inst, val);
	globals.skill_point -= SKILL_COST;

func skill_can_upgrade(skill):
	if globals.skill_point < SKILL_COST:
		return false;
	var val = globals.get(skill);
	if val >= 1.0:
		return false;
	
	return true;

func popup_notification(txt):
	get_node("gui/notification_hud").popup_notification(txt);

func player_give_exp(exps):
	globals.player_exp += exps;
	
	if globals.player_exp >= (100*globals.player_lvl):
		globals.player_exp = 0;
		globals.player_lvl += 1;
		globals.skill_point += 5;
		
		popup_notification(str("Level up to ",globals.player_lvl,"! SP +5"));

func player_apply_damage(dmg):
	globals.player_health = clamp(globals.player_health-dmg, 0.0, float(100+(100*globals.skill_health)));
	globals.gui.get_node("fx_blood_splat/AnimationPlayer").play("splat");
