class_name Plant extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$HurtBox.Damaged.connect(take_damage)
	pass # Replace with function body.


func take_damage( _hit_box: HitBox ) -> void:
	queue_free()
	pass
