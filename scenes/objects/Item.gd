extends RigidBody3D

@export var item_type: String = "generic"
@export var item_name: String = "Item"

func _ready():
	add_to_group("item")
	angular_damp = 5.0 
