#Include "Protheus.ch"
#INCLUDE "RESTFUL.CH"
//------------------------------------------------------------------------------
/*/{Protheus.doc} MovimentaImportacao

Serviço REST responsável pela Movimentação Interna de Notas de Importação

@author		Iatan Santos
@since		28/08/2022
/*/
//------------------------------------------------------------------------------

WSRESTFUL Importacao DESCRIPTION "Executa a Movimentação Interna de Notas de Importação" FORMAT "application/json,text/html" 		

	WSMETHOD POST ;
	DESCRIPTION "Movimentação Interna de Notas de Importação";
	PATH "/Importacao/" ;
	PRODUCES APPLICATION_JSON 

ENDWSRESTFUL

WSMETHOD POST WSSERVICE Importacao

Local cBody 		As Character
Local oBody        	As Object
Local oJsonResponse	As Object
Local oDados		As Object 
Local lRet 			:= .T.
Local filialATUAL   := CFILANT

// --------------------------------------------------------------
// Recupera o body da requisição
cBody := Self:GetContent()
cBody := EncodeUTF8(NoAcento(cBody))
oBody := JsonObject():New()

If ValType(oBody:fromJson( cBody )) <> "U"	.Or. Len(oBody:GetNames()) == 0  
	SetRestFault(400, EncodeUTF8( "EndPoint não conseguiu recuperar a requisicao JSON!"))
	lRet := .F.
Else

	oDados := DocImport():New( oBody )

	IF oDados:FILIAL == '0102'
		CFILANT := '0102'
	ELSEIF oDados:FILIAL == '0103'
		CFILANT := '0103'
	ELSEIF oDados:FILIAL == '0104'
		CFILANT := '0104'
	ELSEIF oDados:FILIAL == '0105'
		CFILANT := '0105'
	ELSEIF oDados:FILIAL == '0106'
		CFILANT := '0106'
	ELSEIF oDados:FILIAL == '0107'
		CFILANT := '0107'
	ELSEIF oDados:FILIAL == '5001'
		CFILANT := '5001'
	ENDIF

    lRet := oDados:Movimentar()

	// ------------------------------------------------------------
	// MONTA JSON DE RESPOSTA DO REST COM O PROCESSAMENTO DO METODO 
	oJsonResponse:= JsonObject():New()
	oJsonResponse['parametros']	:= oDados:aParam
	oJsonResponse["code"]    	:= oDados:cCode
	oJsonResponse["status"]  	:= IIF( lRet, "Success","Error") 
	oJsonResponse["message"]	:= EncodeUTF8( NoAcento(oDados:cMessage) )
	oJsonResponse['empresa']	:= cEmpAnt
	oJsonResponse['filial'] 	:= cFilAnt 
	

	//-> Mensagem de Retorno da RequisiÃƒÂ§ÃƒÂ£o
	self:setContentType("application/json")
	self:setResponse(FwJsonSerialize(ojSonResponse))

	CFILANT := filialATUAL

EndIf 	

Return( lRet )

