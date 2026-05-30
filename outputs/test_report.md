# Test Report

## 1. 测试环境

- 项目路径：`D:\AARPG`
- Godot CLI 位置：`C:\Users\DukeChen\Desktop\Godot_v4.6.3.exe`
- Godot 版本：`Godot Engine v4.6.3.stable.official.7d41c59c4`
- 备注：桌面上同时存在 `Godot_v4.6.3-stable_win64_console.exe`，但它启动时报错 `Main executable ... not found`，因此本轮使用 `Godot_v4.6.3.exe --headless` 执行测试。
- 测试方式：文档复读、静态检查、Godot headless editor 启动、项目加载、主测试场景运行、临时运行时断言场景。
- 临时测试文件：本轮曾临时创建 `outputs/phase4_runtime_test.gd` 和 `outputs/phase4_runtime_test.tscn`，用于自动化断言；测试完成后已删除。
- 人工测试补充：用户曾手动测试发现 projectile 碰到墙 TileMap 时不会自动销毁；后续新测试又发现 dungeon 中 MageEnemy 和普通 Goblin 位于 y 为负的位置时不会显示，但功能仍可正常实现，x 为负貌似没有问题。
- Phase 5 修复补充：已修复上述两个 FAIL 项，并通过临时 Phase 5 回归测试验证：修复前 3 PASS / 2 FAIL，修复后扩展回归 11 PASS / 0 FAIL。

已执行命令：

- `Godot_v4.6.3.exe --headless --editor --path D:\AARPG --quit`：退出码 0。
- `Godot_v4.6.3.exe --headless --path D:\AARPG --quit`：退出码 0；退出阶段有资源清理 warning/error。
- `Godot_v4.6.3.exe --headless --path D:\AARPG --scene res://playground.tscn --quit-after 180`：退出码 0；退出阶段有资源清理 warning/error。
- 临时运行时断言场景：44 PASS / 0 FAIL；退出阶段仍有 `CanvasItem/ObjectDB/resources still in use` 清理 warning/error。
- Phase 5 临时回归测试：11 PASS / 0 FAIL；退出阶段仍有 `ObjectDB instances leaked` 清理 warning。

## 2. 测试对象

- `Enemies/MageEnemy/mage_enemy.tscn`
- `Enemies/MageEnemy/mage_enemy.gd`
- `Enemies/Scripts/states/enemy_state_mage_combat.gd`
- `Enemies/EnemyProjectile/enemy_projectile.tscn`
- `Enemies/EnemyProjectile/enemy_projectile.gd`
- `playground.tscn`
- 普通 Enemy 回归范围：`Enemies/Goblin/`、`Enemies/Slime/`、既有 Enemy 状态脚本、HitBox/HurtBox 系统

## 3. 测试依据

- `docs/spec.md`
- `docs/rules.md`
- `docs/acceptance.md`
- `outputs/project_analysis.md`
- `outputs/implementation_plan.md`
- `outputs/change_report.md`

## 4. 静态检查结果

