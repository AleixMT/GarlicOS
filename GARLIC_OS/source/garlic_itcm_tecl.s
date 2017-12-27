@;==============================================================================
@;
@;	"garlic_itcm_tecl.s":	c�digo de las rutinas del teclado virtual
@;	Programador: Aleix Marin�
@;==============================================================================

.section .itcm,"ax",%progbits

	.arm
	.align 2

	.global _gt_getstring
	@;Par�metros:
	@; R0: string -> direcci�n base del vector de caracteres (bytes)
	@; R1: max_char -> n�mero m�ximo de caracteres del vector
	@; R2: zocalo -> n�mero de z�calo del proceso invocador
	@; Return
	@; R0: int -> N�mero de car�cteres le�dos
	@;	�	Si la interfaz de teclado est� desactivada (oculta), mostrarla
	@;	(ver punto 8) y activar la RSI de teclado (ver punto 9).
	
	@;	�	A�adir el n�mero de z�calo sobre un vector global
	@;	_gd_kbwait[], que se comportar� como una cola en la cual
	@;	estar�n registrados los procesos que esperan la entrada de
	@;	un string por teclado,
	
	@;	�	Esperar a que el bit de una variable global _gd_kbsignal,
	@;	correspondiente al n�mero de z�calo indicado, se ponga a 1,
	
	@;	�	Poner el bit anterior a cero, copiar el string le�do sobre el
	@;	vector que se ha pasado por par�metro, filtrando el n�mero
	@;	total de caracteres y a�adiendo el centinela, y devolviendo
	@;	el n�mero total de caracteres le�dos (excluido el centinela).
_gt_getstring:
	push {r1-r7, lr}

	@; Ahora registraremos el proceso en la cola de espera del KB
	
	ldr r3, =_gd_nKeyboard			@; Cargamos la @ de la varible que tiene el numero de procesos esperando 
	ldrsb r4, [r3]					@; r4 = num procesos
	cmp r4, #16						@; Si el nombre de processos es igual a la mida maxima de la cua
	moveq r0, #-1					@; Carreguem un -1 a r0
	beq .L_getstring_error			@; I sortim de la rutina
	ldr r5, =_gd_Keyboard			@; cargamos @base de la cola de espera del KB (vector de char)
	strb r2, [r5, r4]				@; guardamos el z�calo recibido por par�metro a la posicion
	add r4, #1						@; sumamos 1 al �ndice
	strb r4, [r3]					@; actualizamos el �ndice
	
	@; Mirem que la interficie estigui mostrada
	
	ldr r4, =_gt_kbvisible			@; Cargamos @ de _gt_visible
	ldrb r3, [r4]					@; r3 = _gt_visible
	cmp r3, #1						@; Si esta mostrada, vol dir que algu l'esta utilitzant
	beq .Lgtgetstr_pidzcode			@; Per tant passem aquest pas. Sino...
	mov r5, r0						@; r5 = @ string. Salvamos la direcci�n del string en r5
	mov r0, r2						@; Passada de parametres a _gt_showKB (espera el n�mero de z�calo por r0)
	push {r0-r5}
	bl _gt_showKB 					@; mostramos la interficie para el proceso que llama a getstring
	pop {r0-r5}
	mov r0, r5						@; Recuperamos en r0 @ string
 
	@; Ara posarem a 1 el segon bit de mes pes de la variable _gd_pidz per indicar que es tracta dun proces que espera KB
