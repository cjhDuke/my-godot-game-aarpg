# Implementation Plan

## 1. 方案选择

采用“新增独立 `MageEnemy` 场景”的方案：基于 `Enemies/Goblin/goblin.tscn` 的节点结构新建 `Enemies/MageEnemy/mage_enemy.tscn`，根脚本使用 `MageEnemy extends Enemy`，状态机继续复用现有 Enemy 状态系统。

`EnemyProjectile` 采用独立场景和独立脚本，放在 `Enemies/EnemyProjectile/` 下，作为未来其他敌人也可复用的远程弹体。

## 2. 选择原因

该方案对普通 Enemy 最小侵入：不修改 `Goblin`、`Slime`、现有 `EnemyStateChase`，避免影响近战敌人。

MageEnemy 可以直接复用 Enemy 的血量、方向、动画、HurtBox、受击、死亡、掉落、存档状态逻辑，同时把远程攻击、冷却、仇恨、Projectile 发射隔离在新文件中。

## 3. 新增文件

后续功能开发新增：

- `Enemies/MageEnemy/mage_enemy.tscn`
- `Enemies/MageEnemy/mage_enemy.gd`
- `Enemies/Scripts/states/enemy_state_mage_combat.gd`
- `Enemies/EnemyProjectile/enemy_projectile.tscn`
- `Enemies/EnemyProjectile/enemy_projectile.gd`

本阶段目标文件：

- `outputs/implementation_plan.md`

## 4. 修改文件

后续功能开发仅计划修改：

- `playground.tscn`：加入一个 `MageEnemy` 实例用于演示和验收。
- `outputs/change_report.md`、`outputs/test_report.md`、`outputs/fix_report.md`：后续阶段记录交付。

不修改现有 Enemy 基类、普通 Enemy 场景、HitBox/HurtBox、Player 或全局管理器。若后续 Godot 场景 uid 导致必须调整引用，只允许在新 Mage/Projectile 场景内处理。

## 5. 禁止修改文件

除非发现阻塞性兼容问题并单独说明，否则禁止修改：

- `Player/**`
- `GUI/**`
- `00_Globals/global_player_manager.gd`
- `00_Globals/global_save_manager.gd`
- `GeneralNodes/HitBox/**`
- `GeneralNodes/HurtBox/**`
- `Enemies/Goblin/goblin.tscn`
- `Enemies/Slime/slime.tscn`
- `Enemies/Scripts/states/enemy_state_chase.gd`
- `Enemies/Scripts/states/enemy_state_wander.gd`
- `Enemies/Scripts/states/enemy_state_stun.gd`
- `Enemies/Scripts/states/enemy_state_destroy.gd`

## 6. MageEnemy 实现方案

`MageEnemy` 根节点沿用 `CharacterBody2D + Enemy` 体系，脚本 `mage_enemy.gd` 继承 `Enemy`，新增导出参数：

- `detect_range`
- `attack_range`
- `hate_memory_time`
- `shoot_cooldown`
- `projectile_scene`
- `projectile_spawn_offset`
- `projectile_speed`
- `projectile_damage`
- `projectile_lifetime`

节点结构基于 Goblin：保留 `HurtBox`、`HitBox`、`Sprite2D`、`AnimationPlayer`、`EnemyStateMachine`、`VisionArea`、`DestroyEffectSprite`。保留 `Sprite2D/AttackHitBox` 只为兼容 Goblin 的 `chase_*` 动画轨道，但不让 Mage combat 状态开启它的 `monitoring`。

状态机复用：

- `EnemyStateIdle`：未发现玩家时待机。
- `EnemyStateWander`：未发现玩家时巡逻。
- `EnemyStateStun`：受击后击退和无敌。
- `EnemyStateDestroy`：死亡、掉落、销毁。
- 新增 `EnemyStateMageCombat`：负责发现玩家、追击、攻击范围判断、仇恨倒计时、触发发射。

## 7. EnemyProjectile 实现方案

`EnemyProjectile` 根节点使用 `Area2D`，节点结构：

- `EnemyProjectile` (`Area2D`, script: `enemy_projectile.gd`, collision mask = Walls/16)
- `Sprite2D` 或 `Polygon2D`：简单小球视觉。
- `CollisionShape2D`：用于撞墙检测。
- `HitBox`：实例化 `GeneralNodes/HitBox/hit_box.tscn`，collision mask = `PlayerHurt`/2。
- `HitBox/CollisionShape2D`：与视觉大小一致的圆形判定。

脚本提供初始化方法：接收 `direction`、`speed`、`damage`、`lifetime`。`direction` 在初始化时 normalized；如果传入零向量，使用 `Vector2.DOWN` 兜底。

Projectile 在 `_physics_process(delta)` 中按固定方向移动：`global_position += direction * speed * delta`。发射后不再读取 Player，因此不会持续追踪。

命中玩家：Projectile 监听自身 `HitBox.area_entered`，遇到 `HurtBox` 后关闭 HitBox monitoring 并 `queue_free()`；伤害仍由现有 `HitBox -> HurtBox.take_damage()` 链路处理。

