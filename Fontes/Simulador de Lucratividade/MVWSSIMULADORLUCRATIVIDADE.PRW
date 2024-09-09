#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

#INCLUDE "MATXDEF.CH"


/*/{Protheus.doc} 

@author 
@since  
@version 
  _____   ______   _____  _______
 |  __ \ |  ____| / ____||__   __|
 | |__) || |__   | (___     | |
 |  _  / |  __|   \___ \    | |
 | | \ \ | |____  ____) |   | |
 |_|  \_\|______||_____/    |_|


TODO
	[ ] - Habilitar LOGs
	[ ] - Segregar funções
	[ ] - FreeObj  e  Variaveis NIL
	[ ] - QueryParam na WSINTAX
	[ ] - 
/*/

WSRESTFUL SIMULADOR DESCRIPTION "API para Integracao do Simulador de Margem Liquida no Protheus." //SECURITY "WSRESTDBLIGACAO" FORMAT "APPLICATION_JSON" SSL_ONLY
	
	WSMETHOD POST SIMULADOR DESCRIPTION "Método para Simular Calculo de Impostos." ;
	                        WSSYNTAX "/Simulador/api/v1/simulador" ;
							PATH "/Simulador/api/v1/simulador"     ;
							TTALK "v1"
	WSMETHOD GET SIMULADOR DESCRIPTION "Método para Consultar." ;
		                      WSSYNTAX "/Simulador/api/v1/simulador" ; 
							  PATH "/Simulador/api/v1/simulador" ;
							  TTALK "v1" 

END WSRESTFUL

WSMETHOD GET SIMULADOR WSRECEIVE nullparam WSRESTFUL SIMULADOR
Local lOk     := .T.
Local cBody   := HTTPGetBody()
Local aFil    := iif(Empty(Self:GetHeader("tenantid")),Nil,StrTokArr(Self:GetHeader("tenantid"),","))
Local jJsonFJ := JsonObject():New()
Local oRet    := JsonObject():New()

	::SetContentType("application/json")	// define o tipo de retorno do mÈtodo

	BEGIN SEQUENCE


		jJsonFJ:FromJson(cBody)

		cCliente  := jJsonFJ[ 'cliente']
		cLoja     := jJsonFJ[ 'loja']
		cTipo     := jJsonFJ[ 'tipo']
		cProduto  := jJsonFJ[ 'produto']
		cTes      := jJsonFJ[ 'tes']
		nQtd      := jJsonFJ[ 'quantidade']
		nPrc      := jJsonFJ[ 'preco']
		
		nValor    := nQtd * nPrc

		/*
		cCliente  := "009319"
		cLoja     := "0001"
		cTipo     := "R"
		cProduto  := "CV-AS186-1046"
		cTes      := "558"
		nQtd      := 1
		nPrc      := 100
		nValor    := 100
		*/

		aImpostos := {}

		nImpostoValTot := 0

		VarInfo( "TES 1", cTes )

		cTes := MaTesInt( 2, "01", cCliente, cCliente, "C", cProduto ) // , "C6_TES", cTipoCli, cEstOrig, cOrigem)

		VarInfo( "TES 2", cTes )

		oImposto := FIMPOSTOS(cCliente,cLoja,cTipo,cProduto,cTes,nQtd,nPrc,nValor, @nImpostoValTot,aFil)

/*
		For nCntFor = 1 to Len( aImpostos )



			lTemImpostoCalculado := aImpostos[ nCntFor + 3 ]   >  0
			If lTemImpostoCalculado

				cImposto :=  aImpostos[ nCntFor + 2 ] 
				nAliquota :=  aImpostos[ nCntFor + 4 ] 
				nBaseImposto :=  aImpostos[ nCntFor + 5 ] 

			EndIf
		Next nCntFor
*/
		oRet[ 'cliente' ]    := cCliente
		oRet[ 'loja' ]       := cCliente
		oRet[ 'tipo' ]       := cTipo
		oRet[ 'produto' ]    := cProduto
		oRet[ 'tes' ]        := cTes
		oRet[ 'quantidade' ] := nQtd
		oRet[ 'preco' ]      := nPrc
		oRet[ 'valor' ]      := nValor


    	oRet[ 'impostos' ]   := oImposto

		oRet[ 'valor_impostos'] := nImpostoValTot


		cTipoCli  := GetAdvFval( "SA1","A1_TIPOCLI", FWxFilial("SA1") + cCliente + CLoja,1, "F" )
		cEstOrig := "RS"

		cTes := MaTesInt( 2, "01", cCliente, cCliente, "C", cProduto ) // , "C6_TES", cTipoCli, cEstOrig, cOrigem)

		/*
		oRet['impostos'] := aImpostos
		cJson := FwNoAccent(FWJsonSerialize(oRet, .F., .T., .T.))
		*/

    	cJson := oRet:ToJson()   

		::SetStatus(200) 
		::setResponse( cJson )

		/*
		ValRequisicao( cBody, jJson, lErro, lOk, jJsonFJ )
		MsgRestFault( cErrorMessage, @lErro, @lOk, cDescErro, cDetailMsg )	
		*/

	END SEQUENCE

	/*
	HTTPSetStatus(200, "OK")
	lOk := .T.
	HTTPSetStatus(200, "OK")
	*/


