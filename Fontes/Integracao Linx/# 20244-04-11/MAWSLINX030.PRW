#include "Protheus.ch"
#include "tbiconn.ch"
#include "topconn.ch"
#include "restful.ch"
#include "FWMVCDEF.ch"
#Include "TOTVS.ch" 
#INCLUDE "rwmake.ch"


/*
    TODO        
        [X] - Função Data Epoch Unix
            [ ] - Validacao
        [X] - Função / metodo  EnvioJson
            [X] - Ficou como uma  Static Function
            [X] - Validado

        [ ] - o correto seria usar a função  SladoSB2()  para ober o saldo em estoque
*/
/*
User Function MAWSLNX()
	RpcSetType(3)
	RpcSetEnv("01","0101",,,"FAT")

	U_MAWSLNX30()

	RpcClearEnv()
Return*/

User Function MAWSLNX30( cCodProduto )
Local lRetorno    := .T.
Local oLinx       := FATBCAIntegracaoLinx():New()
Local aHeader     := oLinx:aHeadStr
Local cURLBase    := oLinx:cURLBase

Local lIsBlind    := IsBlind()
Local cLockName   := ProcName() + FWCodFil()
Local cDesc       := "Integração ERP x Linx - Estoques"
Local cPerg       := ""
Local aInfoCustom := {}
Local cTxt        := ""
Local nTimeIni    := 0
Local oProcess    := NIL

DEFAULT cCodProduto := ""

Local lLogCV8     := SuperGetMV( "MA_LNXCV8", .F., .F. )

    TMSLogMSg( "INFO", "MAWSLNX30 -  Iniciando Integração Estoques - LINX -  Empresa:" + FWGrpCompany() )
    
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
                oProcess := tNewProcess():New( 'U_MAWSLNX30', cDesc, {|oSelf| fProcPrdRun(oSelf,NIL) }, cDesc, cPerg, aInfoCustom,,, cDesc,.T.,.T. )
                FWAlertInfo( "Tempo de Duração " + ElapTime(nTimeIni, Time()) )

            ElseIf FwIsInCallStack("MATA010")

                If SB1->B1_MSBLQL == "1"

                    FwAlertWarning( "Produto não será integrado pois se encontra inativado", 'Prodeuto Inativado' )
                
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
    TMSLogMSg( "INFO", "MAWSLNX30 -  Finalizando Integração de Estoques - LINX -  Empresa:" + FWGrpCompany() )

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
Local lRetorno  := .T.
Local aArea     := FWGetArea()
Local cQuery    := ""
Local cJsonEnv  := ""
Local passou    := .F.

Local aObjEstoque := {}


	cQuery := " SELECT * FROM " + RetSqlName("SB2" ) + " SB2 INNER JOIN "+ RetSqlName("SB1" ) + " SB1 ON B1_COD = B2_COD " 
    cQuery += " WHERE SB2.D_E_L_E_T_ <> '*' AND SB1.D_E_L_E_T_ <> '*' AND B2_COD = '" + cCodProduto + "' AND B2_FILIAL = '0101' AND B2_LOCAL = '05' "
	
	TCQuery cQuery New Alias "TRB_SB2"
	TRB_SB2->(DbGoTop())


    //oProcess:SaveLog( "Gerando a Query: " + cQuery )

    While TRB_SB2->(!EOF())

        passou := .T.

        IF EMPTY(ALLTRIM(TRB_SB2->B1_CODITE))
            ALERT("ESTE PRODUTO AINDA NAO FOI INTEGRADO. EFETUAR A INTEGRAÇÃO ANTES DE INTEGRAR O ESTOQUE.")
        ELSE 
            ALERT("Qtd a ser integrada.: " + CVALTOCHAR(TRB_SB2->B2_QATU))

            aAdd( aObjEstoque,  JsonObject():New() )

            aObjEstoque[1]["ProductID"] := VAL(TRB_SB2->B1_CODITE) + 1
            aObjEstoque[1]["WarehouseID"] := 1  // DEIXANDO CHUMBADO ARMAZEM 1 NA LINX
            aObjEstoque[1]["Quantity"] := TRB_SB2->B2_QATU
            aObjEstoque[1]["InventoryMovementTypes"] := 9
            aObjEstoque[1]["ActionEnum"] := 2

            jObjProd :=  JsonObject():New()
            jObjProd["InventorySku"] := aObjEstoque

            cJson := jObjProd:toJson()

            IntegraEstoque( cJson )
        
        ENDIF

        //FWFreeObj( oJsonSB2 )

        TRB_SB2->(dbSkip())
    EndDo
    TRB_SB2->(dbCloseArea())

    IF passou == .F.
        ALERT("Produto não existe no armazem 05 filial 0101")
    ENDIF


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
Static Function IntegraEstoque( cJsonEnv )
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
Local cPath           := "/Catalog/API.svc/web/ChangeSKUInventories

Local lIsBlind        := IsBlind()

Local cIdInteg    := ""
Local cDataEnv    := Date()
Local cHorEnv     := FWTimeStamp(5)
Local cDataRec    := ""
Local cHorRec     := ""
Local cJsonRec    := ""
Local cTabela     := "SB1"

Local cErrorMessage := ""

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
                If AllTrim(FunName()) != "U_MAWSLNX30"

                    FWAlertInfo( "Estoque integrado com sucesso" )
                EndIf

                //GravaIdProduto( nRecno )                
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

        FwAlertWarning( cHTTPCode )
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
    /*
    oLinx:GravaLog( cIdInteg, cDataEnv, cHorEnv, cDataRec, cHorRec, cJsonEnv, cRetorno, cTabela, nRecno, ;
                    cURLBase + cPath, "POST", FunName(), lError, cHTTPCode, cErrorMessage )
    */
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

