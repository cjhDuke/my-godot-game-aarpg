@tool
@icon("res://GUI/dialogue_system/icons/answer_bubble.svg")
class_name DialogueBranch extends DialogueItem

@export var text : String = "ok..." : set = set_text

var dialogue_items : Array[DialogueItem]

func _ready() -> void:
	super()
	if Engine.is_editor_hint():
		return
	
	
	for c in get_children():
		if c is DialogueItem:
			dialogue_items.append(c)

func _set_editor_display() -> void:
	var _p = get_parent()
	if _p is DialogueChoice:
		set_related_text()
		if _p.dialogue_branches.size() < 2:
			return
		example_dialogue.set_dialogue_choice(_p as DialogueChoice)
	pass

func set_related_text() -> void:
	var _p = get_parent()
	var _p2 = _p.get_parent()
	var _t = _p2.get_child(_p.get_index() - 1)
	if _t is DialogueText:
		example_dialogue.set_dialogue_text(_t)
		example_dialogue.content.visible_characters = -1

func set_text(value : String) -> void:
	text = value
	if Engine.is_editor_hint():
		if example_dialogue != null:
			_set_editor_display()
