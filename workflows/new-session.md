# 工作流：新 Agent 会话启动

> 适用于任何 AI coding agent (Claude Code / Codex / Cursor / Copilot)
> 如果是 Hermes Agent，以下步骤由 AGENTS.md 自动触发。

## 流程

```
Step 1 [5s]   读 workspace/AGENTS.md
  → 知道项目地图、依赖关系、跨项目操作

Step 2 [10s]  切到目标项目目录
  → 自动加载 project/AGENTS.md
  → 知道技术栈、命令、约束、陷阱

Step 3 [15s]  读 HANDOVER.md
  → 知道上次 session 进度、关键决策
  → 知道什么方法试过没用

Step 4 [20s]  查 docs/decisions/（如果涉及架构变更）
  → 理解历史决策原因

Step 5 [30s]  确认 CodeGraph/GitNexus MCP 可用
  → 测试：调用一次健康检查

Step 6       开始工作
```

## 检查清单

每次新 session 确认以下问题：

- [ ] 我在哪个项目？对应的 AGENTS.md 读了？
- [ ] HANDOVER.md 里有什么进行中的任务？
- [ ] 上次 session 有什么关键决策？
- [ ] 这个任务涉及跨项目调用吗？（查 shared/api-contracts.md）
- [ ] CodeGraph/GitNexus 在线吗？
