#!/bin/bash
while true; do
    cd /root/.openclaw || exit 1
    if [[ -n "$(git status --porcelain)" ]]; then
        git add -A
        git commit -m "自动同步: 更新 OpenClaw 配置 $(date '+%Y-%m-%d %H:%M:%S')"
        git push
    fi
    # 每隔 1 小时执行一次（3600 秒），可根据需要修改
    sleep 3600
done
