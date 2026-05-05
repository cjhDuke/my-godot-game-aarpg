extends Node

const PLAYER = preload("uid://b4sse476kdci4")
const INVENTORY_DATA : InventoryData = preload("uid://blj4h7rnd0fmh")

signal interact_pressed

var player : Player
var player_spawn : bool = false
var is_respawning : bool = false


func _ready() -> void:
	add_player_instance()
	await get_tree().create_timer(0.2).timeout
	player_spawn = true

func add_player_instance() -> void:
	player = PLAYER.instantiate()
	add_child( player )
	pass

func set_health( hp : int, max_hp : int ) -> void:
	player.max_hp = max_hp
	player.hp = hp
	player.update_hp( 0 )
	

func respawn_player_after_death() -> void:
	if is_respawning:
		return
	is_respawning = true
	player_spawn = false
	player.hp = player.max_hp
	player.velocity = Vector2.ZERO
	player.direction = Vector2.ZERO
	player.invulnerable = true
	player.hit_box.monitoring = false
	player.update_hp( 0 )
	await LevelManager.reload_current_level()
	_reset_player_for_respawn()
	is_respawning = false
	pass


func _reset_player_for_respawn() -> void:
	player.hp = player.max_hp
	player.velocity = Vector2.ZERO
	player.direction = Vector2.ZERO
	player.cardinal_direction = Vector2.DOWN
	player.invulnerable = false
	player.is_dead = false
	player.hit_box.monitoring = true
	player.state_machine.reset_to_initial_state()
	player.update_hp( 0 )
	player.update_animation("idle")
	pass



func set_player_position( _new_pos : Vector2 ) -> void:
	player.global_position = _new_pos
	pass


func set_as_parent( _p : Node2D ) -> void:
	if player.get_parent():
		player.get_parent().remove_child( player )
	_p.add_child( player )
	
	
func unparent_player( _p : Node2D ) -> void:
	_p.remove_child( player )
	

func play_audio( _audio : AudioStream ) -> void:
	player.audio.stream = _audio
	player.audio.play()
	pass
