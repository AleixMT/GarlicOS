/*------------------------------------------------------------------------------

	"main.c" : fase 1 / programador P

	Programa de prueba de creaci�n y multiplexaci�n de procesos en GARLIC 1.0,
	pero sin cargar procesos en memoria ni utilizar llamadas a _gg_escribir().

------------------------------------------------------------------------------*/
#include <nds.h>
#include <stdio.h>
#include <garlic_system.h>	// definici�n de funciones y variables de sistema
#include <GARLIC_API.h>		// inclusi�n del API para simular un proceso
int hola(int);				// funci�n que simula la ejecuci�n del proceso
//int detm(int);
extern int prnt(int);		// otra funci�n (externa) de test correspondiente
							// a un proceso de usuario
extern int tern(int);

extern int * punixTime;		// puntero a zona de memoria con el tiempo real
extern bool _gt_KBvisible;
/*
	"main.c" : fase 1 / programador M

	Programa de prueba de carga de un fichero ejecutable en formato ELF,
	pero sin multiplexaci�n de procesos ni utilizar llamadas a _gg_escribir().*/


/* Inicializaciones generales del sistema Garlic */
//------------------------------------------------------------------------------
void inicializarSistema() {
//------------------------------------------------------------------------------
	
	int v;
	_gg_iniGrafA();			// inicializar procesador gr�fico A
	for (v = 0; v < 4; v++)	// para todas las ventanas
		_gd_wbfs[v].pControl = 0;		// inicializar los buffers de ventana
	
	_gd_seed = *punixTime;	// inicializar semilla para n�meros aleatorios con
	_gd_seed <<= 16;		// el valor de tiempo real UNIX, desplazado 16 bits
	
	irqInitHandler(_gp_IntrMain);	// instalar rutina principal interrupciones
	irqSet(IRQ_VBLANK, _gp_rsiVBL);	// instalar RSI de vertical Blank
	irqEnable(IRQ_VBLANK);			// activar interrupciones de vertical Blank
	REG_IME = IME_ENABLE;			// activar las interrupciones en general
	_gd_pcbs[0].keyName = 0x4C524147;	// "GARL"
	/*
	if (!_gm_initFS()) {
		printf("ERROR: �no se puede inicializar el sistema de ficheros!");
		exit(0);
	}*/
}


//------------------------------------------------------------------------------
int main(int argc, char **argv) {
//------------------------------------------------------------------------------

	inicializarSistema();
	_gg_escribir("********************************", 0, 0, 0);
	_gg_escribir("*                              *", 0, 0, 0);
	_gg_escribir("* Sistema Operativo GARLIC 1.0 *", 0, 0, 0);
	_gg_escribir("*                              *", 0, 0, 0);
	_gg_escribir("********************************", 0, 0, 0);
	_gg_escribir("*** Inicio fase 1_G\n", 0, 0, 0);
	
	_gd_pidz = 6;	// simular z�calo 6
	tern(0);
	_gd_pidz = 7;	// simular z�calo 7
	hola(2);
	_gd_pidz = 5;	// simular z�calo 5
	prnt(1);

	_gg_escribir("*** Final fase 1_G\n", 0, 0, 0);

	
	//_gp_crearProc(hola, 7, "HOLA", 1);
	//_gp_crearProc(hola, 14, "HOLA", 2);
	//_gp_crearProc(detm, 8, "DETM", 2);
	
	
	/*while (_gp_numProc() > 1) {
		_gp_WaitForVBlank();
		printf("*** Test %d:%d\n", _gd_tickCount, _gp_numProc());
	}						// esperar a que terminen los procesos de usuario

	while(1) {
		swiWaitForVBlank();
	}							// parar el procesador en un bucle infinito
	
	
	// ProgM
	
	printf("*** Inicio fase 1_M\n");
	
	printf("*** Carga de programa HOLA.elf\n");
	start = _gm_cargarPrograma("HOLA");
	if (start)
	{	printf("*** Direccion de arranque :\n\t\t%p\n", start);
		printf("*** Pusle tecla \'START\' ::\n\n");
		while(1) {
			swiWaitForVBlank();
			scanKeys();
			if (keysDown() & KEY_START) break;
		}
		start(1);		// llamada al proceso HOLA con argumento 1
	} else
		printf("*** Programa \"HOLA\" NO cargado\n");
	
	printf("\n\n\n*** Carga de programa PRNT.elf\n");
	start = _gm_cargarPrograma("PRNT");
	if (start)
	{	printf("*** Direccion de arranque :\n\t\t%p\n", start);
		printf("*** Pusle tecla \'START\' ::\n\n");
		while(1) {
			swiWaitForVBlank();
			scanKeys();
			if (keysDown() & KEY_START) break;
		}
		start(0);		// llamada al proceso PRNT con argumento 0
	} else
		printf("*** Programa \"PRNT\" NO cargado\n");

	printf("*** Final fase 1_M\n");
*/
	while (1) {
		swiWaitForVBlank();
	}						// parar el procesador en un bucle infinito
	return 0;
	
	
}



/* Proceso de prueba, con llamadas a las funciones del API del sistema Garlic */
//------------------------------------------------------------------------------
int hola(int arg) {
//------------------------------------------------------------------------------
	unsigned int i, j, iter;
	
	if (arg < 0) arg = 0;			// limitar valor m�ximo y 
	else if (arg > 3) arg = 3;		// valor m�nimo del argumento
	
									// esccribir mensaje inicial
	GARLIC_printf("-- Programa HOLA  -  PID (%d) --\n", GARLIC_pid());
	
	j = 1;							// j = c�lculo de 10 elevado a arg
	for (i = 0; i < arg; i++)
		j *= 10;
						// c�lculo aleatorio del n�mero de iteraciones 'iter'
	GARLIC_divmod(GARLIC_random(), j, &i, &iter);
	iter++;							// asegurar que hay al menos una iteraci�n
	
	for (i = 0; i < iter; i++)		// escribir mensajes
		GARLIC_printf("(%d)\t%d: Hello world!\n", GARLIC_pid(), i);

	return 0;
}
