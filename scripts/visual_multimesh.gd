extends MultiMeshInstance3D


func _ready():
	# number of times the world will be visually repeated
	var warp_layers = $/root/Stage/World.get_meta("warp_layers")
	var warps = warp_layers * 2 - 1
	
	# size of the world to repeat
	var world_size = ($/root/Stage/World/Area3D/CollisionShape3D.shape as BoxShape3D).size
	extra_cull_margin = maxf(maxf(world_size.x, world_size.y), world_size.z)
	
	var material = multimesh.mesh.surface_get_material(0) as ShaderMaterial
	material.set_shader_parameter("warps", warps)
	material.set_shader_parameter("world_size", world_size)
	
	var instances = warps ** 3
	multimesh.instance_count = instances
	multimesh.visible_instance_count = instances
	
	for i in range(instances):
		multimesh.set_instance_transform(i, Transform3D())
