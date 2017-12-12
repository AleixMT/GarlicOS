@;==============================================================================
@;
@;	"garlic_itcm_proc.s":	c�digo de las funciones de control de procesos (1.0)
@;						(ver "garlic_system.h" para descripci�n de funciones)
@;
@;==============================================================================

.section .itcm,"ax",%progbits

	.arm
	.align 2
	
	
	.global _gp_WaitForVBlank
	@; rutina para pausar el procesador mientras no se produzca una interrupci�n
	@; de retrazado vertical (VBL); es un sustituto de la "swi #5", que evita
	@; la necesidad de cambiar a modo supervisor en los procesos GARLIC
_gp_WaitForVBlank:
	push {r0-r1, lr}
	ldr r0, =__irq_flags
.Lwait_espera:
	mcr p15, 0, lr, c7, c0, 4	@; HALT (suspender hasta nueva interrupci�n)
	ldr r1, [r0]			@; R1 = [__irq_flags]
	tst r1, #1				@; comprobar flag IRQ_VBL
	beq .Lwait_espera		@; repetir bucle mientras no exista IRQ_VBL
	bic r1, #1
	str r1, [r0]			@; poner a cero el flag IRQ_VBL
	pop {r0-r1, pc}


	.global _gp_IntrMain
	@; Manejador principal de interrupciones del sistema Garlic
