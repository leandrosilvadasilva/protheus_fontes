#include "protheus.ch"
#include "totvs.ch"
#include "tbiconn.ch"
#include "topconn.ch"
#include "restful.ch"

#DEFINE _sEnter  CHR(13)+CHR(10)


/*--------------------------------------------------------------------------------------------------*
| Func:  MAPWMS06()                                                      							|
| Autor: Valmor Marchi                                              								|
| Data:  11/02/2022                                                   								|
| Desc:  Webservice RESTFUL de integração de CONFIRMAÇÃO DE CONFERENCIA vindos do WMS da AKR			|
|		 Endpoint: https://api.diwibom.com.br:9910/CUSTOMERSERVICES.apw						    	|
|		 																							|
| Alterações .:  /                                                            						|
*--------------------------------------------------------------------------------------------------*/

WSRESTFUL RETORNACONFERENCIA DESCRIPTION "Retorna Conferencia da Pre Nota"

WSMETHOD POST DESCRIPTION "Retorna Conferencia da Pre Nota" WSSYNTAX "/RETORNACONFERENCIA" path "/RETORNACONFERENCIA"

END WSRESTFUL

WSMETHOD POST WSSERVICE RETORNACONFERENCIA

LOCAL cJson := ""
Local oJson        As Object
LOCAL cCatch       As Object
Local nQtdWMS		:= 0
Local cLote 		:= ""
Local cLogMsg		:= ""
Local _x := 0
Local aParam := {}
Local lRet          := .F.
Local filialATUAL   := CFILANT

Self:SetContentType("application/json")
cJson := Self:GetContent() 

/************************************************
    Formato de JSON esperado:

    {
	"conferencia": [{
		"codigo_fornecedor": "000052",
		"numero_documento": "000110991/4",  --> Aqui é nro. Documento / série
		"item_documento": "0001",
		"codigo_produto": "HR-P1900.TC355",
		"quantidade": 1,
		"lote": "N307AM2596",
        "filial":"0101"
	}]
}    




************************************************/
oJson              := JsonObject():New()
cCatch             := oJson:FromJSON(cJson)

If cCatch == Nil   
    _oConfer := oJson:GetJsonObject('conferencia')

	IF _oConfer[1]["filial"] == '0102'
		CFILANT := '0102'
	ELSEIF _oConfer[1]["filial"] == '0103'
		CFILANT := '0103'
	ELSEIF _oConfer[1]["filial"] == '0104'
		CFILANT := '0104'
    ELSEIF _oConfer[1]["filial"] == '0105'
		CFILANT := '0105'
    ELSEIF _oConfer[1]["filial"] == '0106'
		CFILANT := '0106'    
    ELSEIF _oConfer[1]["filial"] == '0107'
		CFILANT := '0107'
	ELSEIF _oConfer[1]["filial"] == '5001'
		CFILANT := '5001'
	ENDIF

    For _x := 1 to Len(_oConfer)
        cCodForn 		:= _oConfer[_x]["codigo_fornecedor"]
        cNumDoc 		:= _oConfer[_x]["numero_documento"]
        cSerieDoc 		:= _oConfer[_x]["serie_documento"]
        cItemDoc		:= _oConfer[_x]["item_documento"]
        cCodProd 		:= _oConfer[_x]["codigo_produto"]
        nQtdWMS			:= _oConfer[_x]["quantidade"]
        cLote			:= _oConfer[_x]["lote"]

        AADD(aParam, {cCodForn,cNumDoc,cSerieDoc, cItemDoc,cCodProd,nQtdWMS,cLote})
    Next

	// -----------------------------------------------------
	// Valida se os dados estão todos preenchidos
	If ChkJson( aParam, @cLogMsg )	
		
        // -----------------------------------------------------
		// Faz a atualização da conferência dos itens da pré-nota
		lRet := U_MAPWMS10( aParam, @cLogMsg )
	
	EndIf 
	// ------------------------------------------------------------
	// MONTA JSON DE RESPOSTA DO REST
	oJsonResponse:= JsonObject():New()
    oJsonResponse['parametro'] 	:= aParam
	oJsonResponse['message'] 	:= cLogMsg
	oJsonResponse['code'] 		:= IIF( lRet,  200, 400)
    Self:SetResponse(oJsonResponse)	

	CFILANT := filialATUAL


