extends Sprite3D

func _ready():
	texture = $Viewport.get_texture()

onready var bar = $Viewport/HealthBar2D

func update(value, full):
	bar.update_bar(value, full)
