class_name MageEnemy extends Enemy

@export_category("Mage Combat")
@export var detect_range: float = 128.0
@export var attack_range: float = 96.0
@export var shoot_cooldown: float = 1.5
@export var hate_memory_time: float = 1.5
@export var projectile_scene: PackedScene = preload("res://Enemies/EnemyProjectile/enemy_projectile.tscn")
@export var projectile_spawn_offset: Vector2 = Vector2(0, 18)
@export var projectile_speed: float = 120.0
@export var projectile_damage: int = 1
@export var projectile_lifetime: float = 2.5

var shoot_cooldown_remaining: float = 0.0


func _ready() -> void:
	super._ready()
	if is_queued_for_deletion():
		return
	_configure_vision_area()


func _process(delta: float) -> void:
	super._process(delta)
	if shoot_cooldown_remaining > 0.0:
		shoot_cooldown_remaining = maxf(0.0, shoot_cooldown_remaining - delta)


func can_shoot() -> bool:
	if _is_defeated:
		return false
	if hp <= 0 or invulnerable:
		return false
	if projectile_scene == null:
		return false
	if shoot_cooldown_remaining > 0.0:
		return false
	if state_machine and (
			state_machine.current_state is EnemyStateStun
			or state_machine.current_state is EnemyStateDestroy
	):
		return false
	return true


func shoot_projectile_once() -> bool:
	if not can_shoot():
		return false

	var projectile := projectile_scene.instantiate() as Node2D
	if projectile == null:
		return false

	var parent := get_parent()
	if parent == null:
		projectile.queue_free()
		return false

	var shoot_direction := get_projectile_direction()
	var enemy_projectile := projectile as EnemyProjectile
	if enemy_projectile:
		enemy_projectile.configure(
				shoot_direction,
				projectile_speed,
				projectile_damage,
				projectile_lifetime
		)
	elif projectile.has_method("configure"):
		projectile.configure(
				shoot_direction,
				projectile_speed,
				projectile_damage,
				projectile_lifetime
		)
	else:
		projectile.set("direction", shoot_direction)
		projectile.set("speed", projectile_speed)
		projectile.set("damage", projectile_damage)
		projectile.set("lifetime", projectile_lifetime)

	parent.add_child(projectile)
	projectile.global_position = get_projectile_spawn_position()
	shoot_cooldown_remaining = shoot_cooldown
	return true


func get_projectile_direction() -> Vector2:
	var current_player: Player = PlayerManager.player
	if current_player == null:
		current_player = player
	if current_player != null and is_instance_valid(current_player):
		var player_direction := global_position.direction_to(current_player.global_position)
		if player_direction != Vector2.ZERO:
			return player_direction.normalized()

	if cardinal_direction != Vector2.ZERO:
		return cardinal_direction.normalized()
	return Vector2.DOWN


func get_projectile_spawn_position() -> Vector2:
	var forward := cardinal_direction
	if forward == Vector2.ZERO:
		forward = Vector2.DOWN
	forward = forward.normalized()
	var side := Vector2(-forward.y, forward.x)
	return global_position + side * projectile_spawn_offset.x + forward * projectile_spawn_offset.y


func _configure_vision_area() -> void:
	var vision_area := get_node_or_null("VisionArea")
	if vision_area == null:
		return
	var collision_shape := vision_area.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision_shape == null or collision_shape.shape == null:
		return
	if not collision_shape.shape.resource_local_to_scene:
		collision_shape.shape = collision_shape.shape.duplicate()
		collision_shape.shape.resource_local_to_scene = true
	if collision_shape.shape is CircleShape2D:
		(collision_shape.shape as CircleShape2D).radius = detect_range
