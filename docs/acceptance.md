# Godot敌人功能开发acceptance

## 1. 验收说明

本文件用于验证 `MageEnemy` 功能是否完成。

AI Agent 在完成开发后，需要根据本文件逐条检查，并输出 PASS / FAIL / BLOCKED 结果。

- PASS：已验证通过
- FAIL：已验证失败
- BLOCKED：当前无法自动验证，需要说明原因，并给出手动测试方法

如果某一项无法自动验证，需要说明原因，并给出手动测试方法。

## 2. 基础运行验收

- [ ]  项目可以在 Godot 编辑器中正常打开。
- [ ]  主测试场景可以正常运行。
- [ ]  运行过程中没有阻塞性报错。
- [ ]  新增 `MageEnemy` 后，普通 `Enemy` 仍然可以正常运行。
- [ ]  普通 `Enemy` 的巡逻、追击、攻击、受击、死亡逻辑没有被破坏。

## 3. MageEnemy 生成验收

- [ ]  `MageEnemy` 可以被放置到测试场景中。
- [ ]  `MageEnemy` 可以正常显示。
- [ ]  `MageEnemy` 可以通过简单视觉方式和普通 Enemy 区分。
- [ ]  `MageEnemy` 不依赖新增正式美术资源。
- [ ]  `MageEnemy` 的基础参数可以在编辑器中配置。

## 4. MageEnemy 巡逻与追击验收

- [ ]  玩家不在发现范围内时，`MageEnemy` 处于巡逻状态。
- [ ]  玩家进入发现范围后，`MageEnemy` 可以发现玩家。
- [ ]  玩家进入发现范围后，`MageEnemy` 可以进入追击或攻击准备状态。
- [ ]  玩家进入攻击范围后，`MageEnemy` 可以进入攻击状态。
- [ ]  玩家离开范围后，`MageEnemy` 不会立刻异常报错或卡死。

## 5. 攻击与发射验收

- [ ]  `MageEnemy` 可以播放或复用攻击动画。
- [ ]  `MageEnemy` 进入攻击状态时不会立刻无条件发射 projectile。
- [ ]  projectile 在攻击动画合适时机发射。
- [ ]  每次攻击动作只发射一个 projectile。
- [ ]  不会因为动画持续多帧而重复发射多个 projectile。
- [ ]  冷却时间内不会再次发射 projectile。
- [ ]  冷却结束后可以再次攻击并发射 projectile。

## 6. Projectile 移动验收

- [ ]  projectile 可以正常生成。
- [ ]  projectile 生成后成为独立对象。
- [ ]  projectile 按固定方向移动。
- [ ]  projectile 方向为生成瞬间计算出的方向。
- [ ]  projectile 不会在飞行过程中持续追踪玩家。
- [ ]  projectile 速度可以配置。
- [ ]  projectile 生命周期可以配置。

## 7. Projectile 命中验收

- [ ]  projectile 命中玩家 HurtBox 后可以造成伤害。
- [ ]  projectile 命中玩家后会销毁。
- [ ]  projectile 不会对玩家造成重复多次伤害。
- [ ]  projectile 不会对发射者造成伤害。
- [ ]  projectile 命中墙体或障碍物后会销毁。
- [ ]  projectile 飞行超过生命周期后会自动销毁。
- [ ]  projectile 伤害量可以配置。

## 8. 受击与死亡验收

- [ ]  `MageEnemy` 可以被玩家攻击命中。
- [ ]  `MageEnemy` 被攻击后可以正常扣血。
- [ ]  `MageEnemy` 被攻击后可以进入受击状态。
- [ ]  `MageEnemy` 血量归零后可以进入死亡状态。
- [ ]  `MageEnemy` 死亡后可以被销毁或进入已有死亡处理流程。
- [ ]  `MageEnemy` 死亡后不再发射 projectile。
- [ ]  已经发射出去的 projectile 不会因为 `MageEnemy` 死亡而被销毁。

## 9. 仇恨机制验收

- [ ]  `MageEnemy` 发现玩家后进入仇恨状态。
- [ ]  玩家短暂离开攻击范围后，`MageEnemy` 不会立即回到巡逻状态。
- [ ]  在 `hate_memory_time` 内重新发现玩家后，`MageEnemy` 可以继续追击或攻击。
- [ ]  超过 `hate_memory_time` 仍未发现玩家后，`MageEnemy` 可以回到巡逻状态。
- [ ]  `hate_memory_time` 可以在编辑器中配置。

## 10.参数配置验收

- [ ] detect_range 可以在编辑器中配置。
- [ ] attack_range 可以在编辑器中配置。
- [ ] shoot_cooldown 可以在编辑器中配置。
- [ ] hate_memory_time 可以在编辑器中配置。
- [ ] projectile_speed 可以在编辑器中配置。
- [ ] projectile_damage 可以在编辑器中配置。
- [ ] projectile_lifetime 可以在编辑器中配置。

## 11. 最终验收结论

最终验收需要给出以下结论：

```
验收结果：PASS / FAIL

通过项：
1.
2.
3.

失败项：
1.
2.
3.

失败原因：
1.
2.
3.

后续建议：
1.
2.
3.
```