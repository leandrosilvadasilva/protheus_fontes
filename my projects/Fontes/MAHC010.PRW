#INCLUDE "Totvs.ch"
                        
//Posicoes do Array dos Dados
#Define POS_NUM_PEDIDO		01
#Define POS_ITE_PEDIDO		02
#Define POS_PRODUTO		    03
#Define POS_DESC_PROD		04
#Define POS_SALDO_DISP		05
#Define POS_QTDE_PREVIS	    06
#Define POS_PREV_ENTREG	    07
#Define POS_COD_CLIENTE	    08
#Define POS_LOJ_CLIENTE	    09
#Define POS_NOM_CLIENTE	    10
#Define POS_VALOR			11
#Define POS_EMISSAO		    12
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
#Define POS_SLD01   		27
#Define POS_SLD02   		28
#Define POS_SLD03   		29

#Define POS_SLD_ENTREG 		30
#Define POS_PREV_TRANS 		31
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³MAHC010   ³ Autor ³ Joao Mattos           ³ Data ³07/06/2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Tela de Consulta Status Pedido de Venda                    ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ U_MAHC010()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico MA Hospitalar                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                          ULTIMAS ALTERACOES                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function MAHC010()

	Local aArea     := GetArea()
	Local oDlg      := Nil
	Local aObjects  := {}
	Local aPosObj   := {}
	Local aSizeAut  := MsAdvSize()
	Local aButtons  := {}
	Local nScan     := 0
	Local nn        := 0
	
	Private o1        := LoadBitmap(GetResources(),"BR_VERDE")
	Private o2        := LoadBitmap(GetResources(),"BR_VERMELHO")
	Private o3        := LoadBitmap(GetResources(),"BR_AZUL")
	Private o4        := LoadBitmap(GetResources(),"BR_PINK")
	Private o5        := LoadBitmap(GetResources(),"BR_PRETO")
	Private o6        := LoadBitmap(GetResources(),"BR_AMARELO")
	Private o7        := LoadBitmap(GetResources(),"BR_BRANCO")
	Private o8        := LoadBitmap(GetResources(),"BR_CINZA")
	Private o9        := LoadBitmap(GetResources(),"BR_MARROM")
	Private aLegenda  := {	{ "Incluido", o1 },;
							{ "Faturado", o2 },;
							{ "Bloqueado Credito", o3 },;
							{ "Estoque Pendente", o4 },;
							{ "Representada", o5 },;
							{ "Bloqueado Estoque", o6 },;
							{ "Aguardando Faturamento", o7 },;
							{ "Faturamento Parcial", o8 },;
							{ "Reservado Aguardando outro Item", o9 } }         
	
							
							
	Private _oListBox := Nil
	Private _aListBox := {}
	Private aPerg     := {}
	Private cPerg     := PadR("MAHC010",Len(SX1->X1_GRUPO))
	Private cCadastro := "Tela de Consulta do Status do Pedido de Venda"

	//                           1        2                          	         3       	4      5                   		6       7       8    9     10    11    12    13    14     15
	//.. Perguntas-- Grupo    Ordem    Perguntas                 	 		 Variavel  		Tipo    Tam  	          	 	Dec    Variavel  GSC   F3   Def01 Def02 Def03 Def04 Def05  Valid
	aAdd( 		aPerg , { 		"01", "Do Pedido?"              				, "mv_ch1", "C",  TamSx3("C5_NUM")[1]		, 0 ,"MV_PAR01","G" ,"SC5", "  ","  "," ","   ","    "  ,  ""      } )
	aAdd( 		aPerg , { 		"02", "Até Pedido?"              				, "mv_ch2", "C",  TamSx3("C5_NUM")[1]		, 0 ,"MV_PAR02","G" ,"SC5", "  ","  "," ","   ","    "  ,  ""      } )
	aAdd( 		aPerg , { 		"03", "Data Emissão De?"        	   			, "mv_ch3", "D",  08						, 0 ,"MV_PAR03","G" ,"   ", "  ","  "," ","   ","    "  ,  ""      } )
	aAdd( 		aPerg , { 		"04", "Data Emissão Até?"    	      			, "mv_ch4", "D",  08					 	, 0 ,"MV_PAR04","G" ,"   ", "  ","  "," ","   ","    "  ,  ""      } )
	aAdd( 		aPerg , { 		"05", "Do Cliente?"              				, "mv_ch5", "C",  TamSx3("A1_COD")[1]		, 0 ,"MV_PAR05","G" ,"SA1", "  ","  "," ","   ","    "  ,  ""      } )
	aAdd( 		aPerg , { 		"06", "Até Cliente?"              				, "mv_ch6", "C",  TamSx3("A1_COD")[1]		, 0 ,"MV_PAR06","G" ,"SA1", "  ","  "," ","   ","    "  ,  ""      } )
	aAdd( 		aPerg , { 		"07", "Da Loja?"	              				, "mv_ch7", "C",  TamSx3("A1_LOJA")[1]		, 0 ,"MV_PAR07","G" ,"   ", "  ","  "," ","   ","    "  ,  ""      } )
	aAdd( 		aPerg , { 		"08", "Até Loja?"	              				, "mv_ch8", "C",  TamSx3("A1_LOJA")[1]		, 0 ,"MV_PAR08","G" ,"   ", "  ","  "," ","   ","    "  ,  ""      } )
	aAdd( 		aPerg , { 		"09", "Do Vendedor?"              				, "mv_ch9", "C",  TamSx3("A3_COD")[1]		, 0 ,"MV_PAR09","G" ,"SA3", "  ","  "," ","   ","    "  ,  ""      } )
	aAdd( 		aPerg , { 		"10", "Até Vendedor?"              		    	, "mv_cha", "C",  TamSx3("A3_COD")[1]		, 0 ,"MV_PAR10","G" ,"SA3", "  ","  "," ","   ","    "  ,  ""      } )
	aAdd( 		aPerg , { 		"11", "Status Ped. Incluido?"					, "mv_chb", "N",  01 						, 0 ,"MV_PAR11","C" ,"   ", "Sim","Não"," ","   ","    "  ,  ""      } )
	aAdd( 		aPerg , { 		"12", "Status Ped. Bloqueado Crédito?"			, "mv_chc", "N",  01 						, 0 ,"MV_PAR12","C" ,"   ", "Sim","Não"," ","   ","    "  ,  ""      } )
	aAdd( 		aPerg , { 		"13", "Status Ped. Bloqueado Estoque?"			, "mv_chd", "N",  01 						, 0 ,"MV_PAR13","C" ,"   ", "Sim","Não"," ","   ","    "  ,  ""      } )
	aAdd( 		aPerg , { 		"14", "Status P. Aguardando Faturam.?"			, "mv_che", "N",  01 						, 0 ,"MV_PAR14","C" ,"   ", "Sim","Não"," ","   ","    "  ,  ""      } )
	aAdd( 		aPerg , { 		"15", "Status Ped. Faturado?"					, "mv_chf", "N",  01 						, 0 ,"MV_PAR15","C" ,"   ", "Sim","Não"," ","   ","    "  ,  ""      } )
	aAdd( 		aPerg , { 		"16", "Status Ped. Estoque Pendente?"			, "mv_chg", "N",  01 						, 0 ,"MV_PAR16","C" ,"   ", "Sim","Não"," ","   ","    "  ,  ""      } )
	aAdd( 		aPerg , { 		"17", "Status Ped. Representada?"		     	, "mv_chh", "N",  01 						, 0 ,"MV_PAR17","C" ,"   ", "Sim","Não"," ","   ","    "  ,  ""      } )
	aAdd( 		aPerg , { 		"18", "Status Ped. Faturado Parcialmente"    	, "mv_chi", "N",  01 						, 0 ,"MV_PAR18","C" ,"   ", "Sim","Não"," ","   ","    "  ,  ""      } )
	aAdd( 		aPerg , { 		"19", "Previsao Entrega De?"      				, "mv_chj", "D",  08 						, 0 ,"MV_PAR19","G" ,"   ", "  ","  "," ","   ","    "  ,  ""      } )
	aAdd( 		aPerg , { 		"20", "Previsao Entrega Até?"     				, "mv_chk", "D",  08 						, 0 ,"MV_PAR20","G" ,"   ", "  ","  "," ","   ","    "  ,  ""      } )
	aAdd( 		aPerg , { 		"21", "Do Produto?"              				, "mv_chl", "C",  TamSx3("B1_COD")[1]		, 0 ,"MV_PAR21","G" ,"SB1", "  ","  "," ","   ","    "  ,  ""      } )
	aAdd( 		aPerg , { 		"22", "Até Produto?"              				, "mv_chm", "C",  TamSx3("B1_COD")[1]		, 0 ,"MV_PAR22","G" ,"SB1", "  ","  "," ","   ","    "  ,  ""      } )
	aAdd( 		aPerg , { 		"23", "Quais TES a Considerar?"   				, "mv_chn", "C",  99						, 0 ,"MV_PAR23","G" ,"SF4", "  ","  "," ","   ","    "  ,  ""      } )
	aAdd( 		aPerg , { 		"24", "Do Tipo de Produto?"       				, "mv_cho", "C",  TamSx3("B1_TIPO")[1]		, 0 ,"MV_PAR24","G" ,"02 ", "  ","  "," ","   ","    "  ,  ""      } )
	aAdd( 		aPerg , { 		"25", "Até Tipo de Produto?"      				, "mv_chp", "C",  TamSx3("B1_TIPO")[1]		, 0 ,"MV_PAR25","G" ,"02 ", "  ","  "," ","   ","    "  ,  ""      } )
	aAdd( 		aPerg , { 		"26", "Do Grupo de Produto?"      				, "mv_chq", "C",  TamSx3("B1_GRUPO")[1]	    , 0 ,"MV_PAR26","G" ,"SBM", "  ","  "," ","   ","    "  ,  ""      } )
	aAdd( 		aPerg , { 		"27", "Até Grupo de Produto?"     				, "mv_chr", "C",  TamSx3("B1_GRUPO")[1]	    , 0 ,"MV_PAR27","G" ,"SBM", "  ","  "," ","   ","    "  ,  ""      } )
	aAdd( 		aPerg , { 		"28", "TES que Gera Duplicatas?"				, "mv_chs", "N",  1							, 0 ,"MV_PAR28","C" ,"   ", "Sim","Não","Ambos","   ","    "  ,  ""      } )
	aAdd( 		aPerg , { 		"29", "Ordenar por?"							, "mv_cht", "N",  1						    , 0 ,"MV_PAR29","C" ,"   ", "Pedido/Item","Produto","Data Emissão","Cliente/Loja/Pedido/Item","Previsão de Entrega"  ,  ""      } )
	aAdd( 		aPerg , { 		"30", "Status Ped. Reser. Aguardando outro Item", "mv_chu", "N",  01 						, 0 ,"MV_PAR30","C" ,"   ", "Sim","Não"," ","   ","    "  ,  ""      } )
	aAdd( 		aPerg , { 		"31", "Armazem (01;02...)"        				, "mv_chv", "C",  30                     	, 0 ,"MV_PAR31","G" ,"   ", "  ","  "," ","   ","    "  ,  ""      } )
	aAdd( 		aPerg , { 		"32", "Natureza (81101;11101...)"       		, "mv_chx", "C",  30                     	, 0 ,"MV_PAR32","G" ,"   ", "  ","  "," ","   ","    "  ,  ""      } )
	
	
	DbSelectArea("SX1")
	DbSetOrder(1)
	For nn := 1 to Len( aPerg )
		If !DbSeek(cPerg + aPerg[nn,1] )
			RecLock("SX1",.T.)
				Replace ;
				X1_GRUPO   With cPerg       , X1_ORDEM   With aPerg[nn,01],;
				X1_PERGUNT With aPerg[nn,02], X1_VARIAVL With aPerg[nn,03],;
				X1_TIPO    With aPerg[nn,04], X1_TAMANHO With aPerg[nn,05],;
				X1_DECIMAL With aPerg[nn,06], X1_VAR01   With aPerg[nn,07],;
				X1_GSC     With aPerg[nn,08], X1_F3      With aPerg[nn,09],;
				X1_Def01   With aPerg[nn,10], X1_Def02   With aPerg[nn,11],;
				X1_Def03   With aPerg[nn,12], X1_Def04   With aPerg[nn,13],;
				X1_Def05   With aPerg[nn,14], X1_Valid   With aPerg[nn,15]
			MsUnlock()                       
		End
	Next

	If Pergunte(cPerg,.T.)
	
	  	Processa({|| _aListBox := BuscaInfo(cPerg) },"Pesquisando Pedidos de Vendas...")
		
		If Len(_aListBox) > 0
		
			aAdd( aButtons, { 'EDITABLE', { || C010VIS(_aListBox, _oListBox:nAt)		},	'Visualiza'		} )
			aAdd( aButtons, { 'EDITABLE', { || Atualiza(cPerg, _oListBox, _aListBox)	},	'Atualiza'		} )
			aAdd( aButtons, { 'EDITABLE', { || AltStatus(_aListBox, _oListBox:nAt)		},	'Altera Status'	} )
			aAdd( aButtons, { 'EDITABLE', { || U_MAHR020(_aListBox)						},	'Imprime'		} )   
			aAdd( aButtons, { 'EDITABLE', { || U_MAHR030(_aListBox)						},	'Exp. Planilha'	} )
			aAdd( aButtons, { 'EDITABLE', { || U_MAHC020(_aListBox[_oListBox:nAt][POS_NUM_PEDIDO]+_aListBox[_oListBox:nAt][POS_ITE_PEDIDO])			},	'Saldo Multi Filiais'		} )
			aAdd( aButtons, { 'EDITABLE', { || C010LEG()								},	'Legenda'		} )
			AAdd( aObjects, { 100, 100, .T., .T.,.T. } )
			aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
			aPosObj := MsObjSize( aInfo, aObjects, .T. )
			
			DEFINE MSDIALOG oDlg TITLE cCadastro From aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL
		
				@ aPosObj[1,1],aPosObj[1,2] ListBox _oListBox ;
											Fields Header ;
															' ',;
															'Pedido',;
															'TES',;
															'Item',;
															'Produto',;
															'Descrição',;
															'Status',;
															'Qtd Vendida',;
															'Qtd a Entregar',;
															'Saldo 0101',;
															'Saldo 0102',;
															'Saldo 0103',;
															'Qtd Prev. Transf',;
															'Qtd Prev. Compra',;
															'Qtd Entregue',;
															'Previsao Entrega',;
															'Cliente',;
															'Loja',;
															'Nome Cliente',;
															'Valor do Pedido + IPI',;
															'Data Emissao',;
															'Nota Fiscal',;
															'Data Faturamento',;
															'Transportadora',;
															'Vend 1',;
															'Vend 2',;
															'Vend 3',;
															'Vend 4',;
															'Vend 5' ;
															Size aPosObj[1,3],aPosObj[1,4] Pixel Of oDlg

