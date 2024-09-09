#Include "Totvs.Ch"

//Posicoes do Array dos Dados
#Define POS_NUM_PEDIDO		01
#Define POS_ITE_PEDIDO		02
#Define POS_PRODUTO		03
#Define POS_DESC_PROD		04
#Define POS_SALDO_DISP		05
#Define POS_QTDE_PREVIS	06
#Define POS_PREV_ENTREG	07
#Define POS_COD_CLIENTE	08
#Define POS_LOJ_CLIENTE	09
#Define POS_NOM_CLIENTE	10
#Define POS_VALOR			11
#Define POS_EMISSAO		12
#Define POS_STATUS_PED		13
#Define POS_NOTAFISCAL		14
#Define POS_DATAFATURA		15
#Define POS_TRANSPORTA		16
#Define POS_VEND1			17
#Define POS_VEND2			18
#Define POS_VEND3			19
#Define POS_VEND4			20
#Define POS_VEND5			21
#Define POS_QTDEVEND		22
#Define POS_SALDOFIL		23
#Define POS_QTDEENTR		24
#Define POS_QTD_PREVISF		25

#Define POS_TES     		26
#Define POS_SLD0101   		27
#Define POS_SLD0102   		28
#Define POS_SLD0103   		29

#Define POS_SLD_ENTREG 		30
#Define POS_PREV_TRANS 		31

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MAHR030   ³ Autor ³Gregory Araujo         ³ Data ³10/10/2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Metodo para criacao do relatorio em planilha excel          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³MAHR030()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1: Array de itens de pedidos filtrados na rotina pai    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function MAHR030(aDados)
	
	Private oReport	:= Nil
	Private oSecti1	:= Nil
	Private oBreak
	private oFunction
	
	oReport := TReport():New('Relatorio_Status',"Relatório de Status de Pedido" ,,{|oReport| ReportPrint(oReport, aDados)},"Relatório de Status de Pedido")
		
	oReport:SetLandScape()
	oReport:SetTotalInLine(.F.)	//define se totalizadores serão em linha ou colunas
	
	oReport:PrintDialog()
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ReportPrint³ Autor ³Gregory Araujo        ³ Data ³23/06/2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Metodo para criacao do relatorio                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ReportPrint()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Grupo de perguntas                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportPrint(oReport, aDados) 

	Local nI			:= 0
	
	Private oFont7	   	:= TFont( ):New( 'Arial',,7,.F.,.F. )	
	Private oFont8		:= TFont( ):New( 'Arial',,8,.F.,.F. )	
		
	oSecti1:= TRSection():New(oReport, "Colunas", {}	, NIL, .F., .T.)
	
	TRCell():New(oSecti1,"NUMPED"  		,"XXX"	,"Pedido"				, PesqPict("SC6","C6_NUM") , TamSX3("C6_NUM")[1])
	TRCell():New(oSecti1,"TES"  		,"XXX"	,"TES"  				, PesqPict("SC6","C6_TES") , TamSX3("C6_TES")[1])
	TRCell():New(oSecti1,"ITEM"  		,"XXX"	,"Item"					, PesqPict("SC6","C6_ITEM") , TamSX3("C6_ITEM")[1])
	TRCell():New(oSecti1,"PROD"  		,"XXX"	,"Produto"				, PesqPict("SB1","B1_COD") , TamSX3("B1_COD")[1])
	TRCell():New(oSecti1,"DESC"  		,"XXX"	,"Descricao"			, PesqPict("SB1","B1_DESC") , TamSX3("B1_DESC")[1])
	TRCell():New(oSecti1,"STATUS"  		,"XXX"	,"Status"				, PesqPict("SA1","A1_NREDUZ") , TamSX3("A1_NREDUZ")[1])
	TRCell():New(oSecti1,"QTDPED"  		,"XXX"	,"Qtd vendida"			, PesqPict( "SB2", "B2_QATU" ) , TamSX3("B2_QATU")[1])
	TRCell():New(oSecti1,"SLDENTREG"  	,"XXX"	,"Qtd a Entregar"		, PesqPict( "SB2", "B2_QATU" ) , TamSX3("B2_QATU")[1])
