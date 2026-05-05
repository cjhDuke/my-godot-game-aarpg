class_name EnemyCounter extends Node2D

signal enemies_defeated
var _has_emitted : bool = false

func _ready() -> void:
	child_exiting_tree.connect( _on_enemy_destroyed )
	call_deferred("_check_enemies_defeated")
	pass
	
func _on_enemy_destroyed( e : Node2D ) -> void:
	if e is Enemy:
		if enemy_count() <= 1:
			call_deferred("_check_enemies_defeated")
	pass
	
func enemy_count() -> int:
	var _count : int = 0
	for c in get_children():
		if c is Enemy:
			_count += 1
	return _count


func _check_enemies_defeated() -> void:
	if _has_emitted:
		return
	if enemy_count() > 0:
		return
	_has_emitted = true
	enemies_defeated.emit()
	#print("Enemies Defeated!")
