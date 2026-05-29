# Project Analysis

## 1. 项目结构概览

项目是 Godot 4.6 2D ARPG。核心目录包括 `Enemies/`、`Player/`、`GeneralNodes/`、`Levels/`、`Tile Maps/`、`00_Globals/`。

三份文档要求新增 `MageEnemy`，复用现有 Enemy、美术、状态机、HitBox/HurtBox 和信号机制；新增独立 `EnemyProjectile`，并避免破坏普通 Enemy。

## 2. Enemy 现有结构

Enemy 基础脚本是 `Enemies/Scripts/enemy.gd`，类型为 `Enemy extends CharacterBody2D`。

普通敌人场景主要有 `Enemies/Slime/slime.tscn` 和 `Enemies/Goblin/goblin.tscn`。

Goblin 节点结构包含 `HitBox`、`HurtBox`、`ShadowSprite2D`、`Sprite2D`、`Sprite2D/AttackHitBox`、`CollisionShape2D`、`AnimationPlayer`、`EnemyStateMachine`、`AudioStreamPlayer2D`、`DestroyEffectSprite`、`VisionArea`。

Slime 结构类似，但没有 `Chase` 状态、`VisionArea` 和 `AttackHitBox`。

## 3. 状态机分析

`Enemies/Scripts/enemy_state_machine.gd` 初始化所有 `EnemyState` 子节点，第一个状态是初始状态。

状态基类 `Enemies/Scripts/states/enemy_state.gd` 提供 `init/enter/exit/process/physics`。

Goblin 状态配置为 `idle -> Wander -> idle`，同时有信号驱动的 `Chase`、`Stun`、`Destroy`。

`EnemyStateIdle` 停止移动并计时后切到配置的 `after_idle_state`。

`EnemyStateWander` 随机选择四方向移动，计时结束后回到 `next_state`。

`EnemyBehaviourWander` 可作为额外场景挂到敌人下，限制 wander 半径，超出后反向。

## 4. HitBox / HurtBox 分析

`GeneralNodes/HitBox/hit_box.gd` 是 `Area2D`，监听 `area_entered`，遇到 `HurtBox` 调用 `take_damage(self)`。

`GeneralNodes/HurtBox/hurt_box.gd` 发出 `Damaged(hit_box)` 信号。

默认 `HitBox` 碰撞 mask 为 `2`，对应 `PlayerHurt`；默认 `HurtBox` collision layer 为 `256`，对应 `Enemy`。

Player 的 `HurtBox` 覆盖到 layer `2`；Player 攻击 HitBox mask 为 `256`，用于打敌人。

Enemy projectile 应复用 HitBox 伤害链路，mask 保持打 `PlayerHurt`，另用 Area/Body 逻辑检测 Walls。

## 5. 动画触发分析

Player 普通攻击在 `Player/Scripts/states/state_attack.gd` 中播放动画后等待 `0.075s` 开启 `AttackHitBox.monitoring`，动画结束或退出状态时关闭。

Goblin 没有独立攻击状态；`EnemyStateChase` 进入时开启 `Sprite2D/AttackHitBox.monitoring`，退出时关闭。

Goblin 的 `chase_down/side/up` 动画会移动 `Sprite2D/AttackHitBox:position`，形成戳刺效果，但不会按关键帧开关伤害。

MageEnemy 不能一进入攻击就立即发射 projectile，建议新增动画事件或短延迟触发，并用布尔值保证每轮攻击只发射一次。

## 6. Player 获取方式

项目通过 autoload `PlayerManager` 管理 Player。

`PlayerManager` 在 `_ready()` 中实例化 Player，`Level._ready()` 调用 `PlayerManager.set_as_parent(self)` 放入当前关卡。

`Enemy._ready()` 保存 `player = PlayerManager.player`。

`EnemyStateChase` 直接使用 `PlayerManager.player.global_position`，没有空值保护。

