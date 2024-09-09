#include "Protheus.ch"
#include "tbiconn.ch"
#include "topconn.ch"
#include "restful.ch"
#include "FWMVCDEF.ch"
#Include "TOTVS.ch" 
#INCLUDE "rwmake.ch"

/*--------------------------------------------------------------------------------------------------*
| Func:  MAPWMS13.prw                                                     							|
| Autor: Lucas Brustolin                                              								|
| Data:  Abr/2022                                                   								|
| Desc:  Rotina para inclusao de pedido de venda 					        	                    |   
|		 Endpoint: http://192.168.11.63:43001/rest/PEDIDOVENDA										|
|    																								|
|    Formato de JSON esperado:
|	
|	{
|		"c5_filial": "0101",
|		"c5_tipo": "N",
|		"c5_emissao": "",
|		"c5_cliente": "0033220003",
|		"c5_lojacli": "",
|		"c5_tipocli": "F",
|		"c5_condpag": "010",
|		"c5_tabela": "",
|		"c5_xopewms": "",
|		"c5_xclient": "",
|		"c5_xlojcli": "",
|		"c5_pacient": "",
|		"c5_codmed": "000001",
|		"c5_codconv": "000001",
		"c5_xpedbkl":"011075",
		"c5_oper"   :"01",
		"c5_pedwms"   :"123456",
|		"itens": [
|			{
|				"c6_item": "001",
|				"c6_produto": " ts-sp-dl           ",
|				"c6_qtdven": 1,
|				"c6_qtdlib": 1,
|				"c6_prcven": 100,
|				"c6_prunit": 100,
|				"c6_valor": 100,
|				"c6_tes": "563", // campo eliminado pois estamos utilizando a operação e não mais a tes
|				"c6_xdocwms":"123456789",
|				"c6_xserwms":"123",
|				"c6_xitewms":"001",
			    "c6_local":"01"
|			}
|		]
|	}
|	
|	
|                                                                            						|
*--------------------------------------------------------------------------------------------------*/
/*	Alteracoes Realizadas desde a Estruturacao Inicial

	Data                        Programador                                                    Motivo
  06/03/2023                   Davidson Carvalho					#7992 - Erro natureza no Protheus Ajuste Natureza Cliente Retorno.
*/

WSRESTFUL PEDIDOVENDA DESCRIPTION "Inclusao de Nota Pedido de Venda"

WSMETHOD POST DESCRIPTION "Inclusão de Pedido de Venda" WSSYNTAX "/PEDIDOVENDA" path "/PEDIDOVENDA"

END WSRESTFUL

/*------------------------------------------------------------------
	METODO RESPONSAVEL PELA INCLUSAO DO PEDIDO DE VENDA
------------------------------------------------------------------*/ 
WSMETHOD POST WSSERVICE PEDIDOVENDA

Local aArea 		:= GetArea()
Local aCab			:= {}
Local aItens 		:= {}
Local aLinha 		:= {}
Local aLogErr		:= {}
Local oJson        	:= Nil 
LOCAL cCatch       	:= Nil 
Local oItens		:= Nil
Local cLogMsg		:= "" 
Local cJson 		:= ""
Local cFilPed 		:= ""
Local cProduto 		:= ""
Local cCondPad		:= ""
Local cItem			:= ""
Local cCliente 		:= ""
Local cLojaCli		:= ""
Local cCodMed 		:= ""
Local cCodConv 		:= ""
Local cPaciente 	:= ""
Local cCodLote		:= ""
Local cDocWMS		:= ""
Local cSerWMS		:= ""
Local cITEWMS		:= ""
Local cPedBkLog 	:= ""
Local dEmissao 		:= CTOD("")
Local cTesVen		:= ""
Local nTamProd		:= 0
Local nTamItem 		:= 0
Local nTamDoc		:= 0
Local nTamSer		:= 0
Local nTamITE		:= 0
Local n1 			:= 0
Local lRet          := .T.
Local arrOrig       := {}
Local aAuto         := {}
Local nX
Local cVend         := ""

Local qtdVol        := 0
Local pesoLiq       := 0
Local pesoBrt       := 0
Local obsPED        := ""
Local obsNF         := ""
Local operacao      := ""
Local filialATUAL   := CFILANT

Local cDocumen      := ""

Local recnoSD2


Private lMsErroAuto := .F.
Private lAutoErrNoFile := .T.
Private retSC6        := {}
Private cTabPrc		:= ""

Private LBLOQUEADOS := .F.


Self:SetContentType("application/json")
cJson := Self:GetContent() 

oJson	:= JsonObject():New()
cCatch  := oJson:FromJSON(cJson)

If cCatch == Nil   
	

	cFilPed		:= PadR( oJson["c5_filial"]	, TamSx3("c5_filial")[1] )
	cFilPed		:= IIF( !Empty(cFilPed),cFilPed, xFilial("SC5") )

	CONOUT("cFilPed.:" + cFilPed)
	CONOUT("CFILANT.:" + CFILANT)

	IF cFilPed == '0101' // IATAN EM 23/02/2023
		CFILANT := '0101'
	ELSEIF cFilPed == '0102'
		CFILANT := '0102'
	ELSEIF cFilPed == '0103'
		CFILANT := '0103'
	ELSEIF cFilPed == '0104'
		CFILANT := '0104'
	ELSEIF cFilPed == '0105'
		CFILANT := '0105'
	ELSEIF cFilPed == '0106'
		CFILANT := '0106'
	ELSEIF cFilPed == '0107'
		CFILANT := '0107'			
	ELSEIF cFilPed == '5001'
		CFILANT := '5001'
	ENDIF


	// IATAN EM 19/12/2022
	// ELIMINAÇÃO DE RESIDUO
	IF !EMPTY(AllTrim(oJson["c5_residuo"]))

		// ELIMINA RESIDUO DOS ITENS DO VETOR

		oItens := oJson:GetJsonObject('itens')
			
		For n1 := 1 to Len(oItens)
			
			nTamProd 	:= TamSx3("C6_PRODUTO")[1]
			nTamItem	:= TamSX3("C6_ITEM")[1]

			cPedido  := AllTrim(oJson["c5_pedido"])
			cItem	 := StrZero(VAL(ALLTRIM(oItens[n1]["c6_item"])), nTamItem)
			cProduto := PadR( oItens[n1]["c6_produto"]		, nTamProd )
			POSICIONE("SC5", 1, xFilial("SC5") + cPedido , "C5_NUM")
			POSICIONE("SC6", 1, xFilial("SC6") + cPedido + cItem + cProduto, "C6_PRODUTO")

			IF ALLTRIM(SC5->C5_NUM) <> ALLTRIM(cPedido)
				// NÃO CONSEGUIU SE POSICIONER NA SC5
				oJsonResponse				:= JsonObject():New()
				oJsonResponse['message'] 	:= "NAO CONSEGUIU ENCONTRAR O PEDIDO " + cPedido + " [ Erro de Posicionamento na SC5 ]"
				oJsonResponse['pedido']		:= {}
				oJsonResponse['code'] 		:= 400
				Self:SetResponse(oJsonResponse)	
				RETURN .F.
			ENDIF
			IF ALLTRIM(SC6->C6_NUM) <> ALLTRIM(cPedido) .OR. ALLTRIM(SC6->C6_ITEM) <> ALLTRIM(cItem) .OR. ALLTRIM(SC6->C6_PRODUTO) <> ALLTRIM(cProduto)
				// NÃO CONSEGUIU SE POSICIONER NA SC6
				oJsonResponse				:= JsonObject():New()
				oJsonResponse['message'] 	:= "NAO CONSEGUIU ENCONTRAR O ITEM DO PEDIDO " + cPedido + " [ Erro de Posicionamento na SC6 ]"
				oJsonResponse['pedido']		:= {}
				oJsonResponse['code'] 		:= 400
				Self:SetResponse(oJsonResponse)	
				RETURN .F.
			ENDIF

		Next

		For n1 := 1 to Len(oItens)
			
			nTamProd 	:= TamSx3("C6_PRODUTO")[1]
			nTamItem	:= TamSX3("C6_ITEM")[1]

			cPedido  := AllTrim(oJson["c5_pedido"])
			cItem	 := StrZero(VAL(ALLTRIM(oItens[n1]["c6_item"])), nTamItem)
			cProduto := PadR( oItens[n1]["c6_produto"]		, nTamProd )
			POSICIONE("SC5", 1, xFilial("SC5") + cPedido , "C5_NUM")
			POSICIONE("SC6", 1, xFilial("SC6") + cPedido + cItem + cProduto, "C6_PRODUTO")

			Pergunte("MTA500",.F.)
			MaResDoFat(,.T.,.F.,,MV_PAR12 == 1,MV_PAR13 == 1)
			Pergunte("MTA410",.F.)
			SC6->(MaLiberOk({SC5->C5_NUM},.T.))	
		
		Next

		oJsonResponse				:= JsonObject():New()
		oJsonResponse['message'] 	:= "PEDIDO " + cPedido + " ELIMINADO COM SUCESSO."
		oJsonResponse['pedido']		:= cPedido
		oJsonResponse['code'] 		:= 200
		Self:SetResponse(oJsonResponse)	
		RETURN .T.

	ENDIF


	//IATAN EM 14/02/2023
	IF AllTrim(oJson["c5_oper"]) == "15"

		//IATAN EM 31/01/2023 - VALIDAR NOTAS QUE JÁ FORAM DEVOLVIDAS
		itensTemp := oJson:GetJsonObject('itens')		
		notasDev  := ""
		For n1 := 1 to Len(itensTemp)

			CONOUT("cFilPed - validaSaldo.:" + cFilPed)
			CONOUT("CFILANT - validaSaldo.:" + CFILANT)

			// IATAN EM 23/02/2023
			//notasDev := validaSaldo( itensTemp[n1]["c6_qtdven"], ALLTRIM( itensTemp[n1]["c6_xdocwms"] ), ALLTRIM( itensTemp[n1]["c6_xserwms"] ), ALLTRIM( PadL( itensTemp[n1]["c6_xitewms"], TamSX3("C6_XITEWMS")[1], "0" ) ) )
			notasDev := validaSaldo( cFilPed, itensTemp[n1]["c6_qtdven"], ALLTRIM( itensTemp[n1]["c6_xdocwms"] ), ALLTRIM( itensTemp[n1]["c6_xserwms"] ), ALLTRIM( PadL( itensTemp[n1]["c6_xitewms"], TamSX3("C6_XITEWMS")[1], "0" ) ) )
			IF !EMPTY(ALLTRIM(notasDev))

					oJsonResponse				:= JsonObject():New()
					oJsonResponse['message'] 	:= "****ATENCAO - IMPOSSIVEL PROSSEGUIR**** PRODUTO '" + ALLTRIM( itensTemp[n1]["c6_produto"] ) + " JA FOI DEVOLVIDO NAS SEGUINTES NOTAS.: " + ALLTRIM(notasDev)
					oJsonResponse['pedido']		:=  {}
					oJsonResponse['code'] 		:= 400
					Self:SetResponse(oJsonResponse)	

					return .F. // IATAN EM 13/12/2022 para evitar que algum erro possa fazer com que mais de 
			ENDIF

		Next

	ENDIF


	//IATAN EM 07/07/2022
	//TRATAMENTO PARA DEVOLUÇÃO
