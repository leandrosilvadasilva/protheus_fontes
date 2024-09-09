#Include "PROTHEUS.CH"
#Include "TOTVS.CH"
#Include "RESTFUL.CH"
#Include "TbiConn.ch" 

//Opcoes ExecAuto 
#Define PD_INCLUIR 3 
#Define PD_ALTERAR 4 
#Define PD_EXCLUIR 5   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MAHADINVZ ³ Autor ³ Ednei R. Silva      ³ Data ³ MAI/2021  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ WS para inclusao de registros zerados automaticos.         ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico MA  Hospitalar                                  ³±±
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
WSRESTFUL MAHINVEZ DESCRIPTION "Inventario Online Zerados" 


WSDATA ZA3_FILIAL   AS STRING 	//(04) Filial 
WSDATA ZA3_DOC      AS STRING 	//(09) Documento 
WSDATA ZA3_DATA     AS STRING 	//(08) Data da leitura Ex: 20200430 
WSDATA ZA3_VENDED   AS STRING 	//(06) Codigo do Vendedor
WSDATA ZA3_LONG     AS STRING 	//(25) Longitude
WSDATA ZA3_LATI     AS STRING 	//(25) Latitude
WSDATA ZA3_FORNEC   AS STRING 	//(06) Cliente/Fornecedor
WSDATA ZA3_LOJA     AS STRING 	//(04) Loja cliente/Loja Fornecedor
WSDATA ZA3_IDINV    AS STRING 	//(80) Identificador Inventario		
	
WSMETHOD POST DESCRIPTION "Inventario Online Zerados" WSSYNTAX "/" 
	
END WSRESTFUL



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ POST     ºAutor  ³ Ednei Silva        º Data ³  MAI/2021   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Metodo para incluir inventario Online ZERADOS.             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MA Hospitalar                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

