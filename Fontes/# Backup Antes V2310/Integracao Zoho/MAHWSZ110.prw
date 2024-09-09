#Include "TOTVS.CH"
#Include "RESTFUL.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � MAHZHBIO � Autor � Ednei R. Silva        � Data � JUN/2020 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Servico Web service para integracao Protheus X Zoho.       ���
���          � Bionexo Zoho  .                                            ���
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

WSRESTFUL MAHZHBIO DESCRIPTION "Bionexo Zoho"

	WSDATA BIO_EMIS1       as STRING
    WSDATA BIO_EMIS2       as STRING
    WSDATA BIO_STATUS      as STRING
    WSDATA BIO_COTACAO     as STRING
	WSDATA BIO_ITEMCOTACAO as STRING

	WSMETHOD GET DESCRIPTION "Bionexo Zoho" WSSYNTAX "/MAHZHBIO" 
 
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
WSMETHOD GET WSRECEIVE BIO_EMIS1,BIO_EMIS2,BIO_STATUS,BIO_COTACAO,BIO_ITEMCOTACAO WSSERVICE MAHZHBIO
	
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

    aadd(aCampo, {"BIO_STATUS"     , "STATUS"})
    aadd(aCampo, {"BIO_COTACAO"    , "COTACAO"})
	aadd(aCampo, {"BIO_ITEMCOTACAO", "ITEMCOTACAO"})
	aadd(aCampo, {"BIO_UF"         , "UF"})
	aadd(aCampo, {"BIO_CODCLI"     , "COD_CLIENTE"})
    aadd(aCampo, {"BIO_LOJCLI"     , "LOJA_CLIENTE"})
    aadd(aCampo, {"BIO_NOMCLI"     , "NOME_CLIENTE"})
	aadd(aCampo, {"BIO_CNPJ"       , "CNPJ"})
	aadd(aCampo, {"BIO_EMISSAO"    , "EMISSAO"})
	aadd(aCampo, {"BIO_VENCIMENTO" , "VENCIMENTO"})
	aadd(aCampo, {"BIO_CONFIRMACAO", "CONFIRMACAO"})
	aadd(aCampo, {"BIO_VENDCOTA"   , "VENDEDOR_COTACAO"})
    aadd(aCampo, {"BIO_CODPRO"     , "COD_PRODUTO"})
    aadd(aCampo, {"BIO_DESNOM"     , "DESCRI_PRODUTO"})
    aadd(aCampo, {"BIO_MARCA"      , "MARCA"})
    aadd(aCampo, {"BIO_DESMARCA"   , "DESCRI_MARCA"})
    aadd(aCampo, {"BIO_GRUPO"      , "GRUPO"})
    aadd(aCampo, {"BIO_PRCUNI"     , "VLR_UNITARIO"})
    aadd(aCampo, {"BIO_QUANT"      , "QUANTIDADE"})
    aadd(aCampo, {"BIO_TOTAL"      , "VLR_TOTAL"})
	aadd(aCampo, {"BIO_ALTERACAO"  , "BIO_ALTERACAO"})

	nCampo := Len(aCampo)
		
	cQuery := " SELECT "
	aEval( aCampo, { |Z| nX++, cQuery += Z[1] +" "+ Z[2] + IIf( nX < nCampo, ', ', '') } )
	cQuery += " 	FROM BIO_ZOHO BIOZ "
	cQuery += " WHERE 1=1 "
	
	/*
    If !Empty( ::BIO_EMIS1) .or. !Empty( ::BIO_EMIS2) .or. !Empty( ::BIO_STATUS )
     cQuery += " WHERE 1=1 "
    endif    
	*/

	If !Empty( ::BIO_EMIS1)
		cQuery += " AND BIO_ALTERACAO >= '"+ Upper( ::BIO_EMIS1 ) +"'"
	EndIf
    If !Empty( ::BIO_EMIS2)
		cQuery += " AND BIO_ALTERACAO <= '"+ Upper( ::BIO_EMIS2 ) +"'"
	EndIf
	If !Empty( ::BIO_STATUS )
		cQuery += " AND BIO_STATUS = '"+ Upper( ::BIO_STATUS) +"'"
	EndIf

	If !Empty( ::BIO_COTACAO)

		cQuery += " AND BIO_COTACAO = '"+ ::BIO_COTACAO +"'"
	EndIf
    If !Empty( ::BIO_ITEMCOTACAO)

		cQuery += " AND BIO_ITEMCOTACAO <= '"+ ::BIO_ITEMCOTACAO +"'"
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

		::SetResponse('{"BIOZOHO": [')

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
				
				If aCampo[nX][1] $ "BIO_DESNOM|BIO_NOMCLI"
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
