/*****************************************************************************
* | File      	:   Readme_CN.txt
* | Author      :   Waveshare team
* | Function    :   Help with use
* | Info        :
*----------------
* |	This version:   V1.0
* | Date        :   2023-09-11
* | Info        :   在这里提供一个中文版本的使用文档，以便你的快速使用
******************************************************************************/
这个文件是帮助您使用本例程。
在这里简略的描述本工程的使用：

1.基本信息：
本例程使用RTC WatchDog HAT (B)模块进行了验证，你可以在工程的examples\中查看对应的测试例程;

2.管脚连接：
管脚连接你可以在\lib\Config\DEV_Config.c中查看，这里也再重述一次：
RTC                 =>    RPI(BCM)
VCC                 ->    3.3V
GND                 ->    GND
SDA                 ->    2
SCL                 ->    3

3.安装库：
RPi
    安装bcm2835
        1.	#打开树莓派终端，并运行以下指令
        2.	wget http://www.airspayce.com/mikem/bcm2835/bcm2835-1.71.tar.gz
        3.	tar zxvf bcm2835-1.71.tar.gz 
        4.	cd bcm2835-1.71/
        5.	sudo ./configure && sudo make && sudo make check && sudo make install
        6.	# 更多的可以参考官网：http://www.airspayce.com/mikem/bcm2835/

    安装wiringPi
        1.	sudo apt install git-core
        2.	git clone https://gitee.com/study-dp/WiringPi.git
        3.	cd WiringPi
        4.	./build
        5.	#输入下面命令，显示软件版本，则安装成功
        6.	gpio -v
        7.	# 运行gpio -v会出现2.70版本，如果没有出现说明安装出错

在Makefile文件中有
    # USELIB = USE_BCM2835_LIB
    # USELIB = USE_WIRINGPI_LIB
    USELIB = USE_DEV_LIB
RPI 支持BCM2835_LIB、WIRINGPI和DEV_LIB

4.基本使用：
测试程序在examples\目录中查看
Run:
    make clean 
    make
    sudo ./main



