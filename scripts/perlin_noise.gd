# Perlin.cpp
#
# Copyright Chris Little 2012
# Author: Chris Little

extends Node

var p = [];
var Gx = [];
var Gy = []
var Gz = []

func _init():
	p.resize(256);
	Gx.resize(256);
	Gy.resize(256);
	Gz.resize(256);
	
	set_seed(OS.get_unix_time());

func generate_rand():
	for i in range(256):
		p[i] = i;
		
		Gx[i] = randf() - 1.0;
		Gy[i] = randf() - 1.0;
		Gz[i] = randf() - 1.0;

	var j=0;
	var swp=0;
	for i in range(256):
		j = randi() & 255;
		
		swp = p[i];
		p[i] = p[j];
		p[j] = swp;

func set_seed(seeds):
	seed(seeds);
	generate_rand();

func noise(sample_x, sample_y, sample_z):
	# Unit cube vertex coordinates surrounding the sample povar
	var x0 = int(floor(sample_x));
	var x1 = x0 + 1;
	var y0 = int(floor(sample_y));
	var y1 = y0 + 1;
	var z0 = int(floor(sample_z));
	var z1 = z0 + 1;

	# Determine sample povar position within unit cube
	var px0 = sample_x - float(x0);
	var px1 = px0 - 1.0;
	var py0 = sample_y - float(y0);
	var py1 = py0 - 1.0;
	var pz0 = sample_z - float(z0);
	var pz1 = pz0 - 1.0;

	# Compute dot product between gradient and sample position vector
	var gIndex = p[(x0 + p[(y0 + p[z0 & 255]) & 255]) & 255];
	var d000 = Gx[gIndex]*px0 + Gy[gIndex]*py0 + Gz[gIndex]*pz0;
	gIndex = p[(x1 + p[(y0 + p[z0 & 255]) & 255]) & 255];
	var d001 = Gx[gIndex]*px1 + Gy[gIndex]*py0 + Gz[gIndex]*pz0;

	gIndex = p[(x0 + p[(y1 + p[z0 & 255]) & 255]) & 255];
	var d010 = Gx[gIndex]*px0 + Gy[gIndex]*py1 + Gz[gIndex]*pz0;
	gIndex = p[(x1 + p[(y1 + p[z0 & 255]) & 255]) & 255];
	var d011 = Gx[gIndex]*px1 + Gy[gIndex]*py1 + Gz[gIndex]*pz0;

	gIndex = p[(x0 + p[(y0 + p[z1 & 255]) & 255]) & 255];
	var d100 = Gx[gIndex]*px0 + Gy[gIndex]*py0 + Gz[gIndex]*pz1;
	gIndex = p[(x1 + p[(y0 + p[z1 & 255]) & 255]) & 255];
	var d101 = Gx[gIndex]*px1 + Gy[gIndex]*py0 + Gz[gIndex]*pz1;

	gIndex = p[(x0 + p[(y1 + p[z1 & 255]) & 255]) & 255];
	var d110 = Gx[gIndex]*px0 + Gy[gIndex]*py1 + Gz[gIndex]*pz1;
	gIndex = p[(x1 + p[(y1 + p[z1 & 255]) & 255]) & 255];
	var d111 = Gx[gIndex]*px1 + Gy[gIndex]*py1 + Gz[gIndex]*pz1;

	# varerpolate dot product values at sample povar using polynomial varerpolation 6x^5 - 15x^4 + 10x^3
	var wx = ((6*px0 - 15)*px0 + 10)*px0*px0*px0;
	var wy = ((6*py0 - 15)*py0 + 10)*py0*py0*py0;
	var wz = ((6*pz0 - 15)*pz0 + 10)*pz0*pz0*pz0;

	var xa = d000 + wx*(d001 - d000);
	var xb = d010 + wx*(d011 - d010);
	var xc = d100 + wx*(d101 - d100);
	var xd = d110 + wx*(d111 - d110);
	var ya = xa + wy*(xb - xa);
	var yb = xc + wy*(xd - xc);
	var value = ya + wz*(yb - ya);

	return value;
