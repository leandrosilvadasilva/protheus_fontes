#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#include "tbiconn.ch"
#include "topconn.ch"


/*
    TODO        
        [X] - Fun��o Data Epoch Unix
            [ ] - Validacao
        [X] - Fun��o / metodo  EnvioJson
            [X] - Ficou como uma  Static Function
            [X] - Validado

        [ ] - o correto seria usar a fun��o  SladoSB2()  para ober o saldo em estoque

        [ ] - relatorio dos produtos enviados com sucesso e sem sucesso
              por e-mail em excel        
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
Local cDesc       := "Integra��o ERP x Linx - Estoques"
Local cPerg       := ""
Local aInfoCustom := {}
Local cTxt        := ""
Local nTimeIni    := 0
Local oProcess    := NIL

DEFAULT cCodProduto := ""

Local lLogCV8     := SuperGetMV( "MA_LNXCV8", .F., .F. )

    TMSLogMSg( "INFO", "MAWSLNX30 -  Iniciando Integra��o Estoques - LINX -  Empresa:" + FWGrpCompany() )
    
	BEGIN SEQUENCE
    
        If oLinx:Requisitos()  .and.  oLinx:Conectado()

            // Controle de semaforo pra n�o rodar por mais de um usuario
            If !LockByName( cLockName,.F.,.F.,.T. )

                If !lIsBlind

                    cTxt := Iif( !lIsBlind, "por outro usu�rio", "pelo schedule" )
                    FwAlertWarning( "Rotina est� sendo processada " + cTxt + "  -  " + cLockName )
                Else

                    TMSLogMSg("INFO", "Rotina est� sendo processada por outro usu�rio - " + cLockName )
                Endif
                Break
            EndIf

            // Se n�o estiver rodando pelo  SCHEDULE e n�o for pelo MATA010 - Cadastro de Produtos
            If !lIsBlind  .and.  !FwIsInCallStack("U_MAWSLNX90")  .and.  !FwIsInCallStack("MATA010")

                nTimeIni := Time()
                oProcess := tNewProcess():New( 'U_MAWSLNX30', cDesc, {|oSelf| fProcPrdRun(oSelf,NIL) }, cDesc, cPerg, aInfoCustom,,, cDesc,.T.,.T. )
                FWAlertInfo( "Tempo de Dura��o " + ElapTime(nTimeIni, Time()) )

            ElseIf FwIsInCallStack("MATA010")

                If SB1->B1_MSBLQL == "1"

                    FwAlertWarning( "Produto n�o ser� integrado pois se encontra inativado", 'Prodeuto Inativado' )
                
                Else

                    fProcPrdRun( NIL, SB1->B1_COD )
                
                EndIf
            Else

                fProcPrdRun( NIL, NIL )

            Endif

            UnLockByName( cLockName,.F.,.F.,.T. )

        Else
            
            FWMsgAlert( "Plataforma de Integra��o InaAtiva" )
        EndIf

	END SEQUENCE
    

    oLinx:Destroy()
    FWFreeObj( oLinx )    
    FWFreeObj( oProcess )       
    TMSLogMSg( "INFO", "MAWSLNX30 -  Finalizando Integra��o de Estoques - LINX -  Empresa:" + FWGrpCompany() )

Return lRetorno

/*    
    Integra��o Estoque ao LINX
*/
Static Function fProcPrdRun( oProcess, cCodProduto )
Local lRetorno    := .T.
Local aArea       := FWGetArea()
Local cQuery      := ""
Local aObjEstoque := {}
Local cJson       := ""
Local jObjProd    := NIL

	cQuery := " SELECT SB1.B1_FILIAL, SB1.B1_COD, SB1.B1_IDLINX, SB1.B1_INTEG, SB1.B1_LOCPAD, SB2.B2_FILIAL, SB2.B2_COD,SB2.B2_QATU, SB2.B2_LOCAL"
    cQuery += "   FROM " + RetSqlName("SB2" ) + " SB2 INNER JOIN " + RetSqlName("SB1" ) + " SB1 ON SB2.B2_FILIAL = SB1.B1_FILIAL AND SB1.B1_COD = SB2.B2_COD " 
    cQuery += "  WHERE SB2.D_E_L_E_T_ = ' ' AND SB1.D_E_L_E_T_ = ' ' "
    cQuery += "    AND B2_COD = '" + cCodProduto + "'"
    cQuery += "    AND B2_FILIAL = '0101' "
    cQuery += "    AND SB1.B1_LINXSN = 'S' "
	
	TCQuery cQuery New Alias "TRB_SB2"
	TRB_SB2->(DbGoTop())

    //oProcess:SaveLog( "Gerando a Query: " + cQuery )

    If TRB_SB2->(EOF())

        FwAlertWarning( "Produto sem saldo em estoque  ou  produto ainda n�o integrado a plataforma: " + cCodProduto )
    Else
        While TRB_SB2->(!EOF())

            IF EMPTY(ALLTRIM(TRB_SB2->B1_IDLINX))
                ALERT("ESTE PRODUTO AINDA NAO FOI INTEGRADO. EFETUAR A INTEGRA��O ANTES DE INTEGRAR O ESTOQUE.")
            ELSE 
                ALERT("Qtd a ser integrada.: " + CVALTOCHAR(TRB_SB2->B2_QATU))

                aAdd( aObjEstoque,  JsonObject():New() )

                aObjEstoque[1]["ProductID"]              := VAL(TRB_SB2->B1_IDLINX) + 1
                aObjEstoque[1]["WarehouseID"]            := 1   // DEIXANDO CHUMBADO ARMAZEM 1 NA LINX
                aObjEstoque[1]["Quantity"]               := TRB_SB2->B2_QATU
                aObjEstoque[1]["InventoryMovementTypes"] := 9   // Motivo da movimenta��o de estoque
                aObjEstoque[1]["ActionEnum"]             := 2   // Tipo de movimenta��o de estoque: 0 - I, 1 - D or 2 - R

                jObjProd                                 := JsonObject():New()
                jObjProd["InventorySku"]                 := aObjEstoque

                cJson                                    := jObjProd:toJson()

                IntegraEstoque( cJson )
            
            ENDIF

            TRB_SB2->(dbSkip())
        EndDo
    EndIf
    TRB_SB2->(dbCloseArea())

    FwFreeObj( jObjProd )
    FwFreeArray( aObjEstoque )

