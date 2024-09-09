#include 'totvs.ch'

/*/{Protheus.doc} GENFWS
	
	Integração Protheus x Genesis - Web Service
	
	@type  Function
	@author Jeferson Silva
	@since 01/06/2021
	@version P12
/*/

User Function GENFWS( cRota, cMetodo, aDados, cAccountid )
    
    Local cHost      := GetMV( "ES_GENHOST" )  // "?" 
    Local cToken     := GetMV( "ES_GENKEY" )  // //ES_GENKEY
    Local cResource  := cRota
    Local oRest      := FwRest():New(cHost)
    Local aHeader    := {}     
    Local lRet       := .F.
    Local oJson      := NIL 
    Local cRetWS
    Local nY
    Local aRet       := {} 
    
    Private cBuffer  := ''
    
    ConOut( cBuffer += "GENFWS | NEW | "  + cRota + " | " + cMetodo + CHR(10) + CHR(13) )

    // CABEÇALHO DA REQUISIÇÃO

    AAdd(aHeader, "Content-Type: application/json; charset=UTF-8")
    AAdd(aHeader, "Accept: application/json")
    AAdd(aHeader, "User-Agent: Chrome/65.0 (compatible; Protheus " + GetBuild() + ")")
    AAdd(aHeader, "token: "+ AllTrim(cToken))

    //If (Len(oRest:oResponseH:aHeaderFields) > 0) 
    //    AAdd(aHeader, "Cookie: " + oRest:oResponseH:aHeaderFields[AScan(oRest:oResponseH:aHeaderFields, {|x| Upper(AllTrim(x[1])) == "SET-COOKIE"})][2])
    //Endif 

    // INFORMA O RECURSO E INSERE O JSON NO CORPO (BODY) DA REQUISIÇÃO
    oRest:SetPath(cResource)
    if alltrim(cMetodo) != 'GET'
        oRest:SetPath(cResource)
        if alltrim(cMetodo) == 'POST'
            oRest:SetPostParams(GetJson(aDados))
        endif
    else
        cResource += "?codigoExterno="+aDados
        oRest:SetPath(cResource)
    endif
    // TRATAMENTO ESPECIFICO PARA O METODO ACCOUNT
    If cRota = 'accounts'

        // REALIZA O MÉTODO GET E VALIDA O RETORNO
        If (oRest:Get(aHeader))
         
            ConOut(cBuffer += "GENFWS | GET ON | " + If(oRest:GetResult() <> NIL, oRest:GetResult(),'') + CHR(10) + CHR(13) )
            FwJSONDeserialize(oRest:cResult, @oJson) // DESERIALIZAÇÃO DE STRING PARA OBJETO
            
            For nY := 1 To Len(oJson:Data) 
                
                If oJson:Data[nY]['accountid'] = cAccountid
                    
                    cId := oJson:Data[nY]['id']
                  
                    oRest:SetPath(cResource+'/'+cId)
                    
                    If (oRest:Delete(aHeader))
                  
                        ConOut(cBuffer += "GENFWS | DELETE ON | " + If(oRest:GetResult() <> NIL, oRest:GetResult(),'') + CHR(10) + CHR(13) )
                    Else
                   
                        ConOut(cBuffer += "GENFWS | DELETE OFF | " + If(oRest:GetResult() <> NIL, oRest:GetResult(),'') + CHR(10) + CHR(13) )
                        ConOut(cBuffer += "GENFWS | DELETE OFF | " + If(oRest:GetLastError() <> NIL, oRest:GetLastError(),'') + CHR(10) + CHR(13) )
                    EndIf
                    
                    oRest:SetPath(cResource)
                    Exit
                    
                EndIf
            Next

        Else
            ConOut(cBuffer += "GENFWS | GET OFF | " + If(oRest:GetResult() <> NIL, oRest:GetResult(),'') + CHR(10) + CHR(13) )
            ConOut(cBuffer += "GENFWS | GET OFF | " + If(oRest:GetLastError() <> NIL, oRest:GetLastError(),'') + CHR(10) + CHR(13) )
        EndIf
    
    EndIf
    if alltrim(cMetodo) == 'GET'
        lRet := oRest:GET(aHeader)
    elseif alltrim(cMetodo) == 'POST'
        lRet := oRest:POST(aHeader)
    elseif alltrim(cMetodo) == 'PUT'
        lRet := oRest:PUT(aHeader,GetJson(aDados))
    endif        
    if lRet 
        ConOut( cBuffer += "GENFWS | ON | " + If(oRest:GetResult() <> NIL, cRetWS := oRest:GetResult(),'') + CHR(10) + CHR(13) )
        if alltrim(oRest:GetLastError()) == '200'   
            ConOut(cBuffer += "GENFWS | ON | Update Item Material (Equipamento) OK" + CHR(10) + CHR(13) )
        endif
    else
        ConOut( cBuffer += "GENFWS | OFF | " + If(oRest:GetResult() <> NIL, cRetWS := oRest:GetResult(),'') + CHR(10) + CHR(13) )
        ConOut( cBuffer += "GENFWS | OFF | " + If(oRest:GetLastError() <> NIL, oRest:GetLastError(),'') + CHR(10) + CHR(13) )
        lRet := .F.
    endif
   /* 
   // REALIZA O MÉTODO POST/PUT E VALIDA O RETORNO
    If ( If( cMetodo='POST', oRest:Post(aHeader), oRest:Put(aHeader) ) )
        ConOut( cBuffer += "GENFWS | ON | " + If(oRest:GetResult() <> NIL, cRetWS := oRest:GetResult(),'') + CHR(10) + CHR(13) )
        lRet := .T.
    Else
        ConOut( cBuffer += "GENFWS | OFF | " + If(oRest:GetResult() <> NIL, cRetWS := oRest:GetResult(),'') + CHR(10) + CHR(13) )
        ConOut( cBuffer += "GENFWS | OFF | " + If(oRest:GetLastError() <> NIL, oRest:GetLastError(),'') + CHR(10) + CHR(13) )
        lRet := .F.
    EndIf
    */
    Conout('GENFWS - RETORNO')
    Conout(lRet)
    If cMetodo='PUT' .And. 'clientes' $ cRota
        Conout(cId := '')
    Else
        if alltrim(cMetodo) == 'PUT' .and. !lRet
            ConOut( cBuffer += "GENFWS | OFF | "  + 'Erro na chamada do metodo. Contato o setor de suporte.' + CHR(10) + CHR(13) )
            Conout(cId := '')
        elseif alltrim(cMetodo) == 'PUT' .and. lRet
            ConOut( cBuffer += "GENFWS | OFF | "  + 'Atualizacao dos dados realizada com sucesso.' + CHR(10) + CHR(13) )
            Conout(cId := '')
        else
            FwJSONDeserialize(oRest:cResult, @oJson) // DESERIALIZAÇÃO DE STRING PARA OBJETO
            If  Valtype(oJson) <> 'O'
                If Valtype(oJson) <> 'A'
                    ConOut( cBuffer += "GENFWS | OFF | "  + 'Erro na chamada do metodo. Contato o setor de suporte.' + CHR(10) + CHR(13) )
                    Conout(cId := '')
                Else
                    if (cMetodo == 'POST' .or. cMetodo == 'PUT') .and. !lRet
                        ConOut( cBuffer += "GENFWS | OFF | " +oJson[1]:usermessage+CHR(10) + CHR(13) )
                        Conout(cId := '')
                    else
                        if len(oJson) > 0
                            Conout(cId := cValToChar(oJson[1]:ID))
                        else
                            Conout(cId := '')
                        endif
                    endif
                Endif                
            Else
                Conout(cId := cValToChar(oJson:ID))
            Endif
        endif
    Endif
    aAdd( aRet, { cId, cBuffer } )
