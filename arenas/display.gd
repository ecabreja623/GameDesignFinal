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
	self.text += '\n' + "Gear:" + str(Globals.gear)
	self.text += '\n' + "Speed(KPH):" + str(Globals.kph)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	display_text()
