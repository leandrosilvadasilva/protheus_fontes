#include "Protheus.ch"
#include "tbiconn.ch"
#include "topconn.ch"
#include "restful.ch"
#include "FWMVCDEF.ch"
#Include "TOTVS.ch" 
#INCLUDE "rwmake.ch"

/*--------------------------------------------------------------------------------------------------*
| Func:  MAPWMS17.prw                                                     							|
| Autor: Iatan Santos                                                								|
| Data:  Abr/2022                                                   								|
| Desc:  Rotina para inclusao de pedido de venda 					        	                    |   
|		 Endpoint: http://192.168.11.63:43001/rest/INVENTARIO										|
|    																								|
|    Formato de JSON esperado:
|
| {
|	"inventario": [{
|        "filial":"0101"
|		 "produto": "CV-EGIA45AVM        ",
|		 "armazem": "01",
|		 "quantidade": "3.0",
|		 "lote": "N1K0954Y                      ",
|		 "data": "14/07/2022",
|        "inventario":"123456789"
|	}]
}
|                                                                            						|
*--------------------------------------------------------------------------------------------------*/

WSRESTFUL INVENTARIO DESCRIPTION "Inclusao de Digitação de Inventário"

WSMETHOD POST DESCRIPTION "Inclusão de Digitação de Inventário" WSSYNTAX "/INVENTARIO" path "/INVENTARIO"

END WSRESTFUL

/*------------------------------------------------------------------
	METODO RESPONSAVEL PELA INCLUSAO DA DIGITACAO DO INVENTARIO
------------------------------------------------------------------*/ 
WSMETHOD POST WSSERVICE INVENTARIO

Local aArea 		:= GetArea()
Local aLogErr		:= {}
Local oJson        	:= Nil 
LOCAL cCatch       	:= Nil 
Local cLogMsg		:= "" 
Local cJson 		:= ""
Local cProduto 		:= ""
Local lRet          := .T.
Local cFil          := ""
Local cData    
Local dataValid

Local filialATUAL   := CFILANT

Private lMsErroAuto := .F.
Private lMsHelpAuto := .F.

Self:SetContentType("application/json")
cJson := Self:GetContent() 

oJson	:= JsonObject():New()
cCatch  := oJson:FromJSON(cJson)

If cCatch == Nil   
	

	cFil		:= oJson["filial"]
	cFil		:= IIF( !Empty(cFil),cFil, xFilial("SB7") )


	IF cFil == '0102'
		CFILANT := '0102'
	ELSEIF cFil == '0103'
		CFILANT := '0103'
	ELSEIF cFil == '0104'
		CFILANT := '0104'
	ELSEIF cFil == '0105'
		CFILANT := '0105'
	ELSEIF cFil == '0106'
		CFILANT := '0106'
	ELSEIF cFil == '0107'
		CFILANT := '0107'			
	ELSEIF cFil == '5001'
		CFILANT := '5001'
	ENDIF

    cProduto := PADR(oJson["produto"],  TAMSX3("B7_COD")[1])
    cInventario := PADR(oJson["inventario"],  TAMSX3("B7_DOC")[1])
    cQuant := oJson["quantidade"]
    cLocal := oJson["armazem"]
    cLote := PADR(oJson["lote"],  TAMSX3("B7_LOTECTL")[1])
    cData := CTOD(oJson["data"])


	IF RecLock("SB7",.T.)
		SB7->B7_FILIAL  := cFil
		SB7->B7_COD     := cProduto
		SB7->B7_LOCAL   := cLocal
		SB7->B7_TIPO    := POSICIONE("SB1", 1, XFILIAL("SB1")+cProduto, "B1_TIPO")
		SB7->B7_DOC     := cInventario
		SB7->B7_QUANT   := cQuant
		SB7->B7_DATA    := cData
		SB7->B7_LOTECTL := cLote
	
		dataValid       := getDtValid(cFil, cProduto, cLocal, cLote)
		IF !EMPTY(ALLTRIM(dataValid))
			SB7->B7_DTVALID := CTOD( dataValid )
		ENDIF
	
		SB7->B7_STATUS  := "1"
		SB7->(MsUnlock())
		CONOUT(cFil+cProduto+cLocal+cLote)
	ELSE 
		CONOUT( "**********ERRO********** ") 
		CONOUT( "FILIAL = " + cFil )
		CONOUT( "PRODUTO = " + cProduto)
		CONOUT( "LOCAL = " + cLocal)
		CONOUT( "LOTE = " + cLote)
		CONOUT( "**********ERRO********** ") 
	ENDIF
