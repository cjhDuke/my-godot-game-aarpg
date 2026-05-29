class_name EnemyStateMageCombat extends EnemyState

@export var anim_name: String = "chase"
@export var chase_speed: float = 36.0
@export var turn_rate: float = 0.25
@export var attack_windup_time: float = 0.3
@export var attack_recover_time: float = 0.35

@export_category("AI")
@export var vision_area: VisionArea
@export var next_state: EnemyState

var mage_enemy: MageEnemy
var has_hate: bool = false
var projectile_fired_this_attack: bool = false

var _can_see_player: bool = false
var _hate_timer: float = 0.0
var _direction: Vector2 = Vector2.ZERO
var _is_attacking: bool = false
var _attack_timer: float = 0.0
var _recover_timer: float = 0.0


func init() -> void:
	mage_enemy = enemy as MageEnemy
	if vision_area:
		vision_area.player_entered.connect(_on_player_enter)
		vision_area.player_exited.connect(_on_player_exit)


func enter() -> void:
	if mage_enemy == null:
		return
	projectile_fired_this_attack = false
	_is_attacking = false
	_disable_attack_hit_box()
	enemy.update_animation(anim_name)


func exit() -> void:
	projectile_fired_this_attack = false
	_is_attacking = false
	_disable_attack_hit_box()


func process(delta: float) -> EnemyState:
	if mage_enemy == null:
		return next_state

	var target := _get_player()
	_update_hate(delta, target)
	if not has_hate:
		enemy.velocity = Vector2.ZERO
		return next_state

	if target == null:
		enemy.velocity = Vector2.ZERO
		return null

	var to_player := target.global_position - enemy.global_position
	var distance_to_player := to_player.length()
	var target_direction := to_player.normalized() if distance_to_player > 0.0 else enemy.cardinal_direction
	_update_direction(target_direction)

	var target_visible := _target_in_detect_range(target)
	if target_visible and distance_to_player <= mage_enemy.attack_range:
		enemy.velocity = Vector2.ZERO
		if mage_enemy.can_shoot():
			_process_attack(delta)
		else:
			_reset_attack()
		return null

	_reset_attack()
	enemy.velocity = _direction * chase_speed
	return null


func physics(_delta: float) -> EnemyState:
	return null


func _get_player() -> Player:
	var current_player: Player = PlayerManager.player
	if current_player != null and is_instance_valid(current_player):
		return current_player
	if enemy.player != null and is_instance_valid(enemy.player):
		return enemy.player
	return null


func _update_hate(delta: float, target: Player) -> void:
	if target != null and (_can_see_player or _target_in_detect_range(target)):
		has_hate = true
		_hate_timer = mage_enemy.hate_memory_time
		return

	if not has_hate:
		return

	_hate_timer -= delta
	if _hate_timer <= 0.0:
		has_hate = false
		_can_see_player = false
		_reset_attack()


func _target_in_detect_range(target: Player) -> bool:
	if target == null:
		return false
	return enemy.global_position.distance_to(target.global_position) <= mage_enemy.detect_range


func _update_direction(target_direction: Vector2) -> void:
	if target_direction == Vector2.ZERO:
		return
	if _direction == Vector2.ZERO:
		_direction = target_direction
	else:
		_direction = _direction.lerp(target_direction, turn_rate).normalized()
	if enemy.set_direction(_direction):
		enemy.update_animation(anim_name)


func _process_attack(delta: float) -> void:
	if not _is_attacking:
		_is_attacking = true
		projectile_fired_this_attack = false
		_attack_timer = attack_windup_time
		_recover_timer = attack_recover_time
		enemy.update_animation(anim_name)
		return

	if not projectile_fired_this_attack:
		_attack_timer -= delta
		if _attack_timer <= 0.0:
			projectile_fired_this_attack = true
			mage_enemy.shoot_projectile_once()
		return

	_recover_timer -= delta
	if _recover_timer <= 0.0:
		_reset_attack()


func _reset_attack() -> void:
	projectile_fired_this_attack = false
	_is_attacking = false
	_attack_timer = 0.0
	_recover_timer = 0.0


func _disable_attack_hit_box() -> void:
	var attack_hit_box := enemy.get_node_or_null("Sprite2D/AttackHitBox") as HitBox
	if attack_hit_box:
		attack_hit_box.monitoring = false


func _on_player_enter() -> void:
	_can_see_player = true
	has_hate = true
	if mage_enemy:
		_hate_timer = mage_enemy.hate_memory_time
	if (
			state_machine.current_state is EnemyStateStun
			or state_machine.current_state is EnemyStateDestroy
	):
		return
	state_machine.change_state(self)


func _on_player_exit() -> void:
	_can_see_player = false
