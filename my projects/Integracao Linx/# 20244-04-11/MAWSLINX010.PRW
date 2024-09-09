#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

#DEFINE ENTER   CHR(10) + CHR(13)

/*
    TODO        
        [X] - Função Data Epoch Unix
            [ ] - Validacao
        [X] - Função / metodo  EnvioJson
            [X] - Ficou como uma  Static Function
            [X] - Validado
        [ ] - Campo no SB1 de integração e se o produto vai integrar ou não (Local = 05,  já poderia ser)
        [ ] - Só integra produtos com  saldo em estoque  ?


    https://centraldeatendimento.totvs.com/hc/pt-br/articles/360020380572-Cross-Segmento-Backoffice-Linha-Protheus-SIGAEST-Como-descobrir-a-origem-dos-saldos-na-consulta-com-comando-F4-no-Produto-

    Integração de Produtos - Simples
    https://olapropagandaemuitomais.layer.core-hlg.dcg.com.br/index.html?url=//swagger.json
*/

User Function MAWSLNX()
	RpcSetType(3)
	RpcSetEnv("01","0101",,,"FAT")

	U_MAWSLNX10()

	RpcClearEnv()
Return

User Function MAWSLNX10( cCodProduto )
Local lRetorno    := .T.
Local oLinx       := FATBCAIntegracaoLinx():New()
Local aHeader     := oLinx:aHeadStr
Local cURLBase    := oLinx:cURLBase

Local lIsBlind    := IsBlind()
Local cLockName   := ProcName() + FWCodFil()
Local cDesc       := "Integração ERP x Linx - Produtos - SB1"
Local cPerg       := ""
Local aInfoCustom := {}
Local cTxt        := ""
Local nTimeIni    := 0
Local oProcess    := NIL

DEFAULT cCodProduto := ""

Local lLogCV8     := SuperGetMV( "MA_LNXCV8", .F., .F. )

    TMSLogMSg( "INFO", "MAWSLNX10 -  Iniciando Integração Cadastro de Produtos - LINX -  Empresa:" + FWGrpCompany() )
    
	BEGIN SEQUENCE
    
        If oLinx:Requisitos()  .and.  oLinx:Conectado()

            // Controle de semaforo pra não rodar por mais de um usuario
            If !LockByName( cLockName,.F.,.F.,.T. )

                If !lIsBlind

                    cTxt := Iif( !lIsBlind, "por outro usuário", "pelo schedule" )
                    FwAlertWarning( "Rotina está sendo processada " + cTxt + "  -  " + cLockName )
                Else

                    TMSLogMSg("INFO", "Rotina está sendo processada por outro usuário - " + cLockName )
                Endif
                Break
            EndIf

            // Se não estiver rodando pelo  SCHEDULE e não for pelo MATA010 - Cadastro de Produtos
            If !lIsBlind  .and.  !FwIsInCallStack("U_MAWSLNX90")  .and.  !FwIsInCallStack("MATA010")

                nTimeIni := Time()
                oProcess := tNewProcess():New( 'U_MAWSLNX10', cDesc, {|oSelf| fProcPrdRun(oSelf,NIL) }, cDesc, cPerg, aInfoCustom,,, cDesc,.T.,.T. )
                FWAlertInfo( "Tempo de Duração " + ElapTime(nTimeIni, Time()) )
            ElseIf FwIsInCallStack("MATA010")

                If SB1->B1_MSBLQL == "1"

                    FwAlertWarning( "Produto não será integrado pois se encontra inativado", 'Prodeuto Inativado' )
                ElseIf .F.  //  SB1->B1_LOCPAD <> "05"  Vai ser  pelo  SB2

                    FwAlertWarning( "Produto invalido para integração. Somente produtos cujo o local de estoque seja 05", 'Prodeuto Invlaido' )
                Else

                    fProcPrdRun( NIL, SB1->B1_COD )
                EndIf
            Else

                fProcPrdRun( NIL, NIL )
            Endif

            UnLockByName( cLockName,.F.,.F.,.T. )
        Else
            
            FWMsgAlert( "Plataforma de Integração InaAtiva" )
        EndIf

	END SEQUENCE
    

    oLinx:Destroy()
    FWFreeObj( oLinx )    
    FWFreeObj( oProcess )       
    TMSLogMSg( "INFO", "MAWSLNX10 -  Finalizando Integração dCadastro de Produto - LINX -  Empresa:" + FWGrpCompany() )

