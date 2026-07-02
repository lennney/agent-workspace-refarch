# 工作流：从真实 Workspace 反哺模板

当一个真实项目 workspace 已经跑出了比参考模板更好的习惯时，使用这个 workflow。产出应该是模板优化，而不是复制某个项目的私有上下文或产品细节。

## 输入

- 真实项目的 `AGENTS.md`
- 真实项目的 `HANDOVER.md`
- 真实项目的 `LEARNINGS.md`
- 真实项目的 `docs/index.md`
- 真实项目的 `docs/active_plan.md`
- 能解释这些实践为什么有效的产品、研究或技术设计文档

## 提炼 Checklist

- [ ] 找出让真实 workspace 更容易恢复工作的重复行为。
- [ ] 区分项目事实和可复用结构。
- [ ] 把具体名称、命令和产品细节改成占位符。
- [ ] 保留 `AGENTS.md`、`HANDOVER.md`、`LEARNINGS.md`、`docs/index.md`、`docs/active_plan.md` 的职责分工。
- [ ] 只有当模板字段解释不清时，才新增或更新 workflow 文档。
- [ ] 示例要足够小，让新项目会主动替换，而不是盲目信任。

## 适合反哺什么

适合：

- 更清晰的阶段或范围段落，能防止产品漂移
- 更好用的 `Always` / `Ask` / `Never` 边界
- 更强的文档导航
- 能记录阻塞、下一步切片和验证方式的 handover 结构
- 能把重复陷阱转成未来规则的 learning 格式
- 能告诉 agent 什么时候更新哪个文件的 workflow

不适合：

- 项目专属 roadmap
- 私有服务名或凭据
- 只适合某台机器的工具选择
- 只在某一次有效、但会拖累小项目的重流程

## Review Questions

- 这能让新 agent 更快恢复工作吗？
- 它减少了重复发现吗？
- 它是在保持产品聚焦，而不是扩大范围吗？
- 小型单项目 workspace 仍然能轻量使用吗？
- 新增指导足够短，能在 session 开始时读完吗？
