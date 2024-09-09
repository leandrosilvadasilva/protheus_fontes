#INCLUDE "Totvs.Ch"
#Include "RptDef.CH"
#Include "FwPrintSetup.ch"
#Include "TbiConn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
auditoria	
±±³Funcao    ³MAHR310   ³ Autor ³ Leonir Donatti        ³ Data ³04/03/2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Impressao da Ordem de Servico.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ U_MAHR310()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico MA Hospitalar                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                          ULTIMAS ALTERACOES                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ Motivo da Alteracao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
User Function MAHR310()

   	Local nS				:= 0
   	Local nP				:= 0
    Local aSX5Pt            := {}
   	Private nTotProd		:= 0
   	Private nTotServ 		:= 0
   	Private nTotOrc		:= 0
	Private lPrint		:= .T.

	Private cNresp		:= ""
	Private cDiasE		:= ""
	Private cDddResp	:= ""
	Private cFonResp	:= ""
	Private cEmailResp	:= ""
	Private cNvend		:= ""
	Private cDddVend	:= ""
	Private cFonVend	:= ""
	Private cEmailVend	:= ""

	Private oFontW		:= TFont( ):New( "Wingdings",9,14,.T.,.F.,5,.T.,5,.T.,.F. )
	Private cPerg			:= PadR("MAHR310A",Len(SX1->X1_GRUPO))
	Private cFilePrint	:= "orçamento"+ DtoS( dDataBase ) + StrTran( Time( ),":","" )
	Private cPathInServer:= "\spool\"
	Private cSession	:= GetPrinterSession( )
	Private aDevice		:= { }
	Private nPag		:= 1
   
	Private oNum12		:= TFont( ):New( 'Courier',,12,.T.,.T.)
	Private oNum14N		:= TFont( ):New( 'Courier',,14,.T.,.T. )
	Private oNum16N		:= TFont( ):New( 'Courier',,16,.T.,.T. )
	Private oFont8N  	:= TFont( ):New( 'Arial',,08,.T.,.T. )
	Private oFont8  	:= TFont( ):New( 'Arial',,08,.T.,.F. )
	Private oFont10  	:= TFont( ):New( 'Arial',,10,.T.,.F. )
	Private oFont10N  	:= TFont( ):New( 'Arial',,10,.T.,.T. )
	Private oFont11N  	:= TFont( ):New( 'Arial',,11,.T.,.T. )
	Private oFont12		:= TFont( ):New( 'Arial',,12,.F.,.F.)
	Private oFont14		:= TFont( ):New( 'Arial',,14,.F.,.F.)
	Private oFont14N	:= TFont( ):New( 'Arial',,14,.T.,.T. )
	Private oFont16N	:= TFont( ):New( 'Arial',,16,.T.,.T. )
	Private oPrint  	:= Nil
	Private nLin		:= 010
	Private nCol		:= 000
	Private cLogo
	Private cVendAB3    :=""

	CriaSX1( cPerg )

	If Pergunte( cPerg,.T. )

		//If File( "lgoc" + cEmpAnt + cFilAnt + ".bmp" )
		//	cLogo := "lgoc" + cEmpAnt + cFilAnt + ".bmp"
		//ElseIf File( "lgoc" + cEmpAnt + cFilAnt + ".png" )
		//	cLogo := "lgoc" + cEmpAnt + cFilAnt + ".png"
		//ElseIf File( "lgoc" + cEmpAnt + cFilAnt + ".gif" )
		//	cLogo := "lgoc" + cEmpAnt + cFilAnt + ".gif"
		//Else
			cLogo := "LGOC0101" + ".bmp"
		//EndIf