Return lOk


WSMETHOD POST SIMULADOR WSRECEIVE nullparam WSSERVICE SIMULADOR

Local lOK           := .T.
Local cErrorMessage := ""
Local cDetailMsg    := ""
Local cDescErro     := ""
Local lErro         := .F.


Local cBody         := Self:GetContent() 
Local aFil          //:= {Self:GetHeader("tenantid")}//iif(Empty(Self:GetHeader("tenantid")),Nil,StrTokArr(Self:GetHeader("tenantid"),","))
Local cJson         := ""
Local oRet          := JsonObject():New()
Local oJson         := NIL
Local cHttpStatus   := ""
Local cMsgRetorno   := ""

Local aDados        := {}
Local oDados        := JsonObject():New()
Local jJsonFJ       := JsonObject():New()
Local jJson         := NIL

Local cFwLogMsg     := ""
Local cAmbiente     := GetEnvServer()
Local aURLParams    := ::aURLParms
Local aQueryString  := ::aQueryString

Local nCntFor := 0

Private aHeader := {}


	::SetContentType("application/json")	// define o tipo de retorno do mÈtodo

	BEGIN SEQUENCE

		jJsonFJ:FromJson(cBody)

		aFil      := { jJsonFJ[ 'filial'] }
		cCliente  := jJsonFJ[ 'cliente']
		cLoja     := jJsonFJ[ 'loja']
		cTipo     := jJsonFJ[ 'tipo']
		cProduto  := jJsonFJ[ 'produto']
		cTes      := jJsonFJ[ 'tes']  
		nQtd      := jJsonFJ[ 'quantidade']
		nPrc      := jJsonFJ[ 'preco']

		nValor    := nQtd * nPrc

		/*
		cCliente  := "009319"
		cLoja     := "0001"
		cTipo     := "R"
		cProduto  := "CV-AS186-1046"
		cTes      := "558"
		nQtd      := 1
		nPrc      := 100
		nValor    := 100
		*/

		// Sempre é operacao  01 - Venda
		//cTes := Psicione( "SFM", 1, "01", "SFM->FM_TS" )


		VarInfo( "Empresa posicionada: " + cFilAnt )

		//IATAN EM 18/04/2024
		cTesTemp := cTes
		VARINFO("TES - antes MaTesInt.: ", cTEs)
		 //MaTesInt( 2, "01", cCliente, cLoja, "C", cProduto ) // , "C6_TES", cTipoCli, cEstOrig, cOrigem)
		//cTes := MaTesInt(2,"01",cCliente,cLoja,"C",cProduto,"C6_TES",cTipo,"1")
		MaTesInt(2,,cCliente,cLoja,"C",cProduto,"C6_TES")
		VARINFO("TES - apos MaTesInt.: ", cTEs)
		IF cTes == NIL .OR. EMPTY(ALLTRIM(ctes))
			cTes := cTesTemp
		ENDIF
		//VARINFO("TES - apos IF.: ", cTEs)

		aImpostos := {}

		nImpostoValTot := 0
		nPercetualIPI := 0

		oImposto := FIMPOSTOS(cCliente,cLoja,cTipo,cProduto,cTes,nQtd,nPrc,nValor, @nImpostoValTot,aFil, @nPercetualIPI)

		VARINFO("oImposto.:", oImposto)
/*
		For nCntFor = 1 to Len( aImpostos )



			lTemImpostoCalculado := aImpostos[ nCntFor + 3 ]   >  0
			If lTemImpostoCalculado

				cImposto :=  aImpostos[ nCntFor + 2 ] 
				nAliquota :=  aImpostos[ nCntFor + 4 ] 
				nBaseImposto :=  aImpostos[ nCntFor + 5 ] 

			EndIf
		Next nCntFor
*/
		oRet[ 'cliente' ]        := cCliente
		oRet[ 'loja' ]           := cLoja
		oRet[ 'tipo' ]           := cTipo
		oRet[ 'produto' ]        := cProduto
		oRet[ 'tes' ]            := cTes
		oRet[ 'quantidade' ]     := nQtd
		oRet[ 'preco' ]          := nPrc
		oRet[ 'valor' ]          := nValor
		oRet[ 'percentual_ipi_produto' ] := nPercetualIPI

    	oRet[ 'impostos' ]       := oImposto

		oRet[ 'total_impostos' ] := nImpostoValTot

		/*
		oRet['impostos'] := aImpostos
		cJson := FwNoAccent(FWJsonSerialize(oRet, .F., .T., .T.))
		*/

    	cJson := oRet:ToJson()   

		::SetStatus(200) 
		::setResponse( cJson )

		/*
		ValRequisicao( cBody, jJson, lErro, lOk, jJsonFJ )
		MsgRestFault( cErrorMessage, @lErro, @lOk, cDescErro, cDetailMsg )	
		*/

	END SEQUENCE

	/*
	HTTPSetStatus(200, "OK")
	lOk := .T.
	HTTPSetStatus(200, "OK")
	*/

Return( lOK )

