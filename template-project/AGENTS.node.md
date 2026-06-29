# Agent — [项目名]

一句话： [项目做什么]

## 命令

```bash
# 开发
npm run dev

# 构建
npm run build

# 测试
npm test

# 代码检查
npm run lint
```

## 技术栈

Node.js / TypeScript / 框架按项目定义

## 约束（按优先级）

1. 所有密钥从 `.env` 读取，禁止硬编码
2. 样式按项目 CSS 规范
3. 公共 API 必须带类型定义

## 边界

- ✅ **Always:** 运行测试、更新 HANDOVER.md、修复 lint
- ⚠️ **Ask:** 加依赖、改数据接口、改构建配置
- 🚫 **Never:** 硬编码密钥、提交构建产物

## 陷阱（症状 → 原因 → 解决）

- 构建失败 → 依赖版本冲突 → 检查 `package-lock.json`
- 测试超时 → 网络请求未 mock → 检查测试配置

## 按需文档

- 架构: `docs/architecture.md`
- 陷阱: `docs/troubleshooting.md`
- 决策: `docs/decisions/`
- 踩坑: `LEARNINGS.md`（Agent 自动追加，不需要手动维护）

## Agent 规则

- 每次完成任务后，更新 HANDOVER.md
- 踩到新坑时，运行: `bash hooks/on-lesson.sh "<问题描述>" 踩坑`
- 发现架构洞察时，运行: `bash hooks/on-lesson.sh "<发现>" 发现`
- 把重复出现的坑写入上方"陷阱"段（三段式：症状→原因→解决）