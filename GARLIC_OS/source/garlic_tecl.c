/*------------------------------------------------------------------------------

	"garlic_tecl.c" : Contiene fuciones comunes para la gesti�n de teclado
	
	Inicializa toda la informaci�n necesaria para la gesti�n del teclado, como las
	variables globales, los gr�ficos, instalar la RSI de teclado, etc.

------------------------------------------------------------------------------*/

#include <GARLIC_API.h>			/* definici�n de las funciones API de GARLIC */
#include <nds.h>
#include <stdio.h>

/* definicion de variables globales */

void _gt_initKB()
{
	/* Inicializamos procesador gr�fico en el modo 0 (los 4 fondos en modo texto) */
	videoSetModeSub(MODE_0_2D);
	/* Asignamos el banco de memoria B como fondo principal*/
	vramSetBankB(VRAM_B_MAIN_BG_0x06000000);
	/*	arg 0: Layer, capa de fondo. (0-3) siendo 0 m�s prioritario
		arg 1: Tipo de fondo (tipo texto con 4 bits por pixel)
		arg 2: Dimensiones de tipo texto 32x32
		arg 3: MapBase = 0 -> @fondo + 0*2KB = 0x0600 0000
		arg 4: TileBase = 1 -> @fondo + 1*16KB = 0x0600 0400
	*/
	int tecl_bg = bgInitSub(BG_PRIORITY(0), BgType_Text4bpp, BgSize_T_256x256, 0, 1);
	//inicialitzaci� del fons gr�fics 2 i 3: S'ha de tenir en compte el tamany que ocupar� cada mapa
	//tamany mapa=n� posicions*n�bytes/posici�=64*64posicions * 2bytes/posici� =8192bytes= 8K (separaci� de 4 mapbase)
	//void decompress(const void * data, void * dst, DecompressType type)
	decompress(garlic_fontTiles, bgGetGfxPtr(tecl_bg), LZ77Vram);
	dmaCopy(garlic_fontPal, BG_PALETTE, sizeof(garlic_fontPal));
	
	bgUpdate();
}

void _gt_showKB()
{

}

void _gt_hideKB()
{

}