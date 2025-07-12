extends CanvasLayer

@onready var inventory_label: Label = $InventoryLabel
@onready var inventory_slots: HBoxContainer = $InventoryPanel/InventorySlots

func update_inventory(inventory: Array):
	inventory_label.text = "Inventário: " + ", ".join(inventory)

func update_inventory_slots(inventory: Array, selected_slot: int, max_slots: int):
	# Limpa os slots atuais
	for child in inventory_slots.get_children():
		child.queue_free()
	# Cria os slots
	for i in range(max_slots):
		var panel = Panel.new()
		panel.custom_minimum_size = Vector2(60, 60)
		panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		if i == selected_slot:
			panel.modulate = Color(0.7, 1, 0.7, 1) # Destaque verde
		else:
			panel.modulate = Color(1, 1, 1, 0.8)
		if i < inventory.size() and inventory[i] != null:
			var slot = inventory[i]
			var label = Label.new()
			label.text = slot.item_name
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			label.size_flags_vertical = Control.SIZE_EXPAND_FILL
			panel.add_child(label)
		else:
			# Slot vazio
			pass
		inventory_slots.add_child(panel)
