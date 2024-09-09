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
±±³Funcao    ³ MAHTRG10 ³ Autor ³ Ednei R. Silva      ³ Data ³ MAR/2020   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ WS para inclusao de leitura de inventario.                 ³±±
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
WSRESTFUL MAHADINV DESCRIPTION "Inventario Online" 


WSDATA ZA3_FILIAL   AS STRING 	//(04) Filial 
WSDATA ZA3_COD      AS STRING 	//(20) Codigo do produto 
WSDATA ZA3_LOCAL    AS STRING 	//(02) Armazem 
WSDATA ZA3_TIPO     AS STRING 	//(02) Tipo do Produto
WSDATA ZA3_DOC      AS STRING 	//(09) Documento 
WSDATA ZA3_QUANT    AS STRING 	//(09) Quatidade 
WSDATA ZA3_DATA     AS STRING 	//(08) Data da leitura Ex: 20200430 
WSDATA ZA3_LOTECT   AS STRING 	//(30) Lote
WSDATA ZA3_NUMSER   AS STRING 	//(20) Numero de Sere
WSDATA ZA3_LOCALI   AS STRING 	//(15) Endereco
WSDATA ZA3_DTVALI   AS STRING 	//(08) Data da leitura Ex: 20200430
WSDATA ZA3_VENDED   AS STRING 	//(06) Codigo do Vendedor
WSDATA ZA3_LONG     AS STRING 	//(25) Longitude
WSDATA ZA3_LATI     AS STRING 	//(25) Latitude
WSDATA ZA3_FORNEC   AS STRING 	//(06) Cliente/Fornecedor
WSDATA ZA3_LOJA     AS STRING 	//(04) Loja cliente/Loja Fornecedor
WSDATA ZA3_IDINV    AS STRING 	//(80) Identificador Inventario
WSDATA ZA3_NUMDOC   AS STRING 	//(09) Identificador Inventario	
WSDATA ZA3_SERIE    AS STRING 	//(3) Identificador Inventario			
	
WSMETHOD POST DESCRIPTION "Inventario Online" WSSYNTAX "/" 
	
