extends Marker3D

# properties
@export_range(0., 1., 0.05) var position_weight: float = .5
@export_range(0., 1., 0.05) var rotation_weight: float = .5
@export var trauma_reduction_rate: float = 1.
@export var trauma_noise: FastNoiseLite
@export var noise_speed: float = 0.5
@export var max_trauma: Vector3 = Vector3(1., 1., 1.)

@onready var camera := $Camera3D as Camera3D
@onready var prev_rotation = Quaternion(camera.global_basis)
@onready var prev_velocity = Vector3(0., 0., 0.)
var trauma: float = 0.0


func _process(delta):
	# smooth camera motion
	update_rotation(delta)
	update_position(delta)
	
	# camera shake
	#print("trauma: ", trauma)
	var trauma_degrees = max_trauma * get_shake() * get_noise_3d()
	camera.rotation_degrees += trauma_degrees
	trauma = max(trauma - delta * trauma_reduction_rate, 0.0)


func update_rotation(delta: float):
	var rot = prev_rotation.slerp(Quaternion(global_basis), 1. - rotation_weight * delta * 60.)
	prev_rotation = rot
	camera.global_basis = Basis(rot)


func update_position(delta: float):
	if "linear_velocity" in get_parent():
		var velocity = .5 * get_parent().linear_velocity + .5 * prev_velocity
		prev_velocity = velocity
		var dir = velocity.normalized()
		var speed = velocity.length()
		camera.global_position = global_position - dir * pow(speed, position_weight)


func trauma_baseline(amount: float):
	trauma = clamp(max(trauma, amount), 0., 1.)
	
func add_trauma(amount: float):
	trauma = clamp(trauma + amount, 0., 1.)

func get_shake() -> float:
	return trauma

func get_noise_3d() -> Vector3:
	var vec: Vector3
	trauma_noise.seed = 0
	vec.x = trauma_noise.get_noise_1d(Time.get_ticks_msec() * noise_speed)
	trauma_noise.seed = 1
	vec.y = trauma_noise.get_noise_1d(Time.get_ticks_msec() * noise_speed)
	trauma_noise.seed = 2
	vec.z = trauma_noise.get_noise_1d(Time.get_ticks_msec() * noise_speed)
	return vec