//															'Saldo Disponível',;
//															'Saldo Multi Filial',;
//															'Qtd Prev. Multi Filial',;

				_oListBox:SetArray( _aListBox )
	
				_oListBox:bLine := { || {	IIf(nScan := AsCan( aLegenda, { |X| X[1] == _aListBox[ _oListBox:nAt, POS_STATUS_PED ] }) > 0, aLegenda[AsCan( aLegenda, { |X| X[1] == _aListBox[ _oListBox:nAt, POS_STATUS_PED ] })][2],o7),; // Legenda
												_aListBox[ _oListBox:nAt, POS_NUM_PEDIDO ],; 			// Numero do Pedido de Venda
												_aListBox[ _oListBox:nAt, POS_TES ],;			        // TES do pedido de venda
												_aListBox[ _oListBox:nAt, POS_ITE_PEDIDO ],;			// item do pedido de venda
												_aListBox[ _oListBox:nAt, POS_PRODUTO ],;				// produto
												_aListBox[ _oListBox:nAt, POS_DESC_PROD ],;			    // descricao do produto
												_aListBox[ _oListBox:nAt, POS_STATUS_PED ],;			// situacao do pedido
												Transform(_aListBox[ _oListBox:nAt, POS_QTDEVEND ],    PesqPict( "SB2", "B2_QATU" )),; // quantidade vendida
												Transform(_aListBox[ _oListBox:nAt, POS_SLD_ENTREG ],  PesqPict( "SB2", "B2_QATU" )),; // saldo a entregar
												Transform(_aListBox[ _oListBox:nAt, POS_SLD01 ],       PesqPict( "SB2", "B2_QATU" )),; // saldo filial 0101
												Transform(_aListBox[ _oListBox:nAt, POS_SLD02 ],       PesqPict( "SB2", "B2_QATU" )),; // saldo filial 0102
												Transform(_aListBox[ _oListBox:nAt, POS_SLD03 ],       PesqPict( "SB2", "B2_QATU" )),; // saldo filial 0103
												Transform(_aListBox[ _oListBox:nAt, POS_PREV_TRANS ],  PesqPict( "SB2", "B2_QATU" )),; // quantidade transf.Pre-Nota
												Transform(_aListBox[ _oListBox:nAt, POS_QTDE_PREVIS ], PesqPict( "SB2", "B2_QATU" )),; // quantidade prevista de compra
												Transform(_aListBox[ _oListBox:nAt, POS_QTDEENTR ],    PesqPict( "SB2", "B2_QATU" )),; // quantidade entregue
												Dtoc(_aListBox[ _oListBox:nAt, POS_PREV_ENTREG ]),;	    // data prevista de entrega
												_aListBox[ _oListBox:nAt, POS_COD_CLIENTE ],;			// codigo do cliente
												_aListBox[ _oListBox:nAt, POS_LOJ_CLIENTE ],;			// loja do cliente
												_aListBox[ _oListBox:nAt, POS_NOM_CLIENTE ],;			// nome do cliente
												Transform(_aListBox[ _oListBox:nAt, POS_VALOR ], PesqPict( "SC6", "C6_VALOR" )),; // valor do pedido + ipi
												Dtoc(_aListBox[ _oListBox:nAt, POS_EMISSAO ]),;		    // data de emissao
												_aListBox[ _oListBox:nAt, POS_NOTAFISCAL ],;			// nota fiscal
												Dtoc(_aListBox[ _oListBox:nAt, POS_DATAFATURA ]),;	    // data do faturamento
												_aListBox[ _oListBox:nAt, POS_TRANSPORTA ],;			// nome da transportadora
												_aListBox[ _oListBox:nAt, POS_VEND1 ],;				    // vend 1
												_aListBox[ _oListBox:nAt, POS_VEND2 ],;				    // vend 2
												_aListBox[ _oListBox:nAt, POS_VEND3 ],;				    // vend 3
												_aListBox[ _oListBox:nAt, POS_VEND4 ],;				    // vend 4
												_aListBox[ _oListBox:nAt, POS_VEND5 ] }}				// vend 5

