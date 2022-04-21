extends Label


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	self.text = ""
	display_text()
	return 

func display_text():
	self.text = "Health: " + str(Globals.player_health)
	self.text += '\n' + "Score:" + str(Globals.score)
	self.text += '\n' + "Nitro:" + str(Globals.nitro_fuel)
	self.text += '\n' + "Power ups:" + str(Globals.power_ups_collected)
	# self.text += '\n' + "Gear:" + str(Globals.gear)
	self.text += '\n' + "Health Enemy1: " + str(Globals.enemy_health1)
	self.text += '\n' + "Health Enemy2: " + str(Globals.enemy_health2)
	self.text += '\n' + "Speed(KPH):" + str(Globals.kph)
	
func display_game_over_text():
	self.text = "Game Over!"
	self.text += '\n' + "You Died!"
	self.text += '\n' + "Press ESC to Play Again!"
	
func display_game_win_text():
	self.text = "Game Over!"
	self.text += '\n' + "You Win!"
	self.text += '\n' + "Press ESC to Play Again!"
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	
	if Globals.player_health <= 0:
		display_game_over_text()
		if (Input.is_action_pressed("ui_cancel")):
			Globals.kph = 0;

			Globals.player_health = 100;
			Globals.nitro_fuel = 50;
			Globals.score = 0;

			Globals.power_ups_collected = 0;
			Globals.gear = 0;

			Globals.player_pos = Vector3.ZERO;
			
			Globals.enemy_health1 = 100;
			Globals.enemy_health2 = 100;

			get_tree().reload_current_scene();
			
			
	elif (Globals.enemy_health1 <= 0 and Globals.enemy_health2 <= 0):
		
		display_game_win_text()
		if (Input.is_action_pressed("ui_cancel")):
			Globals.kph = 0;

			Globals.player_health = 100;
			Globals.nitro_fuel = 50;
			Globals.score = 0;

			Globals.power_ups_collected = 0;
			Globals.gear = 0;

			Globals.player_pos = Vector3.ZERO;
			
			Globals.enemy_health1 = 100;
			Globals.enemy_health2 = 100;

			get_tree().reload_current_scene()
	else:
		display_text()
		
