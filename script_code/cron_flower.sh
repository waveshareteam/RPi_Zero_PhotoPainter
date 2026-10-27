#!/bin/bash

##############################################################################
# Configuration Section (Client-Modifiable)
##############################################################################
# Project root directory (Update this if your PaperPiAI is in a different path)
PROJECT_DIR="/home/pi/PaperPiAI"

# Image generation parameters
IMAGE_WIDTH="800"          # Image width (default: 800)
IMAGE_HEIGHT="480"         # Image height (default: 480)
GENERATION_STEPS="1"       # Generation steps (1 step ≈ 30 mins; higher = better quality but slower)
OVERWRITE_OUTPUT="true"    # Overwrite existing output file (true/false)

# E-Paper display settings
DISPLAY_MODEL="epd7in3e"   # Display model (Do NOT change unless using a different screen)
COOLDOWN_DELAY="100"       # Cool-down seconds after generation (protects display/PI)

# Log & Lock files (for troubleshooting and conflict prevention)
LOG_FILE="$PROJECT_DIR/image_update.log"  # Log file path
LOCK_FILE="$PROJECT_DIR/image_update.lock" # Lock file (prevents concurrent runs)

# Target scripts (Do NOT modify unless file paths change)
TARGET_SCRIPTS=(
    "Waveshare_E-Paper/generate_picture.py"
    "Waveshare_E-Paper/display_picture.py"
)

##############################################################################
# Core Functions (Do NOT Modify)
##############################################################################

# Log messages with timestamp (writes to console + log file)
log() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $1" | tee -a "$LOG_FILE"
}

# Acquire resource lock (prevents concurrent execution on Pi Zero)
acquire_lock() {
    # Check for existing valid lock
    if [ -f "$LOCK_FILE" ]; then
        local locked_pid=$(cat "$LOCK_FILE" 2>/dev/null)
        if [ -n "$locked_pid" ] && ps -p "$locked_pid" >/dev/null; then
            log "ERROR: Another instance is running (PID: $locked_pid) - Exiting to avoid resource overload"
            exit 1
        fi
        # Clean up stale lock file
        log "WARNING: Stale lock file detected - cleaning up automatically"
        rm -f "$LOCK_FILE"
    fi

    # Create new lock file with current PID
    echo $$ > "$LOCK_FILE"
    # Auto-release lock on script exit (even if interrupted)
    trap 'rm -f "$LOCK_FILE"; log "Resource lock released"' EXIT

    # Check for conflicting processes
    log "Checking for conflicting tasks..."
    local conflict=0
    for script in "${TARGET_SCRIPTS[@]}"; do
        local pids=$(ps aux | grep -E "$script" | grep -v grep | grep -v "$$" | awk '{print $2}')
        if [ -n "$pids" ]; then
            log "ERROR: Conflicting process found for $script (PIDs: $pids)"
            conflict=1
        fi
    done

    if [ "$conflict" -eq 1 ]; then
        log "ERROR: Resource contention detected - Exiting to protect Pi Zero"
        exit 1
    fi

    log "✅ Resource check passed - No conflicts detected"
}

# Check system resources (CPU/RAM) before starting
check_system_resources() {
    log "Performing system resource check..."

    # Check CPU usage (exit if >85%)
    local cpu_idle=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/")
    local cpu_usage=$(echo "100 - $cpu_idle" | bc | awk '{print int($1)}')
    if [ "$cpu_usage" -ge 85 ]; then
        log "ERROR: High CPU usage ($cpu_usage%) - Insufficient resources"
        exit 1
    fi

    # Check available memory (exit if <100MB)
    local available_mem=$(free -m | awk '/Mem:/ {print $7}')
    if [ "$available_mem" -lt 100 ]; then
        log "ERROR: Low available memory ($available_mem MB) - Insufficient resources"
        exit 1
    fi

    log "✅ System resources sufficient (CPU: $cpu_usage%, RAM: $available_mem MB free)"
}

##############################################################################
# Main Execution Flow
##############################################################################

# Step 1: Acquire lock to prevent concurrent runs
acquire_lock

# Step 2: Validate system resources
check_system_resources

# Start main task
log "=================================================="
log "🚀 Starting Daily Image Update Task (PID: $$)"
log "=================================================="

# Validate project directory
if [ ! -d "$PROJECT_DIR" ]; then
    log "ERROR: Project directory not found - $PROJECT_DIR"
    exit 1
fi

# Navigate to project directory
log "Changing to project directory: $PROJECT_DIR"
cd "$PROJECT_DIR" || {
    log "ERROR: Failed to access directory - $PROJECT_DIR"
    exit 1
}

# Step 3: Generate image
log "📸 Starting image generation (Steps: $GENERATION_STEPS, Resolution: ${IMAGE_WIDTH}x${IMAGE_HEIGHT})"
GENERATE_CMD="python Waveshare_E-Paper/generate_picture.py --width=$IMAGE_WIDTH --height=$IMAGE_HEIGHT --steps $GENERATION_STEPS"
# Add overwrite flag if enabled
if [ "$OVERWRITE_OUTPUT" = "true" ]; then
    GENERATE_CMD="$GENERATE_CMD --overwrite"
fi
log "Execution Command: $GENERATE_CMD"

$GENERATE_CMD
if [ $? -ne 0 ]; then
    log "ERROR: Image generation failed - Check logs for details"
    exit 1
fi
log "✅ Image generation completed successfully"

# Step 4: Cool-down period
log "❄️ Cooling down for $COOLDOWN_DELAY seconds (prevents display discoloration)"
sleep "$COOLDOWN_DELAY"

# Step 5: Display image on E-Paper
log "🖥️ Starting image display (Model: $DISPLAY_MODEL)"
DISPLAY_CMD="python3 Waveshare_E-Paper/display_picture.py -m $DISPLAY_MODEL"
log "Execution Command: $DISPLAY_CMD"

$DISPLAY_CMD
if [ $? -ne 0 ]; then
    log "ERROR: Image display failed - Check display connection"
    exit 1
fi
log "✅ Image displayed successfully"

# Completion message
log "=================================================="
log "🎉 Daily Image Update Task Completed Successfully"
log "Total Execution Time: $((SECONDS/60)) minutes"
log "==================================================\n"

exit 0