//												Transform(_aListBox[ _oListBox:nAt, POS_SALDOFIL ],    PesqPict( "SB2", "B2_QATU" )),; // saldo filial
//												Transform(_aListBox[ _oListBox:nAt, POS_SALDO_DISP ],  PesqPict( "SB2", "B2_QATU" )),; // saldo Multi Filial
//												Transform(_aListBox[ _oListBox:nAt, POS_QTD_PREVISF ], PesqPict( "SB2", "B2_QATU" )),; // quantidade prevista de compra multi filial

			_oListBox:BLDBLCLICK :={|| C010VIS(_aListBox, _oListBox:nAt) }
		
			ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()},,aButtons)
		Else
		
			MsgAlert("Nenhum Pedido de Venda encontrado!","Atenção!")  
		EndIf
	EndIf
	
	RestArea( aArea )

Return ( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³BuscaInfo ³ Autor ³ Joao Mattos           ³ Data ³08.06.2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Busca Informacoes                                          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ BuscaInfo()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpA01-Array com dados                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico MA Hospitalar                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                          ULTIMAS ALTERACOES                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function BuscaInfo( cPerg )

	Local aArea       := GetArea()
	Local aAreaSB2    := SB2->(GetArea())
	Local aReturn     := {}
	Local cQuery      := ""
	Local cPedidoDe   := ""
	Local cPedidoAte  := ""
	Local dDtEmisDe   := Ctod('')
	Local dDtEmisAte  := Ctod('')
	Local cCliDe      := ""
	Local cLojDe      := ""
	Local cCliAte     := ""
	Local cLojAte     := ""
	Local nRegistros  := 0
	Local cVendDe     := ""
	Local cVendAte    := ""
	Local dDtEntDe    := ""
	Local dDtEntAte   := ""
	Local cProdDe     := ""
	Local cProdAte    := ""
	Local cSitPedido  := ""
	Local nX          := ""
	Local nVlPedMIPI  := 0
	Local nStatus     := 0
	Local lSeleciona  := .f.	// indica se ira selecionar
	Local cNomTransp  := ""	// nome da transportadora
	Local nVlrIpi     := 0
	Local lPedInclui  := .f. // considera pedidos incluidos
	Local lPedBlqCre  := .f. // considera pedidos bloqueado credito
	Local lPedBlqEst  := .f. // considera pedidos bloqueado estoque
	Local lPedAguFat  := .f. // considera pedidos aguardando faturamento
	Local lPedFatura  := .f. // considera pedidos faturados
	Local lPedEstPen  := .f. // considera pedidos com estoque pendente
	Local lPedEstRep  := .f. // considera pedidos com estoque representado  
	Local lPedFatPar  := .f. // considera pedidos faturados parcialmente
	Local lPedReser   := .f. // considera pedidos reservados
	Local nSaldo      := 0 // saldo disponivel
	Local aSaldo      := {}
	Local nSaldo01    := 0 // saldo filial 01
	Local nSaldo02    := 0 // saldo filial 02
	Local nSaldo03    := 0 // saldo filial 03
	Local nSaldoTrans := 0 // saldo qtde. Transf. Pre-Nota
	Local nQtdePrev   := 0 // quantidade prevista
	Local nQtdPrevF   := 0 // quantidade prevista multi filial
	Local aProdutos   := {} // array dos produtos para montagem de saldos disponiveis e quantidade prevista
	Local nScan       := 0
	Local aDadosPV    := {}
	Local aSitPedVen  := {}
	Local nSaldoFil   := 0
	Local cTESaConsi  := ""
	Local cTipProDe   := ""
	Local cTipProAte  := ""
	Local cGruProDe   := ""
	Local cGruProAte  := ""
	Local cArmazem    := ""
	Local cInTES      := ""
    Local cNatPed     := ""
	Local nGeraDup    := 0
	Local nOrdemCons  := 1

	Private cVend1 := ""
	Private cVend2 := ""
	Private cVend3 := ""
	Private cVend4 := ""
	Private cVend5 := ""
	
	SA3->( DbSetOrder(1) ) // A3_FILIAL + A3_COD
	SA4->( DbSetOrder(1) ) // A4_FILIAL + A4_COD
	
	Pergunte(cPerg,.f.) 
	cPedidoDe  := MV_PAR01
	cPedidoAte := MV_PAR02
	dDtEmisDe  := MV_PAR03
	dDtEmisAte := MV_PAR04
	cCliDe     := MV_PAR05
	cCliAte    := MV_PAR06
	cLojDe     := MV_PAR07
	cLojAte    := MV_PAR08
	cVendDe    := MV_PAR09
	cVendAte   := MV_PAR10
	lPedInclui := MV_PAR11 == 1 // considera pedidos incluidos
	lPedBlqCre := MV_PAR12 == 1 // considera pedidos bloqueado credito
	lPedBlqEst := MV_PAR13 == 1 // considera pedidos bloqueado estoque
	lPedAguFat := MV_PAR14 == 1 // considera pedidos aguardando faturamento
	lPedFatura := MV_PAR15 == 1 // considera pedidos faturados
	lPedEstPen := MV_PAR16 == 1 // considera pedidos com estoque pendente
	lPedEstRep := MV_PAR17 == 1 // considera pedidos com estoque representado
	lPedFatPar := MV_PAR18 == 1 // considera pedidos faturados parcialmente
	dDtEntDe   := MV_PAR19
	dDtEntAte  := MV_PAR20
	cProdDe    := MV_PAR21
	cProdAte   := MV_PAR22
	cTESaConsi := AllTrim(MV_PAR23)
	cTipProDe  := MV_PAR24
	cTipProAte := MV_PAR25
	cGruProDe  := MV_PAR26
	cGruProAte := MV_PAR27
	nGeraDup   := MV_PAR28 // 1=Sim 2=Nao 3=Ambos
	nOrdemCons := MV_PAR29 // 1=Pedido/Item 2=Produto 3=Data de Emissao 4=Cliente/Loja/Pedido/Item 5=Previsao Entrega
	lPedReser  := MV_PAR30 == 1 // considera pedidos Reservado
	cArmazem   := MV_PAR31
    cNatPed    := MV_PAR32
	
	SB2->( DbSetOrder(1) ) // B2_FILIAL + B2_COD + B2_LOCAL

	ProcRegua(0)
	IncProc()

	cQuery := " SELECT SC5.R_E_C_N_O_ C5_RECNO, C5_NUM,   C6_NUM,  C6_ITEM, C5_EMISSAO, C5_CLIENTE, C5_LOJACLI, C5_VEND1,  C5_VEND2,  C5_VEND3, " 
	cQuery += "        C5_VEND4, C5_VEND5, C5_NATUREZ,   B1_DESC,  C6_ENTREG, C6_VALOR,    B1_IPI, C6_PEDCLI, C5_TRANSP, C5_LIBEROK,   A1_NOME, "
	cQuery += "        C5_BLQ, C6_PRODUTO,  C9_QTDLIB,  C9_BLWMS,  C9_BLCRED, C9_BLEST, C9_PEDIDO,   C9_ITEM,   C6_NOTA, C6_VALDESC, C6_DATFAT, "
	cQuery += "        C6_TES,  C6_PRCVEN,  C6_QTDVEN, C6_QTDENT, C6_STPESTQ, C6_LOCAL,  B1_GRUPO,   B1_TIPO, F4_DUPLIC, C5_ZTPLIBE, C5_FILIAL "
	cQuery += " FROM "            + RetSqlName("SC5") + " SC5 "
	cQuery += " INNER JOIN "      + RetSqlName("SC6") + " SC6 ON C6_FILIAL = '" + xFilial("SC6") + "' AND C6_NUM = C5_NUM "
	cQuery += " LEFT OUTER JOIN " + RetSqlName("SC9") + " SC9 ON C9_FILIAL = '" + xFilial("SC9") + "' AND C9_PEDIDO = C6_NUM AND C9_ITEM = C6_ITEM AND SC9.D_E_L_E_T_ = ' '"
	cQuery += " INNER JOIN "      + RetSqlName("SA1") + " SA1 ON A1_FILIAL = '" + xFilial("SA1") + "' AND A1_COD = C5_CLIENTE AND A1_LOJA = C5_LOJACLI "
	cQuery += " INNER JOIN "      + RetSqlName("SB1") + " SB1 ON B1_FILIAL = '" + xFilial("SB1") + "' AND B1_COD = C6_PRODUTO "
	cQuery += " INNER JOIN "      + RetSqlName("SF4") + " SF4 ON F4_FILIAL = '" + xFilial("SF4") + "' AND F4_CODIGO = C6_TES "
	cQuery += " WHERE C5_FILIAL = '" + xFilial("SC5") + "'"
	cQuery += "   AND C5_NUM     BETWEEN ('" + cPedidoDe + "')       AND ('" + cPedidoAte + "') "
	cQuery += "   AND C5_EMISSAO BETWEEN ('" + Dtos(dDtEmisDe) + "') AND ('" + Dtos(dDtEmisAte) + "') "
	cQuery += "   AND C5_CLIENTE BETWEEN ('" + cCliDe + "')          AND ('" + cCliAte + "') "
	cQuery += "   AND C5_LOJACLI BETWEEN ('" + cLojDe + "')          AND ('" + cLojAte + "') "
	cQuery += "   AND C5_VEND1   BETWEEN ('" + cVendDe + "')         AND ('" + cVendAte + "') "
	cQuery += "   AND C6_ENTREG  BETWEEN ('" + DToS(dDtEntDe) + "')  AND ('" + DToS(dDtEntAte) + "') "
	cQuery += "   AND C6_PRODUTO BETWEEN ('" + cProdDe + "')         AND ('" + cProdAte + "') "

	If !Empty(cTESaConsi)
		cQuery += "   AND C6_TES IN " + FormatIn(cTESaConsi,";") // FILTRA TES
	EndIf
	
	If !Empty(AllTrim(cArmazem))
		cQuery += "   AND C6_LOCAL IN " + FormatIn(AllTrim(cArmazem),";") // FILTRA Armazem
	EndIf
	
	
	If !Empty(AllTrim(cNatPed))
		cQuery += "   AND C5_NATUREZ IN " + FormatIn(AllTrim(cNatPed),";") // FILTRA Natureza
	EndIf

	cQuery += "   AND C6_BLQ <> 'R' " // FITRA OS PEDIDOS ELIMINADOS POR RESEIDUO
	cQuery += "   AND B1_TIPO BETWEEN ('" + cTipProDe + "') AND ('" + cTipProAte + "') " // FILTRA TIPO DE PRODUTO
	cQuery += "   AND B1_GRUPO BETWEEN ('" + cGruProDe + "') AND ('" + cGruProAte + "') " // FILTRA GRUPO DE PRODUTO

	If nGeraDup == 1

		cQuery += "   AND F4_DUPLIC = 'S' " // FITRA TES QUE GERA DUPLICATA
	ElseIf nGeraDup == 2

		cQuery += "   AND F4_DUPLIC = 'N' " // FITRA TES QUE NAO GERA DUPLICATA
	EndIf

	cQuery += "   AND SC5.D_E_L_E_T_ = ' ' "
	cQuery += "   AND SC6.D_E_L_E_T_ = ' ' "
	cQuery += "   AND SA1.D_E_L_E_T_ = ' ' "
	cQuery += "   AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += "   AND SF4.D_E_L_E_T_ = ' ' "

	If nOrdemCons == 1 // Pedido / Item
	
		cQuery += "   ORDER BY C6_NUM, C6_ITEM "
	ElseIf nOrdemCons == 2 // Produto

		cQuery += "   ORDER BY C6_PRODUTO, C6_NUM, C6_ITEM "
	ElseIf nOrdemCons == 3 // Data de Emissao

		cQuery += "   ORDER BY C5_EMISSAO, C6_NUM, C6_ITEM "
	ElseIf nOrdemCons == 4 // Cliente / Loja / Pedido / Item

		cQuery += "   ORDER BY C5_CLIENTE, C5_LOJACLI, C6_NUM, C6_ITEM "
	ElseIf nOrdemCons == 5 // Previsao de Entrega

		cQuery += "   ORDER BY C6_ENTREG, C6_NUM, C6_ITEM "
	EndIf

	cQuery := ChangeQuery(cQuery)                           

  	MEMOWRITE ("\MAHC010.SQL", cQuery)

	dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQuery), "PEDIDOS", .F., .T.) // executa query
	TcSetField( "PEDIDOS", "C5_EMISSAO" , "D", 8, 0 )
	TcSetField( "PEDIDOS", "C6_DATFAT" , "D", 8, 0 )  
	TcSetField( "PEDIDOS", "C6_ENTREG" , "D", 8, 0 )  
	
	Count to nRegistros  
	ProcRegua(nRegistros)
	DbGoTop()                                
	While !Eof()
	
		IncProc()
		
		aDadosPV := { PEDIDOS->C5_LIBEROK,;
						PEDIDOS->C6_NOTA,;
						PEDIDOS->C9_BLCRED,;
						PEDIDOS->C9_BLEST,;
						PEDIDOS->C6_STPESTQ,;
						PEDIDOS->C9_BLWMS,;
						PEDIDOS->C6_QTDVEN,;
						PEDIDOS->C6_QTDENT,;
						PEDIDOS->C5_ZTPLIBE,;
						PEDIDOS->C5_NUM,;
						PEDIDOS->C5_FILIAL;		
					}
		
		aSitPedVen := U_C010StPV( Nil, Nil, Nil, Nil, aDadosPV ) // funcao para verificar o status do pedido de venda
		cSitPedido := aSitPedVen[1] 
		nStatus    := aSitPedVen[2]

		lSeleciona	:= .f.
		lSeleciona	:= lPedInclui .and. nStatus == 1 // considera pedidos incluidos? s/n	-- status 1
	
		If !lSeleciona
	
			lSeleciona	:= lPedFatura .and. nStatus == 2 // considera pedidos faturados? s/n	-- status 2
		EndIf
	
		If !lSeleciona
	
			lSeleciona	:= lPedBlqCre .and. nStatus == 3 // considera pedidos com bloqueio credito? s/n	-- status 3
		EndIf
	
		If !lSeleciona
		
			lSeleciona	:= lPedEstPen .and. nStatus == 4 // considera pedidos com estoque pendente? s/n	-- status 4
		EndIf
		
		If !lSeleciona
		
			lSeleciona	:= lPedEstRep .and. nStatus == 5 // considera pedidos com estoque representado? s/n	-- status 5
		EndIf

		If !lSeleciona
		
			lSeleciona	:= lPedBlqEst .and. nStatus == 6 // considera pedidos com estoque bloqueado? s/n -- status 6
		EndIf
		
		If !lSeleciona
		
			lSeleciona	:= lPedAguFat .and. nStatus == 7 // considera pedidos aguardando faturamento? s/n	-- status 7
		EndIf
	
		If !lSeleciona
		
			lSeleciona	:= lPedFatPar .and. nStatus == 8 // considera pedidos faturamento parcial? s/n	-- status 8
		EndIf
	
		
		If !lSeleciona
		
			lSeleciona	:= lPedReser .and. nStatus == 9 // considera pedidos Reservados? s/n	-- status 9
		EndIf
		
		
		If lSeleciona
	
			// Transportadora
			cNomTransp	:= ""
			If SA4->( DbSeek(xFilial("SA4") + PadR(PEDIDOS->C5_NUM, TamSx3("A4_COD")[1]) ))
			
				cNomTransp	:= AllTrim(SA4->A4_NOME)
			EndIf
	
			// Vendedores
			For nX := 1 to 5
		
				&("cVend" + Str(nX,1)) := ""
		
				If !Empty(&("PEDIDOS->C5_VEND" + Str(nX,1)))
				
					SA3->( DbSeek(xFilial("SA3") + PadR( &("PEDIDOS->C5_VEND" + Str(nX,1) ), TamSx3("A3_COD")[1] ) ))
					&("cVend" + Str(nX,1)) := SA3->A3_NOME
				EndIf
			Next nX
	                                              
		   	//nVlrIpi    := CalcIPI (PEDIDOS->C5_CLIENTE,  PEDIDOS->C5_LOJACLI,  PEDIDOS->C6_PRODUTO, PEDIDOS->C6_TES, PEDIDOS->C6_QTDVEN, PEDIDOS->C6_PRCVEN , PEDIDOS->C6_VALOR)  
	  		nVlrIpi:=0
	  		nVlPedMIPI := PEDIDOS->C6_VALOR  + nVlrIpi
	  		
	  		If (nScan := AsCan( aProdutos, { |X| X[1] == PEDIDOS->C6_PRODUTO })) == 0
	  		