// pesquisa campos pela query

		cQuery := " SELECT  AB3_NUMORC,"
		cQuery += "         AB3_CODCLI,"
		cQuery += "         AB3_ZDIASE,"
		cQuery += "         AB3_ZCDVEN,"
		cQuery += "         AB3_LOJA,"
		cQuery += "         AB3_ATEND,"
		cQuery += "         AB3_EMISSA,"
		cQuery += "         AB3_HORA,"
		cQuery += "         AB3_CONPAG,"
		cQuery += "         AB3_DTPROM,"
		cQuery += "         AB3_VALPRO,"
		cQuery += "         AB3_GARPRO,"
		cQuery += "         AB3_RESTEC,"
		cQuery += "         AB4_CODPRO,"
		cQuery += "         AB4_NUMORC,"
		cQuery += "         AB4_NUMSER,"
		cQuery += "         AB4_TIPO,"
		cQuery += "         AB5_CODPRO,"
		cQuery += "         AB5_QUANT,"
		cQuery += "         AB5_VUNIT,"
		cQuery += "         AB5_DESPRO,"
		cQuery += "         AB5_TOTAL,"
		cQuery += "         B1_TIPO,"
		cQuery += "         B1_MARCA,"
		cQuery += "         AA5_PRCCLI"
		cQuery += " FROM    " + RetSQLName("AB3") + " AB3"
		cQuery += " INNER JOIN " + RetSQLName("AB4") + " AB4"
		cQuery += " ON AB4.AB4_NUMORC = AB3.AB3_NUMORC"
		cQuery += " LEFT OUTER JOIN " + RetSQLName("AB5") + " AB5 ON" + CRLF
		cQuery += "         AB5.AB5_FILIAL = '" + xFilial("AB5") + "' AND AB5.AB5_NUMORC = AB4.AB4_NUMORC AND AB4.AB4_ITEM = AB5.AB5_ITEM AND AB5.D_E_L_E_T_ <> '*'"
		cQuery += " INNER JOIN " + RetSQLName("SB1") + " SB1"
		cQuery += " ON SB1.B1_COD = AB5.AB5_CODPRO"
		cQuery += " INNER JOIN " + RetSQLName("AA5") + " AA5"
		cQuery += " ON AA5.AA5_CODSER = AB5.AB5_CODSER"
		cQuery += " WHERE   AB3.AB3_FILIAL = '" + xFilial("AB3") + "'"
		cQuery += "  AND    AB4.AB4_FILIAL = '" + xFilial("AB4") + "'"
		cQuery += "  AND    SB1.B1_FILIAL = '" + xFilial("SB1") + "'"
		cQuery += "  AND    AA5.AA5_FILIAL = '" + xFilial("AA5") + "'"
		cQuery += "  AND    AB3.AB3_NUMORC BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"
		cQuery += "  AND    AB3.D_E_L_E_T_ <> '*'"
		cQuery += "  AND    AB4.D_E_L_E_T_ <> '*'"
		cQuery += "  AND    SB1.D_E_L_E_T_ <> '*'"
		cQuery += "  AND    AA5.D_E_L_E_T_ <> '*'"
		cQuery += "  ORDER BY AB3_NUMORC"
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T.,"TOPCONN",TcGenQry( ,,cQuery ),"TRB",.T.,.T. )

		oPrint := FWMSPrinter( ):New( "Orçamento", IMP_PDF )
		oPrint:SetPortrait( )
		oPrint:SetPaperSize( DMPAPER_A4 )
		oPrint:SetMargin( 10,10,10,10 )

      	DbSelectArea("TRB")
		DbGoTop( )

		If TRB->(!EOF())

			While TRB->(!EOF())

				cCodOrc := TRB->AB3_NUMORC
            	aProd	:= {}
            	aServ	:= {}
            	nTotOrc := 0
              nPag	:= 1

				While cCodOrc == TRB->AB3_NUMORC

					//DbSelectArea("SX5")
					//DbSetOrder(1)
					aSX5Pt:= FWGetSX5( "ZX",TRB->B1_MARCA,"pt-br") 
					
					
					//If DbSeek( xFilial("SX5")+ "ZX" +TRB->B1_MARCA) 
					if !empty(aSX5Pt[1][4])
						cMarca		:= aSX5Pt[1][4]// fabric            
				    Else
				    	cMarca		:= SB1->B1_MARCA// fabric            
					Endif                            
    
					cVendAB3:=TRB->AB3_ZCDVEN
					cDiasE:=TRB->AB3_ZDIASE
					If Alltrim(TRB->B1_TIPO) == "SV"

					


						aAdd( aServ,{	TRB->AB3_NUMORC,;
							  			TRB->AB3_CODCLI,;
										TRB->AB3_LOJA,;
										TRB->AB3_ATEND,;
										sTod(TRB->AB3_EMISSA),;
										TRB->AB3_HORA,;
										POSICIONE("SE4",1,XFILIAL("SE4")+ TRB->AB3_CONPAG,"E4_DESCRI"),;  //TRB->AB3_CONPAG
										sTod(TRB->AB3_DTPROM),;
										TRB->AB3_VALPRO,;
										TRB->AB3_GARPRO,;
										TRB->AB3_RESTEC,;
										TRB->AB4_CODPRO,;
										TRB->AB4_NUMORC,;
										TRB->AB4_TIPO,;
										TRB->AB5_CODPRO,;
										TRB->AB5_QUANT,;
										TRB->AB5_VUNIT,;
										TRB->AB5_DESPRO,;
										TRB->AB5_TOTAL,;
										TRB->B1_TIPO,;
										cMARCA,;
										TRB->AA5_PRCCLI,;
										TRB->AB4_NUMSER })
					Else
						aAdd( aProd,{	TRB->AB3_NUMORC,;
							  			TRB->AB3_CODCLI,;
										TRB->AB3_LOJA,;
										TRB->AB3_ATEND,;
										sTod(TRB->AB3_EMISSA),;
										TRB->AB3_HORA,;
										POSICIONE("SE4",1,XFILIAL("SE4")+ TRB->AB3_CONPAG,"E4_DESCRI"),;  //TRB->AB3_CONPAG
										sTod(TRB->AB3_DTPROM),;
										TRB->AB3_VALPRO,;
										TRB->AB3_GARPRO,;
										TRB->AB3_RESTEC,;
										TRB->AB4_CODPRO,;
										TRB->AB4_NUMORC,;
										TRB->AB4_TIPO,;
										TRB->AB5_CODPRO,;
										TRB->AB5_QUANT,;
										TRB->AB5_VUNIT,;
										TRB->AB5_DESPRO,;
										TRB->AB5_TOTAL,;
										TRB->B1_TIPO,;
										cMARCA,;
										TRB->AA5_PRCCLI,;
										TRB->AB4_NUMSER })

					EndIF

					TRB->(dbSkip())

				EndDo
				For nP := 1 to Len(aProd)
					If aProd[nP][22] == 100
						nTotOrc += aProd[nP][19]
					Else
						nTotOrc += 0
					EndIf
				Next nP

				For nS := 1 to Len(aServ)
					If aServ[nS][22] == 100
						nTotOrc += aServ[nS][19]
					Else
						nTotOrc += 0
					EndIf
				Next nS
                If !empty (aProd)
                	R310Cabec( aProd, nTotOrc )
	  			Else 
	  				R310Cabec( aServ,nTotOrc )
	  			EndIf
	  			
	//			nPag += 1
	          	DbSelectArea("TRB")
	          	nTotProd := 0
	          	nTotServ := 0

