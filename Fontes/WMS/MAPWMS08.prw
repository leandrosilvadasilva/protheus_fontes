
#Include "Protheus.ch"
#Include "Colors.ch"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"
#Include "TOTVS.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#Include "CI_M001.CH"
#INCLUDE "TbiConn.ch"


 /*

{
	"liberar_itens": [
		{
			"filial": "0101",
			"pedido": "075103",
			"item": "01",
			"produto": " TS-SP-DL",
			"lote": "AAAAA",
			"quantidade_wms": 1
		},
		{
			"filial": "0101",
			"pedido": "075103",
			"item": "01",
			"produto": " TS-SP-DL",
			"lote": "BBBBB",
			"quantidade_wms": 2
		}
	]
}

*/
Class PedVendaWMS08

	Data cFilPed 			As Character
	Data cPedido 			As Character 
	Data cItemPed			As Character
	Data cProduto 			As Character
	Data cLote 				As Character
	Data nQuantidade_wms	As Numeric
	
	Data cTransportadora	As Character
	Data nPbruto 			As Numeric
	Data nPLiquido			As Numeric
	Data nQtdVolumes		As Numeric
	Data cTipoVolumes		As Character
	
	Data aParam				As Array 
		
	Data cCode 				As Character 
	Data cMessage 			As Character 
	
	Method New() CONSTRUCTOR
	Method CheckObrigat()
	Method CheckPedido()
	Method Liberar()
	
EndClass 

/*
---------------------------------------------------------------------
Metodo  	: New
Objetivo	: Inicializa as propriedades com base no JSON
----------------------------------------------------------------------
*/
Method New( oBody ) Class PedVendaWMS08

