#include "Protheus.ch"
#include "tbiconn.ch"
#include "topconn.ch"
#include "restful.ch"
#include "FWMVCDEF.ch"
#Include "TOTVS.ch" 
#INCLUDE "rwmake.ch"


//IATAN EM 12/12/2023
User Function M110STTS()
 
Local cNumSol   := Paramixb[1]
Local nOpt      := Paramixb[2]
Local lCopia    := Paramixb[3]
Local aArea     := GETAREA()
Local sql       := ""
Local contador  := 1
Local alcada    := GETMV("MV_XALCSC")
Local codAprov  := ""
Local codUser   := ""
 
sql += "  SELECT C1_FILIAL, C1_NUM, C1_ITEM, C1_CC, SC1.R_E_C_N_O_ , ZA9_APROV, USR_EMAIL, USR_NOME, AK_USER, AK_COD "
sql += "  FROM SC1010 SC1 LEFT JOIN ZA9010 ZA9 ON ZA9.D_E_L_E_T_ <> '*' AND ZA9_FILIAL = C1_FILIAL AND ZA9_CC = C1_CC "
sql += "                  LEFT JOIN SAK010 SAK ON SAK.D_E_L_E_T_ <> '*' AND AK_FILIAL = C1_FILIAL AND AK_COD = ZA9_APROV  "
sql += "                  LEFT JOIN SYS_USR USR ON USR.D_E_L_E_T_ <> '*' AND USR_ID = AK_USER "
sql += "  WHERE SC1.D_E_L_E_T_ <> '*' AND C1_NUM = '" + SC1->C1_NUM + "' AND C1_FILIAL = '" + SC1->C1_FILIAL + "' "

    IF nOpt == 1     
    //INCLUSÃO

        IF !EMPTY(ALLTRIM(alcada))

            TCQuery sql New Alias "QRY_SC1"
            
            QRY_SC1->(DbGoTop())

            While ! QRY_SC1->(Eof())

                //VALIDO SOMENTE NO PRIMEIRO ITEM
                IF contador == 1
                    IF EMPTY(ALLTRIM(QRY_SC1->C1_CC))
                        ALERT("SC SEM CENTRO DE CUSTO NÃO SERÁ BLOQUEADA")
                        EXIT
                    ENDIF
                    IF EMPTY(ALLTRIM(QRY_SC1->ZA9_APROV))
                        ALERT("SC SEM APROVADOR PARA O CENTRO DE CUSTO " + ALLTRIM(QRY_SC1->C1_CC) + " NA FILIAL " + QRY_SC1->C1_FILIAL )
                        EXIT
                    ENDIF
                    IF EMPTY(ALLTRIM(QRY_SC1->USR_EMAIL))
                        ALERT("EMAIL DO APROVADOR " + ALLTRIM(QRY_SC1->USR_NOME) + " NÃO CONFIGURADO")
                        //EXIT
                    ENDIF

                ENDIF

                SC1->( DBGOTO( QRY_SC1->R_E_C_N_O_ ) )

                RECLOCK("SC1", .F.)
                    SC1->C1_APROV := 'B'
                SC1->( MSUNLOCK() )

                IF contador == 1
                    RECLOCK("SCR", .T.)
                        SCR->CR_FILIAL  := QRY_SC1->C1_FILIAL
                        SCR->CR_NUM     := QRY_SC1->C1_NUM
                        SCR->CR_TIPO    := 'SC'
                        SCR->CR_USER    := QRY_SC1->AK_USER
                        SCR->CR_APROV   := QRY_SC1->AK_COD
                        SCR->CR_NIVEL   := '01'
                        SCR->CR_STATUS  := '02'
                        SCR->CR_EMISSAO := DDATABASE
                    SCR->( MSUNLOCK() )
                ENDIF

                contador++

                RECLOCK("DBM", .T.)
                    DBM->DBM_FILIAL := QRY_SC1->C1_FILIAL
                    DBM->DBM_TIPO   := 'SC'
                    DBM->DBM_NUM    := QRY_SC1->C1_NUM
                    DBM->DBM_ITEM   := QRY_SC1->C1_ITEM
                    DBM->DBM_USER   := QRY_SC1->AK_USER
                    DBM->DBM_APROV  := '2'
                    DBM->DBM_USAPRO := QRY_SC1->AK_USER
                DBM->( MSUNLOCK() )

                

                QRY_SC1->(DbSkip())
            EndDo

            QRY_SC1->(DbCloseArea())

            IF CONTADOR > 1
                // MANDA WORKFLOW
            ENDIF
        
        ENDIF

    ENDIF
     
RESTAREA(aArea)

Return Nil
