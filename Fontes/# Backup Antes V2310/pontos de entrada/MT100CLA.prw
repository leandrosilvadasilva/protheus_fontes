#INCLUDE 'TOTVS.ch'

/*--------------------------------------------------------------------------------------------------*
| Func:  MT100CLA()                                                     							              |
| Autor: Valmor Marchi                                              								                |
| Data:  08/02/2022                                                   								              |
| Desc:  Este ponto de entrada pertence à rotina de Classificação do Documento de Entrada           |
|		                                                                          					            |
|																								                                                  	|
| Alterações .:  /                                                            					            |
*--------------------------------------------------------------------------------------------------*/

User Function MT100CLA()
  Local _cQry := ""
  Local _bContinua := .T.




  _cQry := " SELECT D1_DOC, D1_SERIE, D1_FORNECE,D1_ITEM, D1_COD, D1_QUANT, D1_LOTECTL, D1_QUANT1, D1_LOTE1, D1_CONFWMS "
  _cQry += "   FROM "+RetSqlTab("SD1")+" "
  _cQry += "   WHERE "+RetSqlCond("SD1")+" "
  _cQry += "    AND D1_DOC = '"+SF1->F1_DOC+"' "
  _cQry += "    AND D1_SERIE = '"+SF1->F1_SERIE+"' "
  _cQry += "    AND D1_FORNECE = '"+SF1->F1_FORNECE+"'"
  _cQry := ChangeQuery(_cQry)
	dbUseArea( .T.,"TOPCONN",TcGenQry( ,,_cQry ),"_SD1",.T.,.T. )
  
  While (_SD1->(!EOF()))
    Do Case
    Case _SD1->D1_CONFWMS <> 'S'
        _bContinua := .F.
        msg := "Há itens ainda não conferidos pelo WMS. VERIFIQUE!"
        exit
    Case _SD1->D1_QUANT1 <> _SD1->D1_QUANT
        _bContinua := .F.
        msg := "Item "+Alltrim(SD1->D1_ITEM)+" Cód. "+Alltrim(SD1->D1_COD)+" está com a QUANTIDADE informada na digitação diferente da conferida pelo WMS. VERIFIQUE!"
        exit
    Case _SD1->D1_LOTE1 <>  _SD1->D1_LOTECTL
        _bContinua := .F.
         msg := "Item "+Alltrim(SD1->D1_ITEM)+" Cód. "+Alltrim(SD1->D1_COD)+" está com LOTE informadO na digitação diferente do conferido pelo WMS. VERIFIQUE!"
         exit
    EndCase
    _SD1->(DbSkip())
  End
  _SD1->(DBCloseArea())

  if !_bContinua
    MsgAlert(msg, "ATENÇÃO!!")
  endIf



Return _bContinua
