extends CharacterBody3D

@export var speed: float = 5.0
@export var jump_velocity: float = 4.5
@export var gravity: float = 9.8
@export var mouse_sensitivity: float = 0.003
@export var item_scene: PackedScene = preload("res://scenes/objects/Item.tscn")
var camera_pivot: Node3D
var pitch: float = 0.0
var inventory: Array = []
var interact_distance: float = 2.0

func _ready():
	camera_pivot = $CameraPivot
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	add_to_group("player")
	await get_tree().process_frame # Aguarda um frame para garantir que o HUD existe
	var hud = get_tree().get_root().find_child("HUD", true, false)
	if hud:
		hud.update_inventory(inventory)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		pitch = clamp(pitch - event.relative.y * mouse_sensitivity, deg_to_rad(-80), deg_to_rad(80))
		camera_pivot.rotation.x = pitch

func _physics_process(delta):
	var input_dir = Vector2.ZERO
	input_dir.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_dir.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_dir = input_dir.normalized()

	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction != Vector3.ZERO:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		if Input.is_action_just_pressed("ui_accept"):
			velocity.y = jump_velocity

	move_and_slide()

	# Interação com itens usando Area3D
	if Input.is_action_just_pressed("interact"):
		var detector = $ItemDetector
		for body in detector.get_overlapping_bodies():
			if body.is_in_group("item"):
				print("Pegou o item: %s" % body.item_name)
				inventory.append(body.item_name)
				body.queue_free()
				# Atualiza o inventário no HUD
				var hud = get_tree().get_root().find_child("HUD", true, false)
				if hud:
					hud.update_inventory(inventory)
				break

	# Dropa o último item ao pressionar Q
	if Input.is_action_just_pressed("drop") and inventory.size() > 0:
		var item_name = inventory.pop_back()
		print("Tentou dropar: %s" % item_name)
		# Atualiza o inventário no HUD
		var hud = get_tree().get_root().find_child("HUD", true, false)
		if hud:
			hud.update_inventory(inventory)
		# Instancia o item na frente do player
		if item_scene:
			print("item_scene está definido!")
			var item_instance = item_scene.instantiate()
			var drop_pos = global_transform.origin + -global_transform.basis.z * 1.5
			# Adiciona deslocamento aleatório para evitar sobreposição exata
			drop_pos.x += randf_range(-0.2, 0.2)
			drop_pos.z += randf_range(-0.2, 0.2)
			drop_pos.y = max(drop_pos.y, 1.0) # Garante que fique acima do chão
			item_instance.global_transform.origin = drop_pos
			print("Dropando item na posição: ", item_instance.global_transform.origin)
			var main = get_tree().get_root().find_child("Main", true, false)
			if main:
				main.add_child(item_instance)
			else:
				get_tree().current_scene.add_child(item_instance)
		else:
			print("item_scene está NULL!")
