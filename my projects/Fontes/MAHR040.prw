#Include "Totvs.Ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MAHR040   ³ Autor ³Gregory Araujo         ³ Data ³17/10/2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Metodo para criacao do relatorio em planilha excel          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³MAHR040()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1: Array de itens de pedidos filtrados na rotina pai    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function MAHR040()
	
	Local		aDados		:= {} 
	Local cPerg		:= PadR("MAHR040",10)
	Private	oReport	:= Nil
	Private	oSecti1	:= Nil
	Private	oBreak
	private	oFunction
	
	
	CRIASX1(cPerg)
	If Pergunte(cPerg,.T.)
	
		aDados := R040EXPD()    //Dados para exportação
		
		oReport := TReport():New('Relatorio',"Relatório CRM" ,,{|oReport| R040RptPr(oReport, aDados)},"Relatório CRM")
			
		oReport:SetLandScape()
		oReport:SetTotalInLine(.F.)	//define se totalizadores serão em linha ou colunas
		
		oReport:PrintDialog()
	
	EndIf
		
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³R040RptPr  ³ Autor ³Gregory Araujo        ³ Data ³17/10/2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Metodo para criacao do relatorio                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³R040RptPr()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Grupo de perguntas                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R040RptPr(oReport, aDados) 

	Local nI			:= 0
	
	oSecti1:= TRSection():New(oReport, "Colunas", {}	, NIL, .F., .T.)
	
	TRCell():New(oSecti1,"FILIAL"  		,"XXX"	,"Filial"						, PesqPict("ADZ","ADZ_FILIAL") , TamSX3("ADZ_FILIAL")[1])
	TRCell():New(oSecti1,"VEND"  		,"XXX"	,"Vendedor"					, PesqPict("SA3","A3_NOME")		, TamSX3("A3_NOME")[1])
	TRCell():New(oSecti1,"CLIENT"  		,"XXX"	,"Cliente"					, PesqPict("SA1","A1_NOME")		, TamSX3("A1_NOME")[1])
	TRCell():New(oSecti1,"OPORT"  		,"XXX"	,"Oportunidade"				, PesqPict("ADY","ADY_OPORTU") , TamSX3("ADY_OPORTU")[1])
	TRCell():New(oSecti1,"DESC_OP"  	,"XXX"	,"Descricao_Oportunidade", PesqPict("AD1","AD1_DESCRI") , TamSX3("AD1_DESCRI")[1])
	TRCell():New(oSecti1,"PROC_VEN"  	,"XXX"	,"Processo_Vendas"			, PesqPict("AC1","AC1_DESCRI") , TamSX3("AC1_DESCRI")[1])
	TRCell():New(oSecti1,"ESTG_VEN"		,"XXX"	,"Estagio_Vendas"			, PesqPict("AC2","AC2_DESCRI") , TamSX3("AC2_DESCRI")[1])
	TRCell():New(oSecti1,"COD_PROD"		,"XXX"	,"Codigo_Produto"			, PesqPict("AD2","ADZ_PRODUT") , TamSX3("ADZ_PRODUT")[1])
	TRCell():New(oSecti1,"DESC_PROD"	,"XXX"	,"Descricao_Produto"		, PesqPict("SB1","B1_DESC")		, TamSX3("B1_DESC")[1])
	TRCell():New(oSecti1,"MARC_PROD"  	,"XXX"	,"Marca_Produto"			, PesqPict("SX5","X5_DESCRI")	, TamSX3("X5_DESCRI")[1])
	TRCell():New(oSecti1,"GRP_PROD"  	,"XXX"	,"Grupo_Produto"			, PesqPict("SBM","BM_DESC")		, TamSX3("BM_DESC")[1])
	TRCell():New(oSecti1,"PROP"  		,"XXX"	,"Proposta"					, PesqPict("ADZ","ADZ_PROPOS") , TamSX3("ADZ_PROPOS")[1])
	TRCell():New(oSecti1,"REVIS"  		,"XXX"	,"Revisao" 	  				, PesqPict("ADZ","ADZ_REVISA") , TamSX3("ADZ_REVISA")[1])
	TRCell():New(oSecti1,"DESC_PROP"  	,"XXX"	,"Descricao_Proposta"		, PesqPict("ADZ","ADZ_DESCRI") , TamSX3("ADZ_DESCRI")[1])
	TRCell():New(oSecti1,"ITEM"  		,"XXX"	,"Item"	  					, PesqPict("ADZ","ADZ_ITEM")	, TamSX3("ADZ_ITEM")[1])
	TRCell():New(oSecti1,"MOEDA"  		,"XXX"	,"Moeda"  					, PesqPict("ADZ","ADZ_MOEDA")	, TamSX3("ADZ_MOEDA")[1])
	TRCell():New(oSecti1,"ST_OP"  		,"XXX"	,"Status_Oportunidade"  	, PesqPict("AD1","AD1_STATUS") , TamSX3("AD1_STATUS")[1])	
	TRCell():New(oSecti1,"ST_PROP"  	,"XXX"	,"Status_Proposta"  		, PesqPict("ADY","ADY_STATUS") , TamSX3("ADY_STATUS")[1])		
	TRCell():New(oSecti1,"TP_PROC"  	,"XXX"	,"Tipo_Processo"  			, PesqPict("AD1","AD1_TPPROP") , TamSX3("AD1_TPPROP")[1])	
	TRCell():New(oSecti1,"QTD"  		,"XXX"	,"Quantidade"  				, PesqPict("ADZ","ADZ_QTDVEN") , TamSX3("ADZ_QTDVEN")[1])	
	TRCell():New(oSecti1,"PRC_TAB"  	,"XXX"	,"Preco_Tabela"  			, PesqPict("ADZ","ADZ_PRCTAB") , TamSX3("ADZ_PRCTAB")[1])	
	TRCell():New(oSecti1,"PRC_VEN"  	,"XXX"	,"Preco_Venda"  			, PesqPict("ADZ","ADZ_PRCVEN") , TamSX3("ADZ_PRCVEN")[1])	
 	TRCell():New(oSecti1,"VAL_TOT"  	,"XXX"	,"Valor_Total"  			, PesqPict("ADZ","ADZ_TOTAL")	, TamSX3("ADZ_TOTAL")[1])	
	
	oSecti1:SetPageBreak(.T.)
	oSecti1:SetCellBorder("ALL",1,,.T.)
	
	oReport:SetMeter( Len(aDados) )
	oReport:SetMsgPrint("Gerando Planilha")
	
	oSecti1:SetHeaderSection(.T.)
	oSecti1:Init()
	
	For nI := 1 To Len(aDados) //Todas os registros
		
		oReport:IncMeter(1)
		
		oSecti1:Cell("FILIAL"):SetBlock(	{|| aDados[nI][1]	}	)
		oSecti1:Cell("VEND"):SetBlock(		{|| aDados[nI][2]	}	)
		oSecti1:Cell("CLIENT"):SetBlock(	{|| aDados[nI][3]	}	)
		oSecti1:Cell("OPORT"):SetBlock(		{|| aDados[nI][4]	}	)
		oSecti1:Cell("DESC_OP"):SetBlock(	{|| aDados[nI][5]	}	)
		oSecti1:Cell("PROC_VEN"):SetBlock(	{|| aDados[nI][6]	}	)
		oSecti1:Cell("ESTG_VEN"):SetBlock(	{|| aDados[nI][7]	}	)
		oSecti1:Cell("COD_PROD"):SetBlock(	{|| aDados[nI][8]	}	)
		oSecti1:Cell("DESC_PROD"):SetBlock({|| aDados[nI][9] }	)
		oSecti1:Cell("MARC_PROD"):SetBlock({|| aDados[nI][10]}	)
		oSecti1:Cell("GRP_PROD"):SetBlock(	{|| aDados[nI][11] }	)
		
		oSecti1:Cell("PROP"):SetBlock(		{|| aDados[nI][12] }	)
		oSecti1:Cell("REVIS"):SetBlock(		{|| aDados[nI][13] }	)
		oSecti1:Cell("DESC_PROP"):SetBlock({|| aDados[nI][14]}	)
		
		oSecti1:Cell("ITEM"):SetBlock(		{|| aDados[nI][15] }	)
		oSecti1:Cell("MOEDA"):SetBlock(		{|| aDados[nI][16] }	)
		oSecti1:Cell("ST_OP"):SetBlock(		{|| aDados[nI][17] }	)
		oSecti1:Cell("ST_PROP"):SetBlock(	{|| aDados[nI][18] }	)
		oSecti1:Cell("TP_PROC"):SetBlock(	{|| aDados[nI][19] }	)
		
		oSecti1:Cell("QTD"):SetBlock(		{|| aDados[nI][20]	}	)
		oSecti1:Cell("PRC_TAB"):SetBlock(	{|| aDados[nI][21]	}	)
		oSecti1:Cell("PRC_VEN"):SetBlock(	{|| aDados[nI][22]	}	)
		oSecti1:Cell("VAL_TOT"):SetBlock(	{|| aDados[nI][23]	}	)
		
		oSecti1:SetCellBorder( "ALL",1 )
		oSecti1:Printline()
			
	Next nI
			
	oSecti1:Finish()
	oReport:EndPage()
	oReport:IncMeter(1)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³R040EXPD  ³ Autor ³Gregory Araujo         ³ Data ³17/10/2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Metodo para retornar os dados selecionados pela query       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³R040EXPD()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpA1: Array de itens filtrados                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function R040EXPD()
	
	Local cQuery	:= ""
	Local cAliasTmp	:= GetNextAlias()
	Local aDados	:= {}
	
	cQuery := " SELECT " 
	cQuery += "        	ADZ.ADZ_FILIAL Filial"
	cQuery += " 		,(SELECT A3_NOME from "+RetSQLName("SA3")
	cQuery += " 			where D_E_L_E_T_ = '' and A3_COD = ADY.ADY_VEND  AND A3_FILIAL = '"+xFilial("SA3")+"'"
	cQuery += " 			AND (A3_COD BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "') ) Vendedor"

	
	cQuery += " 		,(SELECT A1_NOME from "+RetSQLName("SA1")
	cQuery += " 			where D_E_L_E_T_ = ''  AND A1_FILIAL = '"+xFilial("SA1")+"'"
	cQuery += " 			and A1_COD = ADY.ADY_CODIGO"
	cQuery += " 			and A1_LOJA = ADY.ADY_LOJA"
	cQuery += " 			and (A1_COD BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR05 + "')"
	cQuery += " 			and (A1_LOJA BETWEEN '" + MV_PAR04 + "' AND '" + MV_PAR06 + "')  ) Cliente"

	
	cQuery += " 		,ADY.ADY_OPORTU AS Oportunidade"
	
	cQuery += " 		,(SELECT AD1_DESCRI from "+RetSQLName("AD1")
	cQuery += " 			where D_E_L_E_T_ = ''  AND AD1_FILIAL = '"+xFilial("AD1")+"'"
	cQuery += " 			and AD1_NROPOR = ADY.ADY_OPORTU"
	cQuery += " 			and AD1_REVISA = ADY.ADY_REVISA) Descricao_Oportunidade"
	
	cQuery += " 		,(SELECT AC1_DESCRI "
	cQuery += " 			from "+RetSQLName("AC1")+" inner join "+RetSQLName("AD1")
	cQuery += " 			on AC1_FILIAL = AD1_FILIAL"
	cQuery += " 			and AC1_PROVEN = AD1_PROVEN"
	cQuery += " 			where "+RetSQLName("AC1")+".D_E_L_E_T_ = '' AND AC1_FILIAL = '"+xFilial("AC1")+"'"
	cQuery += " 			and "+RetSQLName("AD1")+".D_E_L_E_T_ ='' AND AD1_FILIAL = '"+xFilial("AD1")+"'"
	cQuery += " 			and AD1_NROPOR = ADY.ADY_OPORTU "
	cQuery += " 			and AD1_REVISA = ADY.ADY_REVISA) Processo_Vendas"
	
	cQuery += " 		,(SELECT AC2_DESCRI "
	cQuery += " 			from "+RetSQLName("AC2")+" inner join "+RetSQLName("AD1")
	cQuery += " 			on AC2_FILIAL = AD1_FILIAL"
	cQuery += " 			and AC2_PROVEN = AD1_PROVEN"
	cQuery += " 			and AC2_STAGE = AD1_STAGE "
	cQuery += " 			where "+RetSQLName("AC2")+".D_E_L_E_T_ = '' AND AC2_FILIAL = '"+xFilial("AC2")+"'"
	cQuery += " 			and "+RetSQLName("AD1")+".D_E_L_E_T_ = '' AND AD1_FILIAL = '"+xFilial("AD1")+"'"
	cQuery += " 			and AD1_NROPOR = ADY.ADY_OPORTU"
	cQuery += " 			and AD1_REVISA = ADY.ADY_REVISA) Estagio_Vendas"
	          
	cQuery += " 		,ADZ.ADZ_PRODUT Codigo_Produto"
	
	cQuery += " 		,(SELECT B1_DESC from "+RetSQLName("SB1")
	cQuery += " 			where D_E_L_E_T_ = '' AND B1_FILIAL = '"+xFilial("SB1")+"'"
	cQuery += " 			and B1_COD = ADZ.ADZ_PRODUT) Descricao_Produto"
	
	cQuery += " 		,(SELECT X5_DESCRI "
	cQuery += " 			from "+RetSQLName("SX5")
	cQuery += " 			where D_E_L_E_T_ = ''  "
	cQuery += " 			and X5_TABELA = 'ZX'"
	cQuery += " 			and X5_CHAVE = (SELECT B1_MARCA from "+RetSQLName("SB1")
	cQuery += " 			where D_E_L_E_T_ = '' AND B1_FILIAL = '"+xFilial("SB1")+"'"
	cQuery += " 			and B1_COD = ADZ.ADZ_PRODUT"
	cQuery += " 			AND (B1_MARCA BETWEEN '" + MV_PAR11 + "' AND '" + MV_PAR12 + "') ) ) Marca_Produt"
	          
	cQuery += " 		,(SELECT BM_DESC"
	cQuery += " 			from "+RetSQLName("SBM")
	cQuery += " 			where D_E_L_E_T_ = '' AND BM_FILIAL = '"+xFilial("SBM") +"'"
	cQuery += " 			and BM_GRUPO = (SELECT B1_GRUPO from "+RetSQLName("SB1")
	cQuery += " 			where D_E_L_E_T_ = '' AND B1_FILIAL = '"+xFilial("SB1") +"'"
	cQuery += " 			and B1_COD = ADZ.ADZ_PRODUT"
	cQuery += " 			and (B1_GRUPO BETWEEN '" + AllTrim(MV_PAR13) + "' AND '" + (MV_PAR14) + "') ) ) Grupo_Produto"
	
	cQuery += " 		,ADZ.ADZ_PROPOS Proposta"
	cQuery += " 		,ADZ.ADZ_REVISA Revisao"
	cQuery += " 		,ADZ.ADZ_DESCRI Descricao_Proposta"
	cQuery += " 		,ADZ.ADZ_ITEM Item"
	cQuery += " 		,ADZ.ADZ_MOEDA Moeda"
	
	cQuery += " 		,CASE (select AD1_STATUS "
	cQuery += " 			from "+RetSQLName("AD1")
	cQuery += " 			where D_E_L_E_T_ = '' AND AD1_FILIAL = '"+xFilial("AD1") +"'"
	If !Empty(MV_PAR16)
		cQuery += " 		and AD1.AD1_STATUS = '"+MV_PAR16+"'"
	Endif
	cQuery += " 			and AD1_NROPOR = ADY.ADY_OPORTU"
	cQuery += " 			and AD1_REVISA = ADY.ADY_REVISA)"
	cQuery += " 			WHEN '1' THEN 'Aberta'"
	cQuery += " 			WHEN '2' THEN 'Perdido'"
	cQuery += " 			WHEN '3' THEN 'Suspenso'"
	cQuery += " 			WHEN '9' THEN 'Ganha'"
	cQuery += " 			END Status_Oportunidade"
	
	cQuery += " 		,ADY.ADY_STATUS Status_Proposta"
	
	cQuery += " 		,CASE (select AD1_TPPROP "
	cQuery += " 			from "+RetSQLName("AD1")
	cQuery += " 			where D_E_L_E_T_ = '' and AD1_FILIAL = '"+xFilial("AD1")+"'"
	cQuery += " 			and AD1_NROPOR = ADY.ADY_OPORTU"
	cQuery += " 			and AD1_REVISA = ADY.ADY_REVISA)"
	cQuery += " 			WHEN '1' THEN 'Revenda'"
	cQuery += " 			WHEN '2' THEN 'Representacao'"
	cQuery += " 			WHEN '3' THEN 'Importacao Direta'"
	cQuery += " 			WHEN '4' THEN 'Locacao'"
	cQuery += " 			WHEN '5' THEN 'Contrato Manutencao'"
	cQuery += " 			WHEN '6' THEN 'Comodato'"
	cQuery += " 			END Tipo_Processo"
	          
	cQuery += " 		,ADZ.ADZ_QTDVEN Quantidade"
	cQuery += " 		,ADZ.ADZ_PRCTAB Preco_Tabela"
	cQuery += " 		,ADZ.ADZ_PRCVEN Preco_Venda"
	cQuery += " 		,ADZ.ADZ_TOTAL Valor_Total"
	          
	cQuery += " 		from "+RetSQLName("ADZ")+" ADZ inner join " + RetSQLName("ADY") + " ADY "
	cQuery += " 		on ADZ.ADZ_FILIAL = ADY.ADY_FILIAL"
	cQuery += " 		and ADZ.ADZ_PROPOS = ADY.ADY_PROPOS"
	          
	cQuery += " 		where ADZ.D_E_L_E_T_ = '' and ADY.D_E_L_E_T_ = '' and ADZ.ADZ_FILIAL = '"+xFilial("ADZ")+"' and ADY.ADY_FILIAL = '"+xFilial("ADY")+"'"

	cQuery += " 		and (ADY.ADY_OPORTU BETWEEN '" + AllTrim(MV_PAR07) + "' AND '" + AllTrim(MV_PAR08) + "')"
	cQuery += " 		and (ADZ.ADZ_PRODUT BETWEEN '" + AllTrim(MV_PAR09) + "' AND '" + AllTrim(MV_PAR10) + "')"

	If !Empty(MV_PAR15)
		cQuery += " 	and ADZ.ADZ_REVISA = '"+ AllTrim(MV_PAR15) +"'"
	EndIf
	
	If !Empty(MV_PAR17)
		cQuery += " 	and ADY.ADY_STATUS = '"+ AllTrim(MV_PAR17) +"'"
	EndIf

	cQuery += " and ADZ.ADZ_REVISA = (select MAX(ADZ_REVISA) "
	cQuery += " from "+RetSQLName("ADZ")+" where D_E_L_E_T_ = '' "
	cQuery += " and ADZ_FILIAL = ADZ.ADZ_FILIAL"
	cQuery += " and ADZ_PROPOS = ADZ.ADZ_PROPOS )"
	
	//cQuery := ChangeQuery( cQuery )         
	dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.F.,.T. )
	
	While ( cAliasTmp )->(!EoF())
	
		aAdd(aDados, {	( cAliasTmp )->Filial,;
							( cAliasTmp )->Vendedor,;
							( cAliasTmp )->Cliente,;
							( cAliasTmp )->Oportunidade,;
							( cAliasTmp )->Descricao_Oportunidade,;
							( cAliasTmp )->Processo_Vendas,;
							( cAliasTmp )->Estagio_Vendas,;
							( cAliasTmp )->Codigo_Produto,;
							( cAliasTmp )->Descricao_Produto,;
							( cAliasTmp )->Marca_Produto,;
							( cAliasTmp )->Grupo_Produto,;
							( cAliasTmp )->Proposta,;
							( cAliasTmp )->Revisao,;
							( cAliasTmp )->Descricao_Proposta,;
							( cAliasTmp )->Item,;
							( cAliasTmp )->Moeda,;
							( cAliasTmp )->Status_Oportunidade,;
							( cAliasTmp )->Status_Proposta,;
							( cAliasTmp )->Tipo_Processo,;
							( cAliasTmp )->Quantidade,;
							( cAliasTmp )->Preco_Tabela,;
							( cAliasTmp )->Preco_Venda,;
							( cAliasTmp )->Valor_Total })
		
		( cAliasTmp )->(dbSkip())
		
	EndDo

	( cAliasTmp )->(dbCloseArea())
	
