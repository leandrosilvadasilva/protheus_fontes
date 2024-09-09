#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"

WSRESTFUL CustosTransf DESCRIPTION "Retorna os Custos de Transferencia entre Filiais" FORMAT "application/json,text/html" 		
    
    WSMETHOD POST ;
	DESCRIPTION "Retorna os Custos de Transferencia entre Filiais";
	PATH "/CustosTransf/" ;
	PRODUCES APPLICATION_JSON 

ENDWSRESTFUL


WSMETHOD POST WSSERVICE CustosTransf
 
 Local aListCustos := {}
 Local lRet := .T.
 Local oJsonCst := JsonObject():New() 
 Local cJson := ""
 Local _produto
 Local _filial
 Local _oCustos
 Local cCatch
 Local _TES
 Local nX
/************************************************
    Formato de JSON esperado:

{
	"custos": [{
        "filial":"0102",
		"produto": "355/5814            ",
		"cliente": "000001",
		"loja": "0001",
		"custo": 0
	}]
}
     
************************************************/

     Self:SetContentType("application/json")
    cJson := Self:GetContent() 
    
    oJson     := JsonObject():New()
    cCatch    := oJson:FromJSON(cJson)
    _oCustos  := oJson:GetJsonObject('custos')

    For nX := 1 to Len(_oCustos)

        _produto  := _oCustos[nX]["produto"] 
        _cliente  := _oCustos[nX]["cliente"] 
        _loja     := _oCustos[nX]["loja"] 
        _filial   := _oCustos[nX]["filial"] 
        //POSICIONANDO NA FILIAL CORRETA
        CFILANT := _filial
        //OPERAÇÃO SEMPRE É "04" - INFORMADO POR EDER
        _TES      := MaTesInt(2, "04", _cliente, _loja, "C", _produto, NIL) //ROTINA PARA BUSCAR A TES INTELIGENTE

        aAdd( aListCustos , JsonObject():New() )
        
        aListCustos[nX]['filial']   := _filial
        aListCustos[nX]['cliente']  := _cliente
        aListCustos[nX]['loja']     := _loja
        aListCustos[nX]['produto']  := _produto
        aListCustos[nX]['custo']    := U_FCUSXVEN( _TES, _produto, "01", "007") // nos gatilhos da produção está chumbado tabela "007" -- utilizando a mesma lógica

    Next

    oJsonCst['custos'] := aListCustos
 
 //-------------------------------------------------------------------
 // Serializa objeto Json
 //-------------------------------------------------------------------
 cJsonCst := FwJsonSerialize( oJsonCst )
 
 FreeObj(oJsonCst)
 FreeObj(oJson)
 
 Self:SetResponse( cJsonCst ) //-- Seta resposta

Return( lRet )