Return lRetorno


/*/{Protheus.doc} fProcPrdRun
    
    Integração Cadastro de Produtos com a  LINX

    @type  Static Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function fProcPrdRun( oProcess, cCodProduto )
Local lRetorno     := .T.
Local aArea        := FWGetArea()
Local cAliasSB1    := GetNextAlias()
Local cQuery       := ""
Local nQtdreg      := 0
Local oJsonSB1     := NIL
Local cJsonEnv     := ""

Local lSldEst      := SuperGetMV( "MA_LINXSLDEST", .F., .F. )
Local cEstSldWhere := If( lSldEst, "%SB2.B2_QATU > 0%", "%1=1%" )

Local cWhere := If( cCodProduto <> NIL, "%SB1.B1_COD = '" + AllTrim(cCodProduto) + "'%", "%1=1%" )

    // AND B1_INTEG <> 'S' AND B1_MSBLQL <> '1'

    BEGINSQL ALIAS cAliasSB1

        %noparser%
        SELECT
               TOP 3 SB1.R_E_C_N_O_ RECNO, SB1.B1_INTEG, SB1.B1_MSBLQL, SB1.B1_ATIVO, SB1.B1_BLQMA, SB1.B1_COD, SB1.B1_DESC, SB1.B1_CODITE,
                    SB2.B2_QATU, SB2.B2_LOCAL, SB2.B2_RESERVA, SB2.B2_QPEDVEN, SB2.B2_LOCALIZ, SB2.B2_NAOCLAS, SB2.B2_SALPEDI, SB2.B2_QACLASS 
          FROM
               %Table:SB1% SB1
         INNER JOIN %Table:SB2% SB2 ON ( SB2.B2_FILIAL = %xFilial:SFT% AND SB1.B1_COD = SB2.B2_COD AND SB2.%NotDel%)
         WHERE 1=1
           AND SB1.B1_FILIAL = %xFilial:SB1%
           AND %Exp:cWhere%
           AND %Exp:cEstSldWhere%
           --AND SB2.B2_LOCAL = '05'
           AND SB1.%NotDel%

    ENDSQL

	cQuery := GetLastQuery()[2]	
	count to nQtdReg

    If nQtdReg == 0

        FwAlertWarning( "Produto não está  no local de estoque  05 - E-COMMERCE RS" )
    Else

        (cAliasSB1)->(dbGoTop())

        lInteg := (cAliasSB1)->B1_INTEG  == "S"  // 1=Sim; 2=Não                                                                                                                   
        lBloq  := (cAliasSB1)->B1_MSBLQL == "1"  // 1=Sim;2=Não                                                                                                                     
        //oProcess:SaveLog( "Gerando a Query: " + cQuery )

        If lInteg  .or.  lBloq  

            FwAlertWarning( "Produto está  bloqueado ou já foi integrado!" + ENTER + "ID Integracao LINX: " + (cAliasSB1)->B1_CODITE )
        Else

            Do While (cAliasSB1)->( !Eof() )

                oJsonSB1                              := JsonObject():New()

                oJsonSB1[ 'ProductType' ]             := 1
                oJsonSB1[ 'SKU' ]                     := AllTrim( (cAliasSB1)->B1_COD )

                // -- ProductDescriptions
                oDescription                          := JsonObject():New()
                oDescription[ "LongDescription" ]     := AllTrim( (cAliasSB1)->B1_DESC )
                oDescription[ "ShortDescription" ]    := AllTrim( (cAliasSB1)->B1_DESC )
                oDescription[ "WarrantyDescription" ] := ""

                oSeoDescription                       := JsonObject():New()
                oSeoDescription[ 'MetaDescription' ]  := ""
                oSeoDescription[ 'MetaKeywords' ]     := ""
                oSeoDescription[ 'PageTitle' ]        := ""
                oSeoDescription[ 'UrlFriendly' ]      := AllTrim( (cAliasSB1)->B1_DESC  ) + AllTrim( (cAliasSB1)->B1_COD  ) // Ver isso

                oTagSearch                            := JsonObject():New()
                oTagSearch[ "SearchKeywords" ]        := ""

                oProdDescriptions                     := JsonObject():New()
                oProdDescriptions[ 'Description' ]    := oDescription
                oProdDescriptions[ 'SeoDescription' ] := oSeoDescription
                oProdDescriptions[ 'TagSearch' ]      := oTagSearch

                oJsonSB1[ 'ProductDescriptions' ]     := oProdDescriptions

                // -- ProductDetails
                oGeneralDisplaying                    := JsonObject():New()
                oGeneralDisplaying[ "IsSearchable" ]  := .T.
                oGeneralDisplaying[ "IsUponRequest" ] := .F.
                oGeneralDisplaying[ "IsVisible" ]     := .F.
                oGeneralDisplaying[ "VisibleFrom" ]   := CalcDataEpochUnix()

                oSkuDetails                           := JsonObject():New()
                oSkuDetails[ 'IntegrationID' ]        := AllTrim((cAliasSB1)->B1_COD) + " - "
                oSkuDetails[ 'Name' ]                 := AllTrim( (cAliasSB1)->B1_DESC )
                oSkuDetails[ 'ProductDefinitionID' ]  := 4

                // -- 
                aCategoria                          := {}
                aadd(aCategoria, JsonObject():new())
                aCategoria[1][ 'CategoryID' ]       := 34   //  <<< Temporario
                //aadd(aCategoria, JsonObject():new())
                aCategoria[1][ 'IsMain' ]           := .T.

                oGeneral                            := JsonObject():New()
                oGeneral[ 'BrandID' ]               := "1"
                oGeneral[ 'Name' ]                  := "Teste"
                oGeneral[ 'Categories' ]            := aCategoria

                oProdDetails                        := JsonObject():New()
                oProdDetails[ 'GeneralDisplaying' ] := oGeneralDisplaying
                oProdDetails[ 'SkuDetails' ]        := oSkuDetails
                oProdDetails[ 'General' ]           := oGeneral

                oJsonSB1[ 'ProductDetails' ]        := oProdDetails

                // -- ProductInventory
                oInventory                              := JsonObject():New()
                oInventory[ "ForceOutOfStock" ]         := .F.

                oInvDisplaying                          := JsonObject():New()
                oInvDisplaying[ 'DisplayAvailability' ] := "Y"
                oInvDisplaying[ 'DisplayStockQty' ]     := .F.

                oProdInventory                          := JsonObject():New()
                oProdInventory[ 'Inventory' ]           := oInventory
                oProdInventory[ 'InventoryDisplaying' ] := oInvDisplaying

                oJsonSB1[ 'ProductInventory' ]          := oProdInventory

                // -- ProductPrice
                oPricing                   := JsonObject():New()
                oPricing[ "DisplayPrice" ] := "Y"

                oProdPrice                 := JsonObject():New()
                oProdPrice[ 'Pricing' ]    := oPricing

                oJsonSB1[ 'ProductPrice' ] := oProdPrice

                // -- ProductShipping
                oShippingRegion                     := JsonObject():New()
                oShippingRegion[ "IsFreeShipping" ] := .F.

                oProdShipping                       := JsonObject():New()
                oProdShipping[ 'ShippingRegion' ]   := oShippingRegion

                oJsonSB1[ 'ProductShipping' ]       := oProdShipping

                // -- 
                cJsonEnv := oJsonSB1:ToJson()   

                nRecno := (cAliasSB1)->RECNO
                cIdInteg := ""
                If IntegraProduto( cJsonEnv, nRecno, @cIdInteg )

                    cJsonEnv := ""
                    SaveSKU( cIdInteg, @cJsonEnv, (cAliasSB1)->B1_COD, (cAliasSB1)->B1_DESC )
                    IntegraSKU( cJsonEnv, "/Catalog/API.svc/web/SaveSKU" )
                    MontaSKUJson( cIdInteg, @cJsonEnv )
                    IntegraSKU( cJsonEnv, "/Catalog/API.svc/web/AddSKUToProduct" )

                    U_MAWSLNX30( (cAliasSB1)->B1_COD )
                EndIf
                (cAliasSB1)->(dbSkip())
            EndDo
        EndIF
    EndIf

FWFreeObj( oJsonSB1 )
FWRestArea( aArea )
Return lRetorno

/*/{Protheus.doc} CalcDataEpochUnix
    (long_description)
    @type  Static Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function CalcDataEpochUnix()
