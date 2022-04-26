extends TextureProgress

var bar_red = preload("res://assets/health_red.png")
var bar_green = preload("res://assets/health_green.png")
var bar_yellow = preload("res://assets/health_yellow.png")

func _process(delta):
	
	update_nitro(Globals.nitro_fuel, 100)

func update_nitro(amount, full):
	if amount < full:
		show()
	texture_progress = bar_yellow
	if amount < 0.75 * full:
		texture_progress = bar_yellow
	if value < 0.45 * full:
		texture_progress = bar_yellow
	value = amount