.Lgtgetstr_pidzcode:
	ldr r3, = _gd_pidz				@; r3 = @_gd_pidz
	ldr r4, [r3]					@; r4 = _gd_pidz
	orr r4, r4, #0x40000000			@; fiquem a 1 el segon bit de m�s pes del pidz
	bl _gp_rsiVBL					@; Cridem a _gp_rsiVL per a for�ar que es salvi el context del proces
	
	@; aqui continuara el proces que hagi sigut tret de la cua d'espera

	@; copiar el string le�do sobre el vector que se ha pasado por par�metro, filtrando el n�mero de caracteres leido 
	@;total de caracteres y a�adiendo el centinela, y devolviendo
	@;el n�mero total de caracteres le�dos (excluido el centinela).
	ldr r3, =_gt_inputl			@; carreguem @ base de la variable de nombre de caracters
	ldrb r2, [r3]				@; r2 = nombre de caracters d'input
	cmp r1, r2					@; Comparem el nombre de caracters d'input i la capacitat del string dest�
	movlo r2, r1				@; r2 = nombre de caracters maxim (valor m�s limitant)
	
	cmp r2, #0					@; Si no hi ha res al buffer sortim. 
	beq .Lgtgetstr_copystrfi	@; 
	
	ldr r4, =_gt_input			@; r4 = @ base del vector de input
	mov r5, #0					@; r5 = comptador. Inicialitzem comptador
	
.Lgtgetstr_copystr:
	ldrsb r3, [r4, r5]			@; Carreguem signed (per a reconeixer caracter centinella) sobre r3. Cont� el vector a tractar
	add r3, #32					@; Factor de correcci� per a transformar al codi ASCII
	strb r3, [r0, r5]			@; Guardem sobre l'string que rebem per parametre
	add r5, #1					@; Incrementem comptador
	cmp r5, r2					@; Si el comptador no es igual al valor maxim 
	bne .Lgtgetstr_copystr		@; tornem a iterar
.Lgtgetstr_copystrfi:
	mov r6, #0					@; Afegim el caracter de final de string (el \0 de tota la, vida)
	strb r6, [r0, r5]			@; Guardem el caracter de final de linia
	
	push {r0-r5}
	bl _gt_resetKB				@; resetegem per al seg�ent us
	bl _gt_hideKB				@; Amaguem interficie de teclat
	pop {r0-r5}
	
	@; Ara mostrarem la interficie per al seg�ent proces que utilitzara el teclat. Per a fer-ho cal que primer eliminem 
	@; el primer proces que espera teclat (aixo ho fara la rsi) per a que al carregar _gd_Keybard[0] obtinguem el socol 
	@; del seguent proces
	ldr r0, =_gd_Keyboard		
	ldrb r0, [r0]
	push {r0-r5}
	bl _gt_showKB 					@; mostramos la interficie para el proceso en la posicion 0 de la cola
	pop {r0-r5}

	mov r0, r2					@; Retorn de parametres
.L_getstring_error:
	pop {r1-r7, pc}			
	
	
	
	
		.global _gt_cursorini
	@; Inicialitza el cursor en la primera posicio
_gt_cursorini:
	push {r0-r1, lr}
	ldr r0, =_gt_mapbasecursor	@; r0 = @@ del mapa de rajoletes del cursor
	ldr r0, [r0] 				@; r0 = @ el mapa del rajoletes
	add r0, #132				@; Anem a la seg�ent linia de la capsa de text en el mapa del cursor 			
	mov r1, #97					@; carreguem a r1 la rajoleta de cursor (ratlla per la part de dalt)
	strh r1, [r0] 				@; carrega el cursor a la posicio inicial
	pop {r0-r1, pc}







	
	
	
	
	
	
	.global _gt_resetKB
	@; reinicia totes les variables i estructures per a la seg�ent E/S per KB
_gt_resetKB:
	push {r0-r4, lr}
	@; reiniciar cursor
		
	ldr r0, =_gt_cursor_pos		@; r0 = @_gt_cursor_pos	
	ldrb r1, [r0]				@; r1 = _gt_cursor_pos
	mov r1, r1, lsl #1			@; r1 = r1*2
	ldr r2, =_gt_mapbasecursor	@; r2 = @@_gt_mapbasecursor
	ldr r2, [r2]				@; r2 = @_gt_mapbasecursor
	add r2, #260				@; desplacem fins a la linia del cursor
	mov r3, #0					@; r3 = 0
	strb r3, [r0] 				@; cursor a la posicio 0
	strh r3, [r2, r1] 			@; borra el cursor de la posicio on estigui

	bl _gt_cursorini			@; posa cursor a la primera posicio

	mov r0, #0					@; r0 = 0
	mov r1, #-1					@; r1 = -1
	ldr r2, =_gt_input			@; r2 = @_gt_input 
	ldr r3, =_gt_inputl			@; r3 = @_gt_inputl
	ldrb r4, [r3]				@; r4 = _gt_inputl
