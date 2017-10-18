/*------------------------------------------------------------------------------

	"garlic_graf.c" : fase 1 / programador G

	Funciones de gesti�n de las ventanas de texto (gr�ficas), para GARLIC 1.0

------------------------------------------------------------------------------*/
#include <nds.h>

#include <garlic_system.h>	// definici�n de funciones y variables de sistema
#include <garlic_font.h>	// definici�n gr�fica de caracteres

/*definiciones*/
#define NVENT	 4					// n�mero de ventanas totales
#define PPART	 2					// n�mero de ventanas horizontales o verticales (particiones de pantalla)

#define L2_PPART 1				// log base 2 de PPART

#define VCOLS	 32				// columnas y filas de cualquier ventana
#define VFILS	 24
#define PCOLS	 VCOLS * PPART		// n�mero de columnas totales (en pantalla)
#define PFILS	 VFILS * PPART		// n�mero de filas totales (en pantalla)

int bg2, bg3;


/* _gg_generarMarco: dibuja el marco de la ventana que se indica por par�metro*/
void _gg_generarMarco(int v)
{
	//mapPtr=mapbase_bg3+desplazamiento de filas
	u16 * mapPtr=bgGetMapPtr(bg3)+(((v)/PPART)*VFILS*2*VCOLS);
	//si es impar mapPtr=mapPtr+numColumnas de 1 ventana
	if(v%PPART!=0){
		mapPtr=(u16*)mapPtr+VCOLS*(v%PPART);
	}
	//recorremos filas (i=y)
	for (int i=0;i<VFILS;i++){
		//recorremos columnas (j=x)
		for(int j=0;j<VCOLS;j++){
			if(i==0){
				if(j==0)
					mapPtr[j+i*64]=103;
				else 
				{
				if(j==VCOLS-1)
					mapPtr[j+i*64]=102;
				else{
					mapPtr[j+i*64]=99;
					}
				}
			}
			else if(i==VFILS-1){
				if(j==0)
					mapPtr[j+i*64]=100;
				else 
				{
				if(j==VCOLS-1)
					mapPtr[j+i*64]=101;
				else
					mapPtr[j+i*64]=97;
					}
				}
			else{
				if(j==0)
					mapPtr[j+i*64]=96;
				else if(j==VCOLS-1)
					mapPtr[j+i*64]=98;
				}
		}
	}
}


/* _gg_iniGraf: inicializa el procesador gr�fico A para GARLIC 1.0 */
void _gg_iniGrafA()
{
	videoSetMode(MODE_5_2D);
	vramSetBankA(VRAM_A_MAIN_BG_0x06000000);
	lcdMainOnTop();
	//inicialitzaci� del fons gr�fics 2 i 3: S'ha de tenir en compte el tamany que ocupar� cada mapa
	//tamany mapa=n� posicions*n�bytes/posici�=64*64posicions * 2bytes/posici� =8192bytes= 8K (separaci� de 4 mapbase)
	bg2=bgInit(2, BgType_ExRotation,BgSize_ER_512x512,0,3);
	bg3=bgInit(3, BgType_ExRotation,BgSize_ER_512x512,4,3);
	//Prioritat fons 3>fons 2
	bgSetPriority(bg3,0);
	bgSetPriority(bg2,1);
	//void decompress(const void * data, void * dst, DecompressType type)
	decompress(garlic_fontTiles, bgGetGfxPtr(bg3), LZ77Vram);
	
	dmaCopy(garlic_fontPal, BG_PALETTE, sizeof(garlic_fontPal));
	
	//generar los marcos de las ventanas de texto en el fondo 3
	for (int i=0;i<NVENT;i++){
		_gg_generarMarco(i);
	}
	//escalar los fondos 2 y 3 para que se ajusten exactamente a las dimensiones de una pantalla de la nds
	//zoom al 50%
	bgSetScale(bg3,520, 520);
	bgSetScale(bg2, 520, 520);
	bgUpdate();
}



/* _gg_procesarFormato: copia los caracteres del string de formato sobre el
					  string resultante, pero identifica los c�digos de formato
					  precedidos por '%' e inserta la representaci�n ASCII de
					  los valores indicados por par�metro.
	Par�metros:
		formato	->	string con c�digos de formato (ver descripci�n _gg_escribir);
		val1, val2	->	valores a transcribir, sean n�mero de c�digo ASCII (%c),
					un n�mero natural (%d, %x) o un puntero a string (%s);
		resultado	->	mensaje resultante.
	Observaci�n:
		Se supone que el string resultante tiene reservado espacio de memoria
		suficiente para albergar todo el mensaje, incluyendo los caracteres
		literales del formato y la transcripci�n a c�digo ASCII de los valores.
*/
void _gg_procesarFormato(char *formato, unsigned int val1, unsigned int val2,
																char *resultado)
{

}


/* _gg_escribir: escribe una cadena de caracteres en la ventana indicada;
	Par�metros:
		formato	->	cadena de formato, terminada con centinela '\0';
					admite '\n' (salto de l�nea), '\t' (tabulador, 4 espacios)
					y c�digos entre 32 y 159 (los 32 �ltimos son caracteres
					gr�ficos), adem�s de c�digos de formato %c, %d, %x y %s
					(max. 2 c�digos por cadena)
		val1	->	valor a sustituir en primer c�digo de formato, si existe
		val2	->	valor a sustituir en segundo c�digo de formato, si existe
					- los valores pueden ser un c�digo ASCII (%c), un valor
					  natural de 32 bits (%d, %x) o un puntero a string (%s)
		ventana	->	n�mero de ventana (de 0 a 3)
*/
void _gg_escribir(char *formato, unsigned int val1, unsigned int val2, int ventana)
{

}
