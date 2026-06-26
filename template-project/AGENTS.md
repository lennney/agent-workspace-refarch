# Agent — [项目名]

一句话： [项目做什么]

## 命令

```bash
# 运行
uv run python -m server

# 测试
uv run pytest tests/ -v

# 格式化+检查
uv run ruff format . && uv run ruff check --fix

# 数据库迁移
uv run alembic upgrade head
```

## 技术栈

Python 3.12 / FastAPI 0.115 / SQLAlchemy 2.0 / PostgreSQL 16 / uv

## 约束（按优先级）

1. 所有密钥从 `.env` 读取，禁止硬编码
2. 数据库迁移只能 ADD，不能 DROP/RENAME
3. 测试覆盖率不低于 80%
4. 公共 API 必须带 OpenAPI 描述

## 边界

- ✅ **Always:** 运行测试、更新 HANDOVER.md、修复 lint
- ⚠️ **Ask:** 加依赖、改 schema、改公共 API 签名
- 🚫 **Never:** 硬编码密钥、删除测试、改已有迁移

## 陷阱（症状 → 原因 → 解决）

- 服务 502 → 连接池耗尽 → `pool_size=20`
- 迁移回滚失败 → Alembic DDL 不回滚 → 先备份再迁移

## 按需文档

- 架构: `docs/architecture.md`
- 陷阱: `docs/troubleshooting.md`
- 决策: `docs/decisions/`
