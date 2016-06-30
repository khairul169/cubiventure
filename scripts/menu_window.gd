extends Patch9Frame

func _ready():
	get_node("btnReturn").connect("pressed", self, "on_btnReturn_pressed");
	get_node("btnSettings").connect("pressed", self, "on_btnSettings_pressed");
	get_node("btnSkill").connect("pressed", self, "on_btnSkill_pressed");
	get_node("btnQuit").connect("pressed", self, "on_btnQuit_pressed");

func on_btnReturn_pressed():
	globals.game.toggle_menu(false);

func on_btnSettings_pressed():
	globals.game.toggle_menu(false);

func on_btnSkill_pressed():
	globals.game.toggle_menu(false);
	globals.game.toggle_skillmenu(true);

func on_btnQuit_pressed():
	globals.quit_game();
	globals.game.toggle_menu(false);