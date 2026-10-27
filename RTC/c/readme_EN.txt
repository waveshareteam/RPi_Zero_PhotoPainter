/*****************************************************************************
* | File      	:   Readme_CN.txt
* | Author      :   Waveshare team
* | Function    :   Help with use
* | Info        :
*----------------
* |	This version:   V1.0
* | Date        :   2023-09-11
* | Info        :   Here is an English version of the documentation for your quick use.
******************************************************************************/
This file is to help you use this Demo.
A brief description of the use of this project is here:

1. Basic information:
This Demo has been verified using the RTC WatchDog HAT (B). 
You can view the corresponding test routines in the examples\ of the project;

2. Pin connection:
Pin connections can be viewed in lib Config DEV_Config.C. Here again:
RTC                 =>    RPI(BCM)
VCC                 ->    3.3V
GND                 ->    GND
SDA                 ->    2
SCL                 ->    3

    
3.Installation library
RPi
    Installation bcm2835
        1.	#Open the Raspberry Pi terminal and run the following command
        2.	wget http://www.airspayce.com/mikem/bcm2835/bcm2835-1.71.tar.gz
        3.	tar zxvf bcm2835-1.71.tar.gz 
        4.	cd bcm2835-1.71/
        5.	sudo ./configure && sudo make && sudo make check && sudo make install
        6.	# For more, you can refer to the official website at: http://www.airspayce.com/mikem/bcm2835/

    Installation wiringPi
        1.	sudo apt install git-core
        2.	git clone https://gitee.com/study-dp/WiringPi.git
        3.	cd WiringPi
        4.	./build
        5.	#Enter the following command to display the software version, then the installation is successful
        6.	gpio -v
        7.	# Running gpio -v will appear version 2.70, if there is no error, the installation is wrong.
    
In the Makefile
    # USELIB = USE_BCM2835_LIB
    # USELIB = USE_WIRINGPI_LIB
    USELIB = USE_DEV_LIB
RPi stand by BCM2835_LIB and WIRINGPI and DEV_LIB

4. Basic use:
Test the program in the examples\ directory:
    make clean 
    make
    sudo ./main