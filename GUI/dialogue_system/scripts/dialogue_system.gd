@tool
@icon("res://GUI/dialogue_system/icons/star_bubble.svg")
class_name DialogueSystemNode extends CanvasLayer

signal finished
signal letter_added(letter: String)
signal choice_selected(dialogue_branch: DialogueBranch)

var is_active: bool = false
var text_in_progress: bool = false
var waiting_for_choice: bool = false

var text_speed: float = 0.02
var text_length: int = 0
var plain_text: String

var dialogue_items: Array[DialogueItem]
var dialogue_item_index: int = 0

@onready var dialogue_ui: Control = $DialogueUI
@onready var content: RichTextLabel = $DialogueUI/PanelContainer/RichTextLabel
@onready var name_label: Label = $DialogueUI/NameLabel
@onready var portrait_sprite: DialoguePortrait = $DialogueUI/PortraitSprite
@onready var dialogue_progress_indicator: PanelContainer = $DialogueUI/DialogueProgressIndicator
@onready var dialogue_progress_indicator_label: Label = $DialogueUI/DialogueProgressIndicator/Label
@onready var timer: Timer = $DialogueUI/Timer
@onready var audio_stream_player: AudioStreamPlayer = $DialogueUI/AudioStreamPlayer
@onready var choice_options: VBoxContainer = $DialogueUI/VBoxContainer


func _ready() -> void:
	if Engine.is_editor_hint():
		if get_viewport() is Window:
			get_parent().remove_child(self )
			return
	timer.timeout.connect(_on_timer_timeout)
	hide_dialogue()
	return

func _unhandled_input(event: InputEvent) -> void:
	if is_active == false:
		return
	if (
		event.is_action_pressed("interact") or
		event.is_action_pressed("attack") or
		event.is_action_pressed("ui_accept")
	):
		if text_in_progress == true:
			content.visible_characters = text_length
			timer.stop()
			text_in_progress = false
			show_dialogue_button_indicator(true)
			return
		elif waiting_for_choice == true:
			return
		
		dialogue_item_index += 1
		if dialogue_item_index < dialogue_items.size():
			start_dialogue()
		else:
			hide_dialogue()
			
			
func show_dialogue(_items: Array[DialogueItem]) -> void:
	is_active = true
	dialogue_ui.visible = true
	dialogue_ui.process_mode = Node.PROCESS_MODE_ALWAYS
	dialogue_items = _items
	dialogue_item_index = 0
	get_tree().paused = true
	await get_tree().process_frame
	start_dialogue()
	pass
	
	
func hide_dialogue() -> void:
	is_active = false
	choice_options.visible = false
	dialogue_ui.visible = false
	dialogue_ui.process_mode = Node.PROCESS_MODE_DISABLED
	get_tree().paused = false
	finished.emit()
	pass

func start_dialogue() -> void:
	waiting_for_choice = false
	show_dialogue_button_indicator(false)
	var _d: DialogueItem = dialogue_items[dialogue_item_index]
	
	if _d is DialogueText:
		set_dialogue_text(_d as DialogueText)
	elif _d is DialogueChoice:
		set_dialogue_choice(_d as DialogueChoice)
	
	pass

func set_dialogue_text(_d: DialogueText) -> void:
	if _d is DialogueText:
		content.text = _d.text
	choice_options.visible = false
	name_label.text = _d.npc_info.npc_name
	portrait_sprite.texture = _d.npc_info.portrait
	portrait_sprite.audio_pitch_base = _d.npc_info.dialogue_audio_pitch
	content.visible_characters = 0
	text_length = content.get_total_character_count()
	plain_text = content.get_parsed_text()
	text_in_progress = true
	start_timer()
	pass


func set_dialogue_choice(_d: DialogueChoice) -> void:
	choice_options.visible = true
	waiting_for_choice = true
	var first_choice_button: Button
	for c in choice_options.get_children():
		c.queue_free()
	
	for i in _d.dialogue_branches.size():
		var _new_choice: Button = Button.new()
		_new_choice.text = _d.dialogue_branches[i].text
		_new_choice.alignment = HORIZONTAL_ALIGNMENT_LEFT
		_new_choice.pressed.connect(_dialogue_choice_selected.bind(_d.dialogue_branches[i]))
		choice_options.add_child(_new_choice)
		if i == 0:
			first_choice_button = _new_choice
	if Engine.is_editor_hint():
		return
	await get_tree().process_frame
	if first_choice_button:
		first_choice_button.grab_focus.call_deferred()
	
	pass
 
func _dialogue_choice_selected(_d: DialogueBranch) -> void:
	choice_options.visible = false
	choice_selected.emit(_d)
	show_dialogue(_d.dialogue_items)
	pass

func _on_timer_timeout() -> void:
	content.visible_characters += 1
	if content.visible_characters < text_length:
		#audio_stream_player.play()
		letter_added.emit(plain_text[content.visible_characters - 1])
		start_timer()
	else:
		show_dialogue_button_indicator(true)
		text_in_progress = false
	pass


func show_dialogue_button_indicator(_is_visible: bool) -> void:
	dialogue_progress_indicator.visible = _is_visible
	if dialogue_item_index + 1 < dialogue_items.size():
		dialogue_progress_indicator_label.text = "NEXT"
	else:
		dialogue_progress_indicator_label.text = "END"


func start_timer() -> void:
	timer.wait_time = text_speed
	# At the beginning visible_characters is 0, so avoid indexing -1.
	if content.visible_characters > 0 and content.visible_characters <= plain_text.length():
		var _char = plain_text[content.visible_characters - 1]
		if '.!?:;'.contains(_char):
			timer.wait_time *= 4
		elif ', '.contains(_char):
			timer.wait_time *= 2
	timer.start()
	pass
