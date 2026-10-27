/*****************************************************************************
* | File      	:   Readme_CN.txt
* | Author      :   Waveshare team
* | Function    :   Help with use
* | Info        :
*----------------
* |	This version:   V1.0
* | Date        :   2021-07-27
* | Info        :   在这里提供一个中文版本的使用文档，以便你的快速使用
******************************************************************************/
这个文件是帮助您使用本例程。
在这里简略的描述本工程的使用：

1.基本信息：
本例程均在RTC WatchDog HAT上进行了验证;
你可以在工程的examples\中查看对应的测试例程;

2.管脚连接：
管脚连接你可以在\lib\waveshare_DS3231\config.py中查看，这里也再重述一次：
RTC                 =>    RPI(BCM)
VCC                 ->    3.3V/5V
GND                 ->    GND
SDA                 ->    2
SCL                 ->    3



3.安装库：
    sudo apt-get update
    sudo apt-get install python-pip
    sudo apt-get install python-pil
    sudo pip install RPi.GPIO
或

    sudo apt-get update
    sudo apt-get install python3-pip
    sudo apt-get install python3-pil
    sudo pip3 install RPi.GPIO

    
4.基本使用：
python2
    sudo python main.py

python3
    sudo python3 main.py