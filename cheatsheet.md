# 快速参考（一页纸）

## 项目结构（优化版 v2）

```
workspace/
├── AGENTS.md              ← [地图] ≤60 行，项目索引+依赖
├── CLAUDE.md → AGENTS.md  ← [兼容] 符号链接
├── .workspace.yaml        ← [配置] MCP 工具声明
├── shared/                ← [引用] 跨项目文档
├── .github/workflows/
│   └── agents-lint.yml    ← [CI] 每周自动检查

project/
├── AGENTS.md              ← [指南] ≤150 行，命令+约束
├── CLAUDE.md → AGENTS.md  ← [兼容]
├── HANDOVER.md            ← [日志] 变更+会话记录（80 行归档）
├── docs/
│   ├── index.md           ← [导航] 自动生成的文档索引
│   ├── active_plan.md     ← [任务] 当前任务拆解
│   ├── architecture.md    ← [引用] 模块拆解时读
│   ├── conventions.md     ← [引用] 新增文件时读
│   ├── deployment.md      ← [引用] 上线前读
│   ├── troubleshooting.md ← [引用] 报错时搜
│   ├── known_issues.md    ← [引用] 遇到 bug 时查
│   ├── decisions/
│   │   └── ADR-YYYYMMDD   ← [历史] 架构决策
│   └── history/           ← [归档] HANDOVER 旧记录
├── .pre-commit.sh         ← [守卫] commit 前校验
└── .agents-lint.json      ← [守卫] agents-lint 配置
```

## 维护自动化

| 触发 | 动作 | 谁执行 |
|------|------|--------|
| **每次 git commit** | pre-commit hook：校验 AGENTS.md 路径、symlink、HANDOVER 时效 | `tools/pre-commit.sh` |
| **每周一 09:00** | agents-lint：检测过时路径/脚本/框架模式 | GitHub Actions |
| **每 session 结束** | 更新 HANDOVER.md + active_plan.md | 人工/agent |
| **HANDOVER > 80 行** | 旧内容自动归档到 docs/history/YYYY-MM.md | 手动触发 |

## 校验工具

| 工具 | 安装 | 用途 |
|------|------|------|
| `npx agents-lint` | Node（零依赖） | 路径/脚本/框架过时检测，Freshness 评分 |
| `bash tools/validate.sh` | bash | 本架构专有：行数/symlink/HANDOVER 时效 |

## 快速启动

```bash
# Python 项目（默认）
bash setup.sh /path/to/workspace project-a project-b

# Node.js / JS 项目
bash setup.sh /path/to/workspace project-a project-b --type js

# 同时安装 hooks
INSTALL_HOOKS=y bash setup.sh /path/to/workspace project-a --type js

cd /path/to/workspace && ln -sf AGENTS.md CLAUDE.md
npx agents-lint --fix
```
