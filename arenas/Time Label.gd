extends Label


func _ready():
	return 

func display_text():
	self.text = "Time Elapsed: " + str(Globals.min_elapsed).pad_zeros(2) + ":" + str(Globals.sec_elapsed).pad_zeros(2).pad_decimals(2)
	return
	
func _process(delta):
	if Globals.player_health > 0 and Globals.enemies_left > 0:
		Globals.sec_elapsed += delta;
		if Globals.sec_elapsed >= 60:
			Globals.sec_elapsed = 0
			Globals.min_elapsed += 1
		display_text()
	else:
		self.text = ""