//	IF AllTrim(oJson["c5_xopewms"]) == "-99"
//IATAN EM 14/02/2023 - OPERAÇÃO 15 = BACKLOG
	IF AllTrim(oJson["c5_oper"]) == "-99" .OR. AllTrim(oJson["c5_oper"]) == "-98" 

		//IATAN EM 17/11/2022 - FOI NECESSÁRIO TRATAR A OPERAÇÃO "-98" ESPECIFICAMENTE PARA RETORNO DE CONSIGNADOS
		//                      POIS OS RETORNOS DE COSGINADOS DEVEM TER ENTRADA DO TIPO "BENEFICIAMENTO"
		cPedBkLog	:= AllTrim(oJson["c5_xpedbkl"])


		//IATAN EM 31/01/2023 - VALIDAR NOTAS QUE JÁ FORAM DEVOLVIDAS
		itensTemp := oJson:GetJsonObject('itens')		
		notasDev  := ""
		For n1 := 1 to Len(itensTemp)
			
			//IATAN EM 23/02/2023
			//notasDev := validaSaldo( itensTemp[n1]["c6_qtdven"], ALLTRIM( itensTemp[n1]["c6_xdocwms"] ), ALLTRIM( itensTemp[n1]["c6_xserwms"] ), ALLTRIM( PadL( itensTemp[n1]["c6_xitewms"], TamSX3("C6_XITEWMS")[1], "0" ) ) )
			notasDev := validaSaldo( cFilPed, itensTemp[n1]["c6_qtdven"], ALLTRIM( itensTemp[n1]["c6_xdocwms"] ), ALLTRIM( itensTemp[n1]["c6_xserwms"] ), ALLTRIM( PadL( itensTemp[n1]["c6_xitewms"], TamSX3("C6_XITEWMS")[1], "0" ) ) )
			IF !EMPTY(ALLTRIM(notasDev))

					oJsonResponse				:= JsonObject():New()
					oJsonResponse['message'] 	:= "****ATENCAO - IMPOSSIVEL PROSSEGUIR**** PRODUTO '" + ALLTRIM( itensTemp[n1]["c6_produto"] ) + " JA FOI DEVOLVIDO NAS SEGUINTES NOTAS.: " + ALLTRIM(notasDev)
					oJsonResponse['pedido']		:=  {}
					oJsonResponse['code'] 		:= 400
					Self:SetResponse(oJsonResponse)	

					return .F. // IATAN EM 13/12/2022 para evitar que algum erro possa fazer com que mais de 
			ENDIF

		Next
		
		lRet :=	U_DEVOLUCAO(@oJson, @Self, cPedBkLog)
	
	ELSE

		
		dEmissao	:= STOD( oJson["c5_emissao"] )
		dEmissao	:= IIF( !Empty(dEmissao), dEmissao, dDatabase)
		cCliente 	:= AllTrim(oJson["c5_cliente"])
		cLojaCli	:= AllTrim(oJson["c5_lojacli"])
		cCondPad	:= AllTrim(oJson["c5_condpag"])
		cCondPad	:= IIF( !Empty(cCondPad), cCondPad, SuperGetMV( "MV_CONDPAD") )
		cTabPrc		:= AllTrim(oJson["c5_tabela"])

		//iatan em 11/11/2022
		cVend       := AllTrim(oJson["c5_vendedor"])


		cOperWMS 	:= AllTrim(oJson["c5_xopewms"])
		cPedBkLog	:= AllTrim(oJson["c5_xpedbkl"])
		cCodMed		:= AllTrim(oJson["c5_codmed"])
		cCodConv	:= AllTrim(oJson["c5_codconv"])
		cPaciente 	:= UPPER(AllTrim(oJson["c5_pacient"]))
		cCliRem 	:= AllTrim(oJson["c5_xclient"])
		cLojaRem 	:= AllTrim(oJson["c5_xlojcli"])

		obsPED      := AllTrim(oJson["c5_obsexpe"])
		obsNF       := AllTrim(oJson["c5_obsnfse"])

		operacao 	:= PADL( AllTrim(oJson["c5_oper"]), TamSx3("C6_OPER")[1], "0")

		CONOUT("----ANTES----")
		CONOUT("cCliRem" + cCliRem)
		CONOUT("cLojaRem" + cLojaRem)


		CheckCliente( @cCliente, @cLojaCli ) 
		CheckCliente( @cCliRem, @cLojaRem ) 

	
		CONOUT("----DEPOIS----")
		CONOUT("cCliRem" + cCliRem)
		CONOUT("cLojaRem" + cLojaRem)

		AAdd( aCab, { "C5_FILIAL" 		, cFilPed							, Nil } )	// Filial da pv : Obrigatorio
		AAdd( aCab, { "C5_TIPO"    		, AllTrim( oJson["c5_tipo"] )		, Nil } )	// Tipo do pv : Obrigatorio
		AAdd( aCab, { "C5_EMISSAO"  	, dEmissao 			   				, Nil } )	// Serie da pv  : Obrigatorio

		// IATAN EM 15/12/2022
		IF !EMPTY(ALLTRIM(cPedBkLog)) .AND. !EMPTY(ALLTRIM(cCliRem))
			AAdd( aCab, { "C5_CLIENTE"   	, cCliRem 		    				, Nil } )	// Codigo do Cliente   : Obrigatorio
			AAdd( aCab, { "C5_LOJACLI"		, cLojaRem 							, Nil } )	// Loja  do Cliente : Obrigatorio

			//IATAN EM 16/12/2022
			//cCliente := cCliRem
			//cLojaCli := cLojaRem

			AAdd( aCab, { "C5_ZCLIRET"   	, cCliente 		    				, Nil } )	// Codigo do Cliente   : Obrigatorio
			AAdd( aCab, { "C5_ZLOJRET"		, cLojaCli 							, Nil } )	// Loja  do Cliente : Obrigatorio



		// IATAN EM 28/11/2022 - TRATAMENTO DE NATUREZA PARA PEDIDOS DE REMESSA DE OPME
		
		// Tratamento específico para orgãos públicos
		/*POSICIONE("SA1", 1, xFilial("SA1")+cCliente+cLojaCli, "A1_NOME" )
		IF ALLTRIM(SA1->A1_NATUREZ) $ "111206-111214"
			AAdd( aCab, { "C5_NATUREZ"  , "111214", Nil } )
		ELSE*/
			IF AllTrim(oJson["c5_oper"]) == "01"

				POSICIONE("SA1", 1, xFilial("SA1")+cCliRem+cLojaRem, "A1_NOME" )
				IF ALLTRIM(SA1->A1_NATUREZ) $ "111206-111214"
						//IATAN EM 15/12/2022
						//AAdd( aCab, { "C5_NATUREZ"  , "111214", Nil } )
						//AAdd( aCab, { "C5_NATUREZ"  , ALLTRIM(SA1->A1_NATUREZ), Nil } )
						//20221215
						AAdd( aCab, { "C5_NATUREZ"  , "111206", Nil } )
				ELSE
					AAdd( aCab, { "C5_NATUREZ"  , "111101" , Nil } )
				ENDIF

			ELSEIF AllTrim(oJson["c5_oper"]) == "05" .OR. AllTrim(oJson["c5_oper"]) == "06" .OR. ;
				   AllTrim(oJson["c5_oper"]) == "08" .OR. AllTrim(oJson["c5_oper"]) == "09" .OR. ;
				   AllTrim(oJson["c5_oper"]) == "11" .OR. AllTrim(oJson["c5_oper"]) == "12" .OR. ;
				   AllTrim(oJson["c5_oper"]) == "14" .OR. AllTrim(oJson["c5_oper"]) == "21" 
				AAdd( aCab, { "C5_NATUREZ"  , "811101" , Nil } )
			ELSEIF AllTrim(oJson["c5_oper"]) == "15"
				//20221214 AAdd( aCab, { "C5_NATUREZ"  , "111102" , Nil } )
				POSICIONE("SA1", 1, xFilial("SA1")+cCliRem+cLojaRem, "A1_NOME" )
				IF ALLTRIM(SA1->A1_NATUREZ) $ "111206-111214"
						//IATAN EM 15/12/2022
						AAdd( aCab, { "C5_NATUREZ"  , "111214", Nil } )
						//AAdd( aCab, { "C5_NATUREZ"  , ALLTRIM(SA1->A1_NATUREZ), Nil } ) mantive a linha acima, conforme teams com Shaina
				ELSE
					AAdd( aCab, { "C5_NATUREZ"  , "111102" , Nil } )
				ENDIF
			ENDIF
		//ENDIF




		ELSE
			AAdd( aCab, { "C5_CLIENTE"   	, cCliente 		    				, Nil } )	// Codigo do Cliente   : Obrigatorio
			AAdd( aCab, { "C5_LOJACLI"		, cLojaCli 							, Nil } )	// Loja  do Cliente : Obrigatorio


		// IATAN EM 28/11/2022 - TRATAMENTO DE NATUREZA PARA PEDIDOS DE REMESSA DE OPME
		
		// Tratamento específico para orgãos públicos
		/*POSICIONE("SA1", 1, xFilial("SA1")+cCliente+cLojaCli, "A1_NOME" )
		IF ALLTRIM(SA1->A1_NATUREZ) $ "111206-111214"
			AAdd( aCab, { "C5_NATUREZ"  , "111214", Nil } )
		ELSE*/
			IF AllTrim(oJson["c5_oper"]) == "01"

				POSICIONE("SA1", 1, xFilial("SA1")+cCliente+cLojaCli, "A1_NOME" )
				IF ALLTRIM(SA1->A1_NATUREZ) $ "111206-111214"
						//IATAN EM 15/12/2022
						//AAdd( aCab, { "C5_NATUREZ"  , "111214", Nil } )
						//AAdd( aCab, { "C5_NATUREZ"  , ALLTRIM(SA1->A1_NATUREZ), Nil } )
						//20221215
						AAdd( aCab, { "C5_NATUREZ"  , "111206", Nil } )
				ELSE
					AAdd( aCab, { "C5_NATUREZ"  , "111101" , Nil } )
				ENDIF

			ELSEIF AllTrim(oJson["c5_oper"]) == "05" .OR. AllTrim(oJson["c5_oper"]) == "06" .OR. ;
				   AllTrim(oJson["c5_oper"]) == "08" .OR. AllTrim(oJson["c5_oper"]) == "09" .OR. ;
				   AllTrim(oJson["c5_oper"]) == "11" .OR. AllTrim(oJson["c5_oper"]) == "12" .OR. ;
				   AllTrim(oJson["c5_oper"]) == "14" .OR. AllTrim(oJson["c5_oper"]) == "21" 
				AAdd( aCab, { "C5_NATUREZ"  , "811101" , Nil } )
			ELSEIF AllTrim(oJson["c5_oper"]) == "15"
				//20221214 AAdd( aCab, { "C5_NATUREZ"  , "111102" , Nil } )
				POSICIONE("SA1", 1, xFilial("SA1")+cCliente+cLojaCli, "A1_NOME" )
				IF ALLTRIM(SA1->A1_NATUREZ) $ "111206-111214"
						//IATAN EM 15/12/2022
						AAdd( aCab, { "C5_NATUREZ"  , "111214", Nil } )
						//AAdd( aCab, { "C5_NATUREZ"  , ALLTRIM(SA1->A1_NATUREZ), Nil } ) mantive a linha acima, conforme teams com Shaina
				ELSE
					AAdd( aCab, { "C5_NATUREZ"  , "111102" , Nil } )
				ENDIF
			ENDIF
		//ENDIF




		ENDIF
		
		AAdd( aCab, { "C5_TIPOCLI"		, AllTrim(oJson["c5_tipocli"]) 		, Nil } )	// Consumidor Final     : Obrigatorio
		aAdd( aCab, { "C5_CONDPAG"		, cCondPad							, Nil } ) 	// Condición de pago		: Obrigatorio
		
		If !Empty(cTabPrc)
			aAdd( aCab, { "C5_TABELA"		, cTabPrc							, Nil } ) 	// Tabela de Preço		: Opcional 
		EndIf 

		// -- CAMPOS CUSTOMIZADOS 
		AAdd( aCab, { "C5_CODMED"   	, cCodMed 		    				, Nil } )	// Codigo do Medico ZA1    	: Opcional
		AAdd( aCab, { "C5_CODCONV"   	, cCodConv 		    				, Nil } )	// Codigo do Convenio ZA2  	: Opcional
		AAdd( aCab, { "C5_PACIENT"   	, cPaciente		    				, Nil } )	// Paciente					: Opcional
		AAdd( aCab, { "C5_XCLIENT"   	, cCliRem 		    				, Nil } )	// Codigo do Cliente do pedido de remessa   : Opcional
		AAdd( aCab, { "C5_XLOJCLI"		, cLojaRem 							, Nil } )	// Loja  do Cliente do pedido de remessa : Opcional
		AAdd( aCab, { "C5_XPEDBKL"		, cPedBkLog 							, Nil } )	// Loja  do Cliente do pedido de remessa : Opcional

		// -- OBSERVAÇÕES DA NOTA FISCAL E DO PEDIDO
		AAdd( aCab, { "C5_OBSEXPE"   	, obsPED 		    				, Nil } )	// Observação do Pedido
		AAdd( aCab, { "C5_OBSNFSE"   	, obsNF 		    				, Nil } )	// Observação da Nota Fiscal

		//iatan em 11/11/2022
		IF !EMPTY(ALLTRIM(cVend))
			AAdd( aCab, { "C5_VEND1", cVend, Nil } )	// VENDEDOR
		ENDIF

		//iatan em 03/12/2022
		IF !EMPTY( AllTrim(oJson["c5_tpfrete"]) )
			AAdd( aCab, { "C5_TPFRETE", AllTrim(oJson["c5_tpfrete"]), Nil } )	
		ENDIF
		//iatan em 03/12/2022
		IF !EMPTY( AllTrim(oJson["c5_forpg"]) )
			AAdd( aCab, { "C5_FORPG", AllTrim(oJson["c5_forpg"]), Nil } )	
		ENDIF
		//iatan em 03/12/2022
		IF !EMPTY( AllTrim(oJson["c5_ztplibe"]) )
			AAdd( aCab, { "C5_ZTPLIBE", AllTrim(oJson["c5_ztplibe"]), Nil } )	
		ENDIF
		//iatan em 03/12/2022
		IF !EMPTY( AllTrim(oJson["c5_codconv"]) )
			AAdd( aCab, { "C5_CODCONV", AllTrim(oJson["c5_codconv"]), Nil } )	
		ENDIF
		//iatan em 03/12/2022
		IF !EMPTY( AllTrim(oJson["c5_dproced"]) )
			AAdd( aCab, { "C5_DPROCED", STOD( oJson["c5_dproced"] ), Nil } )	
		ENDIF


		nTamProd 	:= TamSx3("C6_PRODUTO")[1]
		nTamItem	:= TamSX3("C6_ITEM")[1]
		nTamLote	:= TamSX3("C6_LOTECTL")[1]

		nTamDoc	:= TamSX3("C6_XDOCWMS")[1]
		nTamSer	:= TamSX3("C6_XSERWMS")[1]
		nTamITE	:= TamSX3("C6_XITEWMS")[1]

		oItens := oJson:GetJsonObject('itens')
			
		For n1 := 1 to Len(oItens)

			cItem		:= StrZero(n1,nTamItem)
			cProduto 	:= PadR( oItens[n1]["c6_produto"]		, nTamProd )
			//Comentado por Iatan em 23/06/2022 pois deixamos de utilizar a TES e passamos a utilizar a OPERAÇÂO
			//cTesVen		:= oItens[n1]["c6_tes"]
			//cTesVen		:= IIF( !Empty(cTesVen), cTesVen, SuperGetMv("ES_TESPED1",,"541") )
			cCodLote	:= PadR( oItens[n1]["c6_lotectl"]		, nTamLote )

			cDocWMS		:= PadR( oItens[n1]["c6_xdocwms"]		, nTamDoc )
			cSerWMS		:= PadR( oItens[n1]["c6_xserwms"]		, nTamSer )
			cITEWMS		:= PadL( oItens[n1]["c6_xitewms"], nTamItem, "0" )

			qtdVol      := qtdVol +  oItens[n1]["c6_qtdlib"]
			pesoLiq     := pesoLiq + POSICIONE("SB1", 1, XFILIAL("SB1")+cProduto, "B1_PESO")
			pesoBrt     := pesoBrt + POSICIONE("SB1", 1, XFILIAL("SB1")+cProduto, "B1_PESBRU")

			aLinha := {}				
			AAdd( aLinha, { "C6_ITEM"		, cItem							, Nil } )  
			AAdd( aLinha, { "C6_PRODUTO"  	, cProduto 				 		, Nil } )
			AAdd( aLinha, { "C6_QTDVEN"   	, oItens[n1]["c6_qtdven"]		, Nil } )
			AAdd( aLinha, { "C6_QTDLIB" 	, oItens[n1]["c6_qtdlib"]  		, Nil } )	
			AAdd( aLinha, { "C6_PRCVEN" 	, oItens[n1]["c6_prcven"]		, Nil } )	
			AAdd( aLinha, { "C6_PRUNIT"		, oItens[n1]["c6_prunit"]  		, Nil } )	
			AAdd( aLinha, { "C6_VALOR" 		, oItens[n1]["c6_valor"]  		, Nil } )	
			
			//IATAN EM 13/12/2022 - QUANDO FOR PEDIDO DE BACKLOG = OPERAÇÃO 15 BUSCAR O ARMAZEM UTILIZADO NA NOTA DE ORIGEM
			IF AllTrim(oJson["c5_oper"]) == "15" .AND. EMPTY(ALLTRIM(cPedBkLog))
				cCodLote := ""
				//AAdd( aLinha, { "C6_LOCAL" 		, getLocalNFOrigem(xFilial("SD2"), cDocWMS, cSerWMS, cITEWMS) 		, Nil } )	
			ELSE
				//AAdd( aLinha, { "C6_LOCAL" 		, oItens[n1]["c6_local"]  		, Nil } )	
			ENDIF
			IF AllTrim(oJson["c5_oper"]) == "15" .OR. EMPTY(ALLTRIM(cDocWMS)) //.AND. EMPTY(ALLTRIM(cPedBkLog))
				AAdd( aLinha, { "C6_LOCAL" 		, oItens[n1]["c6_local"]  		, Nil } )	
			ELSE
				AAdd( aLinha, { "C6_LOCAL" 		, getLocalNFOrigem(xFilial("SD2"), cDocWMS, cSerWMS, cITEWMS) 		, Nil } )	
			ENDIF
			
			//AAdd( aLinha, { "C6_TES" 		, cTesVen				  		, Nil } )		
			AAdd( aLinha, { "C6_OPER" 		, operacao				  		, Nil } )		

			//Iatan em 30/12/2022 - Sugestão de Tiago para evitar o erro A440ACILOT
			IF !EMPTY(ALLTRIM(cCodLote))
				AAdd( aLinha, { "C6_LOTECTL" 	, cCodLote				  		, Nil } )
			ENDIF

			CONOUT(" C6_LOTECTL.: " + cCodLote)
			AAdd( aLinha, { "C6_XDOCWMS" 	, cDocWMS				  		, Nil } )
			AAdd( aLinha, { "C6_XSERWMS" 	, cSerWMS				  		, Nil } )
			AAdd( aLinha, { "C6_XITEWMS" 	, cITEWMS				  		, Nil } )			

			//iatan em 03/12/2022
			IF !EMPTY( AllTrim( oItens[n1]["c6_pedcli"] ) )
				AAdd( aLinha, { "C6_PEDCLI", AllTrim( oItens[n1]["c6_pedcli"] ), Nil } )
			ENDIF

			AAdd( aItens, aLinha)
			
			CONOUT("cFilPed - arrOrig .:" + cFilPed)
			CONOUT("CFILANT - arrOrig.:" + CFILANT)

			AADD( arrOrig, {cFilPed, cDocWMS, cSerWMS, cITEWMS, cCliente, cLojaCli, cProduto, cCodLote, oItens[n1]["c6_local"], oItens[n1]["c6_qtdven"], oItens[n1]["c6_prcven"]  } )
		
		Next

		//Iatan em 31/05/2022 - Inclusão dos campos Peso Bruto, Peso Líquido, Quantidade de Volumes e Especie no cabeçalho
		AAdd( aCab, { "C5_PESOL"		, pesoLiq 							, Nil } )	// Peso Líquido
		AAdd( aCab, { "C5_PBRUTO"		, pesoBrt 							, Nil } )	// Peso Bruto
		AAdd( aCab, { "C5_VOLUME1"		, qtdVol 							, Nil } )	// Quantidade de Volumes
		AAdd( aCab, { "C5_ESPECI1"		, "UN"  							, Nil } )	// Especie dos Volumes
		//IATAN EM 14/10/2022 - PEDIDOS VINDO DO WMS JÁ NASCEM COM O CAMPO DE LIBERAÇÃO FLAGADO 
		//AGORA ESTE CAMPO É VALIDADO NO MAPWMS07 AFIM DE EVITAR DUPLICIDADE DE INTEGRAÇÃO DE PEDIDOS COM O WMS
		AAdd( aCab, { "C5_XWMS"		, "S"  							, Nil } )	// Especie dos Volumes
		AAdd( aCab, { "C5_XMSGWMS"	, "PEDIDO ORIGINADO NO WMS"     , Nil } )	// Especie dos Volumes


		/*
			IATAN EM 20/10/2022
			OPERAÇÃO 15 SIGNIFICA OPME E EXIGE TRANSFERÊNCIA INTERNA
		*/
		IF AllTrim(oJson["c5_oper"]) $ "15"
			// FAZER A MOVIMENTAÇÃO INTERNA DO ESTOQUE DE ORIGEM PARA O ESTOQUE QUE ESTÁ SENDO PASSADO NA API

			//Cabecalho a Incluir
