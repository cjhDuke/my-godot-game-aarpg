@tool
@icon("res://GUI/dialogue_system/icons/question_bubble.svg")
class_name DialogueChoice extends DialogueItem

var dialogue_branches : Array[DialogueBranch]


func _ready() -> void:
	super()
	
	for c in get_children():
		if c is DialogueBranch:
			dialogue_branches.append(c)

func _set_editor_display() -> void:
	set_related_text()
	if dialogue_branches.size() < 2:
		return
	example_dialogue.set_dialogue_choice( self )
	pass

func set_related_text() -> void:
	var _p = get_parent()
	var _i = _p.get_node(self.get_path()).get_index()
	var _t = _p.get_child(_i - 1)
	if _t is DialogueText:
		example_dialogue.set_dialogue_text(_t)
		example_dialogue.content.visible_characters = -1
	pass

func _get_configuration_warnings() -> PackedStringArray:
	if _check_for_dialogue_branches() == false:
		return ["Requires at least 2 DialogueBranch nodes."]
	else:
		return []
	pass

func _check_for_dialogue_branches() -> bool:
	var _count : int = 0
	for c in get_children():
		if c is DialogueBranch:
			_count += 1
			if _count > 1:
				return true
	return false
