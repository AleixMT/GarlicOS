/*------------------------------------------------------------------------------

	garlic_mainARM7  (Aleix Marin�, 24/12/2017)
	
------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------

	Simon1  (Santiago Roman�, novembre 2011)
	
	-> based on "Common" templates from DevkitPro; see the following original
	   legal notice:
	
---------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------
	
	default ARM7 core

		Copyright (C) 2005 - 2010
		Michael Noland (joat)
		Jason Rogers (dovoto)
		Dave Murphy (WinterMute)

	This software is provided 'as-is', without any express or implied
	warranty.  In no event will the authors be held liable for any
	damages arising from the use of this software.

	Permission is granted to anyone to use this software for any
	purpose, including commercial applications, and to alter it and
	redistribute it freely, subject to the following restrictions:

	1.	The origin of this software must not be misrepresented; you
		must not claim that you wrote the original software. If you use
		this software in a product, an acknowledgment in the product
		documentation would be appreciated but is not required.

	2.	Altered source versions must be plainly marked as such, and
		must not be misrepresented as being the original software.

	3.	This notice may not be removed or altered from any source
		distribution.

---------------------------------------------------------------------------------*/
#include <nds.h>
touchPosition tempPos = {0};


/*comprobarPantallaTactil() verifica si se ha pulsado la pantalla t�ctil con el l�piz,
	comprobando que ninguna de las coordenadas raw sea 0; en el caso que lo sea, se fija
	el par�metro pasado por referencia, touchPos, con las coordenadas (x, y) en p�xeles, 
	y la funci�n devuelve cierto.*/ /*
bool comprobarPantallaTactil(void)
{
	if (!touchPenDown()) return false;	// no hay contacto del l�piz con la pantalla
	else		// hay contacto
	{
		touchReadXY(&tempPos);	// leer la posici�n de contacto
		if ((tempPos.rawx == 0) || (tempPos.rawy == 0)) return false;	 // si las posiciones son 0
		else return true; // sino devuelve cierto
	}
}*/

/* comprobarPantallaTactil() verifica si se ha pulsado efectivamente la pantalla
   t�ctil con el l�piz, comprobando que est� pulsada durante al menos dos llama-
   das consecutivas a la funci�n y, adem�s, las coordenadas raw sean diferentes
   de 0; en este caso, se fija el par�metro pasado por referencia, touchPos,
   con las coordenadas (x, y) en p�xeles, y la funci�n devuelve cierto. */

bool comprobarPantallaTactil(void)
{
	static bool penDown = false;
	bool lecturaCorrecta = false;

	if (!touchPenDown())
	{
		penDown = false;	// no hay contacto del l�piz con la pantalla
	}
	else		// hay contacto, pero hay que verificarlo
	{
		if (penDown)		// si anteriormente ya estaba en contacto
		{
			touchReadXY(&tempPos);	// leer la posici�n de contacto
			
			if ((tempPos.rawx == 0) || (tempPos.rawy == 0))
			{						// si alguna coordenada no es correcta
				penDown = false;	// anular indicador de contacto
			}
			else
			{
				lecturaCorrecta = true;
			}
		}
		else
		{					// si es la primera detecci�n de contacto
			penDown = true;		// memorizar el estado para la segunda verificaci�n
		}
	}
	return lecturaCorrecta;		
}


