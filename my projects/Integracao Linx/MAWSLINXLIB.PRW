#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#include "tbiconn.ch"

#DEFINE HML		"2"
#DEFINE PRD		"1"

/*/{Protheus.doc} Biblioteca de Funções
    
    Fonte com as funções utilizadas na inegração com o Linx
    Vamos usar  CLASSE

    @type  CLASS
    @author Time DWT
    @since 25/04/2023
    @version 1.0
/*/
CLASS FATBCAIntegracaoLinx FROM LongNameCLASS

    // Variaveis / Propriedades
	DATA cToken		AS STRING
	DATA cURLBase	AS STRING
	DATA aHeadStr	AS STRING

    // Funções / Metodos de Execução
    METHOD New() CONSTRUCTOR
    METHOD Destroy() 
	METHOD Conectado()
	METHOD EnviaProduto()
	METHOD Requisitos()
	METHOD GravaLog( CHAVE_INTEGRACAO, DATA_ENVIO, HORA_ENVIO, DATA_RECEBIDO, HORA_RECEBIDO, JSON_ENVIO, JSON_RECEBIMENTO, TABELA_ENTIDADE, RECNO, URLPATH, ACAO, ROTINA, OK, STATUS_HTTP )
	METHOD EnviaMail()
	METHOD NoAcento( cString )
	METHOD BaixaTitCliente( aSE1Linx )
	METHOD GeraParcelasCC( cParcelas, aSE1Linx )

	METHOD SearchOrders()
	METHOD GetOrderByNumber( aPVLinx, cParcelas )

ENDCLASS

METHOD New() CLASS FATBCAIntegracaoLinx
    
    // Inicializa as variaveis
    // self:Variavel_2
    // ::Variavel_1

	If SuperGetMv( "MA_LNXAMB", .F., HML ) == HML
		/*
		::cToken		:= SuperGetMv( "MA_LNXTOKEN", .F., "Basic bWEuaW50ZWdyYWNhbzppbnRAMjAyMyNNYSQ=" )
		::cURLBase		:= SuperGetMv( "MA_LNXURLBASE", .F., "https://olapropagandaemuitomais.layer.core-hlg.dcg.com.br/v1" )
		*/
		::cToken		:= SuperGetMv( "MA_LNXTOKEN", .F., "Basic dGkubWFob3NwaXRhbGFyOmludEAyMDIzI01hJA==" )
		::cURLBase		:= SuperGetMv( "MA_LNXURLBASE", .F., "https://mah.layer.core.dcg.com.br/v1" )
	Else

		::cToken		:= SuperGetMv( "MA_LNXTOKEN", .F., "Basic cHJvdGhldXMuaW50ZWdyYWNhbzpAU2xtVDIwMjRUb3R2U0A=" )
		::cURLBase		:= SuperGetMv( "MA_LNXURLBASE", .F., "https://mahospitalar.layer.core.dcg.com.br/v1" )
	EndIF

	::aHeadStr		:= {}

	//Incluir chaves no vetor para autenticaÃ§Ã£o
	aAdd( ::aHeadStr,'User-Agent: Mozilla/4.0 (compatible; Protheus '+ GetBuild() + ')' )
	aAdd( ::aHeadStr,"Content-Type: application/json")
	aAdd( ::aHeadStr,"Accept: application/json")
	aAdd( ::aHeadStr,"Authorization: " + ::cToken )
	aAdd( ::aHeadStr, "tenantId: " + FwCodEmp() + "," + FWCodFil() )
    
	If ExistBlock( "MALIBREQUISITOSLINX" )

		ExecBlock( "MALIBREQUISITOSLINX", .F., .F., { ::aHeadStr } )
	EndIf

Return self


METHOD Destroy() CLASS FATBCAIntegracaoLinx
    
	::cToken	:= ""
	::cURLBase	:= ""
	aSize( ::aHeadStr, 0 )

