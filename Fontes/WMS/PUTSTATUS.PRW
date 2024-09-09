#Include "TOTVS.ch" 
#Include "RESTFUL.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "tbiconn.ch"
#INCLUDE "topconn.CH"

/*
    IATAN EM 21/07/2022
    ENVIAR OS STATUS DAS NOTAS DA SPED050 PARA O WMS
*/

User Function PUTSTATUS

    Local _cQry     := ''
    Local aAreaSC5	:= SC5->(GETAREA())
    Local aAreaSF2	:= SF2->(GETAREA())
    Local resposta
/*
  _cQry := " SELECT DISTINCT C5_NUM, STATUS, F2_XSTATUS, SF2.* "
  _cQry += " FROM SF2010 SF2 INNER JOIN SD2010 SD2 ON F2_FILIAL = D2_FILIAL AND F2_DOC = D2_DOC AND F2_SERIE = D2_SERIE AND F2_CLIENTE = D2_CLIENTE AND F2_LOJA = D2_LOJA "
  _cQry += "                 INNER JOIN SC5010 SC5 ON C5_FILIAL = D2_FILIAL AND C5_CLIENTE = D2_CLIENTE AND C5_LOJACLI = D2_LOJA AND C5_NUM = D2_PEDIDO "
  _cQry += " 				INNER JOIN SPED050 SPED ON SUBSTRING(NFE_ID,4,9) = F2_DOC AND DOC_SERIE = F2_SERIE "
  _cQry += " WHERE SF2.D_E_L_E_T_ <> '*' AND SD2.D_E_L_E_T_ <> '*' AND SC5.D_E_L_E_T_ <> '*' AND SPED.D_E_L_E_T_ <> '*'  "
  _cQry += "       AND F2_XSTATUS <> STATUS AND C5_XWMS = 'S' AND F2_EMISSAO >= '20220718' AND C5_EMISSAO >= '20220718'  "
*/
  _cQry := " SELECT DISTINCT C5_NUM, STATUS, F2_XSTATUS, SF2.* "
  _cQry += " FROM SF2010 SF2 INNER JOIN SD2010 SD2 ON F2_FILIAL = D2_FILIAL AND F2_DOC = D2_DOC AND F2_SERIE = D2_SERIE AND F2_CLIENTE = D2_CLIENTE  "
  _cQry += "                                          AND F2_LOJA = D2_LOJA "
  _cQry += "                 INNER JOIN SC5010 SC5 ON C5_FILIAL = D2_FILIAL AND C5_CLIENTE = D2_CLIENTE AND C5_LOJACLI = D2_LOJA AND C5_NUM = D2_PEDIDO "
  _cQry += " 				INNER JOIN SPED050 SPED ON CAST(F2_DOC AS INT) = DOC_ID AND F2_SERIE = CAST(DOC_SERIE AS VARCHAR) "
  _cQry += " WHERE SF2.D_E_L_E_T_ <> '*' AND SD2.D_E_L_E_T_ <> '*' AND SC5.D_E_L_E_T_ <> '*' AND SPED.D_E_L_E_T_ <> '*'  "
  _cQry += "       AND F2_XSTATUS <> STATUS AND F2_EMISSAO >= '20220725' AND F2_DOC IN ('000034292','000034293') "

  _cQry := ChangeQuery(_cQry)
	dbUseArea( .T.,"TOPCONN",TcGenQry( ,,_cQry ),"_SF2",.T.,.T. )
  
  While (_SF2->(!EOF()))

    //POSICIONO NA SC5 PORQUE O MAPWMS11 ESPERA QUE A SC5 ESTEJA POSICIONADA
	DbSelectArea("SC5")
	SC5->(DbSetOrder(1))
	SC5->(DbSeek(_SF2->F2_FILIAL + _SF2->C5_NUM))

    RECLOCK("SC5", .F.)
        SC5->C5_XWMS := 'S'
    SC5->(MsUnlock())

    U_MAPWMS07( SC5->( Recno() ) )

    CONOUT("MANDANDO PEDIDO PARA WMS.: " + _SF2->F2_FILIAL + _SF2->C5_NUM)

    resposta := U_MAPWMS11( _SF2->R_E_C_N_O_ )
    IF LEN(resposta) >= 2
        // "Nenhuma carga do pedido" incluída em 21/07/2022 pois segundo Gabriel este status é válido
        IF resposta[1] == .T. .OR. "Nenhuma carga do pedido" $ resposta[2] 
            SF2->(DBGOTO( _SF2->R_E_C_N_O_ ))
            RECLOCK("SF2", .F.)
                SF2->F2_XSTATUS := cValToChar(_SF2->STATUS)
            SF2->(MsUnlock())
        ENDIF
    ENDIF
    //FALTA INTEGRAR AS NOTAS DE ENTRADA
    //U_MAPWMS16( _SF1->R_E_C_N_O_ )

    _SF2->(DbSkip())

  End
  _SF2->(DBCloseArea())

    RESTAREA(aAreaSC5)
    RESTAREA(aAreaSF2)

