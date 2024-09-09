#Include "TOTVS.CH"
#Include "RESTFUL.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � MAHWS010 � Autor � Ednei R. Silva        � Data � MAR/2020 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Servico Web service para integracao Protheus X Zoho.       ���
���          � Cadastro de Cliente.                                       ���
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

WSRESTFUL MAHCLIENTE DESCRIPTION "Cadastro de Cliente"

	WSDATA A1_COD AS STRING
	WSDATA A1_LOJA AS STRING
	WSDATA A1_CGC AS STRING 
	WSDATA A1_DTHDE AS STRING 
	WSDATA A1_DTHATE AS STRING 
	WSDATA A1_MSBLQL AS STRING 
	
	WSMETHOD GET DESCRIPTION "Listar Cadastro de Cliente" WSSYNTAX "/MAHCLIENTE" 
 
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
WSMETHOD GET WSRECEIVE A1_COD, A1_LOJA, A1_CGC, A1_DTHDE, A1_DTHATE, A1_MSBLQL WSSERVICE MAHCLIENTE

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
	

	
	
	aAdd(aCampo, {"A1_COD", "COD"})	
	aAdd(aCampo, {"A1_LOJA", "LOJA"})
	aAdd(aCampo, {"A1_PESSOA", "PESSOA"})
	aAdd(aCampo, {"A1_NOME", "NOME"})
	aAdd(aCampo, {"A1_END", "ENDERECO"})	
	aAdd(aCampo, {"A1_NREDUZ", "NREDUZ"})
	aAdd(aCampo, {"A1_BAIRRO", "BAIRRO"})
	aAdd(aCampo, {"A1_TIPO", "TIPO"})
	aAdd(aCampo, {"A1_EST", "EST"})
	aAdd(aCampo, {"A1_CEP", "CEP"})
	aAdd(aCampo, {"A1_COD_MUN", "COD_MUN"})
	aAdd(aCampo, {"A1_MUN", "MUN"})
	aAdd(aCampo, {"A1_DDD", "DDD"})
	aAdd(aCampo, {"A1_TEL", "TEL"})
	aAdd(aCampo, {"A1_CGC", "CGC"})
	aAdd(aCampo, {"A1_INSCR", "INSCR"})
	aAdd(aCampo, {"A1_INSCRM", "INSCR_MUNIC"})
	aAdd(aCampo, {"A1_PAIS", "PAIS"})
	aAdd(aCampo, {"A1_COND", "COND"})
	aAdd(aCampo, {"A1_NATUREZ", "NATUREZA"})
	aAdd(aCampo, {"A1_EMAIL",  "EMAIL"})
	aAdd(aCampo, {"A1_MSBLQL", "MSBLQL"})
	aAdd(aCampo, {"A1_SALDUP", "SALDUP"})
	aAdd(aCampo, {"A1_VEND",   "VEND"})
	aAdd(aCampo, {"A1_RISCO",   "RISCO"})
	aAdd(aCampo, {"A1_CODZHO", "ID_ZOHO"})
	aAdd(aCampo, {"A1_TPESSOA", "TIPO_CLIENTE"})
	aAdd(aCampo, {"A1_TPJ", "TIPO_JURIDICO"})
	aAdd(aCampo, {"A1_CONTATO", "CONTATO"})
	aAdd(aCampo, {"A1_ZOHDTH", "ZOHDTH"})
	aAdd(aCampo, {"A1_ZTPCOUF", "CLIENTE_FORNECEDOR"})
	aAdd(aCampo, {"D_E_L_E_T_", "DELET"})

	nCampo := Len(aCampo)
		
	cQuery := " SELECT "
	aEval( aCampo, { |Z| nX++, cQuery += Z[1] +" "+ Z[2] + IIf( nX < nCampo, ', ', '') } )
	cQuery += "	FROM " + RetSQLName("SA1")
	cQuery += " WHERE A1_FILIAL = '" + xFilial("SA1") + "'"
 
	
	If !Empty( ::A1_MSBLQL )
		cQuery += " AND A1_MSBLQL = '"+ ::A1_MSBLQL +"'"
    else
        cQuery += "   AND A1_MSBLQL <> '1'"
    Endif
	
	
	
	If !Empty( ::A1_COD ) 

		cQuery += "   AND A1_COD = '"+ Upper( ::A1_COD ) +"'"
		
		If !Empty( ::A1_LOJA ) 
			cQuery += "   AND A1_LOJA = '"+ Upper( ::A1_LOJA ) +"'"
		EndIf
		
	EndIf
		
	If !Empty( ::A1_CGC )
		cQuery += "   AND A1_CGC = '"+ ::A1_CGC +"'"
	EndIf

	If !Empty( ::A1_DTHDE ) .Or. !Empty( ::A1_DTHATE )
		cQuery  += "  AND A1_ZOHDTH BETWEEN '" + AllTrim(::A1_DTHDE) + "' AND '" + AllTrim(::A1_DTHATE) + "'"
	EndIf
	
	cQuery := ChangeQuery(cQuery)			
	
	dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQuery), (cArea := GetNextAlias()), .F., .T. )
	
	Count To nReg		

	If nReg == 0
	
		lOk := .F.
		SetRestFault( 1, "Nenhum cliente a ser exibido." )

	ELse
	
		dbSelectArea(cArea)
		dbGoTop()

		::SetResponse('{"CLIENTE": [')

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
				
				If aCampo[nX][1] $ "A1_END|A1_NOME|A1_NREDUZ|A1_BAIRRO|A1_CONTATO"
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
