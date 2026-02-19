#!/bin/bash

# 创建录音目录
mkdir -p /app/recordings

# 设置文件权限
if [ -n "$PUID" ] && [ -n "$PGID" ]; then
    chown -R $PUID:$PGID /app/recordings
fi

# 设置默认环境变量
RECORD_DURATION=${RECORD_DURATION:-3600}
INITIAL_BITRATE=${INITIAL_BITRATE:-128k}
MIN_BITRATE=${MIN_BITRATE:-64k}
MAX_BITRATE=${MAX_BITRATE:-256k}
ADJUST_INTERVAL=${ADJUST_INTERVAL:-60}

# 当前码率
current_bitrate="$INITIAL_BITRATE"

# 主录音循环
while true; do
    # 生成文件名
    timestamp=$(date +"%Y%m%d_%H%M%S")
    output_file="/app/recordings/recording_${timestamp}.mp3"
    
    echo "开始录音: $output_file"
    echo "当前码率: $current_bitrate"
    
    # 使用FFmpeg录音
    # 注意: 这里使用默认音频设备，实际环境可能需要调整
    ffmpeg -f alsa -i default -t "$RECORD_DURATION" \
        -c:a libmp3lame -b:a "$current_bitrate" \
        -af "dynaudnorm" \
        "$output_file"
    
    # 检查录音是否成功
    if [ $? -eq 0 ]; then
        echo "录音完成: $output_file"
        
        # 简单的码率调节逻辑
        # 这里可以根据实际需求实现更复杂的调节算法
        # 例如：基于音频能量、环境噪声等
        if [ "$current_bitrate" = "$MIN_BITRATE" ]; then
            current_bitrate="$INITIAL_BITRATE"
        elif [ "$current_bitrate" = "$MAX_BITRATE" ]; then
            current_bitrate="$INITIAL_BITRATE"
        else
            # 随机波动码率（示例）
            bitrate_values=($MIN_BITRATE $INITIAL_BITRATE $MAX_BITRATE)
            current_bitrate=${bitrate_values[$RANDOM % ${#bitrate_values[@]}]}
        fi
        
        echo "下一段录音将使用码率: $current_bitrate"
    else
        echo "录音失败，将使用相同码率重试"
    fi
    
    # 短暂暂停
    sleep 1
done