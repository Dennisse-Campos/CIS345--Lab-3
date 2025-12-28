# CIS345--Lab-3

## Project Overview
This project is a Bash-based system monitoring tool (`sys_monitor.sh`) designed to track critical system metrics including disk usage, memory consumption, CPU load, and log management. It features automated logging, threshold-based alerts, and command-line options for verbose or quiet operation

## Key Features
* **Threshold Configuration**: Easily adjustable limits for disk (80%), memory (70%), and CPU load
* **Automated Logging**: All checks are timestamped and saved to a daily log file located in `$HOME/sysmon_logs`.
* **Log Rotation**: Automatically removes log files older than 7 days to save disk space[.
* **Command-line Flags**: Supports `-v` / `--verbose` for full system reports and `-q` / `--quiet` to suppress terminal output.

## Exit Code Logic (Corrected)
To comply with standard Linux conventions for automation and error handling, the script utilizes the following exit codes:
* **Exit Code 0**: Indicates a **Healthy Run**. All system metrics are within safe thresholds.
* **Exit Code 1**: Indicates a **Warning/Alert**. One or more system metrics (Disk, RAM, or CPU) exceeded the defined thresholds.

## Sample Run & Implementation Verification
Since this lab requires verification of a successful run, I have provided screen recordings of the script in action:

1. **Direct GitHub File**: You can find the recording file titled `Sample Run.mov` in this repository.
2. **External Backup (Dropbox)**: https://www.dropbox.com/scl/fi/856520pws52t46ss4ze13/Sample-run.mov?rlkey=kib7rr4q7e2zzo7auqshxs0z2&st=s1hhfpjw&dl=0

## How to Run
1. Give execution permissions:
   ```bash
   chmod +x sys_monitor.sh

2. Execute the script:
   ```bash
   ./sys_monitor.sH
3. Run with verbose mode for detailed reports:
   ```bash
   ./sys_monitor.sh --verbose
4. Run with Quiet Mode:
   ```bash
   ./sys_monitor.sh --quiet
