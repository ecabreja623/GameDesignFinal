extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var prop_loader := {}

# Called when the node enters the scene tree for the first time.
func _ready():
	load_vehicle("res://vehicles/gt/gt.tscn")
	

func load_vehicle(name):
	var vehicle = load(name).instance()
	add_child(vehicle)
	vehicle.global_transform = $VehicleSpawnPoint.global_transform
