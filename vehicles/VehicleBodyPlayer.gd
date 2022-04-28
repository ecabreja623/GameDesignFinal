extends VehicleBody

# Member variables


export var steering_max_angle = 0.75
export var steering_speed = 4.0
export var steering_percent_drop = 0.75
export var steering_from_speed = 18
export var steering_to_speed = 100
var health = 100;
var max_health = 100;
var steering_speed_range = 0
var steering_target = 0
var steering_angle = 0

var throttle = 0;
var brakes = false
var start_sound = true

#Alternative A
export var torque_curve_rpms = [500, 5000, 5500, 6500, 7500, 9000]
export var torque_curve_torques = [400, 1100, 1300, 1800, 1600, 0]

#Alternative B
export var torque_curve = [Vector2(500,400), Vector2(5000, 1100), Vector2(5500, 1300), 
						   Vector2(6500, 1800), Vector2(7500, 1600), Vector2(9000, 0)]


export var gear_ratios = [-4.25, 3.2, 2.24, 1.57, 1.23, 1.065]
export var differential_ratio = 2.1
export var transmission_efficiency = 0.75
export var friction_coefficient = -0.8
export var drag_coefficient = -0.8
export var brake_strength = 25


var current_gear
var spin_out = 8
export var slip_speed = 9.0
export var traction_slow = 0.75
export var traction_fast = 0.02

var drifting = false

export var nitro_usage = 0.2
var nitro_toggle = 0
export var has_handbrake = true

var cooldown = 0;

func _ready():
	steering_speed_range = steering_to_speed - steering_from_speed
	current_gear = 1
	if (start_sound):
		$Start_Sound.play()
		start_sound = false
	elif (!start_sound):
		$Start_Sound.stream_paused = true
	

func compute():
	pass


func apply_friction(delta):
	if linear_velocity.length() < 0.02 and engine_force == 0:
		linear_velocity.x = 0
		linear_velocity.z = 0
	var friction_force = linear_velocity.length() *linear_velocity.length()* friction_coefficient * delta
	var drag_force = linear_velocity.length() * linear_velocity.length() * drag_coefficient * delta
	engine_force += drag_force + friction_force
	

	
func _physics_process(delta):
	
	
	if Input.is_action_just_pressed("reset"):
		#get_tree().reload_current_scene()
		apply_impulse(Vector3(1, 0, 0), Vector3(0, mass * 2, 0))
	
	if Globals.player_health <= 0:
		queue_free()
	
	cooldown -= delta;
	Globals.player_pos = global_transform.origin;
	
	if (Input.is_action_pressed("ui_left")):
		steering_target = 1
	elif (Input.is_action_pressed("ui_right")):
		steering_target = -1
	else:
		steering_target = 0

	if (Input.is_action_pressed("ui_up")):
		throttle = 1
	else:
		throttle = 0

	if (Input.is_action_pressed("nitrous")) and Globals.nitro_fuel > 0:
		nitro_toggle = 1
		Globals.nitro_fuel -= nitro_usage
	
		if Globals.nitro_fuel < 0:
			Globals.nitro_fuel = 0
	else:
		nitro_toggle = 0
	
	if nitro_toggle == 1:
		get_node("NitroParticles_left").emitting = true
		get_node("NitroParticles_right").emitting = true
	else:
		get_node("NitroParticles_left").emitting = false
		get_node("NitroParticles_right").emitting = false

	if (Input.is_action_pressed("ui_down")):
		brake = brake_strength

	elif has_handbrake:
		if Input.is_action_pressed("handbrake"):
			brake = brake_strength / 4

			if (spin_out > 3):
				spin_out -= 10 * delta

			get_node("VehicleWheel").wheel_friction_slip = spin_out
			get_node("VehicleWheel2").wheel_friction_slip = spin_out
		else:
			brake = 0
			if (spin_out < 4):
				spin_out += 1 * delta
			if spin_out > 4:
				spin_out = 4
			get_node("VehicleWheel").wheel_friction_slip = spin_out
			get_node("VehicleWheel2").wheel_friction_slip = spin_out
			
	var wheel_radius = get_node("VehicleWheel").wheel_radius
	var local_velocity = get_transform().basis.x.dot(linear_velocity)

	var kph = abs(local_velocity * 3.6);
	Globals.kph = kph;
	var omega = local_velocity / wheel_radius * 6.28;
	var rpm = abs(omega) * abs(gear_ratios[current_gear]) * differential_ratio * (60.0 / 6.28)
	
	#SpeedLines
	
	if kph<40:
		get_node("SpeedLines/Particles2D").emitting = false
		get_node("SpeedLines/Particles2D").speed_scale = 0.2
		
	elif kph >= 40 and kph <50:
		get_node("SpeedLines/Particles2D").emitting = true
		get_node("SpeedLines/Particles2D").amount = 5
	elif kph >= 50 and kph <60:
		get_node("SpeedLines/Particles2D").emitting = true
		get_node("SpeedLines/Particles2D").amount = 6
	elif kph >= 60 and kph <70:
		get_node("SpeedLines/Particles2D").emitting = true
		get_node("SpeedLines/Particles2D").amount = 8
	elif kph >= 70 and kph <80:
		get_node("SpeedLines/Particles2D").emitting = true
		get_node("SpeedLines/Particles2D").amount = 10
	else:
		get_node("SpeedLines/Particles2D").emitting = true
		get_node("SpeedLines/Particles2D").amount = 11
	print(get_node("SpeedLines/Particles2D").emitting)
	
		
	
	if rpm < torque_curve_rpms[0]:
		rpm = torque_curve_rpms[0]
	if rpm > torque_curve_rpms[5] and nitro_toggle == 0:
		rpm = torque_curve_rpms[5]

	if (current_gear == 1 and omega <= 1.0 and omega >= 0 and brake > 0):
		current_gear = 0;

	if current_gear == 0:
		if throttle != 0:
			current_gear = 1
		elif brake > 0:
			throttle = 1
			brake = 0

	if (current_gear > 1):
		if rpm < torque_curve_rpms[1] * 0.5:
			current_gear -= 1
	else:
		pass
		#if rpm < 2000:
		#	rpm = 2000

	if current_gear > 0 and rpm > torque_curve_rpms[4] and current_gear < 5:
		current_gear += 1

	var high = 0
	while (rpm >= torque_curve_rpms[high]):
		high += 1
		if high >= 6:
			high = 5
			break
	var low = high - 1
	if (high == 0):
		low = 0
		high = 1

	var interp = (rpm - torque_curve_rpms[low]) / (torque_curve_rpms[high] - torque_curve_rpms[low])
	var engine_torque = torque_curve_torques[low] + ((torque_curve_torques[high] - torque_curve_torques[low]) * interp)
	var wheel_torque = throttle * engine_torque * gear_ratios[current_gear] * differential_ratio * transmission_efficiency

	engine_force = wheel_torque * wheel_radius * 2

	if not drifting and Globals.kph > slip_speed:
		drifting = true
	if drifting and Globals.kph < slip_speed and steering_angle == 0:
		drifting = false
	# get_node("VehicleWheel").traction = traction_fast if drifting else traction_slow
	# get_node("VehicleWheel2").traction = traction_fast if drifting else traction_slow
	# velocity = lerp(velocity, new_heading * velocity.length(), traction)		
	if nitro_toggle == 1:
		engine_force = engine_force * 2.5



	#print("Gear: %d  RPM: %d  KPH: %d  Force: %d  Nitrous: %d" % [current_gear, rpm, kph, engine_force, Globals.nitro_fuel])
	# apply_friction(delta)
	#calculate steering angle
	steering_angle += steering_speed * steering_target * delta

	#re-center if not steering
	if not steering_target:
		if steering_angle > 0:
			steering_angle -= steering_speed * delta
			if steering_angle < 0:
				steering_angle = 0
		else:
			steering_angle += steering_speed * delta
			if steering_angle > 0:
				steering_angle = 0

	#calculate the new max steering angle based on velocity data
	var max_steer = steering_max_angle

