# 完整架构手册：AI Agent 多项目工作空间上下文工程

## 问题

AI coding agent 的核心瓶颈不是"能不能写代码"，而是**上下文衰减**：

| 问题 | 表现 |
|------|------|
| **窗口有限** | 无法同时加载整个 codebase |
| **跨会话遗忘** | 新的 session 不知道之前改了什么、为什么改 |
| **多项目隔离** | 项目间的依赖关系对 agent 不可见 |
| **团队脱节** | 不同 agent 工具（Claude Code / Codex / Cursor）读不同的配置格式 |

## 架构设计原则

1. **分层加载** — 没用到的不加载，用到时才按需读取
2. **接口契约** — AGENTS.md 是 agent 与人类的接口，机器可读
3. **知识沉淀** — 每次 session 的产出要能被后续 session 复用
4. **工具无关** — 不绑定某个特定 agent 工具，通用标准

---

## 架构详解

### Layer 1：Workspace 层

负责"项目地图"——agent 新到一个工作区，先知道这里有哪些项目、它们之间怎么依赖。

```
workspace/                          ← 这个目录就是工作区根
├── AGENTS.md                       ← [必选] agent 第一个读的文件
├── .workspace.yaml                 ← [推荐] 工具配置 & MCP 声明
└── shared/                         ← [可选] 跨项目共享上下文
    ├── architecture-overview.md    ← 整体架构图（文字版）
    └── api-contracts.md            ← 跨项目 API 契约
```

#### AGENTS.md（外层）

**目标**：让新 agent 在 5 秒内知道这个工作区有什么、怎么定位。

```
内容定位：
   5%  身份声明 —— 这是什么工作区
  30%  项目地图 —— 列出所有子项目 + 几句话说明定位
  25%  依赖关系 —— 哪个项目依赖哪个、调用关系
  30%  常用任务 —— 跨项目工作的典型操作
  10%  工具声明 —— 使用了哪些外部工具（CodeGraph 等）
```

关键规则：
- **外层 AGENTS.md 不带技术栈细节**（那是子项目的事）
- **外层只做索引和路由**，告诉 agent 该读哪个子项目的 AGENTS.md
- 保持 < 60 行

#### .workspace.yaml

定义该 workspace 的全局工具配置。Agent 启动时自动加载。

```yaml
# MCP 服务声明（给 Hermes / Claude Code / Codex 用）
mcp_servers:
  codegraph:
    command: npx
    args: ["@colbymchenry/codegraph"]
  gitnexus:
    command: npx
    args: ["gitnexus"]

# 工作区包含的项目（用于跨项目图谱索引）
projects:
  - path: ./service-a
    name: auth-service
  - path: ./service-b
    name: payment-service
```

---

### Layer 2：项目层

每个子项目独立维护三份上下文文件。

```
service-a/
├── AGENTS.md                       ← [必选] 技术指南（原地加载）
├── HANDOVER.md                     ← [必选] 会话日志（按需读取）
├── CHANGELOG.md                    ← [推荐] 人类可读变更记录
├── docs/
│   └── decisions/                  ← [推荐] 架构决策记录
│       ├── 000-template.md
│       ├── 001-use-graphql-over-rest.md
│       └── 002-migrate-to-fastapi.md
```

#### AGENTS.md（项目内）

**目标**：让 agent 不带探查就知道怎么在这个项目里干活。

结构：

```markdown
# Agent Instructions — [项目名]

## 一句话概述
[项目定位 + 解决什么问题]

## 技术栈（具体到版本）
- Language: Python 3.12
- Framework: FastAPI 0.115
- ...

## 常用命令（放最前面！）
```bash
# 运行（最常用的一条放第一行）
uv run -- python -m server

# 测试
uv run pytest tests/ -v

# 构建
docker compose build
```

## 关键约束（不可违反）
1. 所有 API key 从 .env 读取
2. 数据库迁移必须向后兼容
3. ...

## 边界（三段式）
- ✅ **Always do:** 写测试、修复 lint 错误、更新 HANDOVER.md
- ⚠️ **Ask first:** 修改数据库 schema、添加新依赖、修改 CI 配置
- 🚫 **Never do:** 硬编码密钥、删除测试文件、绕过 review

## 已知陷阱（三段式：症状→原因→解决）
- **服务偶尔 502**：连接池耗尽 → 设置 pool_size=20

## 按需检索的文档
- 架构设计：`docs/architecture.md`
```

**检查清单：**
- [ ] < 150 行
- [ ] 命令放最前面带版本号
- [ ] 边界三段式
- [ ] 陷阱三段式
- [ ] 无目录树（长目录树是 anti-pattern）

#### HANDOVER.md（会话日志）

**目标**：跨 session 传递"现在进行到哪了"，避免重复发现。

