extends Node


# Properties
@export var mesh : Mesh
@export var color : Color
@export var shader : Shader = preload("res://materials/space_mesh.gdshader")


func _ready():
	#region set up Mesh Material
	# create new shader material
	var material = ShaderMaterial.new()
	material.shader = shader
	
	# set shader parameters
	material.set_shader_parameter("albedo", color)
	# number of times the world will be visually repeated
	var warp_layers = $/root/Stage/World.get_meta("warp_layers")
	material.set_shader_parameter("warp_layers", warp_layers)
	# size of the world to repeat
	var world_size = ($/root/Stage/World/Area3D/CollisionShape3D.shape as BoxShape3D).size
	material.set_shader_parameter("world_size", world_size)
	
	# set material to mesh surface
	mesh.surface_set_material(0, material)
	#endregion
	
	#region set up Multimesh
	var mmi = MultiMeshInstance3D.new()
	mmi.extra_cull_margin = maxf(maxf(world_size.x, world_size.y), world_size.z)
	mmi.multimesh = MultiMesh.new()
	
	# set multimesh parameters
	mmi.multimesh.mesh = mesh
	mmi.multimesh.transform_format = MultiMesh.TRANSFORM_3D
	mmi.multimesh.instance_count = (warp_layers * 2 - 1) ** 3
	mmi.multimesh.visible_instance_count = (warp_layers * 2 - 1) ** 3
	for i in range(mmi.multimesh.instance_count):
		mmi.multimesh.set_instance_transform(i, Transform3D())
	add_child(mmi)
	#endregion
	
	#region disable MeshInstance siblings
	var single_meshes = get_parent().find_children("MeshInstance3D")
	for sm in single_meshes:
		sm.queue_free()
	#endregion