END WSRESTFUL



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ POST     ºAutor  ³ Ednei Silva        º Data ³  Ago/2017   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Metodo para incluir inventario Online.                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MA Hospitalar                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
WSMETHOD POST WSRECEIVE NULLPARAM WSSERVICE MAHADINV

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
		
		If Empty( oJson:ZA3_COD )
			lOk := .F.	 				
	 		SetRestFault( 3, "Campo obrigatorio: Codigo do Produto" )
		Endif  
		
		If Empty( oJson:ZA3_LOCAL )
		    lOk := .F.	 				
	 		SetRestFault( 4, "Campo obrigatorio: Armazem" )
		Endif 
		 
		If Empty( oJson:ZA3_QUANT ) 
		    lOk := .F.	 				
	 		SetRestFault( 5, "Campo obrigatorio: Quantidade." )
		Endif 	
		
		If Empty( oJson:ZA3_DATA ) 
			lOk := .F.	 				
	 		SetRestFault( 6, "Campo obrigatorio: Data Leitura." )
		Endif 
		
		If Empty( oJson:ZA3_LOTECT ) 
		    lOk := .F.	 				
	 		SetRestFault( 7, "Campo obrigatorio: Lote." )
		Endif 
		If Empty( oJson:ZA3_DTVALI )
			lOk := .F.	 				
	 		SetRestFault( 8, "Campo obrigatorio: Validade." )
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
	 	
	   cQuery := " SELECT Count(*) AS EXISTE "
	   cQuery += " FROM " + RetSQLName("ZA3")
	   cQuery += " WHERE ZA3_FILIAL  = '" + AllTrim(oJson:ZA3_FILIAL)+"'"
	   cQuery += "   AND ZA3_COD     = '" + AllTrim(oJson:ZA3_COD)  +"'"
       cQuery += "   AND ZA3_LOCAL   = '" + AllTrim(oJson:ZA3_LOCAL)+"'"
       cQuery += "   AND ZA3_TIPO    = '" + AllTrim(oJson:ZA3_TIPO) +"'"
       cQuery += "   AND ZA3_DOC     = '" + AllTrim(oJson:ZA3_DOC)  +"'"
       cQuery += "   AND ZA3_QUANT   = "  + AllTrim(oJson:ZA3_QUANT)
       cQuery += "   AND ZA3_DATA    = '" + AllTrim(oJson:ZA3_DATA)  +"'"
       cQuery += "   AND ZA3_LOTECT  = '" + AllTrim(oJson:ZA3_LOTECT)+"'"
       cQuery += "   AND ZA3_NUMSER  = '" + AllTrim(oJson:ZA3_NUMSER)+"'"
       cQuery += "   AND ZA3_LOCALI  = '" + AllTrim(oJson:ZA3_LOCALI)+"'"
       cQuery += "   AND ZA3_DTVALI  = '" + AllTrim(oJson:ZA3_DTVALI)+"'"
       cQuery += "   AND ZA3_VENDED  = '" + AllTrim(oJson:ZA3_VENDED)+"'"
       cQuery += "   AND ZA3_FORNEC  = '" + AllTrim(oJson:ZA3_FORNEC)+"'"
       cQuery += "   AND ZA3_LOJA    = '" + AllTrim(oJson:ZA3_LOJA)+"'"
       cQuery += "   AND ZA3_IDINV   = '" + AllTrim(oJson:ZA3_IDINV)+"'"
	   cQuery += "   AND ZA3_NUMDOC  = '" + AllTrim(oJson:ZA3_NUMDOC)+"'"
	   cQuery += "   AND ZA3_SERIE   = '" + AllTrim(oJson:ZA3_SERIE)+"'"
	   ZA3_NUMDOC  
	   cQuery += "   AND D_E_L_E_T_<>'*'"
		MEMOWRITE("ZA3COMPARA.SQL",cQuery)
	   cQuery := ChangeQuery( cQuery )
	   dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T. )
		ConOut('ZZ04')
		If ( cAliasT )->EXISTE > 0
		
	        lOk := .F.	 				
	 		SetRestFault( 14, "Registro Duplicado: Produto - "+AllTrim(oJson:ZA3_COD) + " e Lote: " + AllTrim(oJson:ZA3_LOTECT) )	
			
		Else
		    ConOut('ZZ05')
		    dbSelectArea('ZA3')
		    // Inicia a gravacao caso a tabela esteja disponivel 
			If RecLock('ZA3', .t.)
				ZA3->ZA3_FILIAL   := AllTrim(oJson:ZA3_FILIAL)	//(04) Filial 
				ZA3->ZA3_COD      := AllTrim(oJson:ZA3_COD)		//(20) Codigo do produto 
				ZA3->ZA3_LOCAL    := AllTrim(oJson:ZA3_LOCAL) 	//(02) Armazem 
				ZA3->ZA3_TIPO     := AllTrim(oJson:ZA3_TIPO) 	//(02) Tipo do Produto
				ZA3->ZA3_DOC      := AllTrim(oJson:ZA3_DOC) 	//(09) Documento 
				ZA3->ZA3_QUANT    := Val(AllTrim(oJson:ZA3_QUANT)) 	//(09) Quatidade 
				ZA3->ZA3_DATA     := StoD(AllTrim(oJson:ZA3_DATA)) 	//(08) Data da leitura Ex: 20200430 
				ZA3->ZA3_LOTECT   := AllTrim(oJson:ZA3_LOTECT) 	//(30) Lote
				ZA3->ZA3_NUMSER   := AllTrim(oJson:ZA3_NUMSER)  //(20) Numero de Sere
				ZA3->ZA3_LOCALI   := AllTrim(oJson:ZA3_LOCALI)  //(15) Endereco
				ZA3->ZA3_DTVALI   := StoD(AllTrim(oJson:ZA3_DTVALI))  //(08) Data da leitura Ex: 20200430
				ZA3->ZA3_VENDED   := AllTrim(oJson:ZA3_VENDED) 	//(06) Codigo do Vendedor
				ZA3->ZA3_LONG     := AllTrim(oJson:ZA3_LONG)  	//(25) Longitude
				ZA3->ZA3_LATI     := AllTrim(oJson:ZA3_LATI) 	//(25) Latitude
				ZA3->ZA3_FORNEC   := AllTrim(oJson:ZA3_FORNEC) 	//(06) Cliente/Fornecedor
				ZA3->ZA3_LOJA     := AllTrim(oJson:ZA3_LOJA)	//(04) Loja cliente/Loja Fornecedor
			    ZA3->ZA3_IDINV    := AllTrim(oJson:ZA3_IDINV)	//(04) Identificador Inventario
				ZA3->ZA3_NUMDOC   := AllTrim(oJson:ZA3_NUMDOC)	//(04) Identificador Inventario
				ZA3->ZA3_SERIE    := AllTrim(oJson:ZA3_SERIE)	//(04) Identificador Inventario
			    ::SetResponse('{')
				::SetResponse('"B7_COD"')
				::SetResponse(':')
				::SetResponse('"')
				::SetResponse( oJson:ZA3_COD)
				::SetResponse('"')
				::SetResponse(',')
				::SetResponse('"B7_LOCAL"')
				::SetResponse(':')
				::SetResponse('"')
				::SetResponse( oJson:ZA3_LOCAL)
				::SetResponse('"')
				::SetResponse(',')
				::SetResponse('"B7_LOTECTL"')
				::SetResponse(':')
				::SetResponse('"')
				::SetResponse( oJson:ZA3_LOTECT)
				::SetResponse('"')
				::SetResponse(',')
				::SetResponse('"B7_DATA"')
				::SetResponse(':')
				::SetResponse('"')
				::SetResponse( oJson:ZA3_DATA)
				::SetResponse('"')
				::SetResponse(',')
				::SetResponse('"B7_DTVALI"')
				::SetResponse(':')
				::SetResponse('"')
				::SetResponse( oJson:ZA3_DTVALI)
				::SetResponse('"')
				::SetResponse(',')
				::SetResponse('"B7_VENDED"')
				::SetResponse(':')
				::SetResponse('"')
				::SetResponse( oJson:ZA3_VENDED)
				::SetResponse('"')
				::SetResponse(',')
				::SetResponse('"B7_FILIAL"')
				::SetResponse(':')
				::SetResponse('"')
				::SetResponse( oJson:ZA3_FILIAL  )
				::SetResponse('"')
				::SetResponse('}')
		    EndIf
		MsUnLock()
		ConOut('ZZ06')	
		Endif	
		 ( cAliasT )->( dbCloseArea() )	 		
		 dbCloseArea("ZA3") 
		EndIf
	EndIf
	
Return( lOk )