| 编号 | 检查项 | 结果 | 说明 |
| ---- | ------ | ---- | ---- |
| S01 | 必读文档存在并已读取 | PASS | 已读取 `docs/spec.md`、`docs/rules.md`、`docs/acceptance.md`、`outputs/project_analysis.md`、`outputs/implementation_plan.md`、`outputs/change_report.md`。 |
| S02 | Godot CLI 定位 | PASS | 已在桌面找到 `C:\Users\DukeChen\Desktop\Godot_v4.6.3.exe` 并成功运行。 |
| S03 | Headless editor 启动 | PASS | `--headless --editor --path D:\AARPG --quit` 退出码 0。 |
| S04 | 项目加载检查 | PASS | `--headless --path D:\AARPG --quit` 退出码 0；有退出清理 warning/error，但未阻塞加载。 |
| S05 | 主场景运行检查 | PASS | `playground.tscn` headless 运行 180 帧退出码 0。 |
| S06 | MageEnemy/Projectile 文件存在 | PASS | 5 个新增功能文件均存在。 |
| S07 | 禁止修改范围检查 | PASS | 未发现本阶段修改 `Player/**`、`GUI/**`、`00_Globals/**`、`GeneralNodes/**`、Goblin/Slime 场景和既有 Enemy 状态脚本。 |
| S08 | MageEnemy 可配置参数 | PASS | 9 个要求参数均以 `@export` 暴露。 |
| S09 | MageEnemy 复用现有资源 | PASS | 复用 Goblin 贴图、Enemy 基类、HurtBox、HitBox、VisionArea、AnimationPlayer、Idle/Wander/Stun/Destroy 状态。 |
| S10 | MageCombat 状态逻辑 | PASS | 包含 VisionArea 信号、仇恨计时、追击/攻击范围判断、windup、冷却门控、单次发射标记。 |
| S11 | EnemyProjectile 场景结构 | PASS | 根节点为 `Area2D`，包含视觉节点、CollisionShape2D、现有 `HitBox` 实例；墙体 mask 为 16，玩家 HurtBox mask 为 2。 |
| S12 | Projectile 固定方向与销毁保护 | PASS | 初始化 direction normalized；固定方向移动；命中 HurtBox、body、lifetime 均会销毁；`_has_hit` 防重复。 |
| S13 | playground MageEnemy 实例 | PASS | `playground.tscn` 已引用并实例化 MageEnemy。 |
| S14 | 自动化运行时断言 | PASS | 临时测试场景完成 44 项断言，结果 44 PASS / 0 FAIL。 |
| S15 | Phase 5 修复回归 | PASS | 临时回归测试覆盖真实 dungeon TileMap 碰撞、projectile 既有移动/命中/lifetime 行为、dungeon TileMap draw order，结果 11 PASS / 0 FAIL。 |

## 5. 功能验收结果

