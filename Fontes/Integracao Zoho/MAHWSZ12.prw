#Include "TOTVS.CH"
#Include "RESTFUL.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � MAHWS010 � Autor � Ednei R. Silva        � Data � MAR/2020 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Servico Web service para integracao Protheus X Zoho.       ���
���          � Cadastro de Grupo  .                                       ���
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

WSRESTFUL MAHGRUPO DESCRIPTION "Cadastro de Grupo de Produtos"

	WSDATA BM_GRUPO AS STRING	
  

	WSMETHOD GET DESCRIPTION "Listar Cadastro de Grupo" WSSYNTAX "/MAHGRUPO" 
 
END WSRESTFUL


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � GET      � Autor � Ednei R. Silva        � Data � MAR/2020 ���
�������������������������������������������������������������������������͹��
���Desc.     � Metodo para listar Cadastro de Produtos Protheus.          ���
�������������������������������������������������������������������������͹��
���Uso       � 			                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
WSMETHOD GET WSRECEIVE BM_GRUPO WSSERVICE MAHGRUPO

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
	
	aAdd(aCampo, {"BM_GRUPO",  "COD_GRUPO"})	
	aAdd(aCampo, {"BM_DESC", "DESC_GRUPO"})	

	nCampo := Len(aCampo)
		
	cQuery := " SELECT "
	aEval( aCampo, { |Z| nX++, cQuery += Z[1] +" "+ Z[2] + IIf( nX < nCampo, ', ', '') } )
	cQuery += "	FROM " + RetSQLName("SBM")
	cQuery += " WHERE BM_FILIAL = '" + xFilial("SBM") + "'"
    cQuery += "   AND D_E_L_E_T_<> '*'"
  
	If !Empty( ::BM_GRUPO )
		cQuery += " AND BM_GRUPO = '"+ Upper( ::BM_GRUPO ) +"'"
	EndIf
	
		
	cQuery := ChangeQuery(cQuery)			
	
	dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQuery), (cArea := GetNextAlias()), .F., .T. )
	
	Count To nReg		

	If nReg == 0
	
		lOk := .F.
		SetRestFault( 1, "Verifique o parametro ou nenhum Grupo a ser exibido." )

	ELse
	
		dbSelectArea(cArea)
		dbGoTop()

		::SetResponse('{"GRUPO": [')

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
				
				If aCampo[nX][1] $ "BM_XXXX"
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