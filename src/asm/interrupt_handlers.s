/*
Here are some common GCC directives for ARM Cortex-M0 assembly:

.align: Specifies the byte alignment of the following instruction or data item.
.ascii: Specifies a string of characters to be included in the output file.
.asciz: Specifies a zero-terminated string of characters to be included in the output file.
.byte: Specifies one or more bytes of data to be included in the output file.
.data: Marks the start of a data section.
.global: Marks a symbol as visible outside of the current file.
.section: Specifies the section of memory where the following instructions or data items should be placed.
.space: Reserves a block of memory with a specified size.
.thumb: Instructs the assembler to generate Thumb code.
.thumb_func: Marks a function as using the Thumb instruction set.
.word: Specifies one or more words of data to be included in the output file.

Note that this is not an exhaustive list, and different versions of GCC may support additional or different directives.
*/
#include "iocon_11xx_asm.h"
#include "gpio_11xx_2_asm.h"

#define LED1_PORT LPC_GPIO_PORT0_BASE
#define LED1_BIT  7
#define LED2_PORT LPC_GPIO_PORT1_BASE
#define LED2_BIT  0
#define LED3_PORT LPC_GPIO_PORT1_BASE
#define LED3_BIT  4
#define LED4_PORT LPC_GPIO_PORT1_BASE
#define LED4_BIT  5

#define SW1_PORT	LPC_GPIO_PORT1_BASE
#define SW1_BIT 8
#define SW2_PORT	LPC_GPIO_PORT1_BASE
#define SW2_BIT 9
#define SW3_PORT LPC_GPIO_PORT0_BASE
#define SW3_BIT  1
#define SW4_PORT LPC_GPIO_PORT0_BASE
#define SW4_BIT  3

.extern led_timer;

    .syntax unified

.section .bss
    .align 2
    count:
    .space 2

    .text
    .global  SysTick_Handler
    .thumb_func
    .type	SysTick_Handler, %function
SysTick_Handler:
    push {r4, lr}
    ldr r5, =count
    ldr r4, [r5]
    adds r4, #1
    str r4, [r5]
    ldr r0, =led_timer
    ldr r1, [r0]
//  if (++count >= led_timer) {
    cmp r4, r1
    blt end
//    LPC_GPIO0->DATA ^= (1 << 7);
	ldr	r2, =LED1_PORT
	movs	r3, #(1<<LED1_BIT)
	lsls	r3, r3, #2
	ldr	r3, [r2, r3]
	ldr	r2, =LED1_PORT
	movs	r1, #(1<<LED1_BIT)
	eors	r1, r3
	movs	r3, #(1<<LED1_BIT)
	lsls	r3, r3, #2
	str	r1, [r2, r3]
//    LPC_GPIO1->DATA ^= (1 << 0);
	ldr	r3, =LED2_PORT
	ldr	r2, [r3, #4]
	ldr	r3, =LED2_PORT
	movs	r1, #(1<<LED2_BIT)
	eors	r2, r1
	str	r2, [r3, #4]
//    count = 0;
	movs r4, #0
   str r4, [r5]
end:
    pop {r4, pc}
	.size	SysTick_Handler, .-SysTick_Handler

     .text
    .global  PIOINT1_IRQHandler
	.thumb_func
    .type	PIOINT1_IRQHandler, %function
PIOINT1_IRQHandler:
	push	{lr}
	ldr		r3, =LPC_GPIO_PORT1_BASE
	ldr		r1, =GPIO_OFFSET_MIS
	ldr		r4, [r3, r1]
	ldr 	r3, =1 << SW1_BIT
	ands	r3, r4
	beq	CHECK_SW2
	movs	r3, #1
	lsls	r3, r3, #SW1_BIT
	ldr		r0, =SW1_PORT
	ldr		r1, =GPIO_OFFSET_IC
	str		r3, [r0, r1]
// led_timer = led_timer - 200;
	ldr	r3, =led_timer
	ldr	r3, [r3]
	subs	r3, r3, #200
	movs	r2, r3
	ldr	r3, =led_timer
	str	r2, [r3]
	ldr	r3, =led_timer
	ldr	r3, [r3]
// if (led_timer <= 0)
	cmp	r3, #0
	bne	CHECK_SW2
// led_timer = 1000;
	ldr	r3, =led_timer
	ldr		r2, =1000
	str	r2, [r3]
CHECK_SW2:
	movs	r3, #1
	lsls	r3, r3, #SW2_BIT
	ands	r3, r4
	beq	RETURN
	movs	r3, #1
	lsls	r3, r3, #SW2_BIT
	ldr		r0, =SW2_PORT
	ldr		r1, =GPIO_OFFSET_IC
	str		r3, [r0, r1]
RETURN:
	nop
	pop	{pc}
	.size	PIOINT1_IRQHandler, .-PIOINT1_IRQHandler

