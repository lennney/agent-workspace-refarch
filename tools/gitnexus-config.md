# GitNexus 集成指南

> GitNexus 是 MCP-native 代码知识图谱引擎（42k ★）。
> 与 CodeGraph 的核心区别：
> - 16 个 MCP tools vs CodeGraph 的 8 个
> - 原生 cross-repo 分组（跨项目依赖分析更深入）
> - LadybugDB 本地图数据库
> - PolyForm Noncommercial 许可证（有商业版）

## 安装

```bash
npx gitnexus
```

## Workspace 配置

```yaml
mcp_servers:
  gitnexus:
    command: npx
    args: ["gitnexus"]
```

## 核心能力

| 能力 | 描述 |
|------|------|
| 依赖图 | imports, calls, extends, implements |
| 影响分析 | 改一个函数影响哪些文件/服务 |
| 变更检测 | 两次 commit 之间的结构 diff |
| 执行流追踪 | 从 API 入口到数据库的完整调用链 |
| 健康评分 | 模块耦合度、圈复杂度 |
| 跨仓库分组 | 多个相关项目作为一个组索引 |

## Cross-Repo 模式（多项目的关键特性）

```yaml
# GitNexus 跨项目配置
projects:
  - path: ./service-a
    name: auth-service
  - path: ./service-b
    name: payment-service
  - path: ./frontend
    name: web-app

groups:
  - name: full-stack
    projects: [auth-service, payment-service, web-app]
```

组内任意项目的查询都会看到跨项目的调用链。

## 选择建议

| 场景 | 推荐 |
|------|------|
| 纯开源、无商业限制 | CodeGraph（MIT） |
| 需要跨项目深入分析 | GitNexus（cross-repo groups） |
| 需要健康评分/复杂度 | GitNexus |
| 需要 WASM 浏览器运行 | GitNexus |

参考：https://github.com/abhigyanpatwari/GitNexus
