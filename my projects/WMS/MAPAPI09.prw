#Include "Protheus.ch"
#INCLUDE "RESTFUL.CH"
#INCLUDE "topconn.CH"
//------------------------------------------------------------------------------
/*/{Protheus.doc} SaldoEstoque

Serviço REST responsável pela liberação do item do pedido de venda
caso a regra entre o WMS AKR x ERP seja atendida.

	[ATENCAO: JSON DA REQUISICAO DEVERA SER O MESMO NO RESPOSTA CONFORME SOLICITACAO DA AKR]

{
	"codigo_empresa": "01",
	"codigo_filial": "0101",
	"codigo_armazem": "01",
	"numero_documento": "075109",
	"itens_documento": [{
			"codigo_produto": "002204",
			"lote": "1119",
			"quantidade_separada": 1,
			"quantidade_disponivel": null
		},
			{
			"codigo_produto": "002204",
			"lote": "2204",
			"quantidade_separada": 1,
			"quantidade_disponivel": null
		}]
}

@author		Lucas Brustolin
@since		MAR/2022
@version	12
/*/
//------------------------------------------------------------------------------
User Function MAPAPI09() ; Return()

WSRESTFUL SaldoEstoque DESCRIPTION "Executa Consulta do saldo em Estoque" FORMAT "application/json,text/html" 		

	WSMETHOD POST ;
	DESCRIPTION "Consulta Saldo em Estoque";
	PATH "/SaldoEstoque/" ;
	PRODUCES APPLICATION_JSON 

ENDWSRESTFUL

WSMETHOD POST WSSERVICE SaldoEstoque 

Local cMessage		As Character
Local cProduto		As Character
Local cCodLote		As Character
Local cLocalEstoque	As Character
Local cBody 		As Character
Local oBody        	As Object
Local oJsonResponse	As Object
Local oSaldoPrd		As Object 
Local nQtdSeparada  As Numeric
Local nSaldoPrd		As Numeric 
Local nI			As Numeric 
Local aProdutos 	As Array 
Local lRet 			:= .T.
Local filialATUAL   := CFILANT

// --------------------------------------------------------------
// Recupera o body da requisição
cBody := Self:GetContent()
cBody := EncodeUTF8(NoAcento(cBody))
oBody := JsonObject():New()

If ValType(oBody:fromJson( cBody )) <> "U"	.Or. Len(oBody:GetNames()) == 0  
	SetRestFault(400, EncodeUTF8( "EndPoint n�o conseguiu recuperar a requisicao JSON!"))
	lRet := .F.
Else


	IF GetJsonCpo( oBody, "codigo_filial") == '0102'
		CFILANT := '0102'
	ELSEIF GetJsonCpo( oBody, "codigo_filial") == '0103'
		CFILANT := '0103'
	ELSEIF GetJsonCpo( oBody, "codigo_filial") == '0104'
		CFILANT := '0104'
	ELSEIF GetJsonCpo( oBody, "codigo_filial") == '0105'
		CFILANT := '0105'
	ELSEIF GetJsonCpo( oBody, "codigo_filial") == '0106'
		CFILANT := '0106'
	ELSEIF GetJsonCpo( oBody, "codigo_filial") == '0107'
		CFILANT := '0107'			
	ELSEIF GetJsonCpo( oBody, "codigo_filial") == '5001'
		CFILANT := '5001'			
	ENDIF

	// ------------------------------------------------------------
	// MONTA JSON DE RESPOSTA DO REST COM O PROCESSAMENTO DO METODO 
	oJsonResponse						:= JsonObject():New()
	oJsonResponse['codigo_empresa']		:= cEmpAnt
	oJsonResponse['codigo_filial']		:= cFilAnt 
	oJsonResponse['codigo_armazem']		:= GetJsonCpo( oBody, "codigo_armazem")
	oJsonResponse['numero_documento']	:= GetJsonCpo( oBody, "numero_documento")
	oJsonResponse['itens_documento']	:= {}
	
	// ------------------------------------------------------------
	// BUSCA O SALDO EM ESTOQUE DO PRODUTO INFORMADO 	
	cLocalEstoque	:= GetJsonCpo( oBody ,"codigo_armazem")
	aProdutos 		:= GetJsonCpo( oBody, "itens_documento")	
	
	For nI := 1 To Len(aProdutos)
		
		cProduto 	:= GetJsonCpo( aProdutos[nI],	"codigo_produto") 
		cCodLote	:= GetJsonCpo( aProdutos[nI],	"lote") 
		nQtdSeparada := GetJsonCpo( aProdutos[nI],	"quantidade_separada") 

		nSaldoPrd := GetSaldoProduto( cProduto , cCodLote , cLocalEstoque, @cMessage )

		oSaldoPrd 							:= JsonObject():New()
		oSaldoPrd['codigo_produto'] 		:= cProduto
		oSaldoPrd['lote'] 					:= cCodLote
		oSaldoPrd['quantidade_separada'] 	:= nQtdSeparada
		oSaldoPrd['quantidade_disponivel'] 	:= nSaldoPrd
		oSaldoPrd['observacao'] 			:= EncodeUTF8( NoAcento(cMessage) )
		
		aAdd( oJsonResponse['itens_documento'],  oSaldoPrd )

	Next 

	//-> Mensagem de Retorno da RequisiÃƒÂ§ÃƒÂ£o
	self:setContentType("application/json")
	self:setResponse(FwJsonSerialize(ojSonResponse))

	CFILANT := filialATUAL

