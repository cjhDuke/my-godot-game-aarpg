# Godot 敌人功能开发需求文档：MageEnemy

## 1. 项目背景

本项目是一个基于 Godot 的 2D 像素 ARPG 原型，已有基础的玩家移动、玩家攻击、敌人行为、HitBox / HurtBox、状态机和 Signal 通信机制。

当前项目中已有普通近战敌人，敌人在攻击时会向前方伸出长矛进行戳刺，并通过现有 HitBox / HurtBox 系统完成伤害判定。

本次任务希望在已有敌人系统基础上，新增一种法师型远程敌人 `MageEnemy`，并使用 AI Agent 根据需求文档、开发规则和验收标准，自动完成分析、设计、开发、测试、修复和最终验收流程。

## 2. 目标功能

新增一种法师型远程敌人 `MageEnemy`。

目标功能如下：

1. `MageEnemy` 复用现有敌人美术资源。
2. `MageEnemy` 复用现有敌人基础移动逻辑。
3. `MageEnemy` 复用现有敌人受击逻辑。
4. `MageEnemy` 复用现有敌人死亡逻辑。
5. `MageEnemy` 可以复用原有长矛前戳攻击动作。
6. `MageEnemy` 在攻击动作触发时，额外生成一个小球类型的 `projectile`。
7. `MageEnemy` 在玩家进入一定范围内后，可以从巡逻或追击状态切换到攻击状态。
8. `MageEnemy` 锁定玩家后需要引入仇恨机制，短暂失去目标时不会立即放弃目标。
9. `projectile` 朝玩家方向移动，但发射后不持续跟随玩家。
10. `projectile` 命中玩家后造成伤害。
11. `projectile` 命中玩家、墙体或飞行一定时间后自动销毁。
12. 新增 `MageEnemy` 后，不破坏已有普通近战敌人的行为逻辑。
13. 最终功能可以在 Godot 编辑器中运行和演示。

## 3. 非目标范围

本次任务不要求 AI 完成以下内容：

1. 不重构整个项目。
2. 不重写玩家 `Player` 系统。
3. 不新增或修改背包系统。
4. 不新增或修改物品掉落拾取系统。
5. 不修改存档系统。
6. 不改变玩家现有攻击方式。
7. 不新增正式美术资源。
8. 不新增复杂技能系统。
9. 不新增复杂寻路系统。
10. 不修改 UI。
11. 不重新设计整个战斗系统。
12. 不引入第三方插件。
13. 不把所有敌人逻辑重写成另一套系统。

## 4. 美术资源约束

1. `MageEnemy` 复用现有 `Enemy` 的 Sprite 和 Animation。
2. 可以通过 modulate、scale、节点命名或简单标志区分 `MageEnemy` 和普通敌人。
3. 攻击动画可复用现有 `Enemy` 的长矛向前戳攻击动画。
4. `projectile` 可以使用简单小球、圆形、`Polygon2D`、`ColorRect` 或其他 Godot 基础节点实现。
5. 本阶段仅验证玩法可行性，不追求最终美术表现。
6. 后续正式开发时，可以在不改变核心玩法逻辑的前提下替换法师和 projectile 的美术资源。

## 5. 功能需求拆分

### 5.1 MageEnemy 场景或脚本

`MageEnemy` 可以通过以下两种方案实现，具体方案由 AI Agent 根据项目结构和最小侵入原则判断：

#### 方案一：新增 MageEnemy 场景

复制或继承现有 `Enemy` 场景，新增独立的 `MageEnemy` 场景。

#### 方案二：在现有 Enemy 场景上新增远程攻击能力

在现有敌人结构上扩展远程攻击逻辑，通过参数或脚本区分普通敌人和法师敌人。

优先选择对当前项目改动最小、风险最低、便于演示的方案。

### 5.2 巡逻状态

`MageEnemy` 需要具备巡逻行为。

要求：

1. `MageEnemy` 在未发现玩家时处于巡逻状态。
2. 巡逻行为应与现有普通敌人的巡逻表现保持一致或接近。
3. 巡逻状态不应主动发射 projectile。

### 5.3 追击状态

`MageEnemy` 需要具备追击或接近玩家的行为。

要求：

1. 当玩家进入发现范围后，`MageEnemy` 可以进入追击或攻击准备状态。
2. 如果玩家处于攻击范围外，`MageEnemy` 可以尝试靠近玩家。
3. 如果玩家进入攻击范围，`MageEnemy` 可以进入攻击状态。
4. 如果项目现有敌人没有明确追击状态，也可以采用现有发现玩家后的移动逻辑实现。

