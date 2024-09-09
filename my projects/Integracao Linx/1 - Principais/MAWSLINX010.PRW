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


        [ ] - Preciso revisar esse codigo quando enviar em massa e pelo MATA010
              Melhor esse codigo e performance
              Até porque  está sendo feito um  POST  e  deveria ser um  PUT,  se o item ja tiver sido integrado

        [ ] - relatorio dos produtos enviados com sucesso e sem sucesso
              por e-mail em excel
              
        [ ] - declaração de variaveis
        [ ] - FreeObj,  está faltandfo

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
Local cDesc       := "Integração ERP x Linx - TODOS os Produtos - SB1"
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

Local lSldEst      := SuperGetMV( "MA_LINXSB2", .F., .F. )
Local cEstSldWhere := If( lSldEst, "%SB2.B2_QATU > 0%", "%1=1%" )

Local cWhere       := If( cCodProduto <> NIL, "%SB1.B1_COD = '" + AllTrim(cCodProduto) + "'%", "%1=1%" )

Local lIsBlind     := IsBlind()
Local cMsg         := ""
Local lBloq        := .F.
Local lInteg       := .F.

Local oLinx        := FATBCAIntegracaoLinx():New()
Local cDescSB1     := ""
Local cCodSB1      := ""

    // AND B1_INTEG <> 'S' AND B1_MSBLQL <> '1'

    If cCodProduto == NIL  .or.  lIsBlind 

        cMsg += '<font color="#0FFF00" size="20">Confirma ?</font>'

        If !FWAlertNoYes( cMsg, 'Serão enviados  TODOS  os produtos para o LINX' )

            Return  lRetorno
        EndIf
    EndIf

    BEGINSQL ALIAS cAliasSB1

        %noparser%
        SELECT
               SB1.R_E_C_N_O_ RECNO, SB1.B1_INTEG, SB1.B1_MSBLQL, SB1.B1_ATIVO, SB1.B1_BLQMA, SB1.B1_COD, SB1.B1_DESC, SB1.B1_IDLINX, SB1.B1_LINXSN,
               SB2.B2_QATU, SB2.B2_LOCAL, SB2.B2_RESERVA, SB2.B2_QPEDVEN, SB2.B2_LOCALIZ, SB2.B2_NAOCLAS, SB2.B2_SALPEDI, SB2.B2_QACLASS 
          FROM
               %Table:SB1% SB1
         INNER JOIN %Table:SB2% SB2 ON ( SB2.B2_FILIAL = %xFilial:SFT% AND SB1.B1_FILIAL = %xFilial:SB1% AND SB1.B1_COD = SB2.B2_COD AND SB2.%NotDel%)
         WHERE 1=1           
           AND %Exp:cWhere%
           AND %Exp:cEstSldWhere%           
           AND SB1.B1_LINXSN = '1'
           AND SB1.%NotDel%

    ENDSQL

	cQuery := GetLastQuery()[2]	
	count to nQtdReg

    If nQtdReg == 0

        FwAlertWarning( "Nenhum produto encontrado para envio ao LINX" + ENTER + ENTER + "Favor verificar campo de integração!!" )
    Else

        (cAliasSB1)->(dbGoTop())

        lInteg := (cAliasSB1)->B1_INTEG  == "S"  // 1=Sim; 2=Não                                                                                                                   
        lBloq  := (cAliasSB1)->B1_MSBLQL == "1"  // 1=Sim;2=Não                                                                                                                     
        //oProcess:SaveLog( "Gerando a Query: " + cQuery )

        VarInfo( "lInteg", lInteg )
        VarInfo( "lBloq", lBloq )

        If lBloq  

            VarInfo( "lInteg-lBloq", lInteg  .or.  lBloq )
            
            FwAlertWarning( "Produto está  bloqueado!" + ENTER + "ID Integracao LINX: " + (cAliasSB1)->B1_COD )
        ElseIf lInteg

            FwAlertWarning( "Produto já foi integrado!" + ENTER + "ID Integracao LINX: " + (cAliasSB1)->B1_IDLINX )
        Else

            Do While (cAliasSB1)->( !Eof() )

                // Atualmente só integra produtos não integrados ainda,  pois é um  POST
                If Vazio( (cAliasSB1)->B1_IDLINX  )  .or.  (cAliasSB1)->B1_INTEG != "S"

                    cDescSB1                              := oLinx:NoAcento( AllTrim( (cAliasSB1)->B1_DESC ) )
                    cCodSB1                               := AllTrim( (cAliasSB1)->B1_COD )

                    oJsonSB1                              := JsonObject():New()

                    oJsonSB1[ 'ProductType' ]             := 1
                    //oJsonSB1[ 'SKU' ]                     := cCodSB1

                    // -- ProductDescriptions
                    oDescription                          := JsonObject():New()
                    oDescription[ "LongDescription" ]     := cDescSB1
                    oDescription[ "ShortDescription" ]    := cDescSB1
                    oDescription[ "WarrantyDescription" ] := ""

                    oSeoDescription                       := JsonObject():New()
                    oSeoDescription[ 'MetaDescription' ]  := ""
                    oSeoDescription[ 'MetaKeywords' ]     := ""
                    oSeoDescription[ 'PageTitle' ]        := ""
                    oSeoDescription[ 'UrlFriendly' ]      := cDescSB1 + cCodSB1 // Ver isso

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
                    oGeneralDisplaying[ "VisibleFrom" ]   := "/Date(" + FWTimeStamp( 4,Date() , Time() ) + ")/"  // "/Date(1682535404)/" // CalcDataEpochUnix()

                    oSkuDetails                           := JsonObject():New()
                    oSkuDetails[ 'IntegrationID' ]        := cCodSB1 + " - "
                    oSkuDetails[ 'Name' ]                 := cDescSB1
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
                    //cJsonEnv := '{    "ProductDescriptions": {        "Description": {            "LongDescription": "DWTLSS Teste MA HOSPITALAR",            "ShortDescription": "CHICOTE DE ACO INOX DE 1,5 MTS COM ROSCA DE 7 16 20 UNF",            "WarrantyDescription": ""        },        "SeoDescription": {            "MetaDescription": "Teste",            "MetaKeywords": "Teste",            "PageTitle": "CHICOTE DE ACO INOX DE 1,5 MTS COM ROSCA DE 7 16 20 UNF OUTROS 00.0672",            "UrlFriendly": "chicote-de-aco-inox-de-1-mts-com-rosca-de-7-16-20-unf-outros-00.0672"        },        "TagSearch": {            "SearchKeywords": "chicote de a\u00e7o"        }    },    "ProductDetails": {        "General": {            "BrandID": "1",            "Categories": [                {                    "CategoryID": 1,                    "IsMain": true                }            ],            "Name": "Teste"        },        "GeneralDisplaying": {            "IsSearchable": true,            "IsUponRequest": false,            "IsVisible": true,            "VisibleFrom": "/Date(1682535404)/"        },        "SkuDetails": {            "IntegrationID": "DWTLSS_001",            "Name": "CHICOTE DE ACO INOX DE 1,5 MTS COM ROSCA DE 7 16 20 UNF",            "ProductDefinitionID": 4        }    },    "ProductInventory": {        "Inventory": {            "ForceOutOfStock": false        },        "InventoryDisplaying": {            "DisplayAvailability": "Y",            "DisplayStockQty": true        }    },    "ProductPrice": {        "Pricing": {            "DisplayPrice": "Y"        }    },    "ProductShipping": {        "ShippingRegion": {            "IsFreeShipping": false        }    },    "ProductType": 1,    "SKU": "DWTLSS_001"}'
                    If IntegraProduto( cJsonEnv, nRecno, @cIdInteg )

                        cJsonEnv := ""
                        SaveSKU( cIdInteg, @cJsonEnv, cCodSB1, cDescSB1 )
                        IntegraSKU( cJsonEnv, "/Catalog/API.svc/web/SaveSKU" )
                        cJsonEnv := ""
                        MontaSKUJson( cIdInteg, @cJsonEnv )
                        IntegraSKU( cJsonEnv, "/Catalog/API.svc/web/AddSKUToProduct" )

                        U_MAWSLNX30( cCodSB1 )
                    EndIf
                EndIF

                (cAliasSB1)->(dbSkip())
            EndDo
        EndIF
    EndIf

    FWFreeObj( oJsonSB1 )
    FWFreeObj( oLinx )