Return (aRet)



********************************************************************************
Static Function GetJson(aDados) // Cria o Body a ser enviado no JSON
  
Local cMsg      := ''
Local nI, nJ
Local cType

cMsg := '{'

For nI := 1 to Len( aDados )
    
    cType   := ValType( aDados[ nI, 2 ] )

    /*
    If nI <> Len( aDados )
        cMsg    += '"' + aDados[ nI, 1 ] + '": ' + If( cType == 'N', Str( aDados[ nI, 2 ] ), If( cType == 'D', DtoC( aDados[ nI, 2 ] ), aDados[ nI, 2 ] ) ) + ',' + chr( 10 )
    Else
        cMsg    += '"' + aDados[ nI, 1 ] + '": ' + If( cType == 'N', Str( aDados[ nI, 2 ] ), If( cType == 'D', DtoC( aDados[ nI, 2 ] ), aDados[ nI, 2 ] ) ) + chr( 10 )
    EndIf
    */
    
    cMsg    += '"' + aDados[ nI, 1 ] + '": '

    If cType == 'N'

        cMsg    += AllTrim( Str( aDados[ nI, 2 ] ) )

    ElseIf cType == 'D'

        cMsg    += DtoC( aDados[ nI, 2 ] )

    ElseIf cType == 'A'

        cMsg    += '['
        
        For nJ := 1 To Len( aDados[ nI, 2 ] )

            cMsg    += AllTrim( Str( aDados[ nI, 2, nJ ] ) )

            If nJ <> Len( aDados[ nI, 2 ] )

                cMsg    += ','
            EndIf            

        Next nJ

        cMsg    += ']'

    Else

        cMsg    += aDados[ nI, 2 ]

    EndIf

    If nI <> Len( aDados )

        cMsg    += ','
    EndIf
    
    cMsg    += chr( 10 )

