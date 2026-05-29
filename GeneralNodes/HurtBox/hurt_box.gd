class_name HurtBox extends Area2D

signal Damaged(hit_box: HitBox)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func take_damage(hit_box: HitBox) -> void:
	#print( "take_damage: " , damage )
	Damaged.emit(hit_box)