/*/{Protheus.doc} MsgRestFault
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
Static Function MsgRestFault( cErrorMessage, lErro, lRet, cCode, cDetailMsg, cHelpUrl, aDetails, lJson, nStatus )
Local lRetorno      := .T.

DEFAULT cCode       := "999"
DEFAULT lJson       := .T.
DEFAULT nStatus     := 406
DEFAULT cDetailMsg  := ""
DEFAULT cHelpUrl    := ""
DEFAULT aDetails    := {}

	cErrorMessage := EncodeUTF8( cErrorMessage )
	cDetailMsg    := EncodeUTF8( cDetailMsg )

	// Funciona COM o TTALK V1 na declaração do metodo
	SetRestFault( cCode, cErrorMessage, lJson, nStatus, cDetailMsg, cHelpUrl, aDetails )

	lErro  := .T.
	lRet   := .F.	

	/*
		nErrorCode := 400
		lErro      := .T.			
		oRet['status'] 		    := .F.
		oRet['errorCode'] 		:= "001"
		oRet['errorMessage']	:= EncodeUTF8("Nao informado empresa/Filial no HEADER da requisicao - WSDBLIGACAO_REST ")
		self:setStatus(406)
		// Funciona SEM o TTALK V1 na declaração do metodo		
		SetRestFault( nErrorCode, oRet['errorMessage'] )		
		HTTPSetStatus(406, "OK")
		self:setResponse('{"meuJson":"Meu valor"}')		
		Self:SetResponse( EncodeUtf8(oRet:ToJson()))
		self:SetResponse( EncodeUtf8(FwJsonSerialize(oRet,.T.,.T.)) )
	*/

Return lRetorno		

/*/{Protheus.doc} ValRequisicao
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
Static Function ValRequisicao( cBody, jJson, lErro, lRet, jJsonFJ )
Local lRetorno    := .T.
Local lJSContinua := .F.
Local lFJContinua := .F.

	/*
		QOut( VarInfo( " HTTPGetBody() 1", HTTPGetBody() ) )
		HTTPClearBody()
		QOut( VarInfo( " HTTPGetBody() 2", HTTPGetBody() ) )            
		QOut( VarInfo( " GetRestFault()() ", ::GetRestFault() ) )
		HTTPSetStatus(202, "OK" )		
	*/

	// -- Valida se o Json nao esta nulo ou vazio
	if Empty(cBody)

		cErrorMessage := EncodeUTF8("Json nulo ou vazio")
		lRetorno := .F.
	Else
		// -- Converte a estrutura Json em Objeto			
		lJSContinua := FWJsonDeserialize( cBody, @jJson )
		lFJContinua := Empty( jJsonFJ:FromJson(cBody) )  


		// -- Valida a conversão JSON
		If !lJSContinua

			cErrorMessage := EncodeUTF8("Parser Json Error")
			lRetorno := .F.
		EndIf
		If !lFJContinua

			cErrorMessage := EncodeUTF8("Parser Json Error")
			lRetorno := .F.
		EndIf
	EndIf

	If !lRetorno

		MsgRestFault( cErrorMessage, @lErro, @lRet, "003" )
		lRetorno := .F.  // Break 
	EndIf

	VarInfo( "JSON Enviado - cBody", cBody )
	VarInfo( "cBody convertido em objeto JSON - jJsonFJ:FromJson", jJsonFJ)	
	VarInfo( "cBody convertido em objeto JSON - FWJsonDeserialize", jJson)

	lRet := lRetorno

	/*
	// -- Valida se o Json nao esta nulo ou vazio
	if Empty(cBody)

		SetRestFault(400, EncodeUTF8("Json nulo ou vazio"))
		Return .F.
	endif

	// -- Converte a estrutura Json em Objeto			
	lJSContinua := FWJsonDeserialize( cBody, @oJson )
	lFJContinua := !( oJsonFJ:FromJson(cJson) )

	// -- Valida a conversão JSON
	If !lJSContinua

		SetRestFault(500, EncodeUTF8("Parser Json Error"))
		Return .F.
	EndIf
	If !lFJContinua

		SetRestFault(500, EncodeUTF8("Parser Json Error"))
		Return .F.
	EndIf

	// -- Valida se os dados da filial vieram no header
	if Empty(aFil) .OR. Len(aFil) <> 2

		SetRestFault(400, EncodeUTF8("Key tenantid inválida"))
		Return .F.
	endif
	*/


Return lRetorno


