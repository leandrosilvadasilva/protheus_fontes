#include 'protheus.ch'
/*___________________________________________________________________________
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
||-------------------------------------------------------------------------||
|| Fun��o: FA060QRY     || Autor:                       || Data: 20/08/14  ||
||-------------------------------------------------------------------------||
|| Descri��o: PE para filtrar os titulos para ser gerado o bordero         ||
||-------------------------------------------------------------------------||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
���������������������������������������������������������������������������*/
User Function FA060QRY()

Local cFiltro := " E1_PORTADO = '" + cPort060 +"' "

Return( cFiltro )