| 编号 | 验收项 | 结果 | 说明 |
| ---- | ------ | ---- | ---- |
| A2-1 | 项目可以在 Godot 编辑器中正常打开 | PASS | headless editor 启动检查退出码 0；未做 GUI 视觉打开确认。 |
| A2-2 | 主测试场景可以正常运行 | PASS | `playground.tscn` headless 运行 180 帧退出码 0。 |
| A2-3 | 运行过程中没有阻塞性报错 | PASS | headless 加载和场景运行均退出码 0；退出阶段存在资源清理 warning/error，未阻塞运行。 |
| A2-4 | 新增 MageEnemy 后普通 Enemy 仍然可以正常运行 | PASS | 已将 dungeon TileMap `z_index` 对齐 grass TileMap 为 `-1`，修复 y-sort 下 y 为负时普通 Goblin 被 TileMap 覆盖的问题；Goblin/Slime 场景可加载、可实例化，dungeon 场景 headless 运行通过。 |
| A2-5 | 普通 Enemy 巡逻、追击、攻击、受击、死亡逻辑没有被破坏 | PASS | 用户已进行人工测试，其余需要人工确认的条目暂未发现问题；普通 Enemy 文件未改动且可实例化。 |
| A3-1 | MageEnemy 可以放入测试场景 | PASS | `playground.tscn` 已包含 MageEnemy 实例，主场景 headless 可运行。 |
| A3-2 | MageEnemy 可以正常显示 | PASS | 已将 dungeon TileMap `z_index` 对齐 grass TileMap 为 `-1`，修复 y-sort 下 y 为负时 MageEnemy 被 TileMap 覆盖的问题；Phase 5 回归验证 draw order 已通过。 |
| A3-3 | MageEnemy 与普通 Enemy 有视觉区分 | PASS | 场景中通过蓝色 `modulate` 与普通 Enemy 区分。 |
| A3-4 | MageEnemy 不依赖新增正式美术资源 | PASS | 复用 Goblin 贴图；Projectile 使用简单内置 Polygon2D。 |
| A3-5 | MageEnemy 基础参数可在编辑器中配置 | PASS | 相关参数均为 `@export`，Godot 加载通过。 |
| A4-1 | 玩家不在发现范围内时 MageEnemy 处于巡逻状态 | PASS | 用户已进行人工测试，除 projectile 碰墙 TileMap 不销毁外，其余人工项暂未发现问题。 |
| A4-2 | 玩家进入发现范围后 MageEnemy 可以发现玩家 | PASS | 运行时断言触发 MageCombat 发现入口后进入 hate 状态；VisionArea 信号连接静态存在。 |
| A4-3 | 玩家进入发现范围后 MageEnemy 可以追击或攻击准备 | PASS | MageCombat 运行逻辑包含追击速度和攻击准备分支，自动化断言覆盖 combat 状态进入。 |
| A4-4 | 玩家进入攻击范围后 MageEnemy 可以进入攻击状态 | PASS | 自动化断言覆盖攻击范围内 windup 流程。 |
| A4-5 | 玩家离开范围后 MageEnemy 不会立刻异常报错或卡死 | PASS | 自动化断言覆盖 player exit、hate timer 消退并返回非仇恨状态；运行无 FAIL。 |
| A5-1 | MageEnemy 可以播放或复用攻击动画 | PASS | 场景包含并复用 `chase_down`、`chase_side`、`chase_up` 动画；项目加载通过。 |
| A5-2 | MageEnemy 进入攻击状态时不会立刻无条件发射 projectile | PASS | 自动化断言确认攻击开始后 0.1 秒未生成 projectile。 |
| A5-3 | projectile 在攻击动画合适时机发射 | PASS | 自动化断言确认 windup 后发射；具体视觉帧观感建议人工复核。 |
| A5-4 | 每次攻击动作只发射一个 projectile | PASS | 自动化断言确认同一攻击流程只新增一个 projectile。 |
| A5-5 | 不会因为动画持续多帧而重复发射多个 projectile | PASS | `projectile_fired_this_attack` 与运行时断言均验证通过。 |
| A5-6 | 冷却时间内不会再次发射 projectile | PASS | 自动化断言确认 cooldown 内第二次发射返回 false，projectile 数量不增加。 |
| A5-7 | 冷却结束后可以再次攻击并发射 projectile | PASS | 静态逻辑确认 cooldown 在 `_process` 递减且归零后 `can_shoot()` 放行；直接完整循环仍建议手动观察。 |
| A6-1 | projectile 可以正常生成 | PASS | 自动化断言确认 MageEnemy 发射后生成 `EnemyProjectile`。 |
| A6-2 | projectile 生成后成为独立对象 | PASS | 自动化断言确认 projectile 父节点是场景父节点，不依附 MageEnemy。 |
| A6-3 | projectile 按固定方向移动 | PASS | 自动化断言确认按 `direction * speed * delta` 位移。 |
| A6-4 | projectile 方向为生成瞬间计算出的方向 | PASS | 自动化断言确认 direction 在生成时归一化并指向当时 Player 位置。 |
| A6-5 | projectile 飞行中不持续追踪玩家 | PASS | 自动化断言移动 Player 后 projectile direction 不变。 |
| A6-6 | projectile 速度可以配置 | PASS | 自动化断言确认 projectile 接收 MageEnemy 配置速度。 |
| A6-7 | projectile 生命周期可以配置 | PASS | 自动化断言确认 projectile 接收 lifetime，且超时销毁。 |
| A7-1 | projectile 命中玩家 HurtBox 后可以造成伤害 | PASS | 自动化断言直接通过现有 HitBox/HurtBox 链路触发 Damaged 信号，并验证 damage 值。 |
| A7-2 | projectile 命中玩家后会销毁 | PASS | 自动化断言确认 HurtBox 命中后 projectile 被释放或排队释放。 |
| A7-3 | projectile 不会对玩家造成重复多次伤害 | PASS | 自动化断言确认 `_has_hit` 命中锁；脚本同时关闭 HitBox monitoring。 |
| A7-4 | projectile 不会对发射者造成伤害 | PASS | HitBox mask 为 PlayerHurt layer 2，Enemy HurtBox layer 为 256；projectile 不保存发射者引用。 |
| A7-5 | projectile 命中墙体或障碍物后会销毁 | PASS | 已在 projectile 移动时增加 Walls layer 16 的物理射线检测；Phase 5 回归验证 projectile 飞向真实 dungeon TileMap wall 后会销毁。 |
| A7-6 | projectile 飞行超过生命周期后会自动销毁 | PASS | 自动化断言确认 lifetime 到期后 queue_free。 |
| A7-7 | projectile 伤害量可以配置 | PASS | 自动化断言确认配置 damage 传入 HitBox。 |
| A8-1 | MageEnemy 可以被玩家攻击命中 | PASS | MageEnemy 保留 HurtBox 并继承 Enemy 受击链路；碰撞层静态匹配现有玩家攻击。 |
| A8-2 | MageEnemy 被攻击后可以正常扣血 | PASS | `MageEnemy extends Enemy`，复用 Enemy `_take_damage` 扣血逻辑。 |
| A8-3 | MageEnemy 被攻击后可以进入受击状态 | PASS | 状态机包含并复用 `EnemyStateStun`，Enemy 受击信号链路未改动。 |
| A8-4 | MageEnemy 血量归零后可以进入死亡状态 | PASS | 状态机包含并复用 `EnemyStateDestroy`，Enemy destroy 信号链路未改动。 |
| A8-5 | MageEnemy 死亡后进入已有死亡处理流程 | PASS | 复用 `EnemyStateDestroy`、DestroyEffectSprite 和 Enemy defeated 标记逻辑。 |
| A8-6 | MageEnemy 死亡后不再发射 projectile | PASS | 自动化断言确认 defeated 后 `shoot_projectile_once()` 返回 false。 |
| A8-7 | 已发射 projectile 不因 MageEnemy 死亡而销毁 | PASS | 自动化断言确认 MageEnemy defeated 后已有 projectile 仍有效。 |
| A9-1 | MageEnemy 发现玩家后进入仇恨状态 | PASS | 自动化断言确认进入 Vision 回调后 `has_hate = true`。 |
| A9-2 | 玩家短暂离开攻击范围后不会立即回巡逻 | PASS | MageCombat 使用 `hate_timer` 保持仇恨；逻辑检查通过。 |
| A9-3 | hate_memory_time 内重新发现玩家后继续追击或攻击 | PASS | MageCombat 看到 target 时刷新 hate timer；静态检查通过。 |
| A9-4 | 超过 hate_memory_time 未重新发现玩家后回到巡逻 | PASS | 自动化断言确认 hate timer 消退后 `has_hate = false`。 |
| A9-5 | hate_memory_time 可以在编辑器中配置 | PASS | `@export var hate_memory_time` 存在，加载通过。 |
| A10-1 | detect_range 可以在编辑器中配置 | PASS | `@export var detect_range` 存在，并同步 VisionArea CircleShape2D 半径。 |
| A10-2 | attack_range 可以在编辑器中配置 | PASS | `@export var attack_range` 存在。 |
| A10-3 | shoot_cooldown 可以在编辑器中配置 | PASS | `@export var shoot_cooldown` 存在。 |
| A10-4 | hate_memory_time 可以在编辑器中配置 | PASS | `@export var hate_memory_time` 存在。 |
| A10-5 | projectile_speed 可以在编辑器中配置 | PASS | `@export var projectile_speed` 存在，并运行时传入 projectile。 |
| A10-6 | projectile_damage 可以在编辑器中配置 | PASS | `@export var projectile_damage` 存在，并运行时传入 projectile。 |
| A10-7 | projectile_lifetime 可以在编辑器中配置 | PASS | `@export var projectile_lifetime` 存在，并运行时传入 projectile。 |

