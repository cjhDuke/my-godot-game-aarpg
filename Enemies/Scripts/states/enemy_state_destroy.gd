class_name EnemyStateDestroy extends EnemyState

const PICKUP = preload("res://Item/item_pickup/item_pickup.tscn")
const WALL_COLLISION_MASK : int = 16
const DROP_SPAWN_SEARCH_RADIUS_STEP : float = 8.0
const DROP_SPAWN_SEARCH_STEPS : int = 6
const DROP_SPAWN_SEARCH_DIRECTIONS : Array[Vector2] = [
	Vector2.RIGHT,
	Vector2.DOWN,
	Vector2.LEFT,
	Vector2.UP,
	Vector2(0.70710678, 0.70710678),
	Vector2(-0.70710678, 0.70710678),
	Vector2(-0.70710678, -0.70710678),
	Vector2(0.70710678, -0.70710678),
]

@export var anim_name : String = "destroy"
@export var knockback_speed : float = 200.0
@export var decelerate_speed : float = 10.0

@export_category("AI")

@export_category("Item Drops")
@export var drops : Array[ DropData ]
@export var drop_min_speed : float = 80.0
@export var drop_max_speed : float = 180.0

var _damage_position : Vector2
var _direction : Vector2

func init() ->void:
	enemy.enemy_destroyed.connect( _on_enemy_destroyed )


## What happens when the player enters this State
func enter() -> void:
	enemy.invulnerable = true
	enemy.mark_defeated()
	
	_direction = enemy.global_position.direction_to( _damage_position )
	
	enemy.set_direction( _direction )
	enemy.velocity = _direction * -knockback_speed
	
	enemy.update_animation( anim_name )
	enemy.animation_player.animation_finished.connect( _on_animation_finished )
	disable_hurt_box()
	drop_items()
	pass

## What happens when the player exits this State
func exit() -> void:
	pass
	
## What heppens during the process update in the State
func process(_delta : float) -> EnemyState:
	enemy.velocity -= enemy.velocity * decelerate_speed * _delta
	return null
	
## What happens during the _physics_process update in the State
func physics( _delta : float) -> EnemyState:
	return null

func _on_enemy_destroyed( hit_box : HitBox ) -> void:
	_damage_position = hit_box.global_position
	state_machine.change_state( self )
	

func _on_animation_finished( _a : String ) -> void:
	enemy.queue_free()


func disable_hurt_box() -> void:
	var hit_box : HitBox = enemy.get_node_or_null("HitBox")
	if hit_box:
		hit_box.monitoring = false

func _get_drop_spawn_position(drop: ItemPickup, preferred_position: Vector2) -> Vector2:
	var collision_shape := drop.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision_shape == null or collision_shape.shape == null:
		return preferred_position
	if _is_drop_spawn_position_clear(collision_shape, preferred_position):
		return preferred_position
	for radius_step in DROP_SPAWN_SEARCH_STEPS:
		var radius := float(radius_step + 1) * DROP_SPAWN_SEARCH_RADIUS_STEP
		for search_direction in DROP_SPAWN_SEARCH_DIRECTIONS:
			var candidate_position := preferred_position + search_direction * radius
			if _is_drop_spawn_position_clear(collision_shape, candidate_position):
				return candidate_position
	return preferred_position


func _is_drop_spawn_position_clear(collision_shape: CollisionShape2D, position: Vector2) -> bool:
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = collision_shape.shape
	query.transform = Transform2D(collision_shape.rotation, position + collision_shape.position)
	query.collision_mask = WALL_COLLISION_MASK
	query.collide_with_areas = false
	query.collide_with_bodies = true
	return enemy.get_world_2d().direct_space_state.intersect_shape(query, 1).is_empty()


func drop_items() -> void:
	if drops.size() == 0:
		return 
	for i in drops.size():
		if drops[i] == null or drops[i].item == null:
			continue
		var drop_count : int = drops[i].get_drop_count()
		for j in drop_count:
			var drop : ItemPickup = PICKUP.instantiate() as ItemPickup
			drop.item_data = drops[i].item
			enemy.get_parent().call_deferred( "add_child", drop )
			var spawn_position := _get_drop_spawn_position(drop, enemy.global_position)
			drop.global_position = spawn_position
			drop.set_spawn_position(spawn_position)
			var drop_direction := enemy.velocity.rotated( randf_range( -1.5, 1.5 ) ).normalized()
			if drop_direction == Vector2.ZERO:
				drop_direction = Vector2.RIGHT.rotated( randf_range( 0.0, TAU ) )
			drop.velocity = drop_direction * randf_range( drop_min_speed, drop_max_speed )
