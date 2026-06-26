# 整体架构概述

## 系统架构图（文字版）

```
[前端 App] ←HTTP→ [Gateway] ←gRPC→ [Service A]
                                       ←gRPC→ [Service B] ←SQL→ [PostgreSQL]
                                       ←HTTP→ [External API]
```

## 项目职责

| 项目 | 职责 | 对外暴露 |
|------|------|---------|
| gateway | API 网关、认证、路由 | HTTP REST |
| service-a | 核心业务逻辑 | gRPC |
| service-b | 数据持久化层 | gRPC |

## 跨项目调用流

[写清楚一个完整请求从入口到返回的路径]

## 关键基础设施

- 数据库：PostgreSQL 16（service-b 管理）
- 消息队列：RabbitMQ（service-a 和 service-b 之间）
- 缓存：Redis 7