// Monta o cabeçalho dos produtos
	 			nLin += 050
				oBrush1 := TBrush():New( , RGB(  149, 175, 189  ) )
				oPrint:FillRect( {nLin-30, 050, nLin+28, 2280}, oBrush1 )
				oBrush1:End()   
				
				oPrint:Say ( nLin , 050,	"Relação de peças a serem substituídas:",		oFont11N )
				nLin += 030
				oPrint:Line ( nLin, 050, nLin, 2280 ) // linha horizontal superio
				nLin += 030
				//oPrint:Say ( nLin, 050,	"Código",			oFont11N )
				//oPrint:Say ( nLin, 250,	"QTD.",			oFont11N )
				//oPrint:Say ( nLin, 400,	"Vlr.Unitário",	oFont11N )
				//oPrint:Say ( nLin, 700,	"Descrição",		oFont11N )
				//oPrint:Say ( nLin, 1500,"Marca",			oFont11N )
				//oPrint:Say ( nLin, 1800,"Valor Total",	oFont11N )
				
				oPrint:Say ( nLin, 050,	"Código",			oFont11N )
				oPrint:Say ( nLin, 250,	"Descrição",			oFont11N )
				oPrint:Say ( nLin, 1050,"Marca",	oFont11N )
				oPrint:Say ( nLin, 1317,"Qtd.",		oFont11N )
	    		oPrint:Say ( nLin, 1575,"Vlr.Unitário",			oFont11N )
	    		oPrint:Say ( nLin, 2090,"Valor Total",	oFont11N )
				
				nLin += 030
				oPrint:Line ( nLin, 050, nLin, 2280 ) // linha horizontal inferior
				nLin += 060

		 		For nP := 1 to Len(aProd)

// - Verifica se está no final da página e pula para a próxima
  					If nLin >= 2200

						R310Rodap( )
	   		  			oPrint:EndPage()
						R310Cabec( aProd, nTotOrc )
						nPag += 1
						nLin += 050
// Monta o cabeçalho dos produtos na outra página
						oBrush1 := TBrush():New( , RGB(  149, 175, 189  ) )
						oPrint:FillRect( {nLin-30, 050, nLin+28, 2280}, oBrush1 )
						oBrush1:End()
						oPrint:Say ( nLin , 050,	"Relação de peças a serem substituídas",		oFont11N )
						nLin += 030
						oPrint:Line ( nLin, 050, nLin, 2280 ) // linha horizontal superio
						nLin += 030
						//oPrint:Say ( nLin, 050,	"Código",			oFont11N )
						//oPrint:Say ( nLin, 250,	"QTD.",			oFont11N )
						//oPrint:Say ( nLin, 400,	"Vlr.Unitário",	oFont11N )
						//oPrint:Say ( nLin, 700,	"Descrição",		oFont11N )
						//oPrint:Say ( nLin, 1500,"Marca",			oFont11N )
						//oPrint:Say ( nLin, 1800,"Valor Total",	oFont11N )
						
						oPrint:Say ( nLin, 050,	"Código",			oFont11N )
						oPrint:Say ( nLin, 250,	"Descrição",			oFont11N )
						oPrint:Say ( nLin, 1050,"Marca",	oFont11N )
						oPrint:Say ( nLin, 1317,"Qtd.",		oFont11N )
	    				oPrint:Say ( nLin, 1575,"Vlr.Unitário",			oFont11N )
	    				oPrint:Say ( nLin, 2090,"Valor Total",	oFont11N )
						
						nLin += 030
						oPrint:Line ( nLin, 050, nLin, 2280 ) // linha horizontal inferior
						nLin += 060

					EndIf

// Impressão dos produtos

	       		    //oPrint:Say ( nLin, 050,	aProd[nP][15],	oFont12 )
					//oPrint:Say ( nLin, 250,	PadR(cValToChar(aProd[nP][16]),TamSX3("AB5_QUANT")[1]),	oFont12 )
					
					//oPrint:Say ( nLin, 400,	PadR(Transform (aProd[nP][17], PesqPict("AB5","AB5_TOTAL")),TamSX3("AB5_TOTAL")[1]),	oFont12 )
					//oPrint:Say ( nLin, 700,	aProd[nP][18],	oFont12 )
					//oPrint:Say ( nLin, 1500,aProd[nP][21],	oFont12 )
					
					oPrint:Say ( nLin, 050,	aProd[nP][15],	oFont12 )
		            oPrint:Say ( nLin, 250,	aProd[nP][18],	oFont12 )
					oPrint:Say ( nLin, 1050,aProd[nP][21],	oFont12 )
					oPrint:Say ( nLin, 1350,cValToChar(aProd[nP][16]),	oNum12,,,NIL,1 )
					oPrint:Say ( nLin, 1500,Transform (aProd[nP][17], PesqPict("AB5","AB5_TOTAL")),	oNum12,,,NIL,1)
					
					
					
