@tool
@icon("res://GUI/dialogue_system/icons/chat_bubbles.svg")
class_name DialogueInteraction extends Area2D

signal player_interacted
signal finished

@export var enabled: bool = true

var dialogue_items: Array[DialogueItem]

@onready var animation_player: AnimationPlayer = get_node_or_null("AnimationPlayer") as AnimationPlayer


func _ready() -> void:
	if Engine.is_editor_hint():
		return

	# Keep bubble hidden until player enters interaction range.
	if animation_player and animation_player.has_animation("default"):
		animation_player.play("default")
	elif animation_player == null:
		push_warning("DialogueInteraction missing child node 'AnimationPlayer'. Show/hide animation will be skipped.")
	
	area_entered.connect(_on_area_enter)
	area_exited.connect(_on_area_exit)
	
	for c in get_children():
		if c is DialogueItem:
			dialogue_items.append(c)

func player_interact() -> void:
	player_interacted.emit()
	await get_tree().process_frame
	await get_tree().process_frame
	DialogueSystem.show_dialogue(dialogue_items)
	DialogueSystem.finished.connect(_on_dialogue_finished)
	pass

func _on_area_enter(_a: Area2D) -> void:
	if (_a.collision_layer & 4) == 0:
		return
	if enabled == false || dialogue_items.size() == 0:
		return
	if animation_player:
		animation_player.play("show")
	if not PlayerManager.interact_pressed.is_connected(player_interact):
		PlayerManager.interact_pressed.connect(player_interact)
	pass

func _on_area_exit(_a: Area2D) -> void:
	if (_a.collision_layer & 4) == 0:
		return
	if animation_player:
		animation_player.play("hide")
	if PlayerManager.interact_pressed.is_connected(player_interact):
		PlayerManager.interact_pressed.disconnect(player_interact)
	finished.emit()
	pass

func _on_dialogue_finished() -> void:
	DialogueSystem.finished.disconnect(_on_dialogue_finished)
	finished.emit()

func _get_configuration_warnings() -> PackedStringArray:
	if _check_for_dialogue_items() == false:
		return ["Requires at least one DialogueItem node. "]
	else:
		return []
	pass
	
func _check_for_dialogue_items() -> bool:
	for c in get_children():
		if c is DialogueItem:
			return true
	return false
