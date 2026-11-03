---
alwaysApply: false
globs: src/networking/**,Assets/**/Networking/**/*.cs,Assets/**/networking/**/*.cs,Assets/**/Network/**/*.cs,Assets/**/network/**/*.cs,Source/**/Networking/**/*.h,Source/**/Networking/**/*.cpp,Source/**/networking/**/*.h,Source/**/networking/**/*.cpp,Source/**/Network/**/*.h,Source/**/Network/**/*.cpp,Source/**/network/**/*.h,Source/**/network/**/*.cpp
---

# 网络代码规则

- 服务器对所有玩法关键状态具有权威性——绝不要信任客户端
- 所有网络消息必须带版本号，以兼容向前/向后版本
- 客户端本地预测，与服务器对账——为错误预测实现回滚
- 优雅处理断线、重连和主机迁移
- 对所有网络日志做限流，防止日志洪水
- 所有联网数值必须明确复制策略：可靠/不可靠、频率、插值
- 带宽预算：定义并跟踪每种消息类型的带宽占用
- 安全：验证所有传入数据包的大小和字段范围
