extends Area

var hidden = false;

func _ready():
	pass


func _physics_process(_delta):
	rotate_y(deg2rad(30))
	

func _on_Timer_timeout():
	monitoring = true
	visible = true
	hidden = false


func _on_Shield_body_shape_entered(_body_rid, _body, _body_shape_index, _local_shape_index):
	if _body.is_in_group("player"):
		if Globals.shield_active:
			return
		
		if not hidden:
			hidden = true
			monitoring = false
			visible = false
			$Timer.start()
			
		Globals.power_ups_collected += 1
		
		Globals.shield_active = true;
