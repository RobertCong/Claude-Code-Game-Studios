# Phase 7: 将建议性偏差记录为技术债

仅当用户选择"Close and log the advisory deviations as tech debt"时读取。

在 `/tech-debt` 维护的表中，为每个建议性偏差向 `docs/tech-debt-register.md` 添加一行，以便 `/tech-debt report` 能根据其 `Added` 列标注日期：

```
| TD-[next free NNN] | [category] | [deviation] — from [story path] | [files] | [S/M/L/XL] | [Low/Med/High/Critical] | — | Open | [YYYY-MM-DD] | Backlog |
```

- **ID：** 比文件中已有的最大 TD 编号大 1，三位数字；新文件中为 `TD-001`。
- **Category：** Architecture、Code Quality、Test、Documentation、Dependency、Performance 之一。
- **Effort and Impact：** 你根据该偏差做出的估计。
- **Priority：** `—`，直到 `/tech-debt prioritize` 为其评分。
- **Added：** 今天。

文件以 `## Technical Debt Register` 标题、`Last updated: [date]` 行、`Total items: [N] | Estimated total effort: [sizes summed]` 行和表头开头：

```
| ID | Category | Description | Files | Effort | Impact | Priority | Status | Added | Sprint |
|----|----------|-------------|-------|--------|--------|----------|--------|-------|--------|
```

当文件不存在时，按此方式创建它。当它存在时，更新那两行；如果它没有表头，则先添加表头。
