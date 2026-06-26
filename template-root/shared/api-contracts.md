# API 契约

> 跨项目 API 接口定义。修改任意接口时必须同步更新本文档和相关项目。

## Service A → Service B

| 方法 | 端点 | 请求 | 响应 | 变更记录 |
|------|------|------|------|---------|
| GET | /users/{id} | — | User{id, name, email} | 2026-01 |
| POST | /users | CreateUserReq | User | 2026-01 |

## Service B → Service C

（待补充）
