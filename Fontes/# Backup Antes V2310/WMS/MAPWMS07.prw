#Include "TOTVS.ch" 
#Include "RESTFUL.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "tbiconn.ch"
#INCLUDE "topconn.CH"

#DEFINE _sEnter CHR(10)+CHR(13)

/*--------------------------------------------------------------------------------------------------*
| Func:  MAPWMS07()                                                     							|
| Autor: Lucas Brustolin                                              								|
| Data:  Fev/2022                                                   								|
| Desc:  Rotina para envio de Pedidos de Venda para AKR	        	                                |   
|																									|
| Alterações .:  /                                                            						|
*--------------------------------------------------------------------------------------------------*/
User Function MAPWMS07( nRecnoSC5, cMessage)

Local _oPostUser as Object
Local _sPath := "/api/Mahospitalar.V1_0_0/Doc/Add"
Local _sPutErro := ""
Local _aRetPost := {}
Local _sException	:= ""
Local lBlqCred		:= .F.


Default nRecnoSC5	:= SC5->( Recno() )
Default cMessage	:= ""

    Private _sURL := U_MAPWMSAuth(1)

	//IATAN EM 14/10/2022 - IMPLEMENTADO TESTE AFIM DE EVITAR DUPLICIDADE DE PEDIDOS NO WMS
	IF SC5->C5_XWMS == 'S' 
		RETURN .T.
	ENDIF

	lBlqCred 		:= U_ChkBlqCred( SC5->C5_FILIAL, SC5->C5_NUM )
	If lBlqCred 
			// PEDIDOS COM BLOQUEIO DE CR�DITO N�O PODEM INTEGRAR 
			cMessage := "Pedido com bloqueio de credito."
			RETURN .F.
	ENDIF

    _aHeader	:= MontaHead()
    _sJsonPost 	:= MontaJson( nRecnoSC5 )

    _oPostUser := FWRest():New(_sURL)
    _oPostUser:setPath(_sPath)
    _oPostUser:SetPostParams(_sJsonPost)	
	
	//IATAN EM 23/02/2023
	_oPostUser:nTimeOut := 60000

    If _oPostUser:Post(_aHeader)
        _sRetorno := _oPostUser:GetResult()
        
        _oGetRet := JSonObject():New()
        _cErro := _oGetRet:FromJson(_sRetorno)
        _sException := ""        

        If Empty(_cErro)
            _bStatus := _oGetRet:GetJsonObject("status")
            If !_bStatus
                _sException := _oGetRet:GetJsonObject("exception")
                _aRetPost := {.F.,"ERRO POST PEDIDO VENDA RETORNO ==>"+ _sException}
            Else
                _aRetPost := {.T.,"Post PEDIDO VENDA Enviado com Sucesso!"}
            EndIf            
            FreeObj(_oGetRet)
        Else
            _sPutErro 	:= "ERRO JSON PEDIDO VENDA ==> Erro ao converter o retorno da Api em JSON" 
            _aRetPost 	:= {.F.,_sPutErro}
        Endif
    Else
		_sPutErro := "Erro POST PEDIDO VENDA => "
        _sPutErro += _oPostUser:GetLastError() + _sEnter
        //_sPutErro += "ERRO POST PEDIDO VENDA AUTH => " + _oPostUser:GetResult() + _sEnter
        //_sPutErro += _sParam		
        _aRetPost := {.F.,_sPutErro}
    EndIf
    
	If !Empty(_sPutErro) .or. !Empty(_sException)
		FwMakeDir("integracao_wms\pedido\erro")
		//MEMOWRITE("integracao_wms\pedido\erro\"+ SC5->C5_FILIAL + SC5->C5_NUM + ".error", _sPutErro + CRLF +"Exception: " + _sException)
	
		FwMakeDir("integracao_wms\pedido\")
		//MEMOWRITE("integracao_wms\pedido\"+ SC5->C5_FILIAL + SC5->C5_NUM + ".json", _sJsonPost )
	EndIf 

    FreeObj(_oPostUser)

	cMessage := _aRetPost[2]

Return( _aRetPost[1] )


/*--------------------------------------------------------------------------------------------------*
| Func:  MontaHead()                                                     							|
| Autor: Lucas Brustolin                                              								|
| Data:  FEV/2022                                                   								|
| Desc:  Função responsável por montar o cabeçalho das resquisições para AKR		 				|
|																									|
| Alterações .:  /                                                            						|
*--------------------------------------------------------------------------------------------------*/
Static Function MontaHead()
	Local _aHeadRest := {}
	Local _aGetToken := {}
    
    _aGetToken := U_MAPWMS01()

    If _aGetToken[1]
        AADD(_aHeadRest,"Content-Type:application/json" ) 
        AADD(_aHeadRest, "Authorization: Bearer "+Alltrim(_aGetToken[2]))
    Else
        conout("ERRO PEDIDO VENDA MONTA HEADER ==> Não foi possível montar o header: "+_aGetToken[2])
    EndIf
        
    
Return _aHeadRest

/*--------------------------------------------------------------------------------------------------*
| Func:  MontaJson()                                                     							|
| Autor: Lucas Brustolin                                              								|
| Data:  FEV/2022                                                   								|
| Desc:  Função responsável por montar o cabeçalho das resquisições para AKR		 				|
|																									|
| Alterações .:  /                                                            						|
*--------------------------------------------------------------------------------------------------*/
Static Function MontaJson( nRecnoSC5 )
   
Local aArea 	:= GetArea()
Local jPedVenda	:= Nil 
Local jPedAux	:= Nil 
Local cParJSON	:= ""
Local dDataAlt	:= CTOD("")

            


	If nRecnoSC5 > 0 
		SC5->( DbGoTo(  nRecnoSC5 ) )
	EndIf 

	If SC5->( FieldPos("C5_USERLGA") ) > 0 .And. !Empty(FWLeUserlg("C5_USERLGA", 2))
		dDataAlt := STOD(FWLeUserlg("C5_USERLGA", 2))
	EndIf 

	// ITEM Pedido de Venda
	DbSelectArea("SC6")
	SC6->( DbSetOrder(1) )
	SC6->( DbSeek(xFilial("SC6")+SC5->C5_NUM) )

	// Saldo do Produto por Lote
	DbSelectArea("SB8")
	SB8->(DBSetOrder(1))

	jPedVenda 				:= JSonObject():New()
	jPedVenda["DocModel"]	:= {}

	While SC6->( !Eof() ) .And. SC6->C6_NUM == SC5->C5_NUM

		SB8->(MsSeek(SC6->C6_FILIAL + SC6->C6_PRODUTO + SC6->C6_LOCAL + DTOS(SC6->C6_DTVALID) + SC6->C6_LOTECTL))


		jPedAux		:= JSonObject():New()
		 
		jPedAux["DocEntry"] 		:= SC5->C5_NUM							// Número do Documento - Pedido
		jPedAux["DocNum"] 			:= SC6->C6_ITEM							// Número da Linha do Documento 
		jPedAux["CardCodeOrigem"] 	:= cEmpAnt + cFilAnt					// Parceiro de Negócio - ORIGEM 
		jPedAux["CardCodeDestino"] 	:= SC5->C5_CLIENTE + SC5->C5_LOJACLI			// Parceiro de Negócio - DESTINO (CLIENTE ENTREGA?)
		jPedAux["CreateDate"] 		:= FormatDate( SC5->C5_EMISSAO )		// Data de Cadastro 
		jPedAux["UpdateDate"] 		:= FormatDate( dDataAlt )				// Data de Alteração
		jPedAux["OrderedQty"] 		:= SC6->C6_QTDVEN						// Quantidade Solicitada
		jPedAux["Quantity"] 		:= SC6->C6_QTDLIB						// Quantidade Atendida - Opcional
		jPedAux["OpenQty"] 			:= Ma440SaLib()							// Quantidade em Aberto - Campo Virtual SC6->C6_SLDALIB = Ma440SaLib = nSaldo := Max(SC6->C6_QTDVEN - SC6->C6_QTDEMP - SC6->C6_QTDENT,0)
		jPedAux["ItemCode"] 		:= SC6->C6_PRODUTO	    				// Código do Item
		jPedAux["unitMsr"] 			:= SC6->C6_UM							// Unidade de Medida Original
		jPedAux["unitMsr2"] 		:= SC6->C6_UM							// Unidade de Medida Da Venda
		jPedAux["LineStatus"] 		:= "O"									// Status da Linha do Documento [O - Aberto, C - Fechado]
		jPedAux["DocStatus"] 		:= "O"									// Status do Documento [O - Aberto, C - Fechado]
		//Iatan em 27/06/2022
		//jPedAux["Usage"] 			:= SC6->C6_TES	    					// Código da Utilização
		jPedAux["Usage"] 			:= SC6->C6_OPER	    					// Código da Utilização
		jPedAux["ModeloSaida"] 		:= AllTrim(SC5->C5_XOPEWMS) 			//DePara("ModeloSaida", SC5->C5_TIPO )	// Modelo de Saída do Pedido [0 - Nenhum, 1 - Simples Remessa, 2- Devolução de Simples Remessa, 3 - Transferência Retorno, 4 - Backlog, 5 - Venda, 6 - Bonificação, 7 - Perda, 8 - Transferência Envio, 9 - Divergência, 10 - Devolução de Venda, 11 - Revenda, 12 - Envio Filial, 13 - Devolução Recebimento Filial, 14 - Transferência Envio Filial, 15 - Reconsignação Retorno, 16 - Reconsignação Envio] = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16']
		jPedAux["FabricacaoDate"] 	:= FormatDate( SB8->B8_DFABRIC )		// Data de Fabricação Lote - optional
		jPedAux["ValidadeDate"] 	:= FormatDate( SC6->C6_DTVALID )		// Data de Validade do Lote- optional
		jPedAux["Lote"] 			:= AllTrim(SC6->C6_LOTECTL)				// Número do Lote
		//Iatan em 23/06/2022
		jPedAux["DocObs"] 			:= AllTrim(SC5->C5_OBSEXPE)				// Observa��o do pedido
		jPedAux["SerialObs"] 		:= AllTrim(SC5->C5_OBSNFSE)				// Observa��o da Nota Fiscal
		//Iatan em 26/07/2022
		jPedAux["Price"] 			:= SC6->C6_PRCVEN						// Pre�o
		jPedAux["DeliveryDate"] 	:= FormatDate(SC6->C6_ENTREG)			// Data de Entrega
		//Iatan em 11/08/2022
		IF AllTrim(SC5->C5_ZTPLIBE) == '1'
			jPedAux["Parcial"] 			:= 'true'				// Pedido parcial
		ELSE
			jPedAux["Parcial"] 			:= 'false'				// Pedido parcial
		ENDIF


		
		AAdd( jPedVenda["DocModel"], jPedAux )
	
		SC6->( DbSkip() )
	EndDo 

	cParJSON 	:= jPedVenda:GetJsonText("DocModel") //cParJSON := EncodeUTF8( jPedVenda:ToJSON() )
	cParJSON	:= EncodeUTF8(cParJSON)	 

RestArea( aArea )  

Return( cParJSON )


Static Function FormatDate( xDate )

Local cDateFormat := ""

	If !Empty(xDate)
		If ValType(xDate) == "D"
			//cDateFormat := FWTimeStamp(6, SC5->C5_EMISSAO )
			cDateFormat := FWTimeStamp(6, xDate )
		EndIf 
	EndIf 

Return( cDateFormat )

Static Function DePara( cField, xValue )

Local xRet := Nil 

cField := UPPER( AllTrim( cField ) )

	If cField == "MODELOSAIDA"
		
		// N=Normal;C=Compl.Preco/Quantidade;I=Compl.ICMS;P=Compl.IPI;D=Dev.Compras;B=Utiliza Fornecedor                 
		// [0 - Nenhum, 1 - Simples Remessa, 
		// 2- Devolução de Simples Remessa, 
		// 3 - Transferência Retorno, 
		// 4 - Backlog, 
		// 5 - Venda, 
		// 6 - Bonificação, 
		// 7 - Perda, 
		// 8 - Transferência Envio, 
		// 9 - Divergência, 
		// 10 - Devolução de Venda, 
		// 11 - Revenda, 
		// 12 - Envio Filial, 
		// 13 - Devolução Recebimento Filial, 
		// 14 - Transferência Envio Filial, 
		// 15 - Reconsignação Retorno, 
		// 16 - Reconsignação Envio] = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16']
		Do Case 
			Case xValue == "N" ; xRet := 5
			Case xValue == "C" ; xRet := 5
			Case xValue == "I" ; xRet := 5
			Case xValue == "D" ; xRet := 10
			Case xValue == "B" ; xRet := 10
			OtherWise 
				xRet := 5
		EndCase  

	ElseIf  cField == "USAGE"

	ElseIf  cField == "DOCSTATUS"

	EndIf 

Return( xRet )

/*--------------------------------------------------------------------------------------------------*
| Func:  U_X7OPERWMS()                                                     							|
| Autor: Lucas Brustolin                                              								|
| Data:  MAR/2022                                                   								|
| Desc:  Gatilha opera��o WMS conforme a TES de sa�da do item 01 do pedido de venda		 			|
|																									|
| CHAMADA PELO GATILHO C6_TES                                                                       |
| IIF(FindFunction("U_X7OPERWMS"),U_X7OPERWMS(M->C6_TES),M->C6_TES)         					    |
| Altera��es .:   	                                                            					|
*--------------------------------------------------------------------------------------------------*/
User Function X7OPERWMS( cTES )

Local aArea 	:= GetArea()
Local cOperWMS 	:= ""

DbSelectArea("SC5")

	If FieldPos("C5_XOPEWMS") > 0	
		If Valtype(aCols) == "A" .And. ValType(n) == "N" .And. n == 1 

			If AllTrim(cTES) >= "500"

				cOperWMS := Posicione("SF4",1,xFilial("SF4") + cTES, "F4_XOPEWMS" )
			
				M->C5_XOPEWMS := cOperWMS
			
			Else 
				M->C5_XOPEWMS := ""
			EndIf 
		EndIf 
	Else 
		FwLogMsg("ERROR",, "MAPWMS07", "X7OPERWMS", "", "01", "Campo customizado C5_XOPEWMS (Pedido de Venda) nao se encontra do dicionario de dados. Nao sera possivel envia-lo na integracao com o WMS ", 0, 0, {}) 
	EndIf 

RestArea( aArea )

Return( cTES )


/*
-----------------------------------------------------------------------------------------------
Funcao			- ChkBlqCred
Autor 			- 
Descricao 		- Verifica se o Pedido tem Bloqueio de Credito
Data 			- 04/2022
-----------------------------------------------------------------------------------------------
*/
User Function ChkBlqCred(cFilPed,cPedido)

	Local cAlias		:= GetNextAlias()
	Local cQuery		:= ""
	Local lExistBlq		:= .F.

	Default cFilPed := xFilial("SC9") 
	Default cPedido	:= ""

	cQuery += " SELECT 	SC9.C9_PEDIDO" 								+ CRLF
	cQuery += " FROM 		" + RetSqlName("SC9") + " SC9" 			+ CRLF
	cQuery += " WHERE 	SC9.C9_FILIAL		= '" + cFilPed + "'" 	+ CRLF
	cQuery += " AND 		SC9.C9_PEDIDO	= '" + cPedido + "'" 	+ CRLF
	cQuery += " AND 		SC9.C9_BLCRED 	<> ''" 					+ CRLF
	cQuery += " AND 		SC9.C9_BLCRED 	<> '10'" 				+ CRLF
	// DDWT Luciano 20231030 - Mais Negocios
    cQuery += " AND SC9.C9_BLCRED NOT IN ( '80', '92', '90', '91')" + CRLF	
	cQuery += " AND 		SC9.D_E_L_E_T_ 	= ''" 					+ CRLF
	cQuery += " GROUP BY SC9.C9_PEDIDO "			 				+ CRLF
	
	cQuery := ChangeQuery(cQuery)

	If Select(cAlias) > 0
		(cAlias)->(DbCloseArea())
	EndIf

	DBUseArea(.T., "TOPCONN", TCGENQRY(NIL, NIL, cQuery), cAlias, .F., .T.)

	lExistBlq :=  !(cAlias)->(Eof())

	If Select(cAlias) > 0
		(cAlias)->(DbCloseArea())
	EndIf

Return( lExistBlq )

User Function ChkCondPag(cFilPed,cPedido, cCodCli, cLojaCli)

Local aArea := GetArea()
Local lRet	:= .F.

Default cCodCli		:= ""
Default cLojaCli	:= ""

DbSelectArea("SC5")
SC5->( DbSetOrder(1) )
If SC5->( DbSeek( cFilPed + cPedido ) )

	If Empty(cCodCli)
		cCodCli		:= SC5->C5_CLIENTE 
		cLojaCli 	:= SC5->C5_LOJACLI
	EndIf 

	DbSelectArea("SA1")
	SA1->( DbSetOrder(1) )
	SA1->( DbSeek( xFilial("SA1") + cCodCli + cLojaCli) )
	
	lRet :=  ALLTRIM( SC5->C5_CONDPAG ) == ALLTRIM( SA1->A1_COND  )

	// Adicionar a Forma de Pagto. SC5 x SA1 

EndIf 

RestArea( aArea )

Return( lRet )


/*--------------------------------------------------------------------------------------------------*
±±ºDescricao ³ Funcao para retornar no campo C6_QTDLIB o conteudo do 	   º±±
±±º          ³ campo C6_QTDVEN, mas caso nao exista saldo disponivel para  º±±
±±º          ³ o lote informado, o retorno sera = 0. Sera executado por	   º±±
±±º          ³ gatilho no campo	LOTECTL.   								   º±±
*--------------------------------------------------------------------------------------------------*/
User Function C6QtdLib()
Local aArea 	:= GetArea()
Local nRet      := 0
Local nPProd    := AScan( aHeader,{ |x| Upper(Alltrim(x[2])) == "C6_PRODUTO" })
Local nPLocal   := AScan( aHeader,{ |x| Upper(Alltrim(x[2])) == "C6_LOCAL" })
Local nPLote    := AScan( aHeader,{ |x| Upper(Alltrim(x[2])) == "C6_LOTECTL" })
Local nPQtdVen  := AScan( aHeader,{ |x| Upper(Alltrim(x[2])) == "C6_QTDVEN" })

Local cProd     := aCols[n][nPProd]
Local cLocal    := aCols[n][nPLocal]
Local cLote     := aCols[n][nPLote]
Local nQtdVen   := aCols[n][nPQtdVen]
Local nSaldoSB8 := 0
Local nQtdSB8   := 0

// Calcula o saldo do lote no sistema
SB8->(DbSetOrder(3))
If SB8->(DbSeek(xFilial("SB8") + cProd + cLocal + cLote))
	While SB8->(!EOF()) .And. xFilial("SB8") + cProd + cLocal + cLote == SB8->(B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL)
		nSaldoSB8 := SB8Saldo(,,,,,,,dDataBase)
		nQtdSB8   += nSaldoSB8
		SB8->(DbSkip())
	Enddo  	 
Endif	

// Caso tiver saldo disponivel para o lote retorna 
If nQtdVen > nQtdSB8
	MsgAlert("N�o existe saldo disponivel no lote " + cLote + " para atender este item do pedido")  
Else
	nRet := nQtdVen 
Endif

RestArea(aArea)

Return (nRet)

User Function EnvPedWMS( )

Local lIntegAKR		:= SuperGetMV("MAPWMS07A",,.T.) // Integra pedido de venda para AKR avia API.
Local cMessage	 	:= ""
Local cOperWMSBlq	:= ""
Local lBlqCred		:= .F.
Local lVldCondPag	:= .F.
Local lRet			:= .F.

	If ( lIntegAKR )

		lVldCondPag		:= U_ChkCondPag( SC5->C5_FILIAL, SC5->C5_NUM  )
		lBlqCred 		:= U_ChkBlqCred( SC5->C5_FILIAL, SC5->C5_NUM )
		cOperWMSBlq		:= SuperGetMV("MAPWMS07B",,"1|4") 

			//IATAN em 20/06/2022 - Desativado temporariamente
		//If !( AllTrim( SC5->C5_XOPEWMS )  $ cOperWMSBlq )
		//Iatan em 27/06/2022 - N�o estamos mais utilizando amarra��o de TES. Estamos simplesmente mandando a nossa opera��o
		//If !EMPTY(AllTrim( SC5->C5_XOPEWMS ))
			//IATAN em 20/06/2022 - Desativado temporariamente
			//If ( lVldCondPag )
				If ( !lBlqCred ) 

					//IATAN EM 24/10/2023 - N�O PERMITIR INTEGRAR OPERA��ES 'R', '', ....
					IF U_checkOper(SC5->C5_FILIAL, SC5->C5_NUM) == .T.

					ELSE

						lRet := U_MAPWMS07( SC5->( Recno() ), @cMessage )
					
					ENDIF

				Else 
					cMessage := "Cliente com bloqueio de cr�dito"
				EndIf 
			//Else 
			//	cMessage := "Condi��o de Pagamento divergente entre o Pedido x Cliente"
			//EndIf 
		//Else 
		//	cMessage := "A TES UTILIZADA NO PEDIDO N�O EST� VINCULADA A NENHUMA OPERA��O NO WMS "
		//EndIf 
		//Else 
		//	cMessage := "A opera��o WMS [C5_XOPEWMS] n�o permite integrar pedido - Par�metro [MAPWMS07B] "
		//EndIf 
	Else 
		cMessage := "Par�metro de integracao de pedido [MAPWMS07A] est� desativado."
	EndIf 

	RecLock("SC5",.F.)

	SC5->C5_XWMS	:= IIF(lRet,"S","N")    
	SC5->C5_XMSGWMS	:= cMessage

	SC5->( MsUnlock() )


	IF !EMPTY(ALLTRIM(cMessage)) .AND. !ISBLIND() .and. ALLTRIM(cMessage) <> "Post PEDIDO VENDA Enviado com Sucesso!"
		FWAlertError(cMessage, "INTEGRA��O COM WMS N�O EXECUTADA")
	ENDIF


Return( lRet )
