#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#include 'Totvs.ch'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MT100GE2    ³ Autor ³ Ednei Silva	    ³ Data ³18/07/2018³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta uma tela para Informar o Motivo da Devolucao         ³±±
±±³          ³ 									                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MAHOPITALAR / Faturamento                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ Motivo da Alteracao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
#define DS_MODALFRAME   128
User Function MT103FIM()

	Local 	nLinha	  := 010
	Local 	lEdita	  := .F.
	Local 	oCodDev
	Local 	oDescDev
	Local 	aArea     := GetArea()
	Local 	aAreaSE2  := SE2->(GetArea())
	Local 	aAreaSE4  := SE4->(GetArea())
    Local 	aAreaSC7  := SC7->(GetArea())
	Local 	aAreaSD1  := SD1->(GetArea())
	Local 	aAreaSF1  := SF1->(GetArea())
	Local   cCondpg := SF1->F1_COND
    Local   cPPedido := SC7->C7_NUM
	Local 	cCForne := SF1->F1_FORNECE
	Local 	cCNUMNF := SF1->F1_DOC
	Local 	cCLojaF := SF1->F1_LOJA
    Local   cCFormPG := ""

	//PRIVATE nTIPO := (Ascan(PARAMIXB1,{|x| Alltrim(x[1])== 'F1_TIPO' }))
	//PRIVATE nDoc  := (Ascan(PARAMIXB1,{|x| Alltrim(x[1])== 'F1_DOC' }))
	//PRIVATE nMot  := (Ascan(PARAMIXB1,{|x| Alltrim(x[1])== 'F1_ZMOTDEV' }))
	//PRIVATE nDes  := (Ascan(PARAMIXB1,{|x| Alltrim(x[1])== 'F1_ZDESMOT' }))
	Private cCodDev	  := SPACE(4)
	Private cDesDev	  := SPACE(50)
	Private oDlg01
	Private lGrava	  := .F.

	//Inicio demanda chamado 5265
	//Dev. Thalys Augusto
	//Data: 20/09/2022
	If Inclui .or. Altera

		If cCondpg <> ''

			If SF1->F1_TIPO = "N" .OR. SF1->F1_TIPO = "I" .OR. SF1->F1_TIPO = "P" .OR. SF1->F1_TIPO = "C"

				cQuery:=""
				cQuery:="SELECT E2_FILIAL FILIAL, E2_NUM NUM, E2_PREFIXO PREFIXO, E2_TIPO TIPO, E2_FORNECE FORNECE, E2_LOJA LOJA, E2_PARCELA PARCELA, E2_VALOR VALOR "
				cQuery+="FROM "
				cQuery+=	RetSqlName("SE2")+" SE2 "
				cQuery+=" WHERE E2_FILIAL = '"+xFilial("SE2")+"'"
				cQuery+=" AND E2_NUM = '"+cCNUMNF+"' "
				cQuery+=" AND E2_FORNECE = '"+cCForne+"' "
				cQuery+=" AND E2_LOJA = '"+cCLojaF+"' "
				cQuery+=" AND D_E_L_E_T_ = ' ' "


				cQuery:= ChangeQuery(cQuery)
				cAliasQry := GetNextAlias()
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

				dbSelectArea(cAliasQry)
				dbGoTop(cAliasQry)

				dbSelectArea("SE2")
				dbGoTop("SE2")

				While !(cAliasQry)->(EOF())

					DbSelectArea('SC7')
					SC7->(DbSetOrder(1)) // Filial + Código
					//Se conseguir posicionar no produto
					If SC7->(DbSeek(FWxFilial('SC7') + cPPedido))
						cCFormPG := ALLTRIM(SC7->C7_ZFORMAP)
					EndIf

					//Gravar o número dos pedidos na SE2
					If  SE2->(DbSeek(xFilial("SE2")+ (cAliasQry)->PREFIXO + (cAliasQry)->NUM + (cAliasQry)->PARCELA + (cAliasQry)->TIPO + (cAliasQry)->FORNECE + (cAliasQry)->LOJA))
						RecLock('SE2', .F.)
						SE2->E2_XFORMAP := cCFormPG
						SE2->(MsUnLock())
					EndIf

					dbSelectArea(cAliasQry)
					(cAliasQry)->(dbSkip())
				EndDo

				dbSelectArea(cAliasQry)
				(cAliasQry)->(dbCloseArea())


			EndIf

		Endif

	Endif
	//Fim demanda chamado 5265

	//IDENTIFICAR SE ESTÁ VINDO VIA INTEGRAÇÃO WMS
	IF ISINCALLSTACK("U_DEVOLUCAO") .OR. ISINCALLSTACK("U_DEV2")
		RETURN
	ENDIF

	IF EMPTY(SF1->F1_ZMOTDEV) .and. SF1->F1_TIPO='D'

		Define MsDialog oDlg01 Title "Motivo da Devolucao"  From 000,000 To 250, 730 Pixel Style DS_MODALFRAME

		@ nLinha + 002, 010 Say OemToAnsi("Motivo Devolucao") Of oDlg01 Pixel

		@ nLinha, 055 MsGet oCodDev  Var cCodDev of oDlg01  Pixel F3 "Z40" Valid (!Vazio() .and. A010ValMot(cCodDev))
		@ nLinha, 100 MsGet oDescDev Var cDesDev of oDlg01  Pixel When lEdita  Size 261, 012
		nLinha += 018

		@ 080, 330 Button 'Ok'		Size 030,015 Of oDlg01 Pixel Action (Grava())
		//	@ nLinha, 290 Button 'Cancelar'	Size 030,015 Of oDlg01 Pixel Action ( oDlg01:End(), lgrava:= .F. )

		@ 110 + 002, 010 Say OemToAnsi("* É obrigatório informar o motivo de devolução para este tipo de documento") Of oDlg01 Pixel

		oDlg01:lEscClose := .F. //Nao permite sair ao se pressionar a tecla ESC.



		Activate MsDialog oDlg01 Centered

	ENDIF

	RestArea(aAreaSE4)
	RestArea(aAreaSE2)
	RestArea(aAreaSD1)
	RestArea(aAreaSF1)
	RestArea(aArea)

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A010ValMot ³ Autor ³   Ednei Silva    	³ Data ³18/07/2018³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Validação do Motivo		                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³  A010ValMot()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ _cMotivo - Motivo da Devolucao			                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function A010ValMot(_cMotivo)

	lRet := .T.

	If !Empty(_cMotivo)

		DbSelectArea("Z40")
		DbSetOrder(1)

		If	DbSeek(xFilial("Z40")+_cMotivo)
			cDesDev  := Z40->Z40_DESCRI
			lGrava   := .T.
		Else

			Aviso("AVISO","Motivo de Devolucão não cadastrada!", { "Sair" }, 2)
			lRet := .F.

		EndIf

	EndIf

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Grava ³ Autor ³   Ednei Silva    		³ Data ³18/07/2018³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Grava o motivo de devolucao no cabecalho da nota			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³  Grava()         	                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 											                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Grava()

	If	lGrava
		RecLock('SF1',.F.)
		SF1->F1_ZMOTDEV := cCodDev
		SF1->F1_ZDESMOT := cDesDev
		SF1->(MsUnlock())

		MsgInfo("Dados gravados com sucesso!","Informação!")
		oDlg01:End()
	Else
		MsgInfo("Selecione um motivo de devolucao!","Informação!")
	EndIf

Return ()