// Verifica se a peça está em garantia

			If  aProd[nP][22] == 100
						oPrint:Say ( nLin, 2000, Transform(aProd[nP][19], PesqPict("AB5","AB5_TOTAL")),	oNum12,,,NIL,1 )
						nTotProd += aProd[nP][19]
					Else
						oPrint:Say ( nLin, 2000, "Garantia",	oFont12 )
						nTotProd += 0
					EndIf

					nLin += 050

	  			Next nP

// Impressão do total dos produtos

				nLin += 020
		    	oPrint:Line ( nLin, 050, nLin, 2280 ) // linha horizontal inferior
				oPrint:Say ( nLin + 030, 1635,	"Total : ",		oFont14N )
			    oPrint:Say ( nLin + 030, 1952, Transform(nTotProd, PesqPict("AB5","AB5_TOTAL")),	oNum14N,,,NIL,1 )
			    nLin += 060

			   	If nLin >= 2200

					R310Rodap( )
					oPrint:EndPage()
					nPag += 1
					R310Cabec( aProd, nTotOrc)
				EndIf

// Monta o cabeçalho dos serviços
				nLin += 050
				oBrush1 := TBrush():New( , RGB(  149, 175, 189  ) )
				oPrint:FillRect( {nLin-30, 050, nLin+28, 2280}, oBrush1 )
				oBrush1:End()
				oPrint:Say ( nLin , 050,	"Serviços a serem executados",		oFont11N )
				nLin += 030
				oPrint:Line ( nLin, 050, nLin , 2280 ) // linha horizontal superio
				nLin += 030
				//oPrint:Say ( nLin, 050,	 "Código",			oFont11N )
				//oPrint:Say ( nLin, 250,	 "QTD.",			oFont11N )
				//oPrint:Say ( nLin, 400,	 "Vlr.Unitário",	oFont11N )
				//oPrint:Say ( nLin, 700,	 "Descrição",		oFont11N )
				//oPrint:Say ( nLin, 1800, "Valor Total",	    oFont11N )
				
				oPrint:Say ( nLin, 050,	"Código",			oFont11N )
				oPrint:Say ( nLin, 250,	"Descrição",			oFont11N )
				oPrint:Say ( nLin, 1050,"Marca",	oFont11N )
				oPrint:Say ( nLin, 1317,"Qtd.",		oFont11N )
	    		oPrint:Say ( nLin, 1575,"Vlr. Unitário",			oFont11N )
	    		oPrint:Say ( nLin, 2090,"Valor Total",	oFont11N )
				
				oPrint:Line ( nLin + 030, 050, nLin + 030, 2280 ) // linha horizontal inferior
	    		nLin += 060

    			For nS := 1 to Len(aServ)

					If nLin >= 2200

						R310Rodap( )
						oPrint:EndPage()
             			nPag += 1
						R310Cabec( aProd, nTotOrc )

// Monta o cabeçalho dos serviços
             			oPrint:Say ( nLin , 050,	"Serviços a serem executados",		oFont11N )
						nLin += 030
						oPrint:Line ( nLin, 050, nLin , 2280 ) // linha horizontal superio
						nLin += 030
						//oPrint:Say ( nLin, 050,	"Código",			oFont11N )
						//oPrint:Say ( nLin, 250,	"QTD.",			oFont11N )
						//oPrint:Say ( nLin, 400,	"Vlr.Unitário",	oFont11N )
						//oPrint:Say ( nLin, 700,	"Descrição",		oFont11N )
						//oPrint:Say ( nLin, 1800, "Valor Total",	oFont11N )
				   		//oPrint:Line ( nLin + 020, 050, nLin + 020, 2280 ) // linha horizontal inferior
	    				
	    				oPrint:Say ( nLin, 050,	"Código",			oFont11N )
	    				oPrint:Say ( nLin, 250,	"Descrição",			oFont11N )
	    				oPrint:Say ( nLin, 1050,"Marca",	oFont11N )
	    				oPrint:Say ( nLin, 1317,"Qtd.",		oFont11N )
	    				oPrint:Say ( nLin, 1575,"Vlr. Unitário",			oFont11N )
	    				oPrint:Say ( nLin, 2090,"Valor Total",	oFont11N )
	    				
	    				nLin += 060

					EndIf

					
					oPrint:Say ( nLin, 050,	aServ[nS][15],	oFont12 )
		            oPrint:Say ( nLin, 250,	aServ[nS][18],	oFont12 )
					oPrint:Say ( nLin, 1050,aServ[nS][21],	oFont12 )
					oPrint:Say ( nLin, 1350,cValToChar(aServ[nS][16]),	oNum12,,,NIL,1 )
					oPrint:Say ( nLin, 1500,Transform (aServ[nS][17], PesqPict("AB5","AB5_TOTAL")),	oNum12,,,NIL,1)
				    oPrint:Say ( nLin, 2000,Transform (aServ[nS][19], PesqPict("AB5","AB5_TOTAL")),	oNum12,,,NIL,1)
					//oPrint:Say ( nLin, 050,  aServ[nS][15],	oFont12 )
					//oPrint:Say ( nLin, 250,	 PadR(cValToChar(aServ[nS][16]),TamSX3("AB5_QUANT")[1]),	oFont12 )
					//oPrint:Say ( nLin, 400,  PadR(Transform (aServ[nS][17], PesqPict("AB5","AB5_TOTAL")),TamSX3("AB5_TOTAL")[1]),	oFont12 )
					//oPrint:Say ( nLin, 700,	 aServ[nS][18],	oFont12 )
					//oPrint:Say ( nLin, 1800, PadR(Transform (aServ[nS][19], PesqPict("AB5","AB5_TOTAL")),TamSX3("AB5_TOTAL")[1]),	oFont12 )
					nTotServ += aServ[nS][19]
					nLin += 050

  				Next nS

