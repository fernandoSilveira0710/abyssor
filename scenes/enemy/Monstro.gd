extends CharacterBody3D

@export var speed: float = 2.0
@export var detection_radius: float = 7.0
@export var patrol_point_a: Vector3 = Vector3(-3, 1, 0)
@export var patrol_point_b: Vector3 = Vector3(3, 1, 0)
var target_point: Vector3
var chasing: bool = false
var player: Node = null

func _ready():
	target_point = patrol_point_b

func _physics_process(_delta):
	if not player:
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			player = players[0]

	if player and global_position.distance_to(player.global_position) < detection_radius:
		chasing = true
	else:
		chasing = false

	if chasing and player:
		# Persegue o player
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()
	else:
		# Patrulha entre dois pontos
		var direction = (target_point - global_position)
		if direction.length() < 0.2:
			target_point = patrol_point_a if target_point == patrol_point_b else patrol_point_b
		direction = direction.normalized()
		velocity = direction * speed * 0.5
		move_and_slide()
