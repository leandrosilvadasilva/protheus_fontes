#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"

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

		::cToken		:= SuperGetMv( "MA_LNXTOKEN", .F., "Basic bHVjaWFuby5kd3Q6ZWNvbW1hMjAyMw==" )
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

		// Verificar se tabelas customizadas existem
		If AliasInDic("SZ0")  

			ChkFile("SZ0")
			
			// Verificar campos customizados especificos
			If SC5->(FieldPos("C5_ZIDLINX")) 
			
				lRetorno := .T.
			EndIf
		EndIf

		// Verificar parametros SX6 especificos

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
			SZ0->Z0_HORREC  := HORA_RECEBIDO
			SZ0->Z0_DATAREC := DDATABASE // DATA_RECEBIDO 
			SZ0->Z0_HORENV  := HORA_ENVIO
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
			SZ0->Z0_STAMP   := FWTimeStamp(5)
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


