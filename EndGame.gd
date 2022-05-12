extends Control



func _ready():
	if Globals.game_over:
		if Globals.game_result == "win":
			$ColorRect.color = Color(131,52,226)
			$Result.text = "WINNER"
			$Data.text = "Time: " + str(Globals.min_elapsed).pad_zeros(2) + ":" + str(Globals.sec_elapsed).pad_zeros(2) + "\n" \
		+ "Score: " + str(int(Globals.score)) + "\n" \
		+ "Press ESC to play again"
		else:
			$ColorRect.color = Color(103,10,0)
			$Result.text = "GAME OVER"
			$Data.text = "Time: " + str(Globals.min_elapsed).pad_zeros(2) + ":" + str(Globals.sec_elapsed).pad_zeros(2) + "\n" \
		+ "Score: " + str(int(Globals.score)) + "\n" \
		+ "Press ESC to play again"
			
