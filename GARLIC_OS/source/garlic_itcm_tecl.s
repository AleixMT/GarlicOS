@;==============================================================================
@;
@;	"garlic_itcm_tecl.s":	c�digo de las rutinas del teclado virtual
@;	Programador: Aleix Marin�
@;==============================================================================

.section .itcm,"ax",%progbits

	.arm
	.align 2

	.global _gt_getstring
	@; R0: string -> direcci�n base del vector de caracteres (bytes)
	@; R1: max_char -> n�mero m�ximo de caracteres del vector
	@; R2: zocalo -> n�mero de z�calo del proceso invocador
	@; Return
	@; R0: int -> N�mero de car�cteres le�dos
	@;� si la interfaz de teclado est� desactivada (oculta), mostrarla
	@;	(ver punto 8) y activar la RSI de teclado (ver punto 9).
	@;� a�adir el n�mero de z�calo sobre un vector global
	@;_gd_kbwait[], que se comportar� como una cola en la cual
	@;estar�n registrados los procesos que esperan la entrada de
	@;un string por teclado,
	@;� esperar a que el bit de una variable global _gd_kbsignal,
	@;correspondiente al n�mero de z�calo indicado, se ponga a 1,
	@;� poner el bit anterior a cero, copiar el string le�do sobre el
	@;vector que se ha pasado por par�metro, filtrando el n�mero
	@;total de caracteres y a�adiendo el centinela, y devolviendo
	@;el n�mero total de caracteres le�dos (excluido el centinela).
_gt_getstring:
	push {r1-r8, lr}
	
	pop {r1-r8, pc}

.end

