/*------------------------------------------------------------------------------

	"garlic_tecl.c" : Contiene fuciones comunes para la gesti�n de teclado
	
	Inicializa toda la informaci�n necesaria para la gesti�n del teclado, como las
	variables globales, los gr�ficos, instalar la RSI de teclado, etc.

------------------------------------------------------------------------------*/

//#include <GARLIC_API.h>			/* definici�n de las funciones API de GARLIC */
#include <nds.h>
#include <garlic_system.h>	// definici�n de funciones y variables de sistema
#include <garlic_font.h>	// definici�n gr�fica de caracteres

char _gt_minset[4][30] = {{' ', '\\', ' ', '1', ' ', '2', ' ', '3', ' ', '4', ' ', '5', ' ', '6', ' ', '7', ' ', '8', ' ', '9', ' ', '0', ' ', '\'', ' ', '{', ' ', '~', ' ', ' '},
						   {'@', ' ' , '<', ' ', 'q', ' ', 'w', ' ', 'e', ' ', 'r', ' ', 't', ' ', 'y', ' ', 'u', ' ', 'i', ' ', 'o' , ' ', 'p', ' ', '[', ' ', ' ', 'D', 'E', 'L'},
						   {'C', 'A' , 'P', 'S', ' ', 'a', ' ', 's', ' ', 'd', ' ',  'f', ' ','g', ' ', 'h', ' ', 'j', ' ', 'k', ' ' , 'l', ' ', '-', ' ', 'I', 'N', 'T', 'R', 'O'},
						   {'S', 'P' , 'A', 'C', 'E', ' ', 'z', ' ', 'x', ' ', 'c', ' ', 'v', ' ', 'b', ' ', 'n', ' ', 'm', ' ', ',' , ' ', '.', ' ', ' ', '<', '=', ' ', '=', '>'}};

char _gt_majset[4][30] = {{' ', '+', ' ', '!', ' ', '"', ' ', '#', ' ', '$', ' ', '%', ' ', '&', ' ', '/', ' ', '(', ' ', ')', ' ', '=', ' ', '?', ' ', '}', ' ', '|', ' ', ' '},
						   {'*', ' ', '>', ' ', 'Q', ' ', 'W', ' ', 'E', ' ', 'R', ' ', 'T', ' ', 'Y', ' ', 'U', ' ', 'I', ' ', 'O', ' ', 'P', ' ', ']', ' ', ' ', 'D', 'E', 'L'},
						   {'C', 'A', 'P', 'S', ' ', 'A', ' ', 'S', ' ', 'D', ' ', 'F',' ' , 'G', ' ', 'H', ' ', 'J', ' ', 'K', ' ', 'L', ' ', '_', ' ', 'I', 'N', 'T', 'R', 'O'},
			    		   {'S', 'P', 'A', 'C', 'E', ' ', 'Z', ' ', 'X', ' ', 'C', ' ', 'V', ' ', 'B', ' ', 'N', ' ', 'M', ' ', ';', ' ', ':', ' ', ' ', '<', '=', ' ', '=', '>'}};
 

//_gt_set[0].set = _gt_minset;
	//_gt_set[1].set = _gt_minset;
