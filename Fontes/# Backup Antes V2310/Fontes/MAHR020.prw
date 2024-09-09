#Include 'Totvs.ch'
#Include 'RPTDEF.CH'
#Include 'FwPrintSetup.ch'
#Define POS_NUM_PEDIDO  01
#Define POS_ITE_PEDIDO  02
#Define POS_PRODUTO     03
#Define POS_DESC_PROD   04
#Define POS_SALDO_DISP  05
#Define POS_QTDE_PREVIS 06
#Define POS_EMISSAO     07
#Define POS_COD_CLIENTE 08
#Define POS_LOJ_CLIENTE 09
#Define POS_NOM_CLIENTE 10
#Define POS_VALOR       11
#Define POS_PREV_ENTREG 12
#Define POS_STATUS_PED  13
#Define POS_NOTAFISCAL  14
#Define POS_DATAFATURA  15
#Define POS_TRANSPORTA  16
#Define POS_VEND1       17
#Define POS_VEND2       18
#Define POS_VEND3       19
#Define POS_VEND4       20
#Define POS_VEND5       21
#Define POS_QTDEVEND    22
#Define POS_SALDOFIL    23
#Define POS_TES     	26
#Define POS_SLD0101   	27
#Define POS_SLD0102   	28
#Define POS_SLD0103   	29

#Define POS_SLD_ENTREG 		30
#Define POS_PREV_TRANS 		31
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MAHR020   ³ Autor ³Gregory Araujo         ³ Data ³09/06/2016³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Relatorio MA HOSPITALAR - Ped Venda                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³MAHR020()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aExp01 - Array de itens de pedidos filtrados na rotina pai ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Especifico MA HOSPITALAR                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                          ULTIMAS ALTERACOES                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ Motivo da Alteracao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function MAHR020(aDados)

	//Variáveis de uso no código
	Local lFirst			:= .T.
		
	// Variáveis para os tratamentos de valores do relatorio
	Local nTotValIpi	:= 0
	Local nTotFValIp	:= 0
		
	//Variáveis de controle FWMSprinter
	Local cPathInServer	:= "\spool\"
	Local cFilePrint		:= "FWMSprinter_Rel"+DtoS(DATE())+"_"+StrTran(TIME(),":","")
	Local lAdjustToLegacy	:= .F.
	Local lDisableSetup	:= .F.
	Local lViewPDF			:= .F.
	Local lPdfAsPng			:= .F.

	Private nLin			:= 130	// Linha inicial para a impressao dos itens	
	private nCol			:= -5	// Coluna inicial para a impressao dos itens
	Private nI			:= 0
	Private oFontCabN	:= TFont():New("Arial", , 12, , .T., , , , , .F. )
	Private oFontCab	:= TFont():New("Arial", , 12, , .F., , , , , .F. )
	Private oFontItem	:= TFont():New("Arial", , 6, , .F., , , , , .F. )	
	Private oFontStat	:= TFont():New("Arial", , 5, , .F., , , , , .F. )
	Private oFontHead	:= TFont():New("Arial", , 10, , .T., , , , , .F. )	
	Private oFontTot	:= TFont():New("Arial", , 10, , .T., , , , , .F. )
	Private oPrinter
	

	oPrinter := FWMSPrinter():New( cFilePrint, IMP_SPOOL, lAdjustToLegacy, cPathInServer, lDisableSetup, , , , lPdfAsPng, .F., , lViewPDF )
	// Ordem obrigatoria de configuracao do relatorio
	oPrinter:SetResolution(78)
	oPrinter:SetPortrait()
	oPrinter:SetPaperSize(DMPAPER_A4)
	oPrinter:SetMargin(60,60,60,60)
	oPrinter:nDevice := IMP_SPOOL
		
	If oPrinter:nModalResult == PD_OK
		
		R020CABEC() //Funcao para nova pagina de relatorio
		
		If Len(aDados) > 0						
			
			For nI := 1 to Len(aDados)	
			
				If lFirst //primeira vez passando pelo laço
					
					cCodVen		:= aDados[nI][POS_NUM_PEDIDO]
					lFirst			:= .F.
				
				EndIf
					
				If ( cCodVen == aDados[nI][POS_NUM_PEDIDO] ) //lista itens separados por pedido
					nTotValIpi	+= ( aDados[nI][POS_VALOR] * aDados[nI][POS_QTDEVEND] )
				Else
					
					cCodVen		:= aDados[nI][POS_NUM_PEDIDO]
					
					R020TOTA(nTotValIpi, aDados)
					
					nTotFValIp	+= nTotValIpi
					nTotValIpi	:= ( aDados[nI][POS_VALOR] * aDados[nI][POS_QTDEVEND] )
					
					//Cabeçalho por pedidos
					If nLin+2411 >= oPrinter:nVertRes()
						oPrinter:EndPage()
			   		   	R020CABEC() //cria uma nova pagina
			      EndIf 
								
				EndIf	
				
				//oPrinter:Say( nLin , nCol+010 , Transform( aDados[nI][POS_NUM_PEDIDO]      ,  PesqPict( "SC6","C6_NUM" )) , oFontItem, 050, CLR_BLACK)
				oPrinter:Say( nLin , nCol+010 , AllTrim(Transform( aDados[nI][POS_ITE_PEDIDO],	PesqPict( "SC6","C6_ITEM")))	, oFontItem, 050, CLR_BLACK)
				oPrinter:Say( nLin , nCol+025 , AllTrim(Transform( aDados[nI][POS_PRODUTO] 	 ,	PesqPict( "SB1","B1_COD"	)))		, oFontItem, 050, CLR_BLACK)		
				oPrinter:Say( nLin , nCol+070 , Substr(	aDados[nI][POS_DESC_PROD],1,50)      ,	oFontItem, 050, CLR_BLACK)