Next nI

cMsg += '}'

ConOut( cBuffer += "GENFWS | BODY | "  + cMsg + CHR(10) + CHR(13) )

Return cMsg


********************************************************************************
User Function GENWSTMP( cRota, cMetodo, aDados )

Local lRet      := .F.  // retorna .F. para não atualizar base com status de dados enviados...
Local cMsg      := ''
Local nI
Local cType

For nI := 1 to Len( aDados )
    
    cType   := ValType( aDados[ nI, 2 ] )

    cMsg    += '"' + aDados[ nI, 1 ] + '": ' + If( cType == 'N', Str( aDados[ nI, 2 ] ), If( cType == 'D', DtoC( aDados[ nI, 2 ] ), aDados[ nI, 2 ] ) ) + chr( 10 )

Next nI

//ApMsgInfo( 'Rota: ' + cRota + '  Método: ' + cMetodo + '  Dados: ' + chr( 10 ) + cMsg )
Aviso(  cCadastro, 'Rota: ' + cRota + '  Método: ' + cMetodo + '  Dados: ' + chr( 10 ) + cMsg, { 'Ok' } )

Return lRet


// Rota Clientes

// Item Material (ERP - Base de Atendimento)

// Fabricante (ERP - Marcas)

// Modelo (ERP - Código do Produto)

// cRota := modelos/
// cMetodo := Valtype(oJson)'POST'
// aData := aAdd(aData,{

User Function USLimpDesc(cDesc)
**************************
    Local cNdesc := ""
    cNdesc := FWNoAccent(cDesc)
    cNdesc := FwCutOff(cNdesc)
   // cNdesc := EncodeUtf8(cNdesc)
    //cNdesc := StrTran(cNdesc, "Â", '')
    cNdesc := StrTran(cNdesc, "'", '')
    cNdesc := StrTran(cNdesc, "#", '')
    cNdesc := StrTran(cNdesc, "%", '')
    cNdesc := StrTran(cNdesc, "*", '')
    cNdesc := StrTran(cNdesc, "&", 'E')
    cNdesc := StrTran(cNdesc, ">", '')
    cNdesc := StrTran(cNdesc, "<", '')
    cNdesc := StrTran(cNdesc, "!", '')
    cNdesc := StrTran(cNdesc, "@", '')
    cNdesc := StrTran(cNdesc, "$", '')
    cNdesc := StrTran(cNdesc, "(", '')
    cNdesc := StrTran(cNdesc, ")", '')
    cNdesc := StrTran(cNdesc, "_", '')
    cNdesc := StrTran(cNdesc, "=", '')
    cNdesc := StrTran(cNdesc, "+", '')
    cNdesc := StrTran(cNdesc, "{", '')
    cNdesc := StrTran(cNdesc, "}", '')
    cNdesc := StrTran(cNdesc, "[", '')
    cNdesc := StrTran(cNdesc, "]", '')
    cNdesc := StrTran(cNdesc, "/", '')
    cNdesc := StrTran(cNdesc, "?", '')
    cNdesc := StrTran(cNdesc, ".", '')
    cNdesc := StrTran(cNdesc, "\", '')
    cNdesc := StrTran(cNdesc, "|", '')
    cNdesc := StrTran(cNdesc, ":", '')
    cNdesc := StrTran(cNdesc, ";", '')
    cNdesc := StrTran(cNdesc, '"', '')
    cNdesc := StrTran(cNdesc, '°', '')
    cNdesc := StrTran(cNdesc, 'º', '')
    cNdesc := StrTran(cNdesc, 'ª', '')
    cNdesc := StrTran(cNdesc, ",", '')
    cNdesc := StrTran(cNdesc, "-", '')
    cNdesc := StrTran(cNdesc, "–", '')
    cNdesc := StrTran(cNdesc, " ", space(1))
Return(cNdesc)
