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

# 创建并设置工作目录
WORKDIR /workspace
RUN chmod 777 /workspace

# 暴露端口
EXPOSE 7860

# 启动 JupyterLab
# 在启动脚本中先尝试安装 openclaw
CMD bash -c "curl -fsSL https://openclaw.ai/install.sh | bash && jupyter lab \
     --ip=0.0.0.0 \
     --port=7860 \
     --NotebookApp.token=ab87036181 \
     --no-browser \
     --allow-root \
     --ServerApp.base_url=/ \
     --ServerApp.default_url=/lab \
     --ServerApp.disable_check_xsrf=True \
     --ServerApp.allow_origin='*'"