//		  		nSaldo     := C20GetSld( PEDIDOS->C6_PRODUTO )
		  		aSaldo     := C20GetSld( PEDIDOS->C6_PRODUTO )
				nSaldo01   := aSaldo[1,1]
				nSaldo02   := aSaldo[1,2]
				nSaldo03   := aSaldo[1,3]

				nQtdePrev  := U_MAHC021 ( PEDIDOS->C6_PRODUTO )         // alterado para trazer somente pedidos de compra 
				nQtdPrevF  := U_MAHC021a( PEDIDOS->C6_PRODUTO )
				nSaldoTrans:= U_MAHC021b( PEDIDOS->C6_PRODUTO )         // obtem saldo somente de Pre-Notas da filial logada

				nSaldoFil  := 0

				If SB2->( DbSeek( xFilial("SB2") + PEDIDOS->C6_PRODUTO + PEDIDOS->C6_LOCAL ))

					nSaldoFil := SaldoSb2()
				EndIf
				
				aAdd ( aProdutos, { PEDIDOS->C6_PRODUTO, nSaldo, nQtdePrev, nSaldoFil, nQtdPrevF,   nSaldo01, nSaldo02, nSaldo03, nSaldoTrans  } )

			Else
			
//		  		nSaldo     := aProdutos[nScan][2]

				nSaldo01   := aProdutos[nScan][6]
				nSaldo02   := aProdutos[nScan][7]
				nSaldo03   := aProdutos[nScan][8]
				nSaldoTrans:= aProdutos[nScan][9]

				nQtdePrev  := aProdutos[nScan][3]
				nSaldoFil  := aProdutos[nScan][4]
				nQtdPrevF  := aProdutos[nScan][5]
			EndIf
	  		
			aAdd ( aReturn, {	PEDIDOS->C5_NUM,;			// 01-Numero do Pedido de Venda
								PEDIDOS->C6_ITEM,;   		// 02-Item do pedido de venda
								PEDIDOS->C6_PRODUTO,;   	// 03-codigo do produto
								PEDIDOS->B1_DESC,;   		// 04-descricao do produto
								nSaldo,;					// 05-saldo disponivel
								nQtdePrev,;					// 06-quantidade prevista
								PEDIDOS->C6_ENTREG,;		// 07-data prevista de entrega
								PEDIDOS->C5_CLIENTE,;		// 08-Codigo do cliente
								PEDIDOS->C5_LOJACLI,;		// 09-Loja do cliente
								PEDIDOS->A1_NOME,;			// 10-nome do cliente
								nVlPedMIPI,;				// 11-valor do pedido mais ipi
								PEDIDOS->C5_EMISSAO,;		// 12-Data de Emissao
								cSitPedido,;				// 13-Situação do pedido
								PEDIDOS->C6_NOTA,;			// 14-nota fiscal
								PEDIDOS->C6_DATFAT,;		// 15-data faturamento
								cNomTransp,;				// 16-nome da transportadora
								cVend1,;					// 17-Vendedor 1
								cVend2,;					// 18-Vendedor 2
								cVend3,;					// 19-Vendedor 3
								cVend4,;					// 20-Vendedor 4
								cVend5,;					// 21-Vendedor 5
								PEDIDOS->C6_QTDVEN,;		// 22-Quantidade Vendida
								nSaldoFil,;					// 23-Saldo Disponivel da Filial
								PEDIDOS->C6_QTDENT,;		// 24-Quantidade Entregue
								nQtdPrevF,;					// 25-quantidade prevista multi filial
								PEDIDOS->C6_TES,;			// 26-TES do pedido de venda
								nSaldo01,;					// 27-saldo filial 0101
								nSaldo02,;					// 28-saldo filial 0102
								nSaldo03,;					// 29-saldo filial 0103
								PEDIDOS->C6_QTDVEN-PEDIDOS->C6_QTDENT,; // 30-Quantidade A Entregar
								nSaldoTrans })              // 31-Qtde.Transf.Pre-nota


		EndIf
	
		DbSelectArea("PEDIDOS")
		DbSkip()
	EndDo
	DbSelectArea("PEDIDOS")
	DbCloseArea()

	RestArea( aAreaSB2 )
	RestArea( aArea )

