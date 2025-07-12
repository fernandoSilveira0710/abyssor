extends CharacterBody3D

@export var speed: float = 5.0
@export var jump_velocity: float = 4.5
@export var gravity: float = 9.8
@export var mouse_sensitivity: float = 0.003
@export var item_scene: PackedScene = preload("res://scenes/objects/Item.tscn")
@export var player_type: String = "normal" # "fraco", "normal", "forte"

var camera_pivot: Node3D
var pitch: float = 0.0
var inventory: Array = [] # cada slot: {item_type, item_name, quantity}
var selected_slot: int = 0
var MAX_SLOTS: int = 4

# Exemplo de ícone padrão para itens (ajuste para o caminho real se tiver ícones)
const DEFAULT_ITEM_ICON = "res://icon.svg"

func _ready():
	camera_pivot = $CameraPivot
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	add_to_group("player")
	# Define slots conforme tipo de player
	match player_type:
		"fraco": MAX_SLOTS = 3
		"normal": MAX_SLOTS = 4
		"forte": MAX_SLOTS = 5
	await get_tree().process_frame
	var hud = get_tree().get_root().find_child("HUD", true, false)
	if hud:
		hud.update_inventory_slots(inventory, selected_slot, MAX_SLOTS)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		pitch = clamp(pitch - event.relative.y * mouse_sensitivity, deg_to_rad(-80), deg_to_rad(80))
		camera_pivot.rotation.x = pitch
	# Navegação de slots com TAB
	if event is InputEventKey and event.is_pressed() and not event.echo:
		if event.keycode == KEY_TAB:
			selected_slot = (selected_slot + 1) % MAX_SLOTS
			var hud = get_tree().get_root().find_child("HUD", true, false)
			if hud:
				hud.update_inventory_slots(inventory, selected_slot, MAX_SLOTS)
		if event.keycode == KEY_E: # Interagir
			try_pickup_item()
		if event.keycode == KEY_Q:
			drop_selected()

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

# As funções de coleta/drop serão adaptadas depois para usar os slots

func try_pickup_item():
	var detector = $ItemDetector
	for body in detector.get_overlapping_bodies():
		if body.is_in_group("item"):
			var item_data = {
				"item_type": body.item_type,
				"item_name": body.item_name,
				"item_icon": DEFAULT_ITEM_ICON
			}
			# 1. Se slot selecionado vazio ou null, coloca ali
			if selected_slot >= inventory.size() or inventory[selected_slot] == null:
				while inventory.size() <= selected_slot:
					inventory.append(null)
				inventory[selected_slot] = item_data
				print("Pegou o item no slot selecionado vazio: %d" % selected_slot)
			# 2. Se todos ocupados, dropa o selecionado e coloca o novo item ali
			else:
				drop_item(selected_slot)
				inventory[selected_slot] = item_data
				print("Inventário cheio, dropou e pegou no slot: %d" % selected_slot)
			body.queue_free()
			var hud = get_tree().get_root().find_child("HUD", true, false)
			if hud:
				hud.update_inventory_slots(inventory, selected_slot, MAX_SLOTS)
			break

func drop_item(slot_idx: int):
	if slot_idx < inventory.size() and inventory[slot_idx] != null:
		var item = inventory[slot_idx]
		# Instancia o item na frente do player
		if item_scene:
			var item_instance = item_scene.instantiate()
			item_instance.global_transform.origin = global_transform.origin + -global_transform.basis.z * 1.5
			item_instance.item_type = item.item_type
			item_instance.item_name = item.item_name
			var main = get_tree().get_root().find_child("Main", true, false)
			if main:
				main.add_child(item_instance)
			else:
				get_tree().current_scene.add_child(item_instance)
		# Remove do inventário (mantém posição)
		inventory[slot_idx] = null
		var hud = get_tree().get_root().find_child("HUD", true, false)
		if hud:
			hud.update_inventory_slots(inventory, selected_slot, MAX_SLOTS)

func drop_selected():
	if selected_slot < inventory.size():
		drop_item(selected_slot)
		# Seleciona o próximo slot ocupado (ou volta para o primeiro)
		if inventory.size() > 0:
			selected_slot = min(selected_slot, inventory.size() - 1)
		else:
			selected_slot = 0
		var hud = get_tree().get_root().find_child("HUD", true, false)
		if hud:
			hud.update_inventory_slots(inventory, selected_slot, MAX_SLOTS)
