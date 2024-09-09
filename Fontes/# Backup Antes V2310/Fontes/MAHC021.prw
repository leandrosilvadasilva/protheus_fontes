#Include "Totvs.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MAHC021  ³ Autor ³Giovanni Melo          ³ Data ³09/06/2016³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retorna a soma das qtds dos pedidos de compras do produto   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³u_MahC021(ExpC1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Codigo do produto                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpN2: Soma das quantidades                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Especifico MA Hospitalar                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                          ULTIMAS ALTERACOES                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ Motivo da Alteracao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function MAHC021( cCodProd )

	Local nSomaQtd  := 0
	Local cQuery 	:= ""
	Local cQueryPRE := ""
	Local cAliasTmp	:= GetNextAlias()
	Local cAliasPRE	:= GetNextAlias()
	
//-------------------------------------------------------------- calcula qtde pedidos de compra
	cQuery := "SELECT "
	cQuery += "	 SUM(C7_QUANT - C7_QUJE) AS SOMA_QTD "
	cQuery += "FROM "
	cQuery +=	 RetSqlName("SC7")
	cQuery += "WHERE "
	cQuery += "	 C7_PRODUTO = '"+cCodProd+"' "
	cQuery += "AND C7_RESIDUO = '' "
	cQuery += "AND (C7_QUANT - C7_QUJE) > 0 "
	cQuery += "AND C7_FILIAL = '"+xFilial("SC7")+"' "
	cQuery += "AND D_E_L_E_T_ <> '*'"	
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.F.,.T. )
	
	nSomaQtd := ( cAliasTmp )->SOMA_QTD
	
	( cAliasTmp )->( dbCloseArea() )
	
	// Ednei 07.06.19
	// Com o ajuste da transferencia automatica o protheus nao criara 
	// pedido compras. Para saber o saldo de PC por produto foi adicionado 
	// o codigo abaixo.
	  
/* ---------------------------------------------------------- anulado porque este saldo está separado em outra coluna
	cQueryPRE :=""
	cQueryPRE := " SELECT "
	cQueryPRE += " SUM(D1_QUANT) AS SOMA_PRE FROM "
	cQueryPRE += 	RetSqlName("SD1")+" SD1 "
	cQueryPRE += "	INNER JOIN "+RetSqlName("SA2")+ " SA2 ON (SA2.A2_COD=SD1.D1_FORNECE AND SA2.A2_LOJA=SD1.D1_LOJA) "
	cQueryPRE += "	WHERE D1_COD = '"+cCodProd+"' "
	cQueryPRE += "  AND D1_FILIAL = '"+xFilial("SD1")+"' "
	cQueryPRE += "  AND SA2.D_E_L_E_T_ <> '*'"	
	cQueryPRE += "  AND SD1.D_E_L_E_T_ <> '*'"
	cQueryPRE += "  AND SD1.D1_NUMSEQ  = ''"
	
	MEMOWRITE("StatusPVSaldoPre.SQL",cQueryPRE)
	cQueryPRE := ChangeQuery( cQueryPRE )
	dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQueryPRE),cAliasPRE,.F.,.T. )
	
	// soma a quantidade de PC mais a quantidade de Pre nota.
	nSomaQtd := nSomaQtd+( cAliasPRE )->SOMA_PRE

	( cAliasPRE )->( dbCloseArea() )
---------------------------------------------------------------------------------------*/

Return(nSomaQtd)
                      

// Retorno para multi filiais  --------------------------- Pedidos de Compra Multi-filiais
User Function MAHC021a( cCodProd )

	Local nSomaQtd := 0
	Local cQuery 	:= ""
	Local cAliasTmp	:= GetNextAlias()
	
	cQuery := "SELECT "
	cQuery += "	 SUM(C7_QUANT - C7_QUJE) AS SOMA_QTD "
	cQuery += "FROM "
	cQuery +=	 RetSqlName("SC7")
	cQuery += "WHERE "
	cQuery += "	 C7_PRODUTO = '"+cCodProd+"' "
	cQuery += "AND C7_RESIDUO = '' "
	cQuery += "AND (C7_QUANT - C7_QUJE) > 0 "
	//cQuery += "AND C7_FILIAL = '"+xFilial("SC7")+"' "
	cQuery += "AND D_E_L_E_T_ <> '*'"	
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.F.,.T. )
	
	nSomaQtd := ( cAliasTmp )->SOMA_QTD
	
	( cAliasTmp )->( dbCloseArea() )

Return(nSomaQtd)

//-------------------------------------------------------- criado para obter o saldo das Pre-Notas - 05-03-22 (Marlovani)
User Function MAHC021b( cCodProd )

	Local nSomaQtd  := 0
	Local cQueryPRE := ""
	Local cAliasPRE	:= GetNextAlias()
	
	cQueryPRE :=""
	cQueryPRE := " SELECT "
	cQueryPRE += " SUM(D1_QUANT) AS SOMA_PRE FROM "
	cQueryPRE += 	RetSqlName("SD1")+" SD1 "
	cQueryPRE += "	INNER JOIN "+RetSqlName("SA2")+ " SA2 ON (SA2.A2_COD=SD1.D1_FORNECE AND SA2.A2_LOJA=SD1.D1_LOJA) "
	cQueryPRE += "	WHERE D1_COD       = '"+cCodProd+"' "
	cQueryPRE += "  AND D1_FILIAL      = '"+xFilial("SD1")+"' "
	cQueryPRE += "  AND SA2.D_E_L_E_T_ <> '*'"	
	cQueryPRE += "  AND SD1.D_E_L_E_T_ <> '*'"
	cQueryPRE += "  AND SD1.D1_NUMSEQ  = ''"
	
	MEMOWRITE("StatusPVSaldoTrans.SQL",cQueryPRE)
	cQueryPRE := ChangeQuery( cQueryPRE )
	dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQueryPRE),cAliasPRE,.F.,.T. )
	
	// soma a quantidade a quantidade de Pre nota.
	nSomaQtd := ( cAliasPRE )->SOMA_PRE
	
	( cAliasPRE )->( dbCloseArea() )

Return(nSomaQtd)
