#!/usr/bin/env bash
#
# System Monitor Script

# ==============================================
# Configuring Constraints
# ==============================================
# Thresholds
DISK_THRESHOLD=80	# Usage for disk alerts
MEM_THRESHOLD=70	# % RAM usage for alerts
LOG_DAYS=7		# Delete logs older than 7 days

# Log directory and daily log file
LOG_DIR="$HOME/sysmon_logs"
LOG_FILE="$LOG_DIR/system_monitor_$(date +'%Y-%m-%d').log"

# Create the log directory if it doesn't exist
mkdir -p "$LOG_DIR"

# ==============================================
# Command-line Options
# ==============================================

VERBOSE=false		# Default verbose mode off
QUIET=false		# Default quiet mode off

# Parese command-line arguments
for arg in "$@"; do
    case $arg in
        -v|--verbose) 
             VERBOSE=true ;;	# Enable verbose mode
        -q|--quiet) 
             QUIET=true ;;	# Enable quiet mode
    esac
done

# ==============================================
# Logging Function
# ==============================================

log() {
    # Always append log message to daily log file
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"

    # Print to terminal unless quiet mode is enabled
    if [ "$QUIET" = false ]; then
        echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"
    fi
}

log "==== System Health Check Started ===="

# Track whether any warnings occurred
WARNING_TRIGGERED=false

# ==============================================
# Disk Usage
# ==============================================
# Get root (/) disk usage in percent
# df -h / -> human-readable disk usage for root
# awk 'NR==2 {print $5}' -> second line is root, extract 5th column (% used)
# tr -d '%' -> remove the percent sign

root_usage=$(df -h / | awk 'NR==2 {print $5}' | tr -d '%')

# Get /home disk usage if it exists
home_usage=$(df -h /home 2>/dev/null | awk 'NR==2 {print $5}' | tr -d '%')

# Log disk usage
log "Disk usage on /: ${root_usage}%"
[ -n "$home_usage" ] && log "Disk usage on /home: ${home_usage}%"

# Trigger warnings if disk usage exceeds threshold
if [ "$root_usage" -gt "$DISK_THRESHOLD" ]; then
    log "WARNING: Disk usage on / is above 80%"
    WARNING_TRIGGERED=true
fi

if [ -n "$home_usage" ] && [ "$home_usage" -gt "$MEM_THRESHOLD" ]; then
    log "WARNING: Disk usage on /home is above 80%"
    WARNING_TRIGGERED=true
fi

# ==============================================
# Memory Usage
# ==============================================
# Check if 'free' command is available

if command -v free >/dev/null 2>&1; then
    # Read total and used memory in MB
    # free -m -> memory in MB
    # awk'/Mem:/ {print $1, $2, $3, $4}' -> extract total and used
    read -r _ total used free <<<"$(free -m | awk '/Mem:/ {print $1, $2, $3, $4}')"
    
    # Calculate memory usage percentage
    mem_percent=$(( used * 100 / total ))

    # Log memory usage
    log "Memory usage: ${used}MB / ${total}MB (${mem_percent}%)"
    
    # Trigger warning if memory exceeds threshold
    if [ "$mem_percent" -gt "$MEM_THRESHOLD" ]; then
        log "WARNING: High memory usage"
        WARNING_TRIGGERED=true
    fi
else
    # If 'free' is not available, log info
    log "INFO: 'free' command not available"
fi

# ==============================================
# Load Average
# ==============================================
# Get 1-minute load average from /proc/loadavg
# The first number is the 1-minute load

load_1min=$(awk '{print $1}' /proc/loadavg 2>/dev/null)

# Get number of CPU cores for comparison
cpu_cores=$(nproc --all)

# Convert 1-min load to integer for comparison
load_int=${load_1min%.*}

# Log load average
log "Load average (1 min): $load_1min (CPU cores: $cpu_cores)"

# Trigger warning if load exceeds number of CPU cores
if [ "$load_int" -gt "$cpu_cores" ]; then
    log "WARNING: High CPU load"
    WARNING_TRIGGERED=true
fi

# ==============================================
# Top 3 Memory Processes
# ==============================================

log "Top 3 memory-using processes:"

# ps aux -> list all processes
# --sort=-%mem -> sort descending by memory usage
# awk 'NR==1 || NR<=4 {print}' -> print header + top 3 processes
ps aux --sort=-%mem | awk 'NR==1 || NR<=4 {print}' | tee -a "$LOG_FILE"

# ==============================================
# Verbose
# ==============================================

if [ "$VERBOSE" = true ]; then
    # Print full disk usage
    log "Verbose: Full disk report:"
    df -h | tee -a "$LOG_FILE"

    # Print full memory usage
    log "Verbose: Full memory report:"
    free -m | tee -a "$LOG_FILE"
fi

# ==============================================
# Log Rotation
# ==============================================
# Remove log files older than LOG_DAYS
# find -> search in LOG_DIR
# -mtime +LOG_DAYS -> modified more than LOG_DAYS ago
# -exec rm {} \; -> delete found files

find "$LOG_DIR" -type f -name "*.log" -mtime +$LOG_DAYS -exec rm {} \;

log "==== System Health Check Finished ===="

# ==============================================
# Exit 
# ==============================================
# Exit 1 if any warning occurred, else 0
if [ "$WARNING_TRIGGERED" = true ]; then
    exit 1
else
    exit 0
fi