_gp_IntrMain:
	mov	r12, #0x4000000
	add	r12, r12, #0x208	@; R12 = base registros de control de interrupciones	
	ldr	r2, [r12, #0x08]	@; R2 = REG_IE (m�scara de bits con int. permitidas)
	ldr	r1, [r12, #0x0C]	@; R1 = REG_IF (m�scara de bits con int. activas)
	and r1, r1, r2			@; filtrar int. activas con int. permitidas
	ldr	r2, =irqTable
.Lintr_find:				@; buscar manejadores de interrupciones espec�ficos
	ldr r0, [r2, #4]		@; R0 = m�scara de int. del manejador indexado
	cmp	r0, #0				@; si m�scara = cero, fin de vector de manejadores
	beq	.Lintr_setflags		@; (abandonar bucle de b�squeda de manejador)
	ands r0, r0, r1			@; determinar si el manejador indexado atiende a una
	beq	.Lintr_cont1		@; de las interrupciones activas
	ldr	r3, [r2]			@; R3 = direcci�n de salto del manejador indexado
	cmp	r3, #0
	beq	.Lintr_ret			@; abandonar si direcci�n = 0
	mov r2, lr				@; guardar direcci�n de retorno
	blx	r3					@; invocar el manejador indexado
	mov lr, r2				@; recuperar direcci�n de retorno
	b .Lintr_ret			@; salir del bucle de b�squeda
.Lintr_cont1:	
	add	r2, r2, #8			@; pasar al siguiente �ndice del vector de
	b	.Lintr_find			@; manejadores de interrupciones espec�ficas
.Lintr_ret:
	mov r1, r0				@; indica qu� interrupci�n se ha servido
.Lintr_setflags:
	str	r1, [r12, #0x0C]	@; REG_IF = R1 (comunica interrupci�n servida)
	ldr	r0, =__irq_flags	@; R0 = direcci�n flags IRQ para gesti�n IntrWait
	ldr	r3, [r0]
	orr	r3, r3, r1			@; activar el flag correspondiente a la interrupci�n
	str	r3, [r0]			@; servida (todas si no se ha encontrado el maneja-
							@; dor correspondiente)
	mov	pc,lr				@; retornar al gestor de la excepci�n IRQ de la BIOS


	.global _gp_rsiTIMER0
	@; Rutina de Servicio de Interrupci�n (RSI) para contabilizar los tics
	@; de trabajo de cada proceso: suma los tics de todos los procesos y calcula
	@; el porcentaje de uso de la CPU, que se guarda en los 8 bits altos de la
	@; entrada _gd_pcbs[z].workTicks de cada proceso (z) y, si el procesador
	@; gr�fico secundario est� correctamente configurado, se imprime en la
	@; columna correspondiente de la tabla de procesos.
	@; ...
	@; Manegador de interrupcions del timer 0 de Garlic:
	@; se enacrrega de generar el percentatge d'�s de la CPU.
_gp_rsiTIMER0:
	push {r0-r10, lr}
	ldr r9, =_gd_pcbs		@; r9 = direcci� del array de PCBs
	mov r10, #24			@; r10 = despla�ament necess�ri per saltar del pcb d'un proc�s a un altre
	ldr r1, [r9, #20]		@; r1 = workTics del SO
	and r1, r1, #0x00FFFFFF	@; r1 = sera el total de tics de tots els processos
	mov r5, #1				@; r5 = z�calo, recorrem tots els processos actius
.L_bucle_rsiT0_contarTics:
	mla r4, r5, r10, r9		@; despla�ament per arrivar al PCB del z�calo actual: num de z�calo * 24 + direcci� _gd_pcbs, on 24 es la mida de cada PCB (6 ints, 6 * 4 bytes per int)
	ldr r6, [r4]			@; carreguem el pid del proc�s actual
	cmp r6, #0				@; si no hi ha cap proc�s executant-se en aquest z�calo passem al seg�ent
	beq .L_bucle_rsiT0_contarTics_seguent	@; passem al seg�ent PCB
	ldr r6, [r4, #20]		@; carreguem el valor de workTicks
	and r6, r6, #0x00FFFFFF	@; obtenim els workTicks
	add r1, r6				@; sumem els workTicks del proc�s als globals
.L_bucle_rsiT0_contarTics_seguent:
	add r5, #1				@; passem al seg�ent z�calo
	cmp r5, #15				@; mirem que no els haguem comprovat tots
	ble .L_bucle_rsiT0_contarTics	@; si no els hem mirat tots, continua el bucle
	
	@; posem a 0 els tics de cada proc�s i guardem el percentatge de cpu en els 8 bits alts
	@; suposem que a r4 tinc el percentatge de CPU
	mov r5, #100			@; r5 = 100
	add r2, r9, #20			@; r2 = posici� de la variable workTics
	ldr r0, [r2]			@; workTics + % del SO
	and r0, r0, #0x00FFFFFF	@; r0 = workTics del SO
	mul r0, r5				@; r0 = tics * 100
	ldr r3, =_gd_res		@; r3 = variable on guardem el residu
	bl _ga_divmod			@; guardar� en el cap worktics dl pcb del proc�s
	mov r8, #0				@; punter al z�calo actual
	b .L_rsiT0_escriurePercentatge
	
.L_rsiT0_escriurePercentatge_bucle:
	mla r4, r8, r10, r9		@; despla�ament per arrivar al PCB del z�calo actual: num de z�calo * 24 + direcci� _gd_pcbs, on 24 es la mida de cada PCB (6 ints, 6 * 4 bytes per int)
	ldr r6, [r4]			@; carreguem el pid del proc�s actual
	cmp r6, #0				@; si no hi ha cap proc�s executant-se en aquest z�calo passem al seg�ent
	beq .L_rsiT0_escriurePercentatge_seguent	@; passem al seg�ent PCB
	add r2, r4, #20			@; r2 = posici� de la variable workTics
	ldr r0, [r2]			@; workTics + % del proc�s
	and r0, r0, #0x00FFFFFF	@; r0 = workTics
	mul r0, r5				@; r0 = tics * 100
	ldr r3, =_gd_res		@; r3 = variable on guardem el residu
	bl _ga_divmod			@; guardar� en el cap worktics dl pcb del proc�s
	
	@; escriure el percentatge de CPU en la pantalla inferior de la NDS
.L_rsiT0_escriurePercentatge:
	mov r7, r1				@; guardem a r7 els tics totals
	ldr r3, [r2]			@; r3 = carreguem el %
	lsl r4, r3, #24			@; desplacem el % als 8 bits alts
	str r4, [r2]			@; guardem el % en la posici� correcta en la variable workTics
	ldr r0, =_gd_percentatge	@; r0 = string on guardarem el % del CPU
	mov r1, #4				@; r1 = longitud de l'String
	mov r2, r3				@; r2 = %
	bl _gs_num2str_dec		@; convertim el percentatge a String
	ldr r0, =_gd_percentatge	@; r0 = string on guardarem el % del CPU, ja que _gs_num2str_dec maxaca r0
	add r1, r8, #4			@; r1 = fila, z�calo +4
	mov r2, #28				@; r2 = columna
	mov r3, #0				@; r3 = color
	bl _gs_escribirStringSub	@; escribim el % en la taula
	mov r1, r7				@; recuperem a r1 els worktics totals
.L_rsiT0_escriurePercentatge_seguent:
	add r8, #1
	cmp r8, #15
	ble .L_rsiT0_escriurePercentatge_bucle
	
	@; posem a 1 el bit 0 de la variable global _gd_sincMain
	ldr r0, =_gd_sincMain
	ldr r1, [r0]
	orr r1, #1
	str r1, [r0]
	
	pop {r0-r10, pc}
	
	
	.global _gp_rsiVBL
	@; Manejador de interrupciones VBL (Vertical BLank) de Garlic:
	@; se encarga de actualizar los tics, intercambiar procesos, etc.
_gp_rsiVBL:
	push {r4-r7, lr}
	ldr r4, =_gd_tickCount	@; obtenim pa posici� de la variable _tickCount
	ldr r5,[r4]				@; obtenim el nombre de tics en r5
	add r5, r5, #1			@; incrementem el nombre de tics en 1
	str r5, [r4]			@; actualitzem la variable _tickCount
	@; cridem funci� per disminuir els tics dels processos retardats
	bl _gp_actualizarDelay	@; cirdem nova funci� per actualitzar els processos retardats
	
	ldr r4, =_gd_nReady		@; obtenim la posici� de la variable _gd_nReady
	ldr r5, [r4]			@; r1= processos en la cola de ready
	cmp r5, #0				@; mirem si hi ha processos en la cua
	beq .Lfi_rsiVBL			@; sortim de la RSI sense dur a terme un canvi de context
	ldr r4, =_gd_pidz		@; obtim la variable _gd_pidz on hi ha (Identificador de proceso + z�calo actual)
	ldr r5, [r4]			@; obtenim l'identificador del proc�s
	cmp r5, #0				@; mirem si el proc�s en execuci� �s el SO
	beq .Lrsi_salvar_context	@; si ho �s passem directament a salvar el seu context
	lsr r5, #4				@; mirem el cas que no sigui un proc�s que ha acabat, pid=0, per fer-ho desplacem els 4 bits de menys pes (z�calo)
	cmp r5, #0				@; comprobem que el pid no sigui 0
	beq .Lrsi_restauraProc	@; si ho �s no salvem el context
.Lrsi_salvar_context:
	ldr r4, =_gd_nReady		@; r4= direcci� de _gd_nready
	ldr r5, [r4]			@; r5= n�m de processos en Ready
	ldr r6, =_gd_pidz		@; r6= direcci� de _gd_pidz
	bl _gp_salvarProc		@; cridem la funci� salvar context amb els par�metres en els registres que toca
	str r5, [r4]			@; Actualitzem el num de processos en la cua de Ready, valor que ens retorna la funci� 
.Lrsi_restauraProc:
	ldr r4, =_gd_nReady		@; r4= direcci� de _gd_nready
	ldr r5, [r4]			@; r5= n�m de processos en Ready
	ldr r6, =_gd_pidz		@; r6= direcci� de _gd_pidz
	bl _gp_restaurarProc	@;cridem la funci� restaurar context amb els par�metres en els registres que toca
	
.Lfi_rsiVBL:
	@;incrementem el _gd_pcbs[z].workTicks del proceso que entra en ejecuci�n.
	ldr r6, =_gd_pidz		@; r6= direcci� de _gd_pidz
	ldr r4, [r6]			@; r4 = pidz
	and r4, r4, #15			@; obtenim el z�calo del proc�s
	mov r5, #24				@; despla�ament necess�ri per saltar del pcb d'un proc�s a un altre
	ldr r6, =_gd_pcbs		@; obtenim l'adre�a del vector de pcbs
	mla r6, r4, r5, r6		@; despla�ament per arrivar al PCB del z�calo actual: num de z�calo * 24 + direcci� _gd_pcbs, on 24 es la mida de cada PCB (6 ints, 6 * 4 bytes per int)
	ldr r5, [r6, #20]		@; carreguem el valor de workTicks
	add r5, #1				@; augmentem en 1 els workTicks
	str r5, [r6, #20]		@; guardem el nou valor de workticks
	
	pop {r4-r7, pc}


	@; Rutina para actualizar la cola de procesos retardados,
	@; poniendo en cola de READY aquellos cuyo n�mero de tics
	@; de retardo sea 0
_gp_actualizarDelay:
	push {r0-r11, lr}
	ldr r0, =_gd_nDelay		@; r0 = direcci� de la variable amb el nombre de proc. retardats
	ldr r1, [r0]			@; r1 = num. de processos retardats
	mov r2, #0				@; punter del bucle a 0
	cmp r1, r2				@; mirem si ja s'han tractat tots els processos en la cua de retardats
	bls .L_fi_actualizarDelay_bucle1
	ldr r9, =_gd_qReady		@; carreguem en r9 la direccio de la cua de Ready
	ldr r10, =_gd_nReady	@; carreguem a r10 el nombre de processos en Ready
	ldr r11, =_gd_qDelay	@; r11 = cua de processos retardats
.L_actualizarDelay_bucle1:
	@; Augmentem el nombre de tics del porc�s
	ldr r3, [r11, r2, lsl #2]	@; r3 = zocalo + tics
	sub r3, #1				@; restem 1, d'aquesta forma resetem 1 al nombre de tics
	lsl r4, r3, #16			@; obtenim els tics
	lsr r4, r4, #16
	cmp r4, #0				@; mirem si ja han acabat els tics
	bne .L_actualizarDelay_noFiTics
	
	@; Si han acabat els tics, fiquem el proc�s en la cua de Ready
	lsr r4, r3, #24			@; obtenim el zocalo
	ldr r7, [r10]			@; obtenim el nombre de processos en Ready
	strb r4, [r9, r7]		@; guardem el z�calo en la �ltima posici� de la cua de Ready
	add r7, #1
	str r7, [r10]			@; augmentem en 1 el nombre de processos en Ready
	
	@; actualitzem la cua de Delay
	sub r1, #1				@; decrementem el nombre de processos en Delay
	str r1, [r0]
	mov r4, r2				@; punter del segon bucle
	cmp r1, r4				@; mirem si ja s'han tractat tots els processos en la cua de retardats
	bls .L_actualitzarDelay_salt
.L_actualizarDelay_bucle2:
	add r8, r4, #1
	ldr r7, [r11, r8, lsl #2]		@; carreguem valor (zocalo + tics) de la seg�ent posici�
	str r7, [r11, r4, lsl #2]		@; guardem valor (zocalo + tics) de la seg�ent posici�
	add r4, #1				@; Incrementem punter
	cmp r4, r1				@; mirem si ja s'han tractat tots els processos en la cua de retardats
	blo .L_actualizarDelay_bucle2
	b .L_actualitzarDelay_salt

.L_actualizarDelay_noFiTics:
	str r3, [r11, r2, lsl #2]
	add r2, #1				@; incrementem punter
.L_actualitzarDelay_salt:
	cmp r2, r1				@; mirem si ja s'han tractat tots els processos en la cua de retardats
	blo .L_actualizarDelay_bucle1
.L_fi_actualizarDelay_bucle1:
	pop {r0-r11, pc}



	@; Rutina para salvar el estado del proceso interrumpido en la entrada
	@; correspondiente del vector _gd_pcbs
	@;Par�metros
	@; R4: direcci�n _gd_nReady
	@; R5: n�mero de procesos en READY
	@; R6: direcci�n _gd_pidz
	@;Resultado
	@; R5: nuevo n�mero de procesos en READY (+1)
_gp_salvarProc:
	push {r8-r11, lr}
	ldr r8, [r6]  			@; obteim el PID m�s z�calo
	lsr r10, r8, #31		@; carreguem el bit de m�s pes del id + z�calo
	and r8, r8, #15			@; r8= num de z�calo, ens quedem amb els 4 bits de menys pes del pidz
	ldr r9, =_gd_qReady		@; carreguem en r9 la direccio de la cua de Ready
	@; noves instruccions pel cas d'un proc�s retardat
	cmp r10, #1
	beq .L_salvarProc_Delay	@; si el proc�s s'ha de retardar, es salva el seu estat pero no es fica en la cua de Ready
	@; ...
	strb r8, [r9, r5]		@; guardem el nombre de zocalo del proc�s en l'�ltima posici� de la cua de Ready
	add r5, #1				@; incrementem el nombre de processos en la cua de Ready
.L_salvarProc_Delay:
	ldr r9, =_gd_pcbs		@; direcci� del array de PCBs
	mov r10, #24
	mla r9, r10, r8, r9		@; despla�ament per arrivar al PCB del z�calo actual: num de z�calo * 24 + direcci� _gd_pcbs, on 24 es la mida de cada PCB (6 ints, 6 * 4 bytes per int)
	@; guardem PC
	mov r10, sp				@; r10 = SP_irq (punter al top de la pila IRQ)
	ldr r8, [r10, #60]		@; r8 = PC del proc�s a desbancar (+60 per l'estruct. de la pila IRQ veure a imatge)
	str r8, [r9, #4]		@; guardem el PC(r15) en la seva posici� del PCB
	@; guardem el CSPR
	mrs r11, SPSR			@; movem el contingut del SPSR (CSPR del proc�s) al registre r11
	str r11, [r9, #12]		@; guardem el CSPR en el camp Status del PCB
	@; canviem el mode d'execuci�
	mrs r8, CPSR			@; r8 = CPSR
	orr r8, #0x1F			@; Mode System, 5 �ltims bits a 1
	msr CPSR, r8			@; Canvem el mode
	@; apilem els registres r0-r12 i r14
	push {r14}				@; Apilem R14
	ldr r8, [r10, #56]		@; r8 = R12 (emmagatzemat en la posici� 14 de SP_IRQ)
	push {r8}				@; Apilem R12
	ldr r8, [r10, #12]		@; r8 = R11 (emmagatzemat en la posici� 3 de SP_IRQ)
	push {r8}				@; Apilem R11
	ldr r8, [r10, #8]		@; r8 = R10 (emmagatzemat en la posici� 2 de SP_IRQ)
	push {r8}				@; Apilem R10
	ldr r8, [r10, #4]		@; r8 = R9 (emmagatzemat en la posici� 1 de SP_IRQ)
	push {r8}				@; Apilem R9	
	ldr r8, [r10]			@; r8 = R8 (emmagatzemat en la posici� 0 de SP_IRQ)
	push {r8}				@; Apilem R8
	ldr r8, [r10, #32]		@; r8 = R7 (emmagatzemat en la posici� 8 de SP_IRQ)
	push {r8}				@; Apilem R7	
	ldr r8, [r10, #28]		@; r8 = R6 (emmagatzemat en la posici� 7 de SP_IRQ)
	push {r8}				@; Apilem R6
	ldr r8, [r10, #24]		@; r8 = R5 (emmagatzemat en la posici� 6 de SP_IRQ)
	push {r8}				@; Apilem R5	
	ldr r8, [r10, #20]		@; r8 = R4 (emmagatzemat en la posici� 5 de SP_IRQ)
	push {r8}				@; Apilem R4
	ldr r8, [r10, #52]		@; r8 = R3 (emmagatzemat en la posici� 13 de SP_IRQ)
	push {r8}				@; Apilem R3	
	ldr r8, [r10, #48]		@; r8 = R2 (emmagatzemat en la posici� 12 de SP_IRQ)
	push {r8}				@; Apilem R2
	ldr r8, [r10, #44]		@; r8 = R1 (emmagatzemat en la posici� 11 de SP_IRQ)
	push {r8}				@; Apilem R1
	ldr r8, [r10, #40]		@; r8 = R0 (emmagatzemat en la posici� 10 de SP_IRQ)
	push {r8}				@; Apilem R0	
	@; guardem el SP(r13) del proces en el PCB
	str r13, [r9, #8]		@; guardem el r13 en la pos. SP del PCB
	@; canviem el mode d'execuci�
	mrs r8, CPSR			@; r8 = CPSR
	and r8, #0xFFFFFFE0		@; Mode User
	orr r8, #0x12			@; Mode IRQ
	msr CPSR, r8			@; Canviem el mode
	pop {r8-r11, pc}


	@; Rutina para restaurar el estado del siguiente proceso en la cola de READY
	@;Par�metros
	@; R4: direcci�n _gd_nReady
	@; R5: n�mero de procesos en READY
	@; R6: direcci�n _gd_pidz
_gp_restaurarProc:
	push {r8-r11, lr}
	ldr r8, =_gd_qReady 		@; carreguem en r8 la direccio de la cua de Ready
	ldrb r9, [r8]				@; R9= z�calo del proc�s en la primera pos. de la cua de Ready
	sub r5, r5, #1				@; decrementem el nombre de processos en la cua de Ready
	str r5, [r4]				@; actualitzem el nombre de proc. en Ready
	mov r10, #0					@; r10=num de proc despla�ats (en la pos. corresponent)
	@; reordenem la cua de Ready
.Lrest_proc_bucle1:
	cmp r10, r5					@; mirem que quedin processos desordenats en la cua de Ready
	beq .Lrest_proc_fibucle1	@; si no n'hi ha sortim del bucle
	ldrb r11, [r8, #1]			@; r11 = z�calo guardat en la seg�ent posici� de la cua de ready (i+1) 
	strb r11, [r8]				@; guardem el nombre de z�calo en la pos anterior a la que estava (i)
	add r8, #1					@; avancem en la cua de Ready
	add r10, #1					@; incrementem el comptador que indica el nombre de processos ordenats 
	b .Lrest_proc_bucle1		@; retornem a l'inici del bucle
.Lrest_proc_fibucle1:
	@; construim el PIDz i el guardem en el _gd_pidz
	mov r10, #24
	ldr r8, =_gd_pcbs			@; r8=direcci� de l'array de PCBs
	mla r11, r10, r9, r8		@; despla�ament per arrivar al PCB del z�calo actual: num de z�calo * 24 + direcci� _gd_pcbs, on 24 es la mida de cada PCB (6 ints, 6 * 4 bytes per int)
	ldr r10, [r11]				@; r10= PID del proc�s
	lsl r10, #4					@; desplacem els bits del PID als 28 de m�s pes
	orr r10, r9					@; afegim en els 4 bits de menys el z�calo del proces
	str r10, [r6]				@; guardem el pidz en _gd_pidz
	@;recuperem r15 i el guradem en la pos. corresponent de la pila de proc�s
	ldr r10, [r11, #4]			@; carreguem el PC del PCB
	mov r8, sp					@; r8= punter de la pila IRQ
	str r10, [r8, #60]				@; guardem el registre r15 (PC en la posici� corresponent (15) de la pla IRQ)
	@; recuperem el CPSR del proc�s i el guardem en el registre SPSR_irq
	ldr r10, [r11, #12]			@; r10=CPSR del proc�s
	msr SPSR, r10				@; guardem el CPSR en el registre SPSR_irq
	@; canviem el mode d'execuci�
	mrs r10, CPSR			@; r8 = CPSR
	orr r10, #0x1F			@; Mode System, 5 �ltims bits a 1
	msr CPSR, r10			@; Canvem el mode
	@; recuperem el valor del registre r13 del proc�s a recuperar
	ldr r13, [r11, #8]		@; recuperem el SP del PCB en r13
	@; desapilem els registres r0-r12 i r14 i els guardem en la pila IRQ
	pop {r10}				@; Desapilem R0
	str r10, [r8, #40]		@; R0 (emmagatzemat en la posici� 10 de SP_IRQ)
	pop {r10}				@; Desapilem R1
	str r10, [r8, #44]		@; R1 (emmagatzemat en la posici� 11 de SP_IRQ)
	pop {r10}				@; Desapilem R2
	str r10, [r8, #48]		@; R2 (emmagatzemat en la posici� 12 de SP_IRQ)
	pop {r10}				@; Desapilem R3
	str r10, [r8, #52]		@; R3 (emmagatzemat en la posici� 13 de SP_IRQ)
	pop {r10}				@; Desapilem R4
	str r10, [r8, #20]		@; R4 (emmagatzemat en la posici� 5 de SP_IRQ)
	pop {r10}				@; Desapilem R5
	str r10, [r8, #24]		@; R5 (emmagatzemat en la posici� 6 de SP_IRQ)
	pop {r10}				@; Desapilem R6
	str r10, [r8, #28]		@; R6 (emmagatzemat en la posici� 7 de SP_IRQ)
	pop {r10}				@; Desapilem R7
	str r10, [r8, #32]		@; R7 (emmagatzemat en la posici� 8 de SP_IRQ)
	pop {r10}				@; Desapilem R8
	str r10, [r8]			@; R8 (emmagatzemat en la posici� 0 de SP_IRQ)
	pop {r10}				@; Desapilem R9
	str r10, [r8, #4]		@; R9 (emmagatzemat en la posici� 1 de SP_IRQ)
	pop {r10}				@; Desapilem R10
	str r10, [r8, #8]		@; R10 (emmagatzemat en la posici� 2 de SP_IRQ)
	pop {r10}				@; Desapilem R11
	str r10, [r8, #12]		@; R11 (emmagatzemat en la posici� 3 de SP_IRQ)
	pop {r10}				@; Desapilem R12
	str r10, [r8, #56]		@; R12 (emmagatzemat en la posici� 14 de SP_IRQ)
	pop {r14}				@; Desapilem R14
	@; canviem el mode d'execuci�
	mrs r10, CPSR			@; r10 = CPSR
	and r10, #0xFFFFFFE0	@; Mode User
	orr r10, #0x12			@; Mode IRQ
	msr CPSR, r10			@; Canvem el mode
	pop {r8-r11, pc}

	
	.global _gp_numProc
	@;Resultado
	@; R0: n�mero de procesos total
_gp_numProc:
	push {r1-r2, lr}
	mov r0, #1				@; contar siempre 1 proceso en RUN
	ldr r1, =_gd_nReady
	ldr r2, [r1]			@; R2 = n�mero de procesos en cola de READY
	add r0, r2				@; a�adir procesos en READY
	ldr r1, =_gd_nDelay
	ldr r2, [r1]			@; R2 = n�mero de procesos en cola de DELAY
	add r0, r2				@; a�adir procesos retardados
	pop {r1-r2, pc}


	.global _gp_crearProc
	@; prepara un proceso para ser ejecutado, creando su entorno de ejecuci�n y
	@; coloc�ndolo en la cola de READY
	@;Par�metros
	@; R0: intFunc funcion,
	@; R1: int zocalo,
	@; R2: char *nombre
	@; R3: int arg
	@;Resultado
	@; R0: 0 si no hay problema, >0 si no se puede crear el proceso
_gp_crearProc:
	push {r4-r7, lr}
	@; comprovem que el  num de z�calo no sigui el del So o ja estigui assignat a un proc�s
	cmp r1, #0				@; comprovem si el num de z�calo �s 0 (SO)
	beq .Lcrear_proc_err	@; si ho �s final de la funci�
	mov r4, #24
	ldr r5, =_gd_pcbs		@; r5=direcci� de l'array de PCBs
	mla r6, r1, r4, r5		@; despla�ament per arrivar al PCB del z�calo actual: num de z�calo * 24 + direcci� _gd_pcbs, on 24 es la mida de cada PCB (6 ints, 6 * 4 bytes per int)
	ldr r7, [r6]			@; r7= PID del proc�s
	cmp r7, #0				@; comprovem que el PID sigui 0, cap proc�s assignat a aquest z�calo
	bne .Lcrear_proc_err	@; si ja esta ocupat per un altre proc�s, final de la funci�
	@; nou PID pel proc�s i el guardem en el PCB
	ldr r4, =_gd_pidCount	@; r4=direcci� on tenim el pidCount
	ldr r5, [r4]			@; r5=valor de la variable pidCount
	add r5, #1				@; incrementem la variable pidCount
	str r5, [r4]			@; actulitzem la variable pidCount
	str r5, [r6]			@; guardem la nova pid del proc�s en el seu PCB
	@; guardem la direcci� de la primera instrucci� de la funci�
	add r0, #4				@; sumem 4 a la primera instrucci�
	str r0, [r6, #4]		@; guardem primera inst, en el camp PC del PCB
	@; guardem 4 primers car�cters del prog.
	ldr r4, [r2]			@; r4=4 primers car�ct. del prog
	str r4, [r6, #16]		@; guardem els car�c. en el camp KeyName  del PCB
	@; calculem la direcci� base de la pila del proc�s
	ldr r4, =_gd_stacks		@; vector de piles dels processos actius (15*128*4)
	mov r5, #512			@; r5=mida de cada pila (128*4)
	mla r7, r5, r1, r4		@; c�lcul de la pos. de la pila actual (n�m z�clao*mida_pila + direcci� inicial vector piles)-> apunta a la �ltima pos de la pila del z�calo anterior
	sub r7, #4				@; TOP de la pila		
	@; guardem en la pila el valor inicial dels registres
	ldr r4, =_gp_terminarProc	@;r4= direcci� de la rutina terminar_proc
	str r4, [r7]			@;guardem r4 (r14) en la pila  
	mov r4, #0				@; valor que adoptaran els registres
	mov r5, #0				@; comptador de bucle
.Lcrear_proc_bucle:
	sub r7, #4				@; augmentem el top de la pila
	str r4, [r7]			@; guardem registre
	add r5, #1				@; incrementem el comptador
	cmp r5, #12				@; mirem si s'han guardat els registres de (r12-r1)
	bne .Lcrear_proc_bucle	@; sin� retornem a l'inici del bucle
	sub r7, #4				@; augmentem el top de la pila
	str r3, [r7]			@; guardem en r0 els arguments de programa
	@; guardem el regitre r13 en el camp SP del PCB
	str r7, [r6, #8]		@; guardem el top de la pila en el camp SP del PCB
	@; guardem el registre CPSR amb els seus valors inicials per defecte i mode systema
	mov r7, #0x1F			@;Tots els flags a 0 i el mode de execuci� System
	str r7, [r6, #12]		@; guardem el registre CPSR en el camp status del PCB
	@; inicialtzem els altres camps del PCB
	str r4, [r6, #20]		@; camp workTocks del PCB a 0
	@; guardem el num de z�calo en la �ltima pos. de la cua de Ready i augmentem el num de proc en nReady
	ldr r5, =_gd_nReady		@; carreguem en r5 la direcci� de nReady
	ldr r4, =_gd_qReady		@; carreguem en r4 la direccio de la cua de Ready
	
	@;secci� cr�tica
	bl _gp_inhibirIRQs		@; inhibim les interrupcions
	
	ldr r6, [r5]			@; r6=num de proc. en la cua de Ready
	strb r1, [r4, r6]		@; guardem el nombre de zocalo del proc�s en l'�ltima posici� de la cua de Ready
	add r6, #1				@; incrementem el nombre de processos en la cua de Ready
	str r6, [r5]			@; actualitzem el nombre de proc. en la cua de REady
	mov r0, #0				@; retornem 0 ja que s'ha creat el proc�s correctament
	
	bl _gp_desinhibirIRQs	@; habilitem les interrupcions
	
	b .Lfi_crear_proc		@; saltem al final de la funci�
.Lcrear_proc_err:
	mov r0, #1				@; no s'ha pogut crear el proc�s
.Lfi_crear_proc:
	pop {r4-r7, pc}


	.global _gp_retardarProc
	@; retarda la ejecuci�n de un proceso durante cierto n�mero de
	@; segundos, coloc�ndolo en la cola de DELAY
	@;Par�metros
	@; R0: int nsec
_gp_retardarProc:
	push {r0-r5, lr}
	@; calculem el nombre de tics en funci� dels segons (1 segon = 60 tics)
	mov r1, #60					@; r1=60
	mul r3, r0, r1				@; r3= nombre de tics a esperar
	@; construir un word amb el zocalo i el n�mero de tics a retardar
	ldr r4, =_gd_pidz			@; obtim la variable _gd_pidz on hi ha (Identificador de proceso + z�calo actual)
	ldr r5, [r4]				@; obtenim l'identificador + z�calo del proc�s
	cmp r5, #0					@; mirem si el proc�s en execuci� �s el SO
	beq .LfinalRetardarProc		@; si ho �s acabem
	and r2, r5, #0xF			@; r2=z�calo del proc�s (4 bits de menys pes del pidz)
	lsl r2, r2, #24				@; desplacem el z�calo als 8 bits de m�s pes, la sesta a 0s
	orr r0, r2, r3				@; constru�m el word
	@; ho guardem en la cua de processos retardats
	ldr r1, =_gd_qDelay			@; r1 = cua de processos retardats
	ldr r2, =_gd_nDelay			@; carreguem en r3 el nombre de processos en la cua de retardats
	ldr r3, [r2]
	str r0, [r1, r3, lsl #2]	@; guardem el word (zocalo + tics restants) en la cua de retardats
	@; incrementem el nombre de processos en cua de retardats
	add r3, #1					@; incrementem el nombre de processos en la cua e retardats
	str r3, [r2]				@; guardem el valor en la variabl global
	@; fiquem a 1 el bit de m�s pes de _gd_pidz
	orr r5, r5, #0x80000000		@; fiquem a 1 el bit de m�s pes del pidz
	str r5, [r4]				@; guardem el valor en la variabl global
	@; forzar cesi�n de la CPU invocando a la funci�n _gp_WaitForVBlank()
	bl _gp_WaitForVBlank		@; invoquem la funci� WaitForVBlank
.LfinalRetardarProc:
	pop {r0-r5, pc}


	.global _gp_matarProc
	@; Rutina para destruir un proceso de usuario:
	@; borra el PID del PCB del z�calo referenciado por par�metro,
	@; para indicar que esa entrada del vector _gd_pcbs[] est� libre;
	@; elimina el �ndice de z�calo de la cola de READY o de la cola
	@; de DELAY, est� donde est�;
	@; Par�metros:
	@; R0: z�calo del proceso a matar (entre 1 y 15).
_gp_matarProc:
	push {r1-r6, lr}
	@; secci� cr�tica
	bl _gp_inhibirIRQs		@; inhibim les interrupcions
	@; posem a 0 el camp PID del _gd_pcbs[z]
	mov r3, #24
	ldr r1, =_gd_pcbs		@; r1 = direcci� de l'array de PCBs
	mla r2, r0, r3, r1		@; despla�ament per arrivar al PCB del z�calo actual: num de z�calo * 24 + direcci� _gd_pcbs, on 24 es la mida de cada PCB (6 ints, 6 * 4 bytes per int)
	mov r3, #0				@; r3 = 0
	str r3, [r2]			@; PID del proc�s = 0
	str r3, [r2,#20]		@; WorkTics del proc�s a 0, sin� surt impr�s en la pantalla del SO
	@; busquem el valor de z en la cua de READY i si est� l'eliminem
	ldr r1, =_gd_qReady		@; r1 = cua de processos en Ready
	ldr r2, =_gd_nReady		@; r2 = variable amb el nombre de processos en Ready
	ldr r3, [r2]			@; r3 = processos en Ready
	mov r4, #0				@; r4 punter
	cmp r4, r3				@; si no hi ha m�s processos en la cua de Ready busquem en la de Delay
	bhs .L_fi_matarProc_bucle1
.L_matarProc_bucle1:
	ldrb r5, [r1, r4]		@; carreguem z�calo de proc�s en la cua de Ready
	cmp r5, r0				@; si no coincideixen passem al seg�ent
	bne .L_seg�ent_matarProc_bucle1
	
	@; tractament si hi ha coincid�ncia
	add r6, r4, #1				@; r6 punter
.L_matarProc_bucle_reorder:
	cmp r6, r3				@; si no queden m�s elements que ordenar acabem
	beq .L_fi_matarProc_bucle_reorder
	ldrb r5, [r1, r6]		
	strb r5, [r1, r4]			@; desplacem el valor a la posici� anterior del vector
	add r4, #1				@; obtenim la posici� del seg�ent valor del vector
	add r6, #1				@; incrementem el punter
	b .L_matarProc_bucle_reorder	@; tornem a l'inici del bucle
.L_fi_matarProc_bucle_reorder:
	@; disminuir processos en ready	
	sub r3, #1				@; disminuim el nombre de processos en Ready
	str r3, [r2]
	b .L_fi_matarProc		@; acaba la funci�
	
	@; tractament si no hi ha coincid�ncia
.L_seg�ent_matarProc_bucle1:
	add r4, #1				@; augmentem en 1 el punter
	cmp r4, r3				@; si hi ha m�s processos en la cua tornem a l'inici del bucle
	blo .L_matarProc_bucle1
.L_fi_matarProc_bucle1:
	
	@; DELAY
	@; busquem el valor de z en la cua de DELAY i si est� l'eliminem
	ldr r1, =_gd_qDelay		@; r1 = cua de processos en Delay
	ldr r2, =_gd_nDelay		@; r2 = variable amb el nombre de processos en Delay
	ldr r3, [r2]			@; r3 = processos en Delay
	mov r4, #0				@; r4 punter
	cmp r4, r3				@; si no hi ha m�s processos en la cua de Delay acabem
	bhs .L_fi_matarProc
.L_matarProc_bucle2:
	ldr r5, [r1, r4, lsl #2]	@;carreguem el z�calo + tics de proc�s en la cua de Delay
	@;ldr r5, [r1, r4]	@;carreguem el z�calo + tics de proc�s en la cua de Delay
	lsr r5, #24				@; obtenim el z�calo del proc�s
	cmp r5, r0				@; si no coincideixen passem al seg�ent
	bne .L_seg�ent_matarProc_bucle2
	
	@; tractament si hi ha concid�ncia
	add r6, r4, #1				@; r6 punter 2
.L_matarProc_bucle2_reorder:
	cmp r6, r3				@; si no queden m�s elements que ordenar acabem
	beq .L_fi_matarProc_bucle2_reorder
	ldr r5, [r1, r6, lsl #2]		@; desplacem el valor a la posici� anterior del vector
	str r5, [r1, r4, lsl #2]
	add r4, #4				@; obtenim la posici� del seg�ent valor del vector
	add r6, #1				@; incrementem el punter
	b .L_matarProc_bucle2_reorder	@; tornem a l'inici del bucle
.L_fi_matarProc_bucle2_reorder:
	@; disminuir processos en delay	
	sub r3, #1				@; disminuim el nombre de processos en Delay
	str r3, [r2]
	b .L_fi_matarProc		@; acaba la funci�
	
	@; tractament si no hi ha concid�ncia
.L_seg�ent_matarProc_bucle2:
	add r4, #1				@; augmentem en 1 el punter
	cmp r4, r3				@; si hi ha m�s processos en la cua tornem a l'inici del bucle
	blo .L_matarProc_bucle2
	
.L_fi_matarProc:
	bl _gp_desinhibirIRQs	@; habilitem les interrupcions
	pop {r1-r6, pc}
	
	
	
	.global _gp_inihibirIRQs
	@; pone el bit IME (Interrupt Master Enable) a 0, para inhibir todas
	@; las IRQs y evitar as� posibles problemas debidos al cambio de contexto
_gp_inhibirIRQs:
	push {r0-r1, lr}
	ldr r0, =0x4000208			@; carreguem la posici� de l variable REG_IME
	ldr r1, [r0]				@; carreguem el REG_IME
	bic r1, #1					@; fiquem el primer bit a 0
	str r1, [r0]				@; guardem el nou REG_IME
	pop {r0-r1, pc}


	.global _gp_desinihibirIRQs
	@; pone el bit IME (Interrupt Master Enable) a 1, para desinhibir todas
	@; las IRQs
_gp_desinhibirIRQs:
	push {r0-r1, lr}
	ldr r0, =0x4000208			@; carreguem la posici� de l variable REG_IME
	ldr r1, [r0]				@; carreguem el REG_IME
	orr r1, #1					@; fiquem el primer bit a 1
	str r1, [r0]				@; guardem el nou REG_IME
	pop {r0-r1, pc}
	

	@; Rutina para terminar un proceso de usuario:
	@; pone a 0 el campo PID del PCB del z�calo actual, para indicar que esa
	@; entrada del vector _gd_pcbs est� libre; tambi�n pone a 0 el PID de la
	@; variable _gd_pidz (sin modificar el n�mero de z�calo), para que el c�digo
	@; de multiplexaci�n de procesos no salve el estado del proceso terminado.
_gp_terminarProc:
	ldr r0, =_gd_pidz
	ldr r1, [r0]			@; R1 = valor actual de PID + z�calo
	and r1, r1, #0xf		@; R1 = z�calo del proceso desbancado
	bl _gp_inhibirIRQs
	str r1, [r0]			@; guardar z�calo con PID = 0, para no salvar estado			
	ldr r2, =_gd_pcbs
	mov r10, #24
	mul r11, r1, r10
	add r2, r11				@; R2 = direcci�n base _gd_pcbs[zocalo]
	mov r3, #0
	str r3, [r2]			@; pone a 0 el campo PID del PCB del proceso
	str r3, [r2, #20]		@; borrar porcentaje de USO de la CPU
	ldr r0, =_gd_sincMain
	ldr r2, [r0]			@; R2 = valor actual de la variable de sincronismo
	mov r3, #1
	mov r3, r3, lsl r1		@; R3 = m�scara con bit correspondiente al z�calo
	orr r2, r3
	str r2, [r0]			@; actualizar variable de sincronismo
	bl _gp_desinhibirIRQs
.LterminarProc_inf:
	bl _gp_WaitForVBlank	@; pausar procesador
	b .LterminarProc_inf	@; hasta asegurar el cambio de contexto
	
	
.end

