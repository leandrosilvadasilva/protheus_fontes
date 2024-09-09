#include "TOTVS.CH"

User Function MT410TOK()

Local aArea       := GetArea()
Local aAreaSC5    := SC5->(GetArea())
Local aAreaSC6    := SC6->(GetArea())
Local lRet   	  := .T. 
Local __cPedCli	  := M->C5_PEDCLI
Local nPosPCli    :=Ascan( aHeader, { |x| Upper(AllTrim(x[2])) == "C6_PEDCLI" } )



IF INCLUI .or. ALTERA
	For nY := 1 to Len(aCols)
		aCols[ nY ,nPosPCli ]:=__cPedCli
	Next
	
Endif

RestArea( aArea )
RestArea( aAreaSC5 )
RestArea( aAreaSC6 )

Return(lRet)

