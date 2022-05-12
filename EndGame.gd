extends Control

func _ready():
	if Globals.game_over:
		if Globals.game_result == "win":
			$ColorRect.color = Color(0.48,0.17,0.79)
			$Result.text = "WINNER"
			$Data.text = "You Eliminated All the Enemies In: " + str(Globals.min_elapsed).pad_zeros(2) + ":" + str(Globals.sec_elapsed).pad_zeros(2).pad_decimals(2) + "\n" \
		+ "Score: " + str(int(Globals.score)) + "\n" \
		+ "Press ESC to play again!"
		else:
			$ColorRect.color = Color(0.41, 0.04, 0)
			$Result.text = "GAME OVER"
			$Data.text = "You Died!\nYou Survived for: " + str(Globals.min_elapsed).pad_zeros(2) + ":" + str(Globals.sec_elapsed).pad_zeros(2).pad_decimals(2) + "\n" \
		+ "Score: " + str(int(Globals.score)) + "\n" \
		+ "Press ESC to play again!"

func _process(delta):
	if (Input.is_action_pressed("ui_cancel")):
		
		Globals.kph = 0;

		Globals.player_health = 100;
		Globals.nitro_fuel = 100;
		Globals.score = 0;

		Globals.player_pos = Vector3.ZERO;

		Globals.sec_elapsed = 0
		Globals.min_elapsed = 0
		
		Globals.player_dead = false
		
		Globals.game_over = false
		Globals.game_result = null
		
		get_tree().change_scene("res://Menu.tscn")
