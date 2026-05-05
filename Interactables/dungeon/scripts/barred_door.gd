class_name BarredDoor extends Node2D


var is_open: bool = false

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	set_state()
	pass
	
func open_door() -> void:
	is_open = true
	SaveManager.set_scene_node_state_value(self, "is_open", is_open)
	animation_player.play("open_door")
	pass
	
func close_door() -> void:
	is_open = false
	SaveManager.set_scene_node_state_value(self, "is_open", is_open)
	animation_player.play("close_door")
	pass


func set_state() -> void:
	is_open = bool(SaveManager.get_scene_node_state_value(self, "is_open", false))
	if is_open:
		animation_player.play("opened")
	else:
		animation_player.play("closed")
