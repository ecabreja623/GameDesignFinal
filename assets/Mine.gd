extends Area

var hidden = false;

func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	rotate_y(deg2rad(30))

func _on_Mine_body_shape_entered(_body_rid, _body, _body_shape_index, _local_shape_index):
	if _body.is_in_group("player"):
		if Globals.mine_ready:
			return
			
		if not hidden:
			hidden = true
			monitoring = false
			visible = false
			$Timer.start()
		
		Globals.mine_ready = true;
	

func _on_Timer_timeout():
	monitoring = true
	visible = true
	hidden = false
	$Timer.start()
