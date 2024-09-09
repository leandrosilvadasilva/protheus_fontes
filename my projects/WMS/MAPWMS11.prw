#Include "TOTVS.ch" 
#Include "RESTFUL.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "tbiconn.ch"
#INCLUDE "topconn.CH"

/*--------------------------------------------------------------------------------------------------*
| Func:  MAPWMS11()                                                     							|
| Autor: Lucas Brustolin                                              								|
| Data:  Fev/2022                                                   								|
| Desc:  Rotina para envio do Tipo de Entrada\Saida (Nota) para AKR	        	                    |   
|																									|
    /api/Mahospitalar.V1_0_0/Doc/SetSerial

    {
    "DocEntry_Pedido": "string",
    "DocEntry_Nota": "string",
    "Serial": "string",
    "Series": "string",
    "SerialKey": "string",
    "PathPdf": "string",
    "PathXml": "string",
    "SefazStatus": 0,
    "SefazStatusDescription": "string"
    }
    DocEntry_Pedido (string): Número do Documento - Pedido ,
    DocEntry_Nota (string): Número do Documento - Nota Fiscal ,
    Serial (string, optional): Número da Nota Fiscal ,
    Series (string, optional): Número da série da Nota Fiscal ,
    SerialKey (string, optional): Chave da Nota Fiscal ,
    PathPdf (string, optional): Diretório do PDF ,
    PathXml (string, optional): Diretório do XML ,
    SefazStatus (integer): Status Sefaz ,
    SefazStatusDescription (string, optional): Descrição Status Sefaz
|                                                                            						|
*--------------------------------------------------------------------------------------------------*/
User Function MAPWMS11( nRecnoSF2, nOperation)

Local _oPostUser as Object
Local _sPath := "/api/Mahospitalar.V1_0_0/Doc/SetSerial"
Local _sPutErro := ""
Local _aRetPost := {}

