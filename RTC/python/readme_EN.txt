/*****************************************************************************
* | File      	:   Readme_CN.txt
* | Author      :   Waveshare team
* | Function    :   Help with use
* | Info        :
*----------------
* |	This version:   V1.0
* | Date        :   2021-07-27
* | Info        :   Here is an English version of the documentation for your quick use.
******************************************************************************/
This file is to help you use this Demo.
A brief description of the use of this project is here:

1. Basic information:
This routine has been verified on the RTC WatchDog HAT
You can view the corresponding test routines in the examples\ of the project;

2. Pin connection:
Pin connections can be viewed in \lib\waveshare_DS3231\config.py and will be repeated here:
RTC                 =>    RPI(BCM)
VCC                 ->    3.3V/5V
GND                 ->    GND
SDA                 ->    2
SCL                 ->    3



3.Installation library
    sudo apt-get update
    sudo apt-get install python-pip
    sudo apt-get install python-pil
    sudo pip install RPi.GPIO


or
    sudo apt-get update
    sudo apt-get install python3-pip
    sudo apt-get install python3-pil
    sudo pip3 install RPi.GPIO


4. Basic use:
python2
    sudo python main.py

python3
    sudo python3 main.py