Static Function FIMPOSTOS(cCliente,cLoja,cTipo,cProduto,cTes,nQtd,nPrc,nValor, nImpostoValTot,aFil,nPercIPI)
	
    local aImp := {}
    local i
	
	Local nCntFor
	Local aRetorno := {}

	local  nBaseImposto := ""


	for i := 1 to 62
		AAdd(aImp,0)
	next

	PutMV( "MV_1DUPNAT", "SA1->A1_NATUREZ")

	SF1->(dbSelectArea("SF1"))
	SF2->(dbSelectArea("SF2"))
	SF3->(dbSelectArea("SF3"))
	SFT->(dbSelectArea("SFT"))	
	SF4->(dbSelectArea("SF4"))	
	SB1->(dbSelectArea("SB1"))		
	SC5->(dbSelectArea("SC5"))	
	SC6->(dbSelectArea("SC6"))	

	If aFil[1] == NIL  .or.  Empty( aFil[1] )
		cFilAnt := "0101"
	Else
		cFilAnt := aFil[1]
	EndIf
	VarInfo( "Empresa posicionada: " + cFilAnt )

	// -------------------------------------------------------------------
	// Realiza os calculos necessários
	// -------------------------------------------------------------------
	MaFisIni(cCliente,;										// 01- Codigo Cliente/Fornecedor
			 cLoja,;										// 02- Loja do Cliente/Fornecedor
			 "C",;											// 03- C: Cliente / F: Fornecedor
			 "N",;											// 04- Tipo da NF
			 cTipo,;										// 05- Tipo do Cliente/Fornecedor
			 MaFisRelImp("MT100",{"SC5","SC6"}),;			// 06- Relacao de Impostos que suportados no arquivo
			 ,;												// 07- Tipo de complemento
			 ,;												// 08- Permite incluir impostos no rodape (.T./.F.)
			 "SB1",;										// 09- Alias do cadastro de Produtos - ("SBI" para Front Loja)
			 "MTR700")										// 10- Nome da rotina que esta utilizando a funcao
	
	// -------------------------------------------------------------------
	// Monta o retorno para a MaFisRet
	// -------------------------------------------------------------------
	MaFisAdd(cProduto,cTes,nQtd,nPrc,0,"","",,0,0,0,0,nValor,0)
	
	// aImpostos:= { "ICM", "PIS", "COF", "CSL", "PS2", "CF2", "ISS", "IRR", "DIF" }
	aImpostos:= { "ICM", "CSL", "PS2", "CF2", "ISS", "DIF", "IPI" }

	aadd(aRetorno, JsonObject():new())

	nIndice := 0

	For nCntFor = 1 to Len( aImpostos )
			
		If aImpostos[ nCntFor ] != "DIF"
		
			nBaseImposto := "IT_BASE" + aImpostos[ nCntFor ]
		Else

			nBaseImposto := "IT_BASEDES"
		EndIf

		If MaFisRet( 1, nBaseImposto ) > 0

			nIndice := nIndice + 1
			aRetorno[nIndice][ "imposto"]   := aImpostos[ nCntFor ]

			If aImpostos[ nCntFor ] == "DIF"
				aRetorno[nIndice][ "base"]      := MaFisRet( 1, "IT_BASEDES" )
				aRetorno[nIndice][ "aliquota" ] := MaFisRet( 1, "IT_ALIQCMP" )
				aRetorno[nIndice][ 'valor' ]    := MaFisRet( 1, "IT_DIFAL" )

			ElseIf aImpostos[ nCntFor ] == "CSL"  // .and.   MaFisRet( 1, "IT_BASECSL" ) > 0
				aRetorno[nIndice][ "base"]      := nValor
				aRetorno[nIndice][ "aliquota" ] := MaFisRet( 1, "IT_ALIQCSL" )
				aRetorno[nIndice][ 'valor' ]    := ( nValor * (MaFisRet( 1, "IT_ALIQCSL" )) ) / 100
				
			ElseIf aImpostos[ nCntFor ] == "IPI"  // .and.   MaFisRet( 1, "IT_BASECSL" ) > 0

				cOrigem   := Posicione( "SB1", 1, FWxFilial("SB1") + cProduto, "SB1->B1_ORIGEM")

				If cOrigem == "1"  .or.  cOrigem == "6"

					nPercIPI := Posicione( "SB1", 1, FWxFilial("SB1") + cProduto, "SB1->B1_IPI")
					
					aRetorno[nIndice][ "base"]      := MaFisRet( 1, "IT_BASEIPI" )
					aRetorno[nIndice][ "aliquota" ] := nPercIPI
					aRetorno[nIndice][ 'valor' ]    := ( nValor * nPercIPI ) / 100
				EndIf
			Else
				aRetorno[nIndice][ "base"]      := MaFisRet( 1, "IT_BASE" + aImpostos[ nCntFor ] )
				aRetorno[nIndice][ "aliquota" ] := MaFisRet( 1, "IT_ALIQ" + aImpostos[ nCntFor ] )
				aRetorno[nIndice][ 'valor' ]    := MaFisRet( 1, "IT_VAL"  + aImpostos[ nCntFor ] )

			EndIf
			aadd(aRetorno, JsonObject():new())


			If aImpostos[ nCntFor ] == "DIF"
						
				nImpostoValTot += MaFisRet( 1, "IT_DIFAL" )
			ElseIf aImpostos[ nCntFor ] == "CSL"  .and.   MaFisRet( 1, "IT_BASECSL" ) > 0

				nImpostoValTot +=  ( nValor * (MaFisRet( 1, "IT_ALIQCSL" )) ) / 100
			Else

				nImpostoValTot +=  MaFisRet( 1, "IT_VAL"  + aImpostos[ nCntFor ] )
			EndIf		

			//aAdd( aRetorno, oPage )
			/*
			nBaseImposto := MaFisRet( 1, "IT_BASE" + aImpostos[ nCntFor ] )	
			nBaseImposto := MaFisRet( 1, "IT_ALIQ" + aImpostos[ nCntFor ] )
			nBaseImposto  := MaFisRet( 1, "IT_VAL"  + aImpostos[ nCntFor ] )
		
			aAdd( aRetorno, { aImpostos[ nCntFor ], nBaseImposto, nBaseImposto, nBaseImposto } )
			*/

			b:=0
		EndIf
	Next nCntFor

	// CSSL
	If MaFisRet( 1, "IT_BASECSL" ) > 0  .and.  .F.

		nIndice++
		aRetorno[nIndice][ "imposto"]   := "CSL"
		aRetorno[nIndice][ "base"]      := nValor
		aRetorno[nIndice][ "aliquota" ] := MaFisRet( 1, "IT_ALIQCSL" )
		aRetorno[nIndice][ 'valor' ]    := ( nValor * (MaFisRet( 1, "IT_ALIQCSL" )) ) / 100

		nImpostoValTot +=  ( nValor * (MaFisRet( 1, "IT_ALIQCSL" )) ) / 100
	EndIf 

	/*	
	// -------------------------------------------------------------------
	// Monta um array com os valores necessários
	// -------------------------------------------------------------------
	aImp[01] := cProduto
	aImp[02] := cTes
	aImp[03] := "ICM"							//03 ICMS
	aImp[04] := MaFisRet(1,"IT_BASEICM")		//04 Base do ICMS
	aImp[05] := MaFisRet(1,"IT_ALIQICM")		//05 Aliquota do ICMS
	aImp[06] := MaFisRet(1,"IT_VALICM")			//06 Valor do ICMS
	aImp[07] := "IPI"							//07 IPI
	aImp[08] := MaFisRet(1,"IT_BASEIPI")		//08 Base do IPI
	aImp[09] := MaFisRet(1,"IT_ALIQIPI")		//09 Aliquota do IPI
	aImp[10] := MaFisRet(1,"IT_VALIPI")			//10 Valor do IPI
	aImp[11] := "PIS"							//11 PIS/PASEP
	aImp[12] := MaFisRet(1,"IT_BASEPIS")		//12 Base do PIS
	aImp[13] := MaFisRet(1,"IT_ALIQPIS")		//13 Aliquota do PIS
	aImp[14] := MaFisRet(1,"IT_VALPIS")			//14 Valor do PIS
	aImp[15] := "COF"							//15 COFINS
	aImp[16] := MaFisRet(1,"IT_BASECOF")		//16 Base do COFINS
	aImp[17] := MaFisRet(1,"IT_ALIQCOF")		//17 Aliquota COFINS
	aImp[18] := MaFisRet(1,"IT_VALCOF")			//18 Valor do COFINS
	aImp[19] := "ISS"							//19 ISS
	aImp[20] := MaFisRet(1,"IT_BASEISS")		//20 Base do ISS
	aImp[21] := MaFisRet(1,"IT_ALIQISS")		//21 Aliquota ISS
	aImp[22] := MaFisRet(1,"IT_VALISS")			//22 Valor do ISS
	aImp[23] := "IRR"							//23 IRRF
	aImp[24] := MaFisRet(1,"IT_BASEIRR")		//24 Base do IRRF
	aImp[25] := MaFisRet(1,"IT_ALIQIRR")		//25 Aliquota IRRF
	aImp[26] := MaFisRet(1,"IT_VALIRR")			//26 Valor do IRRF
	aImp[27] := "INS"							//27 INSS
	aImp[28] := MaFisRet(1,"IT_BASEINS")		//28 Base do INSS
	aImp[29] := MaFisRet(1,"IT_ALIQINS")		//29 Aliquota INSS
	aImp[30] := MaFisRet(1,"IT_VALINS")			//30 Valor do INSS
	aImp[31] := "CSL"							//31 CSLL
	aImp[32] := MaFisRet(1,"IT_BASECSL")		//32 Base do CSLL
	aImp[33] := MaFisRet(1,"IT_ALIQCSL")		//33 Aliquota CSLL
	aImp[34] := MaFisRet(1,"IT_VALCSL")			//34 Valor do CSLL
	aImp[35] := "PS2"							//35 PIS/Pasep - Via Apuração
	aImp[36] := MaFisRet(1,"IT_BASEPS2")		//36 Base do PS2 (PIS/Pasep - Via Apuração)
	aImp[37] := MaFisRet(1,"IT_ALIQPS2")		//37 Aliquota PS2 (PIS/Pasep - Via Apuração)
	aImp[38] := MaFisRet(1,"IT_VALPS2")			//38 Valor do PS2 (PIS/Pasep - Via Apuração)
	aImp[39] := "CF2"							//39 COFINS - Via Apuração
	aImp[40] := MaFisRet(1,"IT_BASECF2")		//40 Base do CF2 (COFINS - Via Apuração)
	aImp[41] := MaFisRet(1,"IT_ALIQCF2")		//41 Aliquota CF2 (COFINS - Via Apuração)
	aImp[42] := MaFisRet(1,"IT_VALCF2")			//42 Valor do CF2 (COFINS - Via Apuração)
	aImp[43] := "ICC"							//43 ICMS Complementar
	aImp[44] := MaFisRet(1,"IT_ALIQCMP")		//44 Base do ICMS Complementar
	aImp[45] := MaFisRet(1,"IT_ALIQCMP")		//45 Aliquota do ICMS Complementar
	aImp[46] := MaFisRet(1,"IT_VALCMP")			//46 Valor do do ICMS Complementar
	aImp[47] := "ICA"							//47 ICMS ref. Frete Autonomo
	aImp[48] := MaFisRet(1,"IT_BASEICA")		//48 Base do ICMS ref. Frete Autonomo
	aImp[49] := 0								//49 Aliquota do ICMS ref. Frete Autonomo
	aImp[50] := MaFisRet(1,"IT_VALICA")			//50 Valor do ICMS ref. Frete Autonomo
	aImp[51] := "TST"							//51 ICMS ref. Frete Autonomo ST
	aImp[52] := MaFisRet(1,"IT_BASETST")		//52 Base do ICMS ref. Frete Autonomo ST
	aImp[53] := MaFisRet(1,"IT_ALIQTST")		//53 Aliquota do ICMS ref. Frete Autonomo ST
	aImp[54] := MaFisRet(1,"IT_VALTST")			//54 Valor do ICMS ref. Frete Autonomo ST
	aImp[55] := MaFisRet(1,"IT_BASESOL")		//55 Base do ICMS ST
	aImp[56] := MaFisRet(1,"IT_ALIQSOL")		//56 Aliquota do ICMS ST
	aImp[57] := MaFisRet(1,"IT_VALSOL")			//57 Valor do ICMS ST
	aImp[58] := MaFisRet(1,"IT_DESCONTO")		//58 Valor do Desconto
	aImp[59] := MaFisRet(1,"IT_FRETE")			//59 Valor do Frete
	aImp[60] := MaFisRet(1,"IT_SEGURO")			//60 Valor do Seguro
	aImp[61] := MaFisRet(1,"IT_DESPESA")		//61 Valor das Despesas
	aImp[62] := MaFisRet(1,"IT_VALMERC")		//62 Valor da Mercadoria

	//	MaFisSave()
	*/

	MaFisEnd()

	VarInfo( "JSON Retorno", aRetorno )

	PutMV( "MV_1DUPNAT", "SC5->C5_NATUREZ")
	
