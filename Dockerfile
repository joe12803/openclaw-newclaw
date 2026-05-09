# 使用官方 Python 基础镜像
FROM python:3.11-slim

# 设置环境变量避免交互
ENV DEBIAN_FRONTEND=noninteractive

# 安装系统依赖 + Node.js 20.x
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    procps \
    ca-certificates \
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# 安装 JupyterLab
RUN pip install --no-cache-dir jupyterlab

# 尝试预装 OpenClaw (通过设置环境变量或伪造 TTY 避开交互错误)
# 如果脚本失败，也不停止构建
RUN curl -fsSL https://openclaw.ai/install.sh | bash || true

# 设置 OpenClaw 配置环境变量
ENV OPENCLAW_API_BASE=https://openclaw.994938.xyz/v1 \
    OPENCLAW_MODEL_ID=gemini-3-flash \
    OPENCLAW_API_KEY=sk-KhbSk9pyLHkw8AzPy \
    OPENCLAW_CLI_ID=cli_a945168af2b95ccb \
    OPENCLAW_CLI_SECRET=ZNxDr96h2aktjNgZschT1gPk8KutnIHk \
    TELEGRAM_TOKEN=8681968864:AAHYMykz1T7_ykFu-75xg1-aTIFM3FOLq_M

# 设置 Git 身份
RUN git config --global user.email "joe12803@gmail.com" && \
    git config --global user.name "joe12803" && \
    git config --global safe.directory /workspace

# 创建记忆和技能目录
RUN mkdir -p /workspace/memory /workspace/skills

# 创建并设置工作目录
WORKDIR /workspace
RUN chmod 777 /workspace

# 暴露端口
EXPOSE 7860

# 启动脚本
CMD bash -c " \
    export PATH=\"/root/.npm-global/bin:/home/runner/.npm-global/bin:\$PATH\"; \
    # 建立配置文件的备份链接
    mkdir -p ~/.openclaw /workspace/.openclaw_backup; \
    # 如果备份已存在，则恢复它
    cp -r /workspace/.openclaw_backup/* ~/.openclaw/ 2>/dev/null || true; \
    # 启动后台自动同步脚本 (每10分钟同步一次，包含配置文件备份)
    (while true; do \
        cp -r ~/.openclaw/* /workspace/.openclaw_backup/ 2>/dev/null || true; \
        if [ -d /workspace/.git ] && [[ \$(git -C /workspace status --porcelain) ]]; then \
            echo 'Auto-syncing changes (including config) to GitHub...'; \
            git -C /workspace add . && git -C /workspace commit -m 'Auto-sync: update data, memory and config' && git -C /workspace push origin master:main || echo 'Sync failed'; \
        fi; \
        sleep 600; \
    done) & \
    if command -v openclaw > /dev/null; then \
        echo 'Configuring OpenClaw...'; \
        mkdir -p ~/.openclaw; \
        openclaw config set api_base \$OPENCLAW_API_BASE || true; \
        openclaw config set api_key \$OPENCLAW_API_KEY || true; \
        openclaw config set model_id \$OPENCLAW_MODEL_ID || true; \
        echo 'Starting OpenClaw Gateway (Force Run)...'; \
        # 强制使用绝对路径或直接调用 run 避开 systemd 检查
        nohup openclaw gateway run > /tmp/gateway.log 2>&1 & \
        sleep 5; \
    fi && \
    jupyter lab \
    --ip=0.0.0.0 \
    --port=7860 \
    --NotebookApp.token=ab87036181 \
    --no-browser \
    --allow-root \
    --ServerApp.base_url=/ \
    --ServerApp.default_url=/lab \
    --ServerApp.disable_check_xsrf=True \
    --ServerApp.allow_origin='*'"
