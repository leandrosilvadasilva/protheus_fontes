#Include "Protheus.ch"
#INCLUDE "RESTFUL.CH"
#INCLUDE "topconn.CH"
#INCLUDE "TBICONN.ch"



// NUMERO DO LOTE NO ATIVO
USER FUNCTION XNRLT()

    Local retorno := ''

    IF INCLUI .AND. ISINCALLSTACK("GERAENTRADAATIVO") 

        IF RIGHT(ALLTRIM(SD1->D1_COD), 3) == 'IMB'
            retorno := SD1->D1_LOTECTL
            //IATAN EM 07/05/2024 - APROVEITA A SITUÇÃO E OS POSICIONAMENTOS PARA ATUALIZAR A TABELA DE PREÇOS 024 CONFORME SOLICITADO PELO EDER
            ATU_DA1()
        ENDIF

    ENDIF

RETURN retorno

//DATA DE FABRICAÇÃO DO LOTE
USER FUNCTION XDTFABLT()

    Local retorno := STOD("")

    IF INCLUI .AND. ISINCALLSTACK("GERAENTRADAATIVO") 

        IF RIGHT(ALLTRIM(SD1->D1_COD), 3) == 'IMB'
            retorno := SD1->D1_DFABRIC
        ENDIF

    ENDIF
 
RETURN retorno

// DATA DE VALIDADE DO LOTE
USER FUNCTION XDTVLLT()

    Local retorno := STOD("")

    IF INCLUI  .AND. ISINCALLSTACK("GERAENTRADAATIVO") 

        IF RIGHT(ALLTRIM(SD1->D1_COD), 3) == 'IMB'
            retorno := SD1->D1_DTVALID
        ENDIF

    ENDIF

RETURN retorno


STATIC FUNCTION ATU_DA1()

  Local _cQry     := ""
  Local encontrou := .F.

  _cQry := " SELECT * "
  _cQry += " FROM DA1010 "
  _cQry += " WHERE D_E_L_E_T_ <> '*'   "
  _cQry += "    AND DA1_CODTAB = '024' "
  _cQry += "    AND DA1_CODPRO = '"+SD1->D1_COD+"' "

	dbUseArea( .T.,"TOPCONN",TcGenQry( ,,_cQry ),"_SD1",.T.,.T. )
  
  While (_SD1->(!EOF()))

    encontrou := .T.

    DA1->( DBGOTO( _SD1->R_E_C_N_O_ ) )
    RECLOCK("DA1", .F.)
        DA1->DA1_PRCVEN := SD1->D1_VUNIT
    DA1->( MSUNLOCK() )

    _SD1->(DbSkip())

  End
  _SD1->(DBCloseArea())

  IF encontrou == .F.
        RECLOCK("DA1", .T.)
            DA1->DA1_FILIAL := XFILIAL("DA1")
            DA1->DA1_ITEM := Soma1( ultimoItem() )
            DA1->DA1_CODTAB := '024'
            DA1->DA1_CODPRO := SD1->D1_COD
            DA1->DA1_PRCVEN := SD1->D1_VUNIT
            DA1->DA1_ATIVO := '1'
            DA1->DA1_TPOPER := '4'
            DA1->DA1_MOEDA := 1
            DA1->DA1_DATVIG := DDATABASE
            DA1->DA1_TIPO := SD1->D1_TP
        DA1->(MSUNLOCK())
  ENDIF

RETURN


STATIC FUNCTION ultimoitem()

  Local _cQry     := ""
  Local ultimo := ''

  _cQry := " SELECT MAX(DA1_ITEM) AS DA1_ITEM "
  _cQry += " FROM DA1010 "
  _cQry += " WHERE D_E_L_E_T_ <> '*'   "
  _cQry += "    AND DA1_CODTAB = '024' "

	dbUseArea( .T.,"TOPCONN",TcGenQry( ,,_cQry ),"_DA1",.T.,.T. )
  
  While (_DA1->(!EOF()))

    ultimo := _DA1->DA1_ITEM

    _DA1->(DbSkip())

  End
  _DA1->(DBCloseArea())


RETURN ultimo
