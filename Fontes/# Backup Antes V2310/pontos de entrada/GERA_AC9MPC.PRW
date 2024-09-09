#Include "Protheus.ch"
#Include "Colors.ch"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"
#Include "TOTVS.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "TBICONN.CH"
#Include "RESTFUL.CH"
#include 'shell.ch'

/*
    IATAN EM 23/10/2022 - GRAR BANCO DE CONHECIMENTO PARA PRESTAÇÃO DE DESPESAS DE VIAGEM
*/
USER FUNCTION GERAAC9MPC()
    Local _cQry     := ''
    Local arrInfo := GetUserInfoArray()
    Local contador := 0
    Local nX := 1

    FOR nX := 1 TO LEN(arrInfo)
        IF ALLTRIM(arrInfo[nX][5]) == "U_GERAAC9MPC"
            contador++
        ENDIF
    NEXT nX
     
    IF contador > 1 // 1 = THREAD ATUAL
        CONOUT("--->> SAINDO DA ROTINA GERAAC9MPC POIS ESTA JA ESTA SENDO EXECUTADA EM OUTRO THREAD<<---")
        RETURN
    ENDIF

    PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01" MODULO "COM" 

    _cQry := " SELECT CR_FILIAL+TRIM(CR_NUM)+'0001' AS CODENT, CR_XDESPV, AC9.AC9_CODOBJ, AC9_B.AC9_CODOBJ AS CODOBJ, SCR.* "
    _cQry += " FROM SCR010 SCR LEFT  JOIN AC9010 AC9 ON AC9.D_E_L_E_T_ <> '*' AND AC9_ENTIDA = 'SC7' AND AC9_CODENT = CR_FILIAL+TRIM(CR_NUM)+'0001' "
    _cQry += " INNER JOIN AC9010 AC9_B ON AC9_B.D_E_L_E_T_ <> '*' AND AC9_B.AC9_ENTIDA = 'FLE' AND AC9_B.AC9_CODENT LIKE CR_FILIAL+'2'+TRIM(CR_XDESPV)+'%' "
    _cQry += " WHERE SCR.D_E_L_E_T_ <> '*' AND CR_EMISSAO = '" + DTOS(dDataBase) + "' AND AC9.AC9_CODOBJ IS NULL "

    dbUseArea( .T.,"TOPCONN",TcGenQry( ,,_cQry ),"_AC9",.T.,.T. )
    
    While (_AC9->(!EOF()))

        CFILANT := _AC9->CR_FILIAL

        RECLOCK("AC9", .T.)
            AC9->AC9_FILIAL := SUBSTRING(_AC9->CR_FILIAL, 1, 2)
            AC9->AC9_FILENT := ALLTRIM(_AC9->CR_FILIAL)
            AC9->AC9_ENTIDA := 'SC7'
            AC9->AC9_CODENT := _AC9->CODENT
            AC9->AC9_CODOBJ := _AC9->CODOBJ
        AC9->(MsUnlock())

        _AC9->(DbSkip())

    End
    _AC9->(DBCloseArea())

RESET ENVIRONMENT

RETURN
