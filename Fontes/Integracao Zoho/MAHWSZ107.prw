#Include "TOTVS.CH"
#Include "RESTFUL.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MAHWSZ107 ³ Autor ³ Ednei R. Silva       ³ Data ³ JUN/2021 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Servico Web service  Analise de Inventario.       	      ³±±
±±³          ³ 		     	                                              ³±±
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

WSRESTFUL MAHSLDINV DESCRIPTION "Saldos por Lote"

	WSDATA ZA3_FORNEC    AS STRING
	WSDATA ZA3_LOJA       AS STRING

	WSMETHOD GET DESCRIPTION "Saldos OPME" WSSYNTAX "/MAHSLDLOTE" 
 
END WSRESTFUL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ GET      ³ Autor ³ Ednei R. Silva        ³ Data ³ JUN/2021 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Metodo para listar Analise de Inventario    Protheus.      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
WSMETHOD GET WSRECEIVE ZA3_FORNEC ,ZA3_LOJA WSSERVICE MAHSLDINV

	Local cQuery	:= ""
	Local cArea		:= ""
	Local aCampo	:= {}
	Local nX		:= 0
	Local nCount	:= 0
	Local nReg		:= 0
	Local nCampo	:= 0
	Local lOk		:= .T.	
	 


	cQuery += " FROM ZA3010  ZA3 "
    cQuery += " INNER JOIN SB1010 SB1 ON (ZA3.ZA3_COD=SB1.B1_COD AND SB1.D_E_L_E_T_<>'*') "
    cQuery += " INNER JOIN (SELECT  " 	 
	cQuery += " ZA3_FILIAL,  "
	cQuery += " ZA3_COD, "      
	cQuery += " MAX(ZA3_DATA) ZA3_DATA, "  
	cQuery += " ZA3_LOTECT, "
	cQuery += " ZA3_NUMSER, " 
	cQuery += " ZA3_LOCAL, "
	cQuery += " ZA3_DTVALI, "
	cQuery += " ZA3_FORNEC, "
	cQuery += " ZA3_LOJA,   "
	cQuery += " ZA3_VENDED, "
	cQuery += " MAX(ZA3.R_E_C_N_O_) ZA3_ID  "
	cQuery += " FROM ZA3010  ZA3  "
    cQuery += " WHERE ZA3.D_E_L_E_T_<>'*' "
    cQuery += " GROUP BY "
	cQuery += " ZA3_FILIAL,  "
	cQuery += " ZA3_COD,  "  
	cQuery += " ZA3_DOC, "
	cQuery += " ZA3_LOTECT,  "
	cQuery += " ZA3_NUMSER,  "
	cQuery += " ZA3_LOCAL,  "
	cQuery += " ZA3_DTVALI,  "
	cQuery += " ZA3_FORNEC, "
	cQuery += " ZA3_LOJA,   "
	cQuery += " ZA3_VENDED) AS GZA3   " 
	cQuery += " ON (GZA3.ZA3_FILIAL=ZA3.ZA3_FILIAL AND  "
	cQuery += " GZA3.ZA3_COD=ZA3.ZA3_COD AND   "
	cQuery += " GZA3.ZA3_LOTECT= ZA3.ZA3_LOTECT AND "
	cQuery += " GZA3.ZA3_NUMSER = ZA3.ZA3_NUMSER AND  "
	cQuery += " GZA3.ZA3_LOCAL = ZA3.ZA3_LOCAL AND "
	cQuery += " GZA3.ZA3_DTVALI = ZA3.ZA3_DTVALI AND "
	cQuery += " GZA3.ZA3_FORNEC = ZA3.ZA3_FORNEC AND "
	cQuery += " GZA3.ZA3_LOJA = ZA3.ZA3_LOJA AND "
	cQuery += " GZA3.ZA3_DATA = ZA3.ZA3_DATA AND "
	cQuery += " GZA3.ZA3_ID = ZA3.R_E_C_N_O_)	"


	// Define o tipo de retorno do metodo
	::SetContentType("application/json")
	
    
    aAdd(aCampo, {"ZA3.ZA3_FILIAL",           "FILIAL"})	
	aAdd(aCampo, {"ZA3.ZA3_COD",              "PRODUTO"})
	aAdd(aCampo, {"B1_TIPO",                  "TIPO"})	
	aAdd(aCampo, {"B1_GRUPO",                 "GRUPO"})
	aAdd(aCampo, {"B1_MARCA",                 "MARCA"})	
	aAdd(aCampo, {"ZA3.ZA3_DOC",              "DOCUMENTO"})
	aAdd(aCampo, {"ZA3.ZA3_QUANT",            "QUANTIDADE"})
	aAdd(aCampo, {"ZA3.ZA3_DATA",             "DATA"})
    aAdd(aCampo, {"ZA3.ZA3_LOTECT",           "LOTE"})
    aAdd(aCampo, {"ZA3.ZA3_NUMSER",           "NUMERO_SERIE"})
    aAdd(aCampo, {"ZA3.ZA3_LOCAL",            "LOCAL"})
    aAdd(aCampo, {"ZA3.ZA3_DTVALI",           "VALIDAE"})
    aAdd(aCampo, {"ZA3.ZA3_FORNEC",           "CLIENTE"})
    aAdd(aCampo, {"ZA3.ZA3_LOJA",             "LOJA"})
    aAdd(aCampo, {"ZA3.ZA3_VENDED",           "VENDEDOR"})
    aAdd(aCampo, {"ZA3.ZA3_LONG",             "LONGITUDE"})
    aAdd(aCampo, {"ZA3.ZA3_LATI",             "LATITUDE"})
    aAdd(aCampo, {"ZA3.ZA3_IDINV",            "IDINV"})
    aAdd(aCampo, {"ZA3.ZA3_SLDSB6",           "SALDO3"})
    aAdd(aCampo, {"ZA3.R_E_C_N_O_",           "IDREGISTRO"})
	
	nCampo := Len(aCampo)
		
	cQuery := " SELECT "
	aEval( aCampo, { |Z| nX++, cQuery += Z[1] +" "+ Z[2] + IIf( nX < nCampo, ', ', '') } )
	cQuery += " FROM " + RetSQLName("ZA3")+ " ZA3 " 
	cQuery += " INNER JOIN SB1010 SB1 ON (ZA3.ZA3_COD=SB1.B1_COD AND SB1.D_E_L_E_T_<>'*') "
    cQuery += " INNER JOIN (SELECT  " 	 
	cQuery += " ZA3_FILIAL,  "
	cQuery += " ZA3_COD, "      
	cQuery += " MAX(ZA3_DATA) ZA3_DATA, "  
	cQuery += " ZA3_LOTECT, "
	cQuery += " ZA3_NUMSER, " 
	cQuery += " ZA3_LOCAL,  "
	cQuery += " ZA3_DTVALI, "
	cQuery += " ZA3_FORNEC, "
	cQuery += " ZA3_LOJA,   "
	cQuery += " ZA3_VENDED, "
	cQuery += " MAX(ZA3.R_E_C_N_O_) ZA3_ID  "
	cQuery += " FROM ZA3010  ZA3  "
    cQuery += " WHERE ZA3.D_E_L_E_T_<>'*' "
    If !Empty( ::ZA3_FORNEC ) .and. !Empty( ::ZA3_LOJA ) 
        cQuery += "   AND ZA3.ZA3_FORNEC   = '"+ Upper( ::ZA3_FORNEC  ) +"'"
        cQuery += "   AND ZA3.ZA3_LOJA     = '"+ Upper( ::ZA3_LOJA  ) +"'"
    EndIf
    cQuery += " GROUP BY "
	cQuery += " ZA3_FILIAL,  "
	cQuery += " ZA3_COD,  "  
	cQuery += " ZA3_DOC, "
	cQuery += " ZA3_LOTECT,  "
	cQuery += " ZA3_NUMSER,  "
	cQuery += " ZA3_LOCAL,  "
	cQuery += " ZA3_DTVALI,  "
	cQuery += " ZA3_FORNEC, "
	cQuery += " ZA3_LOJA,   "
	cQuery += " ZA3_VENDED) AS GZA3   " 
	cQuery += " ON (GZA3.ZA3_FILIAL=ZA3.ZA3_FILIAL AND  "
	cQuery += " GZA3.ZA3_COD=ZA3.ZA3_COD AND   "
	cQuery += " GZA3.ZA3_LOTECT= ZA3.ZA3_LOTECT AND "
	cQuery += " GZA3.ZA3_NUMSER = ZA3.ZA3_NUMSER AND  "
	cQuery += " GZA3.ZA3_LOCAL = ZA3.ZA3_LOCAL AND "
	cQuery += " GZA3.ZA3_DTVALI = ZA3.ZA3_DTVALI AND "
	cQuery += " GZA3.ZA3_FORNEC = ZA3.ZA3_FORNEC AND "
	cQuery += " GZA3.ZA3_LOJA = ZA3.ZA3_LOJA AND "
	cQuery += " GZA3.ZA3_DATA = ZA3.ZA3_DATA AND "
	cQuery += " GZA3.ZA3_ID = ZA3.R_E_C_N_O_)	"

    

	cQuery := ChangeQuery(cQuery)				
	dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQuery), (cArea := GetNextAlias()), .F., .T. )
	
	Count To nReg		

	If nReg == 0

		lOk := .F.
		SetRestFault( 1, "Nenhum registro a ser exibido." )
	ELse
	
		dbSelectArea(cArea)
		dbGoTop()

		::SetResponse('{"ANALISE_INV": [')

		While (cArea)->( !Eof() )
		
			nCount++

			::SetResponse('{')
			
			nX := 0
			For nX := 1 To nCampo
			
				::SetResponse('"')
				::SetResponse(aCampo[nX][1]) 
				::SetResponse('"')
				::SetResponse(':')
				::SetResponse('"')
				
				If aCampo[nX][1] $ "B1_DESC"
					::SetResponse( U_NoCharEsp( AllTrim( cValToChar( (cArea)->&(aCampo[nX][2]) ) ) ) )
				Else
					::SetResponse( AllTrim( cValToChar( (cArea)->&(aCampo[nX][2]) ) ) )
				EndIf 
				
				::SetResponse('"')				
				
				If nX < nCampo 
					::SetResponse(',')
				EndIf
							
			Next nX
			
			::SetResponse('}')

			If nCount < nReg
			 	::SetResponse(',')
			EndIf	
	
			(cArea)->( dbSkip() )
	  			
		EndDo
	
		::SetResponse(']}')
		
		(cArea)->( dbCloseArea() )
		
	EndIf
		
Return( lOk )