Return .T.


METHOD Conectado() CLASS FATBCAIntegracaoLinx
Local lRetorno   := .T.
Local cRespJSON  := ""
Local cHeaderRet := ""
Local cUrl       := ::cURLBase + "/HealthCheck/API.svc/web/GetCheck"
Local oJsCat     := Nil

	cRespJSON := HTTPPost(cUrl,,"",,::aHeadStr,@cHeaderRet)	
	FWJsonDeserialize(cRespJSON,@oJsCat)
	lRetorno  := cRespJSON <> NIL .and. ("200 OK" $ cHeaderRet .or. "201 Created" $ cHeaderRet)

Return lRetorno

METHOD Requisitos() CLASS FATBCAIntegracaoLinx
Local lRetorno   := .F.
Local lIntegLINX := SuperGetMV( "ES_LINXINT", .F., .T. )

	If lIntegLINX

		lRetorno := .T.
		// Verificar se tabelas customizadas existem
		If AliasInDic("SZ0")  

			ChkFile("SZ0")
			
			// Verificar campos customizados especificos
			If SC5->(FieldPos("C5_ZIDLINX")) 
			
				lRetorno := .T.
			EndIf
		EndIf

		// Verificar parametros SX6 especificos


		// Verifoca  indices  necessarios


	EndIf

	If ExistBlock( "MALIBREQUISITOSLINX" )

		ExecBlock( "MALIBREQUISITOSLINX", .F., .F. )
	EndIf

Return lRetorno

METHOD GravaLog( CHAVE_INTEGRACAO, DATA_ENVIO, HORA_ENVIO, DATA_RECEBIDO, HORA_RECEBIDO, ;
                 JSON_ENVIO, JSON_RECEBIMENTO, TABELA_ENTIDADE, RECNO, URLPATH, ACAO, ;
				 ROTINA, OK, STATUS_HTTP, ERROR_MESSAGE_REST, LOG_EXECAUTO, OBSERVACAO  ) ;
				CLASS FATBCAIntegracaoLinx
Local lRetorno  := .T.
Local cProcName := ProcName(1)

DEFAULT LOG_EXECAUTO := ""
DEFAULT OBSERVACAO   := ""


	If AliasInDic( "SZ0")

		SZ0->(dbSelectArea("SZ0"))
		If RecLock('SZ0', .T.)
			SZ0->Z0_FILIAL  := FWXFilial()
			SZ0->Z0_IDINTEG := CHAVE_INTEGRACAO
			SZ0->Z0_DATAENV := DDATABASE // DATA_ENVIO
			SZ0->Z0_HORENV  := HORA_ENVIO
			SZ0->Z0_DATAREC := DDATABASE // DATA_RECEBIDO 
			SZ0->Z0_HORREC  := HORA_RECEBIDO
			SZ0->Z0_JSONENV := JSON_ENVIO
			SZ0->Z0_JSONREC := JSON_RECEBIMENTO
			SZ0->Z0_TABELA  := TABELA_ENTIDADE
			SZ0->Z0_RECNO   := RECNO
			SZ0->Z0_URLPATH := URLPATH
			SZ0->Z0_USUARIO := CUSERNAME
			SZ0->Z0_ACAO    := ACAO
			SZ0->Z0_ROTINA  := ROTINA
			SZ0->Z0_OK      := IF( OK, "TRUE", "FALSE" )
			SZ0->Z0_CODHTTP := STATUS_HTTP
			SZ0->Z0_EXECAUT := LOG_EXECAUTO
			SZ0->Z0_STAMP11   := FWTimeStamp(5)
			SZ0->Z0_PROCNAM := cProcName
			SZ0->Z0_OBS     := OBSERVACAO
			SZ0->(MsUnlock())
		EndIf


		If ExistBlock( "MALIBGRAVALOGLINX" )

			ExecBlock( "MALIBGRAVALOGLINX", .F., .F., SZ0->(Recno(), SZ0->Z0_MSIDENT, SZ0->Z0_MSUID ) )
		EndIf
	EndIf

