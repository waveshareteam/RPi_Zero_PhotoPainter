import logging
import os
import logging
import sys

logging.basicConfig(level=logging.INFO)
libdir = os.path.join(os.path.dirname(os.path.dirname(os.path.realpath(__file__))), 'lib')
if os.path.exists(libdir):
	sys.path.append(libdir)

import time
from waveshare_DS3231 import DS3231

RTC = DS3231.DS3231(add = 0x68)
RTC.SET_Hour_Mode(24)

time.sleep(1)
RTC.Read_Calendar()
t="%02x-%02x-%02x"%(RTC.Read_Year_BCD(),RTC.Read_Month_BCD(),RTC.Read_Date_BCD())
# print(t)
os.system("sudo date -s %s"%(t))
time.sleep(1)
h="%x:%x:%x"%(RTC.Read_Time_Hour_BCD(),RTC.Read_Time_Min_BCD(),RTC.Read_Time_Sec_BCD())
# print(h)
os.system("sudo date -s %s"%(h))

#t="%02x-%02x-%02x"%(RTC.Read_Year_BCD(),RTC.Read_Month_BCD(),RTC.Read_Date_BCD())
#print(t)
#os.system("sudo date -s %s"%(t))
