extends CanvasLayer

@onready var inventory_label: Label = $InventoryLabel

func update_inventory(inventory: Array):
	inventory_label.text = "Inventário: " + ", ".join(inventory)