FWRestArea( aArea )
Return lRetorno

/*

*/  
Static Function IntegraEstoque( cJsonEnv )
Local oRestClient     := NIL
Local cError          := ""
Local cRetorno        := ""
Local nStatus         := 0
Local lRetorno        := .F.
Local cHTTPError      := ""
Local llChkStatusCode := .T.
Local cHTTPCode       := ""
Local oJson           := JsonObject()          :New()

Local oLinx           := FATBCAIntegracaoLinx():New()
Local aHeader         := oLinx:aHeadStr
Local cURLBase        := oLinx:cURLBase
Local cPath           := "/Catalog/API.svc/web/ChangeSKUInventories

Local cIdInteg        := ""
Local cDataEnv        := Date()
Local cHorEnv         := Time()
Local cDataRec        := ""
Local cHorRec         := ""
Local cJsonRec        := ""
Local cTabela         := "SB2"
Local cErrorMessage   := ""
Local nRecno          := 0

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

    cDataRec        := Date()
    cHorRec         := Time()

    do case
    case nStatus >= 200  .and.  nStatus <= 299

        // FwAlertWarning( cHTTPCode )
        cRetorno := DecodeUTF8(oRestClient:getResult(), "cp1252")
        cJsonRec := oJson:FromJson(cRetorno)

        If cJsonRec == NIL

            lError := oJson:GetJsonObject( 'IsValid' )
            nError := Len( oJson:GetJsonObject( 'Errors' ) ) 

            If Len( nError ) == 0

                cIdInteg := cValtoChar( oJson:GetJsonObject( 'ProductID' ) )
                If AllTrim(FunName()) != "U_MAWSLNX30"

                    FWAlertInfo( "Estoque integrado com sucesso" )
                EndIf

                lRetorno := .T.
            Else

                cErrorMessage := oJson:GetJsonObject( 'Errors' )[1]:GetJsonText('ErrorMessage')                

                FwAlertWarning( cErrorMessage )
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

