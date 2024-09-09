#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � MAHWS010 � Autor � Ednei R. Silva        � Data � MAR/2020 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Servico Web service para integracao Protheus X Zoho.       ���
���          � Cadastro de Condicao de Pagamento.                                       ���
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

WSRESTFUL MAHCONDPAG DESCRIPTION "Cadastro de Condicao de Pagamento"

	WSDATA E4_CODIGO AS STRING
	WSDATA E4_DTHDE AS STRING 
	WSDATA E4_DTHATE AS STRING 
	

	WSMETHOD GET DESCRIPTION "Listar Cadastro de Condicao de Pagamento" WSSYNTAX "/MAHCONDPAG" 
 
END WSRESTFUL


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � GET      � Autor � Ednei R. Silva        � Data � MAR/2020 ���
�������������������������������������������������������������������������͹��
���Desc.     � Metodo para listar Condicao de Pagamento.                  ���
�������������������������������������������������������������������������͹��
���Uso       � 		                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
WSMETHOD GET WSRECEIVE E4_CODIGO, E4_DTHDE, E4_DTHATE WSSERVICE MAHCONDPAG

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
	
	aAdd(aCampo, {"E4_CODIGO", "CODIGO"})	
	aAdd(aCampo, {"E4_TIPO",   "TIPO"})
	aAdd(aCampo, {"E4_COND",   "COND"})	
	aAdd(aCampo, {"E4_DESCRI", "DESCRI"})
	aAdd(aCampo, {"E4_ZOHDTH", "ZOHDTH"})
	aAdd(aCampo, {"D_E_L_E_T_","DELET"})

	nCampo := Len(aCampo)
		
	cQuery := " SELECT "
	aEval( aCampo, { |Z| nX++, cQuery += Z[1] +" "+ Z[2] + IIf( nX < nCampo, ', ', '') } )
	cQuery += "	FROM " + RetSQLName("SE4")
	cQuery += " WHERE E4_FILIAL = '" + xFilial("SE4") + "'"
	cQuery += "   AND E4_MSBLQL <> '1'"
	cQuery += "   AND D_E_L_E_T_ <> '*'"
	
	If !Empty( ::E4_CODIGO )
		cQuery += " AND	E4_CODIGO = '" + Upper( ::E4_CODIGO ) + "' "
	EndIf
	
	If !Empty( ::E4_DTHDE ) .Or. !Empty( ::E4_DTHATE )
		cQuery  += "  AND E4_ZOHDTH BETWEEN '" + AllTrim(::E4_DTHDE) + "' AND '" + AllTrim(::E4_DTHATE) + "'"
	EndIf
	
	cQuery := ChangeQuery(cQuery)			
	
	dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQuery), (cArea := GetNextAlias()), .F., .T. )
	
	Count To nReg		

	If nReg == 0
	
		lOk := .F.
		SetRestFault( 1, "Nenhuma condicao de pagamento a ser exibida." )

	ELse
	
		dbSelectArea(cArea)
		dbGoTop()

		::SetResponse('{"COND": [')

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
				
				If aCampo[nX][1] == "E4_DESCRI"
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