extends Spatial

var world_seed;
var noise = preload("res://scripts/perlin_noise.gd");

const CHUNK_DISTANCE = 20.0;
var player_pos = Vector2();
var chunks = [];

var obj_platform = "res://models/platform/grass_platform.scn";
var obj_tree = ["res://models/props/tree/tree.scn","res://models/props/tree/tree1.scn","res://models/props/tree/pine_tree.scn"];
var obj_stone = ["res://models/props/stone/stone.scn","res://models/props/stone/stone1.scn","res://models/props/stone/stone2.scn"];
var obj_base = "res://models/props/base/base.scn";
var scn_zombie = "res://scenes/zombie.tscn";
var grass_mesh = "res://models/props/grass/grass.msh";

func _ready():
	obj_platform = load(obj_platform);
	for i in range(obj_tree.size()):
		obj_tree[i] = load(obj_tree[i]);
	for i in range(obj_stone.size()):
		obj_stone[i] = load(obj_stone[i]);
	obj_base = load(obj_base);
	scn_zombie = load(scn_zombie);
	grass_mesh = load(grass_mesh);

func generate_world(seeds):
	world_seed = seeds;
	noise = noise.new();
	noise.set_seed(world_seed);
	
	chunks = get_chunkneighboor(pos2chunks(globals.player_pos));
	
	for i in chunks:
		generate_chunk(i);
	
	set_fixed_process(true);

func pos2chunks(pos):
	return Vector2(stepify(pos.x, CHUNK_DISTANCE)/CHUNK_DISTANCE, stepify(pos.z, CHUNK_DISTANCE)/CHUNK_DISTANCE);

func get_chunkneighboor(center):
	var chunks = [];
	for x in range(center.x-((get_chunk_size()-1)/2), center.x+((get_chunk_size()-1)/2)+1):
		for y in range(center.y-((get_chunk_size()-1)/2), center.y+((get_chunk_size()-1)/2)+1):
			chunks.push_back(Vector2(x, y));
	return chunks;

func get_chunk_size():
	return int(globals.cfg_chunksize)*2+1;

func generate_chunk(chunk_pos):
	var chunk = Spatial.new();
	var pos = Vector3(chunk_pos.x*CHUNK_DISTANCE, -20, chunk_pos.y*CHUNK_DISTANCE);
	chunk.set_name(str("chunk_",int(chunk_pos.x),"_",int(chunk_pos.y)));
	var xforsim = pos.x/100.0+40;
	var yforsim = pos.z/100.0+2000;
	var worldHeight = ((noise.noise(xforsim,yforsim,0)+1)*0.5) * 16;
	pos.y += ceil(worldHeight)*2;
	chunk.set_translation(pos);
	
	var platform = obj_platform.instance();
	chunk.add_child(platform, true);
	seed(world_seed+(chunk_pos.x*2)+(chunk_pos.y*4));
	rand_range(10, 100);
	
	if rand_range(10, 100) > 85:
		add_object(chunk, obj_base, Vector3(-4, 0, -4));
	elif rand_range(10, 100) > 80:
		add_object(chunk, scn_zombie);
	
	for i in range(6):
		if rand_range(10, 100) > 50:
			add_object(chunk, obj_tree[rand_range(0, obj_tree.size())], \
			Vector3(rand_range(-8.0,8.0), 0, rand_range(-8.0,8.0)), \
			Vector3(0, rand_range(0.0, 360.0), 0), \
			Vector3(1,1,1)*rand_range(1.0, 2.0));
		
		if rand_range(10, 100) > 20:
			add_object(chunk, obj_stone[rand_range(0, obj_stone.size())], \
			Vector3(rand_range(-8.0,8.0), 0, rand_range(-8.0,8.0)), \
			Vector3(0, rand_range(0.0, 360.0), 0), \
			Vector3(1,1,1)*rand_range(0.8, 1.5));
	
	var inst = MultiMeshInstance.new();
	inst.set_name("grass");
	var multimesh = MultiMesh.new();
	multimesh.set_mesh(grass_mesh);
	multimesh.set_instance_count(rand_range(64*globals.cfg_grassintensity,128*globals.cfg_grassintensity));
	
	for i in range(multimesh.get_instance_count()):
		var trans = Transform();
		trans = trans.scaled(Vector3(1,1,1)*rand_range(0.8, 1.5));
		trans = trans.rotated(Vector3(0,1,0), deg2rad(rand_range(0.0, 360.0)));
		trans.origin = Vector3(rand_range(-8.0,8.0), 0, rand_range(-8.0,8.0));
		multimesh.set_instance_transform(i, trans);
	
	multimesh.generate_aabb();
	inst.set_multimesh(multimesh);
	if globals.cfg_grassshadow:
		inst.set_flag(GeometryInstance.FLAG_CAST_SHADOW, 2);
	else:
		inst.set_flag(GeometryInstance.FLAG_CAST_SHADOW, 0);
	chunk.add_child(inst, true);
	
	add_child(chunk, false);

var thread = Thread.new();

func _fixed_process(delta):
	chunks_update();

func chunks_update():
	var pos = get_viewport().get_camera().get_global_transform().origin;
	if has_node("../player"):
		pos = get_node("../player").get_global_transform().origin;
	var cur_pos = Vector2(stepify(pos.x, CHUNK_DISTANCE)/CHUNK_DISTANCE, stepify(pos.z, CHUNK_DISTANCE)/CHUNK_DISTANCE);
	
	if cur_pos.x != player_pos.x || cur_pos.y != player_pos.y:
		chunk_generate(pos);
	
	player_pos = cur_pos;

func chunk_generate(pos):
	var old_chunks = chunks;
	var new_chunks = get_chunkneighboor(pos2chunks(pos));
	
	for i in new_chunks:
		if chunks.find(i) <= -1:
			generate_chunk(i);
		old_chunks.erase(i);
	
	for i in old_chunks:
		var node = "chunk_"+str(i.x)+"_"+str(i.y);
		if has_node(node):
			node = get_node(node);
			remove_child(node);
			node.free();
	
	chunks = new_chunks;

func add_object(parent, scn, pos = Vector3(), rot = Vector3(), scl = Vector3(1,1,1), etc = null):
	var inst = scn.instance();
	if inst == null:
		return null;
	
	inst.set_translation(pos);
	inst.set_rotation_deg(rot);
	inst.set_scale(scl);
	parent.add_child(inst, true);
	return inst;
