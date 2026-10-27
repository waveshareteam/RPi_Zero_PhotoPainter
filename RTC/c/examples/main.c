#include <stdio.h>      //printf()
#include <stdlib.h>     //exit()
#include <signal.h>
 #include <stdio.h>
 #include <string.h>
#include "DEV_Config.h"
#include "DS3231.h"

char  *str[]  ={"SUN","Mon","Tues","Wed","Thur","Fri","Sat"};
void  Handler(int signo)
{
    //System Exit
    printf("\r\nHandler:Program stop\r\n"); 

    DEV_ModuleExit();

    exit(0);
}


int main(int argc, char **argv)
{
    // Exception handling:ctrl + c
    signal(SIGINT, Handler);
    
	if (DEV_ModuleInit()==1)return 1;
    
    DEV_I2C_Init(DS3231_Address);
    
    DS3231_SET_Hour_Mode(24);
    DS3231_SET_Calendar(2099,12,31);
    DS3231_SET_Day(7);
    DS3231_SET_Time(23,59,50);
    
    UWORD Calendar[3] = {0,0,0};
    UBYTE Time[3] = {0,0,0};
    while(1){
        printf("Day  %d\r\n",DS3231_Read_Day());
        
        
        DS3231_Read_Calendar(Calendar);
        printf ("Calendar %d %d %d\r\n",Calendar[0],Calendar[1],Calendar[2]);
        
        
        DS3231_Read_Time(Time);
        printf("hour : %d : %d : %d \r\n",Time[0],Time[1],Time[2]);
        
        // printf("hour : ,x : ,x : ,x \r\n",(RTC.Read_Time_Hour_BCD(),RTC.Read_Time_Min_BCD(),RTC.Read_Time_Sec_BCD()))
        printf("temperature : %0.2f Celsius\r\n\r\n",DS3231_Read_Temperature());
        DEV_Delay_ms(1000);
    }

	DEV_ModuleExit();
    return 0; 
}
