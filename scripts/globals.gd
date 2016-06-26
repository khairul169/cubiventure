extends Node

var game;
var gui;
var env;

const CONFIG_PATH = "user://config.dat";
var config_var = [];

var cfg_fpscap;
var cfg_shadow;
var cfg_grassintensity;
var cfg_grassshadow;
var cfg_chunksize;
var cfg_lowprocessmode;
var cfg_fxaa;
var cfg_glow;
var cfg_fog;
var cfg_showfps;
var cfg_timecyclefps;

const ENCRYPTED_SAVEGAME = false;
const SAVEGAME_PATH = "user://savegame.dat";
const SAVEGAME_PASSWORD = "hueheueh";
var savedata_var = [];

var world_seeds;
var world_time;
var player_health;
var player_pos;
var player_exp;
var player_lvl;
var player_tomato;
var skill_point;
var skill_run;
var skill_jump;
var skill_throw;
var skill_pocket;
var skill_health;
var skill_medic;

func _init():
	randomize();
	
	cfg_fpscap = 60.0;
	cfg_shadow = true;
	cfg_grassintensity = 1.0;
	cfg_grassshadow = true;
	cfg_chunksize = 4;
	cfg_lowprocessmode = false;
	cfg_fxaa = true;
	cfg_glow = true;
	cfg_fog = true;
	cfg_showfps = false;
	cfg_timecyclefps = 10.0;
	
	config_var.push_back("cfg_fpscap");
	config_var.push_back("cfg_shadow");
	config_var.push_back("cfg_grassintensity");
	config_var.push_back("cfg_grassshadow");
	config_var.push_back("cfg_chunksize");
	config_var.push_back("cfg_lowprocessmode");
	config_var.push_back("cfg_fxaa");
	config_var.push_back("cfg_glow");
	config_var.push_back("cfg_fog");
	config_var.push_back("cfg_showfps");
	config_var.push_back("cfg_timecyclefps");
	
	world_seeds = int(OS.get_unix_time());
	world_time = 8.0;
	player_health = 100.0;
	player_tomato = 1;
	player_pos = Vector3();
	player_lvl = 1;
	player_exp = 0;
	skill_point = 0;
	skill_run = 0.0;
	skill_jump = 0.0;
	skill_throw = 0.0;
	skill_pocket = 0.0;
	skill_health = 0.0;
	skill_medic = 0.0;
	
	savedata_var.push_back("world_time");
	savedata_var.push_back("world_seeds");
	savedata_var.push_back("player_health");
	savedata_var.push_back("player_pos");
	savedata_var.push_back("player_tomato");
	savedata_var.push_back("player_lvl");
	savedata_var.push_back("player_exp");
	savedata_var.push_back("skill_point");
	savedata_var.push_back("skill_run");
	savedata_var.push_back("skill_jump");
	savedata_var.push_back("skill_throw");
	savedata_var.push_back("skill_pocket");
	savedata_var.push_back("skill_health");
	savedata_var.push_back("skill_medic");

func _ready():
	get_tree().set_auto_accept_quit(false);

func quit_game():
	save_config();
	save_game();
	get_tree().quit();

func serialize_data(d, variable):
	d[variable] = var2str(get(variable));

func parse_data(d, variable):
	if d.has(variable):
		set(variable, str2var(d[variable]));

func save_config():
	var data = {};
	for i in config_var:
		serialize_data(data, i);
	data = data.to_json();
	
	var f = File.new();
	f.open(CONFIG_PATH, f.WRITE);
	f.store_string(data);
	f.close();

func load_config():
	var f = File.new();
	if !f.file_exists(CONFIG_PATH):
		print("File isn't exists: ",CONFIG_PATH);
		return;
	f.open(CONFIG_PATH, f.READ);
	var data = {};
	data.parse_json(f.get_as_text());
	f.close();
	
	for i in config_var:
		parse_data(data, i);

func save_game():
	var data = {};
	for i in savedata_var:
		serialize_data(data, i);
	data = data.to_json();
	
	var f = File.new();
	if ENCRYPTED_SAVEGAME:
		f.open_encrypted_with_pass(SAVEGAME_PATH, f.WRITE, str(SAVEGAME_PASSWORD).md5_text());
	else:
		f.open(SAVEGAME_PATH, f.WRITE);
	f.store_string(data);
	f.close();

func load_game():
	var f = File.new();
	if !f.file_exists(SAVEGAME_PATH):
		print("File isn't exists: ",SAVEGAME_PATH);
		return;
	if ENCRYPTED_SAVEGAME:
		f.open_encrypted_with_pass(SAVEGAME_PATH, f.READ, str(SAVEGAME_PASSWORD).md5_text());
	else:
		f.open(SAVEGAME_PATH, f.READ);
	var data = {};
	data.parse_json(f.get_as_text());
	f.close();
	
	for i in savedata_var:
		parse_data(data, i);
