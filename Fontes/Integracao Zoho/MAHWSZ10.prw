#Include "TOTVS.CH"
#Include "RESTFUL.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � MAHWS010 � Autor � Ednei R. Silva        � Data � MAR/2020 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Servico Web service para integracao Protheus X Zoho.       ���
���          � Cadastro de produto.                                       ���
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

WSRESTFUL MAHPRODUTO DESCRIPTION "Cadastro de Produto"

	WSDATA B1_COD    AS STRING	
	WSDATA B1_DTHDE  AS STRING 
	WSDATA B1_DTHATE AS STRING
	WSDATA B1_MSBLQL AS STRING
	WSDATA B1_RECATE AS STRING 
    WSDATA B1_RECDE  AS STRING
	WSDATA B1_LIKENOME  AS STRING  
	WSMETHOD GET DESCRIPTION "Listar Cadastro de Produto" WSSYNTAX "/MAHPRODUTO" 
 
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
WSMETHOD GET WSRECEIVE B1_COD, B1_DTHDE, B1_DTHATE, B1_MSBLQL, B1_RECDE, B1_RECATE,B1_LIKENOME WSSERVICE MAHPRODUTO

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
	
	aAdd(aCampo, {"B1_FILIAL",  	"B1_FILIAL"})
	aAdd(aCampo, {"RTRIM(B1_COD)",  "B1_COD"})	
	aAdd(aCampo, {"B1_DESC", 		"B1_DESC"})	
	aAdd(aCampo, {"B1_TIPO", 		"B1_TIPO"})
	aAdd(aCampo, {"B1_MARCA",   	"B1_MARCA"})
	aAdd(aCampo, {"B1_DESCMAR", 	"B1_DESCMAR"})
	aAdd(aCampo, {"Case WHEN B1_FABRIC <>'' THEN B1_FABRIC WHEN B1_FABRIC=''  THEN B1_DESCMAR END AS ", 	"B1_FABRIC"})
	aAdd(aCampo, {"ISNULL((SELECT YA_DESCR FROM SYA010 WHERE B1_PROCEDE = YA_CODGI AND D_E_L_E_T_<>'*'),'') ", 	"B1_PROCEDE"})
	aAdd(aCampo, {"B1_GRUPO",   	"B1_GRUPO"})
	aAdd(aCampo, {"B1_GRUDES",  	"B1_GRUDES"})
	aAdd(aCampo, {"B1_GRTRIB",  	"B1_GRTRIB"})
	aAdd(aCampo, {"B1_POSIPI",  	"B1_POSIPI"})
	aAdd(aCampo, {"B1_IMPORT",  	"B1_IMPORT"})
	aAdd(aCampo, {"ISNULL(CAST(CAST(B1_FICHATE AS VARBINARY(8000)) AS VARCHAR(8000)),'')", "B1_FICHATE"})
	aAdd(aCampo, {"B1_UM", 			"B1_UM"})
	aAdd(aCampo, {"B1_CODZHO",  	"B1_CODZHO"})
	aAdd(aCampo, {"B1_ZCDTUSS", 	"B1_ZCDTUSS"})
	aAdd(aCampo, {"B1_NRANVIS", 	"B1_NRANVIS"})
	aAdd(aCampo, {"B1_ZOHDTH",  	"B1_ZOHDTH"})	
    
	// DWT Luciano
	aAdd(aCampo, {"B1_ORIGEM",  "B1_ORIGEM"})	
	aAdd(aCampo, {"B1_IPI",  	"B1_IPI"})	   


	nCampo := Len(aCampo)
	If !Empty( ::B1_LIKENOME ) 	
		cQuery := " SELECT TOP 20 "
	else
		cQuery := " SELECT "
    endif
	aEval( aCampo, { |Z| nX++, cQuery += Z[1] +" "+ Z[2] + IIf( nX < nCampo, ', ', '') } )
	cQuery += "	FROM " + RetSQLName("SB1")
	cQuery += " WHERE B1_FILIAL = '" + xFilial("SB1") + "'"
    cQuery += "   AND D_E_L_E_T_<> '*'"
    cQuery += "   AND (B1_TIPO IN ('M1','M2','M3','M4','M5') OR (B1_TIPO = 'AI' AND B1_COD LIKE '%IMB' ) )  "
    cQuery += "   AND (SELECT  MAX(DA1MAX.DA1_ITEM) FROM DA1010 DA1MAX WHERE DA1MAX.DA1_CODPRO=B1_COD AND DA1MAX.D_E_L_E_T_<>'*') <> '' " 	
	
	If !Empty( ::B1_LIKENOME )
		cQuery += " AND B1_DESC LIKE '%" + ::B1_LIKENOME  + "%'"
	EndIf
	
	If !Empty( ::B1_COD )
		cQuery += " AND B1_COD = '"+ Upper( ::B1_COD ) +"'"
	EndIf
	
	If !Empty( ::B1_RECDE  ) .and. !Empty( ::B1_RECATE  )
		cQuery += " AND R_E_C_N_O_ >="+ AllTrim( ::B1_RECDE )
        cQuery += " AND R_E_C_N_O_ <="+ AllTrim( ::B1_RECATE )	
	EndIf
	
	
	If !Empty( ::B1_MSBLQL )
		cQuery += " AND B1_MSBLQL = '"+ ::B1_MSBLQL +"'"
    else
        cQuery += "   AND B1_MSBLQL <> '1'"
    Endif
	
	
	If !Empty( ::B1_DTHDE ) .Or. !Empty( ::B1_DTHATE )
	
		cQuery += " AND B1_ZOHDTH >= '" + AllTrim(::B1_DTHDE)  + "'"
		cQuery += " AND B1_ZOHDTH <= '" + AllTrim(::B1_DTHATE) + "'"


	EndIf
	MemoWrite('wsProduto.SQL',cQuery)
	cQuery := ChangeQuery(cQuery)			
	
	dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQuery), (cArea := GetNextAlias()), .F., .T. )
	
	Count To nReg		

	If nReg == 0
	
		lOk := .F.
		SetRestFault( 1, "Verifique o parametro ou nenhum produto a ser exibido." )

	ELse
	
		dbSelectArea(cArea)
		dbGoTop()

		::SetResponse('{"PRODUTO": [')

		While (cArea)->( !Eof() )
		
			nCount++

			::SetResponse('{')
			
			nX := 0
			For nX := 1 To nCampo
			
				::SetResponse('"')
				::SetResponse(aCampo[nX][2]) 
				::SetResponse('"')
				::SetResponse(':')
				::SetResponse('"')
				
				If aCampo[nX][2] $ "B1_PROCEDE|B1_FABRIC|B1_DESC|B1_DESCMAR|B1_MARCA|B1_GRUDES|"
					::SetResponse( U_NoCharEsp( AllTrim( cValToChar( (cArea)->&(aCampo[nX][2]) ) ) ) ) 
				ElseIf aCampo[nX][2] $ "B1_FICHATE|ISNULL(CAST(CAST(B1_FICHATE AS VARBINARY(8000)) AS VARCHAR(8000)),''),B1_FICHATE))|"
					::SetResponse( sfArrum( AllTrim( cValToChar( (cArea)->&(aCampo[nX][2]) ) ),'C' ) ) 

				Else
					IF aCampo[nX][2] == "B1_COD"
					    ::SetResponse(ALLTRIM((cArea)->B1_COD))
					ELSE
					::SetResponse( AllTrim(strtran( cValToChar( (cArea)->&(aCampo[nX][2]) ),' ',' ' )) )
				    endif
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



