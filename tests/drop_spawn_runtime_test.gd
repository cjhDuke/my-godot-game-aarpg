extends Node

const SLIME_SCENE := preload("res://Enemies/Slime/slime.tscn")
const PICKUP_SCENE := preload("res://Item/item_pickup/item_pickup.tscn")
const WALL_COLLISION_MASK := 16
const RESULT_PATH := "res://tests/drop_spawn_runtime_result.txt"

var _wall: StaticBody2D
var _slime: Enemy
var _drop: ItemPickup


func _ready() -> void:
	_write_result("started")
	_setup_world()
	await get_tree().physics_frame
	_run()


func _setup_world() -> void:
	_wall = StaticBody2D.new()
	_wall.collision_layer = WALL_COLLISION_MASK
	_wall.collision_mask = 0
	var wall_shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(64, 64)
	wall_shape.shape = rectangle
	_wall.add_child(wall_shape)
	add_child(_wall)
	_wall.global_position = Vector2.ZERO
	
	_slime = SLIME_SCENE.instantiate() as Enemy
	add_child(_slime)
	_drop = PICKUP_SCENE.instantiate() as ItemPickup


func _run() -> void:
	var destroy_state := _slime.get_node("EnemyStateMachine/Destroy") as EnemyStateDestroy
	var preferred_position := Vector2.ZERO
	var spawn_position := destroy_state._get_drop_spawn_position(_drop, preferred_position)
	
	if spawn_position == preferred_position:
		_fail("Drop spawn was not moved out of an occupied wall position.")
		return
	
	var drop_shape := _drop.get_node("CollisionShape2D") as CollisionShape2D
	if not _is_position_clear(drop_shape, spawn_position):
		_fail("Resolved drop spawn position still overlaps the wall.")
		return
	
	_write_result("passed: " + str(spawn_position))
	print("Runtime drop spawn test passed: ", spawn_position)
	_cleanup()
	get_tree().quit(0)


func _is_position_clear(collision_shape: CollisionShape2D, position: Vector2) -> bool:
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = collision_shape.shape
	query.transform = Transform2D(collision_shape.rotation, position + collision_shape.position)
	query.collision_mask = WALL_COLLISION_MASK
	query.collide_with_areas = false
	query.collide_with_bodies = true
	return _wall.get_world_2d().direct_space_state.intersect_shape(query, 1).is_empty()


func _fail(message: String) -> void:
	_write_result("failed: " + message)
	push_error(message)
	_cleanup()
	get_tree().quit(1)


func _cleanup() -> void:
	if is_instance_valid(_drop):
		_drop.free()
	if is_instance_valid(_slime):
		_slime.free()
	if is_instance_valid(_wall):
		_wall.free()


func _write_result(value: String) -> void:
	var file := FileAccess.open(RESULT_PATH, FileAccess.WRITE)
	file.store_string(value)
