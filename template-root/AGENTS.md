# Agent Workspace Instructions

## 项目地图

| 项目 | 目录 | 定位 |
|------|------|------|
| [项目名] | `./rel/path` | [一句话] |

## 依赖关系

```
project-a ← project-b   (API 调用)
project-b ← project-c   (共享数据模型)
```
API 契约: `shared/api-contracts.md`

## 跨项目操作

```bash
# 全部测试
for d in project-*; do (cd $d && npm test); done
```

## 工具

- **CodeGraph MCP** — 多文件修改前提 query 调用链
- **Repomix** — `npx repomix` 打包上下文给 LLM

## 规则

- 子项目独立 AGENTS.md 含技术栈/命令/约束
- 跨项目修改前读所有涉及项目的 AGENTS.md
- 架构决策写 HANDOVER.md + docs/decisions/
