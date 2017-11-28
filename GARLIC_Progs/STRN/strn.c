/*------------------------------------------------------------------------------

	"STRN.c" : programa de test del progT
				(versi�n 1.0)

	Duu a terme diferents funcions per a treballar amb strings,aprofitant
	l'entrada del teclat.

------------------------------------------------------------------------------*/

#include <GARLIC_API.h>			/* definici�n de las funciones API de GARLIC */

/* definicion de variables globales
Concatenaci� (0): Llegeix dos strings per teclat i els concatena.
Inversi� (1): Llegeix un sol string i l'inverteix, posant la �ltima posici� en la primera i aix� successivament.
toUpperCase (2): Llegeix un sol string i transforma tots els car�cters en min�scula a maj�scula.
toLowerCase (3): Llegeix un sol string i transforma tots els car�cters en maj�scula a min�scula.

La funci� escriura l'string resultat per pantalla .
*/



int _start(int arg)
{
	if (arg < 0) arg = 0;			// limitar valor m�ximo y
	else if (arg > 3) arg = 3;		// valor m�nimo del argumento

	int lengthv2, lengthv1, i;
	char v1[28], v2[28], vr[57];

	for (i=0; i<57; i++) vr[i] = ' ';
	GARLIC_printf("*Introdueix un string*\n");

	lengthv1 = GARLIC_getstring(v1, 28);

	GARLIC_printf("\nLongitud de l'string: %d", lengthv1);
	GARLIC_printf("\nValor de l'string:\n%s", v1);

	switch (arg)
	{
		case 0:
			GARLIC_printf("\narg=0: Concatenar strings\n*Introdueix un altre string*");
			lengthv2 = GARLIC_getstring(v2, 28);
			GARLIC_printf("\nLongitud de l'string: %d", lengthv2);
			GARLIC_printf("\nValor de l'string:\n%s", v2);
			for (i = 0; i< lengthv1; i++)
			{
				vr[i] = v1[i];
			}
			for (i = 0; i < lengthv2; i++)
			{
				vr[i + lengthv1] = v2[i];
			}
		break;

		case 1:
			GARLIC_printf("\narg=1: Invertir String");

			for (i = 0; i < lengthv1; i++)
			{
				vr[i] = v1[lengthv1-i-1];
			}
		break;

		case 2:
			GARLIC_printf("\narg=2: toUpperCase");

			for (i = 0; i < lengthv1; i++)
			{
				if (v1[i] > 96 && v1[i] < 123)
				{
					vr[i] = v1[i] - 32;
				}
				else vr[i] = v1[i];
			}
		break;

		case 3:
			GARLIC_printf("\narg=3: toLowerCase");

			for (i = 0; i < lengthv1; i++)
			{
				if (v1[i] > 64 && v1[i] < 91)
				{
					vr[i] = v1[i] + 32;
				}
				else vr[i] = v1[i];
			}
		break;
	}
	GARLIC_printf("\nSTRING RESULTAT:\n");
	
	GARLIC_printf(vr);

	return 0;

}
