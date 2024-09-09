#INCLUDE "TOTVS.CH"

User Function M410RLIB()
Local aSaldoSDC := PARAMIXB
Local lPrivateInclui := INCLUI                                 AS LOGICAL
Local lAutomatico    := AllTrim( __CINTERNET ) == "AUTOMATICO" AS LOGICAL
Local lExecAuto      := IsBlind()                              AS LOGICAL
Local lIntegLinx     := FwIsIncallStack( "MyMATA410ExeAuto")   AS LOGICAL
Local lLinxInteg     := FwIsIncallStack( "MAWSLNX20")          AS LOGICAL

    PutMV( "MV_BLOQUEI", .T. )

Return aSaldoSDC