Default nRecnoSF2	:= SF2->( Recno() )
Default nOperation	:= 3

    Private _sURL := U_MAPWMSAuth(1)

    _aHeader	:= MontaHead()
    _sJsonPost 	:= MontaJson( nRecnoSF2 )

    _oPostUser := FWRest():New(_sURL)
    _oPostUser:setPath(_sPath)
    _oPostUser:SetPostParams(_sJsonPost)	

    If _oPostUser:Post(_aHeader)
        _sRetorno := DecodeUTF8( _oPostUser:GetResult() )
        
        _oGetRet := JSonObject():New()
        _cErro := _oGetRet:FromJson(_sRetorno)
        _sException := ""        

        If Empty(_cErro)
            _bStatus := _oGetRet:GetJsonObject("status")
            If !_bStatus
                _sException := _oGetRet:GetJsonObject("exception")
                _aRetPost := {.F.,"ERRO POST Nota Fiscal Saida RETORNO ==>"+ _sException}
            Else
                _aRetPost := {.T.,"Post Nota Fiscal Saida Enviada com Sucesso!"}
            EndIf            
            FreeObj(_oGetRet)
        Else
            _sPutErro := "ERRO JSON Nota Fiscal Saida ==> Erro ao converter o retorno da Api em JSON" 
            _aRetPost := {.F.,_sPutErro}
        Endif
    Else
        _sPutErro := "ERRO POST Nota Fiscal Saida AUTH => " + _oPostUser:GetResult() + CRLF
        _sPutErro += _sParam		
        _aRetPost := {.F.,_sPutErro}
    EndIf
    
	If !Empty(_sPutErro) .or. !Empty(_sException)
		FwMakeDir("integracao_wms\nfs\erro")
		MEMOWRITE("integracao_wms\nfs\erro\"+ AllTrim(SF2->F2_FILIAL + SF2->F2_DOC + SF2->F2_SERIE) + ".error", _sPutErro + CRLF +"Exception: " + _sException)
        
        FwMakeDir("integracao_wms\nfs\")
        MEMOWRITE("integracao_wms\nfs\"+ SF2->F2_FILIAL + SF2->F2_DOC + SF2->F2_SERIE +".json", _sJsonPost )
    EndIf 
    
    FreeObj(_oPostUser)


Return _aRetPost


/*--------------------------------------------------------------------------------------------------*
| Func:  MontaHead()                                                     							|
| Autor: Lucas Brustolin                                              								|
| Data:  FEV/2022                                                   								|
| Desc:  FunÃ§Ã£o responsÃ¡vel por montar o cabeÃ§alho das resquisiÃ§Ãµes para AKR		 				|
|																									|
| AlteraÃ§Ãµes .:  /                                                            						|
*--------------------------------------------------------------------------------------------------*/
Static Function MontaHead()
	Local _aHeadRest := {}
	Local _aGetToken := {}
    
    _aGetToken := U_MAPWMS01()

    If _aGetToken[1]
        AADD(_aHeadRest,"Content-Type:application/json" ) 
        AADD(_aHeadRest, "Authorization: Bearer "+Alltrim(_aGetToken[2]))
    Else
        conout("ERRO NOTA FISCAL DE VENDA MONTA HEADER ==> Nao foi possivel montar o header: "+_aGetToken[2])
    EndIf
        
    
Return _aHeadRest

/*--------------------------------------------------------------------------------------------------*
| Func:  MontaJson()                                                     							|
| Autor: Lucas Brustolin                                              								|
| Data:  FEV/2022                                                   								|
| Desc:  FunÃ§Ã£o responsÃ¡vel por montar o cabeÃ§alho das resquisiÃ§Ãµes para AKR		 				|
|																									|
| AlteraÃ§Ãµes .:  /                                                            						|
*--------------------------------------------------------------------------------------------------*/
Static Function MontaJson( nRecnoSF2 )
   
Local aArea 	:= GetArea()
Local jNFS		:= Nil 
Local cParJSON	:= ""
Local aStatusNF := {}
Private retSD2  := {}

	If nRecnoSF2 > 0 
		SF2->( DbGoTo(  nRecnoSF2 ) )
	EndIf 

    //sleep(20000)

    aStatusNF := U_MASttsNF( SF2->F2_DOC, SF2->F2_SERIE )


	jNFS 				            := JSonObject():New()	 
	jNFS["DocEntry_Pedido"] 	    := SC5->C5_NUM          	// Número do Documento - Pedido
	jNFS["DocEntry_Nota"]	        := SF2->F2_FILIAL + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA // Número do Documento - Nota Fiscal
	jNFS["Serial"]	                := SF2->F2_DOC				// Número da Nota Fiscal
	jNFS["Series"]	                := SF2->F2_SERIE        	// Número da série da Nota Fiscal
	jNFS["SerialKey"]	            := SF2->F2_CHVNFE       	// Chave da Nota Fiscal
	jNFS["PathPdf"]                 := ""   					// Diretório do PDF
    jNFS["PathXml"]                 := "" 	    				// Diretório do XML
    //IATAN EM 22/04/2024
    IF ALLTRIM(SF2->F2_SERIE) == 'NSM'
        jNFS["SefazStatus"]             := '6'    			// Status Sefaz 
        jNFS["SefazStatusDescription"]  := 'NFe autorizada'	    		// (string, optional): Descrição Status Sefaz
    ELSE
        jNFS["SefazStatus"]             := aStatusNF[2]    			// Status Sefaz 
        jNFS["SefazStatusDescription"]  := aStatusNF[3]	    		// (string, optional): Descrição Status Sefaz
    ENDIF
  
    //IATAN EM 02/12/2022
    getRetSD2(@retSD2, SF2->F2_FILIAL + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA )

    jNFS["DocLines"]     := retSD2
	
	cParJSON 	:= jNFS:ToJSon() 
	cParJSON	:= EncodeUTF8(cParJSON)	 

    CONOUT("JSON - MAPWMS11")
    CONOUT(cParJSON)


RestArea( aArea )  

Return( cParJSON )


Static Function FormatDate( xDate )

Local cDateFormat := ""

	If !Empty(xDate)
		If ValType(xDate) == "D"
			cDateFormat := FWTimeStamp(6, xDate )
		EndIf 
	EndIf 

Return( cDateFormat )

User Function MASttsNF( cDoc, cSerie )	
	
Local aArea 	:= GetArea()
Local cQuery 	:= ""
Local cTabQry	:= ""
Local aRet 		:= {.F., "",""}	
	
cQuery:= CRLF+" SELECT "
cQuery+= CRLF+" 	ID_ENT,SUBSTRING(NFE_ID,4,9) NFE_ID,DATE_NFE,TIME_NFE,S50.STATUS,STATUSCANC,NFE_PROT,DOC_CHV,DOC_ID,DOC_SERIE, "
cQuery+= CRLF+" 	CASE "
cQuery+= CRLF+" 		WHEN STATUS='1' THEN 'STATUS' "
cQuery+= CRLF+" 		WHEN STATUS='2' THEN 'NFe Assinada' "
cQuery+= CRLF+" 		WHEN STATUS='3' THEN 'NFe com falha no schema XML' "
cQuery+= CRLF+" 		WHEN STATUS='4' THEN 'NFe transmitida' "
cQuery+= CRLF+" 		WHEN STATUS='5' THEN 'NFe com problemas' "
cQuery+= CRLF+" 		WHEN STATUS='6' THEN 'NFe autorizada' "
cQuery+= CRLF+" 		WHEN STATUS='7' THEN 'Cancelamento' "
cQuery+= CRLF+" 	END STATUS_NFE, "
cQuery+= CRLF+" 	CASE "
cQuery+= CRLF+" 		WHEN STATUSCANC='1' THEN 'NFe Recebida' "
cQuery+= CRLF+" 		WHEN STATUSCANC='2' THEN 'NFe Cancelada' "
cQuery+= CRLF+" 		WHEN STATUSCANC='3' THEN 'NFe com falha de cancelamento/inutilizacao' "
cQuery+= CRLF+" 	ELSE "
cQuery+= CRLF+" 		'' "
cQuery+= CRLF+" 	END STATUS_CANCELAMENTO "
cQuery+= CRLF+" FROM "

cQuery+= CRLF+" 	SPED050 S50 "
cQuery+= CRLF+" WHERE "

cQuery+= CRLF+" 	SUBSTRING(NFE_ID,4,9) = '"	+ ALLTRIM(cDoc)     + "'"
cQuery+= CRLF+" 	AND DOC_SERIE = '"			+ ALLTRIM(cSerie)   + "'"	
cQuery+= CRLF+" 	AND D_E_L_E_T_='' "
cQuery+= CRLF+" ORDER BY "
cQuery+= CRLF+" 	NFE_ID, ID_ENT,DOC_ID "

cQuery := ChangeQuery(cQuery)
cTabQry := MPSysOpenQuery(cQuery)
DbSelectArea(cTabQry)
DBGoTop()
If (cTabQry)->(!EoF())
	aRet[1] := .T.
	aRet[2] := cValToChar( (cTabQry)->STATUS )
	aRet[3] := AllTrim( (cTabQry)->STATUS_NFE ) + " - " + AllTrim( (cTabQry)->STATUS_CANCELAMENTO )
Else 
	aRet[1] := .F.
	aRet[2] := "0"
	aRet[3] := "Documento fiscal nao foi localizado na tabela SPED050 "	
EndIf 
(cTabQry)->(DBCloseArea())


RestArea( aArea )

Return( aRet )


// CHAVE = SF2->F2_FILIAL + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA
Static Function getRetSD2(array, chave)

Local cQry
Local oJsonResponse	As Object

    cQry := " SELECT * FROM SD2010 " 
	cQry += " WHERE D_E_L_E_T_ <> '*' "
    cQry += "       AND D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA = '" + chave + "' "

	TCQuery cQry New Alias "QRY_SD2"
	
	QRY_SD2->(DbGoTop())

    CONOUT("MAPWMS11")

	While ! QRY_SD2->(Eof())

		oJsonResponse := JsonObject():New()
		oJsonResponse['LineNum']  := QRY_SD2->D2_ITEM
		oJsonResponse['ItemCode'] := QRY_SD2->D2_COD
		oJsonResponse['BatchNum'] := QRY_SD2->D2_LOTECTL
        oJsonResponse['Quantity'] := QRY_SD2->D2_QUANT
        
        CONOUT("LineNum = " +  QRY_SD2->D2_ITEM )
        CONOUT("ItemCode = " + QRY_SD2->D2_COD)
        CONOUT("BatchNum = " + QRY_SD2->D2_LOTECTL)
        CONOUT("Quantity = " + CVALTOCHAR( QRY_SD2->D2_QUANT))

		AADD(array, oJsonResponse )

		QRY_SD2->(DbSkip())
	EndDo

	QRY_SD2->(DbCloseArea())

Return 
