#!/bin/bash
# OpenClaw 压缩全量备份脚本

echo "🦞 正在打包并备份 OpenClaw 数据..."

# 1. 准备临时打包目录
TEMP_DIR="/tmp/openclaw_sync"
rm -rf $TEMP_DIR && mkdir -p $TEMP_DIR/config $TEMP_DIR/memory $TEMP_DIR/skills

# 2. 拷贝数据到临时目录
cp -r ~/.openclaw/* $TEMP_DIR/config/ 2>/dev/null || true
cp ~/.bash_history $TEMP_DIR/bash_history.txt 2>/dev/null || true
cp -r /workspace/memory/* $TEMP_DIR/memory/ 2>/dev/null || true
cp -r /workspace/skills/* $TEMP_DIR/skills/ 2>/dev/null || true

# 3. 创建压缩包
mkdir -p /workspace/backups
tar -czf /workspace/backups/openclaw_full_$(date +%Y%m%d).tar.gz -C $TEMP_DIR .
# 同时保留一个最新版，方便恢复脚本调用
cp /workspace/backups/openclaw_full_$(date +%Y%m%d).tar.gz /workspace/backups/latest_backup.tar.gz

# 4. Git 推送
echo "· 正在同步压缩包到 GitHub..."
git -C /workspace add backups/
git -C /workspace commit -m "Full Compressed Backup: $(date '+%Y-%m-%d %H:%M:%S')"
git -C /workspace push origin main

if [ $? -eq 0 ]; then
    echo "✅ 备份成功！文件已存入仓库的 backups/ 目录。"
else
    echo "❌ 推送失败，请检查 GH_TOKEN 权限。"
fi
