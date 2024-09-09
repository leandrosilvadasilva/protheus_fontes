
#Include "Protheus.ch"
#INCLUDE "RESTFUL.CH"
//------------------------------------------------------------------------------
/*/{Protheus.doc} LiberaPedido

Serviço REST responsável pela liberação do item do pedido de venda
caso a regra entre o WMS AKR x ERP seja atendida.

@author		Lucas Brustolin
@since		FEV/2022
@version	12
/*/
//------------------------------------------------------------------------------

WSRESTFUL LiberaPedido DESCRIPTION "Executa a liberacao do pedido de venda" FORMAT "application/json,text/html" 		

	WSMETHOD POST ;
	DESCRIPTION "Liberacao Pedido de Venda.";
	PATH "/LiberaPedido/" ;
	PRODUCES APPLICATION_JSON 

ENDWSRESTFUL

WSMETHOD POST WSSERVICE LiberaPedido 

Local cBody 		As Character
Local oBody        	As Object
Local oJsonResponse	As Object
Local oPedido		As Object 
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

	oPedido := PedVendaWMS08():New( oBody )

	IF oPedido:CFILPED == '0102'
		CFILANT := '0102'
	ELSEIF oPedido:CFILPED == '0103'
		CFILANT := '0103'
	ELSEIF oPedido:CFILPED == '0104'
		CFILANT := '0104'
	ELSEIF oPedido:CFILPED == '0105'
		CFILANT := '0105'
	ELSEIF oPedido:CFILPED == '0106'
		CFILANT := '0106'
	ELSEIF oPedido:CFILPED == '0107'
		CFILANT := '0107'		
	ELSEIF oPedido:CFILPED == '5001'
		CFILANT := '5001'		
	ENDIF
	
	If oPedido:CheckObrigat()
		// -----------------------------------------------------
		// VALIDA REGRA PARA LIBERACAO
		If oPedido:CheckPedido()
			// ---------------------------------------------------
			// FAZ A LIBERAÇÃO DO PEDIDO POR (ITEM)		
			lRet := oPedido:Liberar()

		Else
			lRet := .F. 
		EndIf 
	Else 
		lRet := .F.
	EndIf 

	// ------------------------------------------------------------
	// MONTA JSON DE RESPOSTA DO REST COM O PROCESSAMENTO DO METODO 
	oJsonResponse:= JsonObject():New()
	oJsonResponse['parametros']	:= oPedido:aParam
	oJsonResponse["code"]    	:= oPedido:cCode
	oJsonResponse["status"]  	:= IIF( lRet, "Success","Error") 
	oJsonResponse["message"]	:= EncodeUTF8( NoAcento(oPedido:cMessage) )
	oJsonResponse['empresa']	:= cEmpAnt
	oJsonResponse['filial'] 	:= cFilAnt 
	

	//-> Mensagem de Retorno da RequisiÃƒÂ§ÃƒÂ£o
	self:setContentType("application/json")
	self:setResponse(FwJsonSerialize(ojSonResponse))

	CFILANT := filialATUAL

EndIf 	

Return( lRet )

