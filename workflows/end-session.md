# 工作流：会话结束维护

> 每次 agent session 结束前，必须完成以下步骤。

## 流程

```
Step 1 [3min]  更新 HANDOVER.md
  → 当前目标：更新
  → 已完成：追加这次做了什么
  → 进行中：记录未完成
  → 关键决策：新增决策表
  → 失败尝试：记录什么没成功

Step 2 [1min]  如有架构决策 → 写 ADR
  → 创建 docs/decisions/NNN-title.md
  → 包含上下文、选项、决策、原因

Step 3 [30s]   如有新陷阱 → 更新 AGENTS.md
  → 添加到"已知陷阱"（三段式）

Step 3b [10s]  如有踩坑/发现 → 运行 on-lesson.sh
  → bash hooks/on-lesson.sh "<问题>" 踩坑
  → LEARNINGS.md 自动追加

Step 4 [30s]   如有跨项目变更 → 更新 shared/ 文档
  → api-contracts.md 或 architecture-overview.md

Step 5 [10s]   标记 HANDOVER.md 的上次更新时间
```

## 检查清单

- [ ] HANDOVER.md 更新了"已完成" + "进行中" + "关键决策"
- [ ] 所有失败尝试已记录（避免下次重蹈覆辙）
- [ ] 架构级决策写了 ADR
- [ ] 新发现的陷阱已写进 AGENTS.md
- [ ] 跨项目 API 变更已同步 shared/ 文档
- [ ] 更新了 HANDOVER.md 的时间戳
