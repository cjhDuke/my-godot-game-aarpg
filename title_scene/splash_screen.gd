extends Control

signal finished

@onready var animation_player: AnimationPlayer = $MyLogo/AnimationPlayer

func _ready() -> void:
	animation_player.animation_finished.connect(_on_animation_finished)
	if animation_player.has_animation("splash"):
		animation_player.play("splash")
	else:
		finished.emit()
	
func _on_animation_finished(_name: String) -> void:
	finished.emit()