// Impressão do total dos serviços

   				nLin += 020
	   			oPrint:Line ( nLin, 050, nLin, 2280 ) // linha horizontal inferior
				oPrint:Say ( nLin + 030, 1635,	"Total : ",		oFont14N )
				oPrint:Say ( nLin + 030, 1952, Transform (nTotServ, PesqPict("AB5","AB5_TOTAL")),	oNum14N,,,NIL,1 )
	   			nLin += 100

// Impressão do total do orçamento

				oPrint:Say ( nLin, 1200,	" Valor Total Orçamento ",		oFont16N )
				oPrint:Say ( nLin, 1900,  Transform((nTotProd + nTotServ), PesqPict("AB5","AB5_TOTAL")),	oNum16N,,,NIL,1 )
				R310Rodap()
				oPrint:EndPage()

			EndDo //While do arquivo

			If 	lPrint
	 			oPrint:Preview( )     // Visualiza antes de imprimir
			Endif
        Else
        	Aviso( "Atenção!", "Não há dados a serem exibidos",{"Ok"},1 )
		EndIf

		TRB->(DbCloseArea())

	Else
		Aviso( "Atenção!", "Preencha os parametros",{"Ok"},1 )
	EndIf

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ R001Imp()³ Autor ³Leonir Donatti         ³ Data ³07/03/2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Impressão do Cabeçalho do Orçamento                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ R310Cabec(aProd, nTotOrc)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aProd: Produtos gravados, nTotOrc : Total do orçamento      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R310Cabec( aProd, nTotOrc )

	Local cDescProd	:= ""
	Local cMarca		:= ""
	Local cForma		:= ""
	Local cNomeCli	:= ""
	Local cCgc			:= ""
	Local cEnd			:= ""
	Local cIest		:= ""
	Local cMunic		:= ""
	Local cUf			:= ""
	Local cDdd			:= ""
	Local cTel			:= ""
	Local cFax			:= ""
	Local cCep			:= ""
	Local cContato		:= ""
	Local cContCli		:= ""
    Local aSX5Pt        := {}
	nLin := 300

	oPrint:StartPage() // Inicia uma nova página

// Posiciona na tabela SA1 para buscar dados do Cliente
    
	dbSelectArea( "SA1" )
	dbSetOrder( 1 )
	dbSeek( xFilial( "SA1" ) + aProd[1][2] + aProd[1][3] )
	cNomeCli 	:= SA1->A1_NOME //A1_REDUZ 
	cCgc		:= SA1->A1_CGC
	cEnd		:= SA1->A1_END
	cIest		:= SA1->A1_INSCR
	cMunic		:= SA1->A1_MUN
	cUf			:= SA1->A1_EST
	cDdd		:= SA1->A1_DDD
	cTel		:= SA1->A1_TEL
	cFax		:= SA1->A1_FAX
	cCep		:= SA1->A1_CEP
	cContato	:= SA1->A1_VEND
	cContCli	:= SA1->A1_CONTATO

//Verifica Contato do Cliente 

DbSelectArea("AC8")
DbSetOrder(2)
IF DbSeek(xFilial("AC8")+"SA1"+xFilial("SA1")+SA1->A1_COD+SA1->A1_LOJA)
	// Contatos
	DbSelectArea("SU5")
	DbSetOrder(1)
	IF DbSeek(xFilial("SU5")+Ac8->ac8_codcon)
		cContCli:=SU5->U5_CONTAT
	Endif
Endif	

// Posiciona na tabela AA3 para buscar o campo Patrimônio

	dbSelectArea( "AA3" )
	dbSetOrder( 1 )
	dbSeek( xFilial( "AA3" ) + aProd[1][2] + aProd[1][3] + aProd[1][12] + aProd[1][23] )
	cPatrimonio := AA3->AA3_CHAPA

