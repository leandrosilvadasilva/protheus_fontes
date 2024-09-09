#include 'Totvs.ch'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MAH010    ³ Autor ³ Leonir Donatti       ³ Data ³07/06/2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta uma tela para Alterar informacoes no Pedido de       ³±±
±±³          ³ Venda sem desfazer as Liberacoes.                          ³±±
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
User Function MAHA026( cAlias, nReg, nOpcx )

	Local nLinha		:= 010
	Local lGrava		:= .F.
	Local lEdita		:= .F.
	Local oDoc
	Local oSerie
	Local oTransp
	Local oPliqui
	Local oPbruto
	Local oEspecie
	Local oVolume
	Local oMenNota
	Local oRazao



	Private cDoc		:= (cAlias)->F2_DOC
	Private cSerie		:= (cAlias)->F2_SERIE
	Private cTransp		:= (cAlias)->F2_TRANSP
	Private nPliqui		:= (cAlias)->F2_PLIQUI
	Private nPbruto		:= (cAlias)->F2_PBRUTO
	Private cEspecie	:= (cAlias)->F2_ESPECI1
	Private nVolume		:= (cAlias)->F2_VOLUME1
	Private cMenNota	:= (cAlias)->F2_MENNOTA
	Private cRazao      := ""
	
	If	!Empty(cTransp)
		A010ValTrp(cTransp)
	EndIf

	If Empty(SF2->F2_CHVNFE)
	
		Define MsDialog oDlg01 Title cCadastro  From 000,000 To 460, 730 Pixel
	
			@ nLinha + 002, 010 Say OemToAnsi("Documento") Of oDlg01 Pixel
			@ nLinha, 055 MsGet oDoc  Var cDoc of oDlg01  Pixel When lEdita  Size 110, 012
	
			@ nLinha + 002, 170 Say OemToAnsi("Serie") Of oDlg01 Pixel
			@ nLinha, 210 MsGet oDoc  Var cDoc of oDlg01  Pixel When lEdita  Size 110, 012
			
	
			@ nLinha + 002, 170 Say OemToAnsi("Transportadora") Of oDlg01 Pixel
			@ nLinha, 210 MsGet oTransp Var cTransp of oDlg01  Pixel F3 "SA4" Valid (Vazio() .or. A010ValTrp(cTransp)) 
			@ nLinha, 250 MsGet oRazao  Var cRazao of oDlg01  Pixel When lEdita  Size 110, 012
			nLinha += 018
	
			@ nLinha, 010 Say OemToAnsi("Peso Liquido") Size 050,012 Of oDlg01  Pixel
		   	@ nLinha, 055 MsGet oPliqui Var nPliqui picture "@E 999999.9999" Of oDlg01  Pixel Valid ( nPliqui > 0 )
	
			@ nLinha, 110 Say OemToAnsi("Peso Bruto") Size 050,012 Of oDlg01  Pixel
		   	@ nLinha, 145 MsGet oPBruto Var nPBruto picture "@E 999999.9999" of oDlg01  Pixel Valid ( nPBruto >= nPliqui )
	
			@ nLinha, 205 Say OemToAnsi("Especie") Of oDlg01  Pixel
		  	@ nLinha, 235 MsGet oEspecie Var cEspecie picture "@!" of oDlg01  Pixel
	
			@ nLinha, 305 Say OemToAnsi("Volume") Of oDlg01  Pixel
		  	@ nLinha, 335 MsGet oVolume Var nVolume picture "@E 999999" of oDlg01  Pixel
			nLinha += 018
	
			@ nLinha, 010 Say OemToAnsi("Mensagem Nota") Of oDlg01  Pixel
		  	@ nLinha, 055 MsGet oMenNota Var cMenNota picture "@!80" Of oDlg01  Pixel  Size 305, 012
			nLinha += 020

	
			
			@ nLinha, 330 Button 'Ok'		Size 030,015 Of oDlg01 Pixel Action ( oDlg01:End(), lgrava:= .T. )
			@ nLinha, 290 Button 'Cancelar'	Size 030,015 Of oDlg01 Pixel Action ( oDlg01:End(), lgrava:= .F. )
	   	
		Activate MsDialog oDlg01 Centered
	
		If	lGrava
			DbSelectArea(cAlias)
			RecLock(cAlias, .F. )
				(cAlias)->F2_DOC     := cDoc
				(cAlias)->F2_SERIE   := cSerie
		   		(cAlias)->F2_TRANSP  := cTransp
		   		(cAlias)->F2_PLIQUI  := nPliqui
				(cAlias)->F2_PBRUTO  := nPbruto
				(cAlias)->F2_ESPECI1 := cEspecie
				(cAlias)->F2_VOLUME1 := nVolume
				(cAlias)->F2_MENNOTA := cMenNota
			MsUnlock()
		EndIf
    Else
    
    	MsgInfo("NF Faturada, Doc. não pode ser alterado.","Atenção!")
    EndIf
Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A010ValTrp ³ Autor ³   Leonir Donatti    ³ Data ³07/06/2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Validação da transportadora                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³  A010ValTrp()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ _cTransp - Transportadora do pedido de venda               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function A010ValTrp(_cTransp)

	lRet := .T.

	If !Empty(_cTransp)

		DbSelectArea("SA4")
		DbSetOrder(1)

		If	DbSeek(xFilial("SA4")+_cTransp)
			cRazao  := SA4->A4_NOME
		Else

			Aviso("MAHA026","Transportadora Não Cadastrada!", { "Sair" }, 2)
			lRet := .F.

		EndIf

	EndIf

Return(lRet)
