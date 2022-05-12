extends Label

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
	
	#self.text += '\n' + "You eliminated all the enemies in " + str(Globals.min_elapsed).pad_zeros(2) + ":" + str(Globals.sec_elapsed).pad_zeros(2).pad_decimals(2)
	#self.text += '\n' + "Score:" + str(Globals.score)
	self.text += '\n' + "Click Anywhere to Continue!"

var score_calculated = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Globals.player_dead:
		
		Globals.game_over = true
		Globals.game_result = "loss"
		#display_game_over_text()
		
		#yield(get_tree().create_timer(3),"timeout")
		get_tree().change_scene("res://EndGame.tscn")
			
			
	elif Globals.enemies_left < 1:
		if not score_calculated:
			print_debug("score before end:", Globals.score)
			Globals.score *= ((Globals.num_monsters + Globals.num_pantera) * (5 + Globals.ai_smartness) / ((Globals.min_elapsed * 60) + Globals.sec_elapsed)) + 1
			score_calculated = true
		
		Globals.game_over = true
		Globals.game_result = "win"
		
		display_game_win_text()
		
		if (Input.is_action_pressed("click")):

			get_tree().change_scene("res://EndGame.tscn")
