
/*
    Iatan em 02/07/2022 
    Referencia.: https://tdn.totvs.com/pages/releaseview.action?pageId=198956516
    Motivo.: Manipular aprovadores de prestação de contas de viagens
*/

/*
#Include 'Protheus.ch'
#Include "TOTVS.CH"
*/
#Include 'Protheus.ch'
#INCLUDE "FWBROWSE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"
#Include 'FWMVCDef.ch'
#INCLUDE "XMLXFUN.CH"
#Include "fileio.ch"
#Include "FWEVENTVIEWCONSTS.CH"


USER FUNCTION FA050GRV()

    Local _aTit := {}
    Local xBanco
    Local xAgencia
    Local xConta

    Private lMsErroAuto := .F.
    
    IF ISINCALLSTACK("U_F677AFIN") == .T.

        IF isAdiantamento() == .T. .AND. ALLTRIM(SE2->E2_TIPO) <> 'PA'

            xBanco   := GETMV("MV_XBCOMPC")
            xAgencia := GETMV("MV_XAGMPC")
            xConta   := GETMV("MV_XCTMPC")

            _aTit := {}
            AADD(_aTit , {"E2_PREFIXO"	,SE2->E2_PREFIXO	,Nil})
            AADD(_aTit , {"E2_NUM"		,SE2->E2_NUM		,Nil})
            AADD(_aTit , {"E2_TIPO"		,"PA"				,Nil})
            AADD(_aTit , {"E2_NATUREZ"	,SE2->E2_NATUREZ	,Nil})
            AADD(_aTit , {"E2_FORNECE"	,SE2->E2_FORNECE	,Nil})
            AADD(_aTit , {"E2_LOJA"		,SE2->E2_LOJA		,Nil})
            AADD(_aTit , {"E2_EMISSAO"	,Ddatabase			,Nil})
            AADD(_aTit , {"E2_VENCTO"	,SE2->E2_VENCTO		,Nil})
            AADD(_aTit , {"E2_VENCREA"	,SE2->E2_VENCREA	,Nil})
            AADD(_aTit , {"E2_VALOR"	,SE2->E2_VALOR		,Nil})
            AADD(_aTit , {"E2_HIST"		,SE2->E2_HIST   	,Nil})

            AADD(_aTit , {"AUTBANCO"	,xBanco           	,Nil})
            AADD(_aTit , {"AUTAGENCIA"	,xAgencia        	,Nil})
            AADD(_aTit , {"AUTCONTA"	,xConta         	,Nil})

            //DELETAR O TITULO GERADO NA SE2
            SE2->(RecLock("SE2",.F.))
                SE2->(DbDelete())
            SE2->(MsUnLock())

            //GERAR UM TITULO DO TIPO "PA"
            //MSExecAuto({|x, y| FINA050(x, y)}, _aTit, 3)
            MsExecAuto( { |x,y,z| FINA050(x,y,z)}, _aTit,, 3)

           If lMsErroAuto
                MostraErro()
           Else
                Alert("Título de adiantamento incluído com sucesso!")
           Endif

        ENDIF
    ENDIF
    

RETURN

User Function F677GERAPR()

Local aAprov := {}
Local aAreaRD0 := RD0->(GETAREA())
Local idAprov := ""
Local codGerente := ""
Local cont := 0
Local cQuery := ""

    idAprov := POSICIONE("RD0", 1, XFILIAL("RD0")+FLF->FLF_PARTIC, "RD0_XGER")

	cQuery := " SELECT * FROM " + RetSqlName("RD0" ) + " RD0 " 
    cQuery += " WHERE D_E_L_E_T_ <> '*' AND RD0_USER = '" + idAprov + "' "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T.,"TOPCONN",TcGenQry( ,,cQuery ),"TRB_RD0",.T.,.T. )
    DbSelectArea("TRB_RD0")
    DbGoTop( )

    While TRB_RD0->(!EOF())
        codGerente := TRB_RD0->RD0_CODIGO
        cont++
        TRB_RD0->(dbSkip())
    EndDo
    TRB_RD0->(dbCloseArea())

    IF cont > 1
        MSGSTOP("Aprovação não finalizada. Gerente de código "+idAprov+" vinculado a mais de um Participante.")
    ELSE
        aAdd(aAprov, codGerente) 
    ENDIF

    RESTAREA(aAreaRD0)

Return aAprov


/*
    Função para retornar sempre o usuário logado
    Dessa forma "Todos" terão acesso às prestações de contas 
    O objetivo é filtrar através de campo customizado na tabela de participantes
*/
User Function FN683USR()

    Local aRet := {"ALL"}

Return aRet

