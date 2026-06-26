# 知识维护工作流

## 什么时候做什么

| 触发条件 | 动作 | 文件 | 频次 |
|----------|------|------|------|
| 发现代码依赖关系 | 外层 AGENTS.md 更新依赖表 | `template-root/AGENTS.md` | 低频 |
| 发现新技术陷阱 | 子项目 AGENTS.md 追加"已知陷阱" | `template-project/AGENTS.md` | 按需 |
| 技术栈变更 | 子项目 AGENTS.md 更新"技术栈" | `template-project/AGENTS.md` | 低频 |
| 每次 session 结束 | 更新"已完成/进行中/决策" | `template-project/HANDOVER.md` | 每次 |
| 架构级决策 | 写 ADR 文件 | `docs/decisions/NNN-title.md` | 按需 |
| 跨项目接口变更 | 更新契约文档 | `shared/api-contracts.md` | 按需 |
| 跨项目架构调整 | 更新架构总览 | `shared/architecture-overview.md` | 低频 |

## 知识晋升路径

```
临时笔记 / session 发现
    ↓ （有价值且稳定）
HANDOVER.md 的关键决策
    ↓ （架构级且永久）
docs/decisions/ ADR
    ↓ （影响多项目）
shared/ 文档
```

## 清理规则

- HANDOVER.md **只追加不清零** — 历史即上下文
- AGENTS.md 的"已知陷阱" 超过 10 条 → 按重要度排序，移走不常见的到 `docs/troubleshooting.md`
- ADR 永不删除，只标记 superseded
- shared/ 文档变化慢 → 每次跨项目改动时同步即可