Local aPedItens	:= Nil 
Local nI 		:= 1

	Self:aParam := {}
	aPedItens 	:= oBody['liberar_itens']

	//For nI := 1 To Len( aPedItens )
	For nI := Len( aPedItens ) To 1 Step -1
		IF nI == 1
		// IATAN EM 31/07/2022 - LOG PARA GUARDAR OS JSONS RECEBIDOS
			FwMakeDir("\integracao_wms\liberacao\")
			MEMOWRITE("\integracao_wms\liberacao\"+ GetJsonCpo( aPedItens[nI],"filial") + GetJsonCpo( aPedItens[nI],	"pedido") + "__" + Year2Str(ddatabase) + Month2Str(DDATABASE) + Day2Str(DDATABASE) + '_' + REPLACE(TIME(), ':', '.') + ".json", oBody:GetJsonText("liberar_itens") )
		ENDIF

		Self:cFilPed			:= PadR( GetJsonCpo( aPedItens[nI],	"filial")	, TamSx3("C6_FILIAL")[1] ) 
		Self:cPedido 			:= PadR( GetJsonCpo( aPedItens[nI],	"pedido")	, TamSx3("C6_NUM")[1] )
		Self:cItemPed			:= PadR( GetJsonCpo( aPedItens[nI],	"item")		, TamSx3("C6_ITEM")[1] )
		Self:cProduto 			:= PadR( GetJsonCpo( aPedItens[nI],	"produto")	, TamSx3("C6_PRODUTO")[1] )
		Self:cLote 				:= PadR( GetJsonCpo( aPedItens[nI],	"lote")		, TamSx3("C6_LOTECTL")[1] )
		Self:nQuantidade_wms	:= GetJsonCpo( aPedItens[nI],	"quantidade_wms")

		Self:cTransportadora	:= PadR( GetJsonCpo( aPedItens[nI],	"transportadora")		, TamSx3("C5_TRANSP")[1] )
		Self:nPbruto			:= GetJsonCpo( aPedItens[nI],	"peso_bruto")
		Self:nPLiquido			:= GetJsonCpo( aPedItens[nI],	"peso_liquido")
		Self:nQtdVolumes		:= GetJsonCpo( aPedItens[nI],	"qtd_volumes")
		Self:cTipoVolumes		:= PadR( GetJsonCpo( aPedItens[nI],	"tipo_volumes")		, TamSx3("C5_ESPECI1")[1] )
		

		aAdd( Self:aParam, {Self:cFilPed,Self:cPedido,Self:cItemPed,Self:cProduto,Self:cLote,Self:nQuantidade_wms, Self:cTransportadora, Self:nPbruto, Self:nPLiquido, Self:nQtdVolumes, Self:cTipoVolumes} )
	Next

Return( Self )

/*
---------------------------------------------------------------------
Metodo  	: CheckObrigat
Objetivo	: Valida o preenchimento dos campos obrigatorios
----------------------------------------------------------------------
*/
Method CheckObrigat() Class PedVendaWMS08

Local nI 	:= 0
Local lRet 	:= .F. 

	// --------------------------------
	// VALIDA OS CAMPOS OBRIGATORIOS
	// --------------------------------

	For nI := 1 To Len(Self:aParam)

		If 	!Empty(Self:aParam[nI][1]) 	.And. ; // Filial Pedido
			!Empty(Self:aParam[nI][2]) 	.And. ; // Numero Pedido
			!Empty(Self:aParam[nI][3])	.And. ; // Numero do item no pedido
			!Empty(Self:aParam[nI][4])	.And. ; // Codigo Produto 
			Self:aParam[nI][6] > 0 	 			// Qtd separada no WMS
			//!Empty(Self:aParam[nI][5]) 	.And. ; // Lote do produto // NEM TODOS OS PRODUTOS TEM LOTE
				
			lRet := .T.	
		Else 
			Self:cMessage	:= "Campo(s) obrigatório não informado na lista de parametro, item: " + CValToChar(nI)
			Self:cCode 		:= "400"	
			Exit 
		EndIf 
	Next 
	
Return( lRet )

/*
---------------------------------------------------------------------
Metodo  	: CheckPedido
Objetivo	: Valida dados para liberação do pedido
----------------------------------------------------------------------
*/
Method CheckPedido() Class PedVendaWMS08

Local aArea			:= GetArea()
Local nI 			:= 0
Local lRet			:= .T. 
Local loteSaldo     := ""

	DbSelectArea("SC6")		//-- Pedido de Venda Itens 
	SC6->(DbSetOrder(1)) 	//-- C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO

	For nI := 1 To Len(Self:aParam)

		Self:cFilPed 		:= Self:aParam[nI][1]
		Self:cPedido		:= Self:aParam[nI][2]
		Self:cItemPed		:= Self:aParam[nI][3] 
		Self:cProduto		:= Self:aParam[nI][4]
		Self:cLote			:= Self:aParam[nI][5] 
		Self:nQuantidade_wms:= Self:aParam[nI][6]

		//IATAN EM 23/02/2024 - PRODUTOS COM SUFIXO "IMB" NÃO ENTRAM NA REGRA ABAIXO POIS ELES NÃO SÃO "ESTOQUE" ... SÃO "ATIVOS"
		CONOUT("ALLTRIM IMB = "+RIGHT(ALLTRIM(Self:cProduto), 3))
		IF RIGHT(ALLTRIM(Self:cProduto), 3) == "IMB"
			// NÃO EXECUTA A VALIDAÇÃO ABAIXO
			CONOUT("VALIDOU IMB")
		ELSE
			If SC6->(MsSeek(Self:cFilPed + Self:cPedido + Self:cItemPed + Self:cProduto) ) 
			
				// If !Empty( Self:cLote ) .And. Self:cLote <> AllTrim( SC6->C6_LOTECTL )
				// 	Self:cMessage	:= "Lote [ "+Self:cLote+" ] informado difere do lote do item [ "+AllTrim( SC6->C6_LOTECTL )+" ] "
				// 	Self:cCode 		:= "400"
				// 	lRet 		:= .F.		
				// EndIf 
				
				//comentado por iatan em 11/05/2023 a pedido de Eder - a exceção abaixo estava gerando erros na SD5
				//IF SC6->C6_LOCAL $ "06"
					// IATAN EM 02/12/2022 - OPME NÃO PASSA PELA VALIDAÇÃO DE LOTE
				//ELSE
					loteSaldo := existeLoteSaldo(SC6->C6_FILIAL, SC6->C6_PRODUTO, SC6->C6_LOCAL, Self:cLote , Self:nQuantidade_wms)
					IF loteSaldo $ "1-2"
						IF loteSaldo == "1"
							Self:cMessage	:= "O LOTE INFORMADO NÃO EXISTE. [ REGISTRO NAO ENCONTRADO NA TABELA SB8 ] "
							Self:cCode 		:= "400"
							lRet 			:= .F.			
							Exit 
						ENDIF
						IF loteSaldo == "2"
							Self:cMessage	:= "NAO EXISTE SALDO DISPONIVEL NO LOTE [ B8_SALDO ] "
							Self:cCode 		:= "400"
							lRet 			:= .F.			
							Exit 
						ENDIF
					EndIf
				//ENDIF
			
				
				If ( lRet .And.  Self:nQuantidade_wms > SC6->C6_QTDVEN  )
					Self:cMessage	:= "Quantidade [ "+cValToChar(Self:nQuantidade_wms)+" ]  a ser liberada deve ser menor\igual a quantidade do item [ "+cValToChar( SC6->C6_QTDVEN )+" ]  para o produto [ " + ALLTRIM(SC6->C6_PRODUTO) + " ] e item [ " + ALLTRIM(SC6->C6_ITEM) + " ]"
					Self:cCode 		:= "400"
					lRet 			:= .F.			
					Exit 
				EndIf
			Else 
				Self:cMessage	:= "O item [ "+Self:cItemPed+" ] produto [ "+AllTrim(Self:cProduto)+" ] do pedido de venda [ "+Self:cPedido+" ] da Filial [ "+Self:cFilPed+"] não foi encontrado no sistema, por favor verifique!"
				Self:cCode 		:= "400"
				lRet 			:= .F.
				Exit
			EndIf 
		ENDIF
	Next


RestArea( aArea )

Return( lRet )


Method Liberar() Class PedVendaWMS08

Local cMessage	:= ""
Local lRet 		:= .T. 
	
	If U_MAPWMS08( Self:aParam, @cMessage ) 
		Self:cCode := "200"
		lRet := .T. 
	Else
		Self:cCode := "400"
		lRet := .F.
	EndIf 
	
	Self:cMessage := cMessage
	
Return( lRet )

//------------------------------------------------------------------------------
/*/{Protheus.doc} U_MAPWMS08( aParam, @cMessage )

Rotina responsavel pela liberação do item pedido de venda
caso a regra entre o WMS AKR x ERP seja atendida.
@param 		aParam[1] -> Filial									|
			aParam[2] -> Numero Pedido							
			aParam[3] -> Item pedido 							
			aParam[4] -> Produto 								
			aParam[5] -> Lote 									
			aParam[6] -> Quantidade WMS		
			aParam[7] -> Código da Transportadora		
			aParam[8] -> Peso Bruto
			aParam[9] -> Peso Liquido
			aParam[10] -> Quantidade de Volumes
			aParam[11] -> Tipo de Volumes
@Param 		cMessage  -> Msg do processamento da rotina 			
@author		Lucas Brustolin
@since		FEV/2022
@version	12
/*/
//------------------------------------------------------------------------------
User Function MAPWMS08( aParam, cMessage )

Local aArea 		:= GetArea()
Local cFilPed 		:= ""
Local cPedido 		:= ""
Local cProduto 		:= ""
Local cLote			:= ""
Local nQtdLib 		:= 0
Local nI 			:= 0
Local aLiberar      := {}
Local aLotes		:= {}
Local lRet			:= .F. 

Local recnoSC9
Local listRecnoSC9 := ""
Local jaExiste := .F.
	
Default cMessage := ""

	DbSelectArea("SC9")
	SC9->(DbSetOrder(1)) //C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO

	//Iatan em 02/02/2023 - estorna todas as liberações
	For nI := 1 To Len(aParam)

		aLiberar	:= {}
		aLiberar 	:= aClone( aParam[nI] )

		POSICIONE("SC5", 1, aLiberar[1]+aLiberar[2], "C5_NUM")//POSICIONANDO NA SC5
		POSICIONE("SC6", 1, aLiberar[1]+aLiberar[2]+aLiberar[3]+aLiberar[4], "C6_NUM")//POSICIONANDO NA SC6

		//Inicialização de variáveis utilizadas posteriormente
		cFilPed  := SC5->C5_FILIAL
		cpedido  := SC5->C5_NUM
		cProduto := aLiberar[4]
		cLote    := aLiberar[5]
		nQtdLib  := aLiberar[6]
		xxVLSC6  := SC6->C6_PRCVEN

		If SC9->(DbSeek(cFilPed+cPedido))
			While SC9->(!Eof()) .And. SC9->(C9_FILIAL+C9_PEDIDO) == cFilPed+cPedido
				IF EMPTY(ALLTRIM(SC9->C9_NFISCAL)) // IATAN EM 25/08/2022
					a460Estorna()   
				ENDIF
				SC9->(DbSkip())                            
			EndDo 
		Endif

	Next


	For nI := 1 To Len(aParam)

		//jaExiste := .F.
		aLiberar	:= {}
		aLiberar 	:= aClone( aParam[nI] )

		//recnoSC9 := 0

		POSICIONE("SC5", 1, aLiberar[1]+aLiberar[2], "C5_NUM")//POSICIONANDO NA SC5
		POSICIONE("SC6", 1, aLiberar[1]+aLiberar[2]+aLiberar[3]+aLiberar[4], "C6_NUM")//POSICIONANDO NA SC6

		//Inicialização de variáveis utilizadas posteriormente
		cFilPed  := SC5->C5_FILIAL
		cpedido  := SC5->C5_NUM
		cProduto := aLiberar[4]
		cLote    := aLiberar[5]
		nQtdLib  := aLiberar[6]
		xxVLSC6  := SC6->C6_PRCVEN

		//IATAN EM 16/08/2022 - LIMPAR TODOS OS ITENS DA SC9 ANTES DE PROCESSAR
		/*
		IF nI == 1

			If SC9->(DbSeek(cFilPed+cPedido))
				While SC9->(!Eof()) .And. SC9->(C9_FILIAL+C9_PEDIDO) == cFilPed+cPedido
					IF EMPTY(ALLTRIM(SC9->C9_NFISCAL)) // IATAN EM 25/08/2022
						a460Estorna()   
					ENDIF
					SC9->(DbSkip())                            
				EndDo 
			Endif

		ENDIF*/


		//recnoSC9 := getRecnoSC9(aLiberar[1], aLiberar[2], aLiberar[3], aLiberar[4], aLiberar[5]) // Atenção.: Esta função deve buscar o MAX(C9_SEQUEN) só por segurança
		
		//Iatan em 24/01/2023 - Se não encontrou uma SC9 pode ser porque esta ainda não existe ( Não houve liberação ) 
		IF ( SC6->C6_QTDVEN - SC6->C6_QTDENT ) < aLiberar[6]
			cMessage += "NAO EXISTE SALDO DISPONIVEL PARA FATURAMENTO DO ITEM DO PEDIDO. Codigo do erro MAPWMS08_001 "
			RETURN .F. 
		ENDIF

		
		//IF recnoSC9 == 0
			
			// Iatan em 24/01/2023 - O código contido nesse if serve somente para criar a SC9 quando esta não existir e ainda existir saldo para ser faturado na SC6

			aAreaSB8 := SB8->(GETAREA())
			AADD(aLotes, { cLote,"","","",nQtdLib,ConvUm(cProduto,0,2,nQtdLib), ;
						   Posicione("SB8",3,xFilial("SB8")+cProduto+SC6->C6_LOCAL+cLote,"B8_DTVALID");
						   ,"","","",SC6->C6_LOCAL,0} )
			RESTAREA(aAreaSB8)

			POSICIONE("SA1", 1, XFILIAL("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI, "A1_NOME")
			POSICIONE("SE4", 1, XFILIAL("SE4")+SC5->C5_CONDPAG, "E4_DESCRI")
			POSICIONE("SB1", 1, XFILIAL("SB1")+SC6->C6_PRODUTO, "B1_DESC")
			POSICIONE("SB2", 1, CFILANT+SC6->C6_PRODUTO+SC6->C6_LOCAL, "B2_QATU")
			POSICIONE("SF4", 1, CFILANT+SC6->C6_TES, "F4_TEXTO")

			nQtdLiberada := MaLibDoFat(SC6->(Recno()),nQtdLib,.T.,.T.,.F.,.F.,.F.,.F.,NIL,NIL,aLotes,NIL,NIL,NIL)
			CONOUT("QTD LIBERADA.: " + CVALTOCHAR(nQtdLiberada) )
			CONOUT("SC9 CRIADA.: " + CVALTOCHAR(SC9->(RECNO())) )
			aLotes := {}
			SC6->(MaLiberOk({cPedido},.T.))

			IF !EMPTY(ALLTRIM(SC9->C9_BLEST))  
				cMessage += "Pedido ["+cPedido+"] da Filial ["+cFilPed+"] com bloqueio de Estoque . Codigo do erro MAPWMS08_004 " 
				RETURN .F. 
			ENDIF

		//ELSE 
		//	SC9->(DBGOTO( recnoSC9 ))
		//ENDIF

		IF EMPTY(ALLTRIM(SC9->C9_NFISCAL)) .AND. EMPTY(ALLTRIM(SC9->C9_BLCRED))  

			//a460Estorna()   

			//IATAN EM 19/07/2022 - INCLUSÃO DE DADOS DE TRANSPORTADORA E VOLUMES
			RECLOCK("SC5", .F.)

				VarInfo( "SC5->C5_ZIDLINX", SC5->C5_ZIDLINX )
				VarInfo( "SC5->C5_TRANSP", SC5->C5_TRANSP )
				VarInfo( "aParam[nI][7]", aParam[nI][7] )

				// Se for um pedido do LINX
				If NaoVazio( SC5->C5_ZIDLINX )
					If Vazio( SC5->C5_TRANSP )  
				
						SC5->C5_TRANSP  := aParam[nI][7]
					EndIf
				Else

					SC5->C5_TRANSP  := aParam[nI][7]
				EndIf
				SC5->C5_PBRUTO  := aParam[nI][8]
				SC5->C5_PESOL   := aParam[nI][9]
				SC5->C5_VOLUME1 := aParam[nI][10]
				SC5->C5_ESPECI1 := aParam[nI][11]
			SC5->(MsUnlock())

			/*
			aAreaSB8 := SB8->(GETAREA())
			AADD(aLotes, { cLote,"","","",nQtdLib,ConvUm(cProduto,0,2,nQtdLib), ;
						   Posicione("SB8",3,xFilial("SB8")+cProduto+SC6->C6_LOCAL+cLote,"B8_DTVALID");
						   ,"","","",SC6->C6_LOCAL,0} )
			RESTAREA(aAreaSB8)

			nQtdLiberada := MaLibDoFat(SC6->(Recno()),nQtdLib,.T.,.T.,.F.,.F.,.F.,.F.,NIL,NIL,aLotes,NIL,NIL,NIL)
			aLotes := {}
			SC6->(MaLiberOk({cPedido},.T.))
			*/
			IF !EMPTY(ALLTRIM(SC9->C9_BLEST))  
				cMessage += "Pedido ["+cPedido+"] da Filial ["+cFilPed+"] com bloqueio de Estoque . Codigo do erro MAPWMS08_004 " 
				RETURN .F. 
			ENDIF

			//Iatan em 26/07/2022
			IF SC9->C9_PRCVEN <> SC6->C6_PRCVEN
				RECLOCK("SC9",.F.)
					SC9->C9_PRCVEN := xxVLSC6 //SC6->C6_PRCVEN
				SC9->(MsUnlock())
			ENDIF

			RECLOCK("SC9", .F.)
				SC9->C9_BLCRED := ""
			SC9->(MSUNLOCK())

			If ( nQtdLiberada == nQtdLib )
				cMessage += "O pedido de venda ["+cPedido+"] item ["+SC6->C6_ITEM+"] da Filial ["+cFilPed+"] liberado com sucesso. Quantidade liberada: " + cValToChar(nQtdLib)
			ElseIf nQtdLiberada == 0 
				cMessage += "Não foi possível liberar quantidade ["+cValToChar(nQtdLib)+"] para o pedido de venda ["+cPedido+"] da Filial ["+cFilPed+"]. Codigo do erro MAPWMS08_002" 
				RETURN .F. 
			EndIf 
			
			lRet := .T.

			listRecnoSC9 := listRecnoSC9 + "-" + ALLTRIM(STR( SC9->(RECNO()) ))

		ELSE
			IF !EMPTY(ALLTRIM(SC9->C9_BLCRED)) .OR. !EMPTY(ALLTRIM(SC9->C9_BLEST))
				cMessage += "Pedido ["+cPedido+"] da Filial ["+cFilPed+"] com bloqueio de Credito . Codigo do erro MAPWMS08_003 " 
				RETURN .F. 
			ENDIF
		ENDIF

	Next

	RestArea( aArea )


	U_xFaturar(cFilPed, cPedido, listRecnoSC9)




Return .T.


/*
---------------------------------------------------------------------
Programa   : GetJsonCpo
Objetivo   : Retornar uma Tag do Json
ParÃ¢metros : oObj		- Objeto Json
			 cTag 	- Tag da Informação a ser obtida
Retorno    : xValue - Informação a ser gravada no campo
Autor      : Lucas Brustolin
Data/Hora  : FEV/2022
Obs.       :
----------------------------------------------------------------------
*/
Static Function GetJsonCpo(oObj,cTag)
Local xRet
Local xValue
Local cType

If cTag == "quantidade_wms" .or. cTag == "peso_bruto" .or. cTag == "peso_liquido" .or. cTag == "qtd_volumes"
	If oObj:GetJsonValue(cTag, @xValue, @cType)
		xRet := xValue
	Else 
		xRet :=  0
	EndIf 
Else 
	If oObj:GetJsonValue(cTag, @xValue, @cType) .And. !Empty(xValue) 
		xRet := DecodeUTF8(xValue)
	Else	
		xRet := " "
	EndIf
EndIf 

Return( xRet )



/*
	Iatan em 20/06/2022
*/
USER FUNCTION xFaturar(filial, pedido, listRecnoSC9)

//Iatan em 17/06/2022
Local filialPedido := filial
Local numeroPedido := pedido
Local lBlqCred   := .T.
Local nSaldoSB8  := 0
Local nQtdVenSC6 := 0
Local aAreaSC6   := SC6->(GETAREA())
Local aAreaSC9   := SC9->(GETAREA())
Local aAreaSB8   := SB8->(GETAREA())
LOCAL aAreaSC5   := SC5->(GETAREA())
LOCAL aAreaSE4   := SE4->(GETAREA())
LOCAL aAreaSB1   := SB1->(GETAREA())
LOCAL aAreaSB2   := SB2->(GETAREA())
LOCAL aAreaSF4   := SF4->(GETAREA())
LOCAL aAreaSF2   := SF2->(GETAREA())

Local alotes := {}
Local APVLNFS := {}
Local CNOTA := ''
Local CCHAVE := ''
Local recnoSF2
Local recnoSF3

// CONFORME REUNIÃO COM A MA NA DATA DE HOJE ( 05/07/2022 )
// SR. EDERSON INFORMOU QUE AS SÉRIES DAS NOTAS SEGUEM A SEGUINTE REGRA.:
// SERIE = NSM --> PEDIDOS COM OPERAÇÃO = 19
// SERIE = 6   --> PEDIDOS COM OPERAÇÃO = 14, 15 ou 21 (OPME)
// SERIE = 4   --> PEDIDOS COM OPERAÇÃO DIFERENTE DAS ACIMA ( REVENDA )
Local serie := ''


	//Iatan em 17/06/2022 - Faturamento automático de pedidos com saldo em estoque

		//Como a liberação de crédito ocorre por item, devo verificar se todos os ítens foram liberados.:
		lBlqCred 		:= U_ChkBlqCred( filialPedido, numeroPedido )
		IF lBlqCred == .T.
			RETURN
		ENDIF

		DbSelectArea("SC6")
		SC6->(DbSetOrder(1))
		SC6->(DbSeek(filialPedido+numeroPedido))

		//Iatan em 12/07/2022
		//Retorno da Série alterado para a user function U_getSerie(filial, operacao)
		serie := U_getSerie(filial, ALLTRIM(SC6->C6_OPER) )
		/*
		IF EMPTY(ALLTRIM((SC6->C6_OPER)))
			serie := "4"  // ATRIBUINDO SERIE 4 PADRÃO CASO A OPERAÇÃO NÃO ESTEJA PREENCHIDA
		ELSEIF ALLTRIM((SC6->C6_OPER)) $ "19"
			serie := "NSM"
		ELSEIF ALLTRIM((SC6->C6_OPER)) $ "14-15-21"
			serie := "6"
		ELSE
			serie := "4"
		ENDIF
		*/

		/*
		While SC6->(!Eof()) .And. SC6->C6_FILIAL + SC6->C6_NUM == filialPedido+numeroPedido

			// VERIFICA SE TODOS OS ITENS DO PEDIDO POSSUEM ESTOQUE NO LOTE EM QUESTÃO
			DbSelectArea("SB8")
			SB8->(DbSetOrder(3))
			If SB8->(DbSeek( SC6->C6_FILIAL + SC6->C6_PRODUTO + SC6->C6_LOCAL + SC6->C6_LOTECTL))
					nSaldoSB8 := SB8Saldo(,,,,,,,dDataBase)
					//TESTO ITEM A ITEM AFIM DE GARANTIR QUE TODOS OS ITENS TENHAM SALDOS POR LOTE INDIVIDUALMENTE
					IF nSaldoSB8 < SC6->C6_QTDVEN
						RESTAREA(aAreaSC6)
						RESTAREA(aAreaSB8)
						RETURN
					ENDIF
			Endif	
			SC6->(DbSkip())
		EndDo*/
		RESTAREA(aAreaSC6)
		RESTAREA(aAreaSB8)
		

		//SE EXISTE SALDO EM TODOS OS ITENS, EFETUAR SUAS DEVIDAS LIBERAÇÕES ( ESTOQUE )
		//***********
		//NÃO PRECISO FAZER A LIBERAÇÃO NOVAMENTE QUANDO A CHAMADA VIER 
		//DO FONTE MAPWMS08 PORQUE ESTE JÁ FEZ AS DEVIDAS LIBERAÇÕES
		/*IF !IsInCallStack("U_MTA450I")
			DbSelectArea("SC6")
			SC6->(DbSetOrder(1))
			SC6->(DbSeek(filialPedido+numeroPedido))
			While SC6->(!Eof()) .And. SC6->C6_FILIAL + SC6->C6_NUM == filialPedido+numeroPedido

				DbSelectArea("SC9")
				SC9->(DbSetOrder(2)) //C9_FILIAL+C9_CLIENTE+C9_LOJA+C9_PEDIDO+C9_ITEM
				SC9->(DbSeek( SC6->C6_FILIAL + SC6->C6_CLI + SC6->C6_LOJA + SC6->C6_NUM + SC6->C6_ITEM ))
				a460Estorna()
				aLotes := {}
				aLotes := {{ SC9->C9_LOTECTL,"","","",SC6->C6_QTDVEN,ConvUm(SC6->C6_PRODUTO,0,2,SC6->C6_QTDVEN),Ctod(""),"","","",SC6->C6_LOCAL,0}}				
				MaLibDoFat(SC6->(Recno()),SC6->C6_QTDVEN,.T.,.T.,.T.,.T.,.T.,.T.,NIL,NIL,aLotes,NIL,NIL,NIL)
				//Atualiza o Flag do Pedido de Venda                                                          
				SC6->(MaLiberOk({SC6->C6_NUM},.F.))

				SC6->(DbSkip())
			EndDo
			RESTAREA(aAreaSC6)
			RESTAREA(aAreaSC9)
		ENDIF
		*/
		// FATURA O PEDIDO QUE JÁ NÃO POSSUI MAIS BLOQUEIO DE CRÉDITO OU DE ESTOQUE
		// POSICIONA NO PEDIDO
		DbSelectArea("SC5")
		SC5->(DbSetOrder(1))
		SC5->(DbSeek( filialPedido + numeroPedido ))

		APVLNFS := {}

		DBSELECTAREA("SC9")
		SC9->(DBSETORDER(1))
		SC9->(DBSEEK( filialPedido + numeroPedido )) // PEDIDO DE VENDA LIBERADO

		DBSELECTAREA("SC6")
		SC6->(DBSETORDER(1))
		SC6->(DBSEEK(filialPedido + numeroPedido ))

		DBSELECTAREA("SE4")
		SE4->(DBSETORDER(1))
		SE4->(DBSEEK(XFILIAL("SE4") + SC5->C5_CONDPAG)) // CONDIÇÃO DE PAGAMENTO

		DBSELECTAREA("SB1")
		SB1->(DBSETORDER(1))
		SB1->(DBSEEK(XFILIAL("SB1") + SC9->C9_PRODUTO)) // PRODUTO

		DBSELECTAREA("SB2")
		SB2->(DBSETORDER(1))
		SB2->(DBSEEK(XFILIAL("SB2") + SC9->C9_PRODUTO + SC9->C9_LOCAL )) // SALDO DO PRODUTO

		DBSELECTAREA("SF4")
		SF4->(DBSETORDER(1))
		SF4->(DBSEEK(XFILIAL("SF4") + SC6->C6_TES)) // TES DO PRODUTO
		NNUMITEM := GETMV("MV_NUMITEN")
		ncount :=0
		//IATAN EM 15/12/2022 A PEDIDO DO LEONOR - PARA CADA NOTA GERADA O SISTEMA ESTÁ GERANDO UM GRUPO DE 5.000 REGISTROS NA SD9
		//É necessário carregar o grupo de perguntas MT460A, se não será executado com os valores default.
    	Pergunte("MT460A",.F.)
		while !SC9->( EOF() ) .AND. SC9->C9_FILIAL + SC9->C9_PEDIDO == filialPedido + numeroPedido 
			
			IF ALLTRIM(STR(SC9->(RECNO()))) $ listRecnoSC9 .AND. EMPTY(ALLTRIM(SC9->C9_BLEST)) .AND. EMPTY(ALLTRIM(SC9->C9_BLCRED)) .AND. EMPTY(ALLTRIM(SC9->C9_NFISCAL))
			
				ncount++

				SC6->(DBSEEK(XFILIAL("SC6") + SC9->C9_PEDIDO + SC9->C9_ITEM+SC9->C9_PRODUTO)) // ITEM DO PEDIDO
				SB1->(DBSEEK(XFILIAL("SB1") + SC9->C9_PRODUTO)) // PRODUTO
				SB2->(DBSEEK(XFILIAL("SB2") + SC9->C9_PRODUTO + SC9->C9_LOCAL)) // SALDO DO PRODUTO
				SF4->(DBSEEK(XFILIAL("SF4") + SC6->C6_TES)) // TES DO PRODUTO

				CONOUT("XFATURAR (SC6).: " + XFILIAL("SC6") + SC9->C9_PEDIDO + SC9->C9_ITEM+SC9->C9_PRODUTO)
				CONOUT("XFATURAR (SB1).: " + XFILIAL("SB1") + SC9->C9_PRODUTO)
				CONOUT("XFATURAR (SB2).: " + XFILIAL("SB2") + SC9->C9_PRODUTO + SC9->C9_LOCAL)
				CONOUT("XFATURAR (SF4).: " + XFILIAL("SF4") + SC6->C6_TES)
				CONOUT("XFATURAR (RECNO SC9) .: " + CVALTOCHAR(SC9->(RECNO())))
				CONOUT("XFATURAR (RECNO SC5) .: " + CVALTOCHAR(SC5->(RECNO())))
				CONOUT("XFATURAR (RECNO SC6) .: " + CVALTOCHAR(SC6->(RECNO())))
				CONOUT("XFATURAR (RECNO SE4) .: " + CVALTOCHAR(SE4->(RECNO())))
				CONOUT("XFATURAR (RECNO SB1) .: " + CVALTOCHAR(SB1->(RECNO())))
				CONOUT("XFATURAR (RECNO SB2) .: " + CVALTOCHAR(SB2->(RECNO())))
				CONOUT("XFATURAR (RECNO SF4) .: " + CVALTOCHAR(SF4->(RECNO())))

					AADD( APVLNFS , { SC9->C9_PEDIDO,; // PEDIDO
						SC9->C9_ITEM      ,; // ITEM
						SC9->C9_SEQUEN    ,; // SEQUêNCIA
						SC9->C9_QTDLIB    ,; // QUANTIDADE LIBERADA
						SC9->C9_PRCVEN    ,; // PREçO DE VENDA
						SC9->C9_PRODUTO   ,; // CóDIGO DO PRODUTO
						.F.,;
						SC9->(RECNO())    ,;
						SC5->(RECNO())    ,;
						SC6->(RECNO())    ,;
						SE4->(RECNO())    ,;
						SB1->(RECNO())    ,;
						SB2->(RECNO())    ,;
						SF4->(RECNO())    })			
				
				//QUANDO CHEGAR A 150 ITENS FATURAR E PROSSEGUIR CASO TENHA MAIS ITENS.
				IF NCOUNT == NNUMITEM
					SetFunName("MATA461")
					// CONFORME REUNIÃO COM A MA NA DATA DE HOJE ( 05/07/2022 )
					// SR. EDERSON INFORMOU QUE AS SÉRIES DAS NOTAS SEGUEM A SEGUINTE REGRA.:
					// SERIE = NSM --> PEDIDOS COM OPERAÇÃO = 19
					// SERIE = 6   --> PEDIDOS COM OPERAÇÃO = 14, 15 ou 21 (OPME)
					// SERIE = 4   --> PEDIDOS COM OPERAÇÃO DIFERENTE DAS ACIMA ( REVENDA )
					//CNOTA  := MAPVLNFS( APVLNFS , "4"  )
					CNOTA  := MAPVLNFS( APVLNFS , serie  )
					APVLNFS :={}
					NCOUNT := 0
				ENDIF
			ENDIF

			SC9->(DBSKIP())

		enddo

		IF LEN(APVLNFS)>0 //VALIDAÇÃO PARA QUANDO NF TIVER EXATOS 150 ITENS E ARRAY APVLNFS = {}
			//CNOTA := MAPVLNFS( APVLNFS , "4" )
			SetFunName("MATA461")
			CNOTA := MAPVLNFS( APVLNFS , serie )
		ENDIF

//COMENTADO POR IATAN EM 26/07/2022 POIS ESTE TRECHO FOI TRANSFORMADO EM UM JOB
/*
		IF !EMPTY(ALLTRIM(CNOTA))
			
			//Forço o envio da nota fiscal gerada
			recnoSF2 := SF2->(RECNO())
			U_MAPWMS11( recnoSF2, 3 )
			//GRAVO O NÚMERO DA CHAVE PARA GERAR O PDF E O XML ABAIXO PARA QUE O WMS POSSA BUSCAR
			sleep(20000)
			CCHAVE := SF2->F2_CHVNFE
			recnoSF3 := SF3->(RECNO())

		ENDIF
*/


		//*********************************
		//COLOCAR C5_LIBEROK = 'S'

		RESTAREA(aAreaSC6)
		RESTAREA(aAreaSC5)
		RESTAREA(aAreaSC9)
		RESTAREA(aAreaSB1)
		RESTAREA(aAreaSF4)
		RESTAREA(aAreaSB2)
		RESTAREA(aAreaSE4)
		RESTAREA(aAreaSF2)

//COMENTADO POR IATAN EM 26/07/2022 POIS ESTE TRECHO FOI TRANSFORMADO EM UM JOB
/*
		//Iatan em 30/06/2022
		//ENVIO DO PDF E DO XML DA NOTA PARA O WMS 
		IF serie == 'NSM'
			//SERIE NSM NÃO É TRANSMITIDA EM NENHUMA FILIAL
		ELSE
			U_INICDANFE(CFILANT, recnoSF2, recnoSF3, CCHAVE, CNOTA, serie)
		ENDIF
*/
Return



/*/{Protheus.doc} zGerDanfe
Função que gera a danfe e o xml de uma nota em uma pasta passada por parâmetro
@author Atilio
@since 10/02/2019
@version 1.0
@param cNota, characters, Nota que será buscada
@param cSerie, characters, Série da Nota
@param cPasta, characters, Pasta que terá o XML e o PDF salvos
@type function
@example u_zGerDanfe("000123ABC", "1", "C:\TOTVS\NF")
@obs Para o correto funcionamento dessa rotina, é necessário:
    1. Ter baixado e compilado o rdmake danfeii.prw
    2. Ter baixado e compilado o zSpedXML.prw - https://terminaldeinformacao.com/2017/12/05/funcao-retorna-xml-de-uma-nota-em-advpl/
/*/
User Function wGerDanfe(cChave, cNota, cSerie, cPasta,cPedido,cTipo,cEmail,cCliente,cLoja,cEnv,cPvFil,cPv)
    Local aArea     := GetArea()
    Local cIdent    := ""
    Local oDanfe    := Nil
    Local lEnd      := .F.
    Local nTamNota  := TamSX3('F2_DOC')[1]
    Local nTamSerie := TamSX3('F2_SERIE')[1]
    Private PixelX
    Private PixelY
    Private nConsNeg
    Private nConsTex
    Private oRetNF
    Private nColAux
     
    //Se existir nota
    If ! Empty(cNota)
        //Pega o IDENT da empresa
        cIdent := retEntidade()
         
        //Se o último caracter da pasta não for barra, será barra para integridade
        If SubStr(cPasta, Len(cPasta), 1) != "\"
            cPasta += "\"
        EndIf
         
        //Gera o XML da Nota
		//IATAN EM 26/08/2022 - RETITADA A GERACAO DO XML A PEDIDO DO TIAGO
        //u_wSpedXML(cNota, cSerie, "\pdf_wms\xml\" + cChave + ".xml", .F.)
		//IATAN EM 09/02/2023
		geraXML(cChave, "\pdf_wms\xml\" + cChave + ".xml")
        CONOUT("******GEROU XML******"+cChave)
        	 
        //Define as perguntas da DANFE
        Pergunte("NFSIGW",.F.)
        MV_PAR01 := PadR(cNota,  nTamNota)     //Nota Inicial
        MV_PAR02 := PadR(cNota,  nTamNota)     //Nota Final
        MV_PAR03 := PadR(cSerie, nTamSerie)    //Série da Nota
        MV_PAR04 := cTipo                          //NF de Saida
        MV_PAR05 := 1                          //Frente e Verso = Sim
        MV_PAR06 := 2                          //DANFE simplificado = Nao
         
        oDanfe := FWMSPrinter():New(cChave, IMP_PDF, .F., "\pdf_wms\pdf\", .T., .F., , , .T., .T., , .F.)
         
        //Propriedades da DANFE
        oDanfe:SetResolution(78)
        oDanfe:SetPortrait()
        oDanfe:SetPaperSize(DMPAPER_A4)
        oDanfe:SetMargin(60, 60, 60, 60)
         
        //Força a impressão em PDF
        oDanfe:nDevice  := 6
        oDanfe:cPathPDF := "\pdf_wms\pdf\"
        oDanfe:lServer  := .F.
        oDanfe:lViewPDF := .F.
         
        //Variáveis obrigatórias da DANFE (pode colocar outras abaixo)
        PixelX    := oDanfe:nLogPixelX()
        PixelY    := oDanfe:nLogPixelY()
        nConsNeg  := 0.4
        nConsTex  := 0.5
        oRetNF    := Nil
        nColAux   := 0
        CONOUT("CHAMADA DANFEII") 
    	U_DANFEProc(@oDanfe, @lEnd, cIDEnt, Nil, Nil, .F. )	
		
        oDanfe:Print()

		U_CI_A050( @oDanfe )

		CONOUT("******GEROU PDF******"+cChave)
    EndIf

    RestArea(aArea)
Return


/*/{Protheus.doc} zSpedXML
Função que gera o arquivo xml da nota (normal ou cancelada) através do documento e da série disponibilizados
@author Atilio
@since 25/07/2017
@version 1.0
@param cDocumento, characters, Código do documento (F2_DOC)
@param cSerie, characters, Série do documento (F2_SERIE)
@param cArqXML, characters, Caminho do arquivo que será gerado (por exemplo, C:\TOTVS\arquivo.xml)
@param lMostra, logical, Se será mostrado mensagens com os dados (erros ou a mensagem com o xml na tela)
@type function
@example Segue exemplo abaixo
    u_zSpedXML("000000001", "1", "C:\TOTVS\arquivo1.xml", .F.) //Não mostra mensagem com o XML
     
    u_zSpedXML("000000001", "1", "C:\TOTVS\arquivo2.xml", .T.) //Mostra mensagem com o XML
/*/
 
Static Function retEntidade()

local cIdEnt := ""
Local temp := FWLoadSM0()
Local cnpj := temp[aScan(temp, {|x| AllTrim(Upper(x[2])) == CFILANT})][18]

    cQry := " SELECT * FROM SPED001 WHERE ENTATIV = 'S' AND CNPJ = '" + cnpj + "' "
    contador := 1


	TCQuery cQry New Alias "QRY_SM0"
	
	QRY_SM0->(DbGoTop())

	While ! QRY_SM0->(Eof())

        cIdEnt := QRY_SM0->ID_ENT

		QRY_SM0->(DbSkip())
	EndDo

	QRY_SM0->(DbCloseArea())


Return(cIdEnt)


User Function wSpedXML(cDocumento, cSerie, cArqXML, lMostra)
    Local aArea        := GetArea()
    Local cURLTss      := PadR(GetNewPar("MV_SPEDURL","http://"),250)  
    Local oWebServ
    Local cIdEnt       := retEntidade()//&("StaticCall(SPEDNFE, GetIdEnt)")
    Local cTextoXML    := ""
    //Default cDocumento := ""
    //Default cSerie     := ""
    //Default cArqXML    := GetTempPath()+"arquivo_"+cSerie+cDocumento+".xml"
    //Default lMostra    := .F.
     
    //Se tiver documento
    If !Empty(cDocumento)
        cDocumento := PadR(cDocumento, TamSX3('F2_DOC')[1])
        cSerie     := PadR(cSerie,     TamSX3('F2_SERIE')[1])
         
        //Instancia a conexão com o WebService do TSS    
        oWebServ:= WSNFeSBRA():New()
        oWebServ:cUSERTOKEN        := "TOTVS"
        oWebServ:cID_ENT           := cIdEnt
        oWebServ:oWSNFEID          := NFESBRA_NFES2():New()
        oWebServ:oWSNFEID:oWSNotas := NFESBRA_ARRAYOFNFESID2():New()
        aAdd(oWebServ:oWSNFEID:oWSNotas:oWSNFESID2,NFESBRA_NFESID2():New())
        aTail(oWebServ:oWSNFEID:oWSNotas:oWSNFESID2):cID := (cSerie+cDocumento)
        oWebServ:nDIASPARAEXCLUSAO := 0
        oWebServ:_URL              := AllTrim(cURLTss)+"/NFeSBRA.apw"   
         
        //Se tiver notas
        If oWebServ:RetornaNotas()
         
            //Se tiver dados
            If Len(oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3) > 0
             
                //Se tiver sido cancelada
                If oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFECANCELADA != Nil
                    cTextoXML := oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFECANCELADA:cXML
                     
                //Senão, pega o xml normal
                Else
                    cTextoXML := oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFE:cXML
                EndIf
                 
                //Gera o arquivo
                MemoWrite(cArqXML, cTextoXML)
                 
                //Se for para mostrar, será mostrado um aviso com o conteúdo
                If lMostra
                    //Aviso("zSpedXML", cTextoXML, {"Ok"}, 3)
                EndIf
                 
            //Caso não encontre as notas, mostra mensagem
            Else
                ConOut("zSpedXML > Verificar parâmetros, documento e série não encontrados ("+cDocumento+"/"+cSerie+")...")
                 
                If lMostra
                    //Aviso("zSpedXML", "Verificar parâmetros, documento e série não encontrados ("+cDocumento+"/"+cSerie+")...", {"Ok"}, 3)
                EndIf
            EndIf
         
        //Senão, houve erros na classe
        Else
            ConOut("zSpedXML > "+IIf(Empty(GetWscError(3)), GetWscError(1), GetWscError(3))+"...")
             
            If lMostra
                //Aviso("zSpedXML", IIf(Empty(GetWscError(3)), GetWscError(1), GetWscError(3)), {"Ok"}, 3)
            EndIf
        EndIf
    EndIf
    RestArea(aArea)
Return


Static Function existeLoteSaldo(filial, produto, armazem, lote, quantidade)

Local cQry
Local retorno := "1" // assumo que por padrão o lote não existe
//LEGENDAS DO RETORNO.:
// 1 = LOTE NÃO ENCONTRADO
// 2 = NÃO EXISTE SALDO NO LOTE
// QUALQUER OUTRO RETORNO DIFERENTE DOS ACIMA = LOTE ENCONTRADO E COM SALDO

    cQry := " SELECT * FROM SB8010 
	cQry += " WHERE D_E_L_E_T_ <> '*' AND B8_FILIAL = '" + filial + "' AND B8_PRODUTO = '" + produto + "' "
	cQry += "       AND B8_LOCAL = '" + armazem + "' AND B8_LOTECTL = '" + lote + "' "

	TCQuery cQry New Alias "QRY_SB8"

	CONOUT("cQry.:")
	CONOUT(cQry)
	
	QRY_SB8->(DbGoTop())

	While ! QRY_SB8->(Eof())

        IF quantidade > QRY_SB8->B8_SALDO
			retorno := "2"
		ELSE
			retorno := "9"
		ENDIF

		QRY_SB8->(DbSkip())
	EndDo

	QRY_SB8->(DbCloseArea())


Return retorno


/*
	IATAN EM 24/01/2023
	ROTINA CRIADA PARA RETORNAR O RECNO DA SC9
*/
Static Function getRecnoSC9(filial, pedido, itemPedido, produto, lote) // Atenção.: Esta função deve buscar o MAX(C9_SEQUEN) só por segurança

Local cQry
Local retorno := 0

    cQry := " SELECT * FROM SC9010 "
	cQry += " WHERE D_E_L_E_T_ <> '*' AND C9_FILIAL = '" + filial + "' AND C9_PEDIDO = '" + pedido + "' "
	cQry += "       AND C9_PRODUTO = '" + produto + "' AND C9_ITEM = '" + itemPedido + "' "
	cQry +="        AND C9_LOTECTL = '" +  lote + "' "
	cQry +="        AND C9_NFISCAL = '' "

	CONOUT("cQry - getRecnoSC9 .:")
	CONOUT(cQry)

	TCQuery cQry New Alias "QRY_SC9"

	QRY_SC9->(DbGoTop())

	While ! QRY_SC9->(Eof())

		// NÃO ESTOU DANDO UM MAX(C9_SEQUEN) MAS COMO A ROTINA ESTÁ EM LOOP ESTA SEMPRE RETORNARA O ULTIMO REGISTRO
        retorno := QRY_SC9->R_E_C_N_O_

		QRY_SC9->(DbSkip())
	EndDo

	QRY_SC9->(DbCloseArea())


Return retorno



Static Function geraXML(chave, cArqXML)

	Local cQry
	Local cTextoXML


	BeginSql alias 'QRYXML'

		%noparser% 
		
		SELECT  DOC_CHV, DOC_ID, DOC_SERIE, ID_ENT, DATE_NFE, STATUS, AMBIENTE,
			ISNULL(CAST(CAST(XML_ERP AS VARBINARY(MAX)) AS VARCHAR(MAX)),'') AS XML_ERP,
			ISNULL(CAST(CAST(XML_SIG AS VARBINARY(MAX)) AS VARCHAR(MAX)),'') AS XML_SIG,
			(SELECT (ISNULL(CAST(CAST(XML_PROT AS VARBINARY(MAX)) AS VARCHAR(MAX)),'')) as 'XML_PROT' FROM SPED054 WHERE NFE_CHV =  %exp:chave%  ) AS XML_PROT
		FROM SPED050 
		WHERE 1=1
		AND SPED050.DOC_CHV = %exp:chave%     

	EndSql


	While ! QRYXML->(EoF())

			cTextoXML := '<?xml version="1.0" encoding="UTF-8"?><nfeProc xmlns="http://www.portalfiscal.inf.br/nfe" versao="4.00">'
			cTextoXML += QRYXML->XML_SIG         
			cTextoXML += QRYXML->XML_PROT
			cTextoXML +=  "</nfeProc>"
			QRYXML->(DbSkip())
			
	EndDo
	QRYXML->(DbCloseArea())

	//Gera o arquivo
    MemoWrite(cArqXML, cTextoXML)

return
