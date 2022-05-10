extends Label


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func display_game_over_text():
	self.text = "Game Over!"
	self.text += '\n' + "You Died!"
	self.text += '\n' + "You Survived for " + str(Globals.min_elapsed).pad_zeros(2) + ":" + str(Globals.sec_elapsed).pad_zeros(2).pad_decimals(2)
	self.text += '\n' + "Score:" + str(Globals.score)
	self.text += '\n' + "Press ESC to Play Again!"
	
func display_game_win_text():
	self.text = "Game Over!"
	self.text += '\n' + "You Win!"
	
	self.text += '\n' + "You eliminated all the enemies in " + str(Globals.min_elapsed).pad_zeros(2) + ":" + str(Globals.sec_elapsed).pad_zeros(2).pad_decimals(2)
	self.text += '\n' + "Score:" + str(Globals.score)
	self.text += '\n' + "Press ESC to Play Again!"

var score_calculated = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Globals.player_health <= 0:
		
		display_game_over_text()
		
		if (Input.is_action_pressed("ui_cancel")):
			Globals.kph = 0;

			Globals.player_health = 100;
			Globals.nitro_fuel = 100;
			Globals.score = 0;

			Globals.power_ups_collected = 0;
			#Globals.gear = 0;

			Globals.player_pos = Vector3.ZERO;
			
			Globals.sec_elapsed = 0
			Globals.min_elapsed = 0
			
			#get_tree().reload_current_scene();
			get_tree().change_scene("res://Menu.tscn")
			
			
	elif Globals.enemies_left < 1:
		if not score_calculated:
			print_debug("score before end:", Globals.score)
			Globals.score *= ((Globals.num_monsters + Globals.num_pantera) * (5 + Globals.ai_smartness) / ((Globals.min_elapsed * 60) + Globals.sec_elapsed)) + 1
			score_calculated = true
			
		display_game_win_text()
		
		if (Input.is_action_pressed("ui_cancel")):
			Globals.kph = 0;

			Globals.player_health = 100;
			Globals.nitro_fuel = 100;
			Globals.score = 0;

			Globals.power_ups_collected = 0;
			#Globals.gear = 0;

			Globals.player_pos = Vector3.ZERO;
			
#			Globals.enemy_health1 = 100;
#			Globals.enemy_health2 = 100;

			Globals.sec_elapsed = 0
			Globals.min_elapsed = 0

			#get_tree().reload_current_scene()
			get_tree().change_scene("res://Menu.tscn")
