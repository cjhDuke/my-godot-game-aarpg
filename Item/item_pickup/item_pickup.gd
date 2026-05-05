@tool
class_name ItemPickup extends CharacterBody2D

signal picked_up

@export var item_data: ItemData: set = _set_item_data
@export var bounce_damping: float = 0.55
@export var friction: float = 5.0
@export var max_bounces_per_frame: int = 3
@export var collision_safe_margin: float = 4.0
@export var max_scatter_distance: float = 32.0

var _picked_up: bool = false
var _spawn_position: Vector2 = Vector2.INF

@onready var area_2d: Area2D = $Area2D
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var sprite_2d: Sprite2D = $Sprite2D


func _ready() -> void:
	if _spawn_position == Vector2.INF:
		_spawn_position = global_position
	_update_texture()
	if Engine.is_editor_hint():
		return
	area_2d.body_entered.connect(_on_body_entered)
	
func _physics_process(delta: float) -> void:
	var motion := velocity * delta
	for i in max_bounces_per_frame:
		var collision_info := move_and_collide(motion, false, collision_safe_margin, true)
		if collision_info == null:
			break
		var normal := collision_info.get_normal()
		global_position += normal
		velocity = velocity.bounce(normal) * bounce_damping
		motion = collision_info.get_remainder().bounce(normal) * bounce_damping
		if motion.length() < 0.1:
			break
	_keep_near_spawn()
	velocity = velocity.move_toward(Vector2.ZERO, friction * velocity.length() * delta)
	if velocity.length() < 2.0:
		velocity = Vector2.ZERO

func _on_body_entered(b) -> void:
	if _picked_up == true:
		return
	if b is Player:
		collect()
	pass

func collect() -> bool:
	if _picked_up == true or item_data == null:
		return false
	if PlayerManager.INVENTORY_DATA.add_item(item_data) == true:
		_picked_up = true
		item_picked_up()
		return true
	return false
	
func item_picked_up() -> void:
	if area_2d.body_entered.is_connected(_on_body_entered):
		area_2d.body_entered.disconnect(_on_body_entered)
	audio_stream_player_2d.play()
	visible = false
	picked_up.emit()
	await audio_stream_player_2d.finished
	queue_free()
	pass
	

func _set_item_data(value: ItemData) -> void:
	item_data = value
	_update_texture()
	
	
func _update_texture() -> void:
	if item_data and sprite_2d:
		sprite_2d.texture = item_data.texture
	pass


func _keep_near_spawn() -> void:
	if max_scatter_distance <= 0:
		return
	var offset := global_position - _spawn_position
	if offset.length() <= max_scatter_distance:
		return
	var normal := offset.normalized()
	global_position = _spawn_position + normal * max_scatter_distance
	velocity = velocity.bounce(-normal) * bounce_damping


func set_spawn_position(value: Vector2) -> void:
	_spawn_position = value