MageEnemy 应遵守文档要求：读取 Player 前判空，失败时使用当前朝向作为发射方向。

## 7. 碰撞层与墙体分析

`project.godot` 定义：layer 1 `Player`，layer 2 `PlayerHurt`，layer 3 `PlayerInteract`，layer 5 `Walls`，layer 9 `Enemy`。

`Walls` 的 bit mask 是 `16`。Player 和 Enemy 的 body `collision_mask = 16`。

TileMap 场景如 `Tile Maps/grass-01.tscn`、`Tile Maps/dungeon_01.tscn` 和部分 `Levels/Game/*.tscn` 使用 `physics_layer_0/collision_layer = 16`。

Pot、Plant、door、statue 等障碍物也使用 layer `16`。

`EnemyStateDestroy` 已有 `WALL_COLLISION_MASK = 16`，可作为 projectile 撞墙检测的参考常量。

## 8. 可复用模块

可复用 `Enemy` 基类、`EnemyStateMachine`、`EnemyStateIdle`、`EnemyStateWander`、`EnemyStateStun`、`EnemyStateDestroy`。

可复用 `VisionArea` 的发现玩家信号和随朝向旋转逻辑。

可复用 Goblin 的 Sprite、AnimationPlayer 动画、`AttackHitBox` 位置动画思路。

可复用 `HitBox/HurtBox` 伤害系统、`EnemyCounter` 死亡统计、`DropData` 掉落流程。

`Player/boomerang.tscn` 和 `Player/Scripts/abilities/boomerang.gd` 可参考实例化、方向移动和 HitBox 结构，但不能直接复用返回追踪逻辑。

## 9. 需要新增模块

需要新增 `MageEnemy` 场景，优先基于 Goblin 结构复制/继承并替换少量配置。

需要新增 `EnemyProjectile` 独立场景和脚本，包含方向、速度、伤害、生命周期、命中销毁、撞墙销毁。

需要新增 Mage 专用远程攻击逻辑，建议是新的 `MageAttack` 或 `MageChaseAttack` 状态，而不是改写现有 `EnemyStateChase`。

可新增 `ProjectileSpawnPoint` 节点或脚本内偏移参数。

可新增 Mage 专用动画触发方法，例如 `shoot_projectile()`，由动画方法轨道或受控延迟调用。

## 10. 风险点

现有 Goblin 追击状态同时承担追击和近战攻击，进入 Chase 就开启 AttackHitBox；不适合直接承载 Mage 的冷却和一次性发射要求。

`EnemyStateChase` 对 `PlayerManager.player` 无空值保护，Mage 逻辑必须补足。

Projectile 需要同时处理 HurtBox 命中和 Walls 撞击，不能只依赖现有 HitBox。

碰撞 mask 配错会导致 projectile 打到 Enemy、打不到 Player，或无法撞墙销毁。

动画触发如果放在 `_process` 中，容易一轮攻击生成多个 projectile。

MageEnemy 若继承 Enemy，要确保死亡后不再发射，但已发射 projectile 不依赖 Mage 存活。

不要修改 Player、GUI、GlobalPlayerManager、GlobalSaveManager，除非后续发现必要兼容问题。

## 11. 建议实现路线

优先基于 Goblin 创建 MageEnemy，复用 Enemy 基类、Sprite、AnimationPlayer、HurtBox、状态机、VisionArea。

保留 idle/wander/stun/destroy，新增或替换远程攻击状态，避免修改普通 Enemy 行为。

新增 EnemyProjectile 独立场景，使用 HitBox 对 PlayerHurt 造成伤害，并监听 Walls 撞击与 lifetime。

Mage 攻击进入动画后，在固定触发点调用一次发射方法，发射方向取 Player 当前位置，失败则用 cardinal direction。

最后在测试场景放置 MageEnemy，验证普通 Enemy 未回归、Mage 巡逻/发现/仇恨/冷却/发射/受击/死亡全链路。