Return aRetorno // oPage  // aRetorno // aImp


User Function TEST_FIMPOSTOS()

    local aImp := {}
    local i
	
	Local nCntFor
	Local aRetorno := {}

	PutMV( "MV_1DUPNAT", "SA1->A1_NATUREZ")

	cCliente := "000001"
	cLoja    := "0002"
	cTipo    := "J"
	cProduto := "0000237"
	cTipOper := "01"
	cTes     := Posicione( "SFM", 1, FWxFilial("SFM") + cTipOper, "SFM->FM_TS" )
	If Empty( cTes )

		cTes := "558"
	EndIf
	nQtd     := 1
	nPrc     := 100
	nValor   := 100
	nImpostoValTot := 0
	nBaseImposto := 0

	for i := 1 to 62
		AAdd(aImp,0)
	next

	//MaFisSave()
	//MaFisEnd()

	//MaFisAlt("NF_NATUREZA",  "111206"  )

	cNaturez := GetMV("MV_1DUPNAT")
	Parada1 := 0

	PutMV( "MV_1DUPNAT", "SA1->A1_NATUREZ")

	cNaturez := GetMV("MV_1DUPNAT")
	Parada1 := 0	
	// -------------------------------------------------------------------
	// Realiza os calculos necessários
	// -------------------------------------------------------------------
	
	MaFisIni(cCliente,;										// 01- Codigo Cliente/Fornecedor
			 cLoja,;										// 02- Loja do Cliente/Fornecedor
			 "C",;											// 03- C: Cliente / F: Fornecedor
			 "N",;											// 04- Tipo da NF
			 cTipo,;										// 05- Tipo do Cliente/Fornecedor
			 MaFisRelImp("MT100",{"SC5","SC6"}),;			// 06- Relacao de Impostos que suportados no arquivo
			 ,;												// 07- Tipo de complemento
			 ,;												// 08- Permite incluir impostos no rodape (.T./.F.)
			 "SB1",;										// 09- Alias do cadastro de Produtos - ("SBI" para Front Loja)
			 "MTR700")										// 10- Nome da rotina que esta utilizando a funcao
	/*
	MaFisIni(cCliente,;// 1-Codigo Cliente/Fornecedor
		cLoja,;		// 2-Loja do Cliente/Fornecedor
		"C",;				// 3-C:Cliente , F:Fornecedor
		"N",;				// 4-Tipo da NF
		"J",;		// 5-Tipo do Cliente/Fornecedor
		Nil,;
		Nil,;
		Nil,;
		Nil,;
		"MATA461",;
		Nil,;
		Nil,;
		Nil,;
		Nil,;
		Nil,;
		Nil,;
		Nil,;
		{"",""},;
		Nil,;
		Nil,;
		,;
		cCliente,;
		cLoja,;
		nValor,;
		Nil,;
		,;
		Nil,;
		Nil,;
		Nil,;
		Nil,;
		Nil,;
		Nil,;
		IIf(FindFunction("ChkTrbGen"), ChkTrbGen("SD2","D2_IDTRIB"), .F.),;
		1,;
		.T.)
	*/
	Parada1 := 0
	// -------------------------------------------------------------------
	// Monta o retorno para a MaFisRet
	// -------------------------------------------------------------------
	MaFisAdd(cProduto,cTes,nQtd,nPrc,0,"","",,0,0,0,0,nValor,0)

	Parada1 := 0

	MaFisIniLoad(1,{cProduto,;														//IT_PRODUTO
						cTes,; 												//IT_TES
						"",; 															//IT_CODISS
						nQtd,;	//IT_QUANT
						"",; 														//IT_NFORI
						"",; 														//IT_SERIORI
						7133,;												//IT_RECNOSB1
						2694,;												//IT_RECNOSF4
						0,; 														//IT_RECORI
						,;												//IT_LOTE
						,;   											//IT_SUBLOTE
						"",;                											//IT_PRDFIS
						0,;                 											//IT_RECPRDF
						""})	    					//IT_TPOPER
	
	Parada1 := 0 

	MafisRecal('',1)

	aImpostos:= { "ICM", "PS2", "CF2", "ISS",  "DIF", "PIS" }

	aadd(aRetorno, JsonObject():new())

	nIndice := 0

	For nCntFor = 1 to Len( aImpostos )

			
		If aImpostos[ nCntFor ] != "DIF"
		
			nBaseImposto := "IT_BASE" + aImpostos[ nCntFor ]
		Else

			nBaseImposto := "IT_BASEDES"
		EndIF
		If MaFisRet( 1, nBaseImposto ) > 0

			nIndice := nIndice + 1
			aRetorno[nIndice][ "imposto"]   := aImpostos[ nCntFor ]

			If aImpostos[ nCntFor ] == "DIF"

				aRetorno[nIndice][ "base"]      := MaFisRet( 1, "IT_BASEDES" )
				aRetorno[nIndice][ "aliquota" ] := MaFisRet( 1, "IT_ALIQCMP" )
				aRetorno[nIndice][ 'valor' ]    := MaFisRet( 1, "IT_DIFAL" )
			Else

				aRetorno[nIndice][ "base"]      := MaFisRet( 1, "IT_BASE" + aImpostos[ nCntFor ] )
				aRetorno[nIndice][ "aliquota" ] := MaFisRet( 1, "IT_ALIQ" + aImpostos[ nCntFor ] )
				aRetorno[nIndice][ 'valor' ]    := MaFisRet( 1, "IT_VAL"  + aImpostos[ nCntFor ] )
			EndIf
			aadd(aRetorno, JsonObject():new())


			If aImpostos[ nCntFor ] == "DIF"
			
				nImpostoValTot += MaFisRet( 1, "IT_DIFAL" )
			Else

				nImpostoValTot +=  MaFisRet( 1, "IT_VAL"  + aImpostos[ nCntFor ] )
			EndIF


			

			//aAdd( aRetorno, oPage )
			/*
			nBaseImposto := MaFisRet( 1, "IT_BASE" + aImpostos[ nCntFor ] )	
			nBaseImposto := MaFisRet( 1, "IT_ALIQ" + aImpostos[ nCntFor ] )
			nBaseImposto  := MaFisRet( 1, "IT_VAL"  + aImpostos[ nCntFor ] )
		
			aAdd( aRetorno, { aImpostos[ nCntFor ], nBaseImposto, nBaseImposto, nBaseImposto } )
			*/

			b:=0
		EndIf
	Next nCntFor


	// CSSL
	If MaFisRet( 1, "IT_BASECSL" ) > 0

		nIndice++
		aRetorno[nIndice][ "imposto"]   := "CSL"
		aRetorno[nIndice][ "base"]      := nValor
		aRetorno[nIndice][ "aliquota" ] := MaFisRet( 1, "IT_ALIQCSL" )
		aRetorno[nIndice][ 'valor' ]    := ( nValor * (MaFisRet( 1, "IT_ALIQCSL" )) ) / 100
	EndIf 

	/*	
	// -------------------------------------------------------------------
	// Monta um array com os valores necessários
	// -------------------------------------------------------------------
	aImp[01] := cProduto
	aImp[02] := cTes
	aImp[03] := "ICM"							//03 ICMS
	aImp[04] := MaFisRet(1,"IT_BASEICM")		//04 Base do ICMS
	aImp[05] := MaFisRet(1,"IT_ALIQICM")		//05 Aliquota do ICMS
	aImp[06] := MaFisRet(1,"IT_VALICM")			//06 Valor do ICMS
	aImp[07] := "IPI"							//07 IPI
	aImp[08] := MaFisRet(1,"IT_BASEIPI")		//08 Base do IPI
	aImp[09] := MaFisRet(1,"IT_ALIQIPI")		//09 Aliquota do IPI
	aImp[10] := MaFisRet(1,"IT_VALIPI")			//10 Valor do IPI
	aImp[11] := "PIS"							//11 PIS/PASEP
	aImp[12] := MaFisRet(1,"IT_BASEPIS")		//12 Base do PIS
	aImp[13] := MaFisRet(1,"IT_ALIQPIS")		//13 Aliquota do PIS
	aImp[14] := MaFisRet(1,"IT_VALPIS")			//14 Valor do PIS
	aImp[15] := "COF"							//15 COFINS
	aImp[16] := MaFisRet(1,"IT_BASECOF")		//16 Base do COFINS
	aImp[17] := MaFisRet(1,"IT_ALIQCOF")		//17 Aliquota COFINS
	aImp[18] := MaFisRet(1,"IT_VALCOF")			//18 Valor do COFINS
	aImp[19] := "ISS"							//19 ISS
	aImp[20] := MaFisRet(1,"IT_BASEISS")		//20 Base do ISS
	aImp[21] := MaFisRet(1,"IT_ALIQISS")		//21 Aliquota ISS
	aImp[22] := MaFisRet(1,"IT_VALISS")			//22 Valor do ISS
	aImp[23] := "IRR"							//23 IRRF
	aImp[24] := MaFisRet(1,"IT_BASEIRR")		//24 Base do IRRF
	aImp[25] := MaFisRet(1,"IT_ALIQIRR")		//25 Aliquota IRRF
	aImp[26] := MaFisRet(1,"IT_VALIRR")			//26 Valor do IRRF
	aImp[27] := "INS"							//27 INSS
	aImp[28] := MaFisRet(1,"IT_BASEINS")		//28 Base do INSS
	aImp[29] := MaFisRet(1,"IT_ALIQINS")		//29 Aliquota INSS
	aImp[30] := MaFisRet(1,"IT_VALINS")			//30 Valor do INSS
	aImp[31] := "CSL"							//31 CSLL
	aImp[32] := MaFisRet(1,"IT_BASECSL")		//32 Base do CSLL
	aImp[33] := MaFisRet(1,"IT_ALIQCSL")		//33 Aliquota CSLL
	aImp[34] := MaFisRet(1,"IT_VALCSL")			//34 Valor do CSLL
	aImp[35] := "PS2"							//35 PIS/Pasep - Via Apuração
	aImp[36] := MaFisRet(1,"IT_BASEPS2")		//36 Base do PS2 (PIS/Pasep - Via Apuração)
	aImp[37] := MaFisRet(1,"IT_ALIQPS2")		//37 Aliquota PS2 (PIS/Pasep - Via Apuração)
	aImp[38] := MaFisRet(1,"IT_VALPS2")			//38 Valor do PS2 (PIS/Pasep - Via Apuração)
	aImp[39] := "CF2"							//39 COFINS - Via Apuração
	aImp[40] := MaFisRet(1,"IT_BASECF2")		//40 Base do CF2 (COFINS - Via Apuração)
	aImp[41] := MaFisRet(1,"IT_ALIQCF2")		//41 Aliquota CF2 (COFINS - Via Apuração)
	aImp[42] := MaFisRet(1,"IT_VALCF2")			//42 Valor do CF2 (COFINS - Via Apuração)
	aImp[43] := "ICC"							//43 ICMS Complementar
	aImp[44] := MaFisRet(1,"IT_ALIQCMP")		//44 Base do ICMS Complementar
	aImp[45] := MaFisRet(1,"IT_ALIQCMP")		//45 Aliquota do ICMS Complementar
	aImp[46] := MaFisRet(1,"IT_VALCMP")			//46 Valor do do ICMS Complementar
	aImp[47] := "ICA"							//47 ICMS ref. Frete Autonomo
	aImp[48] := MaFisRet(1,"IT_BASEICA")		//48 Base do ICMS ref. Frete Autonomo
	aImp[49] := 0								//49 Aliquota do ICMS ref. Frete Autonomo
	aImp[50] := MaFisRet(1,"IT_VALICA")			//50 Valor do ICMS ref. Frete Autonomo
	aImp[51] := "TST"							//51 ICMS ref. Frete Autonomo ST
	aImp[52] := MaFisRet(1,"IT_BASETST")		//52 Base do ICMS ref. Frete Autonomo ST
	aImp[53] := MaFisRet(1,"IT_ALIQTST")		//53 Aliquota do ICMS ref. Frete Autonomo ST
	aImp[54] := MaFisRet(1,"IT_VALTST")			//54 Valor do ICMS ref. Frete Autonomo ST
	aImp[55] := MaFisRet(1,"IT_BASESOL")		//55 Base do ICMS ST
	aImp[56] := MaFisRet(1,"IT_ALIQSOL")		//56 Aliquota do ICMS ST
	aImp[57] := MaFisRet(1,"IT_VALSOL")			//57 Valor do ICMS ST
	aImp[58] := MaFisRet(1,"IT_DESCONTO")		//58 Valor do Desconto
	aImp[59] := MaFisRet(1,"IT_FRETE")			//59 Valor do Frete
	aImp[60] := MaFisRet(1,"IT_SEGURO")			//60 Valor do Seguro
	aImp[61] := MaFisRet(1,"IT_DESPESA")		//61 Valor das Despesas
	aImp[62] := MaFisRet(1,"IT_VALMERC")		//62 Valor da Mercadoria

	//	MaFisSave()
	*/

	MaFisEnd()

	VarInfo( "aImp", aRetorno )
	
	PutMV( "MV_1DUPNAT", "SC5->C5_NATUREZ")

Return aRetorno // oPage  // aRetorno // aImp


