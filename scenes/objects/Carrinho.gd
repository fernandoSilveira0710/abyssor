extends RigidBody3D

@export var speed: float = 2.0
@export var max_weight: float = 100.0
@export var push_distance: float = 2.0
@export var push_force: float = 100.0
var current_weight: float = 0.0
var player: Node = null
var is_being_pushed: bool = false

func _ready():
	# Busca o player na cena
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

func _physics_process(delta):
	is_being_pushed = false
	if player:
		var dist = global_position.distance_to(player.global_position)
		if dist < push_distance and Input.is_action_pressed("interact"):
			print("Interagiu com o carrinho!")
			# Empurrar o carrinho na direção que o player está olhando
			var push_dir = -player.global_transform.basis.z.normalized()
			apply_central_force(push_dir * push_force * (1.0 - current_weight / max_weight))
			is_being_pushed = true

func add_weight(amount: float):
	current_weight = clamp(current_weight + amount, 0, max_weight)

func remove_weight(amount: float):
	current_weight = clamp(current_weight - amount, 0, max_weight)
