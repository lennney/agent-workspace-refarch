# Agent Workspace Reference Architecture

> **AI agent 多项目工作空间的上下文工程参考架构。**
> 三层模板 + 生命周期 hooks + 自动校验，让每个新 agent session 都能理解项目全貌。

```bash
# 一键初始化（推荐）
npx create-agent-workspace ./my-workspace svc-a svc-b --hooks --ci

# 或从模板仓库克隆
# Use this repo as a GitHub template → "Use this template"
```

## 解决的问题

| 问题 | 方案 |
|------|------|
| 新 agent session 不知道项目背景 | `AGENTS.md` 分层覆盖（工作区地图 + 项目技术指南） |
| 跨 session 知识丢失 | `HANDOVER.md` 会话日志 + `docs/decisions/` ADR |
| 多项目间找不到依赖关系 | 外层 `AGENTS.md` 项目地图 + CodeGraph/GitNexus 图谱 |
| Agent 不记得更新手账 | `SessionEnd` 自动写 HANDOVER.md |
| 上下文文件过时误导 agent | `agents-lint` 每周校验 + pre-commit hook |

## 三层架构

```
Layer 1: Workspace（工作区）
├── AGENTS.md         ← 项目地图 + 依赖声明
└── shared/           ← 跨项目文档

Layer 2: Per-Project（每个子项目）
├── AGENTS.md         ← 技术栈 + 命令 + 约束
├── HANDOVER.md       ← 会话日志（80 行自动归档）
├── CLAUDE.md → AGENTS.md  ← 兼容 symlink
└── docs/
    ├── index.md          ← 文档导航
    ├── active_plan.md    ← 当前任务拆解
    ├── architecture.md   ← 架构设计
    ├── conventions.md    ← 编码规范
    ├── troubleshooting.md ← 排错手册
    ├── known_issues.md   ← 已知 bug
    ├── decisions/        ← 架构决策（ADR-YYYYMMDD）
    └── history/          ← HANDOVER 归档

Layer 3: Automation（自动化）
├── PreToolUse hook    → 多文件修改前查 CodeGraph 影响范围
├── SessionEnd hook    → 自动写 HANDOVER.md 变更记录
├── pre-commit hook    → commit 前校验
├── GitHub Actions     → 每周 agents-lint 检查
└── handover.sh        → /handover 命令
```

## 快速开始

```bash
# 1. 在工作区初始化
npx create-agent-workspace . project-a project-b --hooks --ci

# 2. 编辑 AGENTS.md（填写项目信息）
vim AGENTS.md
vim project-a/AGENTS.md

# 3. 校验
npx agents-lint --fix

# 4. 开始开发，session 结束时 hooks 自动维护手账
```

## 选型建议

| 场景 | 核心依赖 |
|------|---------|
| 小型单项目 | AGENTS.md + HANDOVER.md 就够了 |
| 多项目工作区 | 加外层 AGENTS.md + shared/ 文档 |
| 需要 agent 理解代码依赖 | 加 CodeGraph 或 GitNexus |
| 团队长期维护 | 加 hooks + agents-lint + CI |
| 跨工具协作 | symlink: CLAUDE.md → AGENTS.md |

## 包含的模板文件

| 文件 | 用途 | 行数上限 |
|------|------|---------|
| 外层 `AGENTS.md` | 项目地图 + 依赖关系 | ≤60 |
| 项目内 `AGENTS.md` | 技术栈 + 命令 + 约束 | ≤150 |
| `HANDOVER.md` | 会话日志 + 变更记录 | 80（自动归档） |
| `docs/decisions/ADR-YYYYMMDD` | 架构决策记录 | 单文件 |
| `docs/active_plan.md` | 当前任务拆解 | 按需 |
| `docs/known_issues.md` | 已知 bug 和临时方案 | 按需 |
| `tools/validate.sh` | 轻量校验 | — |
| `tools/pre-commit.sh` | git commit 自动检查 | — |

## 项目状态

稳定。可用于生产环境。
