extends VehicleBody

# Member variables
var health = 100

export var steering_max_angle = 0.75
export var steering_speed = 4.0
export var steering_percent_drop = 0.75
export var steering_from_speed = 18
export var steering_to_speed = 100
var steering_speed_range = 0
var steering_target = 0
var steering_angle = 0

var throttle = 0;
var brakes = false
var start_sound = false

var path = []
var curr_path_index = 0
var target = null

onready var nav = get_parent()

var has_powerup = false;

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

var kph


func _ready():

	steering_speed_range = steering_to_speed - steering_from_speed
	current_gear = 1
	
	target = Globals.player_pos
	
	get_target_path(target)
	

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

	if health <= 0:
		queue_free()

	var distance_to_player = transform.origin.distance_to(Globals.player_pos)
	
	#print_debug("Player")
	#print_debug(Globals.player_pos)
	#print_debug("enemy:")
	#print_debug(global_transform.origin)
	
	target = Globals.player_pos
	
	if path.size() > 0:
		move_to_target()
		#print_debug(path)
	
	var wheel_radius = get_node("VehicleWheel").wheel_radius
	var local_velocity = get_transform().basis.z.dot(linear_velocity)

	kph = local_velocity * 3.6	
	#Globals.kph = kph;
	var omega = local_velocity / wheel_radius * 6.28;
	var rpm = abs(omega) * abs(gear_ratios[current_gear]) * differential_ratio * (60.0 / 6.28)

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



	# print("Gear: %d  RPM: %d  KPH: %d  Force: %d  Nitrous: %d" % [current_gear, rpm, kph, engine_force, nitro_fuel])
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

	steering = steering_angle

func move_to_target():
	if curr_path_index >= path.size():
		return
	
	var dirToMovePosition = target - transform.origin
	
	var dot = get_global_transform().basis.z.dot(dirToMovePosition)
	
	#print_debug(dot)
	if dot > 0:
		throttle = 1;
	else:
		throttle = -1;
		
	var angleToDir = get_global_transform().basis.z.signed_angle_to(dirToMovePosition, Vector3.UP)
	#print_debug(angleToDir)	# left is positive, right is negative
	
	if angleToDir > 0:
		steering_target = 1;
	else:
		steering_target = -1;
		
func get_target_path(target_pos):
	path = nav.get_simple_path(global_transform.origin, target_pos)
	
	curr_path_index = 0
	
	
	

func _on_VehicleBody_body_entered(body):
	if body.is_in_group('player'):
		if abs(kph) > abs(Globals.kph):	#enemy is moving faster than player
			
			Globals.player_health -= abs(kph) * 0.3
			if self.is_in_group('enemy1'):
				Globals.enemy_health1 -= abs(Globals.kph) * 0.1
			elif self.is_in_group('enemy2'):
				Globals.enemy_health2 -= abs(Globals.kph) * 0.1
			health -= abs(Globals.kph) * 0.1
		
		else:
			if self.is_in_group('enemy1'):
				Globals.enemy_health1 -= abs(Globals.kph) * 0.3
			elif self.is_in_group('enemy2'):
				Globals.enemy_health2 -= abs(Globals.kph) * 0.3
			health -= abs(Globals.kph) * 0.3
			Globals.score += 5
			Globals.player_health -= abs(kph) * 0.1
	return


