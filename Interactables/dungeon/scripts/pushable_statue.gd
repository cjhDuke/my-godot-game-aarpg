class_name PushableStatue extends RigidBody2D

@export var push_speed : float = 30.0

var push_direction : Vector2 = Vector2.ZERO : set = _set_push

@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D


func _ready() -> void:
	_load_state()


func _physics_process(delta: float) -> void:
	linear_velocity = push_direction * push_speed
	if push_direction != Vector2.ZERO:
		_save_state()
	pass
	
	

func _set_push( value : Vector2 ) -> void:
		push_direction = value
		if push_direction == Vector2.ZERO:
			audio.stop()
			_save_state()
		else:
			audio.play()


func _exit_tree() -> void:
	_save_state()


func _load_state() -> void:
	var state := SaveManager.get_scene_node_state(self)
	if state.is_empty():
		return
	if state.has("pos_x") and state.has("pos_y"):
		global_position = Vector2(float(state.pos_x), float(state.pos_y))
	if state.has("rotation"):
		rotation = float(state.rotation)


func _save_state() -> void:
	SaveManager.set_scene_node_state(self, {
		pos_x = global_position.x,
		pos_y = global_position.y,
		rotation = rotation
	})
