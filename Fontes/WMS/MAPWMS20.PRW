#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"

WSRESTFUL SaldosLote DESCRIPTION "Retorna todos os Saldos por Lote" FORMAT "application/json,text/html" 		
    
    WSMETHOD POST ;
	DESCRIPTION "Retorna todos os Saldos por Lote";
	PATH "/SaldosLote/" ;
	PRODUCES APPLICATION_JSON 

ENDWSRESTFUL


WSMETHOD POST WSSERVICE SaldosLote
 
 Local aListSaldos := {}
 Local lRet := .T.
 Local oJsonSld := JsonObject():New() 
 Local cJson := ""
 Local _produto
 Local _filial
 Local _oSaldo
 Local cCatch
 
/************************************************
    Formato de JSON esperado:
    {
	"saldos": [{
        "filial":"0101",
		"produto": "HR-P1900.TC355"
	}]
}    
************************************************/

     Self:SetContentType("application/json")
    cJson := Self:GetContent() 
    
    oJson    := JsonObject():New()
    cCatch   := oJson:FromJSON(cJson)
    _oSaldo  := oJson:GetJsonObject('saldos')
    _produto := _oSaldo[1]["produto"] 
    _filial  := _oSaldo[1]["filial"] 

  _cQry := " SELECT B8_FILIAL, B8_PRODUTO, B8_LOCAL, B8_LOTECTL, B8_SALDO,  "
  _cQry += "        SUBSTRING(B8_DTVALID, 7, 2)+'/'+SUBSTRING(B8_DTVALID, 5, 2)+'/'+SUBSTRING(B8_DTVALID, 1, 4) AS B8_DTVALID "
  _cQry += " FROM SB8010 SB8 "
  _cQry += " WHERE SB8.D_E_L_E_T_ <> '*' AND B8_SALDO <> 0  "
  _cQry += "       AND B8_PRODUTO = '" + _produto + "' AND B8_FILIAL = '" + _filial + "' "


  //fecha o alias temporário
  If Select("_SB8") > 0
      dbSelectArea("_SB8")
      dbCloseArea()
  EndIf

  dbUseArea( .T.,"TOPCONN",TcGenQry( ,,_cQry ),"_SB8",.T.,.T. )
  
    contador := 1
    While (_SB8->(!EOF()))
    
        aAdd( aListSaldos , JsonObject():New() )
        
        aListSaldos[contador]['filial']        := _SB8->B8_FILIAL
        aListSaldos[contador]['produto']       := _SB8->B8_PRODUTO
        aListSaldos[contador]['armazem']       := _SB8->B8_LOCAL
        aListSaldos[contador]['lote']          := _SB8->B8_LOTECTL
        aListSaldos[contador]['saldo_lote']    := _SB8->B8_SALDO
        aListSaldos[contador]['data_validade'] := _SB8->B8_DTVALID
        
        _SB8->( DBSkip() )
        contador++
    End
    
    _SB8->( DBCloseArea() )
    
 oJsonSld['saldos'] := aListSaldos
 
 //-------------------------------------------------------------------
 // Serializa objeto Json
 //-------------------------------------------------------------------
 cJsonSld := FwJsonSerialize( oJsonSld )
 
 FreeObj(oJsonSld)
 FreeObj(oJson)
 
 Self:SetResponse( cJsonSld ) //-- Seta resposta

Return( lRet )
