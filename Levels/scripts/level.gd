class_name Level extends Node2D


@export var music : AudioStream
@export var quest_completion_choice_text: String = "Yes of course!"
@export var quest_completion_choice_text_alt: String = "找到gem"
@export var quest_completion_item: ItemData = preload("uid://cdxl2akpqptbo")
@export var restart_level_path: String = "res://Levels/Game/start_scene.tscn"
@export var congratulations_music: AudioStream = preload("res://Levels/Game/music/congratulations.mp3")

@onready var congratulations: CanvasLayer = get_node_or_null("Congratulations") as CanvasLayer
@onready var restart_button: Button = get_node_or_null("Congratulations/Control/Button_restart") as Button
@onready var congratulations_animation: AnimationPlayer = get_node_or_null("Congratulations/Control/Sprite2D/AnimationPlayer") as AnimationPlayer

var quest_completion_pending: bool = false
var congratulations_audio_player: AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.y_sort_enabled = true
	PlayerManager.set_as_parent( self )
	LevelManager.level_load_started.connect( _free_level )
	AudioManager.play_music( music )
	_setup_congratulations()
	pass # Replace with function body.


func _free_level() -> void:
	PlayerManager.unparent_player( self )
	queue_free()


func _setup_congratulations() -> void:
	if congratulations == null:
		return
	congratulations.visible = false
	congratulations_audio_player = AudioStreamPlayer.new()
	congratulations_audio_player.process_mode = Node.PROCESS_MODE_ALWAYS
	congratulations_audio_player.stream = congratulations_music
	congratulations.add_child(congratulations_audio_player)
	if restart_button and not restart_button.pressed.is_connected(_on_restart_button_pressed):
		restart_button.pressed.connect(_on_restart_button_pressed)
	if not DialogueSystem.choice_selected.is_connected(_on_dialogue_choice_selected):
		DialogueSystem.choice_selected.connect(_on_dialogue_choice_selected)
	if not DialogueSystem.finished.is_connected(_on_dialogue_finished):
		DialogueSystem.finished.connect(_on_dialogue_finished)


func _on_dialogue_choice_selected(dialogue_branch: DialogueBranch) -> void:
	if congratulations == null:
		return
	if dialogue_branch.text != quest_completion_choice_text and dialogue_branch.text != quest_completion_choice_text_alt:
		return
	quest_completion_pending = true


func _on_dialogue_finished() -> void:
	if congratulations == null or not quest_completion_pending:
		return
	quest_completion_pending = false
	if PlayerManager.INVENTORY_DATA.use_item(quest_completion_item):
		_show_congratulations()


func _show_congratulations() -> void:
	_set_game_ui_enabled(false)
	AudioManager.stop_music()
	congratulations.visible = true
	get_tree().paused = true
	if congratulations_audio_player and congratulations_music:
		congratulations_audio_player.play()
	if congratulations_animation and congratulations_animation.has_animation("default"):
		congratulations_animation.play("default")
	if restart_button:
		restart_button.grab_focus.call_deferred()


func _on_restart_button_pressed() -> void:
	if congratulations_audio_player:
		congratulations_audio_player.stop()
	_set_game_ui_enabled(true)
	get_tree().paused = false
	_reset_player_for_restart()
	PlayerManager.player_spawn = false
	LevelManager.load_new_level(restart_level_path, "", Vector2.ZERO)


func _set_game_ui_enabled(enabled: bool) -> void:
	PlayerHud.visible = enabled
	PlayerHud.process_mode = Node.PROCESS_MODE_INHERIT if enabled else Node.PROCESS_MODE_DISABLED
	if enabled:
		PauseMenu.process_mode = Node.PROCESS_MODE_ALWAYS
	else:
		if PauseMenu.is_paused:
			PauseMenu.hide_pause_menu()
		PauseMenu.visible = false
		PauseMenu.process_mode = Node.PROCESS_MODE_DISABLED


func _reset_player_for_restart() -> void:
	PlayerManager.INVENTORY_DATA.clear()
	PlayerManager.player.max_hp = 6
	PlayerManager.player.hp = PlayerManager.player.max_hp
	PlayerManager.player.velocity = Vector2.ZERO
	PlayerManager.player.direction = Vector2.ZERO
	PlayerManager.player.cardinal_direction = Vector2.DOWN
	PlayerManager.player.invulnerable = false
	PlayerManager.player.hurt_box.monitoring = true
	PlayerManager.player.update_hp(0)
	PlayerManager.player.update_animation("idle")