//				oPrinter:Say( nLin , nCol+265 , AllTrim(Transform( aDados[nI][POS_SALDOFIL]	 ,	"@E 999,999.99"))	, oFontItem, 050, CLR_BLACK)	
//				oPrinter:Say( nLin , nCol+312 , AllTrim(Transform( aDados[nI][POS_SALDO_DISP],	"@E 999,999.99"))	, oFontItem, 050, CLR_BLACK)	

				oPrinter:Say( nLin , nCol+265 , AllTrim(Transform( aDados[nI][POS_SLD_ENTREG],	"@E 999,999.99"))	, oFontItem, 050, CLR_BLACK)	

				oPrinter:Say( nLin , nCol+312 , AllTrim(Transform( aDados[nI][POS_SLD0101]	 ,	"@E 999,999.99"))	, oFontItem, 050, CLR_BLACK)	
				oPrinter:Say( nLin , nCol+359 , AllTrim(Transform( aDados[nI][POS_SLD0102]   ,	"@E 999,999.99"))	, oFontItem, 050, CLR_BLACK)	
				oPrinter:Say( nLin , nCol+412 , AllTrim(Transform( aDados[nI][POS_SLD0103]   ,	"@E 999,999.99"))	, oFontItem, 050, CLR_BLACK)	
				oPrinter:Say( nLin , nCol+467 , AllTrim(Transform( aDados[nI][POS_PREV_TRANS],	PesqPict( "SC6","C6_QTDVEN" )))	, oFontItem, 050, CLR_BLACK)

				oPrinter:Say( nLin , nCol+512 , AllTrim(Transform( aDados[nI][POS_QTDE_PREVIS],	PesqPict( "SC6","C6_QTDVEN" )))	, oFontItem, 050, CLR_BLACK)
				oPrinter:Say( nLin , nCol+555 , AllTrim(Transform( aDados[nI][POS_QTDEVEND]	 ,	PesqPict( "SC6","C6_QTDVEN" ))) ,oFontItem, 050, CLR_BLACK)
				oPrinter:Say( nLin , nCol+575 , AllTrim(Transform( aDados[nI][POS_VALOR]	 ,	PesqPict( "SC6","C6_VALOR"	))) ,oFontItem, 050, CLR_BLACK)
				oPrinter:Say( nLin , nCol+595 , AllTrim(Transform( aDados[nI][POS_PREV_ENTREG],	PesqPict( "SC6","C6_ENTREG" ))) ,oFontItem, 050, CLR_BLACK)
				oPrinter:Say( nLin , nCol+615 , AllTrim(Transform( aDados[nI][POS_STATUS_PED] ,	PesqPict( "SA1","A1_NREDUZ" ))) ,oFontStat, 050, CLR_BLACK)

				If Len( Alltrim(aDados[nI][POS_DESC_PROD]) ) > 30  //Quebra de linha da descricao do produto
					nLin += 10
					oPrinter:Say( nLin , nCol+070 , Substr(aDados[nI][POS_DESC_PROD], 31) , oFontItem, 050, CLR_BLACK)
				EndIf
				
				nLin += 10
				
				If aDados[nI] == aTail(aDados) //Ultimo indice do array
					
					nTotFValIp	+= nTotValIpi
					R020TOTA(	nTotValIpi, aDados) //Totalizador de ambiente
					R020TOTF(	nTotFValIp)
					Exit
				
				EndIf // Final do arquivo
				
				// Mudar de pagina
				If nLin+2411 >= oPrinter:nVertRes()
				
					oPrinter:EndPage()
	        		R020CABEC()
		      
		      EndIf 
				
			Next nI
			
		Else	// Len(aDados) > 0
			oPrinter:Say( 050 , 020  , "Nenhum item a ser exibido"   , oFontCab, 050, CLR_BLACK)
		EndIf
		
		oPrinter:EndPage()
		oPrinter:Preview()
		
   		FreeObj(oPrinter)
	
	EndIf //PD_OK
	
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ R020CABEC³ Autor ³ Gregory Araujo        ³ Data ³09/07/2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para criar a estrutura e nova pagina de Relatorio   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function R020CABEC()
	
	Local cLogo 	:= ""	
	
	If File( "lgoc" + cEmpAnt + cFilAnt + ".bmp" )
		cLogo := "lgoc" + cEmpAnt + cFilAnt + ".bmp"
	ElseIf File( "lgoc" + cEmpAnt + cFilAnt + ".png" )
		cLogo := "lgoc" + cEmpAnt + cFilAnt + ".png"
	ElseIf File( "lgoc" + cEmpAnt + cFilAnt + ".gif" )
		cLogo := "lgoc" + cEmpAnt + cFilAnt + ".gif"
	Else
		cLogo := "lgoc" + ".png"
	EndIf

	nLin := 100
	oPrinter:StartPage()
	
	// Caixa do Logotipo
	oPrinter:SayBitmap( 010, 010, cLogo ,160,080)
		
	//Dados do Box   
	dbSelectArea("SM0")
	dbSeek( cEmpAnt + cFilAnt )
	oPrinter:Say( 028, 200,	AllTrim( SM0->M0_NOMECOM )	, oFontCabN, 050)	//NOME	
	oPrinter:Say( 042, 200,	AllTrim( SM0->M0_ENDCOB )+" - Bairro: "+ 	AllTrim( SM0->M0_BAIRCOB )  	, oFontCab, 050)	//ENDEREÇO
	oPrinter:Say( 056, 200, AllTrim(SM0->M0_CIDCOB)+" - "+ ;						//BAIRRO
   							Transform( SM0->M0_CEPCOB, PesqPict( "SA1","A1_CEP" )) +" - "+; //CEP
   							AllTrim( SM0->M0_ESTCOB ), oFontCab, 050)	//ESTADO
									
	oPrinter:Say( 070, 200,	"Fone: " + Alltrim( SM0->M0_TEL ), oFontCab, 050)	

	nLin += 30
	
	R020HEAD()
	nLin += 15
				
	
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ R020TOTA ³ Autor ³ Gregory Araujo        ³ Data ³09/06/2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao de totalizador                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function R020TOTA(nTotValIpi, aDados)
	
	nLin += 5           
	oPrinter:Say( nLin , nCol+40  , "Pedido:"	, oFontHead, 050, CLR_BLACK)
	oPrinter:Say( nLin , nCol+85 , Transform( aDados[nI][POS_NUM_PEDIDO],	PesqPict( "SC6","C6_ITEM" )), oFontItem, 050, CLR_BLACK)
	
	oPrinter:Say( nLin , nCol+130 , "Cliente:"	, oFontHead, 050, CLR_BLACK)
	oPrinter:Say( nLin , nCol+180 , Transform( aDados[nI][POS_NOM_CLIENTE],	PesqPict( "SB1","B1_COD" ))	, oFontItem, 050, CLR_BLACK)		
	
	oPrinter:Say( nLin , nCol+400, "Total:"	, oFontTot, 050)                               	
	oPrinter:Say( nLin , nCol+450 , AllTrim( Transform( nTotValIpi, "@E 999,999,999.00") )	, oFontTot, 050)
	
	nLin += 5
	oPrinter:Line( nLin	, 0, nLin, 610 )
	nLin += 15
	
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ R020TOTF ³ Autor ³ Gregory Araujo        ³ Data ³09/07/2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao de totalizador final                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function R020TOTF(nTotFValIp)
	
	nLin+=5
	oPrinter:Line( nLin	, 0, nLin, 610 )
	nLin+=10
	
	oPrinter:Say( nLin	, 40, "Total Geral:", oFontTot, 050)
	oPrinter:Say( nLin	, nCol+400, AllTrim( Transform( nTotFValIp, "@E 999,999,999.00" ) ), oFontTot, 050)
	
	nLin+=5
	oPrinter:Line( nLin	, 0, nLin, 610 )
	nLin+=10
	
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ R020HEAD ³ Autor ³ Gregory Araujo        ³ Data ³10/06/2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao de cabecalho                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function R020HEAD()

	// Nome das colunas dos itens		
	oPrinter:Say( nLin , nCol+010 , "It."					, oFontHead, 050, CLR_BLACK)
	oPrinter:Say( nLin , nCol+025 , "Produto"			, oFontHead, 050, CLR_BLACK)
	oPrinter:Say( nLin , nCol+070 , "Descricao"			, oFontHead, 050, CLR_BLACK)			
