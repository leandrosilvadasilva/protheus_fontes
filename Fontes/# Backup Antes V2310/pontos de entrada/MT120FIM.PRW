#Include "TOTVS.CH"
#Include "topconn.ch"
/*/{Protheus.doc} User Function MT120FIM
description)
    @type  Function
    @author user
    @since 21/09/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
User Function MT120FIM()

	Local nOpcao := PARAMIXB[1]   // Opção Escolhida pelo usuario
	Local cPedido := PARAMIXB[2]
	Local cUsrPed := RetCodUsr()
	Local cSCRFil := FWCodFil()
	Local cSC7Fil := FWCodFil()
	Local cGrupoap:= ""
	Local cTipo	:= "IP"
	Local cTipoAl := "PC"
	Local cSCRTOTAL := ""
	Local cAprov := "999999"
	Local cUsrSCR := "000093"
	Local aDados := {}

	if (nOpcao = 1 .OR. nOpcao = 9 .OR. nOpcao = 3 )

		cGrupoap	:= posicione("SY1",3,xFILIAL("SY1")+cUsrPed,"Y1_GRAPROV")

		If GetMv("MV_XAPCOM") == "1" //1 = SIM e 2 = NÃO

			if cGrupoap == '999999'

				SCR->(DbSelectArea("SCR"))
				SCR->(dbSetOrder(1))
				SCR->(dbSeek(xFilial("SCR")+PadR(cTipo,Tamsx3("CR_TIPO")[01])+PadR(cPedido,Tamsx3("CR_NUM")[01])))
				Do While SCR->(!Eof()) .And. SCR->(CR_FILIAL+CR_TIPO+CR_NUM) == xFilial("SCR")+PadR(cTipo,Tamsx3("CR_TIPO")[01])+PadR(cPedido,Tamsx3("CR_NUM")[01])
					Reclock("SCR",.F.)
					DbDelete()
					SCR->(MsUnlock())
					SCR->(dbSkip())
				EndDo

				TCSqlExec("DELETE FROM "+RetSqlName("DBM")+" WHERE DBM_NUM = '"+cPedido+"' AND DBM_TIPO = '"+cTipo+"' AND DBM_FILIAL = '"+cSCRFil+"'")

				aDados := QUANTPC(cPedido)
				cSCRTOTAL := aDados[1][1]

				If !SCR->(DbSeek(xFilial("SCR") + PadR(cTipo,Tamsx3("CR_TIPO")[01]) + PadR(cPedido,Tamsx3("CR_NUM")[01])))

					RecLock('SCR', .T.)
					SCR->CR_FILIAL := cSCRFil
					SCR->CR_NUM := cPedido
					SCR->CR_TIPO := cTipoAl
					SCR->CR_USER := cUsrSCR
					SCR->CR_APROV := cAprov
					SCR->CR_GRUPO := cGrupoap
					SCR->CR_NIVEL := '01'
					SCR->CR_STATUS := '02'
					SCR->CR_EMISSAO := dDatabase
					SCR->CR_TOTAL := cSCRTOTAL
					SCR->(MsUnlock())
					SCR->(DBSKIP())

				elseif SCR->(DbSeek(xFilial("SCR") + PadR(cTipoAl,Tamsx3("CR_TIPO")[01]) + PadR(cPedido,Tamsx3("CR_NUM")[01])))

					RecLock('SCR', .F.)
					SCR->CR_FILIAL := cSCRFil
					SCR->CR_NUM := cPedido
					SCR->CR_TIPO := cTipoAl
					SCR->CR_USER := cUsrSCR
					SCR->CR_APROV := cAprov
					SCR->CR_GRUPO := cGrupoap
					SCR->CR_NIVEL := '01'
					SCR->CR_STATUS := '02'
					SCR->CR_EMISSAO := dDatabase
					SCR->CR_TOTAL := cSCRTOTAL
					SCR->(MsUnlock())
					SCR->(DBSKIP())

				Endif

				SC7->(DbSelectArea("SC7"))
				SC7->(dbSetOrder(1))
				SC7->(dbSeek(xFilial("SC7")+PadR(cPedido,Tamsx3("C7_NUM")[01])))
				Do While SC7->(!Eof()) .And. SC7->(C7_FILIAL+C7_NUM) == xFilial("SC7")+PadR(cPedido,Tamsx3("C7_NUM")[01])
					Reclock("SC7",.F.)
					SC7->C7_APROV := cGrupoap
					SC7->(MsUnlock())
					SC7->(dbSkip())
				EndDo

			Elseif cGrupoap == ''

				CONOUT('PEDIDO CRIADO')

			Endif

		Endif

	elseif nOpcao = 4

		cGrupoap	:= posicione("SY1",3,xFILIAL("SY1")+cUsrPed,"Y1_GRAPROV")

		If GetMv("MV_XAPCOM") == "1" //1 = SIM e 2 = NÃO

			if cGrupoap == '999999'

				SCR->(DbSelectArea("SCR"))
				SCR->(dbSetOrder(1))
				SCR->(dbSeek(xFilial("SCR")+PadR(cTipo,Tamsx3("CR_TIPO")[01])+PadR(cPedido,Tamsx3("CR_NUM")[01])))
				Do While SCR->(!Eof()) .And. SCR->(CR_FILIAL+CR_TIPO+CR_NUM) == xFilial("SCR")+PadR(cTipo,Tamsx3("CR_TIPO")[01])+PadR(cPedido,Tamsx3("CR_NUM")[01])
					Reclock("SCR",.F.)
					DbDelete()
					SCR->(MsUnlock())
					SCR->(dbSkip())
				EndDo

				TCSqlExec("DELETE FROM "+RetSqlName("DBM")+" WHERE DBM_NUM = '"+cPedido+"' AND DBM_TIPO = '"+cTipo+"' AND DBM_FILIAL = '"+cSCRFil+"'")

				aDados := QUANTPC(cPedido)
				cSCRTOTAL := aDados[1][1]

				If !SCR->(DbSeek(xFilial("SCR") + PadR(cTipoAl,Tamsx3("CR_TIPO")[01]) + PadR(cPedido,Tamsx3("CR_NUM")[01])))

					RecLock('SCR', .T.)
					SCR->CR_FILIAL := cSCRFil
					SCR->CR_NUM := cPedido
					SCR->CR_TIPO := cTipoAl
					SCR->CR_USER := cUsrSCR
					SCR->CR_APROV := cAprov
					SCR->CR_GRUPO := cGrupoap
					SCR->CR_NIVEL := '01'
					SCR->CR_STATUS := '02'
					SCR->CR_EMISSAO := dDatabase
					SCR->CR_TOTAL := cSCRTOTAL
					SCR->(MsUnlock())
					SCR->(DBSKIP())

				elseif SCR->(DbSeek(xFilial("SCR") + PadR(cTipoAl,Tamsx3("CR_TIPO")[01]) + PadR(cPedido,Tamsx3("CR_NUM")[01])))

					RecLock('SCR', .F.)
					SCR->CR_FILIAL := cSCRFil
					SCR->CR_NUM := cPedido
					SCR->CR_TIPO := cTipoAl
					SCR->CR_USER := cUsrSCR
					SCR->CR_APROV := cAprov
					SCR->CR_GRUPO := cGrupoap
					SCR->CR_NIVEL := '01'
					SCR->CR_STATUS := '02'
					SCR->CR_EMISSAO := dDatabase
					SCR->CR_TOTAL := cSCRTOTAL
					SCR->(MsUnlock())
					SCR->(DBSKIP())

				Endif

				SC7->(DbSelectArea("SC7"))
				SC7->(dbSetOrder(1))
				SC7->(dbSeek(xFilial("SC7")+PadR(cPedido,Tamsx3("C7_NUM")[01])))
				Do While SC7->(!Eof()) .And. SC7->(C7_FILIAL+C7_NUM) == xFilial("SC7")+PadR(cPedido,Tamsx3("C7_NUM")[01])
					Reclock("SC7",.F.)
					SC7->C7_APROV := cGrupoap
					SC7->C7_XENVIWF := ''
					SC7->(MsUnlock())
					SC7->(dbSkip())
				EndDo

			Else

				DbSelectArea('SC7')
				SC7->(DbSetOrder(1)) // Filial + Código
				//Se conseguir posicionar no produto
				If SC7->(DbSeek(FWxFilial('SC7') + cPedido))
					While cSC7Fil==SC7->C7_FILIAL .and. SC7->C7_NUM==cPedido
						RecLock('SC7', .F.)
						SC7->C7_XENVIWF := ''
						SC7->(MsUnLock())
						SC7->(DbSkip())
					EndDo
				EndIf

			Endif

		Endif

	Endif

Return

/*/{Protheus.doc} QUANTPC

    Executa query para buscar os pedidos que nao foi enviado aprovação

    @author  Thalys Augusto
    @example Example
    @return  Return
    @table   Tables
    @since   11-09-2022
/*/
Static Function QUANTPC(cPedido)
	Local cQuery := ""
	Local cPednum := cPedido
	Local aDados := {}

	// Verifica se area está aberta
	If Select("QVL") > 0
		DbSelectArea("QVL")
		QVL->(DbCloseArea())
	EndIf

	// Monta Query
	cQuery := "SELECT SUM(C7_TOTAL) AS C7_TOTAL FROM " + RetSqlName("SC7") + " SC7 "
	cQuery += "WHERE SC7.D_E_L_E_T_ <> '*' "
	cQuery += "AND C7_FILIAL = '" + xFilial("SC7") + "' "
	cQuery += "AND C7_NUM = '" + cPednum + "' "

	// Deixa nos padrões do banco
	cQuery := ChangeQuery(cQuery)

	// Executa
	TcQuery cQuery New Alias "QVL"

	While QVL->(!Eof())
		Aadd(aDados,{QVL->C7_TOTAL})
		QVL->(DbSkip())
	EndDo

Return aDados