/*/{Protheus.doc} sfArrum
//Ajusta o texto do JSON 
@author Renan W.Bordignon
@since 20/09/2020
@version 1.0
@return ${return}, ${return_description}
@param cInChar, characters, descricao
@type function
/*/

static function sfArrum(cIntValr,cTipo)
	Local _cValorRet := cIntValr
	Default cTipo := ''
		// c = utilizado em codigo/chave
		if cTipo <> 'c'
			_cValorRet:= STRTRAN(_cValorRet, "'", "")
			_cValorRet = STRTRAN(_cValorRet, '"', '')
			_cValorRet = STRTRAN(_cValorRet, "/", "-")
			_cValorRet:= STRTRAN(_cValorRet, "\", "")
			_cValorRet:= STRTRAN(_cValorRet, "&", "e")
			_cValorRet:= STRTRAN(_cValorRet, ";", " ")
		else
			_cValorRet:= STRTRAN(_cValorRet, "'", "")
			_cValorRet = STRTRAN(_cValorRet, '"', '')
			_cValorRet = STRTRAN(_cValorRet, "/", "-")
			_cValorRet:= STRTRAN(_cValorRet, "\", "")
			_cValorRet:= STRTRAN(_cValorRet, "&", "e")
			_cValorRet:= STRTRAN(_cValorRet, ";", " ")

		EndIf	

return (_cValorRet)

