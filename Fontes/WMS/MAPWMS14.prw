#Include "TOTVS.ch" 
#Include "RESTFUL.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "tbiconn.ch"
#INCLUDE "topconn.CH"

/*--------------------------------------------------------------------------------------------------*
| Func:  MAPWMS14()                                                     							|
| Autor: Lucas Brustolin                                              								|
| Data:  Fev/2022                                                   								|
| Desc:  Rotina para envio do Tipo de Entrada\Saida (Nota) para AKR	        	                    |   
|																									|
|    /api/Mahospitalar.V1_0_0/Pagamentos/AddCondicaoPagamento
|    
|   [
|     {
|       "GroupNum": "c�digo",
|       "PymntGroup": "descri��o"
|     }
|   ]
|                                                                            						|
*--------------------------------------------------------------------------------------------------*/
User Function MAPWMS14( nRecnoSE4, nOperation)

Local _oPostUser as Object
Local _sPath := "/api/Mahospitalar.V1_0_0/Pagamentos/AddCondicaoPagamento"
Local _sPutErro := ""
Local _aRetPost := {}

Default nRecnoSE4	:= SE4->( Recno() )
Default nOperation	:= 3

    Private _sURL := U_MAPWMSAuth(1)

    _aHeader	:= MontaHead()
    _sJsonPost 	:= MontaJson( nRecnoSE4 )

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
                _aRetPost := {.F.,"ERRO POST Condicao Pagamento RETORNO ==>"+ _sException}
            Else
                _aRetPost := {.T.,"Post Condicao Pagamento Enviada com Sucesso!"}
            EndIf            
            FreeObj(_oGetRet)
        Else
            _sPutErro := "ERRO JSON Condicao Pagamento ==> Erro ao converter o retorno da Api em JSON" 
            _aRetPost := {.F.,_sPutErro}
        Endif
    Else
        _sPutErro += _oPostUser:GetLastError() + CRLF
        _sPutErro += "ERRO POST Condicao Pagamento AUTH => " + _oPostUser:GetResult() + CRLF
        _sPutErro += _sParam		
        _aRetPost := {.F.,_sPutErro}
    EndIf
    
	If !Empty(_sPutErro) .or. !Empty(_sException)
		FwMakeDir("integracao_wms\condpag\erro")
		MEMOWRITE("integracao_wms\condpag\erro\"+ AllTrim(SE4->E4_CODIGO) + ".error", _sPutErro + CRLF +"Exception: " + _sException)

        FwMakeDir("integracao_wms\condpag\")
        MEMOWRITE("integracao_wms\condpag\"+ SE4->E4_CODIGO +".json", _sJsonPost )
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
        conout("ERRO CONDICAO DE PAGAMENTO MONTA HEADER ==> Nao foi possivel montar o header: "+_aGetToken[2])
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
Static Function MontaJson( nRecnoSE4 )
   
Local aArea 	:= GetArea()
Local jCond		:= Nil
Local jCondPag  := Nil  
Local cParJSON	:= ""

	If nRecnoSE4 > 0 
		SE4->( DbGoTo(  nRecnoSE4 ) )
	EndIf 

	jCondPag 				:= JSonObject():New()
	jCondPag["condpagto"]	:= {}


	jCond 				    := JSonObject():New()	 
	jCond["GroupNum"]	    := SE4->E4_CODIGO           // N�mero do Documento - Nota Fiscal
	jCond["PymntGroup"]    := AllTrim(SE4->E4_DESCRI)	// N�mero da Nota Fiscal
 
	
	AAdd( jCondPag["condpagto"], jCond )

	cParJSON 	:= jCondPag:GetJsonText("condpagto") 

RestArea( aArea )  

Return( cParJSON )