/*
    Função para Filtrar os acessos às prestações de contas 
    Essa é a rotina que vai ler os campos customizados fazer os devidos filtros
*/
User Function F677FilBrw()

    Local cFiltro := ""
    Local participantes := ""
	Local cQuery		:= ""

    //Aprovadores financeiros devem ter acesso a tudo 
    //****DESDE QUE ESTEJAM EFETUANDO A LIBERAÇÃO FINANCEIRA ATRAVÉS DA ROTINA F677AFIN
    IF RETCODUSR() $ GETMV("MV_XFIN677") .AND. ISINCALLSTACK("U_F677AFIN")
        RETURN cFiltro
    ENDIF

	cQuery := " SELECT * FROM " + RetSqlName("RD0" ) + " RD0 " 
    cQuery += " WHERE D_E_L_E_T_ <> '*' AND ( RD0_XLID = '" + RETCODUSR() + "' OR RD0_USER = '" + RETCODUSR() + "' OR RD0_XGER = '" + RETCODUSR() + "' ) "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T.,"TOPCONN",TcGenQry( ,,cQuery ),"TRB_RD0",.T.,.T. )
    DbSelectArea("TRB_RD0")
    DbGoTop( )

    While TRB_RD0->(!EOF())
        participantes := participantes + TRB_RD0->RD0_CODIGO + "-"
        TRB_RD0->(dbSkip())
    EndDo
    TRB_RD0->(dbCloseArea())


    cFiltro := " FLF_PARTIC $ '" + participantes + "' "


    //CONDIÇÃO PARA SEPARAR A ROTINA DE APROVAÇÃO
    IF ISINCALLSTACK("U_F677APROVA")
       cFiltro := cFiltro + " .AND. FLF_STATUS == '4' "
    ELSEIF ISINCALLSTACK("U_F677AFIN")
       cFiltro := cFiltro + " .AND. FLF_STATUS == '6' "
    ELSE 
        cFiltro := cFiltro + " .AND. FLF_STATUS <> '4' .AND. FLF_STATUS <> '6' "
    ENDIF



Return cFiltro


/*
    Validação de Usuário para liberar a prestação de contas
*/
User Function F677VLDCF()

    Local retorno := .F.
    Local aAreaRD0 := RD0->(GETAREA())

    //ACESSOU A ROTINA DE CONFERIR
    IF ISINCALLSTACK("F677CONFER")

        IF RETCODUSR() == POSICIONE("RD0", 1, XFILIAL("RD0")+FLF->FLF_PARTIC, "RD0_XLID")
            retorno := .T.
        ELSE 
            MSGSTOP("Usuário sem permissão para Conferência de Dctos de Viagem")
        ENDIF

    ENDIF

    RESTAREA(aAreaRD0)

Return retorno

/*APROVAÇÃO*/
User Function F677APROVA

    FINA677()

RETURN 

/*APROVAÇÃO FINANCEIRA*/
User Function F677AFIN

    FINA677()

RETURN 


/*
    Funcao responsavel por gerar a aprovacao Do Lider via Meu Protheus
*/
User Function aprovN1()

    Local cQuery := ""
    
    cQuery += " SELECT * "
    cQuery += " FROM FLF010 FLF LEFT JOIN SCR010 SCR ON SCR.D_E_L_E_T_ <> '*' AND CR_FILIAL = FLF_FILIAL AND CR_XDESPV = FLF_PRESTA  "
    cQuery += " WHERE FLF.D_E_L_E_T_ <> '*' AND FLF_STATUS IN ('2','3') AND CR_FILIAL IS NULL"
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T.,"TOPCONN",TcGenQry( ,,cQuery ),"TRB_N1",.T.,.T. )
    DbSelectArea("TRB_N1")
    DbGoTop( )

    While TRB_N1->(!EOF())

        POSICIONE("RD0", 1, XFILIAL("RD0")+TRB_N1->FLF_PARTIC, "RD0_XLID")

        xNumSC7 := GETNUMSC7()  
        RECLOCK("SC7", .T.)
            SC7->C7_FILIAL  := TRB_N1->FLF_FILIAL
            SC7->C7_NUM     := xNumSC7
            SC7->C7_TIPO    := 1
            SC7->C7_ITEM    := "0001"
            SC7->C7_PRODUTO := "0000252"
            SC7->C7_DESCRI  := "DESPESAS DE VIAGEM"
            SC7->C7_UM      := "UN"
            SC7->C7_FISCORI := TRB_N1->FLF_FILIAL
            SC7->C7_MOEDA   := 1
            SC7->C7_QUANT   := 1
            SC7->C7_PRECO   := TRB_N1->FLF_TVLRE1
            SC7->C7_TOTAL   := TRB_N1->FLF_TVLRE1
            SC7->C7_LOCAL   := "01"
            SC7->C7_OBS     := "PRESTACAO DE CONTAS DE VIAGEM"
            SC7->C7_FORNECE := RD0->RD0_FORNECE
            SC7->C7_LOJA    := RD0->RD0_LOJA
            SC7->C7_COND    := "002"
            SC7->C7_FILENT  := TRB_N1->FLF_FILIAL
            SC7->C7_EMISSAO := DDATABASE
            SC7->C7_CONAPRO := "B"
        SC7->(MsUnlock())
        RECLOCK("SCR", .T.)
            SCR->CR_FILIAL  := TRB_N1->FLF_FILIAL
            SCR->CR_NUM     := xNumSC7
            SCR->CR_TIPO    := "PC"
            SCR->CR_USER    := RD0->RD0_XLID
            SCR->CR_APROV   := ""
            SCR->CR_GRUPO   := "000001"
            SCR->CR_NIVEL   := "1"
            SCR->CR_STATUS  := "02"
            SCR->CR_EMISSAO := DDATABASE
            SCR->CR_TOTAL   := TRB_N1->FLF_TVLRE1
            SCR->CR_MOEDA   := 1
            SCR->CR_XDESPV  := TRB_N1->FLF_PRESTA
        SCR->(MsUnlock())

        EnviaMail( "APROVAR A PRESTACAO DE CONTAS NUMERO.: "+TRB_N1->FLF_PRESTA, getEmail("GERENTE", TRB_N1->FLF_PARTIC) , "NOVA PRESTACAO DE CONTAS PARA APROVAR", NIL )

        TRB_N1->(dbSkip())
    EndDo
    TRB_N1->(dbCloseArea())

