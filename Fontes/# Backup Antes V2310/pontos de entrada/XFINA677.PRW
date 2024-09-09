//Bibliotecas
#Include "Protheus.ch" 
#Include "RPTDEF.CH"
#Include "FwPrintSetup.ch"
#Include "CI_M001.CH"
#INCLUDE "TbiConn.ch"
#Include "RPTDEF.CH"
#Include "FwPrintSetup.ch"
#Include "CI_M001.CH"
#INCLUDE "TbiConn.ch" 
/*/{Protheus.doc} ITEM
Exemplo de Ponto de Entrada em MVC 
@author zIsMVC 
@since 29/06/2018
@version 1.0 
@type function 
@obs Deixar o nome do prw como: ITEM_pe.prw 
/*/
 
User Function FINA677() 
    Local aParam := PARAMIXB 
    Local xRet := .T. 
    Local oObj := Nil 
    Local cIdPonto := ""
    Local cIdModel := ""
    Local nOper := 0 
    Local nI
    Local total := 0

    //Se tiver parâmetros
    If aParam != Nil 
        //ConOut("> "+aParam[2]) 
 
        //Pega informações dos parâmetros
        oObj := aParam[1] 
        cIdPonto := aParam[2] 
        cIdModel := aParam[3] 
 

        //DEVE SER ASSIM PORQUE QUALQUER RETORNO DIFERENTE DE .T. GERA ERROR.LOG NA INTEGRACAO DO APP COM O PROTHEUS
        //VALIDACOES DEVEM SER TRATADAS NAS LIBERACOES VIA TELA
        IF isBlind()
            CONOUT("PASSANDO SEM BLOQUEIO")

            IF cIdPonto == "MODELPOS"
                 nOper := oObj:nOperation

                // SE ESTIVER TUDO CERTO ATE AQUI, ENVIAR EMAIL PARA O SUPERIOR APROVAR
                xEmail   := ""
                xUser    := ""
                xFornec  := getFornece()
                //CONOUT("OPERACAO.: " + CVALTOCHAR(nOper))
                //CONOUT("FLF->FLF_STATUS.: "+FLF->FLF_STATUS)
                //CONOUT("M->FLF_STATUS.: "+M->FLF_STATUS)
                //CONOUT("FLF->FLF_PRESTA.: "+FLF->FLF_PRESTA)
                //CONOUT("M->FLF_PRESTA.: "+M->FLF_PRESTA)
                IF (nOper == 3 .OR. nOper == 4 ) .AND. xret == .T.
                    IF ALLTRIM(M->FLF_STATUS) $ '1-2-3'
                        xEmail := getEmail("LIDER")
                        xUser  := getuser("LIDER")
                    ELSEIF ALLTRIM(M->FLF_STATUS) $ '4'
                        xEmail := getEmail("GERENTE")
                        xUser  := getuser("GERENTE")
                    ENDIF
                    CONOUT("EMAIL.:" + ALLTRIM(xEmail) )
                    IF !EMPTY(ALLTRIM(xEmail))
                        EnviaMail( "APROVAR A PRESTACAO DE CONTAS NUMERO.: "+M->FLF_PRESTA, xEmail , "NOVA PRESTACAO DE CONTAS PARA APROVAR", NIL )
                    ENDIF
                ENDIF
                //APOS O ENVIO DO EMAIL A PRESTACAO DE CONTAS DEVERA SER ENVIADA PARA APROVACAO DO SUPERIOR VIA "MEU PROTHEUS"
                //PARA ISSO DEVEMOS GERAR UM PEDIDO DE COMPRAS ESPECIFICO PARA POSSIBILITAR A APROVACAO VIA APLICATIVO

                total := 0  // CALCULO DO TOTAL
                FOR nI := 1 TO LEN(APARAM[1]:AMODELSTRUCT[1][3]:ADATAMODEL[2][1][2])
                    //ASSUMINDO VALOR DA DESPESA APRESENTADA NA POSICAO 14
                    total := total + APARAM[1]:AMODELSTRUCT[1][3]:ADATAMODEL[2][1][2][nI][1][1][14]
                NEXT nI

                xNumSC7 := GETNUMSC7()  
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
                    SC7->C7_PRECO   := total
                    SC7->C7_TOTAL   := total
                    SC7->C7_LOCAL   := "01"
                    SC7->C7_OBS     := "PRESTACAO DE CONTAS DE VIAGEM"
                    SC7->C7_FORNECE := SUBSTR(xFornec, 1, 6)
                    SC7->C7_LOJA    := SUBSTR(xFornec, LEN(xFornec)-3, 4)
                    SC7->C7_COND    := "002"
                    SC7->C7_FILENT  := XFILIAL("SC7")
                    SC7->C7_EMISSAO := DDATABASE
                    SC7->C7_CONAPRO := "B"
                SC7->(MsUnlock())
                RECLOCK("SCR", .T.)
                    SCR->CR_FILIAL  := XFILIAL("SCR")
                    SCR->CR_NUM     := xNumSC7
                    SCR->CR_TIPO    := "PC"
                    SCR->CR_USER    := POSICIONE("RD0", 1, XFILIAL("RD0")+M->FLF_PARTIC, "RD0_XLID")
                    SCR->CR_APROV   := "000037"
                    SCR->CR_GRUPO   := "000001"
                    SCR->CR_NIVEL   := "1"
                    SCR->CR_STATUS  := "02"
                    SCR->CR_EMISSAO := DDATABASE
                    SCR->CR_TOTAL   := total
                    SCR->CR_MOEDA   := 1
                    SCR->CR_XDESPV  := M->FLF_PRESTA
                SCR->(MsUnlock())
            ENDIF

            RETURN .T.
        ENDIF
        IF ISINCALLSTACK("FINA665")
            RETURN .T.
        ENDIF


        IF cIdPonto == "MODELPOS"
            xRet := .T. 
            xFiltro := .T.
             nOper := oObj:nOperation
            //ASSUMINDO ANEXO NA POSICAO 27
            IF nOper == 3 .OR. nOper == 4
                FOR nI := 1 TO LEN(APARAM[1]:AMODELSTRUCT[1][3]:ADATAMODEL[2][1][2])
                    IF EMPTY(ALLTRIM(APARAM[1]:AMODELSTRUCT[1][3]:ADATAMODEL[2][1][2][nI][1][1][29]))
                        xRet := .F. 
                    ENDIF
                NEXT nI
                IF xRet == .F. 
                    IF !isBlind()
                        Alert("O ANEXO E OBRIGATORIO. OPERACAO NAO IRA PROSSEGUIR SEM O ANEXO.")
                    ENDIF
                ENDIF
            ENDIF
            IF nOper == 3 .OR. nOper == 4
                FOR nI := 1 TO LEN(APARAM[1]:AMODELSTRUCT[1][3]:ADATAMODEL[2][1][2])
                    //ASSUMINDO TIPOS DE DESPESA NA POSICAO 7 E QUE O VALOR NAO REEMBOLSAVEL ESTA NA POSICAO 15
                    //VALIDANDO SE ALGUMA DESPESA POSSUI LIMITACAO FINANCEIRA
                    IF APARAM[1]:AMODELSTRUCT[1][3]:ADATAMODEL[2][1][2][nI][1][1][15] > 0
                        xRet := .F. 
                        xFiltro := .F.
                    ENDIF
                NEXT nI
                IF xRet == .F.  .AND. xFiltro == .F.
                    IF !isBlind()
                        If MsgYesNo("Atencao. Despesa acima do limite permitido.", "PAGAR A DESPESA NA SUA TOTALIDADE ?")
                            //RECALCULA OS VALORES
                            total := 0
                            FOR nI := 1 TO LEN(APARAM[1]:AMODELSTRUCT[1][3]:ADATAMODEL[2][1][2])
                                //ASSUMINDO TIPOS DE DESPESA NA POSICAO 7 E QUE O VALOR NAO REEMBOLSAVEL ESTA NA POSICAO 15
                                //VALIDANDO SE ALGUMA DESPESA POSSUI LIMITACAO FINANCEIRA
                                APARAM[1]:AMODELSTRUCT[1][3]:ADATAMODEL[2][1][2][nI][1][1][14] := APARAM[1]:AMODELSTRUCT[1][3]:ADATAMODEL[2][1][2][nI][1][1][12]
                                APARAM[1]:AMODELSTRUCT[1][3]:ADATAMODEL[2][1][2][nI][1][1][15] := 0
                                POSICIONE("FLE", 1, APARAM[1]:AMODELSTRUCT[1][3]:ADATAMODEL[2][1][2][nI][1][1][1]+APARAM[1]:AMODELSTRUCT[1][3]:ADATAMODEL[2][1][2][nI][1][1][2]+APARAM[1]:AMODELSTRUCT[1][3]:ADATAMODEL[2][1][2][nI][1][1][3], "FLE_TOTAL" )
                                total := total + FLE->FLE_TOTAL
                                RECLOCK("FLE", .F.)
                                    FLE->FLE_XVALRE := FLE->FLE_VALREE
                                    FLE->FLE_XVALNR := FLE->FLE_VALNRE
                                    FLE->FLE_VALREE := FLE->FLE_TOTAL
                                    FLE->FLE_VALNRE := 0
                                FLE->(MsUnlock())
                                
                            NEXT nI
                            OOBJ:AALLSUBMODELS[1]:ADATAMODEL[2][2][2][1][3][2] := OOBJ:AALLSUBMODELS[1]:ADATAMODEL[2][2][2][1][2][2]
                            OOBJ:AALLSUBMODELS[1]:ADATAMODEL[2][2][2][1][5][2] := OOBJ:AALLSUBMODELS[1]:ADATAMODEL[2][2][2][1][2][2]
                            F677RECALC(FwViewActive()) // RECALCULA OS TOTAIS
                            ALERT('FAVOR RECALCULAR OS TOTAIS E EFETUAR A LIBERACAO NOVAMENTE')
                        EndIf
                    ENDIF
                    xRet := .F.
                ENDIF
                //VALIDACAO SE EXISTE ALGUM BLOQUEIO NO TIPO DE DESPESA
                FOR nI := 1 TO LEN(APARAM[1]:AMODELSTRUCT[1][3]:ADATAMODEL[2][1][2])
                    //ASSUMINDO TIPOS DE DESPESA NA POSICAO 7 E QUE O VALOR NAO REEMBOLSAVEL ESTA NA POSICAO 15
                    liberados := POSICIONE("FLG", 1, XFILIAL("FLG")+APARAM[1]:AMODELSTRUCT[1][3]:ADATAMODEL[2][1][2][nI][1][1][7], "FLG_XVIAJ" )
                    IF !EMPTY(ALLTRIM(liberados))
                        IF ALLTRIM(APARAM[1]:AMODELSTRUCT[1][3]:ADATAMODEL[2][1][2][nI][1][1][4]) $ liberados
                            // CASO O PARTICIPANTE ESTEJA DENTRO DA LISTA DE USUARIOS LIBERADOS ... PODE SEGUIR
                        ELSE
                            // SE NAO ESTIVER ..... PRECISO PARAR O PROCESSO
                            xRet := .F. 
                            Alert("O VIAJANTE NAO PODE UTILIZAR ESTA DESPESA.")
                        ENDIF
                    ENDIF
                NEXT nI
                
            ENDIF
            // SE ESTIVER TUDO CERTO ATE AQUI, ENVIAR EMAIL PARA O SUPERIOR APROVAR
             xEmail   := ""
             xUser    := ""
             xFornec  := getFornece()
            IF (nOper == 3 .OR. nOper == 4 ) .AND. xret == .T.
                IF ALLTRIM(M->FLF_STATUS) $ '1-2-3'
                    xEmail := getEmail("LIDER")
                    xUser  := getuser("LIDER")
                ELSEIF ALLTRIM(M->FLF_STATUS) $ '4'
                    xEmail := getEmail("GERENTE")
                    xUser  := getuser("GERENTE")
                ENDIF
                IF !EMPTY(ALLTRIM(xEmail))
                    EnviaMail( "APROVAR A PRESTACAO DE CONTAS NUMERO.: "+M->FLF_PRESTA, xEmail , "NOVA PRESTACAO DE CONTAS PARA APROVAR", NIL )
                ENDIF
            ENDIF
            //APOS O ENVIO DO EMAIL A PRESTACAO DE CONTAS DEVERA SER ENVIADA PARA APROVACAO DO SUPERIOR VIA "MEU PROTHEUS"
            //PARA ISSO DEVEMOS GERAR UM PEDIDO DE COMPRAS ESPECIFICO PARA POSSIBILITAR A APROVACAO VIA APLICATIVO

            total := 0  // CALCULO DO TOTAL
            FOR nI := 1 TO LEN(APARAM[1]:AMODELSTRUCT[1][3]:ADATAMODEL[2][1][2])
                //ASSUMINDO VALOR DA DESPESA APRESENTADA NA POSICAO 14
                total := total + APARAM[1]:AMODELSTRUCT[1][3]:ADATAMODEL[2][1][2][nI][1][1][14]
            NEXT nI


            xNumSC7 := GETNUMSC7()  
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
                SC7->C7_PRECO   := total
                SC7->C7_TOTAL   := total
                SC7->C7_LOCAL   := "01"
                SC7->C7_OBS     := "PRESTACAO DE CONTAS DE VIAGEM"
                SC7->C7_FORNECE := SUBSTR(xFornec, 1, 6)
                SC7->C7_LOJA    := SUBSTR(xFornec, LEN(xFornec)-3, 4)
                SC7->C7_COND    := "002"
                SC7->C7_FILENT  := XFILIAL("SC7")
                SC7->C7_EMISSAO := DDATABASE
                SC7->C7_CONAPRO := "B"
            SC7->(MsUnlock())
            RECLOCK("SCR", .T.)
                SCR->CR_FILIAL  := XFILIAL("SCR")
                SCR->CR_NUM     := xNumSC7
                SCR->CR_TIPO    := "PC"
                SCR->CR_USER    := xUser
                SCR->CR_APROV   := "000037"
                SCR->CR_GRUPO   := "000001"
                SCR->CR_NIVEL   := "1"
                SCR->CR_STATUS  := "02"
                SCR->CR_EMISSAO := DDATABASE
                SCR->CR_TOTAL   := total
                SCR->CR_MOEDA   := 1
                SCR->CR_XDESPV  := M->FLF_PRESTA
            SCR->(MsUnlock())
        //Commit das operações (antes da gravação)
        ElseIf cIdPonto == "MODELCOMMITTTS"

            //Mostrando mensagens no fim da operação
            If nOper == 3
                //Alert("Fim da Inclusão")/////////////////////////////////////////
                 
            ElseIf nOper == 4  
                //Alert("Fim da Alteração")
            EndIf

        EndIf 
    EndIf 
