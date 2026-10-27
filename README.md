# RPi Zero PhotoPainter

[中文](#中文) | [English](#english)

## 中文

RPi Zero PhotoPainter 是基于 Raspberry Pi Zero 2 W 和 Waveshare 7.3 英寸六色电子纸的相框项目，屏幕分辨率为 **800 × 480**。本仓库提供电子纸驱动示例、AI 图像生成与显示脚本、自动刷新脚本，以及 RTC 和 UPS 相关示例。

### 官方文档

- [中文 Wiki](https://www.waveshare.net/wiki/RPi_Zero_PhotoPainter)
- [English Wiki](https://www.waveshare.com/wiki/RPi_Zero_PhotoPainter)

硬件连接、系统镜像、依赖安装、AI 模型部署及完整使用说明请参阅 Wiki。

### 目录说明

| 目录 | 内容 |
| --- | --- |
| [`7in3_e-Paper_E/`](7in3_e-Paper_E/) | 7.3 英寸电子纸的 C / Python 驱动、测试程序、字体及示例图片 |
| [`Waveshare_E-Paper/`](Waveshare_E-Paper/) | AI 图像生成、图像裁剪与显示程序，以及配套电子纸驱动 |
| [`script_code/`](script_code/) | 自动执行生图、等待和显示的 Shell 脚本，包含中英文日志版本及说明 |
| [`RTC/`](RTC/) | DS3231 实时时钟的 C / Python 示例 |
| [`UPS/`](UPS/) | 基于 INA219 的电压、电流及功率读取示例 |

### 快速开始

以下命令在树莓派终端中执行。请先按照 Wiki 完成硬件连接、系统及依赖配置，并启用 SPI；使用 RTC / UPS 示例时还需配置 I²C。

#### 1. 获取代码

```bash
git clone https://github.com/waveshareteam/RPi_Zero_PhotoPainter.git
cd RPi_Zero_PhotoPainter
```

#### 2. 测试电子纸

安装 Wiki 中列出的 Python 驱动依赖后，在仓库根目录执行：

```bash
cd 7in3_e-Paper_E/python/examples
python3 epd_7in3e_test.py
```

示例会显示文字、图形和测试图片，随后清屏并进入休眠。C 示例的编译方法请参阅 Wiki。

#### 3. 生成并显示 AI 图片

本仓库**不包含模型权重或 OnnxStream 推理程序**。请先按照 Wiki 完成 PaperPiAI、OnnxStream 及模型部署，并在所配置的 Python 3 环境中运行。显示脚本使用 Pillow、NumPy 和 OpenCV；智能裁剪需要带有 `cv2.saliency` 的 OpenCV contrib 模块。

以下示例假设模型工程位于 `~/PaperPiAI`。在本仓库根目录执行：

```bash
cp -r Waveshare_E-Paper ~/PaperPiAI/
cd ~/PaperPiAI
python3 Waveshare_E-Paper/generate_picture.py --steps 1 --overwrite
python3 Waveshare_E-Paper/display_picture.py -m epd7in3e
```

生成程序默认读取 `Waveshare_E-Paper/flowers.json` 中的提示词组合，显示程序默认读取 `output_dir/output.png`。生成程序默认从当前工作目录查找 `OnnxStream/src/build/sd` 和 `models/stable-diffusion-xl-turbo-1.0-anyshape-onnxstream`；路径不同时可通过 `--sd`、`--model` 指定。

也可以指定提示词或显示已有图片：

```bash
python3 Waveshare_E-Paper/generate_picture.py --steps 1 --prompt "A watercolor painting of sunflowers" --overwrite
python3 Waveshare_E-Paper/display_picture.py -m epd7in3e /path/to/image.png
```

#### 4. 自动刷新

在本仓库根目录，将所需脚本复制到已配置好的模型工程：

```bash
cp script_code/cron_flower.sh ~/PaperPiAI/
chmod +x ~/PaperPiAI/cron_flower.sh
```

修改脚本顶部的 `PROJECT_DIR`，使其与实际工程路径一致（默认为 `/home/pi/PaperPiAI`），然后手动运行 `~/PaperPiAI/cron_flower.sh`。脚本包含进程检查、日志记录及生图后的等待步骤。确认运行成功后，再按 Wiki 配置定时任务。

脚本调用了 `python` 和 `python3`，英文版还使用 `bc`；请确保运行环境中这些命令可用，且两个 Python 命令均指向安装了所需依赖的 Python 3 环境。通过 cron 运行时也需配置相同环境。

- 英文日志脚本：[`cron_flower.sh`](script_code/cron_flower.sh)，日志为工程目录下的 `image_update.log`。
- 中文日志脚本：[`cron_flower-CN.sh`](script_code/cron_flower-CN.sh)，日志为工程目录下的 `cron_flower.log`。
- 详细说明：[`中文脚本使用指南`](script_code/Readme-CN.md)。

### 使用提示

- 本项目电子纸的电源控制引脚为 **BCM GPIO 27**，请按本产品 Wiki 接线。
- AI 生图耗时取决于硬件、模型和参数，可先使用 `--steps 1` 验证流程。
- 仅显示已有图片时无需运行 AI 模型，但仍需安装图像处理和电子纸驱动依赖。
- RTC 和 UPS 示例独立于 AI 生图流程，可按需要使用。

## English

RPi Zero PhotoPainter is a photo frame project using a Raspberry Pi Zero 2 W and a Waveshare 7.3-inch six-color e-Paper display with an **800 × 480** resolution. This repository contains display demos, AI image generation and display scripts, refresh automation, and RTC / UPS examples.

### Documentation

- [English Wiki](https://www.waveshare.com/wiki/RPi_Zero_PhotoPainter)
- [中文 Wiki](https://www.waveshare.net/wiki/RPi_Zero_PhotoPainter)

Refer to the Wiki for wiring, system images, dependencies, model setup, and detailed instructions.

### Repository Contents

| Directory | Contents |
| --- | --- |
| [`7in3_e-Paper_E/`](7in3_e-Paper_E/) | C / Python drivers and demos, fonts, and test images for the 7.3-inch display |
| [`Waveshare_E-Paper/`](Waveshare_E-Paper/) | AI image generation, image fitting and display scripts, and display drivers |
| [`script_code/`](script_code/) | Shell scripts for generation, delay, and display, with English / Chinese logs and guides |
| [`RTC/`](RTC/) | C / Python examples for the DS3231 real-time clock |
| [`UPS/`](UPS/) | INA219 voltage, current, and power monitoring example |

### Quick Start

Run these commands on the Raspberry Pi. Complete the wiring, system setup, and dependency installation described in the Wiki first. Enable SPI for the display and configure I²C when using the RTC / UPS examples.

#### 1. Get the Code

```bash
git clone https://github.com/waveshareteam/RPi_Zero_PhotoPainter.git
cd RPi_Zero_PhotoPainter
```

#### 2. Test the Display

After installing the Python driver dependencies listed in the Wiki, run from the repository root:

```bash
cd 7in3_e-Paper_E/python/examples
python3 epd_7in3e_test.py
```

The demo displays text, graphics, and a test image, then clears the screen and enters sleep mode. See the Wiki for C demo build instructions.

#### 3. Generate and Display an AI Image

**Model weights and the OnnxStream executable are not included.** Set up PaperPiAI, OnnxStream, and the model as described in the Wiki, then use the configured Python 3 environment. The display script requires Pillow, NumPy, and OpenCV; intelligent cropping uses the `cv2.saliency` module from OpenCV contrib.

Assuming the model project is at `~/PaperPiAI`, run from this repository's root:

```bash
cp -r Waveshare_E-Paper ~/PaperPiAI/
cd ~/PaperPiAI
python3 Waveshare_E-Paper/generate_picture.py --steps 1 --overwrite
python3 Waveshare_E-Paper/display_picture.py -m epd7in3e
```

Prompts are selected from `Waveshare_E-Paper/flowers.json` by default. The display script reads `output_dir/output.png`. The generator looks for `OnnxStream/src/build/sd` and `models/stable-diffusion-xl-turbo-1.0-anyshape-onnxstream` relative to the working directory; use `--sd` and `--model` to override these paths.

To use a custom prompt or display an existing image:

```bash
python3 Waveshare_E-Paper/generate_picture.py --steps 1 --prompt "A watercolor painting of sunflowers" --overwrite
python3 Waveshare_E-Paper/display_picture.py -m epd7in3e /path/to/image.png
```

#### 4. Automate Updates

From this repository's root, copy the script into the configured model project:

```bash
cp script_code/cron_flower.sh ~/PaperPiAI/
chmod +x ~/PaperPiAI/cron_flower.sh
```

Set `PROJECT_DIR` at the top of the script to your project path (default: `/home/pi/PaperPiAI`), then run `~/PaperPiAI/cron_flower.sh` manually. The script includes process checks, logging, and a delay after generation. Once manual execution succeeds, follow the Wiki to configure scheduled updates.

The script invokes both `python` and `python3`; the English version also uses `bc`. Ensure these commands are available and both Python commands resolve to a Python 3 environment with the required dependencies. Configure the same environment for cron jobs.

- English script: [`cron_flower.sh`](script_code/cron_flower.sh), logging to `image_update.log` in the project directory.
- Chinese script: [`cron_flower-CN.sh`](script_code/cron_flower-CN.sh), logging to `cron_flower.log` in the project directory.
- Detailed instructions: [Script User Guide](script_code/Readme.md).

### Notes

- The display power-control pin for this project is **BCM GPIO 27**. Follow the product-specific wiring guide.
- Generation time depends on hardware, model, and settings. Start with `--steps 1` to check the workflow.
- Displaying an existing image does not require AI inference, but still requires the image-processing and display-driver dependencies.
- RTC and UPS examples can be used independently of the AI workflow.