//	oPrinter:Say( nLin , nCol+265 , "Sld.Disp."			, oFontHead, 050, CLR_BLACK)
//	oPrinter:Say( nLin , nCol+312 , "Sld.Mul.Fil"		, oFontHead, 050, CLR_BLACK)

	oPrinter:Say( nLin , nCol+265 , "Qtd a Entregar"	, oFontHead, 050, CLR_BLACK)
	oPrinter:Say( nLin , nCol+312 , "Sld.0101"			, oFontHead, 050, CLR_BLACK)
	oPrinter:Say( nLin , nCol+359 , "Sld.0102"  		, oFontHead, 050, CLR_BLACK)
	oPrinter:Say( nLin , nCol+412 , "Sld.0103"  		, oFontHead, 050, CLR_BLACK)
	oPrinter:Say( nLin , nCol+467 , "Qtd.Trans."		, oFontHead, 050, CLR_BLACK)

	oPrinter:Say( nLin , nCol+512 , "Qtd. Prev."		, oFontHead, 050, CLR_BLACK)
	oPrinter:Say( nLin , nCol+555 , "Qtd. Ped."			, oFontHead, 050, CLR_BLACK)
	oPrinter:Say( nLin , nCol+575 , "Val. + IPI"		, oFontHead, 050, CLR_BLACK)
	oPrinter:Say( nLin , nCol+595 , "Dt. Prev."			, oFontHead, 050, CLR_BLACK)
	oPrinter:Say( nLin , nCol+615 , "Situação Ped."		, oFontHead, 050, CLR_BLACK)
Return
