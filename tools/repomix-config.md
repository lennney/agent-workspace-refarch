# Repomix 集成指南

> Repomix 把整个仓库打包成一个 AI 友好文件（支持 XML/Markdown）。
> 适合：需要把完整代码喂给 LLM 做一次性分析、code review、文档生成。

## 安装

```bash
npm install -g repomix
# 或直接用 npx
npx repomix
```

## 常用命令

```bash
# 打包当前目录（默认输出 repomix-output.xml）
npx repomix

# 输出 markdown 格式
npx repomix --style markdown --output context.md

# 排除特定目录
npx repomix --ignore "tests/**,node_modules/**"

# 打包多个项目
npx repomix --include "service-a/**,service-b/**" --output full-context.md

# 查看 token 计数
npx repomix --output-include-empty --output-show-token-count
```

## 在 AGENTS.md 中声明

```
## 上下文打包
需要全项目分析时执行：`npx repomix --style markdown --output context.md`
然后将 context.md 直接喂给 LLM。
```

## 最佳实践

1. **每次大改前打包一份**：记录基线，方便对比
2. **用 markdown 格式**：LLM 理解 markdown 比 XML 好
3. **配合 repomix 的 MCP 功能**：让 agent 自动触发打包
4. **HANDOVER.md 记录打包**：`基线打包 @ YYYY-MM-DD，token 计数 XX`

参考：https://github.com/yamadashy/repomix
