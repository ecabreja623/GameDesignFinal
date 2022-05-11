extends Sprite3D

var hidden = false;

func _ready():
	pass # Replace with function body.

func _on_Area_body_entered(body):
	if body.is_in_group('player'):
		if Globals.nitro_fuel >= 100:
			return
			
		if not hidden:
			hidden = true
			$Area.monitoring = false
			visible = false
			$Timer.start()
		
		Globals.nitro_fuel += 20
		if Globals.nitro_fuel > 100 :
			Globals.nitro_fuel = 100
	

func _on_Timer_timeout():
	$Area.monitoring = true
	visible = true
	hidden = false
