# agents-lint 集成指南

> agents-lint 是 AGENTS.md 的专用校验工具。
> 核心能力：检查路径是否存在、npm scripts 是否有效、框架模式是否过时、跨文件一致性、Claude 记忆文件有效性。
> `npx agents-lint` 零依赖运行。

参考：https://github.com/giacomo/agents-lint

## 安装

```bash
# 无需安装，直接运行
npx agents-lint

# 或安装为 dev 依赖
npm install --save-dev agents-lint
```

## 快速启动

```bash
# 生成初始 AGENTS.md（基于项目检测）
npx agents-lint init

# 校验当前目录所有上下文文件
npx agents-lint

# 交互式修复
npx agents-lint --fix

# CI 用：警告超过 5 条就失败
npx agents-lint --max-warnings 5

# JSON 输出
npx agents-lint --format json
```

## 自定义配置

创建 `.agents-lint.json`：

```json
{
  "requiredSections": ["Architecture", "Deployment"],
  "ignorePatterns": ["./legacy", "node_modules"],
  "severity": {
    "missingPath": "error",
    "missingScript": "warn",
    "staleDependency": "warn"
  }
}
```

## 对比 validate.sh

| 维度 | validate.sh | agents-lint |
|------|------------|-------------|
| 依赖 | bash | Node.js |
| 路径校验 | 无 | ✅ 每个路径都存在？ |
| npm scripts 校验 | 无 | ✅ scripts 有效？ |
| 框架过时检测 | 无 | ✅ Angular/React 等模式过时？ |
| 跨文件一致性 | 无 | ✅ 多文件命令冲突？ |
| Claude 记忆文件 | 无 | ✅ MEMORY.md 链接有效？ |
| Freshness 评分 | 无 | ✅ 0-100 分 |
| 行数检查 | ✅ | ✅ |
| HANDOVER 时效 | ✅ | ❌ |
| 本架构专有检查 | ✅ | ❌ |

**建议：** 两者互补
- agents-lint 做深度校验（路径、脚本、框架）
- validate.sh 做本架构专有检查（HANDOVER 时效、符号链接正确性）
- CI 中两个都跑
