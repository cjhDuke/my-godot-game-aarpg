# Fix Report

## 1. 修复依据

- `docs/spec.md`
- `docs/rules.md`
- `docs/acceptance.md`
- `outputs/test_report.md`
- `outputs/change_report.md`

本阶段只修复 `outputs/test_report.md` 中已记录的 FAIL 项，不新增需求外功能，不重构 Enemy 系统。

## 2. 失败项列表

| 编号 | 失败项 | 修复前现象 |
| ---- | ------ | ---------- |
| A7-5 | projectile 命中墙体或障碍物后会销毁 | 用户人工测试发现 projectile 碰到墙 TileMap 时不会自动销毁。 |
| A2-4 / A3-2 | dungeon 中 y 为负时敌人不显示 | MageEnemy 和普通 Goblin 位于 dungeon 的 y 为负位置时不显示，但功能仍正常；x 为负貌似没有问题。 |

## 3. 根因分析

A7-5 根因：`EnemyProjectile` 只依赖根 `Area2D.body_entered` 来处理墙体销毁。真实 dungeon TileMap 碰撞没有稳定触发该信号；此前自动化测试只是直接调用 `_on_body_entered()`，没有覆盖真实 TileMap 物理路径。

dungeon 显示问题根因：`Level` 根节点启用 `y_sort_enabled = true`。`Tile Maps/grass-01.tscn` 的 TileMap 使用 `z_index = -1`，但 `Tile Maps/dungeon_01.tscn` 没有设置该值，默认为 0。敌人 y 为负时会在 y-sort 下排到整个 dungeon TileMap 后面，因此被 TileMap 覆盖。

## 4. 修复内容

- 在 `EnemyProjectile._physics_process()` 中，移动前用 `PhysicsRayQueryParameters2D` 对 Walls layer 16 做射线检测；若从当前位置到下一帧位置之间命中墙体/TileMap，则立即销毁 projectile。
- 保留原有 `body_entered`、HurtBox 命中、lifetime 销毁、固定方向移动逻辑。
- 为 `Tile Maps/dungeon_01.tscn` 的 `Dungeon01` TileMap 设置 `z_index = -1`，与 grass TileMap 的既有工作配置保持一致。

## 5. 修改文件

- `Enemies/EnemyProjectile/enemy_projectile.gd`
- `Tile Maps/dungeon_01.tscn`
- `outputs/test_report.md`
- `outputs/fix_report.md`

测试期间临时创建并运行了 `outputs/phase5_regression_test.gd` 和 `outputs/phase5_regression_test.tscn`，用于 RED/GREEN 回归验证；测试完成后已移除临时文件。

## 6. 回归测试结果

| 测试项 | 结果 | 说明 |
| ------ | ---- | ---- |
| Phase 5 临时回归测试 RED | PASS | 修复前复现 3 PASS / 2 FAIL，失败项正好对应 A7-5 与 dungeon draw order。 |
| Phase 5 临时回归测试 GREEN | PASS | 修复后扩展回归 11 PASS / 0 FAIL。 |
| Godot headless editor 启动 | PASS | `--headless --editor --path D:\AARPG --quit` 退出码 0。 |
| Godot 项目加载 | PASS | `--headless --path D:\AARPG --quit` 退出码 0。 |
| `playground.tscn` 运行 | PASS | headless 运行 180 帧退出码 0。 |
| `Levels/Dungeon01/02.tscn` 运行 | PASS | headless 运行 180 帧退出码 0。 |

## 7. 剩余问题

- Godot headless 退出阶段仍可能输出 `ObjectDB instances leaked` 或 `resources still in use at exit` 等清理 warning/error；这些日志在本阶段测试中未导致非零退出码，也未阻塞加载、场景运行或回归测试。
- dungeon y 为负显示问题已通过 draw order 配置回归验证，仍建议用户在 GUI 中做一次目视复核。

## 8. 最终修复结论

Phase 5 修复结论：PASS。

`outputs/test_report.md` 中记录的两个 FAIL 项均已完成最小必要修复，并通过自动化回归验证。普通 Enemy、MageEnemy、Projectile 的既有 PASS 行为未发现回归。
