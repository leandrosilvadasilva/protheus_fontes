#Include "TOTVS.CH"
#Include "RESTFUL.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MAHWS021 ³ Autor ³ 				        ³ Data ³ SET/2023 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Servico Web service para integracao Protheus X Zoho.       ³±±
±±³          ³ Situacao pedido de venda                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico MA Hospitalar                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                          ULTIMAS ALTERACOES                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ Motivo da Alteracao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³															              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

WSRESTFUL MAHSITPED DESCRIPTION "Situação pedidos"

    WSDATA FILPED AS STRING
    WSDATA NUMPED AS STRING
	WSDATA DATPED AS STRING
	WSMETHOD GET DESCRIPTION "Listr situação dos pedidos" WSSYNTAX "/MAHSITPED" 
 
END WSRESTFUL

WSMETHOD GET WSRECEIVE FILPED,NUMPED,DATPED WSSERVICE MAHSITPED
	Local cQuery	:= ""
	Local cArea		:= ""
	Local nX		:= 0
	Local nCount	:= 0
	Local nReg		:= 0
	Local nCampo	:= 0
	Local lOk		:= .T.	
	Local cData := ""
	Local aCampo := {}
	if empty(::FILPED)
		SetRestFault( 90, "Parametros invalidos, é obrigatório informar a filial!")	
		ConOut("Parametros invalidos, é obrigatório informar a filial!")
		Return()
	endif
	Conout('MAHSITPED - Integracao Situação de pedidos')
	if empty(::NUMPED) .and. empty(::DATPED)
		cData := dTos(dDataBase)
		cData := substr(cData,1,4)+"-"+substr(cData,5,2)+"-"+substr(cData,7,2)
	endif
	if empty(::NUMPED) .and. !empty(::DATPED)
		cData := ::DATPED
		cData := substr(cData,1,4)+"-"+substr(cData,5,2)+"-"+substr(cData,7,2)
	endif
	RpcSetType( 3 )
	RpcSetenv( substr(::FILPED,1,2),::FILPED,,,,GetEnvServer(),{"SC5","SC6","SC9","SB1"} ) 
	// Define o tipo de retorno do metodo
	::SetContentType("application/json")
	Conout('MAHSITPED - Ambiente')
	Conout(cEmpAnt)
	Conout(cFilAnt)
	aAdd(aCampo, {"C5_FILIAL","C5_FILIAL"})	
	aAdd(aCampo, {"C5_NUM","C5_NUM"})	
	aAdd(aCampo, {"C5_CODZHO","C5_CODZHO"})	
	aAdd(aCampo, {"C6_PRODUTO","C6_PRODUTO"})	
	aAdd(aCampo, {"B1_DESC","B1_DESC"})	
	aAdd(aCampo, {"C6_QTDENT","C6_QTDENT"})	
	aAdd(aCampo, {"C6_NOTA","C6_NOTA"})	
	aAdd(aCampo, {"D2_VALFRE","D2_VALFRE"})	
	aAdd(aCampo, {"D2_TOTAL","D2_TOTAL"})	
	aAdd(aCampo, {"DATAFAT","DATAFAT"})
	aAdd(aCampo, {"SITUACAO","SITUACAO"})	
	nCampo := len(aCampo)
	cQuery := ""
	cQuery := " WITH " 
	cQuery += " PEDIDO (C5_FILIAL, C5_NUM, C5_EMISSAO, C5_CODZHO, C5_LIBEROK, C5_ZTPLIBE, C6_PRODUTO, B1_DESC, C6_QTDVEN, C6_QTDENT, C6_NOTA, C6_ENTREG, C6_STPESTQ, C6_DATFAT, C9_BLEST, C9_BLCRED, C9_BLWMS,D2_TOTAL,D2_VALFRE,DATAFAT) AS ( "
	cQuery += "  		SELECT C5_FILIAL, C5_NUM, C5_EMISSAO, C5_CODZHO, C5_LIBEROK, C5_ZTPLIBE, C6_PRODUTO, B1_DESC, C6_QTDVEN, C6_QTDENT, C6_NOTA, C6_ENTREG, C6_STPESTQ, C6_DATFAT, C9_BLEST, C9_BLCRED, C9_BLWMS,D2_TOTAL,D2_VALFRE,D2_EMISSAO "
	cQuery += " FROM "+RetSQLName("SC5")+ " SC5 "
	cQuery += " INNER JOIN "+RetSQLName("SC6")+ " SC6 ON (C6_FILIAL = C5_FILIAL AND C6_NUM = C5_NUM AND SC6.D_E_L_E_T_ = '') "
	cQuery += " INNER JOIN "+RetSQLName("SB1")+ " SB1 ON (B1_FILIAL = '' AND B1_COD = C6_PRODUTO AND SB1.D_E_L_E_T_ = '') "
	cQuery += " LEFT OUTER JOIN "+RetSQLName("SC9")+ " SC9 ON (C9_FILIAL = C6_FILIAL AND C9_PEDIDO = C6_NUM AND C9_ITEM = C6_ITEM AND SC9.D_E_L_E_T_ = '') "
	cQuery += " LEFT OUTER JOIN "+RetSQLName("SD2")+ " SD2 ON (D2_FILIAL = C6_FILIAL AND D2_PEDIDO = C6_NUM AND D2_COD = C6_PRODUTO AND D2_ITEMPV = C6_ITEM AND SD2.D_E_L_E_T_ = '' ) "
	cQuery += " WHERE "
	cQuery += " 		C5_FILIAL = '"+::FILPED+"' AND "
	if !empty(::NUMPED)
		cQuery += " 		C5_NUM = '"+::NUMPED+"' AND "
	endif
	if !empty(cData)
		cQuery += " 	((CONVERT(DATE,SC5.S_T_A_M_P_) >=  '"+cData+"'	AND CONVERT(DATE,SC5.S_T_A_M_P_) <=  '"+cData+"') OR (CONVERT(DATE,SC6.S_T_A_M_P_) >=  '"+cData+"'	AND CONVERT(DATE,SC6.S_T_A_M_P_) <=  '"+cData+"') OR (CONVERT(DATE,SC9.S_T_A_M_P_) >=  '"+cData+"'	AND CONVERT(DATE,SC9.S_T_A_M_P_) <=  '"+cData+"'))  AND "
	endif
	cQuery += " 		C5_CODZHO != '' AND SC5.D_E_L_E_T_ = '' "
	cQuery += " 	) "
	cQuery += " 	SELECT C5_FILIAL, C5_NUM, C5_CODZHO, C6_PRODUTO, B1_DESC, C6_QTDENT, C6_NOTA,D2_VALFRE,D2_TOTAL,DATAFAT, "
	cQuery += " 			(CASE WHEN C5_LIBEROK <> 'S' AND C6_NOTA = '' AND C6_STPESTQ <> 'R' THEN 'INCLUIDO' "  
	cQuery += " 			      WHEN C6_NOTA <> '' AND C9_BLEST = '10' AND C6_QTDVEN = C6_QTDENT THEN 'FATURADO' "
	cQuery += " 				  WHEN C6_NOTA <> '' AND C9_BLEST = '10' AND C6_QTDVEN > C6_QTDENT THEN 'FATURADO PARCIAL' "
	cQuery += " 				  WHEN C9_BLCRED IN ('01','04','09') AND C6_NOTA = '' THEN 'BLOQUEADO CREDITO' "
	cQuery += " 				  WHEN C9_BLEST IN ('02','03') AND C6_STPESTQ = 'P' THEN 'ESTOQUE PENDENTE' "
	cQuery += " 				  WHEN C5_LIBEROK <> 'S' AND C6_STPESTQ = 'R' THEN 'REPRESENTADA' " 
	cQuery += " 				  WHEN C9_BLEST IN ('02','03') THEN 'BLOQUEADO ESTOQUE'  "
	cQuery += " 				  WHEN C5_ZTPLIBE = '2' THEN 'RESERVADO AGUARDANDO OUTRO ITEM'  "
	cQuery += " 				  WHEN C5_ZTPLIBE <> '2' THEN 'AGUARDANDO FATURAMENTO' "
	cQuery += " 				  ELSE 'AGUARDANDO FATURAMENTO' END) SITUACAO "
	cQuery += " FROM PEDIDO "
	cQuery += " ORDER BY C5_FILIAL, C5_NUM,C6_PRODUTO,C6_NOTA "
	CONOUT("MAHSITPED - "+cQuery)
	//cQuery := ChangeQuery(cQuery)			
	dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQuery), (cArea := GetNextAlias()), .F., .T. )
	Count To nReg		
	if nReg == 0
		lOk := .F.
		SetRestFault( 1, "Verifique os parametros ou nenhum registro encontrado!" )
		Conout('MAHSITPED - Verifique os parametros ou nenhum registro encontrado!')
	else
		DBSelectArea(cArea)
		DBGoTop()
		::SetResponse('{"SITUACAOPEDIDOS": [')
		while (cArea)->(!eof())
			nCount++
			::SetResponse('{')
			for nX := 1 to nCampo
				::SetResponse('"')
				::SetResponse(aCampo[nX][1]) 
				::SetResponse('"')
				::SetResponse(':')
				::SetResponse('"')
				if aCampo[nX][1] $ "B1_DESC"
					::SetResponse( U_NoCharEsp( AllTrim( cValToChar( (cArea)->&(aCampo[nX][2]) ) ) ) )
				else
					::SetResponse( AllTrim( cValToChar( (cArea)->&(aCampo[nX][2]) ) ) )
				endif 
				::SetResponse('"')				
				if nX < nCampo 
					::SetResponse(',')
				endif
			next nX
			::SetResponse('}')
			if nCount < nReg
			 	::SetResponse(',')
			endif	
			(cArea)->(DBSkip())
		EndDo
		::SetResponse(']}')
		(cArea)->( dbCloseArea() )
	Conout('MAHSITPED - Finalizacao Ok')
	endif
Return( lOk )
