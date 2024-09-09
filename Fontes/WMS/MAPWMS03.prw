#Include "TOTVS.ch" 
#Include "RESTFUL.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "tbiconn.ch"
#INCLUDE "topconn.CH"

#DEFINE _sEnter CHR(10)+CHR(13)

/*--------------------------------------------------------------------------------------------------*
| Func:  MAPWMS03()                                                     							|
| Autor: Valmor Marchi                                              								|
| Data:  05/05/2020                                                   								|
| Desc:  Rotina para envio de cadastro de clientes (Parceiros Negocios - PN) para AKR	        	|
|																									|
| Alterações .:  /                                                            						|
*--------------------------------------------------------------------------------------------------*/
User Function MAPWMS03(_aClientes)
    Local _oPostPN as Object
    Local _sPath := "/api/Mahospitalar.V1_0_0/PN/Add"
    Local _sPutErro := "Erro POST PN => "
    Local _aRetPost := {}

    Default _sJson := ""

    Private _sURL := U_MAPWMSAuth(1)
    

    _aHeader := MontaHead()
    _sJsonPost := MontaJson(_aClientes)

    _oPostPN := FWRest():New(_sURL)
    _oPostPN:setPath(_sPath)
    _oPostPN:SetPostParams(_sJsonPost)	
    If _oPostPN:Post(_aHeader)
        _sRetorno := _oPostPN:GetResult()
        
        _oGetRet := JSonObject():New()
        _cErro := _oGetRet:FromJson(_sRetorno)
                
        If Empty(_cErro)
            _bStatus := _oGetRet:GetJsonObject("status")
            If !_bStatus
                _sException := _oGetRet:GetJsonObject("exception")
                _aRetPost := {.F.,"ERRO POST PN RETORNO ==>"+ _sException}
            Else
                _aRetPost := {.T.,"Post PN Enviado com Sucesso!"}
            EndIf            
            FreeObj(_oGetRet)
        Else
            _sPutErro := "ERRO JSON PN ==> Erro ao converter o retorno da Api em JSON" 
            _aRetPost := {.F.,_sPutErro}
        Endif
                
    Else
        _sPutErro += _oPostPN:GetLastError() + _sEnter
        _sPutErro += "ERRO POST PN AUTH => " + _oPostPN:GetResult() + _sEnter
        _sPutErro += _sParam		
        _aRetPost := {.F.,_sPutErro}
    EndIf
    
    FreeObj(_oPostPN)


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
        AADD(_aHeadRest,"Content-Type:application/json; charset=iso-8859-1" ) 
        AADD(_aHeadRest, "Authorization: Bearer "+Alltrim(_aGetToken[2]))
    Else
        conout("ERRO PN MONTA HEADER ==> Não foi possível montar o header: "+_aGetToken[2])
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
    Local _sJson    := ""
    Local _x        := 0
    Local cCondPag  := ""
    Local cDescPag  := ""
    Default _aDados := {}

    For _x := 1 to len(_aDados)

        Do Case
        Case _aDados[_x][1] == "CODPN"
            _sCodPN := Alltrim(_aDados[_x][2])
        Case _aDados[_x][1] == "RAZAO"
            _sNomePN := EncodeUTF8( REPLACE(NoAcento(Alltrim(_aDados[_x][2])), '"','') )
        Case _aDados[_x][1] == "TIPO"
            _sTipoPN := Alltrim(_aDados[_x][2])
        Case _aDados[_x][1] == "CODGRP"
            _sCodGrp := Alltrim(cValToChar(_aDados[_x][2]))
        Case _aDados[_x][1] == "NOMEGRP"
            _sNomeGrp := EncodeUTF8( NoAcento(Alltrim(_aDados[_x][2])))
        Case _aDados[_x][1] == "UF"
            _sUF := Alltrim(_aDados[_x][2])
        Case _aDados[_x][1] == "CIDADE"
            _sCidade := EncodeUTF8( NoAcento(Alltrim(_aDados[_x][2])))
        Case _aDados[_x][1] == "BAIRRO"
            _sBairro := EncodeUTF8( NoAcento(Alltrim(_aDados[_x][2])))
        Case _aDados[_x][1] == "RUA"
            _sRua := EncodeUTF8( NoAcento(Alltrim(_aDados[_x][2])))
        Case _aDados[_x][1] == "CEP"
            _sCEP := Alltrim(_aDados[_x][2])
        Case _aDados[_x][1] == "FONE"
            _sFone := Alltrim(_aDados[_x][2]) 
        Case _aDados[_x][1] == "CGC"
            _sCGC := Alltrim(_aDados[_x][2]) 
        Case _aDados[_x][1] == "IE"
            _sIE := Alltrim(_aDados[_x][2]) 
        Case _aDados[_x][1] == "IM"
            _sIM := Alltrim(_aDados[_x][2])                                        
        Case _aDados[_x][1] == "ATIVO"
            _sAtivo := _aDados[_x][2]
        Case _aDados[_x][1] == "CONDPAG"

            // GroupNum = Código da Condição de Pagamento
            // PymntGroup = Descrição da Condição de Pagamento
            cCondPag := PadR(_aDados[_x][2],TamSx3("E4_COND")[1] )

			DBSelectArea("SE4")
			DBSetOrder(1)
			DBSeek(xFilial("SE4")+cCondPag)
			cDescPag :=  EncodeUTF8( NoAcento(AllTrim(SE4->E4_DESCRI)))

        EndCase
    Next

    _sJson := '['
    _sJson += '  {'
    _sJson += '    "DocEntry": '+_sCodPN+', '
    _sJson += '    "CardCode": "'+_sCodPN+'", '
    _sJson += '    "CardName": "'+_sNomePN+'",'
    _sJson += '    "WhsCode": "",       '
    _sJson += '    "CardFName": "",     '
    _sJson += '    "CardType": "'+_sTipoPN+'",'
    _sJson += '    "GroupCode": '+_sCodGrp+', '
    _sJson += '    "GroupName": "'+_sNomeGrp+'",     '
    _sJson += '    "E_Mail": "",        '
    _sJson += '    "State1": "'+_sUf+'",      '
    _sJson += '    "Block": "'+_sBairro+'",   '
    _sJson += '    "Territory": "",     '
    _sJson += '    "descript": "",      '
    _sJson += '    "CreditLine": 0,           '
    _sJson += '    "DebtLine": 0,             '
    _sJson += '    "Balance": 0,              '
    _sJson += '    "SlpCode": "",       '
    _sJson += '    "SlpName": "",       '
    _sJson += '    "OpenValue": 0,            '
    _sJson += '    "Address": "'+_sRua+'",       '
    _sJson += '    "City": "'+_sCidade+'",          '
    _sJson += '    "Country": "",       '
    _sJson += '    "ZipCode": "'+_sCEP+'",       '
    _sJson += '    "Telefone": "'+_sFone+'",      '
    _sJson += '    "CNPJ": "'+_sCGC+'",          '
    _sJson += '    "IE": "'+_sIE+'",            '
    _sJson += '    "IM": "'+_sIM+'",            '
    _sJson += '    "validFor": '+IIF(_sAtivo, 'true','false')+','    
    _sJson += '    "GroupNum": 0,             '
    _sJson += '    "PymntGroup": "",    '
    _sJson += '    "ExtraDays": 0,            '
    _sJson += '    "PayMethCod": 0,           '
    _sJson += '    "PayMethDesc": "",   '
    _sJson += '    "ObsComercial": "",  '
    _sJson += '    "MainUsage": 0,             '
    _sJson += '    "GroupNum": "'   + cCondPag + '",    '
    _sJson += '    "PymntGroup": "' + cDescPag + '"     '
    _sJson += '  }                            '
    _sJson += ']                              '
Return _sJson