Return


/*
    Gera a aprovacao do Gerente no Meu Protheus
*/
User Function aprovN2()

    Local cQuery := ""
    
    cQuery += " SELECT * "
    cQuery += " FROM FLF010 FLF LEFT JOIN SCR010 SCR ON SCR.D_E_L_E_T_ <> '*' AND CR_FILIAL = FLF_FILIAL AND CR_XDESPV = FLF_PRESTA  "
    cQuery += " WHERE FLF.D_E_L_E_T_ <> '*' AND FLF_STATUS IN ('4') AND CR_FILIAL IS NULL"
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T.,"TOPCONN",TcGenQry( ,,cQuery ),"TRB_N2",.T.,.T. )
    DbSelectArea("TRB_N2")
    DbGoTop( )

    While TRB_N2->(!EOF())

        POSICIONE("RD0", 1, XFILIAL("RD0")+TRB_N2->FLF_PARTIC, "RD0_XLID")

        xNumSC7 := GETNUMSC7()  
        RECLOCK("SC7", .T.)
            SC7->C7_FILIAL  := TRB_N2->FLF_FILIAL
            SC7->C7_NUM     := xNumSC7
            SC7->C7_TIPO    := 1
            SC7->C7_ITEM    := "0001"
            SC7->C7_PRODUTO := "0000252"
            SC7->C7_DESCRI  := "DESPESAS DE VIAGEM"
            SC7->C7_UM      := "UN"
            SC7->C7_FISCORI := TRB_N2->FLF_FILIAL
            SC7->C7_MOEDA   := 1
            SC7->C7_QUANT   := 1
            SC7->C7_PRECO   := TRB_N2->FLF_TVLRE1
            SC7->C7_TOTAL   := TRB_N2->FLF_TVLRE1
            SC7->C7_LOCAL   := "01"
            SC7->C7_OBS     := "PRESTACAO DE CONTAS DE VIAGEM"
            SC7->C7_FORNECE := RD0->RD0_FORNECE
            SC7->C7_LOJA    := RD0->RD0_LOJA
            SC7->C7_COND    := "002"
            SC7->C7_FILENT  := TRB_N2->FLF_FILIAL
            SC7->C7_EMISSAO := DDATABASE
            SC7->C7_CONAPRO := "B"
        SC7->(MsUnlock())
        RECLOCK("SCR", .T.)
            SCR->CR_FILIAL  := TRB_N2->FLF_FILIAL
            SCR->CR_NUM     := xNumSC7
            SCR->CR_TIPO    := "PC"
            SCR->CR_USER    := RD0->RD0_XGER
            SCR->CR_APROV   := ""
            SCR->CR_GRUPO   := "000001"
            SCR->CR_NIVEL   := "1"
            SCR->CR_STATUS  := "02"
            SCR->CR_EMISSAO := DDATABASE
            SCR->CR_TOTAL   := TRB_N2->FLF_TVLRE1
            SCR->CR_MOEDA   := 1
            SCR->CR_XDESPV  := TRB_N2->FLF_PRESTA
        SCR->(MsUnlock())

        EnviaMail( "APROVAR A PRESTACAO DE CONTAS NUMERO.: "+TRB_N2->FLF_PRESTA, getEmail("GERENTE", TRB_N2->FLF_PARTIC) , "NOVA PRESTACAO DE CONTAS PARA APROVAR", NIL )

        TRB_N2->(dbSkip())
    EndDo
    TRB_N2->(dbCloseArea())

Return 



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



Static Function isAdiantamento()

    Local retorno := .F.
    Local cQuery := ""
    
    cQuery += " SELECT * FROM FLE010   " 
    cQuery += " WHERE D_E_L_E_T_ <> '*' AND FLE_FILIAL = '" + FLF->FLF_FILIAL + "' "
    cQuery += "       AND FLE_PRESTA = '" + FLF->FLF_PRESTA + "' "
    cQuery += "       AND FLE_DESPES = '99' "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T.,"TOPCONN",TcGenQry( ,,cQuery ),"TRB_ADT",.T.,.T. )
    DbSelectArea("TRB_ADT")
    DbGoTop( )

    While TRB_ADT->(!EOF())
        retorno := .T.
        TRB_ADT->(dbSkip())
    EndDo
    TRB_ADT->(dbCloseArea())


Return retorno
