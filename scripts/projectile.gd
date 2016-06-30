extends Node

var gravity = -9.8;
var velocity = Vector2();
var startpoint = Vector2();

func getX(t):
	return velocity.x * t + startpoint.x;

func getY(t):
	return 0.5 * gravity * t * t + velocity.y * t + startpoint.y;