Return xRet


Static Function getEmail(tipo)

    Local email := ""

    Local cQuery := ""
    
    cQuery += " SELECT (SELECT RD0_EMAIL FROM RD0010 WHERE D_E_L_E_T_ <> '*' AND RD0_USER = RD0.RD0_XLID ) AS LIDER, " 
    cQuery += "        (SELECT RD0_EMAIL FROM RD0010 WHERE D_E_L_E_T_ <> '*' AND RD0_USER = RD0.RD0_XGER ) AS GERENTE " 
    cQuery += " FROM RD0010 RD0  " 
    cQuery += " WHERE RD0.D_E_L_E_T_ <> '*' AND RD0_USER = '" + RETCODUSR() + "' "
	
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

Static Function getUser(tipo)

    Local xuser := ""

    Local cQuery := ""
    
    cQuery += " SELECT RD0_XLID, RD0_XGER " 
    cQuery += " FROM RD0010 RD0  " 
    cQuery += " WHERE RD0.D_E_L_E_T_ <> '*' AND RD0_USER = '" + RETCODUSR() + "' "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T.,"TOPCONN",TcGenQry( ,,cQuery ),"TRB_RD0",.T.,.T. )
    DbSelectArea("TRB_RD0")
    DbGoTop( )

    While TRB_RD0->(!EOF())
        IF tipo == 'LIDER'
            xuser := ALLTRIM(TRB_RD0->RD0_XLID)
        ELSEIF tipo == 'GERENTE'
            xuser := ALLTRIM(TRB_RD0->RD0_XGER)
        ENDIF
        TRB_RD0->(dbSkip())
    EndDo
    TRB_RD0->(dbCloseArea())

Return xuser

Static Function getFornece()

    Local xFornec := ""

    Local cQuery := ""
    
    cQuery += " SELECT RD0_FORNEC, RD0_LOJA " 
    cQuery += " FROM RD0010 RD0  " 
    cQuery += " WHERE RD0.D_E_L_E_T_ <> '*' AND RD0_USER = '" + RETCODUSR() + "' "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T.,"TOPCONN",TcGenQry( ,,cQuery ),"TRB_RD0",.T.,.T. )
    DbSelectArea("TRB_RD0")
    DbGoTop( )

    While TRB_RD0->(!EOF())
        xFornec := TRB_RD0->RD0_FORNEC+TRB_RD0->RD0_LOJA
        TRB_RD0->(dbSkip())
    EndDo
    TRB_RD0->(dbCloseArea())

Return xFornec

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

