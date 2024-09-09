#Include "TOTVS.CH"
#Include "RESTFUL.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � MAHWS010 � Autor � Ednei R. Silva        � Data � OUT/2020 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Servico Web service para integracao Protheus X Zoho.       ���
���          � Saldos OPME.                                               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico MA Hospitalar                                   ���
�������������������������������������������������������������������������Ĵ��
���                          ULTIMAS ALTERACOES                           ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � Motivo da Alteracao                             ���
�������������������������������������������������������������������������Ĵ��
���															              ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/

WSRESTFUL MAHSLDOP DESCRIPTION "Saldos OPME"

	WSDATA B6_CLIFOR    AS STRING
	WSDATA B6_LOJA      AS STRING
	WSDATA B6_LIKEPRO   AS STRING
	WSDATA B6_LIKELOTE  AS STRING
	WSDATA B6_CNPJ      AS STRING
	WSDATA B6_NOTA      AS STRING
	WSDATA B6_SERIE     AS STRING
	WSDATA B6_TEMPPRO   AS STRING

	WSMETHOD GET DESCRIPTION "Saldos OPME" WSSYNTAX "/MAHSLDOP" 
 
END WSRESTFUL


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � GET      � Autor � Ednei R. Silva        � Data � MAR/2020 ���
�������������������������������������������������������������������������͹��
���Desc.     � Metodo para listar Cliente                Protheus.        ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
WSMETHOD GET WSRECEIVE B6_CLIFOR, B6_LOJA, B6_LIKEPRO, B6_LIKELOTE,B6_SERIE,B6_NOTA,B6_CNPJ,B6_TEMPPRO WSSERVICE MAHSLDOP

	Local cQuery	:= ""
	Local cArea		:= ""
	Local aCampo	:= {}
	Local nX		:= 0
	Local nCount	:= 0
	Local nReg		:= 0
	Local nCampo	:= 0
	Local lOk		:= .T.	
	 
	 
	// Define o tipo de retorno do metodo
	::SetContentType("application/json")
	
	aAdd(aCampo, {"A1_COD",     "CODIGO"})	
	aAdd(aCampo, {"A1_LOJA",    "LOJA"})
	aAdd(aCampo, {"A1_CGC",     "CNPJ"})	
	aAdd(aCampo, {"B6_DOC",     "NF"})	
	aAdd(aCampo, {"B6_SERIE",   "SERIE"})
	aAdd(aCampo, {"B6_PRODUTO", "PRODUTO"})
	aAdd(aCampo, {"D2_LOTECTL", "LOTE"})
	aAdd(aCampo, {"B6_SALDO",   "SALDO"})
	aAdd(aCampo, {"F4_CODIGO",  "TES"})		
	aAdd(aCampo, {"D2_DTVALID",  "VALIDADE"})
	aAdd(aCampo, {"B1_DESC",     "DESCRICAO"})	
	nCampo := Len(aCampo)
		
	cQuery := " SELECT "
	aEval( aCampo, { |Z| nX++, cQuery += Z[1] +" "+ Z[2] + IIf( nX < nCampo, ', ', '') } )
	cQuery += " FROM " + RetSQLName("SB6")+ " SB6 " 	
	cQuery += " INNER JOIN  " + RetSQLName("SD2") + " SD2 ON (SD2.D2_DOC=SB6.B6_DOC AND SD2.D2_SERIE=SB6.B6_SERIE AND SD2.D2_CLIENTE=SB6.B6_CLIFOR    AND SD2.D2_LOJA=SB6.B6_LOJA AND SD2.D2_IDENTB6=SB6.B6_IDENT AND SD2.D_E_L_E_T_<>'*')  "  
	cQuery += " INNER JOIN  " + RetSQLName("SC5") + " SC5 ON (SD2.D2_PEDIDO=SC5.C5_NUM and SD2.D2_FILIAL=SC5.C5_FILIAL AND  SD2.D_E_L_E_T_<>'*') "    
	cQuery += " INNER JOIN  " + RetSQLName("SA1") + " SA1 ON (SC5.C5_CLIENTE=SA1.A1_COD AND SC5.C5_LOJACLI=SA1.A1_LOJA AND SA1.D_E_L_E_T_<>'*') "   
	cQuery += " INNER JOIN  " + RetSQLName("SA3") + " SA3 ON (SA3.A3_COD=SC5.C5_VEND1 AND SA3.D_E_L_E_T_<>'*') "    
	cQuery += " INNER JOIN  " + RetSQLName("SF4") + " SF4 ON (SB6.B6_FILIAL=SF4.F4_FILIAL AND SB6.B6_TES=SF4.F4_CODIGO AND SF4.D_E_L_E_T_<>'*') "
	cQuery += " INNER JOIN  " + RetSQLName("SB1") + " SB1 ON (SB1.B1_COD=SB6.B6_PRODUTO AND SB1.D_E_L_E_T_<>'*') "  
	cQuery += " WHERE SB6.D_E_L_E_T_ <> '*'"
	cQuery += " AND SB6.B6_SALDO>0  "
	
	If !Empty( ::B6_CLIFOR ) 

		cQuery += "   AND SB6.B6_CLIFOR = '"+ Upper( ::B6_CLIFOR ) +"'"
		
		If !Empty( ::B6_LOJA ) 
			cQuery += "   AND SB6.B6_LOJA = '"+ Upper( ::B6_LOJA ) +"'"
		EndIf
		
	EndIf
    
    If !Empty( ::B6_LIKEPRO )
    	cQuery += " AND SB6.B6_PRODUTO IN ("+ AllTrim( ::B6_LIKEPRO ) +") "
    Endif


	If !Empty( ::B6_LIKELOTE )
    	cQuery += " AND SD2.D2_LOTECTL IN ("+ AllTrim( ::B6_LIKELOTE ) +") "
    Endif
 
    If !Empty( ::B6_CNPJ )
    	cQuery += " AND SA1.A1_CGC = '"+ Upper( ::B6_CNPJ ) +"'"
    Endif

    If !Empty( ::B6_NOTA )
    	cQuery += " AND SB6.B6_DOC = '"+ Upper( ::B6_NOTA ) +"'"
    Endif

    If !Empty( ::B6_SERIE )
    	cQuery += " AND SB6.B6_SERIE = '"+ Upper( ::B6_SERIE ) +"'"
    Endif

    If ::B6_TEMPPRO ='Temporario'
       cQuery += " AND SB6.B6_TES IN ('697')  "
    Endif
	If ::B6_TEMPPRO ='Permanente'
       cQuery += " AND SB6.B6_TES IN ('722')  "
    Endif

	If ::B6_TEMPPRO ='Ambos'
       cQuery += " AND SB6.B6_TES IN ('697','722')  "
    Endif
	

    

	cQuery := ChangeQuery(cQuery)				
	dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQuery), (cArea := GetNextAlias()), .F., .T. )
	
	Count To nReg		

	If nReg == 0
	
		lOk := .F.
		SetRestFault( 1, "Nenhum registro a ser exibido." )
	ELse
	
		dbSelectArea(cArea)
		dbGoTop()

		::SetResponse('{"OPME": [')

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
				
				If aCampo[nX][1] $ "A1_XXX"
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

