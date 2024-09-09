#INCLUDE 'TOTVS.ch'

/*--------------------------------------------------------------------------------------------------*
| Func:  MT100CLA()                                                     							              |
| Autor: Valmor Marchi                                              								                |
| Data:  08/02/2022                                                   								              |
| Desc:  Este ponto de entrada pertence � rotina de Classifica��o do Documento de Entrada           |
|		                                                                          					            |
|																								                                                  	|
| Altera��es .:  /                                                            					            |
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
        msg := "H� itens ainda n�o conferidos pelo WMS. VERIFIQUE!"
        exit
    Case _SD1->D1_QUANT1 <> _SD1->D1_QUANT
        _bContinua := .F.
        msg := "Item "+Alltrim(SD1->D1_ITEM)+" C�d. "+Alltrim(SD1->D1_COD)+" est� com a QUANTIDADE informada na digita��o diferente da conferida pelo WMS. VERIFIQUE!"
        exit
    Case _SD1->D1_LOTE1 <>  _SD1->D1_LOTECTL
        _bContinua := .F.
         msg := "Item "+Alltrim(SD1->D1_ITEM)+" C�d. "+Alltrim(SD1->D1_COD)+" est� com LOTE informadO na digita��o diferente do conferido pelo WMS. VERIFIQUE!"
         exit
    EndCase
    _SD1->(DbSkip())
  End
  _SD1->(DBCloseArea())

  if !_bContinua
    MsgAlert(msg, "ATEN��O!!")
  endIf



Return _bContinua
