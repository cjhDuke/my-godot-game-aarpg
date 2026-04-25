class_name Plant extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$HitBox.Damaged.connect(take_damage)
	pass # Replace with function body.


func take_damage( _hurt_box: HurtBox ) -> void:
	queue_free()
	pass