Return lRetorno

METHOD EnviaMail() CLASS FATBCAIntegracaoLinx
Local lRetorno   := .T.


Return lRetorno

METHOD NoAcento( cString ) CLASS FATBCAIntegracaoLinx
Local cChar     := ""
Local nX        := 0
Local nY        := 0
Local cVogal    := "aeiouAEIOU"
Local cAgudo    := "áéíóú"+"ÁÉÍÓÚ"
Local cCircu    := "âêîôû"+"ÂÊÎÔÛ"
Local cTrema    := "äëïöü"+"ÄËÏÖÜ"
Local cCrase    := "àèìòù"+"ÀÈÌÒÙ"
Local cTio      := "ãõÃÕ"
Local cCecid    := "çÇ"
Local cMaior    := "&lt;"
Local cMenor    := "&gt;"

DEFAULT cString := ""

For nX:= 1 To Len(cString)
	cChar:=SubStr(cString, nX, 1)
	IF cChar$cAgudo+cCircu+cTrema+cCecid+cTio+cCrase
		nY:= At(cChar,cAgudo)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cCircu)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cTrema)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cCrase)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf		
		nY:= At(cChar,cTio)
		If nY > 0          
			cString := StrTran(cString,cChar,SubStr("aoAO",nY,1))
		EndIf		
		nY:= At(cChar,cCecid)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr("cC",nY,1))
		EndIf
	Endif
Next

If cMaior$ cString 
	cString := strTran( cString, cMaior, "" ) 
EndIf
If cMenor$ cString 
	cString := strTran( cString, cMenor, "" )
EndIf

cString := StrTran( cString, CRLF, " " )

Return cString

METHOD BaixaTitCliente( aSE1Linx ) CLASS FATBCAIntegracaoLinx
Local lRetorno  := .T.
Local aBaixa    := {}
Local aArea     := FWGetArea()

Private lMsErroAuto 	:= .F.
Private lMsHelpAuto 	:= .T.
Private lAutoErrNoFile 	:= .T.

DEFAULT aSE1Linx := {}

	If aSE1Linx[8] > 0
		aBaixa := {;
					{"E1_FILIAL"   , aSE1Linx[1],Nil    },;
					{"E1_PREFIXO"  , aSE1Linx[2],Nil    },;
					{"E1_NUM"      , aSE1Linx[3],Nil    },;
					{"E1_PARCELA"  , aSE1Linx[4],Nil    },;
					{"E1_TIPO"     , aSE1Linx[5],Nil    },;
					{"E1_CLIENTE"  , aSE1Linx[6],Nil    },;
					{"E1_LOJA"     , aSE1Linx[7],Nil    },;	
					{"AUTMOTBX"    ,"NOR"       ,Nil    },;
					{"AUTBANCO"    ,"ECC"       ,Nil    },;
					{"AUTAGENCIA"  ,"0001 "     ,Nil    },;
					{"AUTCONTA"    ,"000001    ",Nil    },;
					{"AUTDTBAIXA"  , dDataBase  ,Nil    },;
					{"AUTDTCREDITO", dDataBase  ,Nil    },;
					{"AUTHIST"     , "BAIXA LINX",Nil   },;
					{"AUTJUROS"    , 0          ,Nil,.T.},;
					{"AUTVALREC"   , aSE1Linx[8],Nil    } ;
				  }
	
		VarInfo( "aBaixa", aBaixa )

		BEGIN TRANSACTION
		
			lMSErroAuto := .F.
		
			FWMsgRun(, {|| MSExecAuto({|x,y| FINA070(x,y)},aBaixa,3) }, "Aguarde", 'Baixando titulo do cliente...' )

			// MSExecAuto({|x,y| Fina070(x,y)},aBaixa,3)
		
			If lMSErroAuto

				DisarmTransaction()
				FWAlertInfo("Ocorreram erros durante o processo. Confirme para visualizar o erro")
				MostraErro()

				lRretorno := .F.
			EndIf

		END TRANSACTION

	EndIf