### 5.4 攻击触发逻辑

`MageEnemy` 的攻击动作可以复用原有长矛前戳攻击动作。

新增逻辑如下：

1. 当 `MageEnemy` 进入攻击状态时，不应立即发射 projectile。
2. projectile 应在动画合适时机发射，例如长矛向前戳到底时。
3. 如果项目已有动画关键帧、动画事件或攻击触发点，应优先复用。
4. 如果项目没有合适的动画关键帧，可以新建关键帧、调用方法轨道，或使用短暂延迟实现。
5. 每次攻击动作只允许发射一个 projectile。
6. 不允许因为攻击动画持续多帧而重复发射多个 projectile。
7. 攻击结束后，`MageEnemy` 可以继续追击、继续攻击或回到巡逻状态，具体由当前状态机逻辑决定。

### 5.5 EnemyProjectile 基本逻辑

新增 `EnemyProjectile`。

要求：

1. projectile 是独立场景。
2. projectile 使用独立脚本。
3. projectile 生成时获得一个初始方向 `direction`。
4. projectile 按固定速度移动。
5. projectile 命中玩家 HurtBox 后造成伤害。
6. projectile 命中玩家后销毁。
7. projectile 在经过一定时间后未命中任何目标时自动销毁。
8. projectile 碰到墙体或障碍物时销毁。
9. projectile 不应对其发射者造成伤害。
10. projectile 不应反复造成多次伤害。
11. projectile 发射出去后应成为独立对象，不再与发射者绑定。
12. projectile 的速度、伤害、生命周期等参数应可配置。

### 5.6 Projectile 目标方向

发射方向要求：

1. 如果 `MageEnemy` 当前能获取 `Player` 节点，则朝玩家当前所在位置发射。
2. projectile 发射方向只在生成时计算一次。
3. projectile 发射后不应持续追踪玩家。
4. 如果无法安全获取 `Player`，则朝 `MageEnemy` 当前面朝方向发射。
5. 无论是否获取到 `Player`，都不应导致运行时报错。

### 5.7 技能冷却

`MageEnemy` 不应每帧发射 projectile。

要求：

1. `MageEnemy` 需要具备射击冷却时间。
2. 冷却时间内不能再次发射 projectile。
3. 每次成功发射 projectile 后，才进入冷却。
4. 冷却时间归零后，保持可攻击状态，不重复重置。
5. 玩家离开视野范围后，`MageEnemy` 不再发射 projectile，但冷却时间依然正常减少。
6. `MageEnemy` 受击或死亡时不应发射 projectile。
7. 冷却时间应可配置。

### 5.8 受击与死亡

`MageEnemy` 需要支持受击和死亡。

要求：

1. `MageEnemy` 可以被玩家攻击命中。
2. `MageEnemy` 被玩家攻击后可以正常扣血。
3. `MageEnemy` 被攻击后可以进入受击状态。
4. `MageEnemy` 血量归零后可以进入死亡状态。
5. `MageEnemy` 死亡后需要销毁或进入已有死亡处理流程。
6. `MageEnemy` 死亡后不再发射 projectile。
7. 已经生成的 projectile 不因 `MageEnemy` 死亡而销毁。

### 5.9 仇恨机制

`MageEnemy` 需要引入基础仇恨机制。

要求：

1. `MageEnemy` 发现 `Player` 后进入仇恨状态。
2. 玩家短暂离开攻击范围时，`MageEnemy` 不应立即回到巡逻状态。
3. `MageEnemy` 需要保留目标一段时间，记为 `hate_memory_time`。
4. 如果在 `hate_memory_time` 内重新发现玩家，则继续追击或攻击。
5. 如果超过 `hate_memory_time` 仍未发现玩家，则回到巡逻状态。
6. `hate_memory_time` 应可配置。

## 6. 推荐可配置参数

`MageEnemy` 推荐包含以下可配置参数：

1. `detect_range`：发现玩家范围。
2. `attack_range`：攻击范围。
3. `hate_memory_time`：仇恨保留时间。
4. `shoot_cooldown`：射击冷却时间。
5. `projectile_scene`：发射的 projectile 场景。
6. `projectile_spawn_offset`：projectile 生成位置偏移。
7. `projectile_speed`：projectile 移动速度。
8. `projectile_damage`：projectile 伤害。
9. `projectile_lifetime`：projectile 存在时间。

具体参数命名可根据项目现有代码风格调整。
