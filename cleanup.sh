#!/bin/bash

# 设置默认环境变量
MAX_FILE_AGE=${MAX_FILE_AGE:-72}

# 清理过期文件
echo "开始清理过期录音文件..."
echo "保留时间: $MAX_FILE_AGE 小时"

# 查找并删除过期文件
find /app/recordings -name "*.mp3" -type f -mmin "+$((MAX_FILE_AGE * 60))" -exec rm -f {} \;

# 检查是否有文件被删除
if [ $? -eq 0 ]; then
    echo "清理完成"
else
    echo "清理过程中出现错误"
fi

# 显示当前目录状态
echo "当前录音文件数量: $(ls -la /app/recordings/*.mp3 2>/dev/null | wc -l)"