// Posiciona na tabela SB1 para buscar a Descrição e a Marca do produto

	dbSelectArea( "SB1" )
	dbSetOrder( 1 )
	dbSeek( xFilial( "SB1" ) + aProd[1][12] )
	cDescProd	:= SB1->B1_DESC
	//DbSelectArea("SX5")
	//DbSetOrder(1)
	
	
	
	aSX5Pt:= FWGetSX5( "ZX",SB1->B1_MARCA,"pt-br") 

					
	//If DbSeek( xFilial("SX5")+ "ZX" +TRB->B1_MARCA) 
	if !empty(aSX5Pt[1][4])
		 cMarca		:= aSX5Pt[1][4]// fabric            
    Else
		 cMarca		:= SB1->B1_MARCA// fabric            
	Endif  

    
	// Posiciona na tabela SA3 para buscar infomações do responsável técnico
	dbSelectArea( "SA3" )
	dbSetOrder( 1 )
	dbSeek( xFilial( "SA3" ) + aProd[1][11] )
	cNresp			:= SA3->A3_NOME
	cDddResp		:= SA3->A3_DDDTEL
	cFonResp		:= SA3->A3_TEL
    cEmailResp	:= SA3->A3_EMAIL

// Posiciona na tabela SA3 para buscar informações do vendedor

	dbSelectArea( "SA3" )
	dbSetOrder( 1 )
	dbSeek( xFilial( "SA3" ) + cVendAB3 )
	cNvend			:= SA3->A3_NOME
	cDddVend		:= SA3->A3_DDDTEL
	cFonVend		:= SA3->A3_TEL
    cEmailVend	:= SA3->A3_EMAIL

// Posiciona na tabela SE4 para buscar a forma de pagamento

	dbSelectArea( "SE4" )
	dbSetOrder( 1 )
	dbSeek( xFilial( "SE4" ) + aProd[1][7] )
	cForma := SE4->E4_FORMA

// Seleciona a área das tabelas

	dbSelectArea( "AB3" )
	dbSetOrder( 1 )

	dbSelectArea( "AB4" )
	dbSetOrder( 1 )

	dbSelectArea( "AB5" )
	dbSetOrder( 1 )

	oPrint:SayBitmap ( 020, 900, cLogo, 310, 260 ) // logo

	oPrint:Say ( nLin-122, 1700,	"Orcamento :  ",		   oFont16N )
	oPrint:Say ( nLin-122, 2000,	aProd[1][1],			   oFont16N )
    nLin += 030
	oPrint:Say ( nLin-122, 1700,	"Pag.: ",				   oFont8N )
	oPrint:Say ( nLin-122, 2000,	cValToChar(nPag),		   oFont8N )
	//oPrint:Say ( nLin-280, 050,		" A(O) ",				   oFont11N )
    nLin += 030
	oPrint:Say ( nLin-122, 1700,	"Data/Hora: ",			   oFont8N )
	oPrint:Say ( nLin-122, 2000,	dToc(Date())+' - '+ Time(),oFont8N )
	
	//nLin += 050
	oBrush1 := TBrush():New( , RGB(  149, 175, 189  ) )
	oPrint:FillRect( {nLin-30, 050, nLin+28, 2280}, oBrush1 )
	oBrush1:End()
	oPrint:Say ( nLin, 050,		"Cliente",				   oFont11N )
	nLin += 060
	//oPrint:Say ( nLin, 050,		" A(O) ",				   oFont11N )
    //nLin += 030
	oPrint:Say ( nLin, 050,	"Razão Social :",			oFont11N )
	oPrint:Say ( nLin, 300,	cNomeCli,					oFont12 )
    nLin += 030
	oPrint:Say ( nLin, 050,	"Contato : ",				oFont11N )
	oPrint:Say ( nLin, 300,	cContCli,					oFont12 )
    nLin += 030
	oPrint:Say ( nLin, 050,	"Endereço : ",				oFont11N )
	oPrint:Say ( nLin, 300,	cEnd,					oFont12 )
	oPrint:Say ( nLin, 1200,	"CNPJ/CPF : ",		oFont11N )
	oPrint:Say ( nLin, 1400,	cCgc,					oFont12 )
    nLin += 030
	oPrint:Say ( nLin, 050,	"Município/UF : ",	oFont11N )
	oPrint:Say ( nLin, 300,	cMunic + "/" + cUf,	oFont12 )
	oPrint:Say ( nLin, 1200,	"I.E : ",				oFont11N )
	oPrint:Say ( nLin, 1400,	cIest,					oFont12 )
    nLin += 030
	oPrint:Say ( nLin, 050,	"CEP : ",				oFont11N )
	oPrint:Say ( nLin, 300,	Transform(cCep,PesqPict("SA1","A1_CEP")),					oFont12 )
	oPrint:Say ( nLin, 1200,	"DDD : ",				oFont11N )
	oPrint:Say ( nLin, 1300,	cDdd,					oFont12 )
	oPrint:Say ( nLin, 1400,	"Tel : ",				oFont11N )
	oPrint:Say ( nLin, 1500,	cTel,					oFont12 )
	oPrint:Say ( nLin, 1700,	"Fax : ",				oFont11N )
	oPrint:Say ( nLin, 1800,	cFax,					oFont12 )
    nLin += 050
	oBrush1 := TBrush():New( , RGB(  149, 175, 189  ) )
	oPrint:FillRect( {nLin-30, 050, nLin+28, 2280}, oBrush1 )
	oBrush1:End()
	oPrint:Say ( nLin, 050,	"Condições gerais da proposta  ",	oFont11N )
    nLin += 060
	oPrint:Say ( nLin, 050,	"Data Documento : ",					oFont11N )
	oPrint:Say ( nLin, 400,	dToc(aProd[1][5]),					oFont12 )
	oPrint:Say ( nLin, 1400,	"Condição de Pag.: ",				oFont11N )
	oPrint:Say ( nLin, 1700,	aProd[1][7],							oFont12 )
    nLin += 030
	oPrint:Say ( nLin, 050,	"Data Prometida : ",					oFont11N )
	oPrint:Say ( nLin, 400,	dToc(aProd[1][8]),					oFont12 )
	oPrint:Say ( nLin, 700,	"Valor Orçamento :  R$ ",			oFont11N )
	oPrint:Say ( nLin, 1200,	Alltrim(Transform (nTotOrc, PesqPict("AB5","AB5_TOTAL"))),	oFont12 )
	oPrint:Say ( nLin, 1400,	"Forma de Pag.: ",					oFont11N )
	oPrint:Say ( nLin, 1700,	cForma,								oFont12 )
    nLin += 030
	oPrint:Say ( nLin, 050,	"Validade da Proposta : ",			oFont11N )
	oPrint:Say ( nLin, 400,	aProd[1][9],							oFont12 )
	oPrint:Say ( nLin, 700,	"Garantia do Produto : ",			oFont11N )
	oPrint:Say ( nLin, 1200,	aProd[1][10],							oFont12 )
    nLin += 060
	oPrint:Say ( nLin, 050,	"Prezado(a)Senhor(a) ",				oFont11N )
	nLin += 030
	oPrint:Say ( nLin, 050,	"Informamos reparos, preços e condições de pagamento para o conserto do equipamento descrito a seguir:",	oFont11N )
	nLin += 030
	oPrint:Say ( nLin, 050,	"Modelo ",				   				oFont11N )
	oPrint:Say ( nLin, 200,	cDescProd,								oFont12 )
	oPrint:Say ( nLin, 1600,	"Patrimônio:",						oFont11N )
	oPrint:Say ( nLin, 1750, cPatrimonio,							oFont12 )
	nLin += 030
	oPrint:Say ( nLin, 050,	"Marca:",								oFont11N )
	oPrint:Say ( nLin, 200,	cMarca,								oFont12 )
	oPrint:Say ( nLin, 500,	"Num. Série:",						oFont11N )
	oPrint:Say ( nLin, 700, 	aProd[1][23],							oFont12 )
	nLin += 030

