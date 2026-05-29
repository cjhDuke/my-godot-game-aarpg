# Change Report

## 1. 本阶段目标

根据 `docs/spec.md`、`docs/rules.md`、`docs/acceptance.md`、`outputs/project_analysis.md` 和 `outputs/implementation_plan.md`，实现独立 `MageEnemy` 远程敌人和独立 `EnemyProjectile`，并确保普通 Enemy 逻辑不被改动。

## 2. 新增文件

- `Enemies/MageEnemy/mage_enemy.tscn`
- `Enemies/MageEnemy/mage_enemy.gd`
- `Enemies/EnemyProjectile/enemy_projectile.tscn`
- `Enemies/EnemyProjectile/enemy_projectile.gd`
- `Enemies/Scripts/states/enemy_state_mage_combat.gd`
- `outputs/change_report.md`

## 3. 修改文件

- `playground.tscn`

仅新增一个 `MageEnemy` 实例用于演示和后续验收，没有修改已有 `Slime`、`Goblin`、`Player`、`GUI` 或全局管理器配置。

## 4. 关键实现说明

`MageEnemy` 使用独立场景和 `MageEnemy extends Enemy` 脚本，保留现有 Enemy 的 `CharacterBody2D`、`HurtBox`、`HitBox`、`Sprite2D`、`AnimationPlayer`、`EnemyStateMachine` 和 `VisionArea` 结构。

`MageEnemy` 提供可配置参数：`detect_range`、`attack_range`、`shoot_cooldown`、`hate_memory_time`、`projectile_scene`、`projectile_spawn_offset`、`projectile_speed`、`projectile_damage`、`projectile_lifetime`。

`EnemyStateMageCombat` 负责发现玩家、追击、攻击范围判断、仇恨倒计时、攻击 windup 和每轮攻击只发射一次 projectile。

`EnemyProjectile` 是独立 `Area2D` 场景。生成时通过 `configure()` 获得初始方向，方向会 normalized；发射后只按固定方向移动，不再读取或追踪 Player。

Projectile 使用现有 `HitBox` 命中 Player `HurtBox` 并造成伤害，命中后关闭判定并销毁；根 `Area2D` 通过 `Walls` layer 16 检测墙体/障碍物并销毁；`lifetime` 归零后自动销毁。

## 5. 与现有系统的复用关系

- 复用 `Enemy` 的血量、方向、动画播放、受击、死亡、存档状态保存逻辑。
- 复用 `EnemyStateMachine`、`EnemyStateIdle`、`EnemyStateWander`、`EnemyStateStun`、`EnemyStateDestroy`。
- 复用 `VisionArea` 的 `player_entered/player_exited` signal。
- 复用 `GeneralNodes/HitBox` 和 `GeneralNodes/HurtBox` 的伤害链路。
- 复用 Goblin 纹理和 `chase_*` 前戳动画思路，但不启用 Mage 的近战 `AttackHitBox` 造成伤害。

## 6. 风险控制

- 未修改普通 Enemy 脚本、普通 Enemy 场景、Player、GUI、GlobalPlayerManager、GlobalSaveManager。
- `EnemyProjectile` 不保存发射者引用，因此已发射 projectile 不依赖 MageEnemy 存活。
- `MageEnemy.shoot_projectile_once()` 在死亡、受击无敌、冷却中、缺失 projectile scene 或 Player 引用为空时都会安全退出或使用当前朝向兜底。
- `EnemyStateMageCombat` 使用 `projectile_fired_this_attack` 防止一轮攻击生成多个 projectile。
- Projectile 命中后设置 `_has_hit` 并关闭 monitoring，避免重复伤害。

## 7. 自检结果

- 已确认新增 5 个功能文件存在。
- 已确认 `MageEnemy` 9 个可配置参数均存在。
- 已确认 `EnemyProjectile` 包含方向归一化、固定方向移动、HitBox 伤害、撞墙销毁和 lifetime 销毁逻辑。
- 已确认 `EnemyProjectile` 脚本不读取 `PlayerManager` 或 Player 引用，发射后不会持续追踪 Player。
- 已确认 `playground.tscn` 已新增 `MageEnemy` 实例。
- 已确认本阶段没有修改 Player、GUI、GlobalPlayerManager、GlobalSaveManager、普通 Enemy 场景或普通 Enemy 状态脚本。

## 8. 已知问题

当前环境 PATH 中未找到 `godot` 或 `godot4` CLI，因此尚未执行 Godot 引擎级场景加载验证。后续 Phase 4 需要在 Godot 编辑器或可用 Godot CLI 中运行 `playground.tscn`，并按 `docs/acceptance.md` 做逐项验收。
