#Include "TOTVS.ch" 
#Include "RESTFUL.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "tbiconn.ch"
#INCLUDE "topconn.CH"

/*--------------------------------------------------------------------------------------------------*
| Func:  MAPWMS09()                                                     							|
| Autor: Lucas Brustolin                                              								|
| Data:  Fev/2022                                                   								|
| Desc:  Rotina para envio do Tipo de Entrada\Saida (TES) para AKR	        	                                |   
|																									|
| Alterações .:  /                                                            						|
*--------------------------------------------------------------------------------------------------*/
User Function MAPWMS09( nRecnoSF4, nOperation)

Local _oPostUser as Object
Local _sPath := "/api/Mahospitalar.V1_0_0/Usage/Add"
Local _sPutErro := ""
Local _aRetPost := {}

Default nRecnoSF4	:= SF4->( Recno() )
Default nOperation	:= 3

    Private _sURL := U_MAPWMSAuth(1)

    _aHeader	:= MontaHead()
    _sJsonPost 	:= MontaJson( nRecnoSF4 )

    _oPostUser := FWRest():New(_sURL)
    _oPostUser:setPath(_sPath)
    _oPostUser:SetPostParams(_sJsonPost)	

    If _oPostUser:Post(_aHeader)
        _sRetorno := _oPostUser:GetResult()
        
        _oGetRet := JSonObject():New()
        _cErro := _oGetRet:FromJson(_sRetorno)
        _sException := ""        

        If Empty(_cErro)
            _bStatus := _oGetRet:GetJsonObject("status")
            If !_bStatus
                _sException := _oGetRet:GetJsonObject("exception")
                _aRetPost := {.F.,"ERRO POST TES RETORNO ==>"+ _sException}
            Else
                _aRetPost := {.T.,"Post TES Enviado com Sucesso!"}
            EndIf            
            FreeObj(_oGetRet)
        Else
            _sPutErro := "ERRO JSON TES ==> Erro ao converter o retorno da Api em JSON" 
            _aRetPost := {.F.,_sPutErro}
        Endif
    Else
        _sPutErro += "ERRO POST TES AUTH => " + _oPostUser:GetResult() + CRLF
        _sPutErro += _sParam		
        _aRetPost := {.F.,_sPutErro}
    EndIf
    
	If !Empty(_sPutErro) .or. !Empty(_sException)
		FwMakeDir("integracao_wms\TES\erro")
		MEMOWRITE("integracao_wms\TES\erro\"+ SF4->F4_FILIAL + SF4->F4_CODIGO + ".error", _sPutErro + CRLF +"Exception: " + _sException)

        FwMakeDir("integracao_wms\tes\")
        MEMOWRITE("integracao_wms\tes\"+ SF4->F4_FILIAL + SF4->F4_CODIGO + ".json", _sJsonPost )
        
	EndIf 
    
    FreeObj(_oPostUser)


Return _aRetPost


/*--------------------------------------------------------------------------------------------------*
| Func:  MontaHead()                                                     							|
| Autor: Lucas Brustolin                                              								|
| Data:  FEV/2022                                                   								|
| Desc:  Função responsável por montar o cabeçalho das resquisições para AKR		 				|
|																									|
| Alterações .:  /                                                            						|
*--------------------------------------------------------------------------------------------------*/
Static Function MontaHead()
	Local _aHeadRest := {}
	Local _aGetToken := {}
    
    _aGetToken := U_MAPWMS01()

    If _aGetToken[1]
        AADD(_aHeadRest,"Content-Type:application/json" ) 
        AADD(_aHeadRest, "Authorization: Bearer "+Alltrim(_aGetToken[2]))
    Else
        conout("ERRO TES VENDA MONTA HEADER ==> Nao foi possivel montar o header: "+_aGetToken[2])
    EndIf
        
    
Return _aHeadRest

/*--------------------------------------------------------------------------------------------------*
| Func:  MontaJson()                                                     							|
| Autor: Lucas Brustolin                                              								|
| Data:  FEV/2022                                                   								|
| Desc:  Função responsável por montar o cabeçalho das resquisições para AKR		 				|
|																									|
| Alterações .:  /                                                            						|
*--------------------------------------------------------------------------------------------------*/
Static Function MontaJson( nRecnoSF4 )
   
Local aArea 	:= GetArea()
Local jTES		:= Nil 
Local jTESAux	:= Nil 
Local cParJSON	:= ""
Local dDataInc	:= CTOD("")
Local dDataAlt	:= CTOD("")


	If nRecnoSF4 > 0 
		SF4->( DbGoTo(  nRecnoSF4 ) )
	EndIf 


	If SF4->( FieldPos("F4_USERLGI") ) > 0 .And. !Empty(FWLeUserlg("F4_USERLGI", 2))
		dDataInc := STOD(FWLeUserlg("F4_USERLGI", 2))
	EndIf 

	If SF4->( FieldPos("F4_USERLGA") ) > 0 .And. !Empty(FWLeUserlg("F4_USERLGA", 2))
		dDataAlt := STOD(FWLeUserlg("F4_USERLGA", 2))
	EndIf 


	jTES 				:= JSonObject():New()
	jTES["UsageModel "]	:= {}

	jTESAux		:= JSonObject():New()
	 
	jTESAux["Usage"] 		:= AllTrim(SF4->F4_CODIGO)	// Codigo  da UtilizaçãoNúmero - TES
	jTESAux["UsageDesc"]	:= AllTrim(SF4->F4_FINALID)	// Descrição da Utilização - - TES
	jTESAux["UsageType"]	:= ""						// Tipo da Utilização Ex. Entrada/Venda/Devolução/Consignação
	jTESAux["CreateDate"]	:= FormatDate( dDataInc )	// Data de Cadastro no sistema
	jTESAux["UpdateDate"]	:= FormatDate( dDataAlt )	// Data de Cadastro no sistema
	jTESAux["CentroContabil"] := "" 					// Código do Centro Contábil

	
	AAdd( jTES["UsageModel "], jTESAux )

	cParJSON 	:= jTES:GetJsonText("UsageModel ") 
	cParJSON	:= EncodeUTF8(cParJSON)	 		

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