Return ( aReturn )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³Atualiza  ³ Autor ³ Joao Mattos           ³ Data ³12.11.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³º Atualiza Informacoes                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Atualiza()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC01 - Perguntas                                         ³±±
±±³          ³ ExpO02 - Objeto list box                                   ³±±
±±³          ³ ExpA03 - Array  list box                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico MA - Hospitalar                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                          ULTIMAS ALTERACOES                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Atualiza(cPerg, _oListBox, _aListBox)

	Local nScan     := 0

	If Pergunte(cPerg,.T.)
	
		_aListBox := {}
		Processa({|| _aListBox := BuscaInfo(cPerg) },"Pesquisando Pedidos de Vendas...")
	
		If Len(_aListBox) == 0
		
			aAdd ( _aListBox, {	"",;		// 01-Numero do Pedido de Venda
								"",;   	    // 02-Item do pedido de venda
								"",;   	    // 03-codigo do produto
								"",;   	    // 04-descricao do produto
								0,;			// 05-saldo disponivel
								0,;			// 06-quantidade prevista
								Ctod(''),;	// 07-Previsao de Entrega
								"",;		// 08-Codigo do cliente
								"",;		// 09-Loja do cliente
								"",;		// 10-nome do cliente
								0,;			// 11-valor do pedido mais ipi
								Ctod(''),;	// 12-data de Emissao
								"xx",;		// 13-Situação do pedido
								"",;		// 14-nota fiscal
								Ctod(''),;	// 15-data faturamento
								"",;		// 16-nome da transportadora
								"",;		// 17-Vendedor 1
								"",;		// 18-Vendedor 2
								"",;		// 19-Vendedor 3
								"",;		// 20-Vendedor 4
								"",;		// 21-Vendedor 5
								0,;			// 22-Quantidade Vendida
								0,;			// 23-Saldo da Filial
								0,;			// 24-Quantidade Entregue
								"",;		// 26-TES do pedido de venda
								0,;			// 27-saldo filial 0101
								0,;			// 28-saldo filial 0102
								0,;			// 29-saldo filial 0103
								0,;			// 30-qtde a entregar
								0 ;			// 31-qtde Transf. Pre-Nota
							})

