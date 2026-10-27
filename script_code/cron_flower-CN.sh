#!/bin/bash

##############################################################################
# 脚本配置区
##############################################################################
PROJECT_DIR="/home/pi/PaperPiAI"  # 项目主目录
WIDTH="800"
HEIGHT="480"
STEPS="1"  # 1步约半小时，Zero性能有限，不建议增加
DISPLAY_MODEL="epd7in3e"
DELAY_SECONDS=100  # 生成后延迟降温时间
LOG_FILE="$PROJECT_DIR/cron_flower.log"  # 日志文件
LOCK_FILE="$PROJECT_DIR/cron_flower.lock"  # 进程锁文件（核心防冲突）

# 关键修改：只匹配你自己的生成/显示脚本（精确路径或文件名，避免误判系统进程）
MY_TASK_COMMANDS=("Waveshare_E-Paper/generate_picture.py" "Waveshare_E-Paper/display_picture.py")

##############################################################################
# 核心函数（重点防资源过载）
##############################################################################

# 1. 日志打印（带时间戳，方便排查）
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# 2. 强进程锁（核心！确保同一时间只有一个资源密集型任务运行）
acquire_strong_lock() {
    # 第一步：检查是否已有锁文件（防止脚本多实例）
    if [ -f "$LOCK_FILE" ]; then
        # 验证锁文件对应的进程是否真的在运行（避免死锁）
        locked_pid=$(cat "$LOCK_FILE" 2>/dev/null)
        if [ -n "$locked_pid" ] && ps -p "$locked_pid" >/dev/null; then
            log "错误：已存在运行中的任务（PID: $locked_pid），Zero资源有限，避免过载，退出！"
            exit 1
        fi
        # 若锁文件存在但进程已结束，清理无效锁文件
        log "发现无效锁文件，已自动清理。"
        rm -f "$LOCK_FILE"
    fi

    # 第二步：创建锁文件，写入当前进程PID（标记占用）
    echo $$ > "$LOCK_FILE"
    # 脚本退出时强制删除锁文件（正常退出、异常退出都生效）
    trap 'rm -f "$LOCK_FILE"; log "任务结束，已释放资源锁"' EXIT

    # 关键修改：精确匹配你自己的生成/显示脚本，不匹配系统进程
    log "检查是否有其他图像生成/显示任务在运行..."
    has_conflict=0
    for task in "${MY_TASK_COMMANDS[@]}"; do
        # 查找包含你的脚本路径的进程（排除当前脚本进程和grep本身）
        conflicting_pids=$(ps aux | grep -E "$task" | grep -v grep | grep -v "$$" | awk '{print $2}')
        if [ -n "$conflicting_pids" ]; then
            log "错误：发现其他正在运行的任务（脚本: $task），PID: $conflicting_pids"
            has_conflict=1
        fi
    done

    if [ "$has_conflict" -eq 1 ]; then
        log "避免Zero资源过载，退出当前任务！"
        exit 1
    fi

    log "资源检查通过，无其他生成/显示任务运行，开始执行当前任务。"
}

# 3. 系统资源预检查（可选，进一步避免过载）
check_system_resources() {
    log "预检查系统资源（CPU/内存）..."
    # 检查CPU使用率（超过85%则退出）
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    cpu_usage_int=${cpu_usage%.*}  # 转为整数
    if [ "$cpu_usage_int" -ge 85 ]; then
        log "错误：当前CPU使用率高达 $cpu_usage%，资源不足，退出任务！"
        exit 1
    fi

    # 检查内存使用率（可用内存低于100MB则退出）
    available_mem=$(free -m | awk '/Mem:/ {print $7}')
    if [ "$available_mem" -lt 100 ]; then
        log "错误：当前可用内存仅 $available_mem MB，资源不足，退出任务！"
        exit 1
    fi

    log "系统资源充足（CPU使用率: $cpu_usage%，可用内存: $available_mem MB）。"
}

##############################################################################
# 脚本执行区
##############################################################################

# 第一步：获取强进程锁（核心防资源过载，必须放在最前面）
acquire_strong_lock

# 第二步：预检查系统资源（可选，若想关闭可注释此行）
check_system_resources

# 开始主任务
log "===== 开始每日图像更新任务（PID: $$）====="

# 检查项目目录
if [ ! -d "$PROJECT_DIR" ]; then
    log "错误：项目目录 $PROJECT_DIR 不存在！"
    exit 1
fi
cd "$PROJECT_DIR" || { log "错误：无法进入目录 $PROJECT_DIR"; exit 1; }

# 步骤1：生成图像（Zero性能有限，不建议并行运行）
log "开始生成图像（步骤: $STEPS，预计半小时左右）..."
log "执行命令: python Waveshare_E-Paper/generate_picture.py --width=$WIDTH --height=$HEIGHT --steps $STEPS"

python Waveshare_E-Paper/generate_picture.py --width="$WIDTH" --height="$HEIGHT" --steps "$STEPS"
if [ $? -ne 0 ]; then
    log "错误：图像生成失败！"
    exit 1
fi
log "图像生成成功。"

# 步骤2：延迟降温（同时让CPU/内存释放部分资源）
log "等待 $DELAY_SECONDS 秒（降温+释放资源）..."
sleep "$DELAY_SECONDS"

# 步骤3：显示图像（同样是资源密集型操作）
log "开始在 $DISPLAY_MODEL 屏幕上显示图像..."
log "执行命令: python3 Waveshare_E-Paper/display_picture.py -m $DISPLAY_MODEL"

python3 Waveshare_E-Paper/display_picture.py -m "$DISPLAY_MODEL"
if [ $? -ne 0 ]; then
    log "错误：图像显示失败！"
    exit 1
fi
log "图像显示成功。"

log "===== 每日图像更新任务完成（总耗时: $((SECONDS/60)) 分钟）=====\n"

exit 0