//------------------------------------------------------------------------------
int main() {
//------------------------------------------------------------------------------
	short x, y;
	char buttons = 0, oldbuttons = 0;
	bool dinsderang, teclaapretada = false;
	unsigned int posarrayx, posarrayy, codi, numcaselles, missatge; 
	
	int proves[]={29,85,51,69, 51, 69, 246,52,241,35};
	int i=0;
	
	irqInit(); // iniciem sistema irq de l'arm 7
	
	//readUserSettings();			// configurar par�metros lectura Touch Screen
	REG_IPC_FIFO_CR = IPC_FIFO_ENABLE | IPC_FIFO_SEND_CLEAR; //  | IPC_FIFO_RECV_IRQ | 1 << 15 | 1 << 10
	irqEnable(IRQ_IPC_SYNC | IRQ_VBLANK | IRQ_FIFO_NOT_EMPTY);	
		
	REG_IPC_SYNC = 0; // inicialitzem el registre de control
	REG_IPC_SYNC = IPC_SYNC_IRQ_ENABLE | IPC_SYNC_IRQ_REQUEST;
	
	posarrayy = 0; // per defecte les posicions seran 0 (si no canvien no entrarem al switch i per tant no enviarem res)
	posarrayx = 0;
	do
	{
		for (i = 0; i < 10; i++) swiWaitForVBlank(); // Esperem per no sobrecarregar cpu 
	
		oldbuttons = buttons; // canviem els botons
		buttons = REG_KEYXY & 0X3; // carreguem el nous botons (ens interessen els dos primers bits)
		/* Permetem interrupcions i passem els 2 primers bits del REG_KEYXY (estat dels botons X i Y) */
		if (oldbuttons != buttons) 	REG_IPC_SYNC = IPC_SYNC_IRQ_REQUEST | IPC_SYNC_IRQ_ENABLE | buttons << 8 ; // li passem els dos botons 
	
		dinsderang = true; // l'entrada sera correcta fins que no es digui el contrari
		codi = 0; // per defecte el codi sera 0, �s a dir tecla normal; 
		numcaselles = 1; // per defecte escriurem una sola casella


		// Comprovem si s'ha apretat la pantalla tactil
		if (comprobarPantallaTactil()) // Aquesta funcio emmagatzema a tempPos la posicio en pixels. Aparentment no e funciona (sempre retorna 0)
		{
			//x = tempPos.px;					// leer posici�n (x, y)
			//y = tempPos.py; 
			x = 29; y = 85; // Cas boto A de la tecla space
			//x = 241; y = 35; // cas boto especial
			//x = 246; y = 52; // cas retroces
			//x = 51; y = 69;
			//x = proves[i]; y = proves[i+1]; // cas de la tecla A
			i=i+2;
			
			x=x / 8;	// Obtenim coordenades en nombre de rajoles (dividim entre 8)
			y=y / 8;
		
			//REG_IPC_FIFO_TX = x;
			switch (y)
			{
			case 4: // fila 4
				if (x % 2 != 0 || x < 2 || x > 30) dinsderang = false; // comprovem que haguem pitjat una de les tecles
				else 
				{
					if (x == 30) codi = 7; // codi per boto especial
					posarrayy = 0; // corregim per a que sigui una posicio de l'array 
				}
			break;
			case 6: // fila 6
				if ( (x % 2 != 0 && x > 0 && x < 26) || (x > 27 && x < 31) ) 
				{
					if (x > 28)
					{
						x = 28; // si hem apretat a DEL que apunti a DEL desde el principi
						numcaselles = 3;
						codi = 3; // codi per a la tecla DEL
					}
					posarrayy = 1;
				}
				else dinsderang = false;
			break;
			case 8: // fila 8
				if ( (x > 0 && x < 5) || (x % 2 == 0 && x > 5 && x < 25) || (x > 25 && x < 31) ) 
				{
					if (x > 0 && x < 5)
					{
						x = 1; // si hem apretat a CAPS que x apunti a CAPS desde el principi
						numcaselles = 4;
						codi = 2; // codi per a la tecla CAPS
					}
					else if (x > 25 && x < 31)
					{
						x = 26;
						numcaselles = 5;
						codi = 4; // codi per a INTRO
					}
					posarrayy = 2;

				}
				else dinsderang = false;
			break;
			case 10:	// fila 10	
				if ( (x > 0 && x < 6) || (x % 2 == 0 && x > 6 && x < 24) || (x == 26 || x == 27) || (x == 29 || x == 30)) 
				{
					if (x > 0 && x < 6)
					{
						x = 1;
						numcaselles = 5;
						codi = 1; // codi per a la tecla SPACE
					}
					else if (x == 26 || x == 27)
					{
						x = 26;
						numcaselles = 2;
						codi = 5; // codi per a la tecla <=
					}
					else if (x == 29 || x == 30)
					{
						x = 29;
						numcaselles = 2;
						codi = 6; // codi per a la tecla <=
					}
					posarrayy = 3;
				}
				else dinsderang = false;
			break;
			default:
				dinsderang = false;
			break;
			}
			posarrayx = x-1; // corregim per a que la pos de x coincideixi amb la del array
			if (dinsderang)
			{
				teclaapretada = true;
				REG_IPC_FIFO_TX	= missatge = (numcaselles & 0x7) << 19 | ((y * 32 + x) & 0x1FF) << 10 | ((posarrayy * 30 + posarrayx) & 0x7F) << 3 | (codi & 0x7);
			//REG_IPC_FIFO_TX	= missatge;
			}
		}
		else if (teclaapretada) // Aquest es el cas on la pantalla no ha estat premuda. Cal comprovar si en l'anterior comprovacio s'havia apretat  apretat una tecla ja que si es aixi s'enviara un missatge per a borrar aquella tecla (despintar les rajoletes) si o s'havia apretat res, o farem res
		{
			REG_IPC_FIFO_TX	= missatge | 0x400000; // passem el mateix missatge que abans pero possem el bit de desapretar a 1
			teclaapretada = false;
		}
	}
	while (1);

return 0;
}
