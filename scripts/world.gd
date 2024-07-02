extends Node3D


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
