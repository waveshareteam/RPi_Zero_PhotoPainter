# 中文版使用说明

## 1. 概述

本脚本专为树莓派 Zero 与 Waveshare 7.3英寸 E-Paper（型号：epd7in3e）设计，实现图像自动生成、降温保护及屏幕显示的全流程自动化。核心优势在于内置资源保护机制，可防止多任务并发导致的设备死机，同时通过详细日志简化问题排查。

## 2. 前置条件

- 硬件：树莓派 Zero 2W 已正常启动，E-Paper 屏幕接线无误（参考 Waveshare 官方接线指南）。

- 软件：已安装 Python 2.7+ 及 Python 3.6+（脚本同时兼容两个版本的生成/显示命令）。

- 环境：已部署 PaperPiAI 项目，且生成脚本（generate_picture.py）与显示脚本（display_picture.py）位于 `Waveshare_E-Paper` 目录下。

## 3. 安装步骤

### 3.1 脚本部署

```bash

# 下载对应文件并解压
wget https://files.waveshare.net/wiki/RPi_Zero_PhotoPainter/RPi_Zero_PhotoPainter.zip
unzip -o RPi_Zero_PhotoPainter.zip -d RPi_Zero_PhotoPainter
cd RPi_Zero_PhotoPainter/script_code
cp -r cron_flower.sh ~/PaperPiAI     # PaperPiAI 为搭建大模型的路径
# 如果您希望显示中文日志请传输下面这个脚本
# cp -r cron_flower-CN.sh ~/PaperPiAI

# 进入项目目录（根据您自己的大模型文件夹进行修改）
cd /home/pi/PaperPiAI

```

### 3.2 权限配置

必须为脚本添加可执行权限，否则无法运行：

```bash

chmod +x /home/pi/PaperPiAI/cron_flower.sh
```

## 4. 配置说明

脚本顶部的「Configuration Section」为可配置区域，无需修改核心代码，仅调整以下参数即可：

|参数名|说明|默认值|修改建议|
|---|---|---|---|
|PROJECT_DIR|PaperPiAI 项目根目录路径|/home/pi/PaperPiAI|若项目路径变更，需同步修改|
|IMAGE_WIDTH/HEIGHT|生成图像的宽/高（需匹配屏幕分辨率）|800/480|与 E-Paper 屏幕分辨率保持一致|
|GENERATION_STEPS|图像生成步数（步数越多质量越高，耗时越长）|1|树莓派 Zero 建议不超过 3 步|
|COOLDOWN_DELAY|生成后降温延迟（保护屏幕和树莓派）|100 秒|若生成后树莓派温度过高，可延长至 120-180 秒|
|OVERWRITE_OUTPUT|是否覆盖已生成的图像文件|true|自动化场景建议保持 true|
## 5. 运行与测试

### 5.1 手动测试（必做）

首次部署后，务必手动运行脚本验证功能，避免定时任务执行失败：

```bash

# 进入项目目录
cd /home/pi/PaperPiAI

# 运行脚本
./cron_flower.sh
```

运行成功的标志：

- 终端输出包含「✅ Image displayed successfully」

- E-Paper 屏幕正常显示新生成的图像

- 项目目录下生成 `image_update.log` 日志文件 (脚本不带 -CN 后缀，默认)

- 项目目录下生成 `cron_flower.log` 日志文件 (脚本带 -CN 后缀)

### 5.2 定时任务配置（自动化）

通过 crontab 配置每日自动运行（示例：每天早上 6 点执行）：

```bash

# 编辑定时任务
crontab -e

# 在文件末尾添加以下内容（绝对路径必须正确）
0 6 * * * /home/pi/PaperPiAI/cron_flower.sh
```

定时任务时间格式说明：`分 时 日 月 周`，例如：

- 每天 20:00 执行：`0 20 * * *`

- 每周一早上 7 点执行：`0 7 * * 1`

## 6. 问题排查

### 6.1 核心日志查看

所有运行信息（成功/错误）均记录在日志文件中，是排查问题的核心依据：

```bash

# 查看完整日志
cat /home/pi/PaperPiAI/image_update.log

# 查看最新10行日志（实时监控用）
tail -n 10 /home/pi/PaperPiAI/image_update.log
```

### 6.2 常见问题解决

|错误现象|可能原因|解决方法|
|---|---|---|
|脚本提示「Another instance is running」|已有一个脚本实例在运行，防止资源冲突|执行 `ps aux | grep image_update.sh` 找到进程ID，用 `kill 进程ID` 终止|
|图像生成失败，日志提示「Python command not found」|Python 环境未配置或路径错误|确认 Python 安装：`python --version`，若为 Python3，将脚本中 `python` 改为 `python3`|
|屏幕无显示，日志提示「Resource busy」|GPIO 引脚被其他程序占用|执行 `ps aux | grep gpio` 终止占用进程，或重启树莓派|
|定时任务未执行|crontab 路径错误或权限不足|确保脚本路径为绝对路径，且 crontab 任务无语法错误|
## 7. 维护建议

- 定期清理日志文件：日志会持续增长，建议每月执行 `> /home/pi/PaperPiAI/image_update.log` 清空。

- 监控设备温度：若频繁出现高温提示，建议为树莓派加装散热片。

- 备份配置：修改脚本配置后，建议保留一份备份，防止误操作导致配置丢失。

---