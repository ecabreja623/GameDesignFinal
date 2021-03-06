extends Spatial



# First four values of the array copied from previous placements
var pantera_positions = [Vector3(-99.75, 0, -8.85), Vector3(-98.69, 0, 93.58), 
Vector3(1.20, 0, 130.53), Vector3(31.77, 0, -42.45), Vector3(3, 0, -6), Vector3(-14, 0, 11), 
Vector3(-41, 0, -15), Vector3(5, 0, -55), Vector3(-46, 0, 13), Vector3(28, 0, 27)]
var monster_positions = [Vector3(-99.40, 0, 49.85), Vector3(-52.50, 0, 151.60), Vector3(59.61, 0, -64.01), 
Vector3(26.98, 0, 79.82), Vector3(20, 0, 72), Vector3(-62, 0, 93), Vector3(-90, 0, 65),
Vector3(-52, 0, 124), Vector3(-20, 0, 173), Vector3(8, 0, 220)]

# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_enemies()

func spawn_enemies():
	var pantera = load("res://vehicles/pantera/pantera.tscn")
	var monster = load("res://vehicles/monster/monster.tscn")	
	var enemy_script = load("res://vehicles/VehicleBodyEnemy.gd")
	for i in range(Globals.num_pantera):
		var temp_instance = pantera.instance()
		temp_instance.set_script(enemy_script)
		temp_instance.add_to_group('enemy')
		temp_instance.add_to_group('enemy1')
		temp_instance.translation = pantera_positions[i]
		$Navigation/Enemies.add_child(temp_instance)
		
	
	for i in range(Globals.num_monsters):
		var temp_instance = monster.instance()
		temp_instance.set_script(enemy_script)
		temp_instance.add_to_group('enemy')
		temp_instance.add_to_group('enemy2')
		temp_instance.translation = monster_positions[i]
		$Navigation/Enemies.add_child(temp_instance)
	
	