#	if kph < steering_from_speed:
#		#going slower than the minimum speed, so no change.
#		pass 
#	elif kph > steering_to_speed:
#		#going faster than highest speed, so remove completely!
#		max_steer -= max_steer * steering_percent_drop
#
#	else:
#		#inside the range [steering_from_speed, steering_to_speed]
#		var steer_delta = (kph - steering_from_speed) / steering_speed_range
#		max_steer -= max_steer * steering_percent_drop * steer_delta
#
	if steering_angle > max_steer:
		steering_angle = max_steer
	elif steering_angle < -max_steer:
		steering_angle = -max_steer
	
	if (Input.is_action_pressed("drift") and (current_gear > 3) and (kph > 60)):
		
		if(Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_left")):
			
			$"Scene Root/skidmark1".rotation_degrees.x += .5
			$"Scene Root/skidmark1".visible = true
		
			$"Scene Root/skidmark2".visible = true
			#doSkidmarks()
			if $Drift_Sound.is_playing():
				$Drift_Sound.stream_paused = false
			else:
				$Drift_Sound.play()
		else:
			$"Scene Root/skidmark1".visible = false
			$"Scene Root/skidmark2".visible = false
			$Drift_Sound.stream_paused = true
	else:
			$"Scene Root/skidmark1".visible = false
			
			$"Scene Root/skidmark2".visible = false
			$Drift_Sound.stream_paused = true

	if (kph != 0) and (engine_force >= 0):
		if $Acceleration_Sound.is_playing():
			$Acceleration_Sound.stream_paused = false
		else:
			$Acceleration_Sound.play()
	else:
		$Acceleration_Sound.stream_paused = true
		
		
	if (Input.is_action_pressed("ui_down") and kph > -1):
		if $Brake_Sound.is_playing():
			$Brake_Sound.stream_paused = false
		else:
			$Brake_Sound.play()
	else:
		$Brake_Sound.stream_paused = true
		
	if ($"Scene Root/obj1".get_global_transform().origin.y > 5):
		if $CrowdReact.is_playing():
			$CrowdReact.stream_paused = false
		else:
			$CrowdReact.play()
	else:
		$CrowdReact.stream_paused = true
		
		

	steering = steering_angle

const Skidmark = preload("res://scenes/skidmark3d.tscn")

func doSkidmarks():
	var skidmark = Skidmark.instance()
	skidmark.add_child($skidmark1)
	skidmark.add_child($skidmark2)
	print(skidmark.get_node("ImmediateGeometry").visible)
	skidmark.get_node("ImmediateGeometry").visible = false
	print(skidmark.get_node("ImmediateGeometry").visible)
	$skidmark1.visible = true
	$skidmark2.visible = true
	
	#print(get_node("skidmark1").get("drifting"))
	#$skidmark1.drifting = true
	#print(skidmark.get_global_position())
	#print($VehicleWheel.position)
	#skidmark.position = position
	#skidmark.rotation = rotation
	get_node("/root/Arena/skidmarks").add_child(skidmark)

func _on_CollisionArea_body_entered(body):
	if body.is_in_group("track"):
		
		if cooldown <= 0:
			Globals.player_health -= abs(Globals.kph) * 0.05
			cooldown = 1
	if body.is_in_group("enemy"):
		print("enemy fire")
		$CarCrash.play()
	return

