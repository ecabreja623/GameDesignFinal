extends Spatial

var countdown = 3;
var exploded = false;

func _ready():
	# start ticking / counting down
	pass

func _physics_process(delta):
	
	countdown -= delta;
	
	if (countdown <= 0):
		
		if not exploded:
			exploded = true;
			_explode();
			print_debug("BOOM")
			
		# explode + do animation

func _explode():
	
	get_node("AnimationPlayer").play("explosion")
	
	var victims = $BlastArea.get_overlapping_bodies();
	
	for victim in victims:
		if victim.is_in_group("player"):
			Globals.player_health -= 25;
			print_debug("player damaged by bomb")
		elif victim.is_in_group("enemy"):
			victim.health -= 50;
			print_debug("enemy damaged by bomb")
	
	yield(get_node("AnimationPlayer"), "animation_finished")
	queue_free()

func _on_Area_body_shape_entered(_body_rid, body, _body_shape_index, _local_shape_index):
	if body.is_in_group("enemy"):
		if not exploded:
			_explode();
			body.health -= 10
			print_debug("enemy ran into bomb")
		
	if body.is_in_group("player"):
		if countdown < 2:
			if not exploded:
				_explode();
				print_debug("player ran into bomb")