碰墙销毁：根 `Area2D` 监听 `body_entered`，collision mask 只检测 `Walls` layer 16；撞到 TileMap、Plant、Pot、Door、Statue 等墙体/障碍物后销毁。

超时销毁：脚本维护 lifetime 计时，归零后 `queue_free()`。

## 8. 攻击触发方案

`EnemyStateMageCombat` 进入攻击范围且冷却结束后，播放/复用 `chase_down`、`chase_side`、`chase_up` 动画作为攻击动作。

不在进入攻击状态瞬间发射。状态进入攻击小阶段后等待固定 `attack_windup_time = 0.3` 秒，对齐 Goblin `chase_*` 动画中长矛前戳最远的时间点，再调用 `MageEnemy.shoot_projectile_once()`。

每轮攻击使用 `projectile_fired_this_attack` 标记，只允许调用一次发射。状态退出、受击、死亡或新一轮攻击开始时重置该标记。

## 9. 冷却系统方案

`MageEnemy` 维护 `shoot_cooldown_remaining`。每次成功发射后设置为 `shoot_cooldown`。

冷却在 `MageEnemy._process(delta)` 中持续递减，因此即使玩家离开视野或状态回到巡逻，冷却也正常减少。

冷却未归零时，MageEnemy 可以追击、面向玩家或等待，但不能再次发射。冷却归零后不主动发射，必须再次进入合法攻击触发流程。

受击或死亡时不发射：`shoot_projectile_once()` 检查当前状态、`invulnerable`、`hp > 0`、`projectile_scene != null` 和冷却状态。

## 10. 仇恨机制方案

`EnemyStateMageCombat` 复用 `VisionArea` 的 `player_entered/player_exited` 信号。

发现玩家后设置 `has_hate = true`，并把 `hate_timer` 重置为 `hate_memory_time`。能看见玩家时持续刷新 timer。

玩家离开 VisionArea 或短暂离开攻击范围后不立即回巡逻；只要 `hate_timer > 0`，MageEnemy 继续追击或等待攻击机会。

超过 `hate_memory_time` 仍未重新发现玩家，则状态返回 `EnemyStateIdle`，再由现有 `Idle/Wander` 循环恢复巡逻。

## 11. 兼容性保护

普通 Enemy 不受影响的核心保证：

- 不修改 `Enemy.gd`、`EnemyStateChase`、Goblin/Slime 场景。
- 新状态脚本只被 `mage_enemy.tscn` 引用。
- Projectile 使用现有 HitBox/HurtBox，不新增平行伤害系统。
- `AttackHitBox` 在 MageEnemy 中保留但不启用，避免动画轨道丢节点。
- `playground.tscn` 只新增 MageEnemy 实例，不改动已有 Slime/Goblin 配置。

## 12. 测试计划

基础检查：

- 用 Godot 打开项目，确认无脚本加载错误。
- 运行 `playground.tscn`，确认 Player、Slime、Goblin、MageEnemy 都能显示和运行。
- 如本地有 Godot CLI，运行 `godot --headless --path D:\AARPG --quit` 做项目加载检查；若 CLI 不可用，在测试报告标记 BLOCKED 并给出手动验证步骤。

功能验收按 `docs/acceptance.md` 逐项检查：

- MageEnemy 可放入测试场景，视觉上与普通 Enemy 区分。
- 未发现玩家时巡逻，进入发现范围后进入 combat。
- 攻击范围外追击，攻击范围内播放攻击动作。
- 攻击动作 windup 后发射一个 projectile。
- 冷却内不重复发射，冷却结束后可再次发射。
- Projectile 固定方向飞行，不追踪玩家。
- Projectile 命中 Player HurtBox 扣血并销毁。
- Projectile 撞 Walls layer 16 或超时后销毁。
- MageEnemy 可被玩家攻击、受击、死亡，死亡后不再发射。
- 已发射 projectile 不因 MageEnemy 死亡而销毁。
- 普通 Slime/Goblin 的巡逻、追击、攻击、受击、死亡行为不回归。

## 13. 风险与回滚方案

主要风险：

- Projectile 碰撞层配置错误会导致打不到玩家或不撞墙。
- `attack_windup_time` 与动画观感可能需要微调。
- 高速 projectile 可能穿过较薄障碍物；首版用保守速度降低风险。
- `VisionArea` 是方向性视野，不是圆形 detect range；本方案通过调整 VisionArea 碰撞形状和 `attack_range` 距离判断满足首版需求。

回滚方案：

- 删除 `Enemies/MageEnemy/`。
- 删除 `Enemies/EnemyProjectile/`。
- 删除 `Enemies/Scripts/states/enemy_state_mage_combat.gd`。
- 从 `playground.tscn` 移除 MageEnemy 实例。
- 普通 Enemy 文件未改动，因此回滚不会影响 Slime/Goblin 原逻辑。