FWRestArea( aArea )
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
            SB1->B1_IDLINX := cIdInteg  // B1_IDLINX        
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

    oJsonSKU[ 'ProductID' ] := cValToChar( Val(cIdInteg) )
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
Local jJsonSKU := JsonObject():New()

    /*
    jJsonSKU[ 'ProductID ' ] := cIdInteg
    jJsonSKU[ 'ProductType ' ] := 1
    jJsonSKU[ 'SKU ' ] := cIdInteg

    // StockKeepUnitDetails
    oStockKeepUnitDetails                          := JsonObject():New()
    oStockKeepUnitDetails[ 'Inventory' ]           := oInventory
    oStockKeepUnitDetails[ 'InventoryDisplaying' ] := oInvDisplaying

    jJsonSKU[ 'StockKeepUnitDetails' ]             := oStockKeepUnitDetails

    // -- 
    aCategoria                          := {}
    aadd(aCategoria, JsonObject():new())
    aCategoria[1][ 'CategoryID' ]       := 34   //  <<< Temporario
    //aadd(aCategoria, JsonObject():new())
    aCategoria[1][ 'IsMain' ]           := .T.
    */

    cJsonenv := "{" 

    cJsonenv += '"ProductID": 0,' 
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

    FWFreeObj( jJsonSKU )

Return lRetorno




// ------------------------------------------------------------------------------------
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

