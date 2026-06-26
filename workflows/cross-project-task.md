# 工作流：跨项目任务

> 当任务涉及 2 个以上项目时（如：改后端 API + 更新前端调用）。

## 流程

```
Step 1 [30s]  识别影响范围
  → 任务涉及哪些项目？
  → 外层 AGENTS.md 的项目地图 + 依赖关系
  → shared/api-contracts.md 的接口定义

Step 2 [30s]  读相关项目的 AGENTS.md
  → 每个项目的技术栈和约束不同
  → 注意不兼容的约定

Step 3 [1min]  可选：调用 CodeGraph/GitNexus 跨项目查询
  → "这个 API endpoint 被哪些前端模块调用？"
  → "改这个数据模型影响哪些服务的测试？"

Step 4        按依赖顺序修改
  → 先改被依赖的（如：后端 API），再改依赖方（如：前端）
  → 每个项目独立测试验证

Step 5 [2min]  更新 shared/ 文档
  → api-contracts.md 同步新接口
  → 新增跨项目错误码等

Step 6        各自更新 HANDOVER.md
```

## 典型场景

### 后端改 API + 前端更新
```
工作区：workspace/
task: 把 /users/{id} 改成 /v2/users/{id}

1. 读 shared/api-contracts.md → 当前接口定义
2. 读 service-a/AGENTS.md → 后端改发
3. 读 frontend/AGENTS.md → 前端调用的 API client
4. 改 service-a → 改前端 → 端到端测试
5. 更新 shared/api-contracts.md
6. 更新两个项目的 HANDOVER.md
```

### 共享库更新
```
task: 修改 shared-utils 的类型定义

1. 查哪些项目依赖 shared-utils（外层 AGENTS.md 的依赖表）
2. 改 shared-utils → 各项目适配 → 各项目测试
3. 更新 HANDOVER.md（shared-utils + 受影响项目）
```
