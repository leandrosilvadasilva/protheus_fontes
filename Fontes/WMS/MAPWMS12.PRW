#include "protheus.ch"
#include "tbiconn.ch"
#include "topconn.ch"
#include "restful.ch"
/*--------------------------------------------------------------------------------------------------*
| Func:  MAPWMS12.prw                                                     							|
| Autor: Lucas Brustolin                                              								|
| Data:  Abr/2022                                                   								|
| Desc:  Rotina para envio do Tipo de Entrada\Saida (Nota) para AKR	        	                    |   
|		 Endpoint: http://192.168.11.63:43001/rest/NOTAENTRADA									|
|    																								|
|
|    Formato de JSON esperado:
|	
|	{
|		"F1_FILIAL": "0101",
|		"F1_DOC": "",
|		"F1_SERIE": "",
|		"F1_EMISSAO": "",
|		"F1_TIPO": "D",
|		"F1_FORNECE": "",
|		"F1_LOJA": "",
|		"itens": [
|			{
|				"D1_ITEMORI": "001",
|				"D1_COD": "CB00000",
|				"D1_QUANT": 10,
|				"D1_NFORI": "000000001",
|				"D1_SERIORI": "1"
|			}
|		]
|	}
|                                                                            						|
*--------------------------------------------------------------------------------------------------*/

WSRESTFUL NOTAENTRADA DESCRIPTION "Inclusao de Nota Fiscal de Entrada"

WSMETHOD POST DESCRIPTION "Entrada da nota de devolução" WSSYNTAX "/NOTAENTRADA" path "/NOTAENTRADA"

END WSRESTFUL

/*------------------------------------------------------------------
	METODO RESPONSAVEL PELA INCLUSAO DA NOTA FISCAL DE DEVOLUÇÃO
------------------------------------------------------------------*/ 
WSMETHOD POST WSSERVICE NOTAENTRADA

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
Local cFilDoc 		:= ""
Local cDoc 			:= ""
Local cSerie 		:= ""
Local cProduto 		:= ""
Local cCondPad		:= ""
Local cFormul 		:= ""
Local cItem			:= ""
Local cFornece 		:= ""
Local cLojaForn		:= ""
Local dEmissao 		:= CTOD("")
Local cTesDev		:= ""
Local cCC			:= ""
Local nTamDoc		:= 0
Local nTamSerie 	:= 0
Local nTamProd		:= 0
Local n1 			:= 0
Local lRet          := .F.
Local filialATUAL   := CFILANT

Self:SetContentType("application/json")
cJson := Self:GetContent() 

oJson	:= JsonObject():New()
cCatch  := oJson:FromJSON(cJson)