void _gt_initKB()
{
	//lcdMainOnTop();

	int i;
	
	/* Instalem la rsi del IRQ IPC SYNC de la NDS:
	Aix� indica al controlador general d'interrupcions que quan es produeixi la interrupci� IRQ_IPC_SYNC
	ha d'executar la funci� rsi que nosaltres li indiquem per a gestionar la interrupcio */
	irqSet(IRQ_IPC_SYNC, _gt_rsi_IPC_SYNC);
	
	/*Habilitem al registre de control REG_IPC_SYNC el bit 13 amb la m�scara IPC_SYNC_IRQ_ENABLE
	que permet rebre interrupcions IPC_SYNC de l'altre processador. En aquest cas ARM7 podra interrompre
	al ARM9. Caldra habilitar el bit complementari (bit 14) del mateix registre pero DE L'ALTRE PROCESSADOR
	per a que es pugui generar la interrupcio. */
	REG_IPC_SYNC = 0;
	REG_IPC_SYNC = IPC_SYNC_IRQ_REQUEST | IPC_SYNC_IRQ_ENABLE;	

	/* Instalem la rsi del IRQ IPC FIFO de la NDS:
	Aix� indica al controlador general d'interrupcions que quan es produeixi la interrupci� IRQ_IPC_FIFO
	ha d'executar la funci� rsi que nosaltres li indiquem per a gestionar la interrupcio */
	irqSet(IPC_FIFO_RECV_IRQ, _gt_rsi_IPC_FIFO);
	
	/* Indiquem que es poden produir interrupcions procedint d'aqeusts dispositiu*/
	REG_IPC_FIFO_CR = IPC_FIFO_ENABLE | IPC_FIFO_SEND_CLEAR | IPC_FIFO_RECV_IRQ | 1 << 15 | 1 << 10;
	
	/* Indiquem al registre IE (interrupt enable) que les interrupcions seg�ents estan actives:
		- IRQ_IPC_SYNC: per a rebre l'estat dels botons X i Y
		- IRQ_FIFO_NOT_EMPTY: Per a rebre informacio sobre iteraccio tactil amb el teclat
		*/
	irqEnable(IRQ_IPC_SYNC);
	irqEnable(IRQ_FIFO_NOT_EMPTY);	

	/* Activaci�n de todas las IRQ (interrupt master enable)  */
	REG_IME=IME_ENABLE;
	
	/* Inicializamos procesador gr�fico en el modo 0 (los 4 fondos en modo texto) */
	videoSetModeSub(MODE_0_2D);
	
	/* Asignamos el banco de memoria B como fondo principal*/
	vramSetBankC(VRAM_C_SUB_BG_0x06200000);
	
	/*	arg 0: Layer, capa de fondo. (0-3) siendo 0 m�s prioritario
			bg1	-> cursor
			bg1	-> linea de texto
			bg2 -> Ventana completa de instrucciones
		arg 1: Tipo de fondo (tipo texto con 4 bits por pixel)
		arg 2: Dimensiones de tipo texto 32x32
		arg 3: MapBase = n -> @fondo + n*2KB; @base -> 0x0600 0000
		arg 4: TileBase = n -> @fondo + n*16KB 
	*/
	_gt_bginfo = bgInitSub(BG_PRIORITY(2), BgType_Text8bpp, BgSize_T_256x256, 4, 1);
	_gt_bgbox = bgInitSub(BG_PRIORITY(1), BgType_Text8bpp, BgSize_T_256x256, 5, 1);
	_gt_bgcursor = bgInitSub(BG_PRIORITY(1), BgType_Text8bpp, BgSize_T_256x256, 6, 1);
	
	/* Inicializamos las variables globales de direcci�n del mapa de baldosas de los diferentes
	fondos */
	_gt_mapbaseinfo = bgGetMapPtr(_gt_bginfo);
	_gt_mapbasebox = bgGetMapPtr(_gt_bgbox);
	_gt_mapbasecursor = bgGetMapPtr(_gt_bgcursor);
	
	/* Descomprimimos las baldosas de GARLIC y los copiamos en la posici�n de mem 
	donde estan definidas la posicion de las baldosas en uno de los fondos, debido 
	a que se ha indicado que todos los mapas tienen su mapa de baldosas en el mismo 
	sitio solamente necesitamos hacer una copia */
	decompress(garlic_fontTiles, bgGetGfxPtr(_gt_bgbox), LZ77Vram);
	
	/* Copiamos la paleta de colores de GARLIC en la paleta de colores del procesador 
	secundario */
	dmaCopy(garlic_fontPal, BG_PALETTE_SUB, garlic_fontPalLen);
	
	/* Carreguem els missatges */
				/*   I  n  p  u  t     f  o   r    z  0 0      (  P  I  D    0000         )  :		*/
	int str1[26] = {41,78,80,85,84,0,70,79,82,0,90,16,16,0,8,48,41,36,0,16,16,16,16,16,9,26};
	for(i=0; i<26;i++)
		_gt_mapbasebox[i]= str1[i];
	
	// Inicialitzem el fons color carn per a 12 files
	for(i=0; i<(32*12); i++){
		_gt_mapbaseinfo[i]=(128*3)+95;
	}
	
	// Cursor
	//_gt_mapbasecursor[166]=128*3+113;

	// Quadre per l'esquerra
	_gt_mapbasebox[32*2+1]=32*3+2;
	
	// Quadre per la dreta
	_gt_mapbasebox[32*2+30]=32*3;
	
	// Quadre de text per dalt i per baix
	for(i=0; i<28; i++){
		_gt_mapbasebox[32+2+i]=32*3+1;
		_gt_mapbasebox[96+2+i]=32*3+3;
	}

	// Inicialitza blanc del quadre de text
	for(i=0; i<28; i++){
		_gt_mapbaseinfo[66+i]=95;
	}
	
	// Rajoles blaves per la primera linia
	for(i=0; i<30; i++)
	{
		if(i%2!=0)
		{
			_gt_mapbaseinfo[32*4+1+i]=128+32*2+31;
		}
	}
	
	// Rajoles blaves per la segona linia
	for(i=0; i<30; i++){
		if(i%2==0&&i<25) {
			_gt_mapbaseinfo[193+i]=128+95;
		}
	}
	
	// Rajoles blaves per la tercera linia
	for(i=0; i<30; i++){
		if(i%2==0&&i<19) {
			_gt_mapbaseinfo[262+i]=128+95;
		}
	}
	
	// Rajoles blaves per la quarta linia
	for(i=0; i<30; i++){
		if(i%2==0&&i<17) {
			_gt_mapbaseinfo[327+i]=128+95;
		}
	}
	
	// rajoles per intro i space
	for(i=0; i<5; i++)
	{
		_gt_mapbaseinfo[282+i]=128+95; // inicialitzem rajoletes blaves intro
		//CUARTA FILA
		_gt_mapbaseinfo[321+i]=128+95; // inicialitzem rajoletes blaves space
	}
	
	// Inicialitzem les rajoletes de les tecles del cursor
	for(i=0; i<2; i++){
		_gt_mapbaseinfo[346+i]=128+95;
		_gt_mapbaseinfo[349+i]=128+95;
	}
	
	// les rajoletes del DEL
	_gt_mapbaseinfo[220]=128+95;
	_gt_mapbaseinfo[221]=128+95;
	_gt_mapbaseinfo[222]=128+95;
	
	 //Inicialitzem input 
	for (i = 0; i < 28; i++) _gt_input[i] = -1;
	
		/* Inicialitzem comptador de processos */
	_gd_nKeyboard = 0; 
	
	/* Posem la visibilitat del teclat a fals */
	_gt_kbvisible = false;
	
	/* inicialitzem el cursor*/
	_gt_cursorini();
	
	/* Amaguem el teclat */
	_gt_hideKB();
	
	/* Indiquem que el bloc maj�scules est� desactivat */
	_gt_CAPS_lock = 1;
	
	/* Inicialitzem la part grafica del teclat */
	_gt_graf();
}

