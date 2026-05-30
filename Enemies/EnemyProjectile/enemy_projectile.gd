class_name EnemyProjectile extends Area2D

const WALL_COLLISION_MASK: int = 16

@export var direction: Vector2 = Vector2.DOWN
@export var speed: float = 120.0
@export var damage: int = 1
@export var lifetime: float = 2.5

var _has_hit: bool = false

@onready var hit_box: HitBox = $HitBox


func _ready() -> void:
	collision_layer = 0
	collision_mask = WALL_COLLISION_MASK
	monitorable = false
	direction = _normalized_or_fallback(direction)
	if hit_box:
		hit_box.damage = damage
		hit_box.area_entered.connect(_on_hit_box_area_entered)
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	if _has_hit:
		return
	lifetime -= delta
	if lifetime <= 0.0:
		_destroy()
		return
	var next_position := global_position + direction * speed * delta
	if _hits_wall_between(global_position, next_position):
		_destroy()
		return
	global_position = next_position


func configure(
		initial_direction: Vector2,
		initial_speed: float,
		initial_damage: int,
		initial_lifetime: float
) -> void:
	direction = _normalized_or_fallback(initial_direction)
	speed = initial_speed
	damage = initial_damage
	lifetime = initial_lifetime
	if is_node_ready() and hit_box:
		hit_box.damage = damage


func _normalized_or_fallback(value: Vector2) -> Vector2:
	if value == Vector2.ZERO:
		return Vector2.DOWN
	return value.normalized()


func _on_body_entered(_body: Node2D) -> void:
	_destroy()


func _on_hit_box_area_entered(area: Area2D) -> void:
	if area is HurtBox:
		_destroy.call_deferred()


func _hits_wall_between(from_position: Vector2, to_position: Vector2) -> bool:
	if from_position == to_position:
		return false
	var query := PhysicsRayQueryParameters2D.create(
			from_position,
			to_position,
			WALL_COLLISION_MASK
	)
	query.collide_with_areas = false
	query.collide_with_bodies = true
	return not get_world_2d().direct_space_state.intersect_ray(query).is_empty()


func _destroy() -> void:
	if _has_hit:
		return
	_has_hit = true
	if hit_box:
		hit_box.set_deferred("monitoring", false)
	set_deferred("monitoring", false)
	queue_free()