//	TRCell():New(oSecti1,"SALDDISP"		,"XXX"	,"Saldo Disponivel"		, PesqPict( "SB2", "B2_QATU" ) , TamSX3("B2_QATU")[1])
//	TRCell():New(oSecti1,"SALDMULT"		,"XXX"	,"Saldo Multi Filial"	, PesqPict( "SB2", "B2_QATU" ) , TamSX3("B2_QATU")[1])
	TRCell():New(oSecti1,"SALD0101"		,"XXX"	,"Saldo 0101"   		, PesqPict( "SB2", "B2_QATU" ) , TamSX3("B2_QATU")[1])
    TRCell():New(oSecti1,"SALD0102"		,"XXX"	,"Saldo 0102"       	, PesqPict( "SB2", "B2_QATU" ) , TamSX3("B2_QATU")[1])
    TRCell():New(oSecti1,"SALD0103"		,"XXX"	,"Saldo 0103"       	, PesqPict( "SB2", "B2_QATU" ) , TamSX3("B2_QATU")[1])
	TRCell():New(oSecti1,"QTDTRANS"  	,"XXX"	,"Qtd. Prev. Trans."	, PesqPict( "SB2", "B2_QATU" ) , TamSX3("B2_QATU")[1])
	TRCell():New(oSecti1,"QTDPREV"  	,"XXX"	,"Qtd. Prev. Compra"	, PesqPict( "SB2", "B2_QATU" ) , TamSX3("B2_QATU")[1])
//	TRCell():New(oSecti1,"QTDPRMF"  	,"XXX"	,"Qtd Prev multi filial", PesqPict( "SB2", "B2_QATU" ) , TamSX3("B2_QATU")[1])
	TRCell():New(oSecti1,"QTDENT"  		,"XXX"	,"Qtd. Entregue"		, PesqPict( "SB2", "B2_QATU" ) , TamSX3("B2_QATU")[1])
	TRCell():New(oSecti1,"DTPREV"  		,"XXX"	,"Previsao Entrega" 	, PesqPict("SC6","C6_ENTREG") , TamSX3("C6_ENTREG")[1])
	TRCell():New(oSecti1,"CLIENTE"  	,"XXX"	,"Cliente" 	  			, PesqPict("SC5","C5_CLIENTE") , TamSX3("C5_CLIENTE")[1])
	TRCell():New(oSecti1,"LOJA"  		,"XXX"	,"Loja"		   			, PesqPict("SA1","A1_LOJA") , TamSX3("A1_LOJA")[1])
	TRCell():New(oSecti1,"NOMCLI"  		,"XXX"	,"Nome Cliente"	  		, PesqPict("SA1","A1_NOME") , TamSX3("A1_NOME")[1])
	TRCell():New(oSecti1,"VALIPI"  		,"XXX"	,"Val. + IPI"  			, PesqPict( "SB2", "B2_QATU" ) , TamSX3("B2_QATU")[1])
	TRCell():New(oSecti1,"DTEMIS"  		,"XXX"	,"Data Emissao"  		, PesqPict("SC5","C5_EMISSAO") , TamSX3("C5_EMISSAO")[1])	
	TRCell():New(oSecti1,"NOTA"  		,"XXX"	,"Nota Fiscal"  		, PesqPict("SF1","F1_DOC") , TamSX3("F1_DOC")[1])		
	TRCell():New(oSecti1,"DTFAT"  		,"XXX"	,"Dt Faturamento"  		, PesqPict("SC5","C5_EMISSAO") , TamSX3("C5_EMISSAO")[1])	
	TRCell():New(oSecti1,"TRANSP"  		,"XXX"	,"Transportadora"  		, PesqPict("SC5","C5_TRANSP") , TamSX3("C5_TRANSP")[1])	
	TRCell():New(oSecti1,"VEND1"  		,"XXX"	,"Vend 1"  				, PesqPict("SC5","C5_VEND1") , TamSX3("C5_VEND1")[1])	
	TRCell():New(oSecti1,"VEND2"  		,"XXX"	,"Vend 2"  				, PesqPict("SC5","C5_VEND2") , TamSX3("C5_VEND2")[1])	
 	TRCell():New(oSecti1,"VEND3"  		,"XXX"	,"Vend 3"  				, PesqPict("SC5","C5_VEND3") , TamSX3("C5_VEND3")[1])	
	TRCell():New(oSecti1,"VEND4"  		,"XXX"	,"Vend 4"  				, PesqPict("SC5","C5_VEND4") , TamSX3("C5_VEND4")[1])	
	TRCell():New(oSecti1,"VEND5"  		,"XXX"	,"Vend 5"  				, PesqPict("SC5","C5_VEND5") , TamSX3("C5_VEND5")[1])	
	oSecti1:SetPageBreak(.T.)
	oSecti1:SetCellBorder("ALL",1,,.T.)
	
	oReport:SetMeter( Len(aDados) )
	oReport:SetMsgPrint("Gerando Planilha")
	
	oSecti1:SetHeaderSection(.T.)
	oSecti1:Init()
	
	For nI := 1 To Len(aDados) //Todas os registros
		
		oReport:IncMeter(1)
		
		oSecti1:Cell("NUMPED"):SetBlock(	{ || aDados[nI][POS_NUM_PEDIDO]	}	)
		oSecti1:Cell("TES")   :SetBlock(	{ || aDados[nI][POS_TES]		}	)
		oSecti1:Cell("ITEM")  :SetBlock(	{ || aDados[nI][POS_ITE_PEDIDO]	}	)
		oSecti1:Cell("PROD")  :SetBlock(	{ || aDados[nI][POS_PRODUTO]	}	)
		oSecti1:Cell("DESC")  :SetBlock(	{ || aDados[nI][POS_DESC_PROD]  }	)
		oSecti1:Cell("STATUS"):SetBlock(	{ || aDados[nI][POS_STATUS_PED] }	)
		oSecti1:Cell("QTDPED"):SetBlock(	{ || aDados[nI][POS_QTDEVEND]   }	)
		oSecti1:Cell("SLDENTREG"):SetBlock(	{ || aDados[nI][POS_SLD_ENTREG] }	)