## 6. 失败项汇总

当前没有未修复 FAIL 项。

Phase 5 修复前临时回归：3 PASS / 2 FAIL，复现了 A7-5 与 dungeon y 为负显示问题。

Phase 5 修复后扩展回归：11 PASS / 0 FAIL。

## 7. 阻塞项汇总

当前无 BLOCKED 项。

原 BLOCKED 的 GUI/交互项已由用户人工测试补充确认，除 A7-5 外暂未发现问题。

## 8. 问题复现步骤

已修复问题的复现与验证：

1. 运行 `playground.tscn`。
2. 让 MageEnemy 发射 projectile。
3. 引导 projectile 飞向墙体 TileMap。
4. 修复前结果：projectile 碰到墙 TileMap 后不会自动销毁。
5. 修复后结果：projectile 碰到真实 dungeon TileMap wall 后会销毁。

dungeon 可视问题复现：

1. 运行 dungeon 相关测试场景。
2. 将 MageEnemy 或普通 Goblin 放置或移动到 y 为负的位置。
3. 修复前结果：敌人不显示，但功能仍可正常实现。
4. 修复后验证：dungeon TileMap `z_index = -1`，不再在 y-sort 下覆盖 y 为负的敌人。

仍需注意的非阻塞日志复现：

1. 运行 `C:\Users\DukeChen\Desktop\Godot_v4.6.3.exe --headless --path D:\AARPG --quit`。
2. 或运行 `C:\Users\DukeChen\Desktop\Godot_v4.6.3.exe --headless --path D:\AARPG --scene res://playground.tscn --quit-after 180`。
3. 进程退出码为 0，但退出阶段可能出现 `ObjectDB instances leaked` 和 `resources still in use at exit` 清理 warning/error。

