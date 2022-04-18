extends Sprite3D

func _ready():
	texture = $Viewport.get_texture()

onready var bar = $Viewport/HealthDisplay

func update(value, full):
	bar.update_bar(value, full)
