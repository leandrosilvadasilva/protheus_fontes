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

	WSDATA BIO_EMIS1   AS STRING
    WSDATA BIO_EMIS2   AS STRING
    WSDATA BIO_STATUS  AS STRING
    

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
WSMETHOD GET WSRECEIVE BIO_EMIS1,BIO_EMIS2,BIO_STATUS WSSERVICE MAHZHBIO
	
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

    aAdd(aCampo, {"BIO_STATUS","STATUS"})
    aAdd(aCampo, {"BIO_COTACAO","COTACAO"})
	aAdd(aCampo, {"BIO_ITEMCOTACAO","ITEMCOTACAO"})		
	aAdd(aCampo, {"BIO_UF","UF"})
	aAdd(aCampo, {"BIO_CODCLI","COD_CLIENTE"})
    aAdd(aCampo, {"BIO_LOJCLI","LOJA_CLIENTE"})
    aAdd(aCampo, {"BIO_NOMCLI","NOME_CLIENTE"})
	aAdd(aCampo, {"BIO_CNPJ"  ,"CNPJ"})
	aAdd(aCampo, {"BIO_EMISSAO","EMISSAO"})
	aAdd(aCampo, {"BIO_VENCIMENTO", "VENCIMENTO"})	
	aAdd(aCampo, {"BIO_CONFIRMACAO","CONFIRMACAO"})
	aAdd(aCampo, {"BIO_VENDCOTA",  "VENDEDOR_COTACAO"})
    aAdd(aCampo, {"BIO_CODPRO",  "COD_PRODUTO"})
    aAdd(aCampo, {"BIO_DESNOM",  "DESCRI_PRODUTO"})
    aAdd(aCampo, {"BIO_MARCA",  "MARCA"})
    aAdd(aCampo, {"BIO_DESMARCA",  "DESCRI_MARCA"})
    aAdd(aCampo, {"BIO_GRUPO",  "GRUPO"})
    aAdd(aCampo, {"BIO_PRCUNI",  "VLR_UNITARIO"})
    aAdd(aCampo, {"BIO_QUANT",  "QUANTIDADE"})
    aAdd(aCampo, {"BIO_TOTAL",  "VLR_TOTAL"})
	
	nCampo := Len(aCampo)
		
	cQuery := " SELECT "
	aEval( aCampo, { |Z| nX++, cQuery += Z[1] +" "+ Z[2] + IIf( nX < nCampo, ', ', '') } )
	cQuery += " 	FROM BIO_ZOHO BIOZ "
	
    If !Empty( ::BIO_EMIS1) .or. !Empty( ::BIO_EMIS2) .or. !Empty( ::BIO_STATUS )
     cQuery += " WHERE 1=1 "
    endif 

   

	If !Empty( ::BIO_EMIS1)
		cQuery += " AND BIO_EMISSAO >= '"+ Upper( ::BIO_EMIS1 ) +"'"
	EndIf
    If !Empty( ::BIO_EMIS2)
		cQuery += " AND BIO_EMISSAO <= '"+ Upper( ::BIO_EMIS2 ) +"'"
	EndIf
	If !Empty( ::BIO_STATUS )
		cQuery += " AND BIO_STATUS = '"+ Upper( ::BIO_STATUS) +"'"
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