```markdown
# HANDOVER

## 当前目标
[一句话：这阶段在做什么]

## 已完成
- [x] 2026-06-20 实现用户注册 API — 含邮箱验证
- [x] 2026-06-21 添加注册失败的重试逻辑

## 进行中
- [ ] 2026-06-22 添加 OAuth 登录 — Email 集成完成，token 刷新待做

## 待办
- [ ] 添加管理员审核流程

## 关键决策
| 日期 | 决策 | 原因 |
|------|------|------|
| 2026-06-20 | 用 FastAPI 而非 Flask | 原生 async 支持 + 自动 OpenAPI |
| 2026-06-21 | 依赖 CodeGraph MCP | 减少 58% tool calls |

## 已尝试且失败的方法
- ❌ 2026-06-21 Cerbos 做权限 — 过于复杂，退回手写装饰器

## 上次更新
2026-06-22 15:30 CST
```

**五要素检查：**
1. ✅ 改了什么（具体配置、命令、值）
2. ✅ 测了什么（基线数据）
3. ✅ 什么没用（避免重复踩坑）
4. ✅ 关键发现（非显而易见的知识）
5. ✅ 待决事项+选项

#### docs/decisions/（架构决策记录）

ADR 模板（每个决策一个文件）：

```markdown
# ADR-NNN: 标题

## 日期
YYYY-MM-DD

## 上下文
[为什么需要做这个决策？什么约束条件？]

## 选项
- A: [方案简述]
- B: [方案简述]

## 决策
选择 A

## 原因
- 约束条件 1 → A 满足但 B 不满足
- 性能对比：A 快 3x

## 后果
- 正向：...
- 负向：需要迁移旧代码
```

一个 ADR 文件只记录一个决策，方便索引。Agent 在涉及架构变更时先 grep 相关决策。

---

### Layer 3：工具层

#### 知识图谱引擎（推荐二选一）

| 工具 | 安装 | AGENTS.md 声明 |
|------|------|---------------|
| **CodeGraph** | `npx @colbymchenry/codegraph` | `## 工具依赖\n此项目使用 CodeGraph MCP 提供依赖分析。涉及多文件修改前先调用 codegraph_affected。` |
| **GitNexus** | `npx gitnexus` | 同上，改为 gitnexus 的 MCP tools |

Agent 执行流程：
```
1. 接到任务 → 涉及多文件修改？
2. 是 → 调用 codegraph_affected("修改目标") → 获取影响范围
3. 根据影响范围规划修改顺序
4. 修改后运行测试验证
```

#### 上下文打包（给 LLM 一次性分析）

```bash
# 单个项目
npx repomix --style markdown --output context.md

# 整个 workspace（多个项目）
npx repomix --include "service-a/**,service-b/**" --output full-context.md
```

---

### 文件读取优先级

Agent 启动的上下文加载顺序：

```
Step 1: workspace/AGENTS.md
  → 知道有哪些项目、依赖方向
  → 知道使用了哪些工具（CodeGraph 等）
  ↓
Step 2: 进入具体子项目目录
  → 自动加载 project/AGENTS.md
  → 知道技术栈、命令、约束
  ↓
Step 3: 按需读取 HANDOVER.md
  → 知道上次 session 做到了哪里
  → 知道关键决策和失败尝试
  ↓
Step 4: 涉及多文件修改
  → 调用 CodeGraph 查询调用链
  → 确定影响范围
  ↓
Step 5: 涉及架构变更
  → 搜索 docs/decisions/
  → 了解历史决策原因
```

---

### 维护原则

#### 何时更新什么

| 触发 | 动作 |
|------|------|
| 发现新陷阱 | 更新项目 AGENTS.md 的"已知陷阱" |
| 修改技术栈 | 更新项目 AGENTS.md 的"技术栈" |
| 每次 session 结束 | 更新 HANDOVER.md |
| 做出架构决策 | 写 ADR 到 docs/decisions/ |
| 添加/移除子项目 | 更新外层 AGENTS.md 的项目地图 |

#### 红线

外层 AGENTS.md 不超过 60 行 — 超过就该把细节下放到子项目
- **项目 AGENTS.md 不超过 150 行** — 超过就该把长篇技术说明移到 docs/
- **HANDOVER.md 每次 session 更新**，不清零，只追加（已合并 CHANGELOG.功能）
- **ADR 用日期编号 ADR-YYYYMMDD**（避免多项目 NNN 冲突）
- **validate.sh 在 CI 中运行** — 守卫文件质量

---

### 与其他方案的对比

| 维度 | 本方案 | 纯 AGENTS.md | 纯 Graph (CodeGraph) | 纯 RAG (claude-context) |
|------|--------|-------------|---------------------|----------------------|
| 跨会话记忆 | ✅ HANDOVER.md | ❌ 无 | ❌ 无 | ❌ 无 |
| 项目地图 | ✅ 外层 AGENTS.md | ❌ 孤立 | ❌ 无 | ❌ 无 |
| 依赖图谱 | ✅ 可选集成 | ❌ 无 | ✅ 核心 | ❌ 无 |
| 语义搜索 | ✅ 可选集成 | ❌ 无 | ❌ 无 | ✅ 核心 |
| 历史决策 | ✅ ADR | ❌ 无 | ❌ 无 | ❌ 无 |
| 启动零延迟 | ✅ 分层加载 | ✅ | ❌ 需要索引 | ❌ 需要索引 |
| 工具无关 | ✅ AGENTS.md 标准 | ✅ | ✅ MCP | ✅ MCP |
