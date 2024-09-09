#include 'Totvs.ch'

User Function MT271FIL()
Local lRet := .T.
Local nPar := PARAMIXB[1]
		    
If nPar == 1    	
  
  IF !Empty(GETMV("ES_INVMAR"))
  	If GetMarca(SB2->B2_COD)<> GETMV("ES_INVMAR")  .AND. SB2->B2_FILIAL=GETMV("ES_FILINVE")      
       lRet := .F. 
    Endif
  Endif
Endif


Return(lRet)

Static Function GetMarca(cProd)
Local cMarc :=''

cQuery:=''
cMarc:=''
cQuery:=" SELECT B1_MARCA FROM SB1010 WHERE  "
cQuery+=" B1_COD='"+cProd+"'"
cQuery+=" AND D_E_L_E_T_<>'*' "
cQuery+=" AND B1_TIPO IN ('M1','M2','M3','M4','M5') "
cQuery:= ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry( ,, cQuery ),"TPRO",.F.,.T.)

cMarc:=AllTrim(TPRO->B1_MARCA)

DBCloseArea("TPRO")

Return(cMarc)

