	.arch armv5te
	.eabi_attribute 23, 1
	.eabi_attribute 24, 1
	.eabi_attribute 25, 1
	.eabi_attribute 26, 1
	.eabi_attribute 30, 6
	.eabi_attribute 34, 0
	.eabi_attribute 18, 4
	.file	"DETM.c"
	.text
	.align	2
	.global	det3
	.syntax unified
	.arm
	.fpu softvfp
	.type	det3, %function
det3:
	@ args = 0, pretend = 0, frame = 8
	@ frame_needed = 0, uses_anonymous_args = 0
	@ link register save eliminated.
	sub	sp, sp, #8
	str	r0, [sp, #4]
	ldr	r3, [sp, #4]
	ldrb	r3, [r3]	@ zero_extendqisi2
	mov	r2, r3
	ldr	r3, [sp, #4]
	add	r3, r3, #3
	ldrb	r3, [r3, #1]	@ zero_extendqisi2
	mov	r1, r3
	mul	r3, r2, r1
	ldr	r2, [sp, #4]
	add	r2, r2, #6
	ldrb	r2, [r2, #2]	@ zero_extendqisi2
	mov	r1, r2
	mul	r2, r3, r1
	ldr	r3, [sp, #4]
	ldrb	r3, [r3, #1]	@ zero_extendqisi2
	mov	r1, r3
	ldr	r3, [sp, #4]
	add	r3, r3, #3
	ldrb	r3, [r3, #2]	@ zero_extendqisi2
	mul	r0, r1, r3
	ldr	r1, [sp, #4]
	add	r1, r1, #6
	ldrb	r1, [r1]	@ zero_extendqisi2
	mul	r3, r1, r0
	add	r2, r2, r3
	ldr	r3, [sp, #4]
	add	r3, r3, #3
	ldrb	r3, [r3]	@ zero_extendqisi2
	mov	r1, r3
	ldr	r3, [sp, #4]
	add	r3, r3, #6
	ldrb	r3, [r3, #1]	@ zero_extendqisi2
	mul	r0, r1, r3
	ldr	r1, [sp, #4]
	ldrb	r1, [r1, #2]	@ zero_extendqisi2
	mul	r3, r1, r0
	add	r2, r2, r3
	ldr	r3, [sp, #4]
	ldrb	r3, [r3, #2]	@ zero_extendqisi2
	mov	r1, r3
	ldr	r3, [sp, #4]
	add	r3, r3, #3
	ldrb	r3, [r3, #1]	@ zero_extendqisi2
	mul	r0, r1, r3
	ldr	r1, [sp, #4]
	add	r1, r1, #6
	ldrb	r1, [r1]	@ zero_extendqisi2
	mul	r3, r1, r0
	sub	r2, r2, r3
	ldr	r3, [sp, #4]
	ldrb	r3, [r3, #1]	@ zero_extendqisi2
	mov	r1, r3
	ldr	r3, [sp, #4]
	add	r3, r3, #3
	ldrb	r3, [r3]	@ zero_extendqisi2
	mul	r0, r1, r3
	ldr	r1, [sp, #4]
	add	r1, r1, #6
	ldrb	r1, [r1, #2]	@ zero_extendqisi2
	mul	r3, r1, r0
	sub	r2, r2, r3
	ldr	r3, [sp, #4]
	add	r3, r3, #3
	ldrb	r3, [r3, #2]	@ zero_extendqisi2
	mov	r1, r3
	ldr	r3, [sp, #4]
	add	r3, r3, #6
	ldrb	r3, [r3, #1]	@ zero_extendqisi2
	mul	r0, r1, r3
	ldr	r1, [sp, #4]
	ldrb	r1, [r1]	@ zero_extendqisi2
	mul	r3, r1, r0
	sub	r3, r2, r3
	mov	r0, r3
	add	sp, sp, #8
	@ sp needed
	bx	lr
	.size	det3, .-det3
	.align	2
	.global	det4
	.syntax unified
	.arm
	.fpu softvfp
	.type	det4, %function
det4:
	@ args = 0, pretend = 0, frame = 48
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r4, r5, r6, r7, r8, fp, lr}
	add	fp, sp, #24
	sub	sp, sp, #52
	str	r0, [fp, #-72]
	mov	r3, sp
	mov	r8, r3
	mov	r3, #1
	str	r3, [fp, #-48]
	mov	r3, #4
	str	r3, [fp, #-52]
	mov	r3, #0
	str	r3, [fp, #-44]
	ldr	r3, [fp, #-52]
	sub	ip, r3, #1
	ldr	r3, [fp, #-52]
	sub	lr, r3, #1
	sub	r3, ip, #1
	str	r3, [fp, #-56]
	mov	r3, ip
	mov	r0, r3
	mov	r1, #0
	mov	r2, #0
	mov	r3, #0
	lsl	r3, r1, #3
	orr	r3, r3, r0, lsr #29
	lsl	r2, r0, #3
	mov	r6, ip
	sub	r3, lr, #1
	str	r3, [fp, #-60]
	mov	r3, ip
	mov	r4, r3
	mov	r5, #0
	mov	r3, lr
	mov	r0, r3
	mov	r1, #0
	mul	r2, r0, r5
	mul	r3, r4, r1
	add	r7, r2, r3
	umull	r2, r3, r4, r0
	add	r1, r7, r3
	mov	r3, r1
	mov	r0, #0
	mov	r1, #0
	lsl	r1, r3, #3
	orr	r1, r1, r2, lsr #29
	lsl	r0, r2, #3
	mov	r3, ip
	mov	r4, r3
	mov	r5, #0
	mov	r3, lr
	mov	r0, r3
	mov	r1, #0
	mul	r2, r0, r5
	mul	r3, r4, r1
	add	r7, r2, r3
	umull	r2, r3, r4, r0
	add	r1, r7, r3
	mov	r3, r1
	mov	r0, #0
	mov	r1, #0
	lsl	r1, r3, #3
	orr	r1, r1, r2, lsr #29
	lsl	r0, r2, #3
	mov	r1, ip
	mov	r2, lr
	mul	r3, r2, r1
	add	r3, r3, #7
	lsr	r3, r3, #3
	lsl	r3, r3, #3
	sub	sp, sp, r3
	mov	r3, sp
	add	r3, r3, #0
	str	r3, [fp, #-64]
	mov	r3, #0
	str	r3, [fp, #-40]
	b	.L4
.L11:
	mov	r3, #0
	str	r3, [fp, #-36]
	b	.L5
.L10:
	mov	r3, #0
	str	r3, [fp, #-32]
	b	.L6
.L9:
	ldr	r2, [fp, #-32]
	ldr	r3, [fp, #-40]
	cmp	r2, r3
	bge	.L7
	ldr	r3, [fp, #-36]
	add	r3, r3, #1
	lsl	r3, r3, #2
	ldr	r2, [fp, #-72]
	add	r2, r2, r3
	ldr	r3, [fp, #-32]
	add	r3, r2, r3
	ldrb	r1, [r3]	@ zero_extendqisi2
	ldr	r2, [fp, #-64]
	ldr	r3, [fp, #-36]
	mul	r0, r6, r3
	add	r2, r2, r0
	ldr	r3, [fp, #-32]
	add	r3, r2, r3
	mov	r2, r1
	strb	r2, [r3]
	b	.L8
.L7:
	ldr	r3, [fp, #-36]
	add	r3, r3, #1
	lsl	r3, r3, #2
	ldr	r2, [fp, #-72]
	add	r2, r2, r3
	ldr	r3, [fp, #-32]
	add	r3, r3, #1
	ldrb	r1, [r2, r3]	@ zero_extendqisi2
	ldr	r2, [fp, #-64]
	ldr	r3, [fp, #-36]
	mul	r0, r6, r3
	add	r2, r2, r0
	ldr	r3, [fp, #-32]
	add	r3, r2, r3
	mov	r2, r1
	strb	r2, [r3]
.L8:
	ldr	r3, [fp, #-32]
	add	r3, r3, #1
	str	r3, [fp, #-32]
.L6:
	ldr	r2, [fp, #-32]
	ldr	r3, [fp, #-52]
	cmp	r2, r3
	blt	.L9
	ldr	r3, [fp, #-36]
	add	r3, r3, #1
	str	r3, [fp, #-36]
.L5:
	ldr	r2, [fp, #-36]
	ldr	r3, [fp, #-52]
	cmp	r2, r3
	blt	.L10
	ldr	r2, [fp, #-72]
	ldr	r3, [fp, #-40]
	add	r3, r2, r3
	ldrb	r3, [r3]	@ zero_extendqisi2
	mov	r2, r3
	ldr	r3, [fp, #-48]
	mul	r4, r3, r2
	ldr	r3, [fp, #-64]
	mov	r0, r3
	bl	det3
	mov	r2, r0
	mul	r3, r4, r2
	ldr	r2, [fp, #-44]
	add	r3, r2, r3
	str	r3, [fp, #-44]
	ldr	r3, [fp, #-48]
	rsb	r3, r3, #0
	str	r3, [fp, #-48]
	ldr	r3, [fp, #-40]
	add	r3, r3, #1
	str	r3, [fp, #-40]
.L4:
	ldr	r2, [fp, #-40]
	ldr	r3, [fp, #-52]
	cmp	r2, r3
	blt	.L11
	ldr	r3, [fp, #-44]
	mov	sp, r8
	mov	r0, r3
	sub	sp, fp, #24
	@ sp needed
	pop	{r4, r5, r6, r7, r8, fp, pc}
	.size	det4, .-det4
	.align	2
	.global	det5
	.syntax unified
	.arm
	.fpu softvfp
	.type	det5, %function
det5:
	@ args = 0, pretend = 0, frame = 48
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r4, r5, r6, r7, r8, fp, lr}
	add	fp, sp, #24
	sub	sp, sp, #52
	str	r0, [fp, #-72]
	mov	r3, sp
	mov	r8, r3
	mov	r3, #1
	str	r3, [fp, #-48]
	mov	r3, #5
	str	r3, [fp, #-52]
	mov	r3, #0
	str	r3, [fp, #-44]
	ldr	r3, [fp, #-52]
	sub	ip, r3, #1
	ldr	r3, [fp, #-52]
	sub	lr, r3, #1
	sub	r3, ip, #1
	str	r3, [fp, #-56]
	mov	r3, ip
	mov	r0, r3
	mov	r1, #0
	mov	r2, #0
	mov	r3, #0
	lsl	r3, r1, #3
	orr	r3, r3, r0, lsr #29
	lsl	r2, r0, #3
	mov	r6, ip
	sub	r3, lr, #1
	str	r3, [fp, #-60]
	mov	r3, ip
	mov	r4, r3
	mov	r5, #0
	mov	r3, lr
	mov	r0, r3
	mov	r1, #0
	mul	r2, r0, r5
	mul	r3, r4, r1
	add	r7, r2, r3
	umull	r2, r3, r4, r0
	add	r1, r7, r3
	mov	r3, r1
	mov	r0, #0
	mov	r1, #0
	lsl	r1, r3, #3
	orr	r1, r1, r2, lsr #29
	lsl	r0, r2, #3
	mov	r3, ip
	mov	r4, r3
	mov	r5, #0
	mov	r3, lr
	mov	r0, r3
	mov	r1, #0
	mul	r2, r0, r5
	mul	r3, r4, r1
	add	r7, r2, r3
	umull	r2, r3, r4, r0
	add	r1, r7, r3
	mov	r3, r1
	mov	r0, #0
	mov	r1, #0
	lsl	r1, r3, #3
	orr	r1, r1, r2, lsr #29
	lsl	r0, r2, #3
	mov	r1, ip
	mov	r2, lr
	mul	r3, r2, r1
	add	r3, r3, #7
	lsr	r3, r3, #3
	lsl	r3, r3, #3
	sub	sp, sp, r3
	mov	r3, sp
	add	r3, r3, #0
	str	r3, [fp, #-64]
	mov	r3, #0
	str	r3, [fp, #-40]
	b	.L14
.L21:
	mov	r3, #0
	str	r3, [fp, #-36]
	b	.L15
.L20:
	mov	r3, #0
	str	r3, [fp, #-32]
	b	.L16
.L19:
	ldr	r2, [fp, #-32]
	ldr	r3, [fp, #-40]
	cmp	r2, r3
	bge	.L17
	ldr	r3, [fp, #-36]
	add	r2, r3, #1
	mov	r3, r2
	lsl	r3, r3, #2
	add	r3, r3, r2
	ldr	r2, [fp, #-72]
	add	r2, r2, r3
	ldr	r3, [fp, #-32]
	add	r3, r2, r3
	ldrb	r1, [r3]	@ zero_extendqisi2
	ldr	r2, [fp, #-64]
	ldr	r3, [fp, #-36]
	mul	r0, r6, r3
	add	r2, r2, r0
	ldr	r3, [fp, #-32]
	add	r3, r2, r3
	mov	r2, r1
	strb	r2, [r3]
	b	.L18
.L17:
	ldr	r3, [fp, #-36]
	add	r2, r3, #1
	mov	r3, r2
	lsl	r3, r3, #2
	add	r3, r3, r2
	ldr	r2, [fp, #-72]
	add	r2, r2, r3
	ldr	r3, [fp, #-32]
	add	r3, r3, #1
	ldrb	r1, [r2, r3]	@ zero_extendqisi2
	ldr	r2, [fp, #-64]
	ldr	r3, [fp, #-36]
	mul	r0, r6, r3
	add	r2, r2, r0
	ldr	r3, [fp, #-32]
	add	r3, r2, r3
	mov	r2, r1
	strb	r2, [r3]
.L18:
	ldr	r3, [fp, #-32]
	add	r3, r3, #1
	str	r3, [fp, #-32]
.L16:
	ldr	r2, [fp, #-32]
	ldr	r3, [fp, #-52]
	cmp	r2, r3
	blt	.L19
	ldr	r3, [fp, #-36]
	add	r3, r3, #1
	str	r3, [fp, #-36]
.L15:
	ldr	r2, [fp, #-36]
	ldr	r3, [fp, #-52]
	cmp	r2, r3
	blt	.L20
	ldr	r2, [fp, #-72]
	ldr	r3, [fp, #-40]
	add	r3, r2, r3
	ldrb	r3, [r3]	@ zero_extendqisi2
	mov	r2, r3
	ldr	r3, [fp, #-48]
	mul	r4, r3, r2
	ldr	r3, [fp, #-64]
	mov	r0, r3
	bl	det4
	mov	r2, r0
	mul	r3, r4, r2
	ldr	r2, [fp, #-44]
	add	r3, r2, r3
	str	r3, [fp, #-44]
	ldr	r3, [fp, #-48]
	rsb	r3, r3, #0
	str	r3, [fp, #-48]
	ldr	r3, [fp, #-40]
	add	r3, r3, #1
	str	r3, [fp, #-40]
.L14:
	ldr	r2, [fp, #-40]
	ldr	r3, [fp, #-52]
	cmp	r2, r3
	blt	.L21
	ldr	r3, [fp, #-44]
	mov	sp, r8
	mov	r0, r3
	sub	sp, fp, #24
	@ sp needed
	pop	{r4, r5, r6, r7, r8, fp, pc}
	.size	det5, .-det5
	.section	.rodata
	.align	2
.LC0:
	.ascii	"%1-- Programa DETM  -  PID %2(%d) %1--\012\000"
	.align	2
.LC1:
	.ascii	"%1(%d)\011%2Element: %3%d\012\000"
	.align	2
.LC2:
	.ascii	"%1(%d)\011%2DETERMINANT = %3%d\012\000"
	.align	2
.LC3:
	.ascii	"%1(%d)\011%2DETERMINANT = %3-%d\012\000"
	.text
	.align	2
	.global	_start
	.syntax unified
	.arm
	.fpu softvfp
	.type	_start, %function
_start:
	@ args = 0, pretend = 0, frame = 40
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r4, r5, r6, r7, r8, fp, lr}
	add	fp, sp, #24
	sub	sp, sp, #44
	str	r0, [fp, #-64]
	mov	r3, sp
	mov	r8, r3
	ldr	r3, [fp, #-64]
	cmp	r3, #0
	bge	.L24
	mov	r3, #0
	str	r3, [fp, #-64]
	b	.L25
.L24:
	ldr	r3, [fp, #-64]
	cmp	r3, #3
	ble	.L25
	mov	r3, #3
	str	r3, [fp, #-64]
.L25:
	ldr	r3, [fp, #-64]
	add	r3, r3, #2
	str	r3, [fp, #-44]
	ldr	ip, [fp, #-44]
	ldr	lr, [fp, #-44]
	sub	r3, ip, #1
	str	r3, [fp, #-48]
	mov	r3, ip
	mov	r0, r3
	mov	r1, #0
	mov	r2, #0
	mov	r3, #0
	lsl	r3, r1, #3
	orr	r3, r3, r0, lsr #29
	lsl	r2, r0, #3
	mov	r6, ip
	sub	r3, lr, #1
	str	r3, [fp, #-52]
	mov	r3, ip
	mov	r4, r3
	mov	r5, #0
	mov	r3, lr
	mov	r0, r3
	mov	r1, #0
	mul	r2, r0, r5
	mul	r3, r4, r1
	add	r7, r2, r3
	umull	r2, r3, r4, r0
	add	r1, r7, r3
	mov	r3, r1
	mov	r0, #0
	mov	r1, #0
	lsl	r1, r3, #3
	orr	r1, r1, r2, lsr #29
	lsl	r0, r2, #3
	mov	r3, ip
	mov	r4, r3
	mov	r5, #0
	mov	r3, lr
	mov	r0, r3
	mov	r1, #0
	mul	r2, r0, r5
	mul	r3, r4, r1
	add	r7, r2, r3
	umull	r2, r3, r4, r0
	add	r1, r7, r3
	mov	r3, r1
	mov	r0, #0
	mov	r1, #0
	lsl	r1, r3, #3
	orr	r1, r1, r2, lsr #29
	lsl	r0, r2, #3
	mov	r1, ip
	mov	r2, lr
	mul	r3, r2, r1
	add	r3, r3, #7
	lsr	r3, r3, #3
	lsl	r3, r3, #3
	sub	sp, sp, r3
	mov	r3, sp
	add	r3, r3, #0
	str	r3, [fp, #-56]
	bl	GARLIC_clear
	bl	GARLIC_pid
	mov	r3, r0
	mov	r1, r3
	ldr	r0, .L41
	bl	GARLIC_printf
	mov	r3, #0
	str	r3, [fp, #-36]
	b	.L26
.L29:
	mov	r3, #0
	str	r3, [fp, #-32]
	b	.L27
.L28:
	bl	GARLIC_random
	mov	r1, r0
	ldr	r0, .L41+4
	smull	r2, r3, r1, r0
	asr	r2, r3, #2
	asr	r3, r1, #31
	sub	r2, r2, r3
	mov	r3, r2
	lsl	r3, r3, #2
	add	r3, r3, r2
	lsl	r3, r3, #1
	sub	r2, r1, r3
	and	r1, r2, #255
	ldr	r2, [fp, #-56]
	ldr	r3, [fp, #-36]
	mul	r0, r6, r3
	add	r2, r2, r0
	ldr	r3, [fp, #-32]
	add	r3, r2, r3
	mov	r2, r1
	strb	r2, [r3]
	ldr	r3, [fp, #-32]
	add	r3, r3, #1
	str	r3, [fp, #-32]
.L27:
	ldr	r2, [fp, #-32]
	ldr	r3, [fp, #-44]
	cmp	r2, r3
	blt	.L28
	ldr	r3, [fp, #-36]
	add	r3, r3, #1
	str	r3, [fp, #-36]
.L26:
	ldr	r2, [fp, #-36]
	ldr	r3, [fp, #-44]
	cmp	r2, r3
	blt	.L29
	mov	r3, #0
	str	r3, [fp, #-36]
	b	.L30
.L33:
	mov	r3, #0
	str	r3, [fp, #-32]
	b	.L31
.L32:
	ldr	r3, [fp, #-64]
	rsb	r3, r3, #4
	mov	r0, r3
	bl	GARLIC_delay
	bl	GARLIC_pid
	mov	r1, r0
	ldr	r2, [fp, #-56]
	ldr	r3, [fp, #-36]
	mul	r0, r6, r3
	add	r2, r2, r0
	ldr	r3, [fp, #-32]
	add	r3, r2, r3
	ldrb	r3, [r3]	@ zero_extendqisi2
	mov	r2, r3
	ldr	r0, .L41+8
	bl	GARLIC_printf
	ldr	r3, [fp, #-32]
	add	r3, r3, #1
	str	r3, [fp, #-32]
.L31:
	ldr	r2, [fp, #-32]
	ldr	r3, [fp, #-44]
	cmp	r2, r3
	blt	.L32
	ldr	r3, [fp, #-36]
	add	r3, r3, #1
	str	r3, [fp, #-36]
.L30:
	ldr	r2, [fp, #-36]
	ldr	r3, [fp, #-44]
	cmp	r2, r3
	blt	.L33
	mvn	r3, #9
	str	r3, [fp, #-40]
	ldr	r3, [fp, #-44]
	cmp	r3, #2
	bne	.L34
	ldr	r3, [fp, #-56]
	ldrb	r3, [r3]	@ zero_extendqisi2
	mov	r1, r3
	ldr	r3, [fp, #-56]
	add	r3, r3, r6
	ldrb	r3, [r3, #1]	@ zero_extendqisi2
	mul	r2, r3, r1
	ldr	r3, [fp, #-56]
	ldrb	r3, [r3, #1]	@ zero_extendqisi2
	mov	r1, r3
	ldr	r3, [fp, #-56]
	ldrb	r3, [r3, r6]	@ zero_extendqisi2
	mov	r0, r3
	mul	r3, r1, r0
	sub	r3, r2, r3
	str	r3, [fp, #-40]
	b	.L35
.L34:
	ldr	r3, [fp, #-44]
	cmp	r3, #3
	bne	.L36
	ldr	r3, [fp, #-56]
	mov	r0, r3
	bl	det3
	str	r0, [fp, #-40]
	b	.L35
.L36:
	ldr	r3, [fp, #-44]
	cmp	r3, #4
	bne	.L37
	ldr	r3, [fp, #-56]
	mov	r0, r3
	bl	det4
	str	r0, [fp, #-40]
	b	.L35
.L37:
	ldr	r3, [fp, #-56]
	mov	r0, r3
	bl	det5
	str	r0, [fp, #-40]
.L35:
	ldr	r3, [fp, #-40]
	cmp	r3, #0
	blt	.L38
	bl	GARLIC_pid
	mov	r3, r0
	ldr	r2, [fp, #-40]
	mov	r1, r3
	ldr	r0, .L41+12
	bl	GARLIC_printf
	b	.L39
.L38:
	bl	GARLIC_pid
	mov	r1, r0
	ldr	r3, [fp, #-40]
	rsb	r3, r3, #0
	mov	r2, r3
	ldr	r0, .L41+16
	bl	GARLIC_printf
.L39:
	mov	r3, #0
	mov	sp, r8
	mov	r0, r3
	sub	sp, fp, #24
	@ sp needed
	pop	{r4, r5, r6, r7, r8, fp, pc}
.L42:
	.align	2
.L41:
	.word	.LC0
	.word	1717986919
	.word	.LC1
	.word	.LC2
	.word	.LC3
	.size	_start, .-_start
	.ident	"GCC: (devkitARM release 47) 7.1.0"
