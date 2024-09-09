#Include "TOTVS.CH"
#Include "RESTFUL.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � MAHMTCLI � Autor � Ednei R. Silva        � Data � JUN/2020 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Servico Web service para integracao Protheus X Zoho.       ���
���          � Matriz Cliente x Vendedor   .                              ���
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

WSRESTFUL MAHMTCLI DESCRIPTION "Matriz Clientes"

	WSDATA ZA7_CODCLI AS STRING
    WSDATA ZA7_LOJCLI AS STRING
    WSDATA ZA7_MARCA  AS STRING
    WSDATA ZA7_CODGRU AS STRING

	WSMETHOD GET DESCRIPTION "Matriz de Clientes" WSSYNTAX "/MAHMTCLI" 
 
END WSRESTFUL


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � GET      � Autor � Ednei R. Silva        � Data � MAR/2020 ���
�������������������������������������������������������������������������͹��
���Desc.     � Metodo para listar Tabela de Preco Protheus.               ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
WSMETHOD GET WSRECEIVE ZA7_CODCLI,ZA7_LOJCLI,ZA7_MARCA,ZA7_CODGRU WSSERVICE MAHMTCLI
	
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
	
	aAdd(aCampo, {"ZA7_FILIAL","FILIAL"})
    aAdd(aCampo, {"ZA7_CODCLI","CLIENTE"})	
	aAdd(aCampo, {"ZA7_LOJCLI","LOJA"})
	aAdd(aCampo, {"ZA7_NOME","NOME"})
    aAdd(aCampo, {"ZA7_CODVEN","COD_VENDEDOR"})
    aAdd(aCampo, {"ZA7_NOMVEN","NOM_VENDEDOR"})
	aAdd(aCampo, {"ZA7_MARCA" ,"COD_MARCA"})
	aAdd(aCampo, {"ZA7_DESMAR","DES_MARCA"})
	aAdd(aCampo, {"ZA7_CODGRU", "GRUPO"})	
	aAdd(aCampo, {"ZA7_DESGRU","DES_GRUPO"})
	aAdd(aCampo, {"ZA7_MUNIC",  "MUNICIPIO"})
	aAdd(aCampo, {"ZA7_EST",  "UF"})
	
	nCampo := Len(aCampo)
		
	cQuery := " SELECT "
	aEval( aCampo, { |Z| nX++, cQuery += Z[1] +" "+ Z[2] + IIf( nX < nCampo, ', ', '') } )
	cQuery += " 	FROM ZA7010 ZA7  "
	cQuery += " WHERE  " 
	cQuery += " ZA7.D_E_L_E_T_<>'*'  "
	If !Empty( ::ZA7_CODCLI )
		cQuery += " AND ZA7_CODCLI = '"+ Upper( ::ZA7_CODCLI ) +"'"
	EndIf
	If !Empty( ::ZA7_LOJCLI )
		cQuery += " AND ZA7_LOJCLI = '"+ Upper( ::ZA7_LOJCLI ) +"'"
	EndIf
    If !Empty( ::ZA7_MARCA )
		cQuery += " AND ZA7_MARCA = '"+ Upper( ::ZA7_MARCA ) +"'"
	EndIf
     If !Empty( ::ZA7_CODGRU )
		cQuery += " AND ZA7_CODGRU = '"+ Upper( ::ZA7_CODGRU ) +"'"
	EndIf
	
		
	cQuery := ChangeQuery(cQuery)			
	
	dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQuery), (cArea := GetNextAlias()), .F., .T. )
	
	Count To nReg		

	If nReg == 0
	
		lOk := .F.
		SetRestFault( 1, "Verifique o parametro ou nenhum Item  a ser exibido." )

	ELse
	
		dbSelectArea(cArea)
		dbGoTop()

		::SetResponse('{"MATRIZ": [')

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
