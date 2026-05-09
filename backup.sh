#!/bin/bash
# OpenClaw 全量备份脚本

echo "🦞 开始全量备份 OpenClaw 数据..."

# 1. 准备备份目录
mkdir -p /workspace/config_backup
mkdir -p /workspace/memory
mkdir -p /workspace/skills

# 2. 拷贝核心配置和历史记录
echo "· 正在打包配置文件和历史记录..."
cp -r ~/.openclaw/* /workspace/config_backup/ 2>/dev/null || true
cp ~/.bash_history /workspace/config_backup/bash_history.txt 2>/dev/null || true

# 3. 执行 Git 推送
echo "· 正在推送到 GitHub 仓库..."
git -C /workspace add .
git -C /workspace commit -m "Manual Full Backup: $(date '+%Y-%m-%d %H:%M:%S')"
git -C /workspace push origin master:main

if [ $? -eq 0 ]; then
    echo "✅ 备份成功！数据已同步到 GitHub。"
else
    echo "❌ 备份失败，请检查网络或 GitHub Token 设置。"
fi
