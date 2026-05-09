#!/bin/bash
# OpenClaw 恢复脚本

echo "🦞 正在从 GitHub 恢复 OpenClaw 数据..."

# 1. 从远程拉取最新代码
git -C /workspace pull origin main

# 2. 恢复配置
if [ -d /workspace/config_backup ]; then
    echo "· 正在恢复配置文件..."
    mkdir -p ~/.openclaw
    cp -r /workspace/config_backup/* ~/.openclaw/ 2>/dev/null || true

    # 特殊处理历史记录
    if [ -f /workspace/config_backup/bash_history.txt ]; then
        cp /workspace/config_backup/bash_history.txt ~/.bash_history
    fi
    echo "✅ 恢复完成！请重启终端或运行 'openclaw gateway restart' 生效。"
else
    echo "⚠️ 仓库中未找到备份数据 (config_backup 目录不存在)。"
fi