.Lgtr_clean_input:
	strb r1, [r2, r0]			@; actualitza la posicio i
	bl _gt_updatechar			@; actualitza el caracter
	add r0, #1					@; afegeix a l'index
	cmp r0, r4					@; mentre no haguem arribat al final del string					
	blo .Lgtr_clean_input		@; seguim netejant l'string d'entrada

	mov r1, #0					@; r1 = 0
	strb r1, [r3]				@; reiniciem la quantitat de input
	
	pop {r0-r4, pc}
	
	
	
	
		.global _gt_updatechar
	@; Consulta un determinat caracter i actualitza el mapa de rajoletes
	@;Par�metros:
	@; R0: pos -> index del caracter a actualitzar
_gt_updatechar:
	push {r0-r2, lr}

	ldr r1, =_gt_mapbasebox		@; r1 = @@_gt_mapbasebox
	ldr r1, [r1] 				@; r1 = @_gt_mapbasebox
	add r1, #196 				@; direccio d'inici del quadre de text
	ldr r2 , =_gt_input			@; r2 = @_gt_input	
	ldrsb r2, [r2, r0]			@; carrega a r2 el caracter a on apunta l'index passat per parametre
	cmp r2, #-1					@; Si el caracter que ens estan dient que actualitzem es el de final de linea
	moveq r2, #0				@; Posem el caracter negre com de buit 
	lsl r0, #1					@; Multipliquem per dos el despla�ament (anem amb halfwords)
	strh r2, [r1, r0]			@; I guardem sobre el mapa de rajoletes a la posicio que toca. 
	pop {r0-r2, pc}
	
	
	
	
	
		.global _gt_getchar
	@; Obtiene el caracter de la posicion indicada del vector de caracteres
	@;Par�metros:
	@; R0: pos -> �ndice del car�cter
	@;Retorna:
	@; R0: char -> caracter en la posicion recibida por par�metro
_gt_getchar:
	push {r1, lr}
	@;lsl r0, #1				@; Multipliquem per 2
	ldr r1 , =_gt_input		@; r1 = @_gt_input
	ldrsb r0, [r1, r0]		@; r0 = _gt_input[r0] -> Caracter desitjat
	pop {r1, pc}
	
	
	
	
	
		.global _gt_putchar
	@;Par�metros:
	@; R0: pos -> �ndice del caracter a actualizar
	@; R1: char -> caracter a introducir
_gt_putchar:
	push {r0-r2, lr}
	@;lsl r0, #1				@; Multipliquem per 2
	ldr r2 , =_gt_input		@; r2 = @_gt_input
	strb r1, [r2, r0]		@; _gt_input[r0] = r1; 
	pop {r0-r2, pc}
	
	
	
	
	@; Recibe el nuevo estado de los botones X e Y del arm7 a traves del sistema IPCSYNC

	.global _gt_rsi_IPC_SYNC
_gt_rsi_IPC_SYNC:
	push {r0-r1, lr}
	ldr r0, =0x04000180 		@; Carreguem direccio del registre de control/dades IPC_SYNC
	ldr r0, [r0]				@; Carreguem el sseu contingut
	and r0, r0, #0x3			@; Fem un clean dels dos primers bit, ja que son els unics que ens interessen
	ldr r1, =_gt_XYbuttons		@; r1 = @_gt_XYbuttons
	strb r0, [r1]				@; Guardem els dos bits de menys pes del registre IPC_SYNC del ARM9 a la variable _gt_XYbuttons
	pop {r0-r1, pc}
.end

