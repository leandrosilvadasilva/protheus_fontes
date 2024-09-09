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
User Function MAHA020( cAlias, nReg, nOpcx )

	Local nLinha		:= 010
	Local lGrava		:= .F.
	Local lEdita		:= .F.
	Local oDescNum
	Local oCondPagto
	Local oDescCPag
	Local oTransp
	Local oRazao
	Local oVeicul
	Local oPliqui
	Local oPBruto
	Local oEspecie
	Local oVolume
	Local oDespesa
	Local oObsNfse
	Local oObsExpe
	Local mObsInt
	Local oFatParc 

	Private cNum			:= (cAlias)->C5_NUM
	Private cCondPagto	:= (cAlias)->C5_CONDPAG
	Private cBanco		:= (cAlias)->C5_BANCO
	Private cTransp		:= (cAlias)->C5_TRANSP
	Private nPliqui		:= (cAlias)->C5_PESOL
	Private nPbruto		:= (cAlias)->C5_PBRUTO
	Private cEspecie		:= (cAlias)->C5_ESPECI1
	Private nVolume		:= (cAlias)->C5_VOLUME1
	Private cMenNota		:= (cAlias)->C5_MENNOTA
	Private mObsNfse		:= (cAlias)->C5_OBSNFSE
	Private mObsExpe		:= (cAlias)->C5_OBSEXPE
    Private cFatParc 	:= (cAlias)->C5_ZTPLIBE
	Private cRazao		:= CriaVar("A4_NOME")
	Private cDescBanco	:= CriaVar("A6_NOME")
	Private cDescCPag		:= CriaVar("E4_DESCRI")
	Private aFatParc 	:= {"1=SIM","2=NAO"}
	If	!Empty(cCondPagto)
		A010ValCPag(cCondPagto)
	EndIf

	If	!Empty(cBanco)
		A010ValBanco(cBanco)
	EndIf

	If	!Empty(cTransp)
		A010ValTrp(cTransp)
	EndIf

	If Empty(SC5->C5_NOTA)
	
		Define MsDialog oDlg01 Title cCadastro  From 000,000 To 460, 730 Pixel
	
			@ nLinha + 002, 010 Say OemToAnsi("Pedido") Of oDlg01 Pixel
			@ nLinha, 055 MsGet oDescNum  Var cNum of oDlg01  Pixel When lEdita  Size 110, 012
	
			@ nLinha + 002, 170 Say OemToAnsi("Cond. Pagto") Of oDlg01 Pixel
			@ nLinha, 210 MsGet oCondPagto Var cCondPagto of oDlg01  Pixel F3 "SE4" Valid A010ValCPag(cCondPagto) When lEdita
			@ nLinha, 250 MsGet oDescCPag  Var cDescCPag of oDlg01  Pixel When lEdita  Size 110, 012
			nLinha += 018
	
			@ nLinha + 002, 010 Say OemToAnsi("Banco") Of oDlg01 Pixel
			@ nLinha, 055 MsGet oBanco Var cBanco of oDlg01  Pixel F3 "SA6" Valid A010ValBanco(cBanco) When lEdita
			@ nLinha, 085 MsGet oDescBanco Var cDescBanco of oDlg01  Pixel When lEdita  Size 080, 012
	
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
	
			@ nLinha, 010 SAY OemToAnsi("Obs. Nota Fiscal") Of oDlg01 Pixel
			@ nLinha, 055 Get oObsNfse Var mObsNfse MEMO Size 305, 050 Of oDlg01 Pixel
			nLinha += 060
	
			@ nLinha, 010 SAY OemToAnsi("Obs. Expedição") Of oDlg01 Pixel
			@ nLinha, 055 Get oObsExpe Var mObsExpe MEMO Size 305, 050 Of oDlg01 Pixel
			nLinha += 060
	
			@ nLinha, 010 Say OemToAnsi("Fat. Parcial") Of oDlg01 Pixel
			@ nLinha, 055 ComboBox oFatParc Var cFatParc Items aFatParc of oDlg01  Pixel Size 085,09
	
			
			@ nLinha, 330 Button 'Ok'		Size 030,015 Of oDlg01 Pixel Action ( oDlg01:End(), lgrava:= .T. )
			@ nLinha, 290 Button 'Cancelar'	Size 030,015 Of oDlg01 Pixel Action ( oDlg01:End(), lgrava:= .F. )
	   	
		Activate MsDialog oDlg01 Centered
	
		If	lGrava
			DbSelectArea(cAlias)
			RecLock(cAlias, .F. )
				(cAlias)->C5_CONDPAG := cCondPagto
				(cAlias)->C5_BANCO   := cBanco
				(cAlias)->C5_TRANSP  := cTransp
				(cAlias)->C5_ESPECI1 := cEspecie
				(cAlias)->C5_PESOL   := nPliqui
				(cAlias)->C5_PBRUTO  := nPbruto
				(cAlias)->C5_VOLUME1 := nVolume
				(cAlias)->C5_MENNOTA := cMenNota
				(cAlias)->C5_OBSNFSE := mObsNfse
				(cAlias)->C5_OBSEXPE := mObsExpe
				(cAlias)->C5_ZTPLIBE := cFatParc
			MsUnlock()
		EndIf
    Else
    
    	MsgInfo("Pedido de Venda Faturado, não pode ser alterado.","Atenção!")
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

			Aviso("MAHA010","Transportadora Não Cadastrada!", { "Sair" }, 2)
			lRet := .F.

		EndIf

	EndIf

Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A010ValBanco ³ Autor ³  Leonir Donatti   ³ Data ³07/06/2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Validação do banco                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³  A010ValBanco()                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ _cBanco - Banco do pedido de venda                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A010ValBanco(_cBanco)

	lRet := .T.

	If !Empty(_cBanco)

		DbSelectArea("SA6")
		DbSetOrder(1)

		If	DbSeek(xFilial("SA4")+_cBanco)
			cDescBanco  := SA6->A6_NOME
		Else

			Aviso("MAHA010","Banco Não Cadastrado!", { "Sair" }, 2)
			lRet := .F.

		EndIf

	EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A010ValCPag  ³ Autor ³  Leonir Donatti   ³ Data ³07/06/2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Validação da condição pagamento                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³  A010ValCPag()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ _cCondPagto - Condição de Pagamento do pedido de venda     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A010ValCPag(_cCondPagto)

	lRet := .T.

	If !Empty(_cCondPagto)

		DbSelectArea("SE4")
		DbSetOrder(1)

		If	DbSeek(xFilial("SE4")+_cCondPagto)
			cDescCPag  := SE4->E4_DESCRI
		Else

			Aviso("MAHA010","Condição de Pagamento Não Cadastrada!", { "Sair" }, 2)
			lRet := .F.

		EndIf

	EndIf

Return(lRet)