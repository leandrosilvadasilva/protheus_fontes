#Include "TOTVS.CH"
#Include "RESTFUL.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � MAHWS010 � Autor � Ednei R. Silva        � Data � MAR/2020 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Servico Web service para integracao Protheus X Zoho.       ���
���          � Transportadora.                                            ���
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

WSRESTFUL MAHTRANSP DESCRIPTION "Cadastro de Transportadora"

	WSDATA A4_COD AS STRING
	WSDATA A4_DTHDE AS STRING 
	WSDATA A4_DTHATE AS STRING 
	
		
	WSMETHOD GET DESCRIPTION "Listar Cadastro de Transportadora" WSSYNTAX "/MAHTRANSP" 
 
END WSRESTFUL


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � GET      � Autor � Ednei R. Silva        � Data � MAR/2020 ���
�������������������������������������������������������������������������͹��
���Desc.     � Metodo para listar Transportadora         Protheus.        ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
WSMETHOD GET WSRECEIVE A4_COD, A4_DTHDE, A4_DTHATE WSSERVICE MAHTRANSP

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
	
	aAdd(aCampo, {"A4_COD", "COD"})	
	aAdd(aCampo, {"A4_NOME", "NOME"})
	aAdd(aCampo, {"A4_END", "ENDERECO"})	
	aAdd(aCampo, {"A4_COD_MUN", "COD_MUN"})
	aAdd(aCampo, {"A4_BAIRRO", "BAIRRO"})
	aAdd(aCampo, {"A4_MUN", "MUN"})
	aAdd(aCampo, {"A4_DDD", "DDD"})
	aAdd(aCampo, {"A4_TEL", "TEL"})
	aAdd(aCampo, {"A4_CGC", "CGC"})
	aAdd(aCampo, {"A4_EMAIL", "EMAIL"})
	aAdd(aCampo, {"A4_ZOHDTH", "ZOHDTH"})
	aAdd(aCampo, {"D_E_L_E_T_", "DELET"})

	nCampo := Len(aCampo)
		
	cQuery := " SELECT "
	aEval( aCampo, { |Z| nX++, cQuery += Z[1] +" "+ Z[2] + IIf( nX < nCampo, ', ', '') } )
	cQuery += "	FROM SA4010 "
	cQuery += " WHERE A4_FILIAL = '" + xFilial("SA4") + "'"
	//cQuery += "   AND A4_MSBLQL <> '1'"
	
	If !Empty( ::A4_COD )
		cQuery += " AND	A4_COD = '" + Upper( ::A4_COD ) + "' "
	EndIf
	
	If !Empty( ::A4_DTHDE ) .Or. !Empty( ::A4_DTHATE )
		cQuery  += "  AND A4_ZOHDTH BETWEEN '" + AllTrim(::A4_DTHDE) + "' AND '" + AllTrim(::A4_DTHATE) + "'"
	EndIf
	
	cQuery := ChangeQuery(cQuery)			
	
	dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQuery), (cArea := GetNextAlias()), .F., .T. )
	
	Count To nReg		

	If nReg == 0
	
		lOk := .F.
		SetRestFault( 1, "Nenhuma transportadora a ser exibida." )

	ELse
	
		dbSelectArea(cArea)
		dbGoTop()

		::SetResponse('{"TRANSP": [')

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
				
				If aCampo[nX][1] $ "A4_NOME|A4_END|A4_BAIRRO"
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