//								0,;			// 25-quantidade prevista multi filial

			MsgAlert("Nenhum Pedido de Venda encontrado!","Atenção!")  
		EndIf
	
		_oListBox:SetArray( _aListBox )
		_oListBox:bLine := { || {	IIf(nScan := AsCan( aLegenda, { |X| X[1] == _aListBox[ _oListBox:nAt, POS_STATUS_PED ] }) > 0, aLegenda[AsCan( aLegenda, { |X| X[1] == _aListBox[ _oListBox:nAt, POS_STATUS_PED ] })][2],o7),; // Legenda
										_aListBox[ _oListBox:nAt, POS_NUM_PEDIDO ],; 			// Numero do Pedido de Venda
										_aListBox[ _oListBox:nAt, POS_ITE_PEDIDO ],;			// item do pedido de venda
										_aListBox[ _oListBox:nAt, POS_TES ],;       			// TES do pedido de venda
										_aListBox[ _oListBox:nAt, POS_PRODUTO ],;				// produto
										_aListBox[ _oListBox:nAt, POS_DESC_PROD ],;			    // descricao do produto
										_aListBox[ _oListBox:nAt, POS_STATUS_PED ],;			// situacao do pedido
										Transform(_aListBox[ _oListBox:nAt, POS_QTDEVEND ],    PesqPict( "SC6", "C6_QTDVEN" )),; // quantidade vendida
										Transform(_aListBox[ _oListBox:nAt, POS_SLD_ENTREG ],  PesqPict( "SC6", "C6_QTDVEN" )),; // quantidade vendida
										Transform(_aListBox[ _oListBox:nAt, POS_SLD01 ],       PesqPict( "SB2", "B2_QATU" )),;   // saldo filial 0101
										Transform(_aListBox[ _oListBox:nAt, POS_SLD02 ],       PesqPict( "SB2", "B2_QATU" )),;   // saldo filial 0102
										Transform(_aListBox[ _oListBox:nAt, POS_SLD03 ],       PesqPict( "SB2", "B2_QATU" )),;   // saldo filial 0103
										Transform(_aListBox[ _oListBox:nAt, POS_PREV_TRANS],   PesqPict( "SB2", "B2_QATU" )),;   // saldo filial 0103
										Transform(_aListBox[ _oListBox:nAt, POS_QTDE_PREVIS ], PesqPict( "SB2", "B2_QATU" )),;	 // quantidade prevista de compra
										Transform(_aListBox[ _oListBox:nAt, POS_QTDEENTR ],    PesqPict( "SC6", "C6_QTDENT" )),; // quantidade entregue
										Dtoc(_aListBox[ _oListBox:nAt, POS_PREV_ENTREG ]),;	    // data prevista de entrega
										_aListBox[ _oListBox:nAt, POS_COD_CLIENTE ],;			// codigo do cliente
										_aListBox[ _oListBox:nAt, POS_LOJ_CLIENTE ],;			// loja do cliente
										_aListBox[ _oListBox:nAt, POS_NOM_CLIENTE ],;			// nome do cliente
										Transform(_aListBox[ _oListBox:nAt, POS_VALOR ], PesqPict( "SC6", "C6_VALOR" )),; // valor do pedido + ipi
										Dtoc(_aListBox[ _oListBox:nAt, POS_EMISSAO ]),;		    // data de emissao
										_aListBox[ _oListBox:nAt, POS_NOTAFISCAL ],;			// nota fiscal
										Dtoc(_aListBox[ _oListBox:nAt, POS_DATAFATURA ]),;	    // data do faturamento
										_aListBox[ _oListBox:nAt, POS_TRANSPORTA ],;			// nome da transportadora
										_aListBox[ _oListBox:nAt, POS_VEND1 ],;				    // vend 1
										_aListBox[ _oListBox:nAt, POS_VEND2 ],;				    // vend 2
										_aListBox[ _oListBox:nAt, POS_VEND3 ],;				    // vend 3
										_aListBox[ _oListBox:nAt, POS_VEND4 ],;				    // vend 4
										_aListBox[ _oListBox:nAt, POS_VEND5 ] }}				// vend 5

//										Transform(_aListBox[ _oListBox:nAt, POS_SALDOFIL ],    PesqPict( "SB2", "B2_QATU" )),;   // saldo filial
//										Transform(_aListBox[ _oListBox:nAt, POS_SALDO_DISP ],  PesqPict( "SB2", "B2_QATU" )),;   // saldo multi filial
//										Transform(_aListBox[ _oListBox:nAt, POS_QTD_PREVISF ], PesqPict( "SB2", "B2_QATU" )),;	 // quantidade prevista de compra multi filial

		_oListBox:Refresh()
	EndIf
Return Nil    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³AltStatus ³ Autor ³ Joao Mattos           ³ Data ³09.06.2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Altera Status do pedido de venda para estoque pendente     ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AltStatus( aDados, nLinha )                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA01 - Array com informacoes                             ³±±
±±³          ³ ExpN02 - Numero da linha                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico MA Hospitalar                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                          ULTIMAS ALTERACOES                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function AltStatus (_aListBox, nLinha)

	Local aArea    := GetArea()
	Local aAreaSC6 := SC6->(GetArea())
	Local oDlg     := Nil
	Local oRadio   := Nil
	Local nRadio   := Nil
	Local cStatus  := ""
	Local nOpca    := 0
	Local cTESESTP := SuperGetMv( "MA_TESESTR",.F.,"" )
	Local cNATESTP := SuperGetMv( "MA_NATESTR",.F.,"" )
	
		DEFINE MSDIALOG oDlg FROM  94,1 TO 300,293 TITLE "Alteração Status Pedido de Venda" PIXEL
		
			@ 05,17 Say "Status" SIZE 150,7 OF oDlg PIXEL
		
			@ 17,07 TO 82, 140 OF oDlg  PIXEL
		
			@ 25,10 Radio oRadio VAR nRadio;
							ITEMS 	"Estoque Pendente",;
									"Representada";
							SIZE 110,10 OF oDlg PIXEL
			
			DEFINE SBUTTON FROM 85,085 TYPE 1 ENABLE OF oDlg ACTION (nOpca := 1, oDlg:End())
			DEFINE SBUTTON FROM 85,115 TYPE 2 ENABLE OF oDlg ACTION (nOpca := 0, oDlg:End())
	
		ACTIVATE MSDIALOG oDlg CENTERED ON INIT (nOpca := 0, .T.)	// Zero nOpca caso para saida com ESC
	
		If nOpca == 1 // Confirma a alteração do status

			SC6->( DbSetOrder(1) ) // C6_FILIAL + C6_NUM + C6_ITEM + C6_PRODUTO
			If SC6->(MsSeek(xFilial("SC6") + PadR(_aListBox[nLinha][POS_NUM_PEDIDO], TamSx3("C6_NUM")[1]) + PadR(_aListBox[nLinha][POS_ITE_PEDIDO], TamSx3("C6_ITEM")[1])  ))

				SC6->( RecLock( "SC6", .f. ) )
					
					If nRadio == 2 // Altera Status do Pedido de Venda para Estoque Representado

						If _aListBox[nLinha][POS_STATUS_PED] == "Incluido" .And. (cTESESTP $ SC6->C6_TES) .And. (cNATESTP $ Posicione("SC5",1,xFilial("SC5")+SC6->C6_NUM,"C5_NATUREZ"))
							SC6->C6_STPESTQ := "R" // P=estoque Representado
							cStatus := "Representada" 
							SC6->(MsUnLock())
							_aListBox[nLinha][POS_STATUS_PED] := cStatus
							_oListBox:Refresh()
						Else
							MsgAlert('Só é permitido alterar o status para "Representada" para pedidos com Status "Incluido", e parametros MA_TESESTP e MA_NATESTP correspondentes.' )
						Endif
					ElseIf nRadio == 1 // Altera Status do Pedido de Venda para Estoque Pendende

						If _aListBox[nLinha][POS_STATUS_PED] == "Bloqueado Estoque"
							SC6->C6_STPESTQ := "P" // P=estoque pendente
							cStatus := "Estoque Pendente" 
							SC6->(MsUnLock())
							_aListBox[nLinha][POS_STATUS_PED] := cStatus
							_oListBox:Refresh()
						Else
							MsgAlert('Só é permitido alterar o status para "Estoque Pendente" para pedidos com Status "Estoque Bloqueado".' )
						Endif
					EndIf
			Else
			
				MsgAlert("Pedido: " + aDados[nLinha][POS_NUM_PEDIDO] + " - Item: " + aDados[nLinha][POS_ITE_PEDIDO] + " não localizado." )
			EndIf
		EndIf
	
	RestArea(aAreaSC6)
	RestArea(aArea)

