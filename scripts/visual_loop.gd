extends Node3D


var dstNode : Node3D


func _ready():
	# pack visual object into scene for instantiation
	var scene = PackedScene.new()
	scene.pack(self)
	
	# create node to add instances to
	dstNode = Node3D.new()
	owner.add_sibling.call_deferred(dstNode)
	
	# number of times the world will be visually repeated
	var warp_layers = $/root/Stage/World.get_meta("warp_layers")
	var warps = warp_layers * 2 - 1
	
	# size of the world to repeat
	var world_size = ($/root/Stage/World/Area3D/CollisionShape3D.shape as BoxShape3D).size
	
	# create instances
	for i in range(pow(warps, 3)):
		var offset = Vector3(
			i % warps			- warps / 2,
			i / warps % warps	- warps / 2,
			i / (warps * warps)	- warps / 2
		)
		if offset == Vector3.ZERO:
			continue
		offset *= world_size
		
		var model_instance = scene.instantiate()
		model_instance.set_script(null)
		model_instance.position = offset
		dstNode.add_child.call_deferred(model_instance)


func _process(delta):
	dstNode.position = global_position
	for m in dstNode.get_children():
		m.rotation = global_rotation


func _exit_tree():
	dstNode.queue_free()