/*aVetor := {;
    	{"B7_FILIAL" , cFil,   Nil},;
        {"B7_COD",     cProduto,     Nil},;
        {"B7_LOCAL",   cLocal,   Nil},;
        {"B7_TIPO",   (POSICIONE("SB1", 1, XFILIAL("SB1")+cProduto, "B1_TIPO")),   Nil},;
        {"B7_DOC",     cInventario,     Nil},;
        {"B7_QUANT",   cQuant,  Nil},;
        {"B7_QTSEGUM", 0, Nil},;
        {"B7_DATA",    cData, Nil},;
        {"B7_LOTECTL", cLote, Nil},;
        {"B7_STATUS", "1", Nil} }

	Pergunte("MTA270", .F.)
	MV_PAR01 := 2 // VALIDA EXISTENCIA DO PRODUTO = NAO
	
	MSExecAuto({|x,y,z| MATA270(x,y,z)},aVetor,.T.,3)
    
    If ( lMsErroAuto  )
        aLogErr := GetAutoGRLog()
        aLogErr	:= TrataErro( aLogErr ) //Trata log a partir do erro do execauto	
        cLogMsg += 'ERROR Ao incluir INVENTARIO [MATA270] - ' + EncodeUTF8( aLogErr[1] )

        FwMakeDir("integracao_wms\ws\inventario")
        MEMOWRITE("integracao_wms\ws\inventario\"+ NomeAutoLog() + ".log", cLogMsg )

        lRet	:= .F. 
    Else */
        lRet 	:= .T. 
        cLogMsg := "Inventario incluido com sucesso!"
    //EndIf

		// ------------------------------------------------------------
		// MONTA JSON DE RESPOSTA DO REST
		oJsonResponse				:= JsonObject():New()
		oJsonResponse['message'] 	:= cLogMsg 
		oJsonResponse['code'] 		:= IIF( lRet, 200, 400)
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

		If SUBSTR( cLinha, 1, 4 ) $ 'HELP;AJUD'
			lHelp := .T.
		EndIf

		If SUBSTR( cLinha, 1, 6 ) == 'TABELA'
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



Static Function getDtValid(filial, produto, local, lote)

	Local dataValid
	Local cQry

    cQry := " SELECT Substring(B8_DTVALID,7,2)+'/'+Substring(B8_DTVALID,5,2)+'/'+Substring(B8_DTVALID,1,4) AS B8_DTVALID "
	cQry += " FROM SB8010 " 
	cQry += " WHERE D_E_L_E_T_ <> '*' AND B8_FILIAL = '" + filial + "' AND B8_PRODUTO = '" + ALLTRIM(produto) + "' "
	cQry += "       AND B8_LOCAL = '" + local + "' AND B8_LOTECTL = '" + ALLTRIM(lote) + "' "

	CONOUT("CONSULTA ( getDtValid ).: " + cQry)

	TCQuery cQry New Alias "QRY_SB8"
	
	QRY_SB8->(DbGoTop())

	While ! QRY_SB8->(Eof())

        dataValid := QRY_SB8->B8_DTVALID
		
		QRY_SB8->(DbSkip())
	EndDo

	QRY_SB8->(DbCloseArea())

Return dataValid
