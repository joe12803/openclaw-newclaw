#!/bin/bash
# OpenClaw 压缩全量备份脚本 (更新版路径)

echo "🦞 正在打包并备份 OpenClaw 数据..."

# 自动获取当前工作目录 (应为 /root/.openclaw/workspace)
WS_PATH=$(pwd)

# 1. 准备临时打包目录
TEMP_DIR="/tmp/openclaw_sync"
rm -rf $TEMP_DIR && mkdir -p $TEMP_DIR/config $TEMP_DIR/memory $TEMP_DIR/skills

# 2. 拷贝数据到临时目录 (包含隐藏文件)
cp -rL ~/.openclaw/. $TEMP_DIR/config/ 2>/dev/null || true
cp ~/.bash_history $TEMP_DIR/bash_history.txt 2>/dev/null || true
# 移除备份中不小心包含的 workspace 递归
rm -rf $TEMP_DIR/config/workspace 2>/dev/null || true

# 3. 创建压缩包
mkdir -p $WS_PATH/backups
tar -czf $WS_PATH/backups/openclaw_full_$(date +%Y%m%d).tar.gz -C $TEMP_DIR .
cp $WS_PATH/backups/openclaw_full_$(date +%Y%m%d).tar.gz $WS_PATH/backups/latest_backup.tar.gz

# 4. Git 推送
echo "· 正在同步压缩包到 GitHub..."
git -C $WS_PATH add backups/
git -C $WS_PATH commit -m "Full Compressed Backup: $(date '+%Y-%m-%d %H:%M:%S')"
git -C $WS_PATH push origin main

if [ $? -eq 0 ]; then
    echo "✅ 备份成功！文件已存入仓库的 backups/ 目录。"
else
    echo "❌ 推送失败，请确认 GH_TOKEN 权限。"
fi
