extends Node3D

# properties
@export var asteroid_scene : PackedScene
@export_range(1, 100) var number_of_asteroids : int = 10


func _ready():
	# spawn in asteroids
	for i in range(number_of_asteroids):
		# create a new instance of the asteroid scene
		var asteroid = asteroid_scene.instantiate()
		
		# set to random position
		var area_shape = $Area3D/CollisionShape3D
		var shape_size = (area_shape.shape as BoxShape3D).size
		asteroid.position = Vector3(
			randf()-0.5, 
			randf()-0.5, 
			randf()-0.5
		) * shape_size + area_shape.global_position
		
		# add it to the scene
		add_child(asteroid)


func _on_area_3d_body_exited(body):
	if not "position" in body:
		return
	
	# get world box
	var area_shape = $Area3D/CollisionShape3D
	var shape_size = (area_shape.shape as BoxShape3D).size
	
	# transform body position to box local space
	var pos = area_shape.to_local(body.position)
	
	# clamp position to box extents
	pos += shape_size * 1.5
	pos.x = fmod(pos.x, shape_size.x)
	pos.y = fmod(pos.y, shape_size.y)
	pos.z = fmod(pos.z, shape_size.z)
	pos -= shape_size / 2
	
	# transform body position back to global space
	body.position = area_shape.to_global(pos)
