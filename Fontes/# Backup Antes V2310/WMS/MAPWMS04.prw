#Include "TOTVS.ch" 
#Include "RESTFUL.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "tbiconn.ch"
#INCLUDE "topconn.CH"

#DEFINE _sEnter CHR(10)+CHR(13)

/*--------------------------------------------------------------------------------------------------*
| Func:  MAPWMS04()                                                     							|
| Autor: Valmor Marchi                                              								|
| Data:  05/05/2020                                                   								|
| Desc:  Rotina para envio de Usuarios para AKR	        	                                        |   
|																									|
| Alterações .:  /                                                            						|
*--------------------------------------------------------------------------------------------------*/
User Function MAPWMS04(_aVend)
    Local _oPostUser as Object
    Local _sPath := "/api/Mahospitalar.V1_0_0/Usuario/Add"
    Local _sPutErro := ""
    Local _aRetPost := {}
    Local _sException   := ""

    Default _sJson := ""

    Private _sURL := U_MAPWMSAuth(1)

    _aHeader := MontaHead()
    _sJsonPost := MontaJson(_aVend)

    _oPostUser := FWRest():New(_sURL)
    _oPostUser:setPath(_sPath)
    _oPostUser:SetPostParams(_sJsonPost)	
    If _oPostUser:Post(_aHeader)
        _sRetorno := _oPostUser:GetResult()
        
        _oGetRet := JSonObject():New()
        _cErro := _oGetRet:FromJson(_sRetorno)
                
        If Empty(_cErro)
            _bStatus := _oGetRet:GetJsonObject("status")
            If !_bStatus
                _sException := _oGetRet:GetJsonObject("exception")
                _aRetPost := {.F.,"ERRO POST USER RETORNO ==>"+ _sException}
            Else
                _aRetPost := {.T.,"Post USER Enviado com Sucesso!"}
            EndIf            
            FreeObj(_oGetRet)
        Else
            _sPutErro := "ERRO JSON USER ==> Erro ao converter o retorno da Api em JSON" 
            _aRetPost := {.F.,_sPutErro}
        Endif
                
    Else
        _sPutErro := "Erro POST USER => "
        _sPutErro += _oPostUser:GetLastError() + _sEnter
        _sPutErro += "ERRO POST USER AUTH => " + _oPostUser:GetResult() + _sEnter
        _sPutErro += _sParam		
        _aRetPost := {.F.,_sPutErro}
    EndIf
    
    FreeObj(_oPostUser)


Return _aRetPost


/*--------------------------------------------------------------------------------------------------*
| Func:  MontaHead()                                                     							|
| Autor: Valmor Marchi                                              								|
| Data:  04/02/2022                                                   								|
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
        conout("ERRO USER MONTA HEADER ==> Não foi possível montar o header: "+_aGetToken[2])
    EndIf
        
    
Return _aHeadRest

/*--------------------------------------------------------------------------------------------------*
| Func:  MontaJson()                                                     							|
| Autor: Valmor Marchi                                              								|
| Data:  04/02/2022                                                   								|
| Desc:  Função responsável por montar o cabeçalho das resquisições para AKR		 				|
|																									|
| Alterações .:  /                                                            						|
*--------------------------------------------------------------------------------------------------*/
Static Function MontaJson(_aDados)
    Local _sJson := ""
    Local _x := 0
    Default _aDados := {}

    For _x := 1 to len(_aDados)

        Do Case
        Case _aDados[_x][1] == "CODUSER"
            _sCodUser := Alltrim(_aDados[_x][2])
        Case _aDados[_x][1] == "NOMEUSER"
            _sNomeUser := Alltrim(_aDados[_x][2])
        Case _aDados[_x][1] == "OBS"
            _sObsUser := Alltrim(_aDados[_x][2])
        Case _aDados[_x][1] == "VLRCOMIS"
            _sComisUser := Alltrim(cValToChar(_aDados[_x][2]))
        Case _aDados[_x][1] == "CODGRP"
            _sCodGrp := Alltrim(_aDados[_x][2])
        Case _aDados[_x][1] == "LOCK"
            _sLockUser := Alltrim(_aDados[_x][2])
        Case _aDados[_x][1] == "CARDCODE"
            _sCardCode := Alltrim(_aDados[_x][2])
        Case _aDados[_x][1] == "FONE"
            _sFone := Alltrim(_aDados[_x][2]) 
        Case _aDados[_x][1] == "EMAIL"
            _sEmail := Alltrim(_aDados[_x][2]) 
        Case _aDados[_x][1] == "ATIVO"
            _sAtivo := _aDados[_x][2]
        EndCase
    Next

    _sJson := '[                          '
_sJson += '  {                        '
_sJson += '    "SlpCode": "'+_sCodUser+'",   '
_sJson += '    "SlpName": "'+_sNomeUser+'",   '
_sJson += '    "Memo": "'+_sObsUser+'",      '
_sJson += '    "Commission": '+_sComisUser+',       '
_sJson += '    "GroupCode": '+_sCodGrp+',        '
_sJson += '    "Locked": "'+_sLockUser+'",    '
_sJson += '    "CardCode": "'+_sCardCode+'",  '
_sJson += '    "Active": "'+IIF(_sAtivo, 'Y','N')+'",    '
_sJson += '    "Telephone": "'+_sFone+'", '
_sJson += '    "Mobil": "'+_sFone+'",     '
_sJson += '    "Fax": "",       '
_sJson += '    "Email": "'+_sEmail+'"      '
_sJson += '  }                        '
_sJson += ']                          '

Return _sJson
