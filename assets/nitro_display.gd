extends TextureProgress

var bar_blue = preload("res://assets/health_blue.png")

func _process(delta):
	
	update_nitro(Globals.nitro_fuel, 100)

func update_nitro(amount, full):
	if amount < full:
		show()
	texture_progress = bar_blue
	value = amount