Return (nLin)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³R310Rodap()³ Autor ³Leonir Donatti        ³ Data ³07/03/2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Impressão do Rodapé do Orçamento                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ R310Rodap()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R310Rodap()

		nLin := 2400
		oBrush1 := TBrush():New( , RGB(  149, 175, 189  ) )
		oPrint:FillRect( {nLin-30, 050, nLin+28, 2280}, oBrush1 )
		oBrush1:End()
		oPrint:Say ( nLin, 050, "Observações ",						oFont11N )
		nLin += 060
		oPrint:Say ( nLin, 050, "Crédito sujeito a análise financeira.",	oFont12 )
		nLin += 030
		oPrint:Say ( nLin, 050, "Após aprovação o prazo de entrega será de até "+IIF(!EMPTY(AllTrim(cDiasE)),AllTrim(cDiasE),"40")+" dias, em casos de indisponibilidade de peças em nosso estoque",		oFont12 )
		nLin += 030
		oPrint:Say ( nLin, 050, "este prazo pode aumentar.",		oFont12 )
		nLin += 060

// Vendedor / Responsável Técnico
        oBrush1 := TBrush():New( , RGB(  149, 175, 189  ) )
		oPrint:FillRect( {nLin-30, 050, nLin+28, 2280}, oBrush1 )
		oBrush1:End()
		oPrint:Say ( nLin, 050, "Responsáveis ",						oFont11N )
		nLin += 060
		
		oPrint:Say ( nLin, 500, "Vendedor:",			oFont11N )
		oPrint:Say ( nLin, 1500,"Responsável Técnico:",	oFont11N )
		nLin += 030
		oPrint:Say ( nLin, 500, cNvend,					oFont10 )
		oPrint:Say ( nLin, 1500,cNresp,					oFont10 )
		nLin += 030
		oPrint:Say ( nLin, 500, cEmailVend,				oFont10 )
		oPrint:Say ( nLin, 1500,cEmailResp ,			oFont10 )
		nLin += 030
		oPrint:Say ( nLin, 500, "(" + cDddVend + ")" + cFonVend,	oFont10 )
		oPrint:Say ( nLin, 1500,"(" + cDddResp + ")" + cFonResp,	oFont10 )
		nLin += 050
		oPrint:Say ( nLin, 050, "Assistência Técnica CRedenciada: Monteiro Antunes Insumos Hospitalares Ltda / CREA-RS 119837",	oFont12 )
		nLin += 030
		oPrint:Say ( nLin, 050, "Em virtude da RDC 59, informamos que este orçamento tem prazo de aprovação de 30( trinta ) dias a contar da data de recebimento. O mesmo deve retornar aprovado com",	oFont12 )
   		nLin += 030
		oPrint:Say ( nLin, 050, "devido aceite do cliente via fax ou e-mail. O prazo final para aprovação será comunicado por fax ou e-mail com 05( cinco ) dias de antecedência.",	oFont12 )
		nLin += 015
						oPrint:Line ( nLin, 050, nLin, 2280 ) // linha horizontal inferior
		nLin += 035
		R310Fil(nLin)

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³R310Fil()  ³ Autor ³Leonir Donatti        ³ Data ³07/03/2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Impressão das Filiais                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ R310Fil(nLin)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nLin: Posição das linhas                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R310Fil(nLin)

		Local aArea		:= GetArea()
		Local cAreaSM0	:= SM0->( GetArea())
		Local aEmpresas := {}
		Local nEmpresas := 4
		Local nCont		:= 0
		Local nCol		:= 050
		Local nX		:= 0

 		DbSelectArea("SM0")
		DbGoTop()

		While !Eof()

			nCont += 1

			If nCont > 4
            	Exit
			EndIf

			aAdd ( aEmpresas, {	SM0->M0_FILIAL,;
									SM0->M0_ENDCOB,;
									SM0->M0_CEPCOB,;
									SM0->M0_BAIRCOB,;
									SM0->M0_CIDCOB,;
									SM0->M0_ESTCOB,;
									SM0->M0_TEL,;
									SM0->M0_FAX,;
									SM0->M0_CGC} )

			DbSelectArea("SM0")
			DbSkip()

		EndDo

		For nX := 1 to Len(aEmpresas)
            
            IF nx=1
            	oPrint:SayBitmap ( nLin-22, 050, cLogo, 103, 70 ) // logo
            	oBrush1 := TBrush():New( , RGB(   200, 225, 209   ) )
            	oPrint:FillRect( {nLin-15, 050+100, nLin+40, 500}, oBrush1 )
            	oBrush1:End()
            endif
            
            IF nx=2
            	oPrint:SayBitmap ( nLin-22, nCol, cLogo, 103, 70 ) // logo
            	oBrush1 := TBrush():New( , RGB(  200, 225, 209   ) )
            	oPrint:FillRect( {nLin-15, nCol+100, nLin+40, 1100}, oBrush1 )
            	oBrush1:End()
            endif
            
            IF nx=3
            	oPrint:SayBitmap ( nLin-22, nCol, cLogo, 103, 70 ) // logo
            	oBrush1 := TBrush():New( , RGB(  200, 225, 209   ) )
            	oPrint:FillRect( {nLin-15, nCol+100, nLin+40, 1700}, oBrush1 )
            	oBrush1:End()
            endif
            
            IF nx=4
            	oPrint:SayBitmap ( nLin-22, nCol, cLogo, 103, 70 ) // logo
            	oBrush1 := TBrush():New( , RGB(  200, 225, 209  ) )
            	oPrint:FillRect( {nLin-15, nCol+100, nLin+40, 2280}, oBrush1 )
            	oBrush1:End()
            endif
            
			oPrint:Say ( nLin +024, nCol+110, aEmpresas[nX][1], oFont10N,,CLR_GRAY, )
			oPrint:Say ( nLin +060, nCol, "" + Alltrim(aEmpresas[nX][2]), oFont8N,,CLR_GRAY, )
			oPrint:Say ( nLin +090, nCol, "CEP " + Alltrim(aEmpresas[nX][3]) + "|" + Alltrim(aEmpresas[nX][4]) + "-" + Alltrim(aEmpresas[nX][5]) + " " + Alltrim(aEmpresas[nX][6]) , oFont8N,,CLR_GRAY, )
			oPrint:Say ( nLin +110, nCol, "Fone/Fax: " + Alltrim(aEmpresas[nX][7]) + "/" + Alltrim(aEmpresas[nX][8]), oFont8N,,CLR_GRAY, )
			oPrint:Say ( nLin +140, nCol, "CNPJ: " + Alltrim(aEmpresas[nX][9]), oFont8N,,CLR_GRAY, )
			nCol += 600

		Next nX

		RestArea( aArea )

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³CriaSx1()  ³ Autor ³Leonir Donatti        ³ Data ³07/03/2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Cria as perguntas                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CriaSx1()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CriaSx1( cPerg )

	Local aP      := {}
	Local aHelp   := {}
	Local nI      := 0
	Local cSeq    := ""
	Local cMvCh   := ""
	Local cMvPar  := ""

	//				Texto Pergunta				Tipo		Tam			Dec		G=get ou C=Choice   	 Val   		F3       Def01   		Def02   	Def03   	Def04   	Def05

	aAdd(aP,{	"Orçamento de? ",					"C",		9,			0,				"G",			 "",		   "AB3",			"",			 "",		  "",		 "",	 	 ""} )
	aAdd(aP,{	"Orçamento até? ",		   		"C",		9,			0,				"G",			 "",		   "AB3",			"",			 "",		  "",		 "",	 	 ""} )

	 //           012345678912345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
    //                    1         2         3         4         5         6         7         8         9        10        11        12
	aAdd( aHelp,{ "Orçamento de? " } )
	aAdd( aHelp,{ "Orçamento até? " } )

	For nI := 1 To Len( aP )

		cSeq	:= StrZero( nI,2,0 )
		cMvPar	:= "mv_par" + cSeq
		cMvCh	:= "mv_ch" + IiF( nI<=9,Chr(nI+48),Chr(nI+87) )

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