FWRestArea( aArea )	
Return lRetorno

METHOD GeraParcelasCC( cParcelas, aSE1Linx, lVariasParcelas ) CLASS FATBCAIntegracaoLinx
Local lRetorno   := .T.
Local aTitulo    := {}
Local aArea      := FWGetArea()

Local cNumTitulo := aSE1Linx[3]	// GetSX8Num("SE1","E1_NUM")
Local cNatureza  := SuperGetMV( "ES_CC1LINX", .F., "111109" )  // Natureza especifica pra  CC
Local cCliente   := SuperGetMV( "ES_CC2LINX", .F., "000001" /*aSE1Linx[6]*/ )
Local cLojaCli   := SuperGetMV( "ES_CC3LINX", .F., "0001"   /*aSE1Linx[7]*/ )
Local cTipo      := SuperGetMV( "ES_CC4LINX", .F., "NF "    /*aSE1Linx[5]*/ )
Local cPrefixo   := SuperGetMV( "ES_CC5LINX", .F., "CC "    /*aSE1Linx[1]*/ )

Private lMsErroAuto 	:= .F.
Private lMsHelpAuto 	:= .T.
Private lAutoErrNoFile 	:= .T.

DEFAULT aSE1Linx := {}

	If !lVariasParcelas

		cCliente   := SuperGetMV( "ES_CC6LINX", .F., "000001" /*aSE1Linx[6]*/ )
		cLojaCli   := SuperGetMV( "ES_CC7LINX", .F., "0001"   /*aSE1Linx[7]*/ )
	EndIf

	If aSE1Linx[8] > 0

		aTitulo := { ;					 
					 {"E1_PREFIXO" , cPrefixo   , Nil},;
					 {"E1_NUM"     , cNumTitulo , Nil},;
					 {"E1_PARCELA" , " "        , Nil},;
					 {"E1_TIPO"    , cTipo      , Nil},;
					 {"E1_NATUREZ" , cNatureza  , Nil},;
					 {"E1_CLIENTE" , cCliente   , Nil},;
					 {"E1_LOJA"    , cLojaCli   , Nil},;					
					 {"E1_EMISSAO" , dDataBase  , Nil},;
					 {"E1_VENCTO"  , dDataBase  , Nil},;
					 {"E1_VENCREA" , dDataBase  , Nil},;
					 {"E1_VALOR"   , aSE1Linx[8], Nil},;
					 {"E1_DESDOBR" , "S"        , Nil} ;
				   }

		aAdd(aTitulo,{"AUTHISTDSD", "Parcelas LINX em " + cValToChar( cParcelas ) + "X", Nil}) //Historico
		aAdd(aTitulo,{"AUTNPARDSD", cParcelas      , Nil}) // Numero de parcelas
		aAdd(aTitulo,{"AUTTOPADSD", "T"            , Nil}) // Valor T = TOTAL ou P = PARCELA
		aAdd(aTitulo,{"AUTPERIDSD", 30             , Nil}) // Periodo            

		VarInfo( "aTitulo", aTitulo )

		BEGIN TRANSACTION
		
			lMSErroAuto := .F.
		
		    // https://tdn.totvs.com/pages/releaseview.action?pageId=306856119
			FWMsgRun(, {|| MSExecAuto({|x,y,z| FINA040(x,y,z)},aTitulo,3) }, "Aguarde", 'Gerando parcelas...' )
	
			If lMSErroAuto

				DisarmTransaction()
				FWAlertInfo("Ocorreram erros durante o processo. Confirme para visualizar o erro")
				MostraErro()

				lRretorno := .F.
			EndIf

		END TRANSACTION

	EndIf

