#Include "TOTVS.ch" 
#Include "RESTFUL.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "tbiconn.ch"
#INCLUDE "topconn.CH"

#DEFINE _sEnter CHR(10)+CHR(13)

/*--------------------------------------------------------------------------------------------------*
| Func:  MAPWMS02()                                                     							|
| Autor: Valmor Marchi                                              								|
| Data:  05/05/2020                                                   								|
| Desc:  Rotina para envio de cadastro de produtos para AKR	        							    |
|																									|
| Alterações .:  /                                                            						|
*--------------------------------------------------------------------------------------------------*/
User Function MAPWMS02(_aItens)
    Local _oPostItem as Object
    Local _sPath := "/api/Mahospitalar.V1_0_0/Itens/Add"
    Local _sPutErro := ""
    Local _aRetPost := {}
    Local _SEXCEPTION := ""

    Default _sJson := ""

    Private _sURL := U_MAPWMSAuth(1)


    _aHeader := MontaHead()
    _sJsonPost := MontaJson(_aItens)

    _oPostItem := FWRest():New(_sURL)
    _oPostItem:setPath(_sPath)
    _oPostItem:SetPostParams(_sJsonPost)	
    If _oPostItem:Post(_aHeader)
        _sRetorno := _oPostItem:GetResult()
        

        CONOUT("INTEGRANDO PRODUTO AO WMS MAPWMS02.: " + _sRetorno)

        _oGetRet := JSonObject():New()
        _cErro := _oGetRet:FromJson(_sRetorno)

        If Empty(_cErro)
            _bStatus := _oGetRet:GetJsonObject("status")
            If !_bStatus
                _sException := _oGetRet:GetJsonObject("exception")
                _aRetPost := {.F.,"ERRO POST ITENS RETORNO ==>"+ _sException}
            Else
                _aRetPost := {.T.,"Post ITENS Enviado com Sucesso!"}
            EndIf            
            FreeObj(_oGetRet)
        Else
            _sPutErro := "ERRO JSON ITENS ==> Erro ao converter o retorno da Api em JSON" 
            _aRetPost := {.F.,_sPutErro}
        Endif
                
    Else
        sPutErro  := "Erro POST Itens => "
        _sPutErro += _oPostItem:GetLastError() + _sEnter
        _sPutErro += "ERRO POST ITENS AUTH => " + _oPostItem:GetResult() + _sEnter
        _sPutErro += _sParam		
        _aRetPost := {.F.,_sPutErro}
    EndIf
    
    
	If !Empty(_sPutErro) .or. !Empty(_sException)
        cProduto := Alltrim(_aItens[1][2])
		FwMakeDir("integracao_wms\produto\erro")
		MEMOWRITE("integracao_wms\produto\erro\"+ xFilial("SB1") + cProduto + ".error", _sPutErro + CRLF +"Exception: " + _sException)
	EndIf 

    FreeObj(_oPostItem)


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
        conout("ERRO ITENS MONTA HEADER ==> Não foi possível montar o header: "+_aGetToken[2])
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
Static Function MontaJson(_aItens)
    Local _sJson := ""
    Local _x := 0
    Default _aItens := {}
    Local imobilizado := .F.

    For _x := 1 to len(_aItens)

        Do Case
        Case _aItens[_x][1] == "CODITEM"
            _sCodItem := _aItens[_x][2]
        Case _aItens[_x][1] == "NOMEITEM"
            _sNomeItem := EncodeUTF8( NoAcento( REPLACE(REPLACE(REPLACE(Alltrim(_aItens[_x][2] ), '"', ''), '\',''), '/','') ) )
        Case _aItens[_x][1] == "CODBAR"
            _sCodBar := Alltrim(_aItens[_x][2])
        Case _aItens[_x][1] == "CODGRP"
            _sCodGrp := Alltrim(_aItens[_x][2])
        Case _aItens[_x][1] == "NOMEGRP"
            _sNomeGrp := EncodeUTF8( NoAcento(Alltrim(_aItens[_x][2])))
        Case _aItens[_x][1] == "UM"
            _sUM := Alltrim(_aItens[_x][2])
        Case _aItens[_x][1] == "ULTCOMPRA"
            _sUltCompr := Alltrim(cValToChar(_aItens[_x][2]))
        Case _aItens[_x][1] == "NCM"
            _sNCM := Alltrim(_aItens[_x][2])
        Case _aItens[_x][1] == "ATIVO"
            _sAtivo := _aItens[_x][2]
        Case _aItens[_x][1] == "CODSEC"
            _sCodSec := Alltrim(_aItens[_x][2])
        Case _aItens[_x][1] == "NOMESEC"
            _sNomeSec := EncodeUTF8( NoAcento(Alltrim(_aItens[_x][2])))
        Case _aItens[_x][1] == "CODLN"
            _sCodLn := Alltrim(_aItens[_x][2])
        Case _aItens[_x][1] == "NOMELN"
            _sNomeLn := EncodeUTF8( NoAcento(Alltrim(_aItens[_x][2])))
        Case _aItens[_x][1] == "RMS"
            _sRMS := Alltrim(_aItens[_x][2])        
        Case _aItens[_x][1] == "CARDNAMEFAB"
            _sFabricante := EncodeUTF8( NoAcento(Alltrim(_aItens[_x][2])))
        Case _aItens[_x][1] == "CARDCODADD"
            _endFab := EncodeUTF8( NoAcento(Alltrim(_aItens[_x][2])))
        Case _aItens[_x][1] == "IMOBILIZADO"
            imobilizado := _aItens[_x][2]
        EndCase

    Next

    IF imobilizado == .T.
        _sJson := ' [                             '
        _sJson += '   {                           '
        _sJson += '     "ItemCode": "'+_sCodItem+'",     '
        _sJson += '     "SWW": "'+_sCodItem+'",          '
        _sJson += '     "Size": "",         '
        _sJson += '     "SizeDesc": "",     '
        _sJson += '     "ItemName": "'+_sNomeItem+'",     '
        _sJson += '     "CodeBars": "'+_sCodBar+'",     '
        _sJson += '     "ItmsGrpCod1": "'+_sCodLn+'",  '
        _sJson += '     "ItmsGrpNam1": "'+_sNomeLn+'",  '
        _sJson += '     "ItmsGrpCod2": "'+_sCodGrp+'",  '
        _sJson += '     "ItmsGrpNam2": "'+_sNomeGrp+'",  '
        _sJson += '     "ItmsGrpCod3": "'+_sCodSec+'",  '
        _sJson += '     "ItmsGrpNam3": "'+_sNomeSec+'",  '
        _sJson += '     "ItmsGrpCod4": "1",  '
        _sJson += '     "ItmsGrpNam4": "1",  '
        _sJson += '     "SalUnitMsr": "'+_sUM+'",   '
        _sJson += '     "CardCode": "1",     '
        _sJson += '     "CardName": "1",     '
        _sJson += '     "RMS": "'+_sRMS+'",     '
        _sJson += '     "CardNameFab": "'+_sFabricante+'",     '
        _sJson += '     "CardCodeAddress": "'+_endFab+'",     '
        _sJson += '     "LastPurPrc": '+_sUltCompr+',          '
        _sJson += '     "NCMCode": "'+_sNCM+'",      '
        _sJson += '     "Series": "1",       '
        _sJson += '     "SeriesName": "1",   '
        _sJson += '     "Weight": 0,              '
        _sJson += '     "validFor": '+IIF(_sAtivo, 'true','false')+', '
        _sJson += '     "Imobilizado": '+'true'+', '
        _sJson += '     "Multiplo": 0            '
        _sJson += '   }                           '
        _sJson += ' ]                             '
    ELSE
        _sJson := ' [                             '
        _sJson += '   {                           '
        _sJson += '     "ItemCode": "'+_sCodItem+'",     '
        _sJson += '     "SWW": "'+_sCodItem+'",          '
        _sJson += '     "Size": "",         '
        _sJson += '     "SizeDesc": "",     '
        _sJson += '     "ItemName": "'+_sNomeItem+'",     '
        _sJson += '     "CodeBars": "'+_sCodBar+'",     '
        _sJson += '     "ItmsGrpCod1": "'+_sCodLn+'",  '
        _sJson += '     "ItmsGrpNam1": "'+_sNomeLn+'",  '
        _sJson += '     "ItmsGrpCod2": "'+_sCodGrp+'",  '
        _sJson += '     "ItmsGrpNam2": "'+_sNomeGrp+'",  '
        _sJson += '     "ItmsGrpCod3": "'+_sCodSec+'",  '
        _sJson += '     "ItmsGrpNam3": "'+_sNomeSec+'",  '
        _sJson += '     "ItmsGrpCod4": "1",  '
        _sJson += '     "ItmsGrpNam4": "1",  '
        _sJson += '     "SalUnitMsr": "'+_sUM+'",   '
        _sJson += '     "CardCode": "1",     '
        _sJson += '     "CardName": "1",     '
        _sJson += '     "RMS": "'+_sRMS+'",     '
        _sJson += '     "CardNameFab": "'+_sFabricante+'",     '
        _sJson += '     "CardCodeAddress": "'+_endFab+'",     '
        _sJson += '     "LastPurPrc": '+_sUltCompr+',          '
        _sJson += '     "NCMCode": "'+_sNCM+'",      '
        _sJson += '     "Series": "1",       '
        _sJson += '     "SeriesName": "1",   '
        _sJson += '     "Weight": 0,              '
        _sJson += '     "validFor": '+IIF(_sAtivo, 'true','false')+', '
        _sJson += '     "Multiplo": 0            '
        _sJson += '   }                           '
        _sJson += ' ]                             '
    ENDIF


	FwMakeDir("integracao_wms\produto\")
	MEMOWRITE("integracao_wms\produto\" + xFilial("SB1") + _sCodItem + ".json", _sJson )

Return _sJson