Return ( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³C20GetSld ³ Autor ³ Joao Mattos           ³ Data ³09.06.2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Saldo Disponivel do produto por local                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ C20GetSld( produto )                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC01 - codigo do produto                                 ³±±
±±³          ³ ExpN02 - Numero da linha                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico MA Hospitalar                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                          ULTIMAS ALTERACOES                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function C20GetSld( cCodProd )

	Local aArea     := GetArea()
	Local aAreaSB2  := SB2->(GetArea())
	Local cQuery    := ""
	Local cAliasTmp := GetNextAlias()
	Local nTotal    := 0
	Local nTotal01  := 0
	Local nTotal02  := 0
	Local nTotal03  := 0
	Local aTotal    := {}
	Local cFilSld   := SuperGetMv( "MA_FILSLDE",.F.,"" )
	Local cLocSld   := SuperGetMv( "MA_LOCSLDE",.F.,"" )

	SB2->( DbSetOrder(1) ) 

	cQuery := " SELECT B2_FILIAL, B2_LOCAL "
	cQuery += " FROM " + RetSqlName("SB2" ) + " SB2 "
//	cQuery += " WHERE SB2.B2_FILIAL IN " + FormatIn(cFilSld,"|")
	cQuery += " WHERE SB2.B2_COD = '" + cCodProd + "' "
	cQuery += "   AND SB2.B2_LOCAL IN " + FormatIn(cLocSld,"|")
	cQuery += "   AND SB2.D_E_L_E_T_ = ' ' "
	cQuery += " GROUP BY B2_FILIAL, B2_LOCAL "
	cQuery += " ORDER BY B2_FILIAL, B2_LOCAL "
  
	cQuery := ChangeQuery( cQuery )
 	dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.F.,.T. )

	If (cAliasTmp)->(!EoF())

       While (cAliasTmp)->(!Eof())
        
 			dbSelectArea("SB2")
 			dbSetOrder(1)
			dbSeek( (cAliasTmp)->B2_FILIAL + cCodProd + (cAliasTmp)->B2_LOCAL )

			If  (cAliasTmp)->B2_FILIAL == '0101'
				nTotal01 += SaldoSb2()
			Endif
			If  (cAliasTmp)->B2_FILIAL == '0102'
				nTotal02 += SaldoSb2()
			Endif
			If  (cAliasTmp)->B2_FILIAL == '0103'
				nTotal03 += SaldoSb2()
			Endif

			nTotal += SaldoSb2()

			(cAliasTmp)->(dbSkip())
        EndDo
  EndIf 

  ( cAliasTmp )->( dbCloseArea() )

	RestArea( aAreaSB2 )
	RestArea( aArea )

	aAdd ( aTotal, {nTotal01,nTotal02,nTotal03} )

Return ( aTotal )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³CalcIPI   ³ Autor ³ Joao Mattos           ³ Data ³09.06.2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Calcula IPI                                                ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CalcIPI(cliente,loja,produto,tes,qtde,unit,total)          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC01 - Codigo do cliente                                 ³±±
±±³          ³ ExpC02 - loja do cliente                                   ³±±
±±³          ³ ExpC03 - codigo do produto                                 ³±±
±±³          ³ ExpC04 - TES                                               ³±±
±±³          ³ ExpN05 - Quantidade                                        ³±±
±±³          ³ ExpN06 - Preco unitario                                    ³±±
±±³          ³ ExpN07 - Valor total                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpN01 - Valor do IPI                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico MA Hospitalar                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                          ULTIMAS ALTERACOES                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CalcIPI (cCLIENTE, cLOJA, cProduto, cTes, nQuant, nPruni, nTotal)

	Private aRelImp     := MaFisRelImp("MT100",{"SF2","SD2"})
	Private cNfOri      := ""
	Private cSeriOri    := ""
	Private nRecnoSD2   := 0      
	Private nIT_ALIQIPI := "" 
	Private nIT_VALIPI  := ""  
	
	MaFisClear()      
	
	MaFisIni(cCLIENTE,;	    // 01-Codigo Cliente/Fornecedor
			 cLOJA,;		// 02-Loja do Cliente/Fornecedor
	         "C",;		    // 03-C:Cliente , F:Fornecedor
			 "N",;			// 04-Tipo da NF
			 "R",;			// 05-Tipo do Cliente/Fornecedor
			 aRelImp,;		// 06-Relacao de Impostos que suportados no arquivo
			  ,;			// 07-Tipo de complemento
			  ,;			// 08-Permite Incluir Impostos no Rodape .T./.F.
		  	 "SB1",;		// 09-Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)
	    	 "MATA461")	    // 10-Nome da rotina que esta utilizando a funcao
	               
	MaFisAdd(cProduto,;	    // 01-Codigo do' Produto ( Obrigatorio )
	 		 cTes,;		    // 02-Codigo do TES ( Opcional )
	 		 nQuant,;		// 03-Quantidade ( Obrigatorio )
			 nPruni,;		// 04-Preco Unitario ( Obrigatorio )
			 0,;			// 005-Valor do Desconto ( Opcional )
			 cNfOri,;		// 06-Numero da NF Original ( Devolucao/Benef )
			 cSeriOri,;	    // 07-Seri''e da NF Original ( Devolucao/Benef )
			 nRecnoSD2,;	// 08-RecNo da NF Original no arq SD1/SD2
			 0,;			// 09-Valor do Frete do Item ( Opcional )
			 0,;			// 10-Valor da Despesa do item ( Opcional )
			 0,;			// 11-Valor do Seguro do item ( Opcional )
			 0,;			// 12-Valor do Frete Autonomo ( Opcional )
			 nTotal,;		// 13-Valor da Mercadoria ( Obrigatorio )
			 0,;			// 14-Valor da Embalagem ( Opiconal )
			 0,;			// 15-RecNo do SB1
			 0,;			// 16-RecNo do SF4   
			 1)				// 17-Nro item
			 
	nIT_ALIQIPI := MaFisRet(1,"IT_ALIQIPI") 
	nIT_VALIPI  := MaFisRet(1,"IT_VALIPI")  
