#Include "TOTVS.ch" 
#Include "RESTFUL.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "tbiconn.ch"
#INCLUDE "topconn.CH"

#DEFINE _sEnter CHR(10)+CHR(13)

/*--------------------------------------------------------------------------------------------------*
| Func:  MAPWMS05()                                                     							|
| Autor: Valmor Marchi                                              								|
| Data:  05/05/2020                                                   								|
| Desc:  Rotina para envio de Pré-Notas para AKR	        	                                    |   
|																									|
| Alterações .:  /                                                            						|
*--------------------------------------------------------------------------------------------------*/
User Function MAPWMS05(_aPreNF)
    Local _oPostUser as Object
    Local _sPath := "/api/Mahospitalar.V1_0_0/Recebimento/Add"
    Local _sPutErro := ""
    Local _aRetPost := {}
    Local cNumDoc   := ""
    Local cSerDoc   := ""
    Local _sException   := ""

    Default _sJson := ""

    Private _sURL := U_MAPWMSAuth(1)

    _aHeader := MontaHead()
    _sJsonPost := MontaJson(_aPreNF)

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
                _aRetPost := {.F.,"ERRO POST PRE-NOTA RETORNO ==>"+ _sException}
            Else
                _aRetPost := {.T.,"Post PRE-NOTA Enviado com Sucesso!"}

                DbSelectArea("SD1")
                

            EndIf            
            FreeObj(_oGetRet)
        Else
            _sPutErro := "ERRO JSON PRE-NOTA ==> Erro ao converter o retorno da Api em JSON" 
            _aRetPost := {.F.,_sPutErro}
        Endif
                
    Else
        _sPutErro := "Erro POST PRE-NOTA => "
        _sPutErro += _oPostUser:GetLastError() + _sEnter
        _sPutErro += "ERRO POST PRE-NOTA AUTH => " + _oPostUser:GetResult() + _sEnter
        _sPutErro += _sParam		
        _aRetPost := {.F.,_sPutErro}
    EndIf
    
    
	If !Empty(_sPutErro) .or. !Empty(_sException)
        IF LEN(_aPreNF) > 0
            cNumDoc := Alltrim(_aPreNF[1][1][2])
            cSerDoc := Alltrim(_aPreNF[1][2][2]) 
            FwMakeDir("integracao_wms\prenota\erro")
            MEMOWRITE("integracao_wms\prenota\erro\"+ xFilial("SF1") + cNumDoc + cSerDoc + ".error", _sPutErro + CRLF +"Exception: " + _sException)
            //Iatan em 29/06/2022
            //FwMakeDir("integracao_wms\prenota\")
            //MEMOWRITE("integracao_wms\prenota\" + xFilial("SF1") + cNumDoc + cSerDoc + ".json", _sJsonPost )
        ENDIF
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
        conout("ERRO PRE-NOTA MONTA HEADER ==> Não foi possível montar o header: "+_aGetToken[2])
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
    Local _y := 0
    Local tpNFE
    Local _sImobilizado := .F.
    Default _aDados := {}

    _sJson += '['

    For _x := 1 to len(_aDados)
        For _y := 1 to len(_aDados[_x])
            Do Case
            Case _aDados[_x][_y][1] == "FILIAL"
                _sFilial := Alltrim(_aDados[_x][_y][2])
            Case _aDados[_x][_y][1] == "NUMDOC"
                _sNumDoc := Alltrim(_aDados[_x][_y][2])
            Case _aDados[_x][_y][1] == "SERIEDOC"
                _sSerie := Alltrim(_aDados[_x][_y][2])
            Case _aDados[_x][_y][1] == "EMISSAO"
                _sEmissao := FWTimeStamp(6, _aDados[_x][_y][2]) // 6 - Formato UTC aaaa-mm-ddThh:mm:ssZ (Transforma a data atual em uma data e hora GMT 0)
            Case _aDados[_x][_y][1] == "NROITEM"
                _sItem := Alltrim(_aDados[_x][_y][2])
            Case _aDados[_x][_y][1] == "CODITEM"
                _sCodProd := _aDados[_x][_y][2]
            Case _aDados[_x][_y][1] == "DESCITEM"
                _sDescProd := EncodeUTF8( NoAcento( Alltrim(_aDados[_x][_y][2]) ) )
            Case _aDados[_x][_y][1] == "REFERENCIA"
                _sRefer := _aDados[_x][_y][2]
            Case _aDados[_x][_y][1] == "TAMANHO"
                _sTamanho := Alltrim(_aDados[_x][_y][2]) 
            Case _aDados[_x][_y][1] == "CODFORNEC"
                _sCodForn := Alltrim(_aDados[_x][_y][2]) 
            Case _aDados[_x][_y][1] == "NOMEFORNEC"
                _sNomeForn := EncodeUTF8( NoAcento( Alltrim(_aDados[_x][_y][2]) ) )
            Case _aDados[_x][_y][1] == "CODFABRIC"
                _sCodFabr := Alltrim(_aDados[_x][_y][2])
            Case _aDados[_x][_y][1] == "NOMEFABRIC"
                _sNomeFabr := EncodeUTF8( NoAcento( Alltrim(_aDados[_x][_y][2]) ) )
            Case _aDados[_x][_y][1] == "QTDE"
                _sQtde := Alltrim(cValToChar(_aDados[_x][_y][2]))
            Case _aDados[_x][_y][1] == "DOCSTATUS"
                _sDocStatus := Alltrim(_aDados[_x][_y][2])
            Case _aDados[_x][_y][1] == "TIPO"
                _sTipo := Alltrim(_aDados[_x][_y][2])
            Case _aDados[_x][_y][1] == "DATAFABRIC"
                _sDtFabr := FWTimeStamp(6, _aDados[_x][_y][2])
            Case _aDados[_x][_y][1] == "DATAVALID"
                _sDtValid := FWTimeStamp(6, _aDados[_x][_y][2])  
            Case _aDados[_x][_y][1] == "LOTE"
                _sLote := Alltrim(_aDados[_x][_y][2])
            Case _aDados[_x][_y][1] == "IMOBILIZADO"
                _sImobilizado := _aDados[_x][_y][2]
            Case _aDados[_x][_y][1] == "CARDCODESAIDA"
                _sCARDCODESAIDA := _aDados[_x][_y][2]
            Case _aDados[_x][_y][1] == "SERIALSAIDA"
                _sSERIALSAIDA := _aDados[_x][_y][2]
            Case _aDados[_x][_y][1] == "LINENUMSAIDA"
                _sLINENUMSAIDA := _aDados[_x][_y][2]
            Case _aDados[_x][_y][1] == "PEDIDO"
                _sPedido := _aDados[_x][_y][2]
            EndCase
        Next

        tmpCGC := POSICIONE("SA2", 1, xFilial("SA2")+_sCodForn, "A2_CGC")
        IF SUBSTR(SM0->M0_CGC, 1, 8) ==  SUBSTR(tmpCGC, 1, 8) // VALIDA A RAIZ DO CNPJ
            _sTipoNFE := "5"
        ELSE
            _sTipoNFE := "0"
        ENDIF

        IF _sImobilizado == .T.
            
            IF ISINCALLSTACK( "SA103Devol" ) // DEVOLUÇÃO DE ATIVO
                _sJson += '  {                                       '
                _sJson += '    "CardCodeFilial": "'+_sFilial+'",     '
                _sJson += '    "DocNum": "'+_sItem+'",               '
                _sJson += '    "Serial": "'+_sNumDoc+'",             '
                _sJson += '    "Series": "'+_sSerie+'",             '
                _sJson += '    "DocDate": "'+_sEmissao+'",           '
                _sJson += '    "ItemCode": "'+_sCodProd+'",          '
                _sJson += '    "SWW": "'+_sRefer+'",                 '
                _sJson += '    "Description": "'+_sDescProd+'",      '
                _sJson += '    "Size": "'+_sTamanho+'",              '
                _sJson += '    "CardCode": "'+_sCodForn+'",          '
                _sJson += '    "CardName": "'+_sNomeForn+'",         '
                _sJson += '    "CardCodeFab": "'+_sCodFabr+'",       '
                _sJson += '    "CardCodeNameFab": "'+_sNomeFabr+'",  '
                _sJson += '    "Quantity": '+_sQtde+',               '
                _sJson += '    "DocStatus": "'+_sDocStatus+'",       '
                _sJson += '    "ObjType": "'+_sTipo+'",              '
                _sJson += '    "FabricacaoDate": "'+_sDtFabr+'",     '
                _sJson += '    "ValidadeDate": "'+_sDtValid+'",      '
                _sJson += '    "Lote": "'+_sLote+'",                 '
                _sJson += '    "Imobilizado": true, '
                _sJson += '    "TipoNFE": 1,'
                _sJson += '    "CardCode_Saida": "' + _sCARDCODESAIDA + '",'
                _sJson += '    "Serial_Saida": "' + _sSERIALSAIDA + '",'
                _sJson += '    "LineNum_Saida": "' + _sLINENUMSAIDA + '"'
                _sJson += '},'
            ELSE
                _sJson += '  {                                       '
                _sJson += '    "CardCodeFilial": "'+_sFilial+'",     '
                _sJson += '    "DocNum": "'+_sItem+'",               '
                _sJson += '    "Serial": "'+_sNumDoc+'",             '
                _sJson += '    "Series": "'+_sSerie+'",             '
                _sJson += '    "DocDate": "'+_sEmissao+'",           '
                _sJson += '    "ItemCode": "'+_sCodProd+'",          '
                _sJson += '    "SWW": "'+_sRefer+'",                 '
                _sJson += '    "Description": "'+_sDescProd+'",      '
                _sJson += '    "Size": "'+_sTamanho+'",              '
                _sJson += '    "CardCode": "'+_sCodForn+'",          '
                _sJson += '    "CardName": "'+_sNomeForn+'",         '
                _sJson += '    "CardCodeFab": "'+_sCodFabr+'",       '
                _sJson += '    "CardCodeNameFab": "'+_sNomeFabr+'",  '
                _sJson += '    "Quantity": '+_sQtde+',               '
                _sJson += '    "DocStatus": "'+_sDocStatus+'",       '
                _sJson += '    "ObjType": "'+_sTipo+'",              '
                _sJson += '    "FabricacaoDate": "'+_sDtFabr+'",     '
                _sJson += '    "ValidadeDate": "'+_sDtValid+'",      '
                _sJson += '    "Lote": "'+_sLote+'",                 '
                _sJson += '    "Imobilizado": true, '
                //_sJson += '    "DocEntry": "'+_sPedido+'",                 ' -- ??????
            // _sJson += '    "TipoNFE": 1,'
                _sJson += '    "CardCode_Saida": "' + _sCARDCODESAIDA + '",'
            // _sJson += '    "Serial_Saida": "' + _sSERIALSAIDA + '",'
                _sJson += '    "LineNum_Saida": "' + _sLINENUMSAIDA + '"'
                _sJson += '},'
            ENDIF
        
        ELSE
            _sJson += '  {                                       '
            _sJson += '    "CardCodeFilial": "'+_sFilial+'",     '
            _sJson += '    "DocNum": "'+_sItem+'",               '
            _sJson += '    "Serial": "'+_sNumDoc+'",             '
            _sJson += '    "Series": "'+_sSerie+'",             '
            _sJson += '    "DocDate": "'+_sEmissao+'",           '
            _sJson += '    "ItemCode": "'+_sCodProd+'",          '
            _sJson += '    "SWW": "'+_sRefer+'",                 '
            _sJson += '    "Description": "'+_sDescProd+'",      '
            _sJson += '    "Size": "'+_sTamanho+'",              '
            _sJson += '    "CardCode": "'+_sCodForn+'",          '
            _sJson += '    "CardName": "'+_sNomeForn+'",         '
            _sJson += '    "CardCodeFab": "'+_sCodFabr+'",       '
            _sJson += '    "CardCodeNameFab": "'+_sNomeFabr+'",  '
            _sJson += '    "Quantity": '+_sQtde+',               '
            _sJson += '    "DocStatus": "'+_sDocStatus+'",       '
            _sJson += '    "ObjType": "'+_sTipo+'",              '
            _sJson += '    "FabricacaoDate": "'+_sDtFabr+'",     '
            _sJson += '    "ValidadeDate": "'+_sDtValid+'",      '
            _sJson += '    "Lote": "'+_sLote+'",                 '
            //_sJson += '    "Imobililizado": "'+ "false" + '", '
            _sJson += '    "TipoNFE": '+_sTipoNFE
            _sJson += '},'
        ENDIF
        
    Next

    _sJson := Left(_sJson,Len(_sJson)-1)
    _sJson += ']'

    VarInfo( "_sJson", _sJson )

Return _sJson
