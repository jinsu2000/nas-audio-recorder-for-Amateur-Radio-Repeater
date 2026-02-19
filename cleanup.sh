#!/bin/bash

# 设置默认环境变量
MAX_FILE_AGE=${MAX_FILE_AGE:-72}
RECORDINGS_DIR="/app/recordings"

# 确保录音目录存在
if [ ! -d "$RECORDINGS_DIR" ]; then
    echo "错误: 录音目录 $RECORDINGS_DIR 不存在"
    exit 1
fi

# 清理过期文件
echo "开始清理过期录音文件..."
echo "保留时间: $MAX_FILE_AGE 小时"

# 查找并删除过期文件
deleted_count=0
while IFS= read -r -d '' file; do
    if rm -f "$file"; then
        echo "删除过期文件: $file"
        ((deleted_count++))
    else
        echo "错误: 无法删除文件 $file"
        exit 1
    fi
done < <(find "$RECORDINGS_DIR" -name "*.mp3" -type f -mmin "+$((MAX_FILE_AGE * 60))" -print0)

# 显示清理结果
echo "清理完成，共删除 $deleted_count 个过期文件"

# 显示当前目录状态
current_count=$(find "$RECORDINGS_DIR" -name "*.mp3" -type f 2>/dev/null | wc -l)
echo "当前录音文件数量: $current_count"