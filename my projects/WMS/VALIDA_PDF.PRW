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

//USER FUNCTION VALIDA_PDF()
USER FUNCTION VALIDA_PDF(chave, nota, serie)

Local continua := .T.

    //PREPARE ENVIRONMENT EMPRESA "01" FILIAL "0101" MODULO "FAT" 

        //SF2->(DBGOTO( 202330 ))

        //ESPERO JÁ ESTAR POSICIONADO NA FILIAL CORRETA E ESTAR POSICIONADO NA SF2**
        
        // SE EXISTEM OS DOIS ARQUIVOS ABAIXO, SIGNIFICA QUE O ARQUIVO ESTÁ CORROMPIDO
        IF FILE("\pdf_wms\"+"pdf\"+ chave +".pd_") .AND. FILE("\pdf_wms\"+"pdf\"+ chave +".rel.log")
            // APAGAR OS 3 ARQUIVOS EXISTENTES
            IF FERASE("\pdf_wms\"+"pdf\"+ chave +".pdf") == -1
                CONOUT('FALHA NA EXCLUSAO DO ARQUIVO .PDF ( FERROR'+str(ferror(),4)+ ')')
                continua := .F.
            ENDIF
            IF continua == .T.
                IF FERASE("\pdf_wms\"+"pdf\"+ chave +".pd_") == -1
                    CONOUT('FALHA NA EXCLUSAO DO ARQUIVO .PD_ ( FERROR'+str(ferror(),4)+ ')')
                    continua := .F.
                ENDIF
                IF continua == .T.
                    IF FERASE("\pdf_wms\"+"pdf\"+ chave +".rel.log") == -1
                        CONOUT('FALHA NA EXCLUSAO DO ARQUIVO .REL.LOG ( FERROR'+str(ferror(),4)+ ')')
                        continua := .F.
                    ENDIF
                ENDIF
            ENDIF

        ENDIF

        IF continua == .T.
            // GERAR O ARQUIVO PDF NOVAMENTE
            //u_wGerDanfe(_SF2->F2_CHVNFE, _SF2->F2_DOC, _SF2->F2_SERIE, "\pdf_wms\", '', 2)
            u_wGerDanfe( chave, nota, serie, "\pdf_wms\", '', 2)
        ENDIF
        
    //RESET ENVIRONMENT

RETURN .T.
