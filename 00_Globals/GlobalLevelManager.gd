extends Node


signal level_load_started
signal level_loaded
signal TileMapBoundsChanged(bounds: Array[Vector2])

var current_tilemap_bounds: Array[Vector2]
var target_transition: String
var position_offset: Vector2
var is_loading_level: bool = false
var transition_cooldown_ms: int = 300
var _last_level_loaded_ms: int = 0


func _ready() -> void:
	await get_tree().process_frame
	_last_level_loaded_ms = Time.get_ticks_msec()
	level_loaded.emit()


func can_start_transition() -> bool:
	if is_loading_level:
		return false
	return Time.get_ticks_msec() - _last_level_loaded_ms >= transition_cooldown_ms

func change_tilemap_bounds(bounds: Array[Vector2]) -> void:
	current_tilemap_bounds = bounds
	TileMapBoundsChanged.emit(bounds)


func reload_current_level() -> void:
	var current_scene := get_tree().current_scene
	if current_scene == null or current_scene.scene_file_path.is_empty():
		return
	await load_new_level(current_scene.scene_file_path, "", Vector2.ZERO)
	pass


func load_new_level(
		level_path: String,
		_target_transition: String,
		_position_offset: Vector2
) -> void:
	if is_loading_level:
		return
	is_loading_level = true
	
	get_tree().paused = true
	target_transition = _target_transition
	position_offset = _position_offset
	
	await SceneTransition.fade_out()
	
	level_load_started.emit()
	
	await get_tree().process_frame
	
	get_tree().change_scene_to_file(level_path)
	
	await SceneTransition.fade_in()
	
	get_tree().paused = false
	
	await get_tree().process_frame
	
	_last_level_loaded_ms = Time.get_ticks_msec()
	is_loading_level = false
	level_loaded.emit()
	
	pass
