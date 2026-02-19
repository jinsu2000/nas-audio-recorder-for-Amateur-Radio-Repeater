FROM debian:bullseye-slim

# 设置时区
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 更新系统并安装依赖
RUN apt-get update && apt-get install -y \
    ffmpeg \
    bash \
    cron \
    && rm -rf /var/lib/apt/lists/*

# 创建非 root 用户
RUN groupadd -g 1000 appuser && \
    useradd -u 1000 -g appuser -m appuser

# 创建工作目录
WORKDIR /app

# 创建录音目录并设置权限
RUN mkdir -p /app/recordings && \
    chown -R appuser:appuser /app

# 复制脚本文件
COPY record.sh /app/
COPY cleanup.sh /app/

# 设置执行权限
RUN chmod +x /app/record.sh /app/cleanup.sh

# 设置cron任务
RUN echo "0 */6 * * * /app/cleanup.sh" > /etc/cron.d/cleanup-cron
RUN chmod 0644 /etc/cron.d/cleanup-cron
RUN crontab /etc/cron.d/cleanup-cron

# 切换到非 root 用户
USER appuser

# 启动脚本
CMD ["bash", "-c", "cron && /app/record.sh"]