void _gt_graf()
{
	short int i,j;
	char tmpset[4][30];
	// Escollir entre majuscules o minuscules
	if(_gt_CAPS_lock){
		for (i = 0; i < 4; i++)
		{
			for (j = 0; j < 30; j++)
			{
				tmpset[i][j] = _gt_majset[i][j];
			}
		}
	} 
	else 
	{
		for (i = 0; i < 4; i++)
		{
			for (j = 0; j < 30; j++)
			{
				tmpset[i][j] = _gt_minset[i][j];
			}
		}
	}

	// PRIMERA FILA
	for(i=0; i<30; i++)
	{
		_gt_mapbasebox[32*4+1+i]=tmpset[0][i]-32;
	}
	
	// SEGONA FILA
	for(i=0; i<30; i++)
	{
		_gt_mapbasebox[193+i]=tmpset[1][i]-32;
	}

	// TERCERA FILA
	for(i=0; i<30; i++)
	{
		_gt_mapbasebox[257+i]=tmpset[2][i]-32;
	}
	
	// rajoles del caps, que estaran a lila o no segons l'estat de les majuscules
	for(i=0; i<4; i++){
		if (_gt_CAPS_lock==0){
			_gt_mapbaseinfo[257+i]=128+95;
		} else {
			_gt_mapbaseinfo[257+i]=256+95;
		}
	}
	
	// CUARTA FILA
	for(i=0; i<30; i++)
	{
		_gt_mapbasebox[321+i]=tmpset[3][i]-32;
	}
}