FWRestArea( aArea )	
Return lRetorno


METHOD GetOrderByNumber( aPVLinx, cParcelas ) CLASS FATBCAIntegracaoLinx
Local lRetorno         := .F.
Local oRestClient      := NIL
Local cError           := ""
Local cRetorno         := ""
Local nStatus          := 0

Local cHTTPError       := ""
Local llChkStatusCode  := .T.
Local cHTTPCode        := ""
Local oJson            := JsonObject():New()

Local oLinx            := FATBCAIntegracaoLinx():New()
Local aHeader          := oLinx:aHeadStr
Local cURLBase         := oLinx:cURLBase
Local cPath            := "/Sales/API.svc/web/GetOrderByNumber"

// Variaveis para o  GravaLOG
Local cDataEnv         := Date()
Local cHorEnv          := Time() // FWTimeStamp(5)
Local cDataRec         := ""
Local cHorRec          := ""
Local cJsonRec         := ""
Local cTabela          := "XXX"
Local nRecno           := 0
Local cIdInteg         := ""
Local cJsonEnv         := ""
Local lError           := .F.
Local cErrorMessage    := ""

Local cNumPedVendaLinx := aPVLinx[2]


    oRestClient := FWRest():New(cURLBase)
    oRestClient:SetPath(cPath)
    oRestClient:SetChkStatus(.F.)

    oRestClient:SetPostParams( cNumPedVendaLinx ) 

    cDataRec        := Date()
    cHorRec         := Time() // FWTimeStamp(5)

    lSucess         := oRestClient:Post(aHeader)
    cRetorno        := oRestClient:GetResult()
    cError          := oRestClient:GetLastError()
    llChkStatusCode := oRestClient:GetChkStatus()
    cHTTPCode       := oRestClient:GetHTTPCode()
    nStatus         := HTTPGetStatus(@cHTTPError)

    do case
    case nStatus >= 200  .and.  nStatus <= 299

        // FwAlertWarning( cHTTPCode )
        cRetorno := DecodeUTF8(oRestClient:getResult(), "cp1252")
        cJsonRec := oJson:FromJson(cRetorno)

        VarInfo( "JSON Pedido", oJson )

        If cJsonRec == NIL

            cPaymentStatus := oJson:GetJsonObject( 'PaymentStatus' ) 
            cStatusIDOrder := oJson:GetJsonObject( 'OrderStatusID' )
            cIDOrder       := oJson:GetJsonObject( 'OrderID' )

			// Forma de Pagamento
			cPaymentMethodID  := oJson:GetJsonObject( 'PaymentMethods' )[1]:GetJsonText( 'PaymentMethodID' )
			cAlias            := oJson:GetJsonObject( 'PaymentMethods' )[1]:GetJsonObject( 'PaymentInfo' ):GetJsonText( 'Alias' )
			cPaymentType      := oJson:GetJsonObject( 'PaymentMethods' )[1]:GetJsonObject( 'PaymentInfo' ):GetJsonText( 'PaymentType' )

			cInstallments     := oJson:GetJsonObject( 'PaymentMethods' )[1]:GetJsonObject( 'Installments' )


			lRetorno  := .T.
			cParcelas := cInstallments
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
                    cURLBase + cPath, "GET", FunName(), lError, cHTTPCode, cErrorMessage )  

    FWFreeObj(oLinx)    
    FreeObj(oJson)
    FreeObj(oRestClient)

Return lRetorno

/*
https://mahospitalar.layer.core.dcg.com.br/v1/Sales/API.svc/web/SearchOrders
BODY:
{
  "Page": {
    "PageIndex": 0,
    "PageSize": 0
  },
  "Where": "CreatedDate >= \"2024-04-19T00:00:00.000Z\" && CreatedDate <= \"2024-04-19T23:59:00.000Z\"",
  "OrderBy": "OrderNumber Desc"
}
*/