Else 
  SetRestFault(400, " Json Invalido!")
  Return .F.
EndIf 	

Return( lRet )


// -----------------------------------------------------+
// Valida os dados recebido do WMS                      |
// aParam[1] -> Código Fornecedor   					|
// aParam[2] -> Numero Pré-Nota							|
// aParam[3] -> Item Pré-Nota 							|
// aParam[4] -> Código do Produto                       |
// aParam[5] -> Quantidade WMS							|
// aParam[6] -> Lote     								|
// -----------------------------------------------------+
Static Function ChkJson( aParam, cLogMsg )

Local lRet := .T. 
	

Return( lRet )


// -----------------------------------------------------+
// Salva os dados recebido na pré-nota                  |
// aParam[1] -> Código Fornecedor   					|
// aParam[2] -> Numero Pré-Nota							|
// aParam[3] -> Serie Pré-Nota							|
// aParam[4] -> Item Pré-Nota 							|
// aParam[5] -> Código do Produto                       |
// aParam[6] -> Quantidade WMS							|
// aParam[7] -> Lote     								|
// -----------------------------------------------------+
 User Function MAPWMS10( aParam, cLogMsg )
    Local cCodForn := ""
    Local cNumDoc := ""
    Local cItemDoc := ""
    Local cCodProd := ""
    Local nQtde := 0
    Local cLote := ""
    Local _x := 0
    Local lRet := .F.
    Local especie

    cLogMsg := ""
    DbSelectArea("SD1")
    SD1->(DbSetOrder(1)) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
    
    //IATAN EM 05/11/2022 - VERIFICAÇÃO SE EXISTE ALGUM ITEM PASSADO PELO WMS DIFERENTE DA SD1
    //                      CASO EXISTA A OPERAÇÃO NÃO DEVE SER REALIZADA
    For _x := 1 to Len(aParam)
        cCodForn    := aParam[_x][1]
        cNumDoc     := aParam[_x][2]
        cSerieDoc   := aParam[_x][3]
        cItemDoc    := aParam[_x][4]
        cCodProd    := aParam[_x][5]
        nQtde       := aParam[_x][6]
        cLote       := aParam[_x][7]

        CONOUT("Filial.: " + CFILANT)
        CONOUT("cNumDoc.: " + cNumDoc)
        CONOUT("cSerieDoc.: " + cSerieDoc)
        CONOUT("cCodForn.: " + cCodForn)
        CONOUT("cCodProd.: " + cCodProd)
        CONOUT("cItemDoc.: " + cItemDoc)

        If SD1->(DbSeek( xFilial("SD1") +;
            PadR(cNumDoc  ,TamSX3("D1_DOC")[1],"")+;
            PadR(cSerieDoc,TamSX3("D1_SERIE")[1],"")+;
            PadR(cCodForn ,TamSX3("D1_FORNECE")[1]+TamSX3("D1_LOJA")[1],"")+; // PadR("0003"   ,TamSX3("D1_LOJA")[1],"")+;
            PadR(cCodProd ,TamSX3("D1_COD")[1],"")+;
            PadR(cItemDoc ,TamSX3("D1_ITEM")[1],"");
            ))

            If SD1->D1_CONFWMS <> 'S' //Se não tiver sido conferido ainda
                
                IF SD1->D1_QUANT <> nQtde .OR. ALLTRIM(SD1->D1_LOTECTL) <> ALLTRIM(cLote)
                    cLogMsg += "Quantidade recebida divergente da quantidade do item da NF. Alteração não permitida."
                    conout(cLogMsg)
                    RETURN .F. 
                ENDIF

            EndIf
            //IATAN EM 11/07/2023
            xEspecie := ""
            xNota    := ""
            //getEspecie(CFILANT, cNumDoc, cSerieDoc, cCodForn, @xEspecie, @xNota )
            //F1_FILIAL+F1_FORNECE+F1_LOJA+F1_DOC                                                                                                                             
            POSICIONE("SF1", 2, SD1->D1_FILIAL+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_DOC, "F1_ESPECIE")
            // IATAN EM 09/05/2024 -- NOTAS DE ATIVO SÃO DO TIPO NFE E PRECISAM SER INTEGRADAS
            IF SF1->F1_SERIE == 'IMB'
                // SERIE IMB FAZ REFERENCIA AO PROCESSO DO ATIVO
                // NOTAS DE ATIVO DEVEM SER INTEGRADAS NORRMALMENTE
            ELSEIf ALLTRIM(SF1->F1_ESPECIE) <> 'SPED'
                    cLogMsg += "Somente Notas da Especie SPED podem ser integradas com o WMS. "
                    cLogMsg += "Nota.: " + SF1->F1_DOC + ", Especie.: " + SF1->F1_ESPECIE
                    conout(cLogMsg)
                    RETURN .F. 
            EndIf
            
        EndIf

    Next  
    //IATAN EM 05/11/2022 - CASO TENHA PASSADO PELA VALIDAÇÃO ACIMA ... SEGUE O FLUXO
    For _x := 1 to Len(aParam)
        cCodForn    := aParam[_x][1]
        cNumDoc     := aParam[_x][2]
        cSerieDoc   := aParam[_x][3]
        cItemDoc    := aParam[_x][4]
        cCodProd    := aParam[_x][5]
        nQtde       := aParam[_x][6]
        cLote       := aParam[_x][7]

        CONOUT("Filial.: '" + CFILANT + "'")
        CONOUT("cNumDoc.: '" + cNumDoc + "'")
        CONOUT("cSerieDoc.: '" + cSerieDoc + "'")
        CONOUT("cCodForn.: '" + cCodForn + "'")
        CONOUT("cCodProd.: '" + cCodProd + "'")
        CONOUT("cItemDoc.: '" + cItemDoc + "'")

        If SD1->(DbSeek( xFilial("SD1") +;
            PadR(cNumDoc  ,TamSX3("D1_DOC")[1],"")+;
            PadR(cSerieDoc,TamSX3("D1_SERIE")[1],"")+;
            PadR(cCodForn ,TamSX3("D1_FORNECE")[1]+TamSX3("D1_LOJA")[1],"")+; // PadR("0003"   ,TamSX3("D1_LOJA")[1],"")+;
            PadR(cCodProd ,TamSX3("D1_COD")[1],"")+;
            PadR(cItemDoc ,TamSX3("D1_ITEM")[1],"");
            ))

            If SD1->D1_CONFWMS <> 'S' //Se não tiver sido conferido ainda
                
                RecLock("SD1", .F.)
                    SD1->D1_QUANT1 := SD1->D1_QUANT
                    SD1->D1_LOTE1 := SD1->D1_LOTECTL
                    SD1->D1_QUANT := nQtde
                    SD1->D1_LOTECTL := Alltrim(cLote)
                    SD1->D1_CONFWMS := 'S'
                SD1->(MsUnlock())

                cLogMsg += "Conferencia do item "+Alltrim(cItemDoc)+" da Pre-Nota "+cNumDoc+" atualizado com sucesso."
                conout(cLogMsg)
                lRet := .T. 

            Else
                cLogMsg += "Item "+Alltrim(cItemDoc)+" da Pre-Nota "+cNumDoc+" ja conferido. Nada foi feito."
                conout(cLogMsg)
            EndIf
            
        Else 
            cLogMsg += "O item da nota informado nao foi localizado do sistema. Revise os parametros."
            conout(cLogMsg)            
        EndIf

    Next  

Return( lRet )