Local nSec        := 1596060836
Local dData       := CToD("01/01/1970") + Int(nSec/86400) // Retorna a data
Local nAdicionais := cValToChar( Int(nSec%86400) ) // segundos adicionais da data

Local cRetorno := "/Date(" + nAdicionais + ")/"

Return cRetorno  // "/Date(1682535404)/"

/*/{Protheus.doc} nomeStaticFunction
    (long_description)
    @type  Static Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function IntegraProduto( cJsonEnv, nRecno, cIdInteg )
Local oRestClient     := NIL
Local cError          := ""
Local cRetorno        := ""
Local nStatus         := 0
Local lRetorno        := .T.
Local cHTTPError      := ""
Local llChkStatusCode := .T.
Local cHTTPCode       := ""
Local oJson           := JsonObject():New()

Local oLinx           := FATBCAIntegracaoLinx():New()
Local aHeader         := oLinx:aHeadStr
Local cURLBase        := oLinx:cURLBase
Local cPath           := "/Catalog/API.svc/web/SaveProduct

Local cDataEnv    := Date()
Local cHorEnv     := FWTimeStamp(5)
Local cDataRec    := ""
Local cHorRec     := ""
Local cJsonRec    := ""
Local cTabela     := "SB1"

Local cErrorMessage := ""
Local lError        := .F.

DEFAULT cIdInteg    := ""

    oRestClient := FWRest():New(cURLBase)
    oRestClient:SetPath(cPath)
    oRestClient:SetChkStatus(.F.)

    oRestClient:SetPostParams(cJsonEnv) 

    lSucess         := oRestClient:Post(aHeader)
    cRetorno        := oRestClient:GetResult()
    cError          := oRestClient:GetLastError()
    llChkStatusCode := oRestClient:GetChkStatus()
    cHTTPCode       := oRestClient:GetHTTPCode()
    nStatus         := HTTPGetStatus(@cHTTPError)

    cDataRec    := Date()
    cHorRec     := FWTimeStamp(5)

    do case
    case nStatus >= 200  .and.  nStatus <= 299

        // FwAlertWarning( cHTTPCode )
        cRetorno := DecodeUTF8(oRestClient:getResult(), "cp1252")
        cJsonRec := oJson:FromJson(cRetorno)

        If cJsonRec == NIL

            lError := oJson:GetJsonObject( 'IsValid' )
            nError := Len( oJson:GetJsonObject( 'Errors' ) ) 

            If lError

                cIdInteg := cValtoChar( oJson:GetJsonObject( 'ProductID' ) )
                If AllTrim(FunName()) != "U_MAWSLNX10"

                    FWAlertInfo( "Integração do Produto com sucesso" )
                EndIf

                GravaIdProduto( nRecno, cIdInteg )                
            Else

                //cErrorMessage := DecodeUTF8( oJson:GetJsonObject( 'Errors' )[1]:GetJsonText('ErrorMessage'), "cp1251" )
                cErrorMessage := oJson:GetJsonObject( 'Errors' )[1]:GetJsonText('ErrorMessage')                

                FwAlertWarning( cErrorMessage )
                lRetorno := .F.
            EndIf
        Else

            FWAlertError( "JSON Errado")
        EndIf
    case nStatus >= 300  .and.  nStatus <= 399

        FwAlertWarning( cHTTPCode )
        lRetorno := .F.        
    case nStatus >= 400  .and.  nStatus <= 499            

        FwAlertWarning( cHTTPCode )
        lRetorno := .F.        
    case nStatus >= 500  .and.  nStatus <= 599

        // FwAlertWarning( cHTTPCode )
        FwAlertWarning( "Erro na integração" )
        lRetorno := .F.
    end case

    /*
        cIdInteg      = ALIAS_CHAVE_INTEGRACAO
        cDataEnv      = ALIAS_DATA_HORA_ENVIO
        cHorEnv       = ALIAS_DATA_HORA_ENVIO
        cDataRec      = ALIAS_DATA_HORA_RECEBIMENTO
        cHorRec       = ALIAS_DATA_HORA_RECEBIMENTO
        cJsonEnv      = ALIAS_JSON_ENVIO
        cJsonRec      = ALIAS_JSON_RECEBIMENTO
        cTabela       = ALIAS_TABELA_ENTIDADE
        nRecno        = ALIAS_RECNO
        cHTTPCode     = ALIAS_STATUS_HTTP
        cErrorMessage = ALIAS_ERROR
    */
    oLinx:GravaLog( cIdInteg, cDataEnv, cHorEnv, cDataRec, cHorRec, cJsonEnv, cRetorno, cTabela, nRecno, ;
                    cURLBase + cPath, "POST", FunName(), lError, cHTTPCode, cErrorMessage )

    FreeObj(oJson)
    FreeObj(oLinx)
    FreeObj(oRestClient)

