@;==============================================================================
@;
@;	"garlic_vector.s":	vector de direcciones de rutinas del API de GARLIC 1.0
@;
@;	ATENCI�N: �sta y las dem�s rutinas del API se declaran aqu� para obtener 
@;	un vector de direcci�n de inicio de esas rutinas. Esto permite llamar a dichas 
@;	rutinas de forma independiente de su ubicaci�n real en memoria, la cual cambia
@;	cada vez que se modifica el c�digo de las rutinas. Este vector se alojar� en 
@;	las primeras posiciones de la memoria ITCM.
@;
@;==============================================================================

.section .vectors,"a",%note


APIVector:						@; Vector de direcciones de rutinas del API
	.word	_ga_pid				@; (c�digo de rutinas en "garlic_itcm_api.s")
	.word	_ga_random
	.word	_ga_divmod
	.word	_ga_printf
	.word	_ga_getstring

.end
