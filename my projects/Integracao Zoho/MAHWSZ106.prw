#Include "TOTVS.CH"
#Include "RESTFUL.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � MAHWSZ106 � Autor � Ednei R. Silva       � Data � MAI/2021 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Servico Web service  Saldo por Lote.       				  ���
���          � 		     	                                              ���
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

WSRESTFUL MAHSLDLOTE DESCRIPTION "Saldos por Lote"

	WSDATA B8_FILIAL    AS STRING
	WSDATA B8_PRODUTO   AS STRING
	WSDATA B8_LOCAL     AS STRING
	WSDATA B6_LOTE      AS STRING
	

	WSMETHOD GET DESCRIPTION "Saldos OPME" WSSYNTAX "/MAHSLDLOTE" 
 
END WSRESTFUL


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � GET      � Autor � Ednei R. Silva        � Data � MAI/2021 ���
�������������������������������������������������������������������������͹��
���Desc.     � Metodo para listar Saldo por lote         Protheus.        ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
WSMETHOD GET WSRECEIVE B8_FILIAL,B8_PRODUTO,B8_LOCAL,B6_LOTE WSSERVICE MAHSLDLOTE

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
	
	aAdd(aCampo, {"B8_FILIAL",                "FILIAL"})	
	aAdd(aCampo, {"B8_LOCAL",                 "LOCAL"})
	aAdd(aCampo, {"B8_PRODUTO",               "PRODUTO"})	
	aAdd(aCampo, {"B1_DESC",                  "DESCRICAO"})
	aAdd(aCampo, {"B8_LOTECTL",               "LOTE"})	
	aAdd(aCampo, {"B8_DTVALID",               "VALIDADE"})
	aAdd(aCampo, {"SUM(B8_SALDO-B8_EMPENHO)", "SALDO"})
	
	
	nCampo := Len(aCampo)
		
	cQuery := " SELECT "
	aEval( aCampo, { |Z| nX++, cQuery += Z[1] +" "+ Z[2] + IIf( nX < nCampo, ', ', '') } )
	cQuery += " FROM " + RetSQLName("SB8")+ " SB8 " 
	cQuery += " INNER JOIN " + RetSQLName("SB1")+ " SB1 ON (SB8.B8_PRODUTO=SB1.B1_COD) "	
	cQuery += " WHERE SB8.D_E_L_E_T_ <> '*'"
	cQuery += " AND SB1.D_E_L_E_T_ <> '*'"
	cQuery += " AND SB8.B8_SALDO<>0  "
	
	
	If !Empty( ::B8_FILIAL ) .and. !Empty( ::B8_PRODUTO) .and. !Empty( ::B8_LOCAL ) 

		cQuery += "   AND SB8.B8_FILIAL  = '"+ Upper( ::B8_FILIAL ) +"'"
        cQuery += "   AND SB8.B8_PRODUTO = '"+ Upper( ::B8_PRODUTO ) +"'"
		cQuery += "   AND SB8.B8_LOCAL   = '"+ Upper( ::B8_LOCAL ) +"'"
		IF !Empty( ::B6_LOTE)
      		cQuery += "   AND SB8.B8_LOTECTL   = '"+ Upper( ::B8_LOTE ) +"'"
	    Endif

	ELSE
        
		 IF !Empty( ::B6_LOTE)
      
	       cQuery += "   AND SB8.B8_LOTECTL   = '"+ Upper( ::B8_LOTE ) +"'"
	    else 
		   cQuery += "   AND SB8.B8_PRODUTO ='NAO BUSCAR NADA' "
        endif

	Endif
    
	cQuery += " GROUP BY B8_FILIAL, B8_LOCAL, B8_PRODUTO,B1_DESC, B8_LOTECTL, B8_DTVALID "

	cQuery := ChangeQuery(cQuery)				
	dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQuery), (cArea := GetNextAlias()), .F., .T. )
	
	Count To nReg		

	If nReg == 0

		lOk := .F.
		SetRestFault( 1, "Nenhum registro a ser exibido." )
	ELse
	
		dbSelectArea(cArea)
		dbGoTop()

		::SetResponse('{"SALDO_LOTE": [')

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