Return( aDados )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ R050SX1  ³ Autor ³ Gregory Araujo        ³ Data ³21/07/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cria as perguntas do Relatorio                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CRIASX1(cPerg)

	Local aP		:= {}
	Local aHelp	:= {}
	Local nI		:= 0
	Local cSeq		:= ""
	Local cMvCh		:= ""
	Local cMvPar	:= ""
	//			Texto Pergunta  			Tipo 	Tam Dec G=get ou C=Choice Val F3 Def01 Def02 Def03 Def04 Def05

	aAdd(aP,{ "Vendedor De?"				,"C", TamSx3("A3_COD")[1]	,	0,	"G"  ,	"","SA3","",	  "",	 "",	  "",	 "" })
	aAdd(aP,{ "Vendedor Até?"			,"C", TamSx3("A3_COD")[1]	,	0,	"G"  ,	"",	"SA3","",	  "",	 "",	  "",	 "" })
	
	aAdd(aP,{ "Cliente De?"				,"C", TamSx3("A1_COD")[1]	,	0,	"G"  ,	"","SA1","",	  "",	 "",	  "",	 "" })
	aAdd(aP,{ "Loja De?"					,"C", TamSx3("A1_LOJA")[1]	,	0,	"G"  ,	"",	 "",  "",	  "",	 "",	  "",	 "" })
	aAdd(aP,{ "Cliente Até?"				,"C", TamSx3("A1_COD")[1]	,	0,	"G"  ,	"",	"SA1","",	  "",	 "",	  "",	 "" })
	aAdd(aP,{ "Loja Até?"					,"C", TamSx3("A1_LOJA")[1]	,	0,	"G"  ,	"",	 ""	,  "",	  "",	 "",	  "",	 "" })
	
	aAdd(aP,{ "Oportunidade De?"		,"C", TamSx3("ADY_OPORTU")[1],	0,	"G"  ,	"",	"","",	  "",	 "",	  "",	 "" })
	aAdd(aP,{ "Oportunidade Até?"		,"C", TamSx3("ADY_OPORTU")[1],	0,	"G"  ,	"",	"","",	  "",	 "",	  "",	 "" })
	
	aAdd(aP,{ "Produto de ?"  			,"C",TamSx3("ADZ_PRODUT")[1], 0, "G","","SB1","","","","","",2})
	aAdd(aP,{ "Produto até ?" 			,"C",TamSx3("ADZ_PRODUT")[1], 0, "G","","SB1","","","","","",2})
	
	aAdd(aP,{ "Marca de ?"  				,"C",TamSx3("B1_MARCA")[1], 0, "G","","","ZX","","","","",2})
	aAdd(aP,{ "Marca até ?" 				,"C",TamSx3("B1_MARCA")[1], 0, "G","","","ZX","","","","",2})
	
	aAdd(aP,{ "Grupo de ?"  				,"C",TamSx3("B1_GRUPO")[1], 0, "G","","B02","","","","","",2})
	aAdd(aP,{ "Grupo até ?" 				,"C",TamSx3("B1_GRUPO")[1], 0, "G","","B02","","","","","",2})
	
	aAdd(aP,{ "Revisão ?" 				,"C",TamSx3("ADZ_REVISA")[1], 0, "G","","","","","","","",2})
	
	aAdd(aP,{ "Status Oportunidade?" 	,"C",TamSx3("AD1_STATUS")[1], 0, "G","","","","","","","",2})
	
	aAdd(aP,{ "Status Proposta ?" 		,"C",TamSx3("ADY_STATUS")[1], 0, "G","","","","","","","",2})
	
	//Preparação do Help dos Campos.
	aAdd(aHelp,{"Informe o Código do Vendedor."})	//MV_PAR01
	aAdd(aHelp,{"Informe o Código do Vendedor."})	//MV_PAR02
	
	aAdd(aHelp,{"Informe o Código do Cliente."})	//MV_PAR03
	aAdd(aHelp,{"Informe a Loja do Cliente."})		//MV_PAR04
	aAdd(aHelp,{"Informe o Código do Cliente."})	//MV_PAR05
	aAdd(aHelp,{"Informe a Loja do Cliente."})		//MV_PAR06
	
	aAdd(aHelp,{"Informe o Código da Oport."})//MV_PAR07
	aAdd(aHelp,{"Informe o Código da Oport."})//MV_PAR08
	
	aAdd(aHelp,{"Informe o Código do Produto."})	//MV_PAR09
	aAdd(aHelp,{"Informe o Código do Produto."})	//MV_PAR10
	
	aAdd(aHelp,{"Informe o Código da Marca."})		//MV_PAR11
	aAdd(aHelp,{"Informe o Código da Marca."})		//MV_PAR12
	
	aAdd(aHelp,{"Informe o Grupo de Produtos."})	//MV_PAR13
	aAdd(aHelp,{"Informe o Grupo de Produtos."})	//MV_PAR14
	
	aAdd(aHelp,{"Informe o Código da Revisão."})	//MV_PAR15
	aAdd(aHelp,{"Informe o Status de Oportunidade."})//MV_PAR16
	aAdd(aHelp,{"Informe o Status de Proposta."})	//MV_PAR17
	
	For nI := 1 To Len(aP)

		cSeq	:= StrZero(nI,2,0)
		cMvPar	:= "mv_par"+cSeq
		cMvCh	:= "mv_ch"+IIF(nI<=9,Chr(nI+48),Chr(nI+87))

		PutSx1(cPerg,;
		cSeq,;
		aP[nI,1],aP[nI,1],aP[nI,1],;
		cMvCh,;
		aP[nI,2],;
		aP[nI,3],;
		aP[nI,4],;
		1,;
		aP[nI,5],;
		aP[nI,6],;
		aP[nI,7],;
		"",;
		"",;
		cMvPar,;
		aP[nI,8],aP[nI,8],aP[nI,8],;
		"",;
		aP[nI,9],aP[nI,9],aP[nI,9],;
		aP[nI,10],aP[nI,10],aP[nI,10],;
		aP[nI,11],aP[nI,11],aP[nI,11],;
		aP[nI,12],aP[nI,12],aP[nI,12],;
		aHelp[nI],;
		{},;
		{},;
		"")

	Next nI
	
Return
