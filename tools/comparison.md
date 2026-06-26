# 工具选型对比

| 维度 | CodeGraph | GitNexus | Serena |
|------|-----------|----------|--------|
| ★ Stars | 47.4k | 42k | 25.2k |
| License | MIT | PolyForm NC（商业版另购） | MIT |
| 语言栈 | TypeScript | TypeScript | TypeScript |
| 数据存储 | 本地 SQLite (FTS5) | LadybugDB（自定义图库） | LSP 服务，无持久化 |
| 核心能力 | 依赖图 + 调用链 | 依赖图 + 执行流追踪 + 健康评分 | 符号检索 + 编辑（LSP 层） |
| MCP tools | 8 个 | 16 个 | 12 个 |
| 跨项目 | 需要多目录配置 | 原生 cross-repo groups | 不支持 |
| 增量同步 | ✅ 文件监听 | ⏳ 路线图中 | N/A（LSP 实时） |
| 独立基准 | 减少 58-70% tool calls | 减少 88% tool calls | N/A |
| 启动速度 | 索引后快 | 索引后快 | 即时（LSP） |
| 浏览器运行 | ❌ | ✅ WASM 模式 | ❌ |

## 怎么选

- **两个都不装也行** — AGENTS.md + HANDOVER.md + ADR 已经解决了 70% 的问题
- **只装一个** → **CodeGraph**（MIT 开源、生态最大）
- **跨项目多且复杂** → **GitNexus**（cross-repo groups 强）
- **只需要符号导航** → **Serena**（LSP 实时，不索引）

## 必备（必装，零成本）

| 工具 | 用途 | 文件 |
|------|------|------|
| **validate.sh** | 校验 AGENTS.md 质量和时效性 | `tools/validate.sh` |
| **hooks** | Claude Code 自动提醒更新 HANDOVER.md | `tools/hooks-guide.md` |

不比知识图谱工具重要，但比知识图谱**更容易被忽略**。默认先配好 validate.sh + hooks。