EndIf 	

Return( lRet )


Static Function GetJsonCpo(oObj,cTag)
Local xRet
Local xValue
Local cType

If cTag == "quantidade_separada" 
	If oObj:GetJsonValue(cTag, @xValue, @cType)
		xRet := xValue
	Else 
		xRet :=  0
	EndIf 
Else 
	If oObj:GetJsonValue(cTag, @xValue, @cType) .And. !Empty(xValue) 
		xRet := xValue //DecodeUTF8(xValue)
	Else	
		xRet := " "
	EndIf
EndIf 

Return( xRet )

// ----------------------------------------------------------------------------------------------------------
// 	ROTINA PARA BUSCAR O SALDO TOTAL DE PRODUTOS NAS TABELAS SB2 "SALDO EM ESTOQUE" OU SB8 "SALDO POR LOTE" 
// ----------------------------------------------------------------------------------------------------------
Static Function GetSaldoProduto( cProduto , cCodLote , cLocalEstoque, cMessage )

Local aArea 		:= GetArea()
Local cQuery 		:= ""
Local nSaldoPrd 	:= 0

Default cMessage := ""

	cProduto := PadR(cProduto, TamSx3("B1_COD")[1])
	
	DbSelectArea("SB1")
	SB1->( DbSetOrder(1) )
	If SB1->( DbSeek( xFilial("SB1") + cProduto  ) )

		IF ALLTRIM(SB1->B1_TIPO) == 'AI'
			// IATAN EM 09/05/2024
			nSaldoPrd := 1
		ELSE
			If Alltrim(SB1->B1_RASTRO) = 'N' 

				cQuery := " SELECT " 
				cQuery += "   SUM(B2_QATU) B2_QATU "
				cQuery += " FROM "+ RetSQLName("SB2") 
				cQuery += " WHERE "
				cQuery += "   	B2_FILIAL 		= '"+ xFILIAL("SB2") + "'"
				cQuery += "		AND B2_COD		= '"+ cProduto +"' " 
				
				If !Empty(cLocalEstoque)
					cQuery += "   	AND B2_LOCAL 	IN "+ FormatIn(cLocalEstoque,";") 
				EndIf 
				
				cQuery += "		AND D_E_L_E_T_ 	= ' ' "
				
				TcQuery cQuery Alias TSB2 New
				TSB2->(dbGoTop())
				
				While !TSB2->(EOF())
					nSaldoPrd := TSB2->B2_QATU
				
					TSB2->(dbSkip())
				Enddo
				TSB2->(dbCloseArea())			
				
				cMessage := "Busca realizada na tabela [SB2] Saldo Em Estoque "

			Else

				cQuery := " SELECT "
				cQuery += "		B8_PRODUTO, B8_LOTECTL, B8_LOCAL,"
				cQuery += "   	SUM(B8_SALDO) B8_SALDO "
				cQuery += " FROM "+ RetSQLName("SB8")
				cQuery += " WHERE "
				cQuery += "  	B8_FILIAL 		= '"+ xFILIAL("SB8") +"' "
				cQuery += "		AND B8_PRODUTO 	= '"+ cProduto +"' "
				cQuery += "   	AND B8_LOTECTL 	= '"+ cCodLote +"' " 
				
				If !Empty(cLocalEstoque)
					cQuery += "		AND B8_LOCAL 	IN " + FormatIn(cLocalEstoque,";") +" "		
				EndIf 
				
				cQuery += "   	AND D_E_L_E_T_ 	= ' ' "
				cQuery += "GROUP BY B8_PRODUTO, B8_LOTECTL, B8_LOCAL, B8_SALDO"

				TcQuery cQuery Alias TSB8 New
				TSB8->( DbGoTop())
				
				While !TSB8->(EOF())

					nSaldoPrd	:= TSB8->B8_SALDO
							
					TSB8->(dbSkip())
				Enddo
				TSB8->(dbCloseArea())
				
				cMessage := "Busca realizada na tabela [SB8] Saldo Por Lote"
				
			Endif
		ENDIF
	Else 
		cMessage := "Produto:" + cProduto + " Nao foi localizado!"
	EndIf 

RestArea( aArea )

RETURN( nSaldoPrd )