Return ( nIT_VALIPI )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³CalcIPI   ³ Autor ³ Joao Mattos           ³ Data ³09.06.2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Calcula IPI                                                ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CalcIPI(cliente,loja,produto,tes,qtde,unit,total)          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC01 - Filial do Pedido                                  ³±±
±±³          ³ ExpC02 - Numero do Pedido                                  ³±±
±±³          ³ ExpC03 - Item do Pedido de Venda                           ³±±
±±³          ³ ExpC04 - Recno do SC9                                      ³±±
±±³          ³ ExpA05 - Dados do Pedido De Venda                          ³±±
±±³          ³          Elemento 1 = C5_LIBEROK                           ³±±
±±³          ³          Elemento 2 = C6_NOTA                              ³±±
±±³          ³          Elemento 3 = C9_BLCRED                            ³±±
±±³          ³          Elemento 4 = C9_BLEST                             ³±±
±±³          ³          Elemento 5 = C6_STPESTQ                           ³±±
±±³          ³          Elemento 6 = C9_BLWMS                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpN01 - Valor do IPI                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico MA Hospitalar                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                          ULTIMAS ALTERACOES                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function C010StPV( _cFilial, _cPedido, _cItem, _nRecSC9, aDadosPV )

	Local aArea       := GetArea()
	Local aAreaSC5    := SC5->( GetArea() ) 
	Local aAreaSC6    := SC6->( GetArea() ) 
	Local aReturn     := { "Sem Classificacao", 0 }
	Local lOk         := .t.
	Local cStatus     := ""
	Local cC5_LIBEROK := ""
	Local cC6_NOTA    := ""
	Local cC9_BLCRED  := ""
	Local cC9_BLEST   := ""
	Local cC6_STPESTQ := ""
	Local cC9_BLWMS   := ""
	Local nC6_QTDENT  := 0
	Local nC6_QTDVEN  := 0
	Local cC5_ZTPLIBE := ""
	
	
	If aDadosPV <> Nil
	
		cC5_LIBEROK := aDadosPV[1] 
		cC6_NOTA    := aDadosPV[2]
		cC9_BLCRED  := aDadosPV[3]
		cC9_BLEST   := aDadosPV[4]
		cC6_STPESTQ := aDadosPV[5]
		cC9_BLWMS   := aDadosPV[6]
		nC6_QTDVEN  := aDadosPV[7]
		nC6_QTDENT  := aDadosPV[8]
		cC5_ZTPLIBE := aDadosPV[9]
		cC5_PEDIDO  := aDadosPV[10]
		cC5_FILIAL  := aDadosPV[11]
	Else
	
		_cFilial := PadR( _cFilial, TamSx3("C5_FILIAL")[1] )
		_cPedido := PadR( _cPedido, TamSx3("C6_NUM")[1] )
		_cItem   := PadR( _cItem  , TamSx3("C6_ITEM")[1] )
		
		// Pesquisa Cabecalho do Pedido de Venda
		SC5->( DbSetOrder(1) ) // C5_FILIAL + C5_NUM
		If SC5->( DbSeek( _cFilial + _cPedido ))
		
			cC5_LIBEROK := SC5->C5_LIBEROK
			
			// Pesquisa item do pedido de venda
			SC6->( DbSetOrder(1) ) // C6_FILIAL + C6_NUM + C6_ITEM + C6_PRODUTO
			If SC6->( DbSeek( _cFilial + _cPedido + _cItem ))

				cC6_NOTA    := SC6->C6_NOTA 
				cC6_STPESTQ := SC6->C6_STPESTQ 
				nC6_QTDVEN  := SC6->C6_QTDVEN 
				nC6_QTDENT  := SC6->C6_QTDENT 

				// Posiciona no registro da liberacao do pedido de venda
				DbSelectArea("SC9")
				DbGoTo(_nRecSC9)
				If !Eof()
				
					cC9_BLCRED := SC9->C9_BLCRED 
					cC9_BLEST  := SC9->C9_BLEST 
					cC9_BLWMS  := SC9->C9_BLWMS
				Else
				
					lOk     := .f.
					cStatus := "liberação não localizada"
				EndIf
			Else
			
				lOk     := .f.
				cStatus := "Item não localizado" 	
			EndIf
		Else
			
			lOk     := .f. 	
			cStatus := "Pedido não localizado" 	
		EndIf
	EndIf

	If lOk
	
		If cC5_LIBEROK <> 'S' .And. Empty(cC6_NOTA)  .And. cC6_STPESTQ != "R"
			aReturn := { "Incluido", 1 }
		ElseIf !Empty(cC6_NOTA) .And. cC9_BLEST == "10" .And.  (nC6_QTDVEN = nC6_QTDENT)
			aReturn := { "Faturado", 2 }
		ElseIf cC9_BLCRED $ "01|04|09"  .And. Empty(cC6_NOTA) 
			aReturn := { "Bloqueado Credito", 3 }
		ElseIf cC9_BLEST $ "02|03"  .And. cC6_STPESTQ == "P" // estoque pendente 
			aReturn := { "Estoque Pendente", 4 }
		ElseIf cC5_LIBEROK <> 'S' .And. cC6_STPESTQ == "R" // estoque representado 
			aReturn := { "Representada", 5 }
		ElseIf cC9_BLEST $ "02|03"   // .And. Empty(cC6_NOTA) 
			aReturn := { "Bloqueado Estoque", 6 }
		ElseIf Empty(cC9_BLCRED) .And. Empty(cC9_BLEST) .And. Empty(cC9_BLWMS) .And. Empty(cC6_NOTA)	 
		   
		   DO CASE
  				
  				CASE lLibFat(cC5_PEDIDO,cC5_FILIAL)=.F. .And. cC5_ZTPLIBE="2"
     				aReturn := { "Reservado Aguardando outro Item", 9 }
  				CASE lLibFat(cC5_PEDIDO,cC5_FILIAL)=.F. .And. cC5_ZTPLIBE<>"2"
     				aReturn := { "Aguardando Faturamento", 7 }
   				CASE lLibFat(cC5_PEDIDO,cC5_FILIAL)=.T. .And. cC5_ZTPLIBE<>"2"
					aReturn := { "Aguardando Faturamento", 7 }
  				OTHERWISE
    				aReturn := { "Aguardando Faturamento", 7 }
		   ENDCASE
			
		ElseIf !Empty(cC6_NOTA) .And. cC9_BLEST == "10" .And. (nC6_QTDVEN <> nC6_QTDENT)
			aReturn := { "Faturamento Parcial", 8 }
        Endif
	Else
	        
		aReturn := { cStatus, 0 }
	EndIf

Return ( aReturn )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³C010LEG   ³ Autor ³ Joao Mattos           ³ Data ³13/06/2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para legenda                  				           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ C010LEG()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                              		                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                           		    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MAHC010                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                          ULTIMAS ALTERACOES                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ Motivo da Alteracao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function C010LEG()

	BrwLegenda(cCadastro,"Legenda Status Pedido de Venda", 	{ ;
																		{"BR_VERDE" ,"Incluído"},;
																		{"BR_VERMELHO" ,"Faturado"},;
																		{"BR_AZUL" ,"Bloqueado Crédito"},;
																		{"BR_PINK" ,"Estoque Pendente"},;
																		{"BR_PRETO" ,"Representada"},;
																		{"BR_AMARELO" ,"Bloqueado Estoque"},;
																		{"BR_BRANCO" ,"Aguardando Faturamento"},;
																		{"BR_CINZA" , "Faturamento Parcial"},;
    																	{"BR_MARROM" , "Reservado Aguardando outro Item"};
    																	} )  
    																	
    																	
Return ( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ C010VIS  ³ Autor ³ Joao Mattos           ³ Data ³13/06/2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para Visualizacao                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ C010VIS()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                              		                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MAHC010                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                          ULTIMAS ALTERACOES                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ Motivo da Alteracao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function C010VIS( aDados, nLinha )

	Local aArea    := GetArea()
	Local aAreaSC6 := SC6->( GetArea() ) 

	SC6->( DbSetOrder(1) )
	If SC6->( DbSeek( xFilial("SC6") + aDados[nLinha][POS_NUM_PEDIDO] + aDados[nLinha][POS_ITE_PEDIDO] ))
	
		AXVISUAL( "SC6", SC6->( Recno() ), 2 )
	EndIf

	RestArea( aAreaSC6 )
	RestArea( aArea )

Return ( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ lLibFat  ³ Autor ³ Ednei Silva           ³ Data ³12/04/2018³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna se todas as linhas do pedido estao aguardando      ´±±
±±³faturamento     							                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ lLibFat(cPedido,cFilial)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                              		                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MAHC010                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                          ULTIMAS ALTERACOES                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ Motivo da Alteracao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function lLibFat(cZPed,cZFil)

Local lLibOk:=.T.

cQuery := " SELECT C9_BLCRED,C9_BLEST,C9_BLWMS,C6_NOTA "
cQuery += " FROM " + RetSqlName("SC9") + " SC9 "
cQuery += " INNER JOIN " + RetSqlName("SC6") + " SC6 ON (SC9.C9_PEDIDO=SC6.C6_NUM AND SC9.C9_FILIAL=SC6.C6_FILIAL AND SC6.D_E_L_E_T_<>'*') "
cQuery += " WHERE SC9.C9_PEDIDO = '" + cZPed + "'"
cQuery += "   AND SC9.C9_FILIAL = '" + cZFil + "'"
cQuery += "   AND SC9.D_E_L_E_T_<>'*' "
cQuery := ChangeQuery(cQuery)
MEMOWRITE ("\libFat.SQL", cQuery)
dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQuery), "LIBFAT", .F., .T.) // executa query

DbGoTop()
While !Eof()
	
	If	Empty(LIBFAT->C9_BLCRED) .And. Empty(LIBFAT->C9_BLEST) .And. Empty(LIBFAT->C9_BLWMS) .And. Empty(LIBFAT->C6_NOTA) .And. lLibOk
		
		lLibOk:=.T.
	else
		
		lLibOk:=.F.
		
	Endif
	
	DbSkip()
EndDo

dbCloseArea("LIBFAT")
return lLibOk
  
