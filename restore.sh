#!/bin/bash
# OpenClaw 压缩包恢复脚本 (更新版路径)

echo "🦞 正在从 GitHub 恢复 OpenClaw 压缩包..."

WS_PATH=$(pwd)

# 1. 从远程拉取最新代码
git -C $WS_PATH pull origin main

# 2. 检查压缩包
BACKUP_FILE="$WS_PATH/backups/latest_backup.tar.gz"

if [ -f "$BACKUP_FILE" ]; then
    echo "· 正在解压并恢复数据..."
    TEMP_RESTORE="/tmp/openclaw_restore"
    rm -rf $TEMP_RESTORE && mkdir -p $TEMP_RESTORE
    tar -xzf $BACKUP_FILE -C $TEMP_RESTORE

    # 恢复配置
    mkdir -p ~/.openclaw
    cp -r $TEMP_RESTORE/config/* ~/.openclaw/ 2>/dev/null || true

    # 恢复历史记录
    [ -f $TEMP_RESTORE/bash_history.txt ] && cp $TEMP_RESTORE/bash_history.txt ~/.bash_history

    # 恢复记忆和技能 (回到新 workspace)
    mkdir -p $WS_PATH/memory $WS_PATH/skills
    cp -r $TEMP_RESTORE/memory/* $WS_PATH/memory/ 2>/dev/null || true
    cp -r $TEMP_RESTORE/skills/* $WS_PATH/skills/ 2>/dev/null || true

    echo "✅ 全量恢复成功！"
else
    echo "⚠️ 未找到 backups/latest_backup.tar.gz。"
fi
