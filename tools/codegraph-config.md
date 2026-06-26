# CodeGraph 集成指南

> CodeGraph 是本地代码知识图谱引擎（MIT, 47.4k ★）。
> 用 tree-sitter 解析代码，构建符号/调用/类继承图，通过 MCP 暴露给 agent。

## 安装

```bash
npx @colbymchenry/codegraph
# 或全局安装
npm install -g @colbymchenry/codegraph
```

## Workspace 配置

在 `.workspace.yaml` 中声明：

```yaml
mcp_servers:
  codegraph:
    command: npx
    args: ["-y", "@colbymchenry/codegraph"]
```

或在 Hermes 的 `config.yaml` 中：

```yaml
mcpServers:
  codegraph:
    command: npx
    args: ["-y", "@colbymchenry/codegraph"]
```

## 在 AGENTS.md 中声明

在项目 `AGENTS.md` 的"规则"部分加入：

```
## 工具依赖
此项目使用 CodeGraph MCP 提供依赖分析。
涉及多文件修改前先调用 codegraph_affected 查询影响范围。
```

## CodeGraph 的核心能力

| 查询 | 用途 |
|------|------|
| `affected(symbol)` | 改这个会影响到谁（blast radius） |
| `callers(symbol)` | 谁调用这个函数 |
| `callees(symbol)` | 这个函数调用了谁 |
| `dependents(file)` | 哪些文件依赖这个文件 |
| `defines(symbol)` | 这个符号定义在哪里 |
| `search(query)` | 语义搜索 |

## 典型工作流

```
1. 用户要求修改 handleLogin 函数
2. Agent 调用 codegraph.callers("handleLogin")
   → 发现被 3 个路由、1 个中间件调用
3. Agent 调用 codegraph.callees("handleLogin")
   → 调用了 validateUser、generateToken、log
4. Agent 规划修改：改 handleLogin + 检查 3 个调用方
5. 修改后运行测试验证
```

## 跨项目支持

CodeGraph 支持多项目索引。在 `.workspace.yaml` 中配置所有项目路径即可。

参考：https://github.com/colbymchenry/codegraph
