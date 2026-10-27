# PaperPiAI Image Update Script User Guide

# English Version

## 1. Overview

This script is specifically designed for the Raspberry Pi Zero paired with the Waveshare 7.3-inch E-Paper (model: epd7in3e). It automates the full workflow of image generation, cooldown protection, and screen display. Key advantages include a built-in resource protection mechanism (prevents device crashes caused by concurrent tasks) and detailed logging to simplify troubleshooting.

## 2. Prerequisites

- **Hardware**: Raspberry Pi Zero 2W is normally booted, and the E-Paper screen is wired correctly (refer to Waveshare's official wiring guide).

- **Software**: Python 2.7+ and Python 3.6+ are installed (the script is compatible with both versions for generation/display commands).

- **Environment**: The PaperPiAI project is deployed, and the generation script (generate_picture.py) and display script (display_picture.py) are located in the `Waveshare_E-Paper` directory.

## 3. Installation Steps

### 3.1 Script Deployment

```bash

# Download the corresponding file and unzip it
wget https://files.waveshare.net/wiki/RPi_Zero_PhotoPainter/RPi_Zero_PhotoPainter.zip
unzip -o RPi_Zero_PhotoPainter.zip -d RPi_Zero_PhotoPainter
cd RPi_Zero_PhotoPainter/script_code
cp -r cron_flower.sh ~/PaperPiAI     # PaperPiAI is the path for building the large model
# If you want to display Chinese logs, transfer the following script
# cp -r cron_flower-CN.sh ~/PaperPiAI

# Enter the project directory (Modify according to your own large model folder)
cd /home/pi/PaperPiAI
```

### 3.2 Permission Configuration

The script must be granted executable permissions, otherwise it cannot run:

```bash

chmod +x /home/pi/PaperPiAI/cron_flower.sh
```

## 4. Configuration Instructions

The "Configuration Section" at the top of the script is configurable. There is no need to modify the core code; only adjust the following parameters:

|Parameter|Description|Default Value|Modification Suggestion|
|---|---|---|---|
|PROJECT_DIR|Root directory path of the PaperPiAI project|/home/pi/PaperPiAI|If the project path changes, it needs to be updated synchronously|
|IMAGE_WIDTH/HEIGHT|Width/height of the generated image (must match the screen resolution)|800/480|Keep consistent with the E-Paper screen resolution|
|GENERATION_STEPS|Number of image generation steps (more steps mean better quality but longer time consumption)|1|It is recommended not to exceed 3 steps for Raspberry Pi Zero|
|COOLDOWN_DELAY|Cooldown delay after generation (protects the screen and Raspberry Pi)|100 seconds|If the Raspberry Pi temperature is too high after generation, it can be extended to 120-180 seconds|
|OVERWRITE_OUTPUT|Whether to overwrite the generated image file|true|It is recommended to keep true in automated scenarios|
## 5. Operation & Testing

### 5.1 Manual Testing (Mandatory)

After the initial deployment, the script must be run manually to verify the function to avoid the failure of scheduled tasks:

```bash

# Enter the project directory
cd /home/pi/PaperPiAI

# Run the script
./cron_flower.sh
```

Signs of successful operation:

- Terminal output includes "✅ Image displayed successfully"

- The E-Paper screen normally displays the newly generated image

- An `image_update.log` file is generated in the project directory (default for scripts without the -CN suffix)

- A `cron_flower.log` file is generated in the project directory (for scripts with the -CN suffix)

### 5.2 Scheduled Task Configuration (Automation)

Configure daily automatic operation through crontab (example: execute at 6:00 every morning):

```bash

# Edit scheduled tasks
crontab -e

# Add the following content at the end of the file (the absolute path must be correct)
0 6 * * * /home/pi/PaperPiAI/cron_flower.sh
```

Explanation of the scheduled task time format: `Minute Hour Day Month Weekday`. For example:

- Execute at 20:00 every day: `0 20 * * *`

- Execute at 7:00 every Monday: `0 7 * * 1`

## 6. Troubleshooting

### 6.1 Core Log Viewing

All operation information (success/error) is recorded in the log file, which is the core basis for troubleshooting:

```bash

# View the full log
cat /home/pi/PaperPiAI/image_update.log

# View the latest 10 lines of logs (for real-time monitoring)
tail -n 10 /home/pi/PaperPiAI/image_update.log
```

### 6.2 Common Problem Solutions

|Error Phenomenon|Possible Cause|Solution|
|---|---|---|
|The script prompts "Another instance is running"|There is already a script instance running to prevent resource conflicts|Execute `ps aux | grep image_update.sh` to find the process ID, and use `kill Process ID` to terminate it|
|Image generation fails, and the log prompts "Python command not found"|The Python environment is not configured or the path is incorrect|Confirm Python installation: `python --version`. If it is Python3, change `python` to `python3` in the script|
|No display on the screen, and the log prompts "Resource busy"|GPIO pins are occupied by other programs|Execute `ps aux | grep gpio` to terminate the occupied process, or restart the Raspberry Pi|
|The scheduled task is not executed|Incorrect crontab path or insufficient permissions|Ensure the script path is an absolute path and there are no syntax errors in the crontab task|
## 7. Maintenance Recommendations

- **Regular log cleaning**: Logs will grow continuously. It is recommended to execute `> /home/pi/PaperPiAI/image_update.log` every month to clear them.

- **Device temperature monitoring**: If high-temperature prompts appear frequently, it is recommended to install a heat sink for the Raspberry Pi.

- **Configuration backup**: After modifying the script configuration, it is recommended to keep a backup to prevent configuration loss caused by misoperation.
