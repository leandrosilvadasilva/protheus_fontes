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
	Local cChave := ""
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
	aAdd(aCampo, {"C6_PRODUTO","C6_PRODUTO"})	
	aAdd(aCampo, {"B1_DESC","B1_DESC"})	
	aAdd(aCampo, {"C6_QTDENT","C6_QTDENT"})	
	aAdd(aCampo, {"C6_NOTA","C6_NOTA"})	
	aAdd(aCampo, {"D2_VALFRE","IF_VALFRE"})	
	aAdd(aCampo, {"D2_TOTAL","IF_TOTAL"})	
	aAdd(aCampo, {"DATAFAT","DATAFAT"})
	aAdd(aCampo, {"SITUACAO","SITUACAO"})	
	nCampo := len(aCampo)
	cQuery := ""
	cQuery := " WITH " 
	cQuery += " PEDIDO (P_FILPED,P_NUMPED,P_PEDZOHO) AS ( "
	cQuery += "  		SELECT DISTINCT C5_FILIAL,C5_NUM,C5_CODZHO   "
	cQuery += " FROM "+RetSQLName("SC5")+ " SC5 "
	cQuery += " INNER JOIN "+RetSQLName("SC6")+ " SC6 ON (C6_FILIAL = C5_FILIAL AND C6_NUM = C5_NUM AND SC6.D_E_L_E_T_ = '') "
	cQuery += " INNER JOIN "+RetSQLName("SB1")+ " SB1 ON (B1_FILIAL = '' AND B1_COD = C6_PRODUTO AND SB1.D_E_L_E_T_ = '') "
	cQuery += " LEFT OUTER JOIN "+RetSQLName("SC9")+ " SC9 ON (C9_FILIAL = C6_FILIAL AND C9_PEDIDO = C6_NUM AND C9_ITEM = C6_ITEM AND SC9.D_E_L_E_T_ = '') "
	cQuery += " WHERE "
	cQuery += " 		C5_FILIAL = '"+::FILPED+"' AND "
	if !empty(::NUMPED)
		cQuery += " 		C5_NUM = '"+::NUMPED+"' AND "
	endif
	if empty(::NUMPED) .and. !empty(cData)
		cQuery += " 	((CONVERT(DATE,SC5.S_T_A_M_P_) >=  '"+cData+"'	AND CONVERT(DATE,SC5.S_T_A_M_P_) <=  '"+cData+"') OR (CONVERT(DATE,SC6.S_T_A_M_P_) >=  '"+cData+"'	AND CONVERT(DATE,SC6.S_T_A_M_P_) <=  '"+cData+"') OR (CONVERT(DATE,SC9.S_T_A_M_P_) >=  '"+cData+"'	AND CONVERT(DATE,SC9.S_T_A_M_P_) <=  '"+cData+"')) AND "
	endif
	cQuery += " 		C5_CODZHO != '' AND SC5.D_E_L_E_T_ = '' "
	cQuery += " ), "
	cQuery += " VALPED (V_FILPED,V_NUMPED,V_PEDZOHO,V_VALPED) AS " 
	cQuery += " ( "
	cQuery += " SELECT P_FILPED,P_NUMPED,P_PEDZOHO,ROUND(SUM(C6_QTDVEN*C6_PRCVEN),2) C5_VALOR  FROM PEDIDO "
 	cQuery += " INNER JOIN "+RetSQLName("SC6")+ "  SC6 ON (C6_FILIAL = P_FILPED AND C6_NUM = P_NUMPED AND SC6.D_E_L_E_T_ = '') " 
 	cQuery += " INNER JOIN "+RetSQLName("SB1")+ "  SB1 ON (B1_FILIAL = '' AND B1_COD = C6_PRODUTO AND SB1.D_E_L_E_T_ = '') "
 	cQuery += " GROUP BY P_FILPED,P_NUMPED,P_PEDZOHO "
	cQuery += " ), "
	cQuery += " FATURADO (F_FILPED,F_NUMPED,F_PEDZOHO,F_VALFAT) AS "
	cQuery += " ( "
	cQuery += " SELECT P_FILPED,P_NUMPED,P_PEDZOHO,SUM(D2_TOTAL) C6_VALOR  FROM PEDIDO "
	cQuery += " INNER JOIN "+RetSQLName("SC6")+ " SC6 ON (C6_FILIAL = P_FILPED AND C6_NUM = P_NUMPED AND SC6.D_E_L_E_T_ = '' AND C6_BLQ != 'R') "
	cQuery += " INNER JOIN "+RetSQLName("SD2")+ " SD2 ON (D2_FILIAL = C6_FILIAL AND D2_PEDIDO = C6_NUM AND D2_COD = C6_PRODUTO AND D2_ITEMPV = C6_ITEM AND SD2.D_E_L_E_T_ = '' ) "
	cQuery += " GROUP BY P_FILPED,P_NUMPED,P_PEDZOHO "
	cQuery += " ), "
	cQuery += " NAOFAT (N_FILPED,N_NUMPED,N_PEDZOHO,N_VALNFAT) AS "
	cQuery += " ( "
	cQuery += " SELECT P_FILPED,P_NUMPED,P_PEDZOHO,SUM(C6_VALOR) C6_VALOR FROM PEDIDO "
	cQuery += " INNER JOIN "+RetSQLName("SC6")+ " SC6 ON (C6_FILIAL = P_FILPED AND C6_NUM = P_NUMPED AND SC6.D_E_L_E_T_ = '' AND C6_NOTA = '' AND C6_BLQ != 'R') "
	cQuery += " GROUP BY P_FILPED,P_NUMPED,P_PEDZOHO "
	cQuery += " ), "
	cQuery += " ESTOQUE (E_FILPED,E_NUMPED,E_PEDZOHO,E_VALEST) AS "
	cQuery += " ( "
	cQuery += " SELECT P_FILPED,P_NUMPED,P_PEDZOHO,SUM(C9_PRCVEN*C9_QTDLIB) VALEST FROM PEDIDO "
	cQuery += " INNER JOIN "+RetSQLName("SC6")+ " SC6 ON (C6_FILIAL = P_FILPED AND C6_NUM = P_NUMPED AND SC6.D_E_L_E_T_ = '' AND C6_NOTA = '' AND C6_BLQ != 'R' AND C6_STPESTQ != 'P') "
	cQuery += " INNER JOIN "+RetSQLName("SC9")+ " SC9 ON (C9_FILIAL = P_FILPED AND C9_PEDIDO = P_NUMPED AND C9_PRODUTO = C6_PRODUTO AND C9_BLEST IN ('02','03') AND C9_BLCRED NOT IN ('01','04','09')  AND SC9.D_E_L_E_T_ = '') "
	cQuery += " GROUP BY P_FILPED,P_NUMPED,P_PEDZOHO "
	cQuery += " ), "
	cQuery += " CREDITO (C_FILPED,C_NUMPED,C_PEDZOHO,C_VALCRE) AS "
	cQuery += " ( "
	cQuery += " SELECT P_FILPED,P_NUMPED,P_PEDZOHO,SUM(C9_PRCVEN*C9_QTDLIB) VALCRED FROM PEDIDO "
	cQuery += " INNER JOIN "+RetSQLName("SC9")+ " SC9  ON (P_FILPED = C9_FILIAL AND C9_PEDIDO = P_NUMPED AND C9_BLCRED IN ('01','04','09')  AND SC9.D_E_L_E_T_ = '') "
	cQuery += " GROUP BY P_FILPED,P_NUMPED,P_PEDZOHO "
	cQuery += " ), "
	cQuery += " SC5PED(H_FILPED,H_NUMPED,H_PEDZOHO,H_VALPED,H_VALFAT,H_VALCRE,H_VALEST,H_SITUACAO) AS "
	cQuery += " (SELECT P_FILPED,P_NUMPED,P_PEDZOHO,V_VALPED,F_VALFAT,C_VALCRE,E_VALEST, "
	cQuery += " (CASE WHEN F_VALFAT = 0 AND C_VALCRE = 0 AND E_VALEST = 0 THEN 'INCLUIDO' "  
	cQuery += " 	WHEN (V_VALPED-F_VALFAT) < .02 THEN 'FATURADO' "
	cQuery += " 	WHEN F_VALFAT > 0 AND F_VALFAT < V_VALPED   THEN 'FATURADO PARCIAL' "
	cQuery += " 	WHEN C_VALCRE > 0  THEN 'BLOQUEADO CREDITO' "
	cQuery += " 	WHEN E_VALEST > 0  THEN 'ANALISE ESTOQUE'  "
	cQuery += " 	ELSE 'AGUARDANDO FATURAMENTO' END) SITUACAO "
	cQuery += " FROM PEDIDO "
	cQuery += " INNER JOIN VALPED  ON (V_FILPED = P_FILPED AND V_NUMPED = P_NUMPED) "
	cQuery += " LEFT OUTER JOIN FATURADO ON (P_FILPED = F_FILPED AND P_NUMPED = F_NUMPED) "
	cQuery += " LEFT OUTER JOIN NAOFAT ON (P_FILPED = N_FILPED AND P_NUMPED = N_NUMPED) "
	cQuery += " LEFT OUTER JOIN ESTOQUE ON (P_FILPED = E_FILPED AND P_NUMPED = E_NUMPED) "
	cQuery += " LEFT OUTER JOIN CREDITO ON (P_FILPED = C_FILPED AND P_NUMPED = C_NUMPED) "
	cQuery += " ), "
	cQuery += " ITEMPED (C5_FILIAL, C5_NUM, C5_EMISSAO, C5_CODZHO, C5_LIBEROK, C5_ZTPLIBE, C6_PRODUTO, B1_DESC, C6_QTDVEN, C6_QTDENT, C6_NOTA, C6_ENTREG, C6_STPESTQ, C6_DATFAT, C9_BLEST, C9_BLCRED, C9_BLWMS,C6_ITEM) AS ( "
	cQuery += " SELECT C5_FILIAL, C5_NUM, C5_EMISSAO, C5_CODZHO, C5_LIBEROK, C5_ZTPLIBE, C6_PRODUTO, B1_DESC, C6_QTDVEN, C6_QTDENT, C6_NOTA, C6_ENTREG, C6_STPESTQ, C6_DATFAT, C9_BLEST, C9_BLCRED, C9_BLWMS,C6_ITEM  "
 	cQuery += " FROM SC5PED "
 	cQuery += " INNER JOIN "+RetSQLName("SC5")+ " SC5 ON (C5_FILIAL = H_FILPED AND C5_NUM = H_NUMPED AND SC5.D_E_L_E_T_ = '') "
 	cQuery += " INNER JOIN "+RetSQLName("SC6")+ " SC6 ON (C6_FILIAL = C5_FILIAL AND C6_NUM = C5_NUM AND SC6.D_E_L_E_T_ = '') "
 	cQuery += " INNER JOIN "+RetSQLName("SB1")+ " SB1 ON (B1_FILIAL = '' AND B1_COD = C6_PRODUTO AND SB1.D_E_L_E_T_ = '') "
 	cQuery += " LEFT OUTER JOIN "+RetSQLName("SC9")+ " SC9 ON (C9_FILIAL = C6_FILIAL AND C9_PEDIDO = C6_NUM AND C9_PRODUTO = C6_PRODUTO AND C9_ITEM = C6_ITEM AND C9_SEQUEN = '01' AND SC9.D_E_L_E_T_ = '') "
	cQuery += " ), "
	cQuery += " ITEMFAT (IF_FILIAL, IF_NUM, IF_PRODUTO,IF_ITEMPV,DATAFAT,IF_TOTAL,IF_VALFRE) AS ( "
	cQuery += " 	SELECT C5_FILIAL, C5_NUM,C6_PRODUTO,D2_ITEMPV,D2_EMISSAO,SUM(D2_QUANT*C6_PRCVEN) D2_TOTAL,SUM(D2_VALFRE) "
	cQuery += "  FROM SC5PED "
	cQuery += "  INNER JOIN "+RetSQLName("SC5")+ " SC5 ON (C5_FILIAL = H_FILPED AND C5_NUM = H_NUMPED AND SC5.D_E_L_E_T_ = '') "
	cQuery += "  INNER JOIN "+RetSQLName("SC6")+ " SC6 ON (C6_FILIAL = C5_FILIAL AND C6_NUM = C5_NUM AND SC6.D_E_L_E_T_ = '') "
	cQuery += "  INNER JOIN "+RetSQLName("SD2")+ " SD2 ON (D2_FILIAL = C6_FILIAL AND D2_PEDIDO = C6_NUM AND D2_COD = C6_PRODUTO AND D2_ITEMPV = C6_ITEM AND SD2.D_E_L_E_T_ = '' ) "
	cQuery += "  GROUP BY C5_FILIAL, C5_NUM,C6_PRODUTO,D2_ITEMPV,D2_EMISSAO "
	cQuery += " ) "
	cQuery += " SELECT C5_FILIAL, C5_NUM, C5_CODZHO,H_SITUACAO,H_VALPED,H_VALFAT,H_VALCRE,H_VALEST,C6_PRODUTO, B1_DESC, C6_QTDENT, C6_NOTA,IF_VALFRE,IF_TOTAL,DATAFAT, "
	cQuery += "  			(CASE WHEN C5_LIBEROK <> 'S' AND C6_NOTA = '' AND C6_STPESTQ <> 'R' THEN 'INCLUIDO'   "
	cQuery += "  			      WHEN C6_NOTA <> '' AND C9_BLEST = '10' AND C6_QTDVEN = C6_QTDENT THEN 'FATURADO' "
	cQuery += "  				  WHEN C6_NOTA <> '' AND C9_BLEST = '10' AND C6_QTDVEN > C6_QTDENT THEN 'FATURADO PARCIAL' "
	cQuery += "  				  WHEN C9_BLCRED IN ('01','04','09') AND C6_NOTA = '' THEN 'BLOQUEADO CREDITO' " 
	cQuery += "  				  WHEN C9_BLEST IN ('02','03') AND C6_STPESTQ = 'P' THEN 'ESTOQUE PENDENTE' "
	cQuery += "  				  WHEN C5_LIBEROK <> 'S' AND C6_STPESTQ = 'R' THEN 'REPRESENTADA'  "
	cQuery += "  				  WHEN C9_BLEST IN ('02','03') THEN 'BLOQUEADO ESTOQUE'  "
	cQuery += "  				  WHEN C5_ZTPLIBE = '2' THEN 'RESERVADO AGUARDANDO OUTRO ITEM'  "
	cQuery += "  				  WHEN C5_ZTPLIBE <> '2' THEN 'AGUARDANDO FATURAMENTO' "
	cQuery += "  				  ELSE 'AGUARDANDO FATURAMENTO' END) SITUACAO "
	cQuery += "  FROM SC5PED "
	cQuery += "  INNER JOIN ITEMPED ON (C5_FILIAL = H_FILPED AND C5_NUM = H_NUMPED) "
	cQuery += "  LEFT JOIN ITEMFAT ON (C5_FILIAL = IF_FILIAL AND C5_NUM = IF_NUM AND IF_PRODUTO = C6_PRODUTO AND C6_ITEM = IF_ITEMPV) "
	cQuery += "  ORDER BY C5_FILIAL, C5_NUM,C6_PRODUTO,C6_NOTA  "
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
		::SetResponse('{"SITUACAOPEDIDOS": [ ')
		while (cArea)->(!eof())
			nCount++
			if cChave != alltrim((cArea)->C5_FILIAL)+alltrim((cArea)->C5_NUM)
				if !empty(cChave)
					::SetResponse('},')
				endif
				::SetResponse('{')
				::SetResponse('"')
				::SetResponse("C5_FILIAL") 
				::SetResponse('"')
				::SetResponse(':')
				::SetResponse('"')
				::SetResponse( AllTrim( cValToChar( (cArea)->C5_FILIAL) ) )
				::SetResponse('"')
				::SetResponse(',')
				::SetResponse('"')
				::SetResponse("C5_NUM") 
				::SetResponse('"')
				::SetResponse(':')
				::SetResponse('"')
				::SetResponse( AllTrim( cValToChar( (cArea)->C5_NUM) ) )
				::SetResponse('"')
				::SetResponse(',')
				::SetResponse('"')
				::SetResponse("C5_CODZHO") 
				::SetResponse('"')
				::SetResponse(':')
				::SetResponse('"')
				::SetResponse( AllTrim( cValToChar( (cArea)->C5_CODZHO) ) )
				::SetResponse('"')
				::SetResponse(',')
				::SetResponse('"')
				::SetResponse("SITUACAO") 
				::SetResponse('"')
				::SetResponse(':')
				::SetResponse('"')
				::SetResponse( AllTrim( cValToChar( (cArea)->H_SITUACAO ) ) )
				::SetResponse('"')
				::SetResponse(',')
				::SetResponse('"')
				::SetResponse("VALORFATURADO") 
				::SetResponse('"')
				::SetResponse(':')
				::SetResponse('"')
				::SetResponse( AllTrim( cValToChar( (cArea)->H_VALFAT) ) )
				::SetResponse('"')
				::SetResponse(',')
				::SetResponse('"ITENS": [')
				//::SetResponse(',')
				cChave := alltrim((cArea)->C5_FILIAL)+alltrim((cArea)->C5_NUM)
			endif
			while (cArea)->(!eof()) .and. cChave == alltrim((cArea)->C5_FILIAL)+alltrim((cArea)->C5_NUM)
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
				(cArea)->(DBSkip())
				if (cArea)->(!eof()) .and. cChave == alltrim((cArea)->C5_FILIAL)+alltrim((cArea)->C5_NUM)
					::SetResponse(',')
				endif
			enddo
			::SetResponse(']')
			//if nCount < nReg
			//if (cArea)->(!eof()) 
			// 	::SetResponse(',')
			//endif
			//endif	
			//(cArea)->(DBSkip())
		EndDo
		::SetResponse('}]}')
		(cArea)->( dbCloseArea() )
	Conout('MAHSITPED - Finalizacao Ok')
	endif
Return( lOk )
