class_name InventoryUI extends Control

const INVENTORY_SLOT = preload("uid://ceoaksai3yr1")

var focus_index: int = 0

@export var data: InventoryData

@onready var pause_menu: CanvasLayer = $"../../.."


func _ready() -> void:
	PauseMenu.shown.connect(update_inventory)
	PauseMenu.hidden.connect(clear_inventory)
	clear_inventory()
	data.changed.connect(on_inventory_changed)
	pass
	
func clear_inventory() -> void:
	for c in get_children():
		c.queue_free()

func update_inventory(i: int = 0) -> void:
	clear_inventory()
	for s in data.slots:
		var new_slot = INVENTORY_SLOT.instantiate()
		add_child(new_slot)
		new_slot.slot_data = s
		new_slot.focus_entered.connect(item_focused)
		
	await get_tree().process_frame
	await get_tree().process_frame
	focus_slot(i)

func focus_slot(i: int = 0) -> void:
	if not is_visible_in_tree():
		return
	if get_child_count() == 0:
		return
	var target_index = clampi(i, 0, get_child_count() - 1)
	var target_slot = get_child(target_index) as Control
	if target_slot:
		target_slot.grab_focus.call_deferred()

func item_focused() -> void:
	for i in get_child_count():
		if get_child(i).has_focus():
			focus_index = i
			return

func on_inventory_changed() -> void:
	var i = focus_index
	clear_inventory()
	update_inventory(i)
	#await get_tree().process_frame
	#if get_child_count() > 0:
		#var target_index = min(focus_index, get_child_count() - 1)
		#get_child(target_index).grab_focus()
