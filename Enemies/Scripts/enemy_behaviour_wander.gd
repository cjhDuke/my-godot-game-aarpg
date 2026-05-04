@tool
class_name EnemyBehaviourWander
extends Node2D

@export var wander_range : int = 2 : set = _set_wander_range
@export var limit_to_wander_state : bool = true

var enemy : Enemy
var original_position : Vector2


func _ready() -> void:
	_ensure_unique_debug_shape()
	_update_debug_radius()
	if Engine.is_editor_hint():
		return
	
	var p = get_parent()
	if p is Enemy:
		enemy = p as Enemy
		original_position = enemy.global_position
	
	var collision_shape := get_node_or_null("CollisionShape2D")
	if collision_shape:
		collision_shape.queue_free()


func _process(_delta: float) -> void:
	if Engine.is_editor_hint() or enemy == null:
		return
	if limit_to_wander_state and not (enemy.state_machine.current_state is EnemyStateWander):
		return
	
	var offset := enemy.global_position - original_position
	if offset.length() <= wander_range * 32.0:
		return
	if enemy.velocity.dot(offset) <= 0:
		return
	
	enemy.velocity *= -1
	enemy.set_direction(enemy.velocity.normalized())
	
	var current_state := enemy.state_machine.current_state
	if current_state is EnemyStateWander:
		enemy.update_animation(current_state.anim_name)


func reset_origin() -> void:
	if enemy:
		original_position = enemy.global_position


func _set_wander_range(v : int) -> void:
	wander_range = maxi(0, v)
	_ensure_unique_debug_shape()
	_update_debug_radius()


func _ensure_unique_debug_shape() -> void:
	var collision_shape := get_node_or_null("CollisionShape2D")
	if collision_shape == null or collision_shape.shape == null:
		return
	if collision_shape.shape.resource_local_to_scene:
		return
	collision_shape.shape = collision_shape.shape.duplicate()
	collision_shape.shape.resource_local_to_scene = true


func _update_debug_radius() -> void:
	var collision_shape := get_node_or_null("CollisionShape2D")
	if collision_shape and collision_shape.shape:
		collision_shape.shape.radius = wander_range * 32.0