//			aAuto         := {}
//			cDocumen := GetSxeNum("SD3","D3_DOC")
//			cDocumen := nextnumero ("SD3", 2, "D3_DOC", .T.)
//			aadd(aAuto,{cDocumen,dDataBase}) //Cabecalho

			For nX := 1 To Len(arrOrig)

				// POSICIONANDO NA SB1 E SD2
				CONOUT("PRODUTO MOV INTERNA.:" + arrOrig[nX][7])
				POSICIONE("SB1", 1, xFilial("SB1")+arrOrig[nX][7], "B1_DESC")
				
				//IATAN EM 17/11/2022 - TENTA POSICIONAR NA SD2 ATRAVÉS DO INDICE PADRÃO
				//POSICIONE("SD2", 3, xFilial("SD2")+arrOrig[nX][2]+arrOrig[nX][3]+arrOrig[nX][5]+arrOrig[nX][6]+arrOrig[nX][7]+arrOrig[nX][4], "D2_LOCAL")
				
				//IF ALLTRIM(SD2->D2_FILIAL) == ALLTRIM(arrOrig[nX][1]) .AND. ALLTRIM(SD2->D2_DOC) == ALLTRIM(arrOrig[nX][2]) .AND. ALLTRIM(SD2->D2_SERIE) == ALLTRIM(arrOrig[nX][3])
					// CONSEGUIU SE POSICIONAR NA SD2 PELO INDICE PADRÃO
				//ELSE
					recnoSD2 := getRecnoSD2(arrOrig[nX])
					IF VALTYPE(recnoSD2) == "U" // IATAN EM 27/12/2022 - QUANDO NÃO CONSEGUIR SE POSICIONAR NA SD2 RETORNA ERRO PARA A API
						oJsonResponse				:= JsonObject():New()
						oJsonResponse['message'] 	:= "NAO ENCONTRADO ITEM DA NOTA DE ORIGEM [ Erro de posicionamento SD2 ]" 
						oJsonResponse['code'] 		:= 499
						//oJsonResponse['c6_item']	:= ""
						oJsonResponse['c6_produto']	:= arrOrig[nX][7]
						oJsonResponse['c6_lotectl']	:= arrOrig[nX][8]
						oJsonResponse['c6_xdocwms']	:= arrOrig[nX][2]
						oJsonResponse['c6_xserwms']	:= arrOrig[nX][3]
						oJsonResponse['c6_xitewms']	:= arrOrig[nX][4]
						Self:SetResponse(oJsonResponse)	
						RETURN .F.
					ENDIF
					SD2->(DBGOTO(recnoSD2))
				//ENDIF


				CONOUT("PRODUTO SB1.:" + SB1->B1_COD)
				IF ALLTRIM(SB1->B1_COD) <> ALLTRIM(arrOrig[nX][7])
					oJsonResponse				:= JsonObject():New()
					oJsonResponse['message'] 	:= "NAO CONSEGUIU ENCONTRAR O PRODUTO - ERRO POSICIONAMENTO SB1" 
					oJsonResponse['pedido']		:= {}
					oJsonResponse['code'] 		:= 400
					Self:SetResponse(oJsonResponse)	
					RETURN .F.
				ENDIF
				CONOUT("DOCTO ORIGEM.:" + arrOrig[nX][2] )
				CONOUT("CHAVE SD2.: '" + xFilial("SD2")+arrOrig[nX][2]+arrOrig[nX][3]+arrOrig[nX][5]+arrOrig[nX][6]+arrOrig[nX][7]+arrOrig[nX][4] + "' ")
				CONOUT("DOC ORIGEM - SD2.:" + SD2->D2_DOC )
				IF SD2->D2_DOC <> arrOrig[nX][2]
					oJsonResponse				:= JsonObject():New()
					oJsonResponse['message'] 	:= "NAO CONSEGUIU ENCONTRAR O DCTO DE ORIGEM - ERRO POSICIONAMENTO SD2" 
					oJsonResponse['pedido']		:= {}
					oJsonResponse['code'] 		:= 400
					Self:SetResponse(oJsonResponse)	
					RETURN .F.
				ENDIF
				/*IF ALLTRIM(SD2->D2_LOTECTL) <> ALLTRIM(arrOrig[nX][8])
					oJsonResponse				:= JsonObject():New()
					oJsonResponse['message'] 	:= "LOTE INFORMADO NO JSON DIFERENTE DO LOTE DE ORIGEM NO DCTO ORIGINAL"
					oJsonResponse['pedido']		:= ""
					oJsonResponse['code'] 		:= 400
					Self:SetResponse(oJsonResponse)	
					RETURN .F.
				ENDIF*/

				//SE NÃO EXISTE O ARMAZEM ... CRIAR
				SB2->( dbSetOrder( 1 ) )
				If SB2->( !dbSeek( xFilial( 'SB2' ) + arrOrig[nX][7] + arrOrig[nX][9], .F. ) )

					lMsErroAuto := .F.

					MSExecAuto( { |x,y| MATA220( x, y ) }, { { 'B9_COD', arrOrig[nX][7], Nil }, { 'B9_LOCAL', arrOrig[nX][9], Nil } }, 3 )

					If lMsErroAuto
							cMessage := "ERRO AO CRIAR SALDO DO PRODUTO - SB9"
							oJsonResponse				:= JsonObject():New()
							oJsonResponse['message'] 	:= cMessage
							oJsonResponse['pedido']		:= {}
							oJsonResponse['code'] 		:= 400
							Self:SetResponse(oJsonResponse)	
							RETURN .F.
					EndIf

				EndIf				

				
				aAuto         := {}
				cDocumen := GetSxeNum("SD3","D3_DOC")
				cDocumen := nextnumero ("SD3", 2, "D3_DOC", .T.)
				aadd(aAuto,{cDocumen,dDataBase}) //Cabecalho

				aLinha := {} 
				CONOUT("CFILANT.: " + CFILANT)
				CONOUT("SB1->B1_COD.: "+SB1->B1_COD)
				CONOUT("SB1->B1_DESC.: " + SB1->B1_DESC)
				CONOUT("SB1->B1_UM.: " + SB1->B1_UM)
				CONOUT("SD2->D2_LOCAL.: " + SD2->D2_LOCAL)
				CONOUT("------")
				CONOUT("arrOrig[nX][9].: " + arrOrig[nX][9])
				CONOUT("SD2->D2_LOTECTL.: " + SD2->D2_LOTECTL)
				CONOUT("SD2->D2_DTVALID.: " + DTOS(SD2->D2_DTVALID))
				CONOUT("arrOrig[nX][10].: " + ALLTRIM(STR(arrOrig[nX][10])))
				aLinha := { {"D3_FILIAL",  CFILANT, Nil},;
							{"D3_COD",     SB1->B1_COD, Nil},;
							{"D3_DESCRI",  SB1->B1_DESC, Nil},;
							{"D3_UM",      SB1->B1_UM, Nil},;
							{"D3_LOCAL",   SD2->D2_LOCAL, Nil},;
							{"D3_LOCALIZ", PadR(" ", tamsx3('D3_LOCALIZ') [1]),Nil},;
							{"D3_COD",     SB1->B1_COD, Nil},;
							{"D3_DESCRI",  SB1->B1_DESC, Nil},;
							{"D3_UM",      SB1->B1_UM, Nil},;
							{"D3_LOCAL",   arrOrig[nX][9], Nil},;
							{"D3_LOCALIZ", PadR(" ", tamsx3('D3_LOCALIZ') [1]),Nil},;
							{"D3_NUMSERI", "", Nil},;
							{"D3_LOTECTL", SD2->D2_LOTECTL, Nil},;
							{"D3_NUMLOTE", "", Nil},;
							{"D3_DTVALID", SD2->D2_DTVALID, Nil},;
							{"D3_POTENCI", 0, Nil},;
							{"D3_QUANT",   arrOrig[nX][10], Nil},;
							{"D3_QTSEGUM", 0, Nil},;
							{"D3_ESTORNO", "", Nil},;
							{"D3_NUMSEQ", "", Nil},;
							{"D3_LOTECTL", SD2->D2_LOTECTL, Nil},;
							{"D3_DTVALID", SD2->D2_DTVALID, Nil},;
							{"D3_SERVIC", "", Nil},;
							{"D3_ITEMGRD", "", Nil}}


					aAdd(aAuto,aLinha)

					CONOUT("INICIANDO MOVIMENTACAO INTERNA")
					nOpcAuto := 3 // Inclusao
					PUTMV("MV_ESTNEG","S")
					//IATAN EM 01/12/2022
					//MOVIMENTAÇÃO INTERNA retirada deste processo - vamos faturar diretamente no armazem 06 as operações 15
					//MSExecAuto({|x,y| mata261(x,y)},aAuto,nOpcAuto)
					PUTMV("MV_ESTNEG","N")

					IF lMsErroAuto
						PUTMV("MV_ESTNEG","N")
						aLogErr := GetAutoGRLog()
						IF "MA240NEGAT" $ aLogErr[1]
							cMessage := 'NÃO EXISTE SALDO SUFICIENTE NO LOTE [SB8] - ' + ALLTRIM(aLogErr[1])
						ELSE
							cMessage := 'ERRO AO MOVIMENTAR IMPORTACAO [MATA261] - ' + ALLTRIM(aLogErr[1]) 
						ENDIF

						oJsonResponse				:= JsonObject():New()
						oJsonResponse['message'] 	:= cMessage
						oJsonResponse['pedido']		:= {}
						oJsonResponse['code'] 		:= 400
						Self:SetResponse(oJsonResponse)	
						RETURN .F.
					ELSE
						//CONOUT("MOVIMENTACAO INTERNA FINALIZADA CORRETAMENTE")
					ENDIF


			next

			/*
			CONOUT("INICIANDO MOVIMENTACAO INTERNA")
			nOpcAuto := 3 // Inclusao
			PUTMV("MV_ESTNEG","S")
			MSExecAuto({|x,y| mata261(x,y)},aAuto,nOpcAuto)
			PUTMV("MV_ESTNEG","N")

			IF lMsErroAuto
				PUTMV("MV_ESTNEG","N")
				aLogErr := GetAutoGRLog()
				IF "MA240NEGAT" $ aLogErr[1]
					cMessage := 'NÃO EXISTE SALDO SUFICIENTE NO LOTE [SB8] - ' + ALLTRIM(aLogErr[1])
				ELSE
					cMessage := 'ERRO AO MOVIMENTAR IMPORTACAO [MATA261] - ' + ALLTRIM(aLogErr[1]) 
				ENDIF

				oJsonResponse				:= JsonObject():New()
				oJsonResponse['message'] 	:= cMessage
				oJsonResponse['pedido']		:= ""
				oJsonResponse['code'] 		:= 400
				Self:SetResponse(oJsonResponse)	
				RETURN .F.
			ELSE
				CONOUT("MOVIMENTACAO INTERNA FINALIZADA CORRETAMENTE")
			ENDIF
			*/

			// --------------------------------------------------
			// TRATAMENTO PARA PROCESSO DE FATURAMENTO DE BACKLOG 
			// 1. Posiciona no pedido de BackLog 
			// -----------------------------------
			If cOperWMS == AllTrim(SuperGetMV("ES_PVFATBK",,"5")) .And. !Empty(cPedBkLog) 
				
				// iatan em 13/12/2022
				CONOUT("GERANDO RETORNO DE BACKLOG")
				lRet := U_DEVOLUCAO(@oJson, @Self, cPedBkLog) // retorno do consignado -- iatan em 11/12/2022

				IF lRet == .T.
					lRet :=  UpdateBackLog( aCab, aItens, @cLogMsg )
				ENDIF


			EndIf 


		ENDIF



		If ( lRet )
			//------------------------------------
			// Variaveis de controle de Erro \ Log 
			//------------------------------------
			Private lMsErroAuto 	:= .F.
			Private lMsHelpAuto 	:= .T.
			Private lAutoErrNoFile  := .T. //<= para nao gerar arquivo e pegar o erro com a funcao GETAUTOGRLOG()

			//-- Organiza os Arrays conforme dicionario 
			aCab	:= FWVetByDic(aCab		, "SC5",.F.)                 
			aItens 	:= FWVetByDic(aItens	, "SC6",.T.)  

			CONOUT("cFilPed - EXECAUTO .:" + cFilPed)
			CONOUT("CFILANT - EXECAUTO.:" + CFILANT)

			// IATAN EM 23/02/2023
			IF cFilPed <> CFILANT
				CONOUT("***ERRO DE POSICIONAMENTO***")
				CFILANT := cFilPed
			ENDIF

			MsExecAuto({|x,y,z| MATA410(x,y,z)}, aCab, aItens,3)

			If ( lMsErroAuto  )
				aLogErr := GetAutoGRLog()
				aLogErr	:= TrataErro( aLogErr ) //Trata log a partir do erro do execauto	
				cLogMsg += 'ERROR Ao incluir Pedido de Venda [MATA410] - ' + EncodeUTF8( aLogErr[1] )

				FwMakeDir("integracao_wms\ws\pedido")
				MEMOWRITE("integracao_wms\ws\pedido\"+ NomeAutoLog() + ".log", cLogMsg )

				lRet	:= .F. 
			Else 
				lRet 	:= .T. 
				filialPedido := SC5->C5_FILIAL
				numeroPedido := SC5->C5_NUM
				cLogMsg += "Pedido de venda incluido com sucesso!"
				
				If Empty(cTabPrc)
					RECLOCK("SC5", .F.)
						SC5->C5_TABELA := "007"
					SC5->(MsUnlock())
				ENDIF

				//IATAN EM 17/11/2022
				getRetSC6(@retSC6, SC5->C5_FILIAL, SC5->C5_NUM)


			EndIf
		EndIf 

		// ------------------------------------------------------------
		// MONTA JSON DE RESPOSTA DO REST
		IF EMPTY(ALLTRIM(cLogMsg)) .AND. lRet == .F. //.AND. EMPTY(ALLTRIM(retSC6))
			// TRATAMENTO PARA NÃO MANDAR MAIS DE UMA MENSAGEM PARA O WMS
		ELSE
			oJsonResponse				:= JsonObject():New()
			oJsonResponse['message'] 	:= cLogMsg 
			//oJsonResponse['pedido']		:= IIF( lRet, AllTrim(SC5->C5_NUM),"")
			oJsonResponse['code'] 		:= IIF( lRet, 200, 400)
			oJsonResponse['pedido']     := retSC6
			Self:SetResponse(oJsonResponse)	
		ENDIF
	ENDIF

	CFILANT := filialATUAL

Else 
  SetRestFault(400, "Json Invalido! - FromJSON ")
EndIf 	

RestArea( aArea )


Return( lRet )

/*------------------------------------------------------------------
	FUNCAO PARA FORMATAR O RETORNO DO EXECAUTO - ERROR LOG
------------------------------------------------------------------*/ 
Static Function TrataErro( aErr )

Local lHelp   := .F.
Local lTabela := .F.
Local cLinha  := ""
Local aRet    := {}
Local nI      := 0

	For nI := 1 to LEN( aErr)
		cLinha  := UPPER( aErr[nI] )
		cLinha  := STRTRAN( cLinha,CHR(13), " " )
		cLinha  := STRTRAN( cLinha,CHR(10), " " )

		If SUBS( cLinha, 1, 4 ) $ 'HELP;AJUD'
			lHelp := .T.
		EndIf

		If SUBS( cLinha, 1, 6 ) == 'TABELA'
			lHelp   := .F.
			lTabela := .T.
		EndIf

		If  lHelp .or. ( lTabela .AND. '< -- INVALIDO' $  cLinha )
			aAdd( aRet,  cLinha )
		EndIf
	Next

	If Empty(aRet)
		aAdd( aRet,  "Indeterminado - " + Procname() )
	EndIf
Return( aRet )


Static Function CheckCliente( cCliente, cLojaCli )

Local nTamCli := TamSx3("C5_CLIENTE")[1]
Local nTamLoj := TamSx3("C5_LOJACLI")[1]

If 	!Empty(cCliente)	.And. ;
	 Empty(cLojaCli)	.And. ;
	 Len(cCliente) > nTamCli

	cLojaCli	:= SubStr( cCliente, nTamCli + 1 , Len(cCliente) )
	cCliente	:= SubStr( cCliente, 1, nTamCli )
	

ElseIf	!Empty(cCliente)	.And. ;
	 	!Empty(cLojaCli)	.And. ;
	 	Len(cCliente) > nTamCli 

	cCliente 	:= SubStr( cCliente,1,nTamCli)
	cLojaCli	:= PADR( cLojaCli, nTamLoj ) 


EndIf 

Return()


Static Function UpdateBackLog( aCab, aItens, cLogMsg )

Local aArea 		:= GetArea()
Local cFilPed 		:= ""
Local cPedido 		:= ""
Local aCposSC5		:= {}
Local aCposSC6		:= {}
Local aCabecAlt		:= {}
Local aItensAlt		:= {}
Local aLinha		:= {}
Local aLogErr		:= {}
Local bCondAddC5	:= {|| }
Local bCondAddC6	:= {|| }
Local cAutDeleta	:= ""
Local nPosProd 		:= 0
Local nOperation 	:= 4
Local nQtdItens		:= 0
Local nQtdItensDel	:= 0 		
Local lRet 			:= .T.

	
	cFilPed := GetValCampo( aCab, "C5_FILIAL" )
	cPedido := GetValCampo( aCab, "C5_XPEDBKL" )

	DbSelectArea("SC5")
	SC5->(DbSetOrder(1))
	If SC5->(DbSeek(cFilPed + cPedido))

		/* ------------------------------------------------
			Condição para a adição do campo para o ExecAuto
			Só insere campos com conteúdo
		---------------------------------------------------*/
		/* Busca os campos da SC5 */
		aCposSC5 := GetFldSX3("SC5")

		/* Busca os campos da SC6 */
		aCposSC6 := GetFldSX3("SC6")

		/* Remove o campo C6_ITEM, pois o mesmo será adicionado manualmente */	
		If (nPos := AScan(aCposSC6, {|x| AllTrim(x) == "C6_ITEM"})) > 0
			ADel(aCposSC6, nPos)
			ASize(aCposSC6, Len(aCposSC6) - 1)
		EndIf
		/* Remove o campo C6_QTDVEN, pois o mesmo será adicionado manualmente */	
		If (nPos := AScan(aCposSC6, {|x| AllTrim(x) == "C6_QTDVEN"})) > 0
			ADel(aCposSC6, nPos)
			ASize(aCposSC6, Len(aCposSC6) - 1)
		EndIf

		bCondAddC5 := {|cCampo| IIf(!Empty(&("SC5->" + cCampo)), Aadd(aCabecAlt, {cCampo, &("SC5->" + cCampo), Nil}), Nil)}

		AEVal(aCposSC5, bCondAddC5)

		//Busca se um dos itens e de venda
		DbSelectArea("SC6")
		SC6->(DbSetOrder(1))
		SC6->(DbSeek(xFilial("SC6")+SC5->C5_NUM))
		While SC6->(!Eof()) .And. SC6->C6_FILIAL + SC6->C6_NUM == xFilial("SC6")+SC5->C5_NUM
			
			nQtdItens += 1
			nPosProd  := GetPosProd(aItens,SC6->C6_ITEM + SC6->C6_PRODUTO)

			CONOUT("Saiu com a chave.: " + ALLTRIM(STR(nPosProd)) )
		
			If (nPosProd > 0)
			
				nQtdVen := GetValCampo( aItens[nPosProd], "C6_QTDVEN")
			
				If  (SC6->C6_QTDVEN >= nQtdVen)  
					If  (SC6->C6_QTDVEN == nQtdVen)
						/* Variavel que determina se o item do pedido de venda 
						será deletado ("S") ou não ("N") */
						cAutDeleta		:= "S"
						nQtdItensDel 	+= 1
						Aadd(aLinha, {"LINPOS"	 , "C6_ITEM" , SC6->C6_ITEM})
						Aadd(aLinha, {"AUTDELETA", cAutDeleta, Nil		   })
					EndIf 

					Aadd(aLinha, {"C6_QTDVEN"	 , nQtdVen , Nil})


					/* Adiciona os demais campos que tem conteúdo no array de itens */
					bCondAddC6 := {|cCampo| IIf(!Empty(&("SC6->" + cCampo)), AAdd(aLinha, {cCampo, &("SC6->" + cCampo), Nil}), Nil)}

					AEVal(aCposSC6, bCondAddC6)

					Aadd(aItensAlt, aLinha)

					aLinha := {}
				Else 
					cLogMsg := "ERROR Pedido BackLog ["+ cPedido +"] C6_ITEM+C6_PRODUTO ["+AllTrim(SC6->C6_ITEM)+"] + ["+ AllTrim(SC6->C6_PRODUTO) +"] quantidade ["+ cValToChar(SC6->C6_QTDVEN) +"] não atendida."
					lRet 	:= .F.
					Exit 				
				EndIf 
			Else 
				cLogMsg := "ERROR Pedido BackLog ["+ cPedido +"] C6_ITEM+C6_PRODUTO ["+AllTrim(SC6->C6_ITEM)+"] + ["+ AllTrim(SC6->C6_PRODUTO) +"] Não foi localizado."
				lRet 	:= .F.
				Exit 
			EndIf 

			SC6->(DbSkip())
		EndDo

		If ( lRet )

			//------------------------------------
			// Variaveis de controle de Erro \ Log 
			//------------------------------------
			Private lMsErroAuto 	:= .F.
			Private lMsHelpAuto 	:= .T.
			Private lAutoErrNoFile  := .T. //<= para nao gerar arquivo e pegar o erro com a funcao GETAUTOGRLOG()
			
			//-- Organiza os Arrays conforme dicionario 
			aCabecAlt	:= FWVetByDic(aCabecAlt , "SC5",.F.)                 
			aItensAlt 	:= FWVetByDic(aItensAlt	, "SC6",.T.)  

			//-- Seta operação 
			nOperation := IIF( nQtdItens == nQtdItensDel, MODEL_OPERATION_DELETE, MODEL_OPERATION_UPDATE  )

			// IATAN EM 23/02/2023
			IF cFilPed <> CFILANT
				CONOUT("***ERRO DE POSICIONAMENTO - UPDATEBACKLOG***")
				CFILANT := cFilPed
			ENDIF

		 	MsExecAuto( {|x, y, z| MATA410(x, y, z)}, aCabecAlt, aItensAlt, nOperation) // nOperation 4 = Alteração ou nOperation 5 = Exclusao

			If ( lMsErroAuto  )
				aLogErr := GetAutoGRLog()
				aLogErr	:= TrataErro( aLogErr ) //Trata log a partir do erro do execauto	
				cLogMsg := "ERROR Ao atualizar/deletar Pedido de BackLog ["+ cPedido +"]  - " + EncodeUTF8( aLogErr[1] )
				lRet	:= .F. 
			Else 
				lRet 	:= .T. 
				cLogMsg := "Pedido de BackLog ["+cPedido+"] foi "+ IIF( nOperation == 5,"totalmente atendido (Exclusão efetuada)","atualizado")+" com sucesso!"

				If Empty(cTabPrc)
					RECLOCK("SC5", .F.)
						SC5->C5_TABELA := "007"
					SC5->(MsUnlock())
				ENDIF

				//IATAN EM 17/11/2022 - RETORNO DA SC6
				getRetSC6(@retSC6, SC5->C5_FILIAL, SC5->C5_NUM)

			EndIf

		EndIf 
	Else 
	// IATAN EM 13/01/2023
		cLogMsg := "ERROR Pedido de BackLog ["+cPedido+"] informado não existe!"
		lRet := .F.
	EndIf 


RestArea( aArea )

Return( lRet )

Static Function SetValCampo(aArrayCpos, cNomeCpo, xValor)

	Local nPos := aScan(aArrayCpos, {|x| Upper(AllTrim(x[1])) == cNomeCpo })

	If nPos > 0
		aArrayCpos[nPos, 2] := xValor
	EndIf 

Return .T.

Static Function GetValCampo(aArrayCpos, cNomeCpo)
  
	Local nPos   := aScan(aArrayCpos, {|x| Upper(AllTrim(x[1])) == cNomeCpo })
	Local xValor := Nil
	If nPos > 0
		xValor := aArrayCpos[nPos, 2]
	EndIf

Return xValor 

Static Function RemoveCampo(aArrayCpos, cNomeCpo)

	Local nPos := aScan(aArrayCpos, {|x| Upper(AllTrim(x[1])) == cNomeCpo })

	If nPos > 0
		ADel(aArrayCpos, nPos)
		ASize(aArrayCpos, Len(aArrayCpos) - 1)
	EndIf

Return .T.

Static Function GetPosProd(aItens,cChave)

Local cItemProd	:= ""
Local nPos 		:= 0
Local nI		:= 0

	For nI := 1 To Len(aItens)
	
		CONOUT("cItemProd.: '" + GetValCampo(aItens[nI], "C6_ITEM") + GetValCampo(aItens[nI], "C6_PRODUTO") + "'" )
		cItemProd 	:= AllTrim(GetValCampo(aItens[nI], "C6_ITEM") + GetValCampo(aItens[nI], "C6_PRODUTO"))
		cChave		:= AllTrim(cChave)	
		CONOUT("cChave.: '" + cChave + "' ")

		If (cItemProd == cChave)
		
			nPos  := nI
			Exit 
		EndIf 
	Next 

Return( nPos )
/*/{Protheus.doc} GetFldSX3
Retorna os campos da tabela SX3 da tabela passada por parâmetro.
@author Juliano Fernandes
@since 18/10/2017
@return aCampos, Array com os campos da tabela SX3
@param cTabela, characters, Tabela para retorno dos campos
@type function
/*/
Static Function GetFldSX3(cTabela)
	Local aCampos := {}

	dbSelectArea("SX3")
	SX3->(dbSetOrder(1))
	If SX3->(dbSeek( cTabela ))
		Do While SX3->(!EoF()) .And. AllTrim(SX3->X3_ARQUIVO) == cTabela
			If X3Uso(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL .And. SX3->X3_CONTEXT != "V"
			   	Aadd( aCampos, SX3->X3_CAMPO )
			EndIf

			SX3->(dbSkip())
		EndDo
	EndIf
Return(AClone(aCampos))


USER FUNCTION DEVOLUCAO(oJson, Self, cPedBkLog)

	Local aCab   := {}
	Local aIt    := {}
	Local _aCabAuto   := {}
	Local _aLinAuto := {}
	Local aLinha    := {}  
	Local cFilPed                 
	Local oItens
	Local n1
	Local nTamItD1	:= TamSX3("D1_ITEM")[1]
	Local nTamProd 	:= TamSx3("D1_COD")[1]
	Local cItem
	Local cTes
	Local cCF
	Local cTesOri
	Local cNfOri
	Local cSrOri
	Local cItOri
	Local cCliente
	Local cLoja
	Local cLote
	Local cLogMsg
	Local lRet
	Local pedWms := ""

	Local oError := ErrorBlock({|e| CONOUT("ERRO APOS EXECATUTO MATA103: " +chr(10)+ e:Description)})

	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .F.

	nModulo := 4 //numero do módulo

    oItens := oJson:GetJsonObject('itens')

	aCabec := {}
	aItens := {}

	pedWms      := AllTrim(oJson["c5_pedwms"])

	cFilPed		:= PadR( oJson["c5_filial"]	, TamSx3("c5_filial")[1] )
	cFilPed		:= IIF( !Empty(cFilPed),cFilPed, xFilial("SC5") )
	cCliente    := AllTrim(oJson["c5_cliente"])
	cLoja       := AllTrim(oJson["c5_lojacli"])
	//PEGANDO DADOS DE ORIGEM DO PRIMEIRO ITEM E ATRIBUINDO QUE AS DEVULUÇÕES SERÃO SEMPRE DA MESMA NOTA
	//cNfOri    := ALLTRIM( oItens[1]["c6_xdocwms"])
	cSrOri    := PADR(ALLTRIM( oItens[1]["c6_xserwms"]), 3, " ")
	//Iatan em 25/11/2022 - Os itens devem ser atualizados conforme cada um dos itens passados pelo json
//	cItOri    := PADL(ALLTRIM( oItens[1]["c6_xitewms"]), 2, "0")
	CheckCliente( @cCliente, @cLoja ) 

	IF EMPTY(AllTrim(oJson["c5_chave3"]))
		//FORMULARIO DE EMISSÃO PRÓPRIA
		cNum := NxtSx5Nota(cSrOri, .T., GetNewPar("MV_TPNRNFS","3"))
		aadd(aCabec,{"F1_FILIAL"     ,cFilped, NIL}) 

		IF AllTrim(oJson["c5_oper"]) == "-98"
			aadd(aCabec,{"F1_TIPO"     ,"B", NIL}) 
		ELSE 
			IF EMPTY(ALLTRIM(cPedBkLog))
				aadd(aCabec,{"F1_TIPO"     ,"D", NIL}) 
			ELSE
				aadd(aCabec,{"F1_TIPO"     ,"B", NIL}) 
			ENDIF
		ENDIF
		
		aadd(aCabec,{"F1_FORMUL"   ,"S", NIL}) 
		aadd(aCabec,{"F1_DOC"     ,cNum, NIL}) 
		aadd(aCabec,{"F1_SERIE"   ,cSrOri, NIL}) 
		aadd(aCabec,{"F1_EMISSAO" ,DDATABASE, NIL}) 
		aadd(aCabec,{"F1_FORNECE" ,cCliente, NIL}) 
		aadd(aCabec,{"F1_LOJA"    ,cLoja, NIL}) 
		aadd(aCabec,{"F1_ESPECIE" ,"SPED", NIL}) 
		aadd(aCabec,{"F1_XPEDWMS" ,pedWms, NIL})  // IATAN EM 04/10/2022 ARMAZENAR O CAMPO CÓDIGO DO PEDIDO WMS POR MOTIVOS DE AUDITORIA
		For n1 := 1 to Len(oItens)

			//IATAN EM 13/01/2023
			cNfOri    := ALLTRIM( oItens[n1]["c6_xdocwms"] )
			cSrOri    := PADR(ALLTRIM( oItens[n1]["c6_xserwms"]), 3, " ") // CASO EXISTAM RETORNOS DE NOTAS COM SERIES DIFERENTES

			//IATAN EM 25/11/2022
			cItOri    := PADL(ALLTRIM( oItens[n1]["c6_xitewms"]), 2, "0")

			cItem	  := StrZero(n1,nTamItD1)
			cProduto  := PadR( oItens[n1]["c6_produto"]		, nTamProd )
			//Para pegar a TES de devolução, devemos posiscionar na nota original e depois pegar 
			cTesOri   := POSICIONE("SD2", 3, cFilPed+cNfOri+cSrOri+cCliente+cLoja+cProduto+cItOri, "D2_TES")   // 3 = D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
			cTes      := POSICIONE("SF4", 1, cFilPed+cTesOri,"F4_TESDV") // POSICIONA NA TES DE ORIGEM
			cCF       := POSICIONE("SF4", 1, cFilPed+cTes,"F4_CF") // BUSCA O CFOP DA TES DE DEVOLUÇÃO
			//SE A TES DE DEVOLUÇÃO CONTROLA PODER DE TERÇEIROS, DEVEMOS OBRIGATORIAMENTE INFORMAR O CAMPO D1_IDENTB6 RELACIONADO NA SB6 
			cEst      := SD2->D2_EST
			cLote     := SD2->D2_LOTECTL

			//IATAN EM 13/01/2023 - SE NÃO CONSEGUIU SE POSICIONAR NA NOTA DE DEVOLUÇÃO CORRETA, NEM ADIANTA SEGUIR ADIANTE
			IF ALLTRIM(SD2->D2_DOC) <> ALLTRIM(cNfOri) .OR. ALLTRIM(SD2->D2_SERIE) <> ALLTRIM(cSrOri) .OR. ALLTRIM(SD2->D2_COD) <> ALLTRIM(cProduto)

				oJsonResponse				:= JsonObject():New()
				oJsonResponse['message'] 	:= 'NOTA DE ORIGEM NÃO ENCONTRADA. ' + 'Nota = ' + ALLTRIM(cNfOri) + ', Serie = ' + ALLTRIM(cSrOri) + ', Produto = ' + ALLTRIM(cProduto)
				oJsonResponse['pedido']		:= {}
				oJsonResponse['code'] 		:= 400
				Self:SetResponse(oJsonResponse)	

				return .F. // IATAN EM 13/12/2022 para evitar que algum erro possa fazer com que mais de uma mensagem de retorno seja retornada

			ENDIF

			aadd(aLinha,{"D1_FILIAL"  ,cFilPed,  Nil}) 
			aadd(aLinha,{"D1_ITEM"    ,cItem,    Nil}) 
			aadd(aLinha,{"D1_COD"     ,cProduto, Nil}) 
			IF !EMPTY(ALLTRIM(cPedBkLog))
				aadd(aLinha,{"D1_LOCAL"   , "06",Nil}) 
			ELSE
				aadd(aLinha,{"D1_LOCAL"   ,SD2->D2_LOCAL,Nil}) 
			ENDIF

			aadd(aLinha,{"D1_QUANT"   ,oItens[n1]["c6_qtdven"],     Nil}) 
			//IATAN EM 13/12/2022 - TRATAMENTO PARA BUSCAR O VALOR DO ITEM ORIGINAL EM CASOS DE RETORNO DE BACKLOG
			IF !EMPTY(ALLTRIM(cPedBkLog))
				CONOUT("PEGANDO VALOR DA NOTA ORIGINAL NA GERAÇÃO DE RETORNO DE BACKLOG")
				CONOUT("NOTA = " + SD2->D2_DOC)
				CONOUT("VALOR = " + ALLTRIM(STR(SD2->D2_PRCVEN)))
				// RETORNO DE BACKLOG
				aadd(aLinha,{"D1_VUNIT"   , SD2->D2_PRCVEN ,Nil}) 
				aadd(aLinha,{"D1_TOTAL"   , SD2->D2_PRCVEN*oItens[n1]["c6_qtdven"] ,Nil}) 
			ELSE
				// DEVOLUÇÃO "NORMAL"
				aadd(aLinha,{"D1_VUNIT"   ,oItens[n1]["c6_prcven"],Nil}) 
				aadd(aLinha,{"D1_TOTAL"   , oItens[n1]["c6_valor"],Nil}) 
			ENDIF
			aadd(aLinha,{"D1_TES"     ,cTes ,Nil}) 
			aadd(aLinha,{"D1_CF"      ,cCF ,Nil}) 
			aadd(aLinha,{"D1_DOC"     ,cNum,Nil}) 
			aadd(aLinha,{"D1_SERIE"   ,cSrOri,Nil}) 
			aadd(aLinha,{"D1_EMISSAO" ,DDATABASE,Nil}) 
			aadd(aLinha,{"D1_NFORI"   ,cNfOri,Nil}) 
			aadd(aLinha,{"D1_SERIORI" ,cSrOri,Nil}) 
			aadd(aLinha,{"D1_ITEMORI" ,cItOri,Nil}) 		
			aadd(aLinha,{"D1_LOTECTL" ,SD2->D2_LOTECTL,Nil}) 
			aadd(aLinha,{"D1_DTVALID" ,SD2->D2_DTVALID,Nil})  // IATAN EM 25/01/2023
			aadd(aLinha,{"D1_IDENTB6" ,SD2->D2_IDENTB6,Nil}) 
			aadd(aLinha,{"AUTDELETA" ,"N" ,Nil})

			aadd(aItens,aLinha)  
			aLinha := {}

		Next
	ELSE
		// CLIENTE EMITIU A PRÓPRIA NOTA
		cNum := SUBSTRING(AllTrim(oJson["c5_chave3"]), 26, 9)
		cSerie := SUBSTRING(AllTrim(oJson["c5_chave3"]), 23, 3)
		aadd(aCabec,{"F1_FILIAL"     ,cFilped, NIL}) 
		aadd(aCabec,{"F1_TIPO"     ,"D", NIL}) 
		aadd(aCabec,{"F1_FORMUL"   ," ", NIL}) 
		aadd(aCabec,{"F1_DOC"     ,cNum, NIL}) 
		aadd(aCabec,{"F1_SERIE"   ,cSerie, NIL}) 
		aadd(aCabec,{"F1_EMISSAO" ,DDATABASE, NIL}) 
		aadd(aCabec,{"F1_FORNECE" ,cCliente, NIL}) 
		aadd(aCabec,{"F1_LOJA"    ,cLoja, NIL}) 
		aadd(aCabec,{"F1_ESPECIE" ,"SPED", NIL}) 
		aadd(aCabec,{"F1_XPEDWMS" ,pedWms, NIL})  // IATAN EM 04/10/2022 ARMAZENAR O CAMPO CÓDIGO DO PEDIDO WMS POR MOTIVOS DE AUDITORIA
		For n1 := 1 to Len(oItens)

			cItem	  := StrZero(n1,nTamItD1)
			cProduto  := PadR( oItens[n1]["c6_produto"]		, nTamProd )
			//Para pegar a TES de devolução, devemos posiscionar na nota original e depois pegar 
			cTesOri   := POSICIONE("SD2", 3, cFilPed+cNfOri+cSrOri+cCliente+cLoja+cProduto+cItOri, "D2_TES")   // 3 = D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
			cTes      := POSICIONE("SF4", 1, cFilPed+cTesOri,"F4_TESDV") // POSICIONA NA TES DE ORIGEM
			cCF       := POSICIONE("SF4", 1, cFilPed+cTes,"F4_CF") // BUSCA O CFOP DA TES DE DEVOLUÇÃO
			//SE A TES DE DEVOLUÇÃO CONTROLA PODER DE TERÇEIROS, DEVEMOS OBRIGATORIAMENTE INFORMAR O CAMPO D1_IDENTB6 RELACIONADO NA SB6 
			cEst      := SD2->D2_EST
			cLote     := SD2->D2_LOTECTL

			aadd(aLinha,{"D1_FILIAL"  ,cFilPed,  Nil}) 
			aadd(aLinha,{"D1_ITEM"    ,cItem,    Nil}) 
			aadd(aLinha,{"D1_COD"     ,cProduto, Nil}) 
			aadd(aLinha,{"D1_LOCAL"   ,SD2->D2_LOCAL,Nil}) 
			aadd(aLinha,{"D1_QUANT"   ,oItens[n1]["c6_qtdven"],     Nil}) 
			aadd(aLinha,{"D1_VUNIT"   ,oItens[n1]["c6_prcven"],Nil}) 
			aadd(aLinha,{"D1_TOTAL"   , oItens[n1]["c6_valor"],Nil}) 
			aadd(aLinha,{"D1_TES"     ,cTes ,Nil}) 
			aadd(aLinha,{"D1_CF"      ,cCF ,Nil}) 
			aadd(aLinha,{"D1_DOC"     ,cNum,Nil}) 
			aadd(aLinha,{"D1_SERIE"   ,cSerie,Nil}) 
			aadd(aLinha,{"D1_EMISSAO" ,DDATABASE,Nil}) 
			aadd(aLinha,{"D1_NFORI"   ,cNfOri,Nil}) 
			aadd(aLinha,{"D1_SERIORI" ,cSrOri,Nil}) 
			aadd(aLinha,{"D1_ITEMORI" ,cItOri,Nil}) 		
			aadd(aLinha,{"D1_LOTECTL" ,SD2->D2_LOTECTL,Nil}) 
			aadd(aLinha,{"D1_DTVALID" ,SD2->D2_DTVALID,Nil})  // IATAN EM 25/01/2023
			aadd(aLinha,{"D1_IDENTB6" ,SD2->D2_IDENTB6,Nil}) 
			aadd(aLinha,{"AUTDELETA" ,"N" ,Nil})

			aadd(aItens,aLinha)  
			aLinha := {}

		Next

	ENDIF



	BEGIN SEQUENCE
			MSExecAuto({|x,y,z| mata103(x,y,z)},aCabec,aItens,3)
	END SEQUENCE 

	ErrorBlock( oError )

	If lMsErroAuto 

		aLogErr := GetAutoGRLog()
		aLogErr	:= TrataErro( aLogErr ) //Trata log a partir do erro do execauto	
		cLogMsg := 'ERRO NA DEVOLUÇÃO [MATA103] - ' + EncodeUTF8( aLogErr[1] )

		FwMakeDir("integracao_wms\devolucoes\erro")
		MEMOWRITE("integracao_wms\devolucoes\erro\"+ cFilPed+ cNfOri + ".log", cLogMsg)

		lRet := .F.

		//IATAN EM 13/01/2023 - SE NÃO CONSEGUIU SE POSICIONAR NA NOTA DE DEVOLUÇÃO CORRETA, NEM ADIANTA SEGUIR ADIANTE
		oJsonResponse				:= JsonObject():New()
		oJsonResponse['message'] 	:= 'ERRO NA DEVOLUÇÃO [MATA103] - ' + EncodeUTF8( aLogErr[1] )
		oJsonResponse['pedido']		:= {}
		oJsonResponse['code'] 		:= 400
		Self:SetResponse(oJsonResponse)	

		return .F. // IATAN EM 13/12/2022 para evitar que algum erro possa fazer com que mais de uma mensagem de retorno seja retornada

	ELSE

		lRet 	:= .T. 
		cLogMsg := "Nota de Devolucao incluida com sucesso!"

		IF EMPTY(AllTrim(oJson["c5_chave3"]))
			//AMBIENTE 1 = PRODUÇÃO                                          |
			//AMBIENTE 2 = HOMOLOGAÇÃO                                       V
			cRetorno := U_SpedNFeTrf("SF1", cSrOri, cNum, cNum, GetIdEnt(), "1", "1", "4.00", .F.,.F.,.T.)

			sleep(20000) // 20 segundos

			//Forço o envio da nota fiscal gerada
			U_MAPWMS16( pedWms, SF1->(RECNO()), 3 )

			//Iatan em 30/06/2022
			//ENVIO DO PDF E DO XML DA NOTA PARA O WMS 
			//u_wGerDanfe(CCHAVE, CNOTA, "4", "\pdf_wms\")
			//u_wGerDanfe(SF1->F1_CHVNFE, SF1->F1_DOC, SF1->F1_SERIE, "\pdf_wms\")

		ENDIF

	EndIF 

	// ------------------------------------------------------------
	// MONTA JSON DE RESPOSTA DO REST
	IF EMPTY(ALLTRIM(cPedBkLog))
		oJsonResponse				:= JsonObject():New()
		oJsonResponse['message'] 	:= cLogMsg 
		oJsonResponse['nota']		:= IIF( lRet, cNum,"")
		oJsonResponse['code'] 		:= IIF( lRet, 200, 400)
		Self:SetResponse(oJsonResponse)	
	ENDIF


RETURN lRet



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³SpedNFeTrf³ Autor ³Eduardo Riera          ³ Data ³21.06.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de remessa da Nota fiscal eletronica para o Totvs    ³±±
±±³          ³Service SPED                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpC1: Mensagem de retorno                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias da tabela da Mbrowse                           ³±±
±±³          ³ExpC2: Serie                                                ³±±
±±³          ³ExpC3: Nota inicial                                         ³±±
±±³          ³ExpC4: Nota final                                           ³±±
±±³          ³ExpC5: Id da entidade empresarial                           ³±±
±±³          ³ExpC6: Ambiente de emissao da NFe                           ³±±
±±³          ³ExpC7: Modalidade de emissao da NFe                         ³±±
±±³          ³ExpC8: Versa da NFe                                         ³±±
±±³          ³ExpL9: Controle de encerramento                             ³±±
±±³          ³ExpL10: Controle de execucao em Job                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
USER Function SpedNFeTrf(cAlias,cSerie,cNotaIni,cNotaFim,cIDEnt,cAmbiente,cModalidade,cVersao,lEnd,lCte,lAuto,dDataDe,dDataAte,lAutomato)

Local aArea			:= GetArea()
Local aNotas		:= {}
Local aNotasOri		:= {}
Local aRetNotas		:= {}
Local aXml			:= {}
Local aNfCup		:= {{"",CTOD("  /  /  "),"","","","","",""}} // Array com as Notas sobre cupom
Local aMotivoCont	:= {}
Local aInfnota		:= {}
Local aValNFe		:= {}
Local aRetCol		:= {}
Local aErro		    := {}

Local cRetorno		:= ""
Local cAliasSF3		:= "SF3"
Local cAliasSF1		:= "SF1"
Local cWhere		:= ""
Local cErro			:= ""
Local cErroScan  	:= ""
Local cHoraIni		:= Time()
Local cURL			:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local cNfCup		:= "CF/SERIE:" // Identifica que eh Nf sobre Cup
Local cFsimpFat		:= "F - Simples Faturamento"						// Identifica se é Nf sobre Cupom Nova validação Lj.
Local cModeloNF	:= ""

Local cGrupo		:= FWGrpCompany()		//Retorna o grupo
Local cFil 		    := FWCodFil()			//Retorna o código da filial
Local cAviso		:= ""
Local cMsgErr		:= ""
Local cXmlConEsp	:= ""
Local dDataIni		:= Date()

Local lQuery		:= .F.
Local lRetorno		:= .T.
Local lTMSCTe		:= SuperGetMv( "MV_TMSCTE", .F., .F. )
Local lMvColESP	:= SuperGetMv( "MV_COLESP", .F., .F. )
Local lFISVALNFE	:= ExistBlock("FISVALNFE")
Local lTermScan     := .F.
Local lRetCons		:= .F.
Local lErro			:= .F.
Local lNaoErro		:= .F.
Local lUsaColab   	:= .F.
Local lSdoc       	:= TamSx3("F2_SERIE")[1] == 14
Local cVersaoTSS		:= ""
Local cError    		:= ""

Local nX			:= 0
Local nY			:= 0
Local nNFes			:= 0
Local nXmlSize		:= 0
Local nPosAux		:= 0 // Posicao auxiliar
Local nTemp			:= 0
Local nZ			:= 0
Local nNFtrans		:= 0
Local cCampos 		:= ""
Local cSerId 		:= ""

Local oWs
Local oDoc
Local cErroEsp	:= ""
Local lEspelho	:= .F.

Local TAMMAXXML  := GetNewPar("MV_XMLSIZE",400000) 

Default lCTe		:= .F.
Default lAuto		:= .F.
Default dDataDe		:= CtoD("")
Default dDataAte	:= CtoD("")
Default lAutomato := .F.

cModeloNF := IIF(lCte,"57","55")
lUsaColab   := UsaColaboracao( IIF(lCte,"2","1") )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaura a integridade da rotina caso exista filtro             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (!lCTe)
	dbSelectArea(cAlias)
	dbClearFilter()
	RetIndex(cAlias)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Alimenta o array    aInfnota                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aadd(aInfnota,cSerie)
aadd(aInfnota,cNotaIni)
aadd(aInfnota,cNotaFim)

If lSdoc .And. !Empty(dDataDe) .And. !Empty(dDataAte)
	aadd(aInfnota,dDataDe)
	aadd(aInfnota,dDataAte)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Analisa parametros                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cAmbiente   := SubStr(cAmbiente,1,1)
cModalidade := SubStr(cModalidade,1,1)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cancela as notas do dia anterior                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lAuto
	SpedNFeCan(cEmpAnt,cFilAnt,cIdEnt,cAmbiente,cModalidade,cVersao,aInfnota,lCTe)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Filtra as notas fiscais do dia                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Obtem as informacoes de contigencia                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cModalidade$"2,3,5,7" .And. !lUsaColab

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Contingencia SCAN - Quando a serie da NFe for menor que 900-999 ³
	//³	nao realiza transmissao e nao grava nas tabelas do SPED		    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cModalidade = "3"
		If Alltrim(SubStr(cSerie,1,3)) < "900"
			lTermScan	:= .T.
			lRetorno	:= .F.
		EndIf
	EndIf

	oWs2 := WsSpedCfgNFe():New()
	oWS2:cUSERTOKEN := "TOTVS"
	oWS2:cID_ENT    := cIdEnt
	oWS2:dDATEINIC  := SToD("  /  /    ")
	oWS2:dDATEFIM   := SToD("  /  /    ")
	oWS2:_URL       := AllTrim(cURL)+"/SPEDCFGNFe.apw"
	oWS2:GetDateCont()
	If Type("oWS2:oWSGETDATECONTRESULT")=="O" .And. Type("oWS2:oWSGETDATECONTRESULT:OWSGETCONT")=="A" .And. Len(oWS2:oWSGETDATECONTRESULT:OWSGETCONT)>0
		aAdd(aMotivoCont,AllTrim(oWS2:oWSGETDATECONTRESULT:OWSGETCONT[Len(oWS2:oWSGETDATECONTRESULT:OWSGETCONT)]:CXMOTIVO))
		aAdd(aMotivoCont,oWS2:oWSGETDATECONTRESULT:OWSGETCONT[Len(oWS2:oWSGETDATECONTRESULT:OWSGETCONT)]:DDATEINIC)
		aAdd(aMotivoCont,AllTrim(oWS2:oWSGETDATECONTRESULT:OWSGETCONT[Len(oWS2:oWSGETDATECONTRESULT:OWSGETCONT)]:CTIMEINIC))
	EndIf
EndIf
If (!lCTe) .And. !lTermScan
    If !lAuto
		ProcRegua(Val(cNotaFim)-Val(cNotaIni)+1)
	EndIf

	if(lAuto .and. val(cNotaFim) - val(cNotaIni) > 50 )
		cNotaIni := alltrim(cNotaIni)
		cNotaFim := strzero(val(cNotaIni) + 50, len(cNotaIni))
		cNotaIni := strzero(val(cNotaIni), len(cNotaIni))
	endif
	conout("transmitindo notas de: " + cNotaIni + " a: " + cNotaFim )
	//---------------Tratamento para Transmisso de notas de Entrada sem SF3 --------------------//
	If SF1->(FieldPos("F1_STATUS"))>0
		dbSelectArea("SF1")
		dbSetOrder(1)
		#IFDEF TOP
			cWhere := "%( (SF1.F1_FORMUL='S' And SF1.F1_STATUS='C')) AND"
			cAliasSF1 := GetNextAlias()
			lQuery    := .T.

			If lSdoc
				cCampos += ", SF1.F1_SDOC"
				cSerie := Padr(cSerie,TamSx3("F3_SDOC")[1])

				If !Empty(dDataDe) .And. !Empty(dDataAte)
					cWhere += " SF1.F1_SDOC = '"+ SubStr(cSerie,1,3) + "' AND (SF1.F1_EMISSAO >= '"+ DtoS(dDataDe) + "' AND SF1.F1_EMISSAO <= '"+ DtoS(dDataAte) + "') %"
				Else
					cWhere += " SF1.F1_SDOC = '"+ SubStr(cSerie,1,3) + "'%"
				EndIf

			Else
				cSerie := Padr(cSerie,TamSx3("F3_SERIE")[1])
				cWhere += " SF1.F1_SERIE = '"+ cSerie + "'%"
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Campos que serao adicionados a query somente se existirem na base³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Empty(cCampos)
				cCampos := "%%"
			Else
				cCampos := "% " + cCampos + " %"
			Endif

			BeginSql Alias cAliasSF1

			COLUMN F1_EMISSAO AS DATE

			SELECT	F1_FILIAL,F1_EMISSAO,F1_NFeLETR,F1_FORMUL,F1_DOC,F1_SERIE,F1_FORNECE,F1_LOJA,F1_ESPECIE,F1_STATUS
				%Exp:cCampos%
			FROM
				%Table:SF1% SF1
			WHERE
				SF1.F1_FILIAL = %xFilial:SF1% AND
				SF1.F1_DOC >= %Exp:cNotaIni% AND
				SF1.F1_DOC <= %Exp:cNotaFim% AND
				%Exp:cWhere% AND
				SF1.%notdel%
			EndSql
			cWhere := ".T."
		#ELSE
			MsSeek(xFilial("SF1")+cNotaIni+cSerie,.T.)
		#ENDIF
		cWhere := "(F1_FORMUL='S' .And. F1_STATUS='C')"
	EndIf

	If lSdoc
		cSerId := (cAliasSF1)->F1_SDOC
	Else
		cSerId := (cAliasSF1)->F1_SERIE
	EndIf

	While !Eof() .And. xFilial("SF1") == (cAliasSF1)->F1_FILIAL .And.;
		cSerId == cSerie .And.;
		(cAliasSF1)->F1_DOC >= cNotaIni .And.;
		(cAliasSF1)->F1_DOC <= cNotaFim
	    /*
	    +------------------------------------------------------+
		|PONTO DE ENTRADA PARA VALIDAÇÃO DA TRANSMISSAO DA NOTA|
		+------------------------------------------------------+
		*/
		If lFISVALNFE
			aValNFe:={}
			Aadd(aValNFe,"E")
			Aadd(aValNFe,(cAliasSF1)->F1_FILIAL)
			Aadd(aValNFe,(cAliasSF1)->F1_EMISSAO)
			Aadd(aValNFe,(cAliasSF1)->F1_DOC)
			Aadd(aValNFe,(cAliasSF1)->F1_SERIE)
			Aadd(aValNFe,(cAliasSF1)->F1_FORNECE)
			Aadd(aValNFe,(cAliasSF1)->F1_LOJA)
			Aadd(aValNFe,(cAliasSF1)->F1_ESPECIE)
			Aadd(aValNFe,(cAliasSF1)->F1_FORMUL)
			If !ExecBlock("FISVALNFE",.F.,.F.,aValNFe)
				dbSelectArea(cAliasSF1)
				dbSkip()

				If lSdoc
					cSerId := (cAliasSF1)->F1_SDOC
				Else
					cSerId := (cAliasSF1)->F1_SERIE
				EndIf

				Loop
			EndIf
		EndIf

		dbSelectArea(cAliasSF1)
		If ((cAliasSF1)->F1_FORMUL=="S") .And. aScan(aNotas,{|x| x[3]+x[4]==(cAliasSF1)->F1_SERIE+(cAliasSF1)->F1_DOC})==0 .And. (cAliasSF1)->F1_STATUS='C'

		If !lAuto
			IncProc("(1/2) "+'STR0022'+(cAliasSF1)->F1_DOC) //"Preparando nota: "
		EndIf
			If (AModNot((cAliasSF1)->F1_ESPECIE)$"55,57" .Or. cAmbiente=="2") .And. &cWhere
				aadd(aNotas,{})
				nX := Len(aNotas)
				aadd(aNotas[nX],"0")
				aadd(aNotas[nX],(cAliasSF1)->F1_EMISSAO)
				aadd(aNotas[nX],(cAliasSF1)->F1_SERIE)
				aadd(aNotas[nX],(cAliasSF1)->F1_DOC)
				aadd(aNotas[nX],(cAliasSF1)->F1_FORNECE)
				aadd(aNotas[nX],(cAliasSF1)->F1_LOJA)
				aadd(aNotas[nX],aMotivoCont)
				aadd(aNotas[nX], SF1->F1_CHVNFE)
				If !lAuto
					aadd(aNotasOri,{})
					nX := Len(aNotasOri)

					aadd(aNotasOri[nX],(cAliasSF1)->F1_DOC)
					aadd(aNotasOri[nX],(cAliasSF1)->F1_SERIE)
				EndIf
				If lUsaColab
					aadd(aNotas[nX])		// Sera add o XML do Rdmake NF Entrada
				EndIf
			EndIf
		EndIf
		dbSelectArea(cAliasSF1)
		dbSkip()

		If lSdoc
			cSerId := (cAliasSF1)->F1_SDOC
		Else
			cSerId := (cAliasSF1)->F1_SERIE
		EndIf

	EndDo
	If lQuery
		dbSelectArea(cAliasSF1)
		dbCloseArea()
		dbSelectArea("SF1")
	EndIf

	//-----------------------------------------------------------------//
EndIf
dbSelectArea("SF3")
dbSetOrder(5)
#IFDEF TOP
	lQuery    	:= .T.
	cAliasSF3	:= GetNextAlias()
	cQuery 		:= retQueryTrans( .F., cNotaIni, cNotaFim, cSerie , cModeloNF  )
	cQuery 		:= ChangeQuery( cQuery )

	dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAliasSF3, .F., .T.)

	TcSetField(cAliasSF3,"F3_ENTRADA","D",08,0)
	TcSetField(cAliasSF3,"F3_DTCANC","D",08,0)
#ELSE
	MsSeek(xFilial("SF3")+cSerie+cNotaIni,.T.)
#ENDIF
cWhere := "((SubStr(F3_CFO,1,1) < '5' .AND. F3_FORMUL='S') .OR. (SubStr(F3_CFO,1,1) >= '5'))"

If lSdoc
	cSerId := (cAliasSF3)->F3_SDOC
Else
	cSerId := (cAliasSF3)->F3_SERIE
EndIf

While !Eof() .And. xFilial("SF3") == (cAliasSF3)->F3_FILIAL .And.;
	cSerId == cSerie .And.;
	(cAliasSF3)->F3_NFISCAL >= cNotaIni .And.;
	(cAliasSF3)->F3_NFISCAL <= cNotaFim
    /*
    +------------------------------------------------------+
	|PONTO DE ENTRADA PARA VALIDAÇÃO DA TRANSMISSAO DA NOTA|
	+------------------------------------------------------+
	*/
	If lFISVALNFE
		aValNFe:={}
		Aadd(aValNFe,IF((cAliasSF3)->F3_CFO < "5","E","S"))
		Aadd(aValNFe,(cAliasSF3)->F3_FILIAL)
		Aadd(aValNFe,(cAliasSF3)->F3_ENTRADA)
		Aadd(aValNFe,(cAliasSF3)->F3_NFISCAL)
		Aadd(aValNFe,(cAliasSF3)->F3_SERIE)
		Aadd(aValNFe,(cAliasSF3)->F3_CLIEFOR)
		Aadd(aValNFe,(cAliasSF3)->F3_LOJA)
		Aadd(aValNFe,(cAliasSF3)->F3_ESPECIE)
		Aadd(aValNFe,(cAliasSF3)->F3_FORMUL)
		If !ExecBlock("FISVALNFE",.F.,.F.,aValNFe)
			dbSelectArea(cAliasSF3)
			dbSkip()

			If lSdoc
				cSerId := (cAliasSF3)->F3_SDOC
			Else
				cSerId := (cAliasSF3)->F3_SERIE
			EndIf

			Loop
		EndIf
	EndIf

	dbSelectArea(cAliasSF3)
	If (SubStr((cAliasSF3)->F3_CFO,1,1)>="5" .Or. (cAliasSF3)->F3_FORMUL=="S") .And. aScan(aNotas,{|x| x[3]+x[4]==(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_NFISCAL})==0 .And. ;
		( Val( (cAliasSF3)->F3_NFISCAL ) >= Val( cNotaIni ) .And. Val ( (cAliasSF3)->F3_NFISCAL ) <= Val( cNotaFim ) )

		If (!lCTe) .And. !lAuto
			IncProc("(1/2) "+'STR0022'+(cAliasSF3)->F3_NFISCAL) //"Preparando nota: "
		EndIf

		If (AModNot((cAliasSF3)->F3_ESPECIE)$"55,57" .Or. cAmbiente=="2") .And. Empty((cAliasSF3)->F3_DTCANC);
			.And. &cWhere
			If !AModNot((cAliasSF3)->F3_ESPECIE)$"59,60,65"

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³No caso de Nota Fiscal sobre cupom (SIGALOJA)³
				//³busca os dados do registro original.         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ( cNfCup $ (cAliasSF3)->F3_OBSERV .or. ( cFsimpFat $ (cAliasSF3)->F3_OBSERV ) ) //.AND. !LjAnalisaLeg(53)[1]
					LjVerNfCup(@aNotas		,cAliasSF3,@aNfCup,.T.,;
								aMotivoCont	)
					//Grava doc Original da Transmissão da NF-e
					aadd(aNotasOri,{})
					nX := Len(aNotasOri)

					aadd(aNotasOri[nX],(cAliasSF3)->F3_NFISCAL)
					aadd(aNotasOri[nX],(cAliasSF3)->F3_SERIE)
				Else
					aadd(aNotas,{})
					nX := Len(aNotas)
					aadd(aNotas[nX],IIF((cAliasSF3)->F3_CFO<"5","0","1"))
					aadd(aNotas[nX],(cAliasSF3)->F3_ENTRADA)
					aadd(aNotas[nX],(cAliasSF3)->F3_SERIE)
					aadd(aNotas[nX],(cAliasSF3)->F3_NFISCAL)
					aadd(aNotas[nX],(cAliasSF3)->F3_CLIEFOR)
					aadd(aNotas[nX],(cAliasSF3)->F3_LOJA)
					aadd(aNotas[nX],aMotivoCont)
					
					SF2->( dbSetOrder(1) )
					if( SF2->(MsSeek(xFilial("SF2")+ (cAliasSF3)->F3_NFISCAL + (cAliasSF3)->F3_SERIE + (cAliasSF3)->F3_CLIEFOR + (cAliasSF3)->F3_LOJA,.T.)) )
						aadd(aNotas[nX], SF2->F2_CHVNFE)
					endif
					
					If !lAuto
						aadd(aNotasOri,{})
						nX := Len(aNotasOri)
						aadd(aNotasOri[nX],(cAliasSF3)->F3_NFISCAL)
						aadd(aNotasOri[nX],(cAliasSF3)->F3_SERIE)
					EndIf
					If lUsaColab
						aadd(aNotas[nX])		// Sera add o XML do Rdmake NF Saida
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
	dbSelectArea(cAliasSF3)
	dbSkip()

	If lSdoc
		cSerId := (cAliasSF3)->F3_SDOC
	Else
		cSerId := (cAliasSF3)->F3_SERIE
	EndIf

EndDo
If lQuery
	dbSelectArea(cAliasSF3)
	dbCloseArea()
	dbSelectArea("SF3")
EndIf
If (!lCTe) .And. !lAuto
	ProcRegua(Len(aNotas))
EndIf

If lAuto
	//NfeVldAuto(@aNotas,cAlias)
EndIf

If lUsaColab
	oDoc := ColaboracaoDocumentos():new()
	oDoc:cModelo 	:= IIF(lCTE,"CTE","NFE")
	oDoc:cTipoMov	:= "1"
Else
	oWs:= WsNFeSBra():New()
	oWs:cUserToken := "TOTVS"
	oWs:cID_ENT    := cIdEnt
	oWS:_URL       := AllTrim(cURL)+"/NFeSBRA.apw"
	oWs:oWsNFe:oWSNOTAS :=  NFeSBRA_ARRAYOFNFeS():New()
EndIf
For nX := 1 To Len(aNotas)

	cXmlConEsp	:= ""

	if( len(aNotas[nX]) < 8 )
		aadd(aNotas[nX],"")
	endif
	setDocChv(aNotas[nX][8])
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	//³                        Agroindustria                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If FindFunction("OGXUtlOrig") //Encontra a função
		If OGXUtlOrig() // Retorna se tem integração com Agro/originação modulo 67
			If FindFunction("AGRXVALNFE") .AND. !AGRXVALNFE(aNotas[nX][3],aNotas[nX][4], @aErro)
				LOOP //não faz a transmissão da NF
			EndIf
		EndIf
	EndIf

	If lUsaColab

		oDoc:cIdErp	:= aNotas[nX][3]+ aNotas[nX][4]+cGrupo+cFil
		lErro := .F.

		lRetCons := oDoc:consultar()

		If lRetCons
			If !Empty(oDoc:cXMLRet)
				cXml	:= oDoc:cXMLRet
			Else
				cXml	:= oDoc:cXml
			EndIf
			aDados := ColDadosNf(1,IIF(lCTE,"57","55"))
			aDadosXml := ColDadosXMl(cXml, aDados, @cErro, @cAviso)

			If len(aDadosXml) > 0

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Validacao para verificar se a NF ja foi autorizada e nao permitir a retransmissao ³
				//³ OU a NF foi retornada que a operacao esta em contingencia                        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If  ( ColMsgSefaz(oDoc:cModelo,aDadosXml[1]) .And. !Empty(aDadosXml[3]) ) .OR. ( aDadosXml[1]="1" .And. Empty(aDadosXml[3]) )
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Valida se o documento tem Protocolo, caso nao tenha significa que eh Contingencia³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !Empty( aDadosXml[3] )
						cMsgErr := ColGetErro(21)[2]
					Else
						cMsgErr := ColGetErro(22)[2]
					EndIf
					lErro := .T.

				ElseIf oDoc:cCdStatDoc == "1"
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Valida se o documento ja foi Enviado	³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cMsgErr := ColGetErro(4)[2]
					lErro := .T.
				EndIf

				If lErro
					aAdd( aErro , {} )
					aAdd( aErro[Len(aErro)] , .T. )	         //Tem erro
					aAdd( aErro[Len(aErro)] , aNotas[nX][4] ) 	//NF
					aAdd( aErro[Len(aErro)] , aNotas[nX][3] ) 	//Serie
					aAdd( aErro[Len(aErro)] , cMsgErr ) 		//Motivo
				endif

			EndIf
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso seja SCAN, e a Serie da NFe for menor que 900-999 nao eh transmitida NFe ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lTermScan .And. ( !(Len(aErro) > 0) .Or. !lRetCons )
		If (!lCTe) .And. !lAuto
			IncProc("(2/2) "+'STR0023'+aNotas[nX][4]) //"Transmitindo XML da nota: "
		EndIf

		//-- Parametro do
		If lTMSCTe .And. lCTe
			If ExistBlock("XmlCte3",,.T.)
				aXml := ExecBlock("XmlCte3",.F.,.F.,{aNotas[nX], cAmbiente, cVersao, cModalidade, TZoneUTC(cIdEnt)})
			EndIf
		Else
			If (Empty (aNfCup))
				nTemp := aScan( aNotasOri, { | x | x[1] == aNotas[nX][4] .and. x[2] == aNotas[nX][3] } )
			Else
				nTemp := nX
			EndIf
			if nTemp < 1
				loop
			endif
			If !lAuto
				aXml	:= ExecBlock("XmlNFeSef",.F.,.F.,{aNotas[nX],cVersao,cAmbiente,aNotasOri[nTemp]})
			ElseIf lAuto .and. lUsaColab													 //  nNF			Serie
				aXml	:= ExecBlock("XmlNFeSef",.F.,.F.,{aNotas[nX],cVersao,cAmbiente,{aNotas[nX][4],aNotas[nX][3]}})
			Else
				aXml	:= ExecBlock("XmlNFeSef",.F.,.F.,{aNotas[nX],cVersao,cAmbiente,{"",""}})
			EndIf
		EndIf

		If aXML <> Nil
			nXmlSize2 := Len(aXML[2])

			nPosAux := Ascan( aNfCup,{|x| x[7] == aNotas[nX][3] .AND. x[8] == aNotas[nX][4]})

			If nPosAux > 0
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Caso encontre alguma Nf sobre cupom volta a numeração³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				LjVerNfCup(@aNotas[nX], NIL , aNfCup[nPosAux] , .F. )
			EndIf

			If  Len(aXML)==4 .And.!Empty (aXML[3]) .And. !Empty (aXML[4])
				aNotas[nX][4]:= aXML[3]
				aNotas[nX][3]:= aXML[4]
				If ( lUsaColab .And. !Empty (aXML[2]) )
					aNotas[nX][8] := aXML[2]
				EndIf

		   	EndIF

			If !Empty(aXML[2]) .And. nXmlSize2 <= TAMMAXXML
				If nXmlSize + Len(aXML[2]) <= TAMMAXXML
					nY++
					nNFes++
					nXmlSize += Len(aXML[2])
					If lUsaColab			//   ID ERP(Serie+NF+Emp+Fil)      Erro     XML		 Entr/Saida	    Serie				NF				Cliente		   Loja							 Retorno da Transmissao

						lRetorno := XMLRemCol(aXml[4]+aXml[3]+cGrupo+cFil , @cErro , aXml[2] , aNotas[nX][1] , aNotas[nX][3] , aNotas[nX][4] , aNotas[nX][5] , aNotas[nX][6] , @nXmlSize , nY , @aRetCol, @cXmlConEsp)

						If lRetorno .And. lMvColESP
							lEspelho := XmlColEsp(aNotas[nX][4],aNotas[nX][3],aNotas[nX][5],aNotas[nX][6],aXml[4]+aXml[3]+cGrupo+cFil,cXmlConEsp,@cErroEsp)
							If !lEspelho
								cErro += cErroEsp + CRLF + CRLF
							EndIf
						EndIf

					Else
						aadd(oWs:oWsNFe:oWSNOTAS:oWSNFeS,NFeSBRA_NFeS():New())

						aadd(aRetNotas,aNotas[nX])

						oWs:oWsNFe:oWSNOTAS:oWsNFes[nY]:cID := aNotas[nX][3]+aNotas[nX][4]
						oWs:oWsNFe:oWSNOTAS:oWsNFes[nY]:cXML:= aXML[2]
					EndIf
				Else
					If lUsaColab			//   ID ERP(Serie+NF+Emp+Fil)      Erro     XML		 Entr/Saida	    Serie				NF				Cliente		   Loja							 Retorno da Transmissao

						lRetorno := XMLRemCol(aXml[4]+aXml[3]+cGrupo+cFil , @cErro , aXml[2] , aNotas[nX][1] , aNotas[nX][3] , aNotas[nX][4] , aNotas[nX][5] , aNotas[nX][6] , @nXmlSize , nY , @aRetCol, @cXmlConEsp)

						If lRetorno .And. lMvColESP
							lEspelho := XmlColEsp(aNotas[nX][4],aNotas[nX][3],aNotas[nX][5],aNotas[nX][6],aXml[4]+aXml[3]+cGrupo+cFil,cXmlConEsp,@cErroEsp)
							If !lEspelho
								cErro += cErroEsp + CRLF + CRLF
							EndIf
						EndIf
					Else
						lRetorno := XMLRemessa(@oWs,@cErro,@aRetNotas,@nY,@nXmlSize,cIdEnt,cURL,lAuto,aXml[4]+aXml[3]+cGrupo+cFil)
						If !lRetorno
							Exit
						EndIf
						nX -- //- Diminui o contador para que seja pego a nota corrente
						Loop
					EndIf
				EndIF
			ElseIf !Empty(aXML[2]) .And. nXmlSize2 > TAMMAXXML
				If !lAuto
					Aviso("SPED",'STR0149'+ "("+cValToChar(nXmlSize2)+" Caracteres )"+CRLF+CRLF+'STR0150'+aNotas[nX][4]+" / "+aNotas[nX][3],{'STR0114'},3)
				Else
					If !lAutomato
						Conout("SPED",'STR0149'+ "("+cValToChar(nXmlSize2)+" Caracteres )"+CRLF+CRLF+'STR0150'+aNotas[nX][4]+" / "+aNotas[nX][3],{'STR0114'},3)
					Else
			   			If FindFunction("GetParAuto")
							aRetAuto	 := GetParAuto("AUTONFETestCase")
							aRetAuto[5]:= .F.
							aRetAuto[6]:="SPED "+'STR0149'+ "("+cValToChar(nXmlSize2)+" Caracteres )"+CRLF+CRLF+'STR0150'+aNotas[nX][4]+" / "+aNotas[nX][3]
							aRetAuto[7]:=nXmlSize2
							aRetAuto[8]:=TAMMAXXML
						EndIf
						Conout("SPED",'STR0149'+ "("+cValToChar(nXmlSize2)+" Caracteres )"+CRLF+CRLF+'STR0150'+aNotas[nX][4]+" / "+aNotas[nX][3],{'STR0114'},3)
					EndIf
				EndIf
				nXmlSize2 := 0
			EndIf
			If  lMvColESP .And. nNFes > 0 .And. !lUsaColab
				XMLRemessa(@oWs,@cErro,@aRetNotas,@nY,@nXmlSize,cIdEnt,cURL,lAuto,aXml[4]+aXml[3]+cGrupo+cFil)
			ElseIf ((nY >=50 .Or. nX == Len(aNotas) .Or. nXmlSize>=TAMMAXXML) .And. nNFes > 0) .And. !lUsaColab
				XMLRemessa(@oWs,@cErro,@aRetNotas,@nY,@nXmlSize,cIdEnt,cURL,lAuto,aXml[4]+aXml[3]+cGrupo+cFil)
			EndIf
		EndIf
	EndIf
Next nX

If lUsaColab

	If ( Len(aErro) > 0 )
		For nZ	:= 1 to Len(aErro)
			If aErro[nZ][1] == .T.	//Retornado .T. no caso tem erro.
				cErro += "NFe:    " + aErro[nZ][2] + CRLF +;
					      "Série:  " + SubStr(aErro[nZ][3],1,3) + CRLF +;
				    	  "Motivo: " + aErro[nZ][4] + CRLF + CRLF
				lErro := .T.
			EndIf
		Next nZ
		nZ	:= 0
	EndIf
	If ( Len(aRetCol) > 0 )
		For nZ := 1 to Len(aRetCol)

			If aRetCol[nZ][1] == .F.	//Retornado .F. no caso tem erro, pois o .T. eh qdo o documento foi processado com sucesso.
				cErro += "NFe:    " + aRetCol[nZ][3] + CRLF +;
					      "Série:  " + SubStr(aRetCol[nZ][2],1,3) + CRLF +;
					      "Motivo: " + aRetCol[nZ][6] + CRLF + CRLF
				lErro := .T.
			Else
				lNaoErro := .T.
				nNFtrans ++
			EndIf
		Next nZ
	EndIf

	If ( lNaoErro .And. lErro )
		cRetorno := 'STR0491'+CRLF 		//"Você concluíu com sucesso a geração do arquivo para transmissão via TOTVS Colaboração."
		cRetorno += 'STR0492'+CRLF+CRLF //"Verifique se os arquivos foram processados e autorizados na SEFAZ via TOTVS Colaboração, utilizando a rotina 'Monitor'. Antes de imprimir a DANFe."
		cRetorno += 'STR0028'+AllTrim(Str(nNFtrans,18))+'STR0029'+IntToHora(SubtHoras(dDataIni,cHoraIni,Date(),Time()))+CRLF+CRLF //"Foram transmitidas "###" nota(s) em "
		//Erro na geracao
		cRetorno += "---------------------------------------------------------------------------------------------------------------------------" + CRLF
		cRetorno += 'STR0490'+CRLF+CRLF //"Houve um erro durante a geração do arquivo para transmissão via TOTVS Colaboração."
		cRetorno += 'STR0024'+CRLF+CRLF 	//"As notas abaixo foram recusadas, verifique a rotina 'Monitor' para saber os motivos."
	ElseIf lErro
		cRetorno := 'STR0490'+CRLF+CRLF //"Houve um erro durante a geração do arquivo para transmissão via TOTVS Colaboração."
		cRetorno += 'STR0024'+CRLF+CRLF 	//"As notas abaixo foram recusadas, verifique a rotina 'Monitor' para saber os motivos."
	Else
		cRetorno := 'STR0491'+CRLF 		//"Você concluíu com sucesso a geração do arquivo para transmissão via TOTVS Colaboração."
		cRetorno += 'STR0492'+CRLF+CRLF //"Verifique se os arquivos foram processados e autorizados na SEFAZ via TOTVS Colaboração, utilizando a rotina 'Monitor'. Antes de imprimir a DANFe."
		cRetorno += 'STR0028'+AllTrim(Str(nNFtrans,18))+'STR0029'+IntToHora(SubtHoras(dDataIni,cHoraIni,Date(),Time()))+CRLF+CRLF //"Foram transmitidas "###" nota(s) em "
	EndIf
	lErro := .F.
Else
	If lRetorno
		cRetorno := 'STR0026'+CRLF //"Você concluíu com sucesso a transmissão do Protheus para o Totvs Services SPED."
		cRetorno += 'STR0027'+CRLF+CRLF //"Verifique se as notas foram autorizadas na SEFAZ, utilizando a rotina 'Monitor'. Antes de imprimir a DANFe."
		cRetorno += 'STR0028'+AllTrim(Str(nNFes,18))+'STR0029'+IntToHora(SubtHoras(dDataIni,cHoraIni,Date(),Time()))+CRLF+CRLF //"Foram transmitidas "###" nota(s) em "
	Else
		cRetorno := 'STR0030'+CRLF+CRLF //"Houve erro durante a transmissão para o Totvs Services SPED."
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Contingencia SCAN - Exibe mensagem que nao foi transmitida NFe  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cModalidade = "3" .And. !lUsaColab
	cErroScan   := 'STR0079'+": "+ "Série utilizada fora da faixa permitida no Ambiente SCAN (900-999)"
	cErroScan += cErroScan+CRLF+CRLF
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Exibicao do range de NFe nao transmitidas						³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 To Len(aNotas)

		cRetorno += "Segue abaixo a NF-e não transmitida: "  	+CRLF
		cRetorno += 'STR0249' + ": " + SubStr(aNotas[nX][3],1,3) 	+CRLF 		//"Serie"
		cRetorno += 'STR0049' + ": " + aNotas[nX][4] 				+CRLF+CRLF //"NF"

	Next nX


Else
	cRetorno += cErro + cErroScan
EndIf


If (!lCTe) .And. !lAuto
	IF VALTYPE(bFiltraBrw) == "B"
		Eval(bFiltraBrw)
	ENDIF
EndIf
RestArea(aArea)

Return(cRetorno)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³XMLRemessa³ Autor ³ Gustavo. G. Rueda     ³ Data ³24.03.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao responsavel pela envio do XML ao TSS                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function XMLRemessa(oWs,cErro,aRetNotas,nTotNf,nXmlSize,cIdEnt,cURL,lAuto,cIdErp)
Local nY
Local lRetorno	:= .T.
Local lTransmitida	:= .F.
Local cXmlTSSEsp		:= ""
Local lMvColESP		:= SuperGetMv( "MV_COLESP", .F., .F. )
Local lEspelho		:= .F.
Local cErroEsp 		:= ""

Default lAuto	:= .F.
Default cIdErp	:= ""

If nXmlSize>0 .And. oWs:Remessa()
	If Len(oWs:oWsRemessaResult:oWSID:cString) <> nTotNF
		cErro := 'STR0024'+CRLF+CRLF //"As notas abaixo foram recusadas, verifique a rotina 'Monitor' para saber os motivos."
	EndIf
	For nY := 1 To Len(aRetNotas)

		lTransmitida := aScan(oWs:oWsRemessaResult:oWSID:cString,aRetNotas[nY][3]+AllTrim(aRetNotas[nY][4])) > 0

		//Grava na F3_CODRET = T |Transmitido|se existir o campo na SF3
			gravaCodRet( aRetNotas[nY] )

		If Len(oWs:oWsRemessaResult:oWSID:cString) <> nY
			If !lTransmitida
				cErro += "NFe: "+aRetNotas[nY][3]+aRetNotas[nY][4]+CRLF
			EndIf
			If aScan(oWs:oWsRemessaResult:oWSID:cString,aRetNotas[nY][3]+aRetNotas[nY][4])==0 .and. lMvColESP
				cErro += "NFe: "+aRetNotas[nY][3]+aRetNotas[nY][4]+CRLF
			EndIf
		EndIf
		If aRetNotas[nY][1] == "0"
			If SF1->(FieldPos("F1_FIMP"))>0
				dbSelectArea("SF1")
				dbSetOrder(1)
				If MsSeek(xFilial("SF1")+aRetNotas[nY][4]+aRetNotas[nY][3]+aRetNotas[nY][5]+aRetNotas[nY][6]) .And. SF1->F1_FIMP$"N, "
					RecLock("SF1")
					SF1->F1_FIMP := IIF(lTransmitida,"T","N")
					MsUnlock()
				EndIf
			EndIf
		Else
			dbSelectArea("SF2")
			dbSetOrder(1)
 			If MsSeek(xFilial("SF2")+aRetNotas[nY][4]+aRetNotas[nY][3]+aRetNotas[nY][5]+aRetNotas[nY][6]) .And. SF2->F2_FIMP$"N, "
				RecLock("SF2")
				SF2->F2_FIMP := IIF(lTransmitida,"T","N")
				MsUnlock()
			EndIf
		EndIf

		//Geracao do espelho da nota apos transmissão do TSS
		If lTransmitida .And. lMvColESP
			cXmlTSSEsp	:= RetXmlNFe(cIdEnt, aRetNotas[nY][3]+aRetNotas[nY][4] )
			lEspelho := XmlColEsp(aRetNotas[nY][4],aRetNotas[nY][3],aRetNotas[nY][5],aRetNotas[nY][6],cIdErp,cXmlTSSEsp,@cErroEsp)
			If!lEspelho
				cErro += cErroEsp + CRLF + CRLF
			EndIf
		EndIf

	Next nY

	If ExistBlock("FISENVNFE")
		ExecBlock("FISENVNFE",.F.,.F.,{oWs:oWsRemessaResult:oWSID:cString})
	EndIf

	oWs:= WsNFeSBra():New()
	oWs:cUserToken := "TOTVS"
	oWs:cID_ENT    := cIdEnt
	oWS:_URL       := AllTrim(cURL)+"/NFeSBRA.apw"
	oWs:oWsNFe:oWSNOTAS :=  NFeSBRA_ARRAYOFNFeS():New()
	nTotNF := 0
	nXmlSize := 0
	aRetNotas := {}
Else
	cErro := GetWscError(3)
	DEFAULT cErro := 'STR0025' //"Erro indeterminado"
	lRetorno := .F.
EndIf
Return lRetorno



Static Function GetIdEnt(lUsaColab)

local cIdEnt := ""
local cError := ""

Default lUsaColab := .F.

If !lUsaColab

	cIdEnt := getCfgEntidade(@cError)

	if(empty(cIdEnt))
		Aviso("SPED", cError, {'STR0114'}, 3)

	endif

else
	if !( ColCheckUpd() )
		Aviso("SPED","UPDATE do TOTVS Colaboração 2.0 não aplicado. Desativado o uso do TOTVS Colaboração 2.0",{'STR0114'},3)
	else
		cIdEnt := "000000"
	endif
endIf

Return(cIdEnt)



//-------------------------------------------------------------------
/*/{Protheus.doc} gravaCodRet
Grava flag de transmissao Auto NF-e

@author  Sergio S. Fuziaka
@since   10/02/2014
@version 12
/*/
//-------------------------------------------------------------------
static function gravaCodRet( aRetNotas )

local aArea 	:= GetArea()
local aAreaSF3	:= SF3->(GetArea())
local lContinua	:= .F.

If SF3->(FieldPos("F3_CODRET")) > 0
	//---------------------------------------------------------
	// Validacao Array
	//---------------------------------------------------------
	if ( len(aRetNotas) > 0 )
		if ( len(aRetNotas[3]) > 0 )
			if ( len(aRetNotas[4]) > 0 )
				if ( len(aRetNotas[5]) > 0 )
					if ( len(aRetNotas[6]) > 0 )
						lContinua := .T.
					endif
				endif
			endif
		endif
	endif
	//---------------------------------------------------------
	// Realizado alteracao para atualizar todos os registros
	// da SF3 para aquele documento.
	// @data: 24/08/2018 @autor: Douglas Parreja
	//---------------------------------------------------------
	if lContinua
	SF3->( dbSetOrder(4) )
		if ( SF3->( dbSeek( xFilial("SF3")+aRetNotas[5]+aRetNotas[6]+aRetNotas[4]+aRetNotas[3])) )
			while ( !SF3->(eof()) .and. ;
				SF3->(F3_CLIEFOR) == aRetNotas[5] .and. ;
					SF3->(F3_LOJA) == aRetNotas[6] .and. ;
						SF3->(F3_NFISCAL) == aRetNotas[4] .and. ;
							SF3->(F3_SERIE) == aRetNotas[3] .and. ;
								alltrim(SF3->F3_CODRET) <> "T" )
				SF3->(recLock("SF3",.F.))
		SF3->F3_CODRET := "T"	// Transmitido
				SF3->(msUnlock())
				SF3->(dbSkip())
			endDo
		endif
	Endif
Endif

RestArea( aAreaSF3 )
RestArea( aArea )

return



//AADD( arrOrig, {cFilPed, cDocWMS, cSerWMS, cITEWMS, cCliente, cLojaCli, cProduto, cCodLote, oItens[n1]["c6_local"], oItens[n1]["c6_qtdven"], oItens[n1]["c6_prcven"]  } )

Static Function getRecnoSD2(array)

Local cQry
Local retorno 

    cQry := " SELECT * FROM SD2010 " 
	cQry += " WHERE D_E_L_E_T_ <> '*' AND D2_FILIAL = '" + array[1] + "' AND D2_DOC = '" + array[2] + "' "
	cQry += "       AND D2_SERIE = '" + ALLTRIM(array[3]) + "' AND D2_COD = '" + ALLTRIM(array[7]) + "' "
	//cQry += "       AND D2_LOTECTL = '" + ALLTRIM(array[8]) + "' "
//RETIRADO POR IATAN EM 17/11/2022 A PEDIDO DE TIAGO
//	cQry += "       AND D2_PRCVEN = " + ALLTRIM(STR(array[11]))
//IATAN EM 17/11/2022
//IATAN EM 13/12/2022 ALTERADO DE D2_ITEMPV PARA D2_ITEM
	cQry += "       AND D2_ITEM = '" + ALLTRIM(array[4]) + "' "

	CONOUT("CONSULTA.: " + cQry)

	TCQuery cQry New Alias "QRY_SD2"
	
	QRY_SD2->(DbGoTop())

	While ! QRY_SD2->(Eof())

        retorno := QRY_SD2->R_E_C_N_O_
		CONOUT("R_E_C_N_O_ DA SD2 --> " + CVALTOCHAR(QRY_SD2->R_E_C_N_O_ ) )
		SD2->(DBGOTO(QRY_SD2->R_E_C_N_O_))

		QRY_SD2->(DbSkip())
	EndDo

	QRY_SD2->(DbCloseArea())

	

Return retorno



Static Function getRetSC6(array, filial, pedido)

Local cQry
Local tmp := {}
Local oJsonResponse	As Object

    cQry := " SELECT * FROM SC6010 " 
	cQry += " WHERE D_E_L_E_T_ <> '*' AND C6_FILIAL = '" + filial + "' AND C6_NUM = '" + pedido + "' "

	TCQuery cQry New Alias "QRY_SC6"
	
	QRY_SC6->(DbGoTop())

	While ! QRY_SC6->(Eof())

		oJsonResponse := JsonObject():New()
		oJsonResponse['filial']	 := QRY_SC6->C6_FILIAL
		oJsonResponse['pedido']	 := QRY_SC6->C6_NUM
		oJsonResponse['produto'] := QRY_SC6->C6_PRODUTO
		oJsonResponse['item']	 := QRY_SC6->C6_ITEM
		oJsonResponse['valor_unitario']	 := QRY_SC6->C6_PRCVEN
		oJsonResponse['quantidade']	 := QRY_SC6->C6_QTDVEN

		AADD(array, oJsonResponse )

		QRY_SC6->(DbSkip())
	EndDo

	QRY_SC6->(DbCloseArea())

	

Return 



Static Function getLocalNFOrigem(filial, documento, serie, item)

Local cQry
Local retorno 

    cQry := " SELECT * FROM SD2010 " 
	cQry += " WHERE D_E_L_E_T_ <> '*' AND D2_FILIAL = '" + filial + "' AND D2_DOC = '" + documento + "' "
	cQry += "       AND D2_SERIE = '" + serie + "' AND D2_ITEM = '" + item + "' "

	CONOUT("CONSULTA ( getLocalNFOrigem ).: " + cQry)

	TCQuery cQry New Alias "QRY_SD2"
	
	QRY_SD2->(DbGoTop())

	While ! QRY_SD2->(Eof())

        retorno := QRY_SD2->D2_LOCAL

		QRY_SD2->(DbSkip())
	EndDo

	QRY_SD2->(DbCloseArea())

Return retorno



//IATAN EM 23/02/2023
//Static Function validaSaldo( quantidade, documento, serie, item)
Static Function validaSaldo( filial, quantidade, documento, serie, item)

Local cQry := ''
Local retorno  := ''

    cQry := " SELECT D2_QUANT - (SELECT SUM(D1_QUANT) FROM SD1010 WHERE D_E_L_E_T_ <> '*' AND D1_FILIAL = D2_FILIAL AND D1_NFORI = D2_DOC AND D1_SERIORI = D2_SERIE AND D1_ITEMORI = D2_ITEM ) AS SLDDEV, "
	cQry += "   (SELECT STRING_AGG(CONVERT(varchar, D1_DOC), ', ') FROM SD1010 WHERE D_E_L_E_T_ <> '*' AND D1_FILIAL = D2_FILIAL AND D1_NFORI = D2_DOC AND D1_SERIORI = D2_SERIE AND D1_ITEMORI = D2_ITEM ) AS NFSDEV "
	cQry += " FROM SD2010 "
	cQry += " WHERE D_E_L_E_T_ <> '*' AND D2_FILIAL = '" + filial + "' AND D2_DOC = '" + DOCUMENTO + "' AND D2_SERIE = '" + SERIE + "' AND D2_ITEM = '" + ITEM + "' "
//	cQry += " WHERE D_E_L_E_T_ <> '*' AND D2_FILIAL = '" + CFILANT + "' AND D2_DOC = '" + DOCUMENTO + "' AND D2_SERIE = '" + SERIE + "' AND D2_ITEM = '" + ITEM + "' "


	CONOUT("CONSULTA ( validaSaldo ).: " + cQry)

	TCQuery cQry New Alias "QRY_VLD"
	
	QRY_VLD->(DbGoTop())

	While ! QRY_VLD->(Eof())

		CONOUT("Qtd a ser Devolvida.: " + CVALTOCHAR(quantidade) )
		CONOUT("Saldo a ser Devolvido.: " + CVALTOCHAR(QRY_VLD->SLDDEV ) )
		CONOUT("QRY_VLD->SLDDEV < quantidade.: " + CVALTOCHAR(QRY_VLD->SLDDEV < quantidade) )

        IF  QRY_VLD->SLDDEV < quantidade 

			retorno := QRY_VLD->NFSDEV
			//CONOUT("retorno.: " + retorno)
			//CONOUT("retorno.: " + CVALTOCHAR(retorno))

		ENDIF

		QRY_VLD->(DbSkip())
	EndDo

	QRY_VLD->(DbCloseArea())

	CONOUT("retorno.: " + retorno)
Return retorno
