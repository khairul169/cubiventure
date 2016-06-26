extends Spatial

const SPEED = 5.0;
const SUN_ANGLE = 45.0;

const lightningMin = 0.3;
const lightningMax = 0.8;

var delay;
var env;
var dirlight;

func _ready():
	delay = 0.0;
	env = get_node("WorldEnvironment").get_environment();
	dirlight = get_node("DirectionalLight");
	
	env.set_enable_fx(Environment.FX_FXAA, globals.cfg_fxaa);
	env.set_enable_fx(Environment.FX_GLOW, globals.cfg_glow);
	env.set_enable_fx(Environment.FX_FOG, globals.cfg_fog);
	dirlight.set_project_shadows(globals.cfg_shadow);
	set_process(true);

func calculate_lightning(hour, minute):
	var ctime = (hour + (minute / 60.0)) / 24.0;
	var light = lightningMax * sin(PI*ctime);
	return clamp(light, lightningMin, lightningMax);

func _process(delta):
	globals.world_time += 1/60.0*SPEED*delta;
	if globals.world_time >= 24.0:
		globals.world_time -= 24.0;
	
	delay -= delta;
	if delay > 0.0:
		return;
	delay = 1.0/globals.cfg_timecyclefps;
	
	var sunmoon_angle = deg2rad(360*(globals.world_time/24.0));
	get_node("pivot").set_rotation(Vector3(0, deg2rad(SUN_ANGLE), sunmoon_angle));
	
	var light = calculate_lightning(floor(globals.world_time), (globals.world_time-floor(globals.world_time))*60);
	dirlight.set_parameter(Light.PARAM_ENERGY, light);
	var target_light = get_node("pivot/sun").get_global_transform().origin;
	if globals.world_time < 5.5 || globals.world_time >= 18.0:
		target_light = get_node("pivot/moon").get_global_transform().origin;
	dirlight.look_at_from_pos(target_light, get_global_transform().origin, Vector3(0,1,0));
	
	var light_color = Color(1,1,1);
	if globals.world_time >= 17.5 && globals.world_time < 18:
		var d = (globals.world_time-17.5)/0.5;
		light_color = Color(1-((1-17/255.0)*d), 1-((1-27/255.0)*d), 1-((1-65/255.0)*d));
		light = lightningMin+((calculate_lightning(18.0, 0.0)-lightningMin)*(1.0-d));
	elif globals.world_time >= 5.5 && globals.world_time < 6.0:
		var d = (globals.world_time-5.5)/0.5;
		light_color = Color((17/255.0)+((1-17/255.0)*d), (27/255.0)+((1-27/255.0)*d), (65/255.0)+((1-65/255.0)*d));
		light = lightningMin+((calculate_lightning(6.0, 0.0)-lightningMin)*d);
	elif globals.world_time >= 18 || globals.world_time < 5.5:
		light = lightningMin;
		light_color = Color8(17, 27, 65);
	
	dirlight.set_color(Light.COLOR_DIFFUSE, light_color);
	
	var bg = Color(169/255.0*(light-0.1), 189/255.0*(light-0.1), 242/255.0*(light-0.1));
	var col = Color(light,light,light);
	env.set_background_param(Environment.BG_PARAM_COLOR, bg);
	env.fx_set_param(Environment.FX_PARAM_AMBIENT_LIGHT_COLOR, col);
	env.fx_set_param(Environment.FX_PARAM_AMBIENT_LIGHT_ENERGY, 0.2+(0.4*light));