void _gt_writePIDZ(char zoc)
{
	int i;
	_gs_num2str_dec(_gt_PIDZ_tmp, 2, zoc);
	
	for (i = 0; i < 2; i++)
	{
		if (_gt_PIDZ_tmp[i] == 32) _gt_mapbasebox[11+i] = _gt_PIDZ_tmp[i]-16;
		else _gt_mapbasebox[11+i] = _gt_PIDZ_tmp[i]-32;
	}
	
	_gs_num2str_dec(_gt_PIDZ_tmp, 6, _gd_pcbs[(int)zoc].PID);

	for (i = 0; i < 5; i++)
	{
		if (_gt_PIDZ_tmp[i] == 32) _gt_mapbasebox[19+i] = _gt_PIDZ_tmp[i]-16;
		else _gt_mapbasebox[19+i] = _gt_PIDZ_tmp[i]-32;
	}
}
/*

		.global _gt_writePIDZ
	@; Recibe un char con el n�mero de z�calo y muestra el PID del proceso correspondiente en la interf�cie de teclado 
	@; usando el fondo info
	@; Par�metros
	@; R0: char zocalo
_gt_writePIDZ:
	push {r1-r6,lr}
	
	@; Z�CALO
	
	mov r5, r0					@; r5 = socol (copia de seguretat)
	mov r2, r0					@; r2 = socol		
	ldr r0, =_gt_PIDZ_tmp		@; r0 = @ _gd_PIDZ_tmp
	mov r1, #3					@; r1 = 3 (nombre de caracters)
	bl _gs_num2str_dec			@; converteix el zocalo passat per parametre a string R0: char * numstr, R1: int length, R2: int num. return r0 = 0 si toot va be
	ldr r0, =_gt_PIDZ_tmp		@; r0 = @ _gd_PIDZ_tmp
	ldr r2, =_gt_mapbaseinfo	@; r2 = @@ _gt_mapbaseinfo
	ldr r2, [r2]				@; r2 = @ _gt_mapbaseinfo
	mov r6, r2					@; Salvem aquesta direccio de memoria
	add r2, #22					@; Anem a on comen�a el text aquell de z00
	
	mov r1, #0					@; Inicialitzem comptador
.Lgtesc_V1:
	ldrb r4, [r0, r1]			@; carreguem el digit del nombre de socol
	cmp r4, #32					@; comparem amb 32
	subne r4, #32				@; Si es tracta d'un n�mero normal (0-9) restem 32 per a passar a rajoletes
	subeq r4, #16				@; Si es tracta d'un espai (32) restem 16 per a obtenir un 0 en coddificacio de rajoletes
	mov r3, r1, lsl #1			@; Ens desplacem en el mapa de rajoletes (halfwords)
	strh r4, [r2, r3]			@; guardem a la posicio de zocalo
	add r1, #1					@; incrementem el comptador
	cmp r1, #2					@; si hem fet ja 3 repeticions sortim ja
	bne .Lgtesc_V1 				@; iteracio

	@; PID

	mov r4, #24					@; carrega 24 a r4 (la mida de cada PCB)
	mul r3, r5, r4				@; multipliquem aquest 24 amb el zocalo per a saber el despla�ament 
	ldr r2, =_gd_pcbs			@; carreguem direcci� base del vector de PCBs
	ldr r2, [r2, r3] 			@; r2 = PIDZ del proces
	
	ldr r0, =_gt_PIDZ_tmp		@; r0 = @_gd_PIDZ_tmp
	mov r1, #6					@; r1 = 6 (caracters maxims)
	bl _gs_num2str_dec			@; converteix el PIDZ a string
	ldr r0, =_gt_PIDZ_tmp		@; r0 = @_gd_PIDZ_tmp

	mov r2, r6					@; restaurem r2 = @ _gt_mapbaseinfo
	add r2, #38					@; accedim a on comen�a el PID:00000
	
	mov r1, #0					@; Inicialitzem comptador
.Lgtesc_V:
	ldrb r4, [r0, r1]			@; procedim igual que abans
	cmp r4, #32
	subne r4, #32
	subeq r4, #16
	mov r3, r1, lsl #1
	strh r4, [r2, r3]
	add r1, #1
	cmp r1, #5					@; pero amb limit 5
	blo .Lgtesc_V 				@; segueix iterant

	pop {r1-r6, pc}
	*/
	
void _gt_showKB(char zoc)
{	
	_gt_kbvisible = true;	// indiquem que teclat mostrat

	bgShow(_gt_bginfo);		// activem els fons del teclat
	bgShow(_gt_bgbox);
	bgShow(_gt_bgcursor);
	
	_gt_writePIDZ(zoc);	// escribim el pidz del proc�s rebut per parametre en la finestreta
}

void _gt_hideKB()
{
	
	bgHide(_gt_bginfo);		// amaguem tots els background
	bgHide(_gt_bgbox);
	bgHide(_gt_bgcursor);
	
	_gt_kbvisible = false;	// indiquem que teclat amagat

	//_gt_resetKB();
	
}