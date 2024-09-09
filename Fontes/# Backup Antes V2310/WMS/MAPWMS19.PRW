#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"

WSRESTFUL Precos DESCRIPTION "Retorna as tabelas de Preco" FORMAT "application/json,text/html" 		

	WSMETHOD GET ;
	DESCRIPTION "Retorna as Tabelas de Preco";
	PATH "/Precos/" ;
	PRODUCES APPLICATION_JSON 

ENDWSRESTFUL


WSMETHOD GET WSSERVICE Precos
 
 Local aListPrc := {}
 
 Local lRet := .T.
 
 Local oJsonPrc := JsonObject():New() 
 
 
 
  _cQry := " SELECT DA0_CODTAB, DA0_DESCRI, DA1_CODPRO, B1_DESC, DA1_PRCVEN, DA1_PRCDOL, DA1_PRCEUR, B1_IPI, "
  _cQry += "        CASE WHEN DA0_DATDE = '' THEN '' ELSE SUBSTRING(DA0_DATDE, 7, 2)+'/'+SUBSTRING(DA0_DATDE, 5, 2)+'/'+SUBSTRING(DA0_DATDE, 1, 4) END AS DA0_DATDE, "
  _cQry += "        CASE WHEN DA0_DATATE = '' THEN '' ELSE SUBSTRING(DA0_DATATE, 7, 2)+'/'+SUBSTRING(DA0_DATATE, 5, 2)+'/'+SUBSTRING(DA0_DATATE, 1, 4) END AS DA0_DATATE "
  _cQry += " FROM DA0010 DA0 WITH (NOLOCK) INNER JOIN DA1010 DA1 WITH (NOLOCK) ON DA0_CODTAB = DA1_CODTAB "
  _cQry += "                               INNER JOIN SB1010 SB1 WITH (NOLOCK) ON B1_COD = DA1_CODPRO "
  _cQry += " WHERE DA0.D_E_L_E_T_ <> '*'  AND DA1.D_E_L_E_T_ <> '*'   AND SB1.D_E_L_E_T_ <> '*'   "
  _cQry +="  ORDER BY 1, 5"


  //fecha o alias temporário
  If Select("_DA0") > 0
      dbSelectArea("_DA0")
      dbCloseArea()
  EndIf

  dbUseArea( .T.,"TOPCONN",TcGenQry( ,,_cQry ),"_DA0",.T.,.T. )
  
    contador := 1
    While (_DA0->(!EOF()))
    
        aAdd( aListPrc , JsonObject():New() )
        
        aListPrc[contador]['tabela']           := ALLTRIM(_DA0->DA0_CODTAB)
        aListPrc[contador]['descricao_tabela'] := ALLTRIM(_DA0->DA0_DESCRI)
        aListPrc[contador]['inicio_validade']  := _DA0->DA0_DATDE
        aListPrc[contador]['termino_validade'] := _DA0->DA0_DATATE
        aListPrc[contador]['codigo']           := ALLTRIM(_DA0->DA1_CODPRO)
        aListPrc[contador]['descricao']        := Alltrim( EncodeUTF8( _DA0->B1_DESC ) )
        aListPrc[contador]['preco']            := _DA0->DA1_PRCVEN
        aListPrc[contador]['percentual_ipi']   := _DA0->B1_IPI
        
        _DA0->( DBSkip() )
        contador++
    End
    
    _DA0->( DBCloseArea() )
    
 oJsonPrc['precos'] := aListPrc
 
 //-------------------------------------------------------------------
 // Serializa objeto Json
 //-------------------------------------------------------------------
 cJsonPrc := FwJsonSerialize( oJsonPrc )
 
 FreeObj(oJsonPrc)
 
 Self:SetResponse( cJsonPrc ) //-- Seta resposta

Return( lRet )