## 9. 可能原因分析

- 资源清理 warning/error 发生在 Godot 退出阶段，当前未阻塞项目加载、主场景运行或 MageEnemy 自动化断言。
- 该日志可能来自项目已有 autoload、场景资源、headless 快速退出流程，或测试期间创建/销毁节点后的 Godot 清理时序。
- A7-5 根因：projectile 仅依赖 Area2D 的 `body_entered` 信号；真实 TileMap 碰撞路径没有稳定触发该信号。自动化旧测试只直接调用了 body collision 回调，因此遗漏真实 TileMap 场景。
- dungeon y 为负显示根因：`Level` 根节点启用 `y_sort_enabled = true`，dungeon TileMap 原本 `z_index = 0`，而 grass TileMap 使用 `z_index = -1`。当敌人 y 为负时，y-sort 会把整个 dungeon TileMap 画在敌人前面，导致敌人被覆盖。

## 10. 修复建议

- A7-5 已修复：projectile 移动前对 Walls layer 16 做 `intersect_ray` 物理查询，命中真实 TileMap/墙体时销毁。
- dungeon y 为负显示问题已修复：`Tile Maps/dungeon_01.tscn` 增加 `z_index = -1`，对齐 grass TileMap 的既有工作配置。
- 若后续阶段要求消除所有 Godot 退出日志，可使用 `--verbose` 单独追踪资源泄漏来源。

## 11. 手动测试步骤

1. 用 Godot GUI 打开 `D:\AARPG`，确认项目可见且无弹窗阻塞。
2. 打开并运行 `playground.tscn`，确认 Player、Slime、Goblin、MageEnemy 均正常显示。
3. 让 Player 远离 MageEnemy，观察 MageEnemy 是否 Idle/Wander 巡逻且不发射 projectile。
4. 让 Player 进入 MageEnemy 发现范围，观察 MageEnemy 是否进入追击或攻击准备。
5. 在攻击范围内停留，确认 MageEnemy 播放攻击动作，并在 windup 后只发射一个 projectile。
6. 保持玩家在攻击范围内，确认 cooldown 内不重复发射，cooldown 后可再次发射。
7. 发射后移动 Player，确认 projectile 不追踪玩家。
8. 让 projectile 命中 Player，确认 Player 扣血且 projectile 销毁。
9. 让 projectile 撞墙、TileMap 或障碍物，确认 projectile 销毁。
10. 让 projectile 不命中任何目标，确认超过 lifetime 后自动销毁。
11. 已修复项：让 projectile 撞墙 TileMap，应观察到 projectile 自动销毁。
12. 已修复项：在 dungeon 中将 MageEnemy 或普通 Goblin 放到 y 为负的位置，应不再被 TileMap 覆盖。
13. 用 Player 攻击 MageEnemy，确认受击、扣血、硬直、死亡和死亡后不再发射。
14. 在 MageEnemy 已发射 projectile 后击杀 MageEnemy，确认已发射 projectile 不会因 MageEnemy 死亡消失。
15. 重复测试 Slime/Goblin 的巡逻、追击、攻击、受击、死亡，确认普通 Enemy 行为未回归。

## 12. 最终结论

Phase 4 第二轮测试已使用桌面 Godot CLI 重新执行。

自动化测试结论：PASS。项目 headless editor 启动、项目加载、`playground.tscn` 运行、MageEnemy/EnemyProjectile 运行时断言均通过；自动化断言结果为 44 PASS / 0 FAIL。

人工测试补充问题已进入 Phase 5 修复流程：A7-5 与 dungeon y 为负显示问题均已完成最小修复，并通过自动化回归验证。

完整验收结论：PASS。当前无 FAIL / BLOCKED 项；保留一个非阻塞注意事项：Godot headless 退出阶段仍可能出现资源清理 warning/error，但退出码为 0，未阻塞加载、运行或本次修复回归。
