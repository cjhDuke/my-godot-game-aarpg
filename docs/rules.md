# Godot敌人功能开发rule

## 1. 总体原则

AI Agent 必须遵守以下原则：

1. 优先复用已有系统。
2. 优先选择最小侵入式修改方案。
3. 不允许重构整个项目。
4. 不允许删除已有功能。
5. 不允许引入第三方插件。
6. 不允许创建与现有系统平行的新战斗系统。
7. 不允许为了实现 MageEnemy 而破坏普通 Enemy 的原有逻辑。
8. 新增功能必须服务于 `spec.md` 中定义的目标，不允许随意扩展需求。

## 2.现有资源复用规则

AI必须优先复用现有的资源：

1. 优先复用已有 `Enemy` 基础类或基础场景。
2. 优先复用已有敌人状态机。
3. 优先复用已有巡逻状态。
4. 优先复用已有追击状态和发现玩家逻辑。
5. 优先复用已有攻击状态。
6. 优先复用已有受击状态。
7. 优先复用已有死亡状态。
8. 优先复用已有 HitBox / HurtBox 系统。
9. 优先复用已有 Signal 通信机制。
10. 优先复用已有动画触发方式。
11. 如果已有系统可以实现某功能，不要重新新建一套平行系统。

## 3. 修改范围规则

### 3.1 优先允许新增或修改的范围

优先允许新增：

```
Enemies/MageEnemy
Enemies/MageEnemy/EnemyProjectile
Enemies/EnemyProjectile
Enemies/Scripts
```

谨慎允许修改：

```
Enemies/Scripts
Enemies/Enemy.tscn
Enemies/Enemy.gd
Enemies/StateMachine
```

具体路径以项目真实结构为准。

### 3.2 谨慎修改范围

以下内容只有在必要时才允许小范围修改：

```
HitBox
HurtBox
AnimationPlayer
Enemy StateMachine
Enemy AttackState
Enemy ChaseState
Enemy PatrolState
```

如果需要修改，需要在变更报告中说明：

1. 为什么必须修改。
2. 修改了什么。
3. 是否影响普通 Enemy。
4. 如何验证没有破坏旧逻辑。

### 3.3 禁止修改范围

除非修复必要兼容问题，否则不得修改：

```
Player
GUI
GlobalPlayerManager
GlobalSaveManager
```

如果必须修改上述或者其他未被描述为可修改的文件，AI Agent 必须说明原因，并保证改动最小。

## 4. MageEnemy 实现规则

1. `MageEnemy` 应尽量继承或复用现有 `Enemy`。
2. `MageEnemy` 应尽量复用现有敌人场景结构。
3. `MageEnemy` 不应复制大量重复代码。
4. `MageEnemy` 不应破坏普通 Enemy 的行为。
5. `MageEnemy` 死亡后不允许继续发射 projectile。
6. `MageEnemy` 受击状态下不允许发射 projectile。
7. `MageEnemy` 应具备可配置参数，例如攻击范围、发现范围、冷却时间和仇恨时间。
8. `MageEnemy` 应能在 Godot 编辑器中直接放入场景测试。

## 5. Projectile 实现规则

1. `EnemyProjectile` 必须是独立场景。
2. `EnemyProjectile` 必须使用独立脚本。
3. projectile 发射时必须获得初始方向。
4. projectile 的 `direction` 必须是 normalized 后的方向。
5. projectile 发射后不允许持续追踪玩家。
6. projectile 不应依赖 `MageEnemy` 存活。
7. projectile 不应对发射者造成伤害。
8. projectile 命中玩家后必须销毁。
9. projectile 命中墙体或障碍物后必须销毁。
10. projectile 超过生命周期后必须销毁。
11. projectile 不允许重复造成多次伤害。
12. projectile 速度、伤害和生命周期必须可配置。

## 6. 攻击触发规则

1. `MageEnemy` 进入攻击状态时，不应立即发射 projectile。
2. projectile 应在攻击动画合适帧触发。
3. 如果已有动画关键帧或攻击判定触发点，应优先复用。
4. 如果没有现成触发点，可以使用 AnimationPlayer 方法轨道或短暂延迟实现。
5. 每轮攻击只允许发射一个 projectile。
6. 发射 projectile 后立即进入冷却。
7. 冷却未结束时不允许再次发射。
8. 普通 Enemy 的近战攻击逻辑不应受到影响。

## 7. Player 引用安全规则

1. 获取 Player 节点前需要进行空值检查。
2. 不允许因为 Player 引用为空导致运行时报错。
3. 如果无法获取 Player，则使用敌人当前面朝方向作为默认发射方向。
4. 不允许硬编码脆弱路径，除非项目已有统一路径约定。
5. 优先使用项目已有的玩家查找方式、分组、信号或检测区域。

## 8. Godot 实现规则

1. 新增脚本变量应尽量使用 `@export`，便于在编辑器中调整。
2. 新增节点命名应清晰，例如 `MageEnemy`、`EnemyProjectile`、`ProjectileSpawnPoint`。
3. 不允许保留无用调试节点。
4. 不允许保留无用打印。
5. 不允许保留废弃代码。
6. 不允许出现明显未使用变量。
7. 不允许引入复杂寻路系统。
8. 不允许引入复杂技能系统。
9. 不允许改变现有玩家输入方式。
10. 不允许改变现有 UI。

## 9. AI Agent 执行流程规则

AI Agent 必须按以下阶段执行：

1. 项目分析阶段。
2. 实现方案设计阶段。
3. 功能开发阶段。
4. 测试验证阶段。
5. 问题修复阶段。
6. 最终验收阶段。

每个阶段都必须输出阶段性结果。 

如果处于人工监督模式，则阶段结果需要经用户确认后继续。 

如果处于自动闭环模式，则 AI Agent 可以在满足 rules.md 和 acceptance.md 的前提下自动进入下一阶段。

## 10. 交付物规则

AI Agent 最终需要输出以下文件或内容：

1. `project_analysis.md`
2. `implementation_plan.md`
3. `change_report.md`
4. `test_report.md`
5. `fix_report.md`
6. 最终验收结果

每份报告需要说明：

1. 做了什么。
2. 修改了哪些文件。
3. 为什么这么做。
4. 是否存在风险。
5. 是否通过测试。