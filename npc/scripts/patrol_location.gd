@tool
class_name PatrolLocation extends Node2D

signal transform_changed

@export var wait_time: float = 0.0:
	set(v):
		wait_time = v
		_update_wait_time_label()

var target_position: Vector2 = Vector2.ZERO
@onready var sprite_2d: Sprite2D = get_node_or_null("Sprite2D") as Sprite2D
@onready var label_main: Label = get_node_or_null("Sprite2D/Label") as Label
@onready var label_wait: Label = get_node_or_null("Sprite2D/Label2") as Label
@onready var line_2d: Line2D = get_node_or_null("Sprite2D/Line2D") as Line2D


func _enter_tree() -> void:
	set_notify_transform(true)
	
func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		transform_changed.emit()

func _ready() -> void:
	target_position = global_position
	_update_wait_time_label()
	
	if Engine.is_editor_hint():
		return
	
	if sprite_2d:
		sprite_2d.queue_free()
	
	
func update_label(_s: String) -> void:
	if label_main:
		label_main.text = _s
	
func update_line(next_location: Vector2) -> void:
	if line_2d == null:
		return
	if line_2d.points.size() < 2:
		line_2d.points = PackedVector2Array([Vector2.ZERO, next_location - position])
	else:
		line_2d.points[1] = next_location - position


func _update_wait_time_label() -> void:
	if Engine.is_editor_hint() and label_wait:
		label_wait.text = "wait: " + str(snappedf(wait_time, 0.01)) + "s"