Return



Static Function MAStNFRET( cDoc, cSerie )	
	
Local aArea 	:= GetArea()
Local cQuery 	:= ""
Local cTabQry	:= ""
Local aRet 		:= {.F., "",""}	
	
cQuery:= CRLF+" SELECT "
cQuery+= CRLF+" 	ID_ENT,SUBSTRING(NFE_ID,4,9) NFE_ID,DATE_NFE,TIME_NFE,S50.STATUS,STATUSCANC,NFE_PROT,DOC_CHV,DOC_ID,DOC_SERIE, "
cQuery+= CRLF+" 	CASE "
cQuery+= CRLF+" 		WHEN STATUS='1' THEN 'STATUS' "
cQuery+= CRLF+" 		WHEN STATUS='2' THEN 'NFe Assinada' "
cQuery+= CRLF+" 		WHEN STATUS='3' THEN 'NFe com falha no schema XML' "
cQuery+= CRLF+" 		WHEN STATUS='4' THEN 'NFe transmitida' "
cQuery+= CRLF+" 		WHEN STATUS='5' THEN 'NFe com problemas' "
cQuery+= CRLF+" 		WHEN STATUS='6' THEN 'NFe autorizada' "
cQuery+= CRLF+" 		WHEN STATUS='7' THEN 'Cancelamento' "
cQuery+= CRLF+" 	END STATUS_NFE, "
cQuery+= CRLF+" 	CASE "
cQuery+= CRLF+" 		WHEN STATUSCANC='1' THEN 'NFe Recebida' "
cQuery+= CRLF+" 		WHEN STATUSCANC='2' THEN 'NFe Cancelada' "
cQuery+= CRLF+" 		WHEN STATUSCANC='3' THEN 'NFe com falha de cancelamento/inutilizacao' "
cQuery+= CRLF+" 	ELSE "
cQuery+= CRLF+" 		'' "
cQuery+= CRLF+" 	END STATUS_CANCELAMENTO "
cQuery+= CRLF+" FROM "

cQuery+= CRLF+" 	SPED050 S50 "
cQuery+= CRLF+" WHERE "

cQuery+= CRLF+" 	SUBSTRING(NFE_ID,4,9) = '"	+ ALLTRIM(cDoc)     + "'"
cQuery+= CRLF+" 	AND DOC_SERIE = '"			+ ALLTRIM(cSerie)   + "'"	
cQuery+= CRLF+" 	AND D_E_L_E_T_='' "
cQuery+= CRLF+" ORDER BY "
cQuery+= CRLF+" 	NFE_ID, ID_ENT,DOC_ID "

cQuery := ChangeQuery(cQuery)
cTabQry := MPSysOpenQuery(cQuery)
DbSelectArea(cTabQry)
DBGoTop()
If (cTabQry)->(!EoF())
	aRet[1] := .T.
	aRet[2] := cValToChar( (cTabQry)->STATUS )
	aRet[3] := AllTrim( (cTabQry)->STATUS_NFE ) + " - " + AllTrim( (cTabQry)->STATUS_CANCELAMENTO )
Else 
	aRet[1] := .F.
	aRet[2] := "0"
	aRet[3] := "Documento fiscal nao foi localizado na tabela SPED050 "	
EndIf 
(cTabQry)->(DBCloseArea())


RestArea( aArea )

Return( aRet )