//		oSecti1:Cell("SALDDISP") :SetBlock(	{ || aDados[nI][POS_SALDOFIL]   }	)
//		oSecti1:Cell("SALDMULT") :SetBlock(	{ || aDados[nI][POS_SALDO_DISP] }	)

		oSecti1:Cell("SALD0101"):SetBlock(	{ || aDados[nI][ POS_SLD0101] }	)
		oSecti1:Cell("SALD0102"):SetBlock(	{ || aDados[nI][ POS_SLD0102] }	)
		oSecti1:Cell("SALD0103"):SetBlock(	{ || aDados[nI][ POS_SLD0103] }	)

		oSecti1:Cell("QTDTRANS"):SetBlock(	{ || aDados[nI][ POS_PREV_TRANS ] } )
		oSecti1:Cell("QTDPREV") :SetBlock(	{ || aDados[nI][ POS_QTDE_PREVIS ] } )
//		oSecti1:Cell("QTDPRMF") :SetBlock(	{ || aDados[nI][ POS_QTD_PREVISF ] } )  
		oSecti1:Cell("QTDENT")  :SetBlock(	{ || aDados[nI][ POS_QTDEENTR ] }	)
		oSecti1:Cell("DTPREV")  :SetBlock(	{ || Dtoc(aDados[nI][ POS_PREV_ENTREG ]) }	)
		
		oSecti1:Cell("CLIENTE"):SetBlock(	{ || aDados[nI][POS_COD_CLIENTE] }	)
		oSecti1:Cell("LOJA"):SetBlock(		{ || aDados[nI][POS_LOJ_CLIENTE] }	)
		oSecti1:Cell("NOMCLI"):SetBlock(	{ || aDados[nI][POS_NOM_CLIENTE] }	)
		
		oSecti1:Cell("VALIPI"):SetBlock(	{ || aDados[nI][POS_VALOR] }	)
		oSecti1:Cell("DTEMIS"):SetBlock(	{ || Dtoc(aDados[nI][POS_EMISSAO]) }	)
		oSecti1:Cell("NOTA"):SetBlock(		{ || aDados[nI][POS_NOTAFISCAL] }	)
		oSecti1:Cell("DTFAT"):SetBlock(		{ || Dtoc(aDados[nI][POS_DATAFATURA]) }	)
		oSecti1:Cell("TRANSP"):SetBlock(	{ || aDados[nI][POS_TRANSPORTA] }	)
		
		oSecti1:Cell("VEND1"):SetBlock(		{ || aDados[nI][POS_VEND1]}	)
		oSecti1:Cell("VEND2"):SetBlock(		{ || aDados[nI][POS_VEND2]}	)
		oSecti1:Cell("VEND3"):SetBlock(		{ || aDados[nI][POS_VEND3]}	)
		oSecti1:Cell("VEND4"):SetBlock(		{ || aDados[nI][POS_VEND4]}	)
		oSecti1:Cell("VEND5"):SetBlock(		{ || aDados[nI][POS_VEND5]}	)
	
		oSecti1:SetCellBorder( "ALL",1 )
		oSecti1:Printline()
			
	Next nI
			
	oSecti1:Finish()
	oReport:EndPage()
	oReport:IncMeter(1)

Return
