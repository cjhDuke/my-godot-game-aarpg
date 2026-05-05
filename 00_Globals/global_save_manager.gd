extends Node

const SAVE_PATH = "user://"

signal game_loaded
signal game_saved


var current_save: Dictionary = {
	scene_path = "",
	player = {
		hp = 1,
		max_hp = 1,
		pos_x = 0,
		pos_y = 0
	},
	items = [],
	persistence = [],
	completed_scenes = [],
	scene_node_states = {},
	quests = [],
}


func save_game() -> void:
	update_player_data()
	update_scene_path()
	update_item_data()
	var file := FileAccess.open(SAVE_PATH + "save.sav", FileAccess.WRITE)
	var save_json = JSON.stringify(current_save)
	file.store_line(save_json)
	game_saved.emit()
	

	pass
	
	

func get_save_file() -> FileAccess:
	return FileAccess.open(SAVE_PATH + "save.sav", FileAccess.READ)


func load_game() -> void:
	if FileAccess.file_exists(SAVE_PATH + "save.sav") == false:
		return
	var file := get_save_file()
	var json := JSON.new()
	json.parse(file.get_line())
	var save_dict: Dictionary = json.get_data() as Dictionary
	current_save = save_dict
	_validate_save_data()
	
	LevelManager.load_new_level(current_save.scene_path, "", Vector2.ZERO)
	
	await LevelManager.level_load_started
	
	PlayerManager.set_player_position(Vector2(current_save.player.pos_x, current_save.player.pos_y))
	PlayerManager.set_health(current_save.player.hp, current_save.player.max_hp)
	PlayerManager.INVENTORY_DATA.parse_save_data(current_save.items)
	
	await LevelManager.level_loaded
	
	game_loaded.emit()
	
	pass


func update_player_data() -> void:
	var p: Player = PlayerManager.player
	current_save.player.hp = p.hp
	current_save.player.max_hp = p.max_hp
	current_save.player.pos_x = p.global_position.x
	current_save.player.pos_y = p.global_position.y


func update_scene_path() -> void:
	var p: String = ""
	for c in get_tree().root.get_children():
		if c is Level:
			p = c.scene_file_path
	current_save.scene_path = p

func update_item_data() -> void:
	current_save.items = PlayerManager.INVENTORY_DATA.get_save_data()


func add_persistent_value( value : String ) -> void:
	if check_persistent_value( value ) == false:
		current_save.persistence.append( value )
	pass
	
func check_persistent_value( value : String ) -> bool:
	var p = current_save.persistence as Array
	return p.has( value )


func set_scene_node_state(node: Node, state: Dictionary) -> void:
	var key := get_scene_node_key(node)
	if key.is_empty():
		return
	_validate_save_data()
	current_save.scene_node_states[key] = state


func get_scene_node_state(node: Node) -> Dictionary:
	var key := get_scene_node_key(node)
	if key.is_empty():
		return {}
	_validate_save_data()
	var scene_path := get_scene_path_for_node(node)
	if scene_path.is_empty() or not is_scene_completed(scene_path):
		return {}
	var states := current_save.scene_node_states as Dictionary
	return states.get(key, {}) as Dictionary


func set_scene_node_state_value(node: Node, state_key: String, value: Variant) -> void:
	var state := get_scene_node_state(node)
	state[state_key] = value
	set_scene_node_state(node, state)


func get_scene_node_state_value(node: Node, state_key: String, default_value: Variant = null) -> Variant:
	var state := get_scene_node_state(node)
	return state.get(state_key, default_value)


func get_scene_node_key(node: Node) -> String:
	var scene_path := get_scene_path_for_node(node)
	if scene_path.is_empty():
		return ""
	var scene := get_tree().current_scene
	return scene_path + "/" + str(scene.get_path_to(node))


func get_scene_path_for_node(node: Node) -> String:
	var scene := get_tree().current_scene
	if scene == null or scene.scene_file_path.is_empty() or node == null or not scene.is_ancestor_of(node):
		return ""
	return scene.scene_file_path


func mark_current_scene_completed() -> void:
	var scene := get_tree().current_scene
	if scene == null or scene.scene_file_path.is_empty():
		return
	mark_scene_completed(scene.scene_file_path)


func mark_scene_completed(scene_path: String) -> void:
	if scene_path.is_empty():
		return
	_validate_save_data()
	if not current_save.completed_scenes.has(scene_path):
		current_save.completed_scenes.append(scene_path)


func is_scene_completed(scene_path: String) -> bool:
	if scene_path.is_empty():
		return false
	_validate_save_data()
	return current_save.completed_scenes.has(scene_path)


func _validate_save_data() -> void:
	if not current_save.has("persistence"):
		current_save.persistence = []
	if not current_save.has("completed_scenes"):
		current_save.completed_scenes = []
	if not current_save.has("scene_node_states"):
		current_save.scene_node_states = {}