WSMETHOD POST WSRECEIVE NULLPARAM WSSERVICE MAHINVEZ

	Local lOk		:= .T.
	Local cBody		:= ::GetContent()
	Local oJson 
	Local cQuery	:= ""
	Local cAliasT	:= GetNextAlias()
	
    ConOut('ZZ01')
	::SetContentType("application/json")//Define o tipo de retorno do metodo	
				
	If !FWJsonDeserialize(cBody,@oJson)//Converte a estrutura Json em Objeto
	
		lOk := .F.
		SetRestFault( 1, "Nao foi possivel processar a estrutura Json." )	

	Else
		
		
		If Empty( oJson:ZA3_FILIAL )
			lOk := .F.	 				
	 		SetRestFault( 2, "Campo obrigatorio: Filial." )
		Endif 
		
		
		If Empty( oJson:ZA3_DATA ) 
			lOk := .F.	 				
	 		SetRestFault( 6, "Campo obrigatorio: Data Leitura." )
		Endif 
		
		If Empty( oJson:ZA3_VENDED )
			lOk := .F.	 				
	 		SetRestFault( 9, "Campo obrigatorio: Vendedor." )
		Endif 

		If Empty( oJson:ZA3_LONG )
			lOk := .F.	 				
	 		SetRestFault( 10, "Campo obrigatorio: Longitude." )
		Endif
		
		If Empty( oJson:ZA3_LATI )
			lOk := .F.	 				
	 		SetRestFault( 11, "Campo obrigatorio: Latitude." )
		Endif
		
		If Empty( oJson:ZA3_FORNEC )
			lOk := .F.	 				
	 		SetRestFault( 12, "Campo obrigatorio: Cliente." )
		Endif
		
		If Empty( oJson:ZA3_Loja )
			lOk := .F.	 				
	 		SetRestFault( 13, "Campo obrigatorio: Loja." )
		Endif
		
	
	    ConOut('ZZ02')    
        IF lOk
			cQuery := " SELECT      "
			cQuery += " B6_FILIAL,  "
			cQuery += " B6_LOCAL,   "
			cQuery += " B1_TIPO,    "
			cQuery += " ZA3_FILIAL, "
			cQuery += " B6_CLIFOR,  "
			cQuery += " B6_LOJA,    "
			cQuery += " B6_PRODUTO, "
			cQuery += " D2_LOTECTL, "
			cQuery += " D2_NUMSERI, "
	 		cQuery += " D2_LOCALIZ, "
			cQuery += " D2_DTVALID, "
			cQuery += " A3_COD, "
			cQuery += " SUM(B6_SALDO) B6_SALDO"	
			cQuery += " FROM  SB6010 SB6  INNER JOIN  SD2010 SD2 ON (SD2.D2_FILIAL=SB6.B6_FILIAL AND SD2.D2_DOC=SB6.B6_DOC AND SD2.D2_SERIE=SB6.B6_SERIE AND SD2.D2_CLIENTE=SB6.B6_CLIFOR AND SD2.D2_LOJA=SB6.B6_LOJA AND SD2.D2_COD=SB6.B6_PRODUTO AND  SD2.D_E_L_E_T_<>'*')  " 
			cQuery += " INNER JOIN  SC5010 SC5 ON (SD2.D2_PEDIDO=SC5.C5_NUM and SD2.D2_FILIAL=SC5.C5_FILIAL AND  SD2.D_E_L_E_T_<>'*')  " 
			cQuery += " INNER JOIN  SA1010 SA1 ON (SC5.C5_CLIENTE=SA1.A1_COD AND SC5.C5_LOJACLI=SA1.A1_LOJA AND SA1.D_E_L_E_T_<>'*') " 
			cQuery += " INNER JOIN  SA3010 SA3 ON (SA3.A3_COD=SC5.C5_VEND1 AND SA3.D_E_L_E_T_<>'*')  "  
			cQuery += " JOIN  SB1010 SB1 ON (SB6.B6_PRODUTO=SB1.B1_COD AND  SB1.D_E_L_E_T_<>'*')  "  
			cQuery += " JOIN  SF4010 SF4 ON (SB6.B6_FILIAL=SF4.F4_FILIAL AND SB6.B6_TES=SF4.F4_CODIGO AND SF4.D_E_L_E_T_<>'*') "
			cQuery += " LEFT OUTER JOIN  ZA3010 ZA3 ON ( SB6.B6_FILIAL=ZA3.ZA3_FILIAL AND SB6.B6_CLIFOR=ZA3.ZA3_FORNEC "
			cQuery += " AND SB6.B6_LOJA=ZA3.ZA3_LOJA AND SB6.B6_PRODUTO=ZA3.ZA3_COD AND SD2.D2_LOTECTL=ZA3.ZA3_LOTECT "
			cQuery += " AND SA3.A3_COD=ZA3.ZA3_VENDED) "
			cQuery += " WHERE SB6.B6_DOC >= '' "
			cQuery += " AND SB6.B6_DOC <= 'ZZZZZZZZZ' "
			cQuery += " AND SB6.B6_SERIE   	 >= '' "
			cQuery += " AND SB6.B6_SERIE   	 <= 'ZZZ' "
			cQuery += " AND SB6.B6_PRODUTO 	 >= '' "
			cQuery += " AND SB6.B6_PRODUTO 	 <= 'ZZZZZZZZZZZ' "
			cQuery += " AND SB6.B6_SALDO>0
			cQuery += " AND SA3.A3_COD         >= '' "
			cQuery += " AND SA3.A3_COD  	     <= 'ZZZZZZ' "
			cQuery += " AND B6_TPCF			  = 'C' "
			cQuery += " AND B6_SALDO>0 "
			cQuery += " AND SB6.B6_TIPO		  = 'E'    "
			cQuery += " AND SB6.D_E_L_E_T_	 <> '*'    "
			cQuery += " AND F4_CODIGO IN ('722','697') "
			cQuery += " AND A1_COD    = '" + AllTrim(oJson:ZA3_FORNEC)+"'"  
			cQuery += " AND A1_LOJA   = '" + AllTrim(oJson:ZA3_LOJA)+"'"  
			cQuery += " AND ZA3.ZA3_FILIAL IS NULL "
			cQuery += " GROUP BY 
			cQuery += " B6_FILIAL,  "
			cQuery += " B6_LOCAL,   "
			cQuery += " B1_TIPO,    "
			cQuery += " ZA3_FILIAL, "
			cQuery += " B6_CLIFOR,  "
			cQuery += " B6_LOJA,    "
			cQuery += " B6_PRODUTO, "
			cQuery += " D2_LOTECTL, "
			cQuery += " D2_NUMSERI, "
	 		cQuery += " D2_LOCALIZ, "
			cQuery += " D2_DTVALID, "
			cQuery += " A3_COD      "
	   					
			MEMOWRITE("ZERADOSZA3.SQL",cQuery)
	   		cQuery := ChangeQuery( cQuery )
	   		dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T. )
			ConOut('ZZ04')
            While ( cAliasT )->( !Eof() )		
		
		    	ConOut('ZZ05')
				dbSelectArea('ZA3')
		    	// Inicia a gravacao caso a tabela esteja disponivel 
				If RecLock('ZA3', .t.)
					ZA3->ZA3_FILIAL   := AllTrim(oJson:ZA3_FILIAL)	         //(04) Filial 
					ZA3->ZA3_COD      := AllTrim(( cAliasT )->B6_PRODUTO)    //(20) Codigo do produto 
					ZA3->ZA3_LOCAL    := AllTrim(( cAliasT )->B6_LOCAL) 	 //(02) Armazem 
					ZA3->ZA3_TIPO     := AllTrim(( cAliasT )->B1_TIPO) 	     //(02) Tipo do Produto
					ZA3->ZA3_DOC      := AllTrim(oJson:ZA3_DOC) 	         //(09) Documento 
					ZA3->ZA3_QUANT    := Val("0") 	                         //(09) Quatidade 
					ZA3->ZA3_DATA     := StoD(AllTrim(oJson:ZA3_DATA)) 	     //(08) Data da leitura Ex: 20200430 
					ZA3->ZA3_LOTECT   := AllTrim(( cAliasT )->D2_LOTECTL)  	 //(30) Lote
					ZA3->ZA3_NUMSER   := AllTrim(( cAliasT )->D2_NUMSERI)    //(20) Numero de Sere
					ZA3->ZA3_LOCALI   := AllTrim(( cAliasT )->D2_LOCALIZ)    //(15) Endereco
					ZA3->ZA3_DTVALI   := StoD(( cAliasT )->D2_DTVALID)       //(08) Data da leitura Ex: 20200430
					ZA3->ZA3_VENDED   := AllTrim(oJson:ZA3_VENDED) 	         //(06) Codigo do Vendedor
					ZA3->ZA3_LONG     := AllTrim(oJson:ZA3_LONG)  	         //(25) Longitude
					ZA3->ZA3_LATI     := AllTrim(oJson:ZA3_LATI) 	         //(25) Latitude
					ZA3->ZA3_FORNEC   := AllTrim(oJson:ZA3_FORNEC) 	         //(06) Cliente/Fornecedor
					ZA3->ZA3_LOJA     := AllTrim(oJson:ZA3_LOJA)	         //(04) Loja cliente/Loja Fornecedor
					ZA3->ZA3_IDINV    := AllTrim(oJson:ZA3_IDINV)	         //(04) Identificador Inventario
					ZA3->ZA3_SLDSB6   := ( cAliasT )->B6_SALDO	            //(09) Saldo em poder de 3 (Fiscal)
			    EndIf
		           MsUnLock()
				   ( "ZA3")->( dbCloseArea() )	
			       ( cAliasT )->( dbSkip() ) 
			EndDo
			::SetResponse('{')
			::SetResponse('"Retorno"')
			::SetResponse(':')
			::SetResponse('"')
			::SetResponse('OK')
			::SetResponse('"')
			::SetResponse('}')
		    ConOut('ZZ06')	
		Endif	
		 ( cAliasT )->( dbCloseArea() )	 		
	EndIf
Return( lOk )
