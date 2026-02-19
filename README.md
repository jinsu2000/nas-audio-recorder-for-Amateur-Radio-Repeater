# Docker 音频录制解决方案

## 功能特点
- 基于 Docker 容器运行
- 使用 FFmpeg 进行音频录制
- 自动调节录音码率
- 分段录制（默认每小时一段）
- 定期清理过期录音文件（默认保留72小时）

## 环境要求
- Docker
- Docker Compose

## 快速开始

### 1. 克隆项目
```bash
git clone <repository-url>
cd audio-recorder
```

### 2. 构建并启动容器
```bash
docker-compose up -d
```

### 3. 查看录音文件
录音文件将保存在 `./recordings` 目录中。

## 配置参数

可以通过修改 `docker-compose.yml` 文件中的环境变量来调整配置：

| 环境变量 | 默认值 | 描述 |
|---------|-------|------|
| RECORD_DURATION | 3600 | 每段录音时长（秒） |
| MAX_FILE_AGE | 72 | 文件最大保留时间（小时） |
| INITIAL_BITRATE | 128k | 初始码率 |
| MIN_BITRATE | 64k | 最小码率 |
| MAX_BITRATE | 256k | 最大码率 |
| ADJUST_INTERVAL | 60 | 码率调节间隔（秒） |

## 目录结构
```
audio-recorder/
├── Dockerfile          # Docker 构建文件
├── docker-compose.yml  # Docker Compose 配置
├── record.sh           # 录音脚本
├── cleanup.sh          # 清理脚本
└── recordings/         # 录音文件存储目录
```

## 音频设备配置

默认情况下，脚本使用系统默认音频设备 (`default`)。在不同环境中，可能需要调整 FFmpeg 的音频输入设备配置：

### Linux 环境
- 使用 `arecord -l` 查看可用设备
- 修改 `record.sh` 中的 `-i default` 为具体设备

### Windows 环境
- 可能需要使用 `dshow` 输入格式
- 例如：`ffmpeg -f dshow -i audio="麦克风设备名称"`

### MacOS 环境
- 可能需要使用 `avfoundation` 输入格式
- 例如：`ffmpeg -f avfoundation -i ":0"`

## 码率调节机制

当前实现了简单的码率调节逻辑，在最小、初始和最大码率之间随机切换。可以根据实际需求修改 `record.sh` 中的调节算法，例如：

- 基于音频能量自动调节
- 基于环境噪声水平调节
- 基于固定时间表调节

## 日志查看

查看容器运行日志：
```bash
docker logs -f audio-recorder
```

## 停止服务

```bash
docker-compose down
```

## 注意事项

1. 确保主机系统有可用的音频输入设备
2. 在某些环境中，可能需要添加额外的权限来访问音频设备
3. 录音质量取决于输入设备和码率设置
4. 定期清理功能通过 cron 任务实现，每6小时执行一次

## 故障排除

### 无法找到音频设备
- 检查主机系统的音频设备是否正常工作
- 调整 `record.sh` 中的音频输入配置

### 录音文件过大
- 降低 `MAX_BITRATE` 值
- 增加 `RECORD_DURATION` 以减少文件数量

### 录音质量不佳
- 提高 `MIN_BITRATE` 和 `INITIAL_BITRATE` 值
- 确保使用高质量的音频输入设备