Return lRetorno


/*/{Protheus.doc} GravaIdProduto
    (long_description)
    @type  Static Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function GravaIdProduto( nRecno, cIdInteg )
Local lRetorno := .T.

    SB1->(dbSelectArea("SB1"))
    SB1->(DbGoTo(nRecno))
    If SB1->(Recno()) == nRecno
        
        If RecLock( "SB1", .F. )
            
            SB1->B1_INTEG := "S"        // B1_INTEGRAD    
            SB1->B1_CODITE := cIdInteg  // B1_IDINTEG        
            SB1->(MsUnlock())
        EndIf
    EndIf

Return lRetorno

/*/{Protheus.doc} IntegraSKU
    (long_description)
    @type  Static Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function IntegraSKU( cJsonEnv, cPath )
Local lRetorno        := .T.
Local oRestClient     := NIL
Local cError          := ""
Local cRetorno        := ""
Local nStatus         := 0

Local cHTTPError      := ""
Local llChkStatusCode := .T.
Local cHTTPCode       := ""
Local oJson           := JsonObject():New()

Local oLinx           := FATBCAIntegracaoLinx():New()
Local aHeader         := oLinx:aHeadStr
Local cURLBase        := oLinx:cURLBase
// Local cPath           := "/Catalog/API.svc/web/AddSKUToProduct"
Local cDataEnv        := Date()
Local cErrorMessage   := ""
Local cHorEnv         := FWTimeStamp(5)
Local cTabela         := "SB2"
Local lError          := .F.

    oRestClient := FWRest():New(cURLBase)
    oRestClient:SetPath(cPath)
    oRestClient:SetChkStatus(.F.)

    oRestClient:SetPostParams(cJsonEnv) 

    lSucess         := oRestClient:Post(aHeader)
    cRetorno        := oRestClient:GetResult()
    cError          := oRestClient:GetLastError()
    llChkStatusCode := oRestClient:GetChkStatus()
    cHTTPCode       := oRestClient:GetHTTPCode()
    nStatus         := HTTPGetStatus(@cHTTPError)

    cDataRec    := Date()
    cHorRec     := FWTimeStamp(5)

    do case
    case nStatus >= 200  .and.  nStatus <= 299

        // FwAlertWarning( cHTTPCode )
        cRetorno := DecodeUTF8(oRestClient:getResult(), "cp1252")
        cJsonRec := oJson:FromJson(cRetorno)

        If cJsonRec == NIL

            lError := oJson:GetJsonObject( 'IsValid' )
            nError := Len( oJson:GetJsonObject( 'Errors' ) ) 

            If lError

                cIdInteg := cValtoChar( oJson:GetJsonObject( 'ProductID' ) )
                If AllTrim(FunName()) != "U_MAWSLNX10"

                    If ( "AddSKUToProduct" $ cPath )

                        FWAlertInfo( "Integração da amarração do SKU com Produto com sucesso" )
                    Else

                        FWAlertInfo( "Integração do SKU integrado com sucesso" )
                    EndIF
                EndIf

                GravaIdProduto( nRecno, cIdInteg )                
            Else

                //cErrorMessage := DecodeUTF8( oJson:GetJsonObject( 'Errors' )[1]:GetJsonText('ErrorMessage'), "cp1251" )
                cErrorMessage := oJson:GetJsonObject( 'Errors' )[1]:GetJsonText('ErrorMessage')                

                FwAlertWarning( cErrorMessage )
                lRetorno := .F.
            EndIf
        Else

            FWAlertError( "JSON Errado")
        EndIf
    case nStatus >= 300  .and.  nStatus <= 399

        FwAlertWarning( cHTTPCode )
    case nStatus >= 400  .and.  nStatus <= 499            

        FwAlertWarning( cHTTPCode )
    case nStatus >= 500  .and.  nStatus <= 599

        // FwAlertWarning( cHTTPCode )
        FwAlertWarning( "Erro na integração" )
        lRetorno := .F.        
    end case

    /*
        cIdInteg      = ALIAS_CHAVE_INTEGRACAO
        cDataEnv      = ALIAS_DATA_HORA_ENVIO
        cHorEnv       = ALIAS_DATA_HORA_ENVIO
        cDataRec      = ALIAS_DATA_HORA_RECEBIMENTO
        cHorRec       = ALIAS_DATA_HORA_RECEBIMENTO
        cJsonEnv      = ALIAS_JSON_ENVIO
        cJsonRec      = ALIAS_JSON_RECEBIMENTO
        cTabela       = ALIAS_TABELA_ENTIDADE
        nRecno        = ALIAS_RECNO
        cHTTPCode     = ALIAS_STATUS_HTTP
        cErrorMessage = ALIAS_ERROR
    */      
    oLinx:GravaLog( cIdInteg, cDataEnv, cHorEnv, cDataRec, cHorRec, cJsonEnv, cRetorno, cTabela, nRecno, ;
                    cURLBase + cPath, "POST", FunName(), lError, cHTTPCode, cErrorMessage )


    FreeObj(oJson)
    FreeObj(oLinx)
    FreeObj(oRestClient)

