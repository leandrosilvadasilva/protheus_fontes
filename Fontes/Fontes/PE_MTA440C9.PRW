
#Include "Protheus.ch"


USER FUNCTION MTA440C9()


Local aAreaSC5 := SC5->(GetArea())
Local aAreaSC6 := SC6->(GetArea())
Local aAreaSC9 := SC9->(GetArea())
Local cTESBLK  := GETMV("ES_TESINV") // Contem TES de consignado para bloqueio de credito
 
dbselectarea("SC6")
dbselectarea("SC9")
          
RecLock("SC6",.F.)
RecLock("SC9",.F.)
//--------------------------------------
// SE o TES DO PEDIDO E DE CONSIGNACAO 
//--------------------------------------
IF SC6->C6_TES $ cTESBLK                   
	SC9->C9_BLCRED= "01"   //----> 01- INDICA BLOQUEIO POR CREDITO                       
EndIF
MsUnlock()
     
DbselectArea("SC6")
Dbskip()
     
RestArea(aAreaSC9)
RestArea(aAreaSC6) 

Return() 