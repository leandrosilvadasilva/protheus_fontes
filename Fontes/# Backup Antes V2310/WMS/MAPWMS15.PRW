#Include "TOTVS.ch" 
#Include "RESTFUL.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "tbiconn.ch"
#INCLUDE "topconn.CH"

/*--------------------------------------------------------------------------------------------------*
| Func:  MAPWMS15()                                                     							|
| Autor: Iatan Santos                                               								|
| Data:  23/06/2022                                                 								|
| Desc:  Rotina para envio do OPERA��ES ( C6_OPER ) para AKR	                                    |   
|																									|
| Alterações .:  /                                                            						|
*--------------------------------------------------------------------------------------------------*/
User Function MAPWMS15( nRecnoSX5, nOperation)

Local _oPostUser as Object
Local _sPath := "/api/Mahospitalar.V1_0_0/Usage/Add"
Local _sPutErro := ""
Local _aRetPost := {}

Default nRecnoSX5	:= SX5->( Recno() )
Default nOperation	:= 3

    Private _sURL := U_MAPWMSAuth(1)

    _aHeader	:= MontaHead()
    _sJsonPost 	:= MontaJson( nRecnoSX5 )

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
                _aRetPost := {.F.,"ERRO POST OPERACAO RETORNO ==>"+ _sException}
            Else
                _aRetPost := {.T.,"Post OPERA��O Enviada com Sucesso!"}
            EndIf            
            FreeObj(_oGetRet)
        Else
            _sPutErro := "ERRO JSON TES ==> Erro ao converter o retorno da Api em JSON" 
            _aRetPost := {.F.,_sPutErro}
        Endif
    Else
        _sPutErro += "ERRO POST OPERACAO AUTH => " + _oPostUser:GetResult() + CRLF
        _sPutErro += _sParam		
        _aRetPost := {.F.,_sPutErro}
    EndIf
    
	If !Empty(_sPutErro) .or. !Empty(_sException)
		FwMakeDir("integracao_wms\OPER\erro")
		MEMOWRITE("integracao_wms\OPER\erro\"+ SX5->X5_FILIAL + SX5->X5_CHAVE + ".error", _sPutErro + CRLF +"Exception: " + _sException)

        FwMakeDir("integracao_wms\OPER\")
        MEMOWRITE("integracao_wms\OPER\"+ SX5->X5_FILIAL + SX5->X5_CHAVE + ".json", _sJsonPost )
        
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
        conout("ERRO OPERACAO MONTA HEADER ==> Nao foi possivel montar o header: "+_aGetToken[2])
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
Static Function MontaJson( nRecnoSX5 )
   
Local aArea 	:= GetArea()
Local jOPER		:= Nil 
Local jOPERAux	:= Nil 
Local cParJSON	:= ""


	If nRecnoSX5 > 0 
		SX5->( DbGoTo(  nRecnoSX5 ) )
	EndIf 


	jOPER 				:= JSonObject():New()
	jOPER["UsageModel "]	:= {}

	jOPERAux		:= JSonObject():New()
	 
	jOPERAux["Usage"] 		:= AllTrim(SX5->X5_CHAVE)	// Codigo  da OPERACAO
	jOPERAux["UsageDesc"]	:= AllTrim(SX5->X5_DESCRI)	// Descri��o da OPERACAO

	
	AAdd( jOPER["UsageModel "], jOPERAux )

	cParJSON 	:= jOPER:GetJsonText("UsageModel ") 
	cParJSON	:= EncodeUTF8(cParJSON)	 		

RestArea( aArea )  

Return( cParJSON )