Return lRetorno




//-------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
	Execucao da rotina via Schedule.
	@return  aParam
/*/
//-------------------------------------------------------------------
Static Function SchedDef()
	Local aParam := {}

	aParam := 	{"P"	,;	//Tipo R para relatorio P para processo
				""		,;	//Nome do grupo de perguntas (SX1)
				Nil		,;	//cAlias (para Relatorio)
				Nil		,;	//aArray (para Relatorio)
				Nil		}	//Titulo (para Relatorio)
Return aParam


/*/{Protheus.doc} MontaSKUJson( cIdInteg, @cJsonEnv )
    (long_description)
    @type  Static Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function MontaSKUJson( cIdInteg, cJsonEnv )
Local lRetorno := .T.

    oJsonSKU                := JsonObject():New()

    oJsonSKU[ 'ProductID' ] := cValToChar( Val(cIdInteg) - 1 )
    oJsonSKU[ 'SkuID' ]     := cValToChar( Val(cIdInteg)  )

    cJsonEnv := oJsonSKU:ToJson() 

Return lRetorno


/*/{Protheus.doc} nomeStaticFunction
    (long_description)
    @type  Static Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function SaveSKU( cIdInteg, cJsonEnv, cCodProduto, cDescProduto )
Local lRetorno := .T.

    cJsonenv := "{" 

    cJsonenv += '"ProductID":' + cIdInteg + ','
    cJsonenv += '"ProductType": 1,'
    //cJsonenv += '"SKU": "' + AllTrim(cCodProduto) + '",' 
    cJsonenv += '"SKU": "' + cIdInteg + '",'     

    cJsonenv += '"StockKeepUnitDetails": {'
    cJsonenv += '"GeneralDisplaying": {'
    cJsonenv += '"IsSearchable": true,'
    cJsonenv += '"IsUponRequest": false,'
    cJsonenv += '"IsVisible": true,'
    cJsonenv += '"VisibleFrom": "/Date(1504284871432-0420)/",'
    cJsonenv += '"VisibleTo": "/Date(4658658471432-0420)/"'
    cJsonenv += '},'
    cJsonenv += '    "SkuDetails": {'
    cJsonenv += '      "IntegrationID": "' + AllTrim(cCodProduto) + '",'
    cJsonenv += '      "Name": "' + AllTrim(cDescProduto) + '",'
    cJsonenv += '      "ProductDefinitionID": 11,'                            //  <<<<   Verificar isso!!!!
    cJsonenv += '      "Suppliers": ['
    cJsonenv += '        0'
    cJsonenv += '      ],'
    cJsonenv += '      "VariationProperties": ['
    cJsonenv += '        {'
    cJsonenv += '          "PropertyMetadataID": 0,'
    cJsonenv += '          "PropertyMetadataValue": "0"'
    cJsonenv += '        }'
    cJsonenv += '      ]'
    cJsonenv += '    }'
    cJsonenv += '  },'
    cJsonenv += '  "StockKeepUnitInventory": {'
    cJsonenv += '    "Backorder": {'
    cJsonenv += '      "BackorderLimit": 10,'
    cJsonenv += '      "Backorderable": false'
    cJsonenv += '    },'
    cJsonenv += '    "Handling": {'
    cJsonenv += '      "InStockHandlingDays": 2,'   // <<<  prazo no despacho  adicionar  2 dias ao prazo da transportadora
    cJsonenv += '      "OutStockHandlingDays": 20'  // <<<  prazo no despacho  adicionar  2 dias ao prazo da transportadora  mas "sem"  estoque
    cJsonenv += '    },'
    cJsonenv += '    "Preorder": {'
    cJsonenv += '      "Preorderable": false'
    cJsonenv += '    },'
    cJsonenv += '    "SkuInventory": {'
    cJsonenv += '      "DisableOnReorderPoint": true,'
    cJsonenv += '      "ForceOutOfStock": false,'
    cJsonenv += '      "ManageStock": true,'
    cJsonenv += '      "NotifyReorderPoint": true,'
    cJsonenv += '      "ReorderPoint": 100,'
    cJsonenv += '      "Replenishment": 0'
    cJsonenv += '    }'
    cJsonenv += '  }'
    cJsonenv += '}'

Return lRetorno

