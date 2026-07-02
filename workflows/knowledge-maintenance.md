# 知识维护工作流

这个 workflow 用来让 agent workspace 在多次 session 之后仍然好用。目标不是写更多文档，而是让下一个 agent 不必重新发现同一批上下文。

## 什么写到哪里

| 触发条件 | 动作 | 文件 | 频次 |
|----------|------|------|------|
| 项目定位、首版范围或技术栈变化 | 更新项目规则和权威文档 | `AGENTS.md`、产品/设计/计划文档 | 低频 |
| 近期任务变化 | 更新当前 checklist 和下一步切片 | `docs/active_plan.md` | 每个聚焦切片 |
| 有意义的进展发生 | 追加简明当前状态 | `HANDOVER.md` | 每次较完整 session |
| 出现重复陷阱或长期经验 | 写入经验，必要时提升为规则 | `LEARNINGS.md`、`AGENTS.md` | 按发现 |
| 文档结构变化 | 更新导航表 | `docs/index.md` | 同一轮 |
| 作出架构级决策 | 新增或更新 ADR | `docs/decisions/` | 按需 |
| 跨项目 API 或依赖变化 | 更新共享 workspace 文档 | `shared/api-contracts.md` 或 `shared/architecture-overview.md` | 按需 |

## 知识晋升路径

```
session 观察或临时笔记
    -> HANDOVER.md 记录当前状态
    -> LEARNINGS.md 沉淀长期经验
    -> AGENTS.md 晋升为操作规则
    -> docs/decisions/ 记录架构 trade-off
    -> shared/ 同步跨项目影响
```

## 保持职责分离

- `AGENTS.md` 是操作契约：范围、边界、命令、陷阱、agent 规则。
- `docs/active_plan.md` 是当前工作切片：下一步做什么，以及如何判断完成。
- `HANDOVER.md` 是跨 session 记忆：发生了什么、卡在哪里、下一步是什么。
- `LEARNINGS.md` 是长期记忆：应该跨越当前任务继续有效的经验。
- `docs/index.md` 是地图：每类上下文应该去哪里读。

## 清理规则

- `HANDOVER.md` 保持当前且可扫读；旧记录归档到 `docs/history/`。
- `AGENTS.md` 保持精简；长解释移到 docs 并链接。
- `LEARNINGS.md` 只放长期经验；一次性笔记移走或归档。
- ADR 不删除；决策变化时标记 superseded。
- 新增、移动或废弃文档时，同一轮更新 `docs/index.md`。
