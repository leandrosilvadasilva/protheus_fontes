#Include "Protheus.ch"
#Include "Colors.ch"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"
#Include "TOTVS.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#Include "CI_M001.CH"
#INCLUDE "TbiConn.ch"
#Include "RESTFUL.CH"
#include 'shell.ch'


/*
    IATAN EM 24/07/2022 - ARQUIVO RESPONSÁVEL POR GERAR PDF E XML VIA JOB
*/
USER FUNCTION VALIDASPED()
    
    Local _cQry      := ''
    Local referencia := ''
    Local nX

    Local listaNotas   := {}

    PREPARE ENVIRONMENT EMPRESA "01" FILIAL "0101" MODULO "FAT" 



    _cQry += " SELECT DISTINCT SUBSTRING(NFE_ID, 1, 3) AS SERIE, SUBSTRING(NFE_ID, 4, 9) AS NOTA "
    _cQry += " FROM SPED054  "
    _cQry += " WHERE D_E_L_E_T_ <> '*' AND NFE_ID LIKE '6  %' AND DTREC_SEFR >= '20230401' AND CSTAT_SEFR = '100' "
    _cQry += " ORDER BY 2 "

    dbUseArea( .T.,"TOPCONN",TcGenQry( ,,_cQry ),"_SF2",.T.,.T. )
    
    While (_SF2->(!EOF()))

        IF VAL(_SF2->NOTA) <> referencia+1 .AND. referencia <> ''
            //ENCONTROU UMA FALHA NA SEQUENCIA DE NUMERAÇÃO
            diferenca := ( (VAL(_SF2->NOTA)) - (referencia+1)  )
            FOR nX := 1 TO diferenca
                    AADD(listaNotas, {_SF2->SERIE, CVALTOCHAR(referencia+nX)})
            NEXT
        ENDIF

        referencia := VAL(_SF2->NOTA)

        _SF2->(DbSkip())

    End
    _SF2->(DBCloseArea())


RESET ENVIRONMENT  

RETURN


