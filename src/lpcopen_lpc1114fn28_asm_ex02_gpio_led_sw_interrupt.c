/*
===============================================================================
 Name        : lpcopen_lpc1114fn28_asm_ex02_gpio_led_sw_interrupt.c
 Author      : $(author)
 Version     :
 Copyright   : $(copyright)
 Description : main definition
===============================================================================
*/

#if defined (__USE_LPCOPEN)
#if defined(NO_BOARD_LIB)
#include "chip.h"
#else
#include "board.h"
#endif
#endif

#include <cr_section_macros.h>

// TODO: insert other include files here
#include "led.h"
#include "sw.h"

// TODO: insert other definitions and declarations here
extern void gpio_config_request(void);

volatile uint32_t led_timer = 1000;		// LED点滅設定 初期値 1000ms(1秒)毎

int main(void) {

#if defined (__USE_LPCOPEN)
    // Read clock settings and update SystemCoreClock variable
    SystemCoreClockUpdate();
#if !defined(NO_BOARD_LIB)
    // Set up and initialize all required blocks and
    // functions related to the board hardware
    Board_Init();
    // Set the LED to the state of "On"
    Board_LED_Set(0, true);
#endif
#endif

    // TODO: insert code here
	volatile static uint32_t period;


	gpio_config_request();
	NVIC_EnableIRQ(EINT1_IRQn);

	period = SystemCoreClock / 1000;
	SysTick_Config(period);

    // Force the counter to be placed into memory
    volatile static int i = 0 ;
    // Enter an infinite loop, just incrementing a counter
    while(1) {
		i++ ;
    	// "Dummy" NOP to allow source level single
    	// stepping of tight while() loop
    	__asm volatile ("nop");
    }
    return 0 ;
}