If cCatch == Nil   
	
	cFilDoc		:= PadR( oJson["f1_filial"]	, TamSx3("F1_FILIAL")[1] )
	cSerie 		:= SuperGetMv("ES_SERIDEV",,"1")

	IF cFilDoc== '0102'
		CFILANT := '0102'
	ELSEIF cFilDoc == '0103'
		CFILANT := '0103'
	ELSEIF cFilDoc == '0104'
		CFILANT := '0104'
	ELSEIF cFilDoc == '0105'
		CFILANT := '0105'
	ELSEIF cFilDoc == '0106'
		CFILANT := '0106'
	ELSEIF cFilDoc == '0107'
		CFILANT := '0107'		
	ELSEIF cFilDoc == '5001'
		CFILANT := '5001'
	ENDIF

	cNFiscal	:= oJson["f1_emissao"]
	If Empty( cNFiscal )
		cNFiscal 	:= NxtSX5Nota(cSerie,,SuperGetMV("MV_TPNRNFS",.F.,"1"))
	EndIf 

	dEmissao	:= STOD( oJson["f1_emissao"] )
	cCondPad	:= SuperGetMV( "MV_CONDPAD")
	cFormul 	:= IIF( AllTrim(oJson["f1_tipo"]) == "D", "S","N")
	cFornece 	:= AllTrim(oJson["f1_fornece"])
	cLojaForn	:= AllTrim(oJson["f1_loja"])

	CheckFornecedor( @cFornece, @cLojaForn ) 


	AAdd( aCab, { "F1_FILIAL" 		, cFilDoc					, Nil } )	// Filial da NF : Obrigatorio
	AAdd( aCab, { "F1_DOC"    		, cNFiscal					, Nil } )	// Numero da NF : Obrigatorio
	AAdd( aCab, { "F1_SERIE"  		, cSerie 			   		, Nil } )	// Serie da NF  : Obrigatorio
	AAdd( aCab, { "F1_TIPO"   		, oJson["f1_tipo"]    		, Nil } )	// Tipo da NF   : Obrigatorio
	AAdd( aCab, { "F1_FORNECE"		, cFornece					, Nil } )	// Codigo do Fornecedor : Obrigatorio
	AAdd( aCab, { "F1_LOJA"   		, cLojaForn			   		, Nil } )	// Loja do Fornecedor   : Obrigatorio
	AAdd( aCab, { "F1_EMISSAO"		, oJson["f1_emissao"] 		, Nil } )	// Emissao da NF        : Obrigatorio
	aAdd( aCab, { "F1_COND"			, cCondPad					, Nil } ) 	//Condición de pago		: Obrigatorio
	AAdd( aCab, { "F1_FORMUL" 		, cFormul                	, Nil } )   // Formulario Proprio
	AAdd( aCab, { "F1_ESPECIE"		, "SPED"		        	, Nil } )   // Especie                


	DbSelectArea("SF2")
	SF2->(DbSetOrder(1)) // F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
	
	DbselectArea("SD2")
	SD2->(DbSetOrder(3)) // D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM 

	cTesDev  := SuperGetMv("ES_TESDEV1",,"338")

	DbselectArea("SF4")
	SF4->( DbSetOrder(1) )
	SF4->(DbSeek(xFilial("SF4")+cTesDev))

	nTamDoc		:= TamSx3("D1_DOC")[1]
	nTamSerie 	:= TamSx3("D1_SERIE")[1] 
	nTamProd 	:= TamSx3("D1_COD")[1]

    oItens := oJson:GetJsonObject('itens')
		
    For n1 := 1 to Len(oItens)

		cItem		:= StrZero(nI,TamSX3("D1_ITEM")[1])
		cDoc		:= PadR( oItens[n1]["d1_nfori"]		, nTamDoc )
		cSerie 		:= PadR( oItens[n1]["d1_seriori"] 	, nTamSerie )
		cProduto 	:= PadR( oItens[n1]["d1_cod"]		, nTamProd )


		SF2->( MsSekk( xFilDoc + cDoc + cSerie ) )

		If SD2->( MsSeek(SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA) + cProduto ) )
			aLinha := {}				
			AAdd( aLinha, { "D1_ITEM" 		, cItem							, Nil } )  
			AAdd( aLinha, { "D1_ITEMORI"    , oItens[n1]["d1_itemori"]  	, Nil } )
			AAdd( aLinha, { "D1_COD"    	, oItens[n1]["d1_cod"]			, Nil } )
			AAdd( aLinha, { "D1_QUANT"  	, oItens[n1]["d1_quant"]  		, Nil } )	
			AAdd( aLinha, { "D1_NFORI"  	, oItens[n1]["d1_nfori"]		, Nil } )	
			AAdd( aLinha, { "D1_SERORI" 	, oItens[n1]["d1_seriori"]  	, Nil } )			

			AAdd( aLinha, { "D1_UNBRUT" 	, SD2->D2_TOTAL / SD2->D2_QUANT	, Nil })					
			AAdd( aLinha, { "D1_BRUTO"  	, SD2->D2_TOTAL                 , Nil })					
			AAdd( aLinha, { "D1_VUNIT"  	, SD2->D2_TOTAL / SD2->D2_QUANT	, Nil })					
			AAdd( aLinha, { "D1_TOTAL"  	, SD2->D2_TOTAL                 , Nil } )	

			// --------------------------------------------------
			//³Monta a linha de devolucao que sera gerado o SD1³
			// -------------------------------------------------    
			AAdd( aLinha, { "D1_IPI"    , SD2->D2_IPI    , Nil } )	
			AAdd( aLinha, { "D1_LOCAL"  , SD2->D2_LOCAL  , Nil } )
			AAdd( aLinha, { "D1_TES" 	, cTesDev        , Nil } )
			AAdd( aLinha, { "D1_CC" 	, cCC            , Nil } )
			AAdd( aLinha, { "D1_CF" 	, SF4->F4_CF     , Nil } )
			AAdd( aLinha, { "D1_UM"     , SD2->D2_UM     , Nil } )

			// ---------------------------------------------------
			// Verifica se existe rastreabilidade              
			// ---------------------------------------------------
			If Rastro(SD2->D2_COD)
				AAdd( aLinha, { "D1_LOTECTL", SD2->D2_LOTECTL	, Nil } )
				AAdd( aLinha, { "D1_NUMLOTE", Nil				, Nil } )
				AAdd( aLinha, { "D1_DTVALID", SD2->D2_DTVALID	, Nil } )
				AAdd( aLinha, { "D1_POTENCI", SD2->D2_POTENCI	, Nil } )
			Endif
			
			AAdd( aLinha, { "D1_NFORI"	, SD2->D2_DOC     , Nil } )
			AAdd( aLinha, { "D1_SERIORI", SD2->D2_SERIE   , Nil } )
			AAdd( aLinha, { "D1_ITEMORI", SD2->D2_ITEM    , Nil } )
			AAdd( aLinha, { "D1_ICMSRET", SD2->D2_ICMSRET , Nil } )	
			AAdd( aLinha, { "D1_NFREF1" , SD2->D2_DOC     , Nil } )				
		    AAdd( aLinha, { "D1_DTREF1" , SD2->D2_EMISSAO , Nil } )				

			// ------------------------------------------------------
			// Verifica se o TES eh de poder de terceiro       
			// ------------------------------------------------------
			If SF4->F4_PODER3=="D"
				AAdd( aLinha, { "D1_IDENTB6", SD2->D2_NUMSEQ, Nil } )								
			Endif


			AAdd( aLinha, { "D1RECNO"		, SD2->(RECNO())				, Nil } )
			
			AAdd( aItens, aLinha)
		EndIf 
    Next

	//------------------------------------
	// Variaveis de controle de Erro \ Log 
	//------------------------------------
	Private lMsErroAuto 	:= .F.
	Private lMsHelpAuto 	:= .T.
	Private lAutoErrNoFile  := .T. //<= para nao gerar arquivo e pegar o erro com a funcao GETAUTOGRLOG()

	//-- Organiza os Arrays conforme dicionario 
	aCab	:= FWVetByDic(aCab		, "SF1",.F.)                 
	aItens 	:= FWVetByDic(aItens	, "SD1",.T.)  

	MSExecAuto({|x,y,z| MATA103(x,y,z)}, aCab, aItens, 3)

	If ( lMsErroAuto  )
		aLogErr := GetAutoGRLog()
		aLogErr	:= TrataErro( aLogErr ) //Trata log a partir do erro do execauto	
		cLogMsg := 'ERROR Ao incluir Nota Devolucao [MATA103] - ' + EncodeUTF8( aLogErr[1] )
		lRet	:= .F. 
	Else 
		lRet 	:= .T. 
		cLogMsg := "Nota de Devolucao ["+AllTrim(SF1->F1_DOC)+" "+ AllTrim(SF1->F1_SERIE) +"] incluida com sucesso!"
	EndIf

	// ------------------------------------------------------------
	// MONTA JSON DE RESPOSTA DO REST
	oJsonResponse				:= JsonObject():New()
	oJsonResponse['message'] 	:= cLogMsg
	oJsonResponse['code'] 		:= IIF( lRet,  200, 400)
    Self:SetResponse(oJsonResponse)	

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


Static Function CheckFornecedor( cFornece, cLojaForn )

Local nTamForn := TamSx3("F1_FORNECE")[1]
Local nTamLoj  := TamSx3("F1_LOJA")[1]

If 	!Empty(cFornece)	.And. ;
	 Empty(cLojaForn)	.And. ;
	 Len(cFornece) > nTamForn

	cLojaForn	:= SubStr( cFornece, nTamForn + 1 , Len(cFornece) )
	cFornece	:= SubStr( cFornece, 1, nTamForn )
	

ElseIf	!Empty(cFornece)	.And. ;
	 	!Empty(cLojaForn)	.And. ;
	 	Len(cFornece) > nTamForn 

	cFornece 	:= SubStr( cFornece,1,nTamForn)
	cLojaForn	:= PADR( cLojaForn, nTamLoj ) 


EndIf 

Return()
