#Include "TOTVS.ch" 
#Include "RESTFUL.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "tbiconn.ch"
#INCLUDE "topconn.CH"

#DEFINE _sEnter CHR(10)+CHR(13)


/*--------------------------------------------------------------------------------------------------*
| Func:  MAPWMS01()                                                     							|
| Autor: Valmor Marchi                                              								|
| Data:  05/05/2020                                                   								|
| Desc:  Rotina para gerar o token de autenticação nas api's da AKR								    |
|																									|
| Alterações .:  /                                                            						|
*--------------------------------------------------------------------------------------------------*/
User Function MAPWMS01()
    Local _oGetToken as Object
    Local _sPath := "/token"
    Local _sPutErro := "Erro GET Token => "
	Local _sRetorno := ""
    Local _sToken := ""
    Local _cErro := ""
    Local _sParam := ""
    Local _aRetAuth := {}
    Local _aRetToken := {}
    Local _aHeader := {}
    Local aAuth     := {}

    Private _sURL       := ""
    Private _sUser      := ""
    Private  _sSenha    := ""
	
    aAuth   := U_MAPWMSAuth()
    _sURL   := aAuth[1]
    _sUser  := aAuth[2]
    _sSenha := aAuth[3]


    _aRetAuth := AuthAKR()

    If _aRetAuth[1]

        _sToken := StrTran( _aRetAuth[2], '"','') 
        _aHeader := HeadAKR("F")
        _sParam := MontaParam(_sToken)

        oRestToken := FWRest():New(_sURL)
        oRestToken:setPath(_sPath)
        oRestToken:SetPostParams(_sParam)	
        If oRestToken:Post(_aHeader)
            _sRetorno := oRestToken:GetResult()
            
            _oGetToken := JSonObject():New()
            _cErro := _oGetToken:FromJson(_sRetorno)
                    
            If Empty(_cErro)
                _sToken := _oGetToken:GetJsonObject("access_token")
                _aRetToken := {.T.,_sToken}
                FreeObj(_oGetToken)
            Else
                _sPutErro := "ERRO JSON ==> Erro ao converter o retorno da Api em JSON" 
                _aRetToken := {.F.,_sPutErro}
            Endif
                    
        Else
            _sPutErro += oRestToken:GetLastError() + _sEnter
            _sPutErro += "Erro POST AUTH => " + oRestToken:GetResult() + _sEnter
            _sPutErro += _sParam		
            _aRetToken := {.F.,_sPutErro}
        EndIf
        
        FreeObj(oRestToken)
        
    Else

    EndIf

Return _aRetToken


/*--------------------------------------------------------------------------------------------------*
| Func:  AuthAKR(_sToken)                                                     						|
| Autor: Valmor Marchi                                              								|
| Data:  04/02/2022                                                   								|
| Desc:  Função responsável por Autenticar Usuário e Senha de acesso AKR e retornar o token de au-  |
|		tenticação																					|
| Alterações .:  /                                                            						|
*--------------------------------------------------------------------------------------------------*/
Static Function AuthAKR()
	Local oRestAuth as Object
    Local _sPath := "/api/api.V1_0_0/info/Encrypt?value="+_sSenha    
    Local _aHeadRest := HeadAKR("J")
	Local _sRetorno := ""
	Local _sPutErro := ""
    Local _aRet := {}

	oRestAuth := FWRest():New(_sURL)
	oRestAuth:setPath(_sPath)
	oRestAuth:SetPostParams()	
	If oRestAuth:Post(_aHeadRest)
		_sRetorno := oRestAuth:GetResult()
        _aRet := {.T.,_sRetorno}		
	Else
		_sPutErro += oRestAuth:GetLastError() + _sEnter
		//_sPutErro += "Erro POST AUTH => " + oRestAuth:GetResult() + _sEnter
		_aRet := {.F.,_sPutErro}
	EndIf
	
	FreeObj(oRestAuth)
Return _aRet



/*--------------------------------------------------------------------------------------------------*
| Func:  HeadAKR(_sToken)                                                     							|
| Autor: Valmor Marchi                                              								|
| Data:  04/02/2022                                                   								|
| Desc:  Função responsável por montar o cabeçalho das resquisições para AKR		 				|
|																									|
| Alterações .:  /                                                            						|
*--------------------------------------------------------------------------------------------------*/
Static Function HeadAKR(_sTpCType)
	Local aHeadRest := {}
	Default _sToken := "J"
	
    If _sTpCType == "F"
        AADD(aHeadRest,"Content-Type: application/x-www-form-urlencoded" )                         
    Else
        AADD(aHeadRest,"Content-Type:application/json" ) 
    EndIf

Return aHeadRest



/*--------------------------------------------------------------------------------------------------*
| Func:  MontaParam()                                                     							|
| Autor: Valmor Marchi                                              								|
| Data:  04/02/2022                                                   								|
| Desc:  Função responsável por montar o BODY para envio da requisição de autenticação da API  da AKR|
|																									|
| Alterações .:  /                                                            						|
*--------------------------------------------------------------------------------------------------*/
Static Function MontaParam(_sToken)
	Local _sParam := ""
	
    /*
    _sParam := '{"grant_type" : password,'+;
              '  "username" : '+_sUser+', '+;
              '  "password" : '+_sToken+' '+;
              '}'
    */

    _sToken := StrTran(_sToken,"+","%2B")
    
    _sParam := "grant_type=password&username="+_sUser+"&password="+EncodeUTF8(Alltrim(_sToken))

Return _sParam


User Function MAPWMSAuth( nOption )

Local cURL      := ""
Local cUser     := ""
Local cPassword := ""
Local aAuth     := {}
Local cRet      := {}
Local lAuthPrd  := SuperGetMv( "MA_AuthPRD",, .F. ) 
    
Default nOption := 0

    If ( lAuthPrd )

        cURL      := SuperGetMv( "MA_URLPRD",,"http://ma.akrsistemas.com.br:8082")
        cUser     := SuperGetMv( "MA_USRPRD",,"Mahospitalar")
        cPassword := SuperGetMv( "MA_PSWPRD",,"Pass4Mahospitalar")

    Else

        //cURL      := SuperGetMv( "MA_PRDHOM",,"http://10.117.83.103:32555") // HOMOLOGAÇÃO
        cURL      := SuperGetMv( "MA_PRDHOM",,"http://10.117.83.103:31000")  // PRODUÇÃO
        cUser     := SuperGetMv( "MA_USRHOM",,"Mahospitalar")
        cPassword := SuperGetMv( "MA_PSWHOM",,"Pass4Mahospitalar")

    EndIf 

    aAuth := { cUrl, cUser, cPassword }

    If ( nOption >= 1 .And. nOption <= 3 )

        cRet := aAuth[ nOption ] 

        Return( cRet )
    EndIf 

Return( aAuth )

