extends Control

var name = "";
var val = 0.0;
var global_var = "";

func _ready():
	get_node("btnPlus").connect("pressed", self, "on_btnPlus_pressed");

func on_btnPlus_pressed():
	globals.game.skill_upgrade(self, global_var);