/*
    IATAN EM 11/09/2022

    DESENVOLVIDO PARA FAZER OS TRATAMENTOS DE APROVACAO DAS DESPESAS DE VIAGEM

*/

#Include "Protheus.ch" 
#Include "RPTDEF.CH"
#Include "FwPrintSetup.ch"
#Include "CI_M001.CH"
#INCLUDE "TbiConn.ch"
#Include "RPTDEF.CH"
#Include "FwPrintSetup.ch"
#Include "CI_M001.CH"
#INCLUDE "TbiConn.ch" 


User Function MT097APR() 

    Local aArea := GETAREA()
    Local recnoFLF 
    Local crTotal
    Local crXdespv
    Local c7Fornece
    Local c7Loja
    
    IF !EMPTY(ALLTRIM(SCR->CR_XDESPV)) 
        //DESPESAS PROVENIENTES DO DESPESAS DE VIAGEM
        recnoFLF := getFLF(SCR->CR_FILIAL, SCR->CR_XDESPV)
        
        FLF->(DBGOTO( recnoFLF ))

        IF ALLTRIM(FLF->FLF_STATUS) $ '1-2-3' // SIGNIFICA QUE A DESPESA ESTA SENDO APROVADA PELO LIDER

            RECLOCK("FLF", .F.)
                FLF->FLF_STATUS := "4"
                FLF->FLF_CONFER := POSICIONE("RD0", 1, XFILIAL("RD0")+FLF->FLF_PARTIC, "RD0_XLID")
                FLF->FLF_DTCONF := DDATABASE
            FLF->(MsUnlock())

            xNumSC7 := GETNUMSC7()  
            c7Fornece := POSICIONE("SC7", 1, SCR->CR_FILIAL+ALLTRIM(SCR->CR_NUM), "C7_FORNECE")
            c7Loja := POSICIONE("SC7", 1, SCR->CR_FILIAL+ALLTRIM(SCR->CR_NUM), "C7_LOJA")
            RECLOCK("SC7", .T.)
                SC7->C7_FILIAL  := XFILIAL("SC7")
                SC7->C7_NUM     := xNumSC7
                SC7->C7_TIPO    := 1
                SC7->C7_ITEM    := "0001"
                SC7->C7_PRODUTO := "0000252"
                SC7->C7_DESCRI  := "DESPESAS DE VIAGEM"
                SC7->C7_UM      := "UN"
                SC7->C7_FISCORI := XFILIAL("SC7")
                SC7->C7_MOEDA   := 1
                SC7->C7_QUANT   := 1
                SC7->C7_PRECO   := SCR->CR_TOTAL
                SC7->C7_TOTAL   := SCR->CR_TOTAL
                SC7->C7_LOCAL   := "01"
                SC7->C7_OBS     := "PRESTACAO DE CONTAS DE VIAGEM"
                SC7->C7_FORNECE := c7Fornece
                SC7->C7_LOJA    := c7Loja
                SC7->C7_COND    := "002"
                SC7->C7_FILENT  := XFILIAL("SC7")
                SC7->C7_EMISSAO := DDATABASE
                SC7->C7_CONAPRO := "B"
            SC7->(MsUnlock())
            RECLOCK("SC7", .F.)
                SC7->C7_CONAPRO := "B"
            SC7->(MsUnlock())

            crTotal  := SCR->CR_TOTAL
            crXdespv := SCR->CR_XDESPV

            RECLOCK("SCR", .T.)
                SCR->CR_FILIAL  := XFILIAL("SCR")
                SCR->CR_NUM     := xNumSC7
                SCR->CR_TIPO    := "PC"
                SCR->CR_USER    := POSICIONE("RD0", 1, XFILIAL("RD0")+FLF->FLF_PARTIC, "RD0_XGER")
                SCR->CR_APROV   := "000037"
                SCR->CR_GRUPO   := "000001"
                SCR->CR_NIVEL   := "1"
                SCR->CR_STATUS  := "02"
                SCR->CR_EMISSAO := DDATABASE
                SCR->CR_TOTAL   := crTotal
                SCR->CR_MOEDA   := 1
                SCR->CR_XDESPV  := crXdespv
            SCR->(MsUnlock())

            //MANDA EMAIL PARA O GERENTE APROVAR A DESPESA
            EnviaMail( "APROVAR A PRESTACAO DE CONTAS NUMERO.: "+ALLTRIM(crXdespv), getEmail("GERENTE", FLF->FLF_PARTIC) , "NOVA PRESTACAO DE CONTAS PARA APROVAR", NIL )


        ELSEIF ALLTRIM(FLF->FLF_STATUS) $ '4'  // SIGNIFICA QUE A DESPESA EST[A SENDO APROVADA PELO GERENTE

            RECLOCK("FLF", .F.)
                FLF->FLF_STATUS := "6"
            FLF->(MsUnlock())

        ENDIF

    ENDIF

    // IATAN EM 07/11/2023
    // CHAMADO #11100
    IF ALLTRIM(SCR->CR_TIPO) == 'SC'

        POSICIONE("SC1", 1, SCR->CR_FILIAL+ALLTRIM(SCR->CR_NUM), "C1_FILIAL")
        IF SCR->CR_FILIAL+ALLTRIM(SCR->CR_NUM) == SC1->C1_FILIAL+SC1->C1_NUM// SE CONSEGUIU POSICIONER CORRETAMENTE, EFETUA A LIBERAÇÃO DA SC

            IF ISINCALLSTACK("A94ExLiber") // APROVAR
                RECLOCK("SC1", .F.)
                    SC1->C1_APROV := 'L'
                SC1->( MSUNLOCK() )
            ENDIF
            
        ENDIF

    ENDIF

    RESTAREA(aArea)

Return 

Static Function getFLF(filial, codigo)

    Local chave

    Local cQuery := ""
    
    cQuery += " SELECT R_E_C_N_O_ AS RECNO " 
    cQuery += " FROM FLF010 FLF  " 
    cQuery += " WHERE FLF.D_E_L_E_T_ <> '*' AND FLF_FILIAL = '" + filial + "' AND FLF_PRESTA = '" + codigo + "' "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T.,"TOPCONN",TcGenQry( ,,cQuery ),"TRB_FLF",.T.,.T. )
    DbSelectArea("TRB_FLF")
    DbGoTop( )

    While TRB_FLF->(!EOF())
        chave := TRB_FLF->RECNO
        TRB_FLF->(dbSkip())
    EndDo
    TRB_FLF->(dbCloseArea())

Return chave

Static Function EnviaMail( cHTML, cTo, cSubject, cPdf )

	Local cError     := ""
	Local cMsg       := ""
	Local lOK        := .F.
	Local lMsgError  := .T.
	Local lAuth      := GetMv( "MV_RELAUTH" )
	Local cServer    := GetMv( "MV_RELSERV" )
	Local cAccount   := GetMv( "MV_RELACNT" )
	Local cPassword  := GetMv( "MV_RELPSW"  )

	// conectando-se com o servidor de e-mail
	CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lResult

		// Fazendo autenticacao
		If lResult .And. lAuth

			lResult := MailAuth( cAccount,cPassword )
			If !lResult

				If lMsgError// Erro na conexao com o SMTP Server

					GET MAIL ERROR cError
					cMsg += "- Erro na autenticação da conta do e-mail. " + cError + CRLF
					lOK:= .F.

				EndIf

			EndIf

		Else

			If !lResult

				If lMsgError//Erro na conexao com o SMTP Server

					GET MAIL ERROR cError
					cMsg += "- Erro de conexão com servidor SMTP. " + cError + CRLF
					lOK:= .F.

				EndIf

			EndIf

		EndIf

		If !lResult

			GET MAIL ERROR cError
			cMsg += "- Erro ao conectar a conta de e-mail. " + cError
			lOK:= .F.

		Else

			//SEND MAIL FROM cAccount TO cTo SUBJECT cSubject BODY cHTML ATTACHMENT aFiles[1] RESULT lResult
			SEND MAIL FROM cAccount TO cTo SUBJECT cSubject BODY cHTML RESULT lResult

			If !lResult

				GET MAIL ERROR cError
				cMsg := "- Erro no Envio do e-mail. " + cError + CRLF
				lOK  := .F.

			EndIf

			lOK := .T.

		EndIf

		DISCONNECT SMTP SERVER

Return( {lOK, cMsg} )



Static Function getEmail(tipo, participante)

    Local email := ""

    Local cQuery := ""
    
    cQuery += " SELECT (SELECT RD0_EMAIL FROM RD0010 WHERE D_E_L_E_T_ <> '*' AND RD0_USER = RD0.RD0_XLID ) AS LIDER, " 
    cQuery += "        (SELECT RD0_EMAIL FROM RD0010 WHERE D_E_L_E_T_ <> '*' AND RD0_USER = RD0.RD0_XGER ) AS GERENTE " 
    cQuery += " FROM RD0010 RD0  " 
    cQuery += " WHERE RD0.D_E_L_E_T_ <> '*' AND RD0_CODIGO = '" + participante + "' "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T.,"TOPCONN",TcGenQry( ,,cQuery ),"TRB_RD0",.T.,.T. )
    DbSelectArea("TRB_RD0")
    DbGoTop( )

    While TRB_RD0->(!EOF())
        IF tipo == 'LIDER'
            email := ALLTRIM(TRB_RD0->LIDER)
        ELSEIF tipo == 'GERENTE'
            email := ALLTRIM(TRB_RD0->GERENTE)
        ENDIF
        TRB_RD0->(dbSkip())
    EndDo
    TRB_RD0->(dbCloseArea())

Return email
