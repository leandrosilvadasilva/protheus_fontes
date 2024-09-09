//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"

//Vari�veis utilizadas no fonte inteiro
Static nPadLeft   := 0                                                                     //Alinhamento a Esquerda
Static nPadRight  := 1                                                                     //Alinhamento a Direita
Static nPadCenter := 2                                                                     //Alinhamento Centralizado
Static nTamFundo  := 15                                                                    //Altura de fundo dos blocos com t�tulo
//Static cEmpEmail  := Alltrim(SuperGetMV("MV_X_EMAIL", .F., "compras-ma@mahospitalar.com.br"))        //Par�metro com o e-Mail da empresa
Static cEmpSite   := Alltrim(SuperGetMV("MV_X_HPAGE", .F., "http://www.mahospitalar.com.br"))   //Par�metro com o site da empresa
Static nCorAzul   := RGB(062, 179, 206)                                                    //Cor Azul usada nos T�tulos
Static nPosCod    := 0000                                                                  //Posi��o Inicial da Coluna de C�digo do Produto
Static nPosDesc   := 0000                                                                  //Posi��o Inicial da Coluna de Descri��o
Static nPosForn   := 0000                                                                  //Posi��o Inicial da Coluna de C�d. Forn.
Static nPosQtd    := 0000                                                                  //Posi��o Inicial da Coluna de Qtde
Static nPosUni    := 0000                                                                  //Posi��o Inicial da Coluna de Vlr. Unit.
Static nPosIPI    := 0000                                                                  //Posi��o Inicial da Coluna de % IPI
Static nPosTot    := 0000                                                                  //Posi��o Inicial da Coluna de Vlr. Tot.
Static nPosEnt    := 0000                                                                  //Posi��o Inicial da Coluna de Entrega
Static cNomeFont  := "Arial"                                                               //Nome da Fonte Padr�o
Static oFontDet   := Nil                                                                   //Fonte utilizada na impress�o dos itens
Static oFontDetN  := Nil                                                                   //Fonte utilizada no cabe�alho dos itens
Static oFontRod   := Nil                                                                   //Fonte utilizada no rodap� da p�gina
Static oFontTit   := Nil                                                                   //Fonte utilizada no T�tulo das se��es
Static oFontCab   := Nil                                                                   //Fonte utilizada na impress�o dos textos dentro das se��es
Static oFontCabN  := Nil                                                                   //Fonte negrita utilizada na impress�o dos textos dentro das se��es
Static oFontBlo   := Nil                                                                   //Fonte utilizada na impress�o do bloco final
Static oFontBloN  := Nil                                                                   //Fonte utilizada na impress�o do bloco final (em negrito)
Static cMaskPad   := "@E 999,999.99"                                                       //M�scara padr�o de valor
Static cMaskTel   := "@R (99) 99999999"                                                    //M�scara de telefone / fax
Static cMaskCNPJ  := "@R 99.999.999/9999-99"                                               //M�scara de CNPJ
Static cMaskCEP   := "@R 99999-999"                                                        //M�scara de CEP
Static cMaskCPF   := "@R 999.999.999-99"                                                   //M�scara de CPF
Static cMaskQtd   := PesqPict("SC7", "C7_QUANT")                                           //M�scara de quantidade
Static cMaskPrc   := PesqPict("SC7", "C7_PRECO")                                           //M�scara de pre�o
Static cMaskIPI   := PesqPict("SC7", "C7_IPI")                                             //M�scara de IPI
Static cMaskVlr   := PesqPict("SC7", "C7_TOTAL")                                           //M�scara de valor
Static cMaskFrete := PesqPict("SC7", "C7_VALFRE")                                          //M�scara de frete

/*/{Protheus.doc} zRPedCom
Impress�o gr�fica gen�rica de Pedido de Compra (em pdf)
@type function
@author Atilio
@since 06/01/2019
@version 1.0
	@example
	u_zRPedCom()
/*/

User Function zRPedCom()
	Local aArea      := GetArea()
	Local aAreaC7    := SC7->(GetArea())
	Local aAreaA2    := SA2->(GetArea())
	Local aPergs     := {}
	Local aRetorn    := {}
	Local oProcess   := Nil

	//Vari�veis usadas nas outras fun��es
	Private cLogoEmp := fLogoEmp()
	Private cPedDe   := SC7->C7_NUM
	Private cPedAt   := SC7->C7_NUM
	Private cZeraPag := "1"
	Private cDescPrd := "1"					

	//Adiciona os parametros para a pergunta
	aAdd(aPergs, {1, "Pedido De",  cPedDe, "", ".T.", "SC7", ".T.", 80, .T.})
	aAdd(aPergs, {1, "Pedido At�", cPedAt, "", ".T.", "SC7", ".T.", 80, .T.})
	aAdd(aPergs, {2, "Zera a P�gina ao trocar Pedido", Val(cZeraPag), {"1=Sim",              "2=N�o"},                                                 100, ".T.", .F.})
	aadd(aPergs, {2, "Descri��o do Produto"          , Val(cDescPrd), {"1=Pedido","2=Produto"}, 100  , ".T.", .F.})																											  

	//Se a pergunta for confirmada
	If ParamBox(aPergs, "Informe os par�metros", @aRetorn, , , , , , , , .F., .F.)
		cPedDe   := aRetorn[1]
		cPedAt   := aRetorn[2]
		cZeraPag := cValToChar(aRetorn[3])
		cDescPrd := cValToChar(aRetorn[4])							

		//Chama o processamento do relat�rio
		oProcess := MsNewProcess():New({|| fMontaRel(@oProcess) }, "Impress�o Pedidos de Compra", "Processando", .F.)
		oProcess:Activate()
	EndIf

	RestArea(aAreaA2)
	RestArea(aAreaC7)
	RestArea(aArea)
Return

/*---------------------------------------------------------------------*
 | Func:  fMontaRel                                                    |
 | Desc:  Fun��o principal que monta o relat�rio                       |
*---------------------------------------------------------------------*/

Static Function fMontaRel(oProc)
	//Vari�veis usada no controle das r�guas
	Local nTotIte       := 0
	Local nItAtu        := 0
	Local nTotPed       := 0
	Local nPedAtu       := 0
	//Consultas SQL
	Local cQryPed       := ""
	Local cQryIte       := ""
	//Vari�veis do Relat�rio
	Local cNomeRel      := "pedido_compra_" + FunName() + "_" + RetCodUsr() + "_" + dToS(Date()) + "_" + StrTran(Time(), ":", "-")
	Private oPrintPvt
	Private cHoraEx     := Time()
	Private nPagAtu     := 1
	//Linhas e colunas
	Private nLinAtu     := 0
	Private nLinFin     := 780
	Private nColIni     := 010
	Private nColFin     := 550
	Private nColMeio    := (nColFin-nColIni)/2
	//Totalizadores
	Private nValorTot   := 0
	Private nTotIPI     := 0
	Private nTotICMS    := 0
	Private nTotPeso    := 0
	Private nTotFrete	:= 0				   

	//Fun��o que muda alinhamento e fontes
	fSetLayout()

	//Criando o objeto de impress�o
	oPrintPvt := FWMSPrinter():New(cNomeRel, IMP_PDF, .F., /*cStartPath*/, .T., , @oPrintPvt, , , , , .T.)
	oPrintPvt:cPathPDF := GetTempPath()
	oPrintPvt:SetResolution(72)
	oPrintPvt:SetPortrait()
	oPrintPvt:SetPaperSize(DMPAPER_A4)
	oPrintPvt:SetMargin(60, 60, 60, 60)

	//Selecionando os pedidos
	cQryPed := " SELECT "                                            + CRLF
	cQryPed += "    C7_NUM, "                                        + CRLF
	cQryPed += "    MIN(C7_EMISSAO) AS C7_EMISSAO, "                 + CRLF
	cQryPed += "    C7_TPFRETE, "                                    + CRLF
	cQryPed += "    C7_FORNECE, "                                    + CRLF
	cQryPed += "    C7_LOJA, "                                       + CRLF
	cQryPed += "    C7_COND, "                                       + CRLF
	cQryPed += "    C7_USER, "                                       + CRLF
	cQryPed += "    ISNULL(E4_DESCRI, '') AS E4_DESCRI "             + CRLF
	cQryPed += " FROM "                                              + CRLF
	cQryPed += "    " + RetSQLName("SC7") + " SC7 "                  + CRLF
	cQryPed += "    LEFT JOIN " + RetSQLName("SA2") + " SA2 ON ( "   + CRLF
	cQryPed += "        A2_FILIAL   = '" + FWxFilial("SA2") + "' "   + CRLF
	cQryPed += "        AND A2_COD  = SC7.C7_FORNECE "               + CRLF
	cQryPed += "        AND A2_LOJA = SC7.C7_LOJA "                  + CRLF
	cQryPed += "        AND SA2.D_E_L_E_T_ = ' ' "                   + CRLF
	cQryPed += "    ) "                                              + CRLF
	cQryPed += "    LEFT JOIN " + RetSQLName("SE4") + " SE4 ON ( "   + CRLF
	cQryPed += "        E4_FILIAL     = '" + FWxFilial("SE4") + "' " + CRLF
	cQryPed += "        AND E4_CODIGO = SC7.C7_COND "                + CRLF
	cQryPed += "        AND SE4.D_E_L_E_T_ = ' ' "                   + CRLF
	cQryPed += "    ) "                                              + CRLF
	cQryPed += " WHERE "                                             + CRLF
	cQryPed += "    C7_FILIAL   = '" + FWxFilial("SC7") + "' "       + CRLF
	cQryPed += "    AND C7_NUM >= '" + cPedDe + "' "                 + CRLF
	cQryPed += "    AND C7_NUM <= '" + cPedAt + "' "                 + CRLF
	cQryPed += "    AND SC7.D_E_L_E_T_ = ' ' "                       + CRLF
	cQryPed += " GROUP BY "                                          + CRLF
	cQryPed += "    C7_NUM, "                                        + CRLF
	cQryPed += "    C7_USER, "                                    + CRLF
	cQryPed += "    C7_TPFRETE, "                                    + CRLF
	cQryPed += "    C7_FORNECE, "                                    + CRLF
	cQryPed += "    C7_LOJA, "                                       + CRLF
	cQryPed += "    C7_COND, "                                       + CRLF
	cQryPed += "    E4_DESCRI "                                      + CRLF
	cQryPed += " ORDER BY "                                          + CRLF
	cQryPed += "    C7_NUM "                                         + CRLF
	TCQuery cQryPed New Alias "QRY_PED"
	TCSetField('QRY_PED', 'C7_EMISSAO', 'D')
	Count To nTotPed
	oProc:SetRegua1(nTotPed)

	//Somente se houver pedidos
	If nTotPed != 0

		//Enquanto houver pedidos
		QRY_PED->(DbGoTop())
		While ! QRY_PED->(EoF())
			If cZeraPag == "1"
				nPagAtu := 1
			EndIf
			nPedAtu++
			oProc:IncRegua1("Processando o pedido " + cValToChar(nPedAtu) + " de " + cValToChar(nTotPed) + "...")
			oProc:SetRegua2(1)
			oProc:IncRegua2("...")

			//Posiciona no fornecedor
			DbSelectArea('SA2')
			SA2->(DbSetOrder(1))
			SA2->(DbSeek(FWxFilial('SA2') + QRY_PED->C7_FORNECE + QRY_PED->C7_LOJA))

			//Posiciona no pedido
			DbSelectArea('SC7')
			SC7->(DbSetOrder(1))
			SC7->(DbSeek(FWxFilial('SC7') + QRY_PED->C7_NUM))

			//Imprime o cabe�alho
			fImpCab()

			//Seleciona agora os itens do pedido
			cQryIte := " SELECT "                                           + CRLF
			cQryIte += "    C7_PRODUTO, "                                   + CRLF
 			
			//--Davidson DWT 19/07/2023 - Descri��o Pedido / Produto
			If Val(cDescPrd) == 1
			
				cQryIte += "    SUBSTRING(C7_DESCRI,1,60) AS B1_DESC, "           + CRLF
			EndIf
			cQryIte += "    SUBSTRING(B1_DESC,1,60) AS B1_DESC, "           + CRLF
			cQryIte += "    C7_QUANT, "                                     + CRLF
			cQryIte += "    SUBSTRING(C7_OBS,1,60) AS C7_OBS, "             + CRLF
			cQryIte += "    C7_PRECO, "                                     + CRLF
			cQryIte += "    C7_IPI, "                                       + CRLF
			cQryIte += "    C7_TOTAL, "                                     + CRLF
			cQryIte += "    C7_VALIPI, "                                    + CRLF
			cQryIte += "    C7_VALFRE, "  																		 
			cQryIte += "    C7_VALICM, "                                    + CRLF
			cQryIte += "    (B1_PESO * C7_QUANT) AS PESO, "                 + CRLF
			cQryIte += "    C7_DATPRF "                                     + CRLF
			cQryIte += " FROM "                                             + CRLF
			cQryIte += "    " + RetSQLName("SC7") + " SC7 "                 + CRLF
			cQryIte += "    INNER JOIN " + RetSQLName("SB1") + " SB1 ON ( " + CRLF
			cQryIte += "        B1_FILIAL = '" + FWxFilial("SB1") + "' "    + CRLF
			cQryIte += "        AND B1_COD = SC7.C7_PRODUTO "               + CRLF
			cQryIte += "        AND SB1.D_E_L_E_T_ = ' ' "                  + CRLF
			cQryIte += "    ) "                                             + CRLF
			cQryIte += " WHERE "                                            + CRLF
			cQryIte += "    C7_FILIAL = '" + FWxFilial("SC7") + "' "        + CRLF
			cQryIte += "    AND C7_NUM = '" + QRY_PED->C7_NUM + "' "        + CRLF
			cQryIte += "    AND SC7.D_E_L_E_T_ = ' ' "                      + CRLF
			cQryIte += " ORDER BY "                                         + CRLF
			cQryIte += "    C7_ITEM "                                       + CRLF
			TCQuery cQryIte New Alias "QRY_ITE"
			TCSetField("QRY_ITE", "C7_DATPRF", "D")
			Count To nTotIte
			nValorTot := 0
			nTotIPI   := 0
			nTotICMS  := 0
			nTotPeso  := 0
			nTotFrete := 0				 
			oProc:SetRegua2(nTotIte)

			//Enquanto houver itens
			oProc:IncRegua2("...")
			oProc:SetRegua2(nTotIte)
			nItAtu := 0
			QRY_ITE->(DbGoTop())
			While ! QRY_ITE->(EoF())
			
				nItAtu++
				oProc:IncRegua2("Imprimindo item " + cValToChar(nItAtu) + " de " + cValToChar(nTotIte) + "...")
				nValorTot += QRY_ITE->C7_TOTAL
				nTotIPI   += QRY_ITE->C7_VALIPI
				nTotICMS  += QRY_ITE->C7_VALICM
				nTotPeso  += QRY_ITE->PESO
				nTotFrete += QRY_ITE->C7_VALFRE								   

				oPrintPvt:SayAlign(nLinAtu, nPosCod , Alltrim(QRY_ITE->C7_PRODUTO)                   , oFontDet, 200, 07, , nPadLeft, )
				oPrintPvt:SayAlign(nLinAtu, nPosDesc, Alltrim(QRY_ITE->B1_DESC)                      , oFontDet, 200, 07, , nPadLeft, )
				oPrintPvt:SayAlign(nLinAtu, nPosForn, Alltrim(QRY_ITE->C7_OBS)                       , oFontDet, 140, 07, , nPadLeft, )
				oPrintPvt:SayAlign(nLinAtu, nPosQtd , Alltrim(Transform(QRY_ITE->C7_QUANT, cMaskQtd)), oFontDet, 040, 07, , nPadRight, )
				oPrintPvt:SayAlign(nLinAtu, nPosUni , Alltrim(Transform(QRY_ITE->C7_PRECO, cMaskPrc)), oFontDet, 040, 07, , nPadRight, )
				oPrintPvt:SayAlign(nLinAtu, nPosIPI , Alltrim(Transform(QRY_ITE->C7_IPI,   cMaskIPI)), oFontDet, 040, 07, , nPadRight, )
				oPrintPvt:SayAlign(nLinAtu, nPosTot , Alltrim(Transform(QRY_ITE->C7_TOTAL, cMaskVlr)), oFontDet, 040, 07, , nPadRight, )
				oPrintPvt:SayAlign(nLinAtu, nPosEnt , dToC(QRY_ITE->C7_DATPRF),                        oFontDet, 040, 07, , nPadRight, )
				nLinAtu += 7
				oPrintPvt:Line(nLinAtu + 1, nColIni, nLinAtu + 1, nColFin, RGB(200, 200, 200))

				//Se por acaso atingiu o limite da p�gina, finaliza, e come�a uma nova p�gina
				If nLinAtu >= nLinFin
					fImpRod()
					fImpCab()
				EndIf

				QRY_ITE->(DbSkip())
			EndDo
			QRY_ITE->(DbCloseArea())

			//Impress�o do bloco final do pedido
			fImpBloco()

			//Imprime o rodap�
			fImpRod()

			QRY_PED->(DbSkip())
		EndDo

		//Gera o pdf para visualiza��o
		oPrintPvt:Preview()

	Else
		MsgStop("N�o h� pedidos!", "Aten��o")
	EndIf
	QRY_PED->(DbCloseArea())
Return

/*---------------------------------------------------------------------*
 | Func:  fImpCab                                                      |
 | Desc:  Fun��o que imprime o cabe�alho                               |
*---------------------------------------------------------------------*/

Static Function fImpCab()
	Local cTexto      := ""
	Local nLinCab     := 025
	Local nLinCabOrig := nLinCab
	Local lCNPJ       := Len(Alltrim(SA2->A2_CGC)) > 11
	Local cForAux     := QRY_PED->C7_FORNECE + " " + QRY_PED->C7_LOJA + " - " + SA2->A2_NOME
	Local cFunEmail	  := Alltrim(UsrRetMail(QRY_PED->C7_USER))
	Local cCGC        := ""
	//Dados da empresa
	Local cEmpresa    := Iif(Empty(SM0->M0_NOMECOM), Alltrim(SM0->M0_NOME), Alltrim(SM0->M0_NOMECOM))
	Local cEmpTel     := Alltrim(Transform(SubStr(SM0->M0_TEL, 4,2)+SubStr(SM0->M0_TEL, 7,9),cMaskTel))
	Local cEmpFax     := Alltrim(Transform(SubStr(SM0->M0_FAX, 1,2)+SubStr(SM0->M0_FAX, 4,9), cMaskTel))
	Local cEmpCidade  := AllTrim(SM0->M0_CIDENT) + " / " + SM0->M0_ESTENT
	Local cEmpCnpj    := Alltrim(Transform(SM0->M0_CGC, cMaskCNPJ))
	Local cEmpCep     := Alltrim(Transform(SM0->M0_CEPENT, cMaskCEP))

	//Iniciando P�gina
	oPrintPvt:StartPage()

	//Dados da Empresa
	oPrintPvt:Box(nLinCab, nColIni, nLinCab + 075, nColMeio-3)
	oPrintPvt:Line(nLinCab + nTamFundo, nColIni, nLinCab + nTamFundo, nColMeio-3)
	nLinCab += nTamFundo - 5
	oPrintPvt:SayAlign(nLinCab-10, nColIni + 5, "Comprador:",                                     oFontTit,  060, nTamFundo, nCorAzul, nPadLeft, )
	nLinCab += 5
	oPrintPvt:SayBitmap(nLinCab + 3, nColIni + 5, cLogoEmp, 054, 054)
	oPrintPvt:SayAlign(nLinCab,    nColIni + 65, "Empresa:",                                      oFontCabN, 060, 07, , nPadLeft, )
	oPrintPvt:SayAlign(nLinCab,    nColIni + 95, cEmpresa,                                        oFontCab,  120, 07, , nPadLeft, )
	nLinCab += 7
	oPrintPvt:SayAlign(nLinCab,   nColIni + 65, "CNPJ:",                                          oFontCabN, 060, 07, , nPadLeft, )
	oPrintPvt:SayAlign(nLinCab,   nColIni + 87, cEmpCnpj,                                         oFontCab,  120, 07, , nPadLeft, )
	nLinCab += 7
	oPrintPvt:SayAlign(nLinCab,   nColIni + 65, "Cidade:",                                        oFontCabN, 060, 07, , nPadLeft, )
	oPrintPvt:SayAlign(nLinCab,   nColIni + 95, cEmpCidade,                                       oFontCab,  120, 07, , nPadLeft, )
	nLinCab += 7
	oPrintPvt:SayAlign(nLinCab,   nColIni + 65, "CEP:",                                           oFontCabN, 060, 07, , nPadLeft, )
	oPrintPvt:SayAlign(nLinCab,   nColIni + 85, cEmpCep,                                          oFontCab,  120, 07, , nPadLeft, )
	nLinCab += 7
	oPrintPvt:SayAlign(nLinCab,   nColIni + 65, "Telefone:",                                      oFontCabN, 060, 07, , nPadLeft, )
	oPrintPvt:SayAlign(nLinCab,   nColIni + 95, cEmpTel,                                          oFontCab,  120, 07, , nPadLeft, )
	nLinCab += 7
	oPrintPvt:SayAlign(nLinCab,   nColIni + 65, "FAX:",                                           oFontCabN, 060, 07, , nPadLeft, )
	oPrintPvt:SayAlign(nLinCab,   nColIni + 85, cEmpFax,                                          oFontCab,  120, 07, , nPadLeft, )
	nLinCab += 7
	oPrintPvt:SayAlign(nLinCab,   nColIni + 65, "e-Mail:",                                        oFontCabN, 060, 07, , nPadLeft, )
	oPrintPvt:SayAlign(nLinCab,   nColIni + 87, cFunEmail,                                        oFontCab,  120, 07, , nPadLeft, )
	nLinCab += 7
	oPrintPvt:SayAlign(nLinCab,   nColIni + 65, "Home Page:",                                     oFontCabN, 060, 07, , nPadLeft, )
	oPrintPvt:SayAlign(nLinCab,   nColIni + 105, cEmpSite,                                        oFontCab,  120, 07, , nPadLeft, )
	nLinCab += 7

	//Dados do Pedido
	nLinCab := nLinCabOrig
	oPrintPvt:Box(nLinCab, nColMeio + 3, nLinCab + 075, nColFin)
	oPrintPvt:Line(nLinCab + nTamFundo, nColMeio + 3, nLinCab + nTamFundo, nColFin)
	nLinCab += nTamFundo - 5
	oPrintPvt:SayAlign(nLinCab-10, nColMeio + 8,  "Pedido:",                                      oFontTit,  060, nTamFundo, nCorAzul, nPadLeft, )
	nLinCab += 5
	oPrintPvt:SayAlign(nLinCab,    nColMeio + 8,  "N�m.Pedido:",                                  oFontCabN, 060, 07, , nPadLeft, )
	oPrintPvt:SayAlign(nLinCab,    nColMeio + 52, Alltrim(QRY_PED->C7_NUM),                                oFontCabN, 060, 07, , nPadLeft, )
	nLinCab += 7
	oPrintPvt:SayAlign(nLinCab,    nColMeio + 8,  "Dt.Emiss�o:",                                  oFontCabN, 060, 07, , nPadLeft, )
	oPrintPvt:SayAlign(nLinCab,    nColMeio + 50, dToC(QRY_PED->C7_EMISSAO),                      oFontCab,  060, 07, , nPadLeft, )
	nLinCab += 7
	oPrintPvt:SayAlign(nLinCab,    nColMeio + 8,  "Fornecedor:",                                  oFontCabN, 060, 07, , nPadLeft, )
	oPrintPvt:SayAlign(nLinCab,    nColMeio + 51, cForAux,                                        oFontCab,  200, 07, , nPadLeft, )
	nLinCab += 7
	cCGC := SA2->A2_CGC
	If lCNPJ
		cCGC := Iif(!Empty(cCGC), Alltrim(Transform(cCGC, cMaskCNPJ)), "-")
		oPrintPvt:SayAlign(nLinCab, nColMeio + 8, "CNPJ:",                                        oFontCabN, 060, 07, , nPadLeft, )
	Else
		cCGC := Iif(!Empty(cCGC), Alltrim(Transform(cCGC, cMaskCPF)), "-")
		oPrintPvt:SayAlign(nLinCab, nColMeio + 8, "CPF:",                                         oFontCabN, 060, 07, , nPadLeft, )
	EndIf
	oPrintPvt:SayAlign(nLinCab, nColMeio + 32, cCGC,                                              oFontCab,  060, 07, , nPadLeft, )
	nLinCab += 7
	oPrintPvt:SayAlign(nLinCab, nColMeio + 8, "A/C:",                                             oFontCabN, 060, 07, , nPadLeft, )
	oPrintPvt:SayAlign(nLinCab, nColMeio + 25, SA2->A2_CONTATO,                                   oFontCab,  060, 07, , nPadLeft, )
	nLinCab += 7
	oPrintPvt:SayAlign(nLinCab, nColMeio + 8,  "Endere�o:",                                       oFontCabN, 060, 07, , nPadLeft, )
	oPrintPvt:SayAlign(nLinCab, nColMeio + 45, SA2->A2_END,                                       oFontCab,  200, 07, , nPadLeft, )
	nLinCab += 7
	oPrintPvt:SayAlign(nLinCab, nColMeio + 15, Alltrim(SA2->A2_MUN) + " / " + SA2->A2_EST + "    - Bairro " + SA2->A2_BAIRRO, oFontCab,  200, 07, , nPadLeft, )
	nLinCab += 7
	oPrintPvt:SayAlign(nLinCab, nColMeio + 8,  "Telefone:",                                       oFontCabN, 060, 07, , nPadLeft, )
	oPrintPvt:SayAlign(nLinCab, nColMeio + 40, "(" + SA2->A2_DDD + ") " + SA2->A2_TEL,            oFontCab,  200, 07, , nPadLeft, )
	nLinCab += 7

	//T�tulo
	nLinCab := nLinCabOrig + 080
	oPrintPvt:Box(nLinCab, nColIni, nLinCab + nTamFundo, nColFin)
	nLinCab += nTamFundo - 5
	oPrintPvt:SayAlign(nLinCab-10, nColIni, "Relat�rio de Pedidos de Compra:", oFontTit, nColFin-nColIni, nTamFundo, nCorAzul, nPadCenter, )

	//Linha Separat�rio
	nLinCab += 6

	//Cabe�alho com descri��es das colunas
	nLinCab += 3
	oPrintPvt:SayAlign(nLinCab, nPosCod , "C�d.Prod.", oFontDetN, 035, 07, , nPadLeft, )
	oPrintPvt:SayAlign(nLinCab, nPosDesc, "Descri��o", oFontDetN, 200, 07, , nPadLeft, )
	oPrintPvt:SayAlign(nLinCab, nPosForn, "Observa��o", oFontDetN, 040, 07, , nPadLeft, )
	oPrintPvt:SayAlign(nLinCab, nPosQtd , "Qtde",      oFontDetN, 040, 07, , nPadRight, )
	oPrintPvt:SayAlign(nLinCab, nPosUni , "Vlr.Uni.",  oFontDetN, 040, 07, , nPadRight, )
	oPrintPvt:SayAlign(nLinCab, nPosIPI , "% IPI",     oFontDetN, 040, 07, , nPadRight, )
	oPrintPvt:SayAlign(nLinCab, nPosTot , "Vlr.Tot.",  oFontDetN, 040, 07, , nPadRight, )
	oPrintPvt:SayAlign(nLinCab, nPosEnt , "Entrega",   oFontDetN, 040, 07, , nPadRight, )

	//Atualizando a linha inicial do relat�rio
	nLinAtu := nLinCab + 8
Return

/*---------------------------------------------------------------------*
 | Func:  fImpRod                                                      |
 | Desc:  Fun��o que imprime o rodap�                                  |
*---------------------------------------------------------------------*/

Static Function fImpRod()
	Local nLinRod:= nLinFin + 10
	Local cTexto := ""

	//Linha Separat�ria
	oPrintPvt:Line(nLinRod, nColIni, nLinRod, nColFin)
	nLinRod += 3

	//Dados da Esquerda
	cTexto := "Pedido: " + QRY_PED->C7_NUM + "    |    " + dToC(Date()) + "     " + cHoraEx + "     " + FunName() + "     " + UsrRetName(RetCodUsr())
	oPrintPvt:SayAlign(nLinRod, nColIni,    cTexto, oFontRod, 250, 07, , nPadLeft, )

	//Direita
	cTexto := "P�gina " + cValToChar(nPagAtu)
	oPrintPvt:SayAlign(nLinRod, nColFin-40, cTexto, oFontRod, 040, 07, , nPadRight, )

	//Finalizando a p�gina e somando mais um
	oPrintPvt:EndPage()
	nPagAtu++
Return

/*---------------------------------------------------------------------*
 | Func:  fLogoEmp                                                     |
 | Desc:  Fun��o que retorna o logo da empresa (igual a DANFE)         |
*---------------------------------------------------------------------*/

Static Function fLogoEmp()
	Local cGrpCompany := AllTrim(FWGrpCompany())
	Local cCodEmpGrp  := AllTrim(FWCodEmp())
	Local cUnitGrp    := AllTrim(FWUnitBusiness())
	Local cFilGrp     := AllTrim(FWFilial())
	Local cLogo       := ""
	Local cCamFim     := GetTempPath()
	Local cStart      := GetSrvProfString("Startpath", "")
	Local cEmpAux     := cEmpAnt + cFilAnt

	//Se tiver filiais por grupo de empresas
	If ! Empty(cUnitGrp)
		cDescLogo	:= cGrpCompany + cCodEmpGrp + cUnitGrp + cFilGrp

		//Sen�o, ser� apenas, empresa + filial
	Else
		cEmpAux     := cEmpAnt + cFilAnt
		cDescLogo	:= cEmpAux
	EndIf

	//Pega a imagem
	cLogo := cStart + "DANFE" + cDescLogo + ".BMP"

	//Se o arquivo n�o existir, pega apenas o da empresa, desconsiderando a filial
	If ! File(cLogo)
		cLogo	:= cStart + "DANFE" + cEmpAnt + ".BMP"
	EndIf

	//Copia para a tempor�ria do s.o.
	CpyS2T(cLogo, cCamFim)
	cLogo := cCamFim + StrTran(cLogo, cStart, "")

	//Se o arquivo n�o existir na tempor�ria, espera meio segundo para terminar a c�pia
	If !File(cLogo)
		Sleep(500)
	EndIf
Return cLogo

/*---------------------------------------------------------------------*
 | Func:  fSetLayout                                                   |
 | Desc:  Fun��o que muda as vari�veis das colunas do layout           |
*---------------------------------------------------------------------*/

Static Function fSetLayout()
	//Definindo os alinhamentos
	nPosCod  := 0010           //C�digo do Produto
	// DWT Luciano - 20230627
	nPosDesc := 0060           //Descri��o
	nPosForn := nColFin - 0320 //C�d. Forn.
	nPosQtd  := nColFin - 0200 //Qtde
	nPosUni  := nColFin - 0160 //Vlr. Unit.
	nPosIPI  := nColFin - 0120 //% IPI
	nPosTot  := nColFin - 0080 //Vlr. Tot.
	nPosEnt  := nColFin - 0040 //Entrega

	//Definindo as fontes
	oFontRod   := TFont():New(cNomeFont, , -06, , .F.)
	oFontTit   := TFont():New(cNomeFont, , -13, , .T.)
	oFontCab   := TFont():New(cNomeFont, , -07, , .F.)
	oFontCabN  := TFont():New(cNomeFont, , -07, , .T.)
	oFontDet   := TFont():New(cNomeFont, , -05, , .F.)
	oFontDetN  := TFont():New(cNomeFont, , -07, , .T.)
	oFontBlo   := TFont():New(cNomeFont, , -10, , .F.)
	oFontBloN  := TFont():New(cNomeFont, , -10, , .T.)
Return

/*---------------------------------------------------------------------*
 | Func:  fImpBloco                                                    |
 | Desc:  Fun��o que imprime o bloco final do relat�rio                |
*---------------------------------------------------------------------*/

Static Function fImpBloco()
	Local nLinBloco  := nLinAtu + 20
	Local cTextoDesc := ""
	Local nTotDesc   := SC7->C7_DESC1 + SC7->C7_DESC2 + SC7->C7_DESC3
	// DWT Luciano - 20230627
	Local nTotGeral  := (nValorTot - nTotDesc) + nTotIPI + nTotFrete   
	Local nTamBloco  := 155
	Local cFretePed  := ""
	Local cTexto := " "

	//Se o bloco for passar do limite da p�gina, faz uma quebra
	If nLinBloco + nTamBloco >= nLinFin
		fImpRod()
		fImpCab()
	EndIf

	//Definindo o tipo de Frete
	If QRY_PED->C7_TPFRETE == "C"
		cFretePed := "CIF"
	ElseIf QRY_PED->C7_TPFRETE == "F"
		cFretePed := "FOB"
	ElseIf QRY_PED->C7_TPFRETE == "T"
		cFretePed := "Terceiros"
	Else
		cFretePed := "Sem Frete"
	EndIf

	oPrintPvt:Box(nLinBloco, nColIni, nLinBloco + nTamBloco, nColFin)

	//T�tulo do Bloco
	oPrintPvt:Line(nLinBloco + nTamFundo, nColIni, nLinBloco + nTamFundo, nColFin)
	nLinBloco += nTamFundo - 5
	oPrintPvt:SayAlign(nLinBloco-10, nColIni, "Resumo e Totais:", oFontTit, nColFin-nColIni, nTamFundo, nCorAzul, nPadCenter, )
	nLinBloco += 5

	//Imprimindo Desconto
	cTextoDesc := Alltrim(Transform(SC7->C7_DESC1, "@E 99.99")) + "     +     " + ;
		Alltrim(Transform(SC7->C7_DESC2, "@E 99.99")) + "     +     " + ;
		Alltrim(Transform(SC7->C7_DESC3, "@E 99.99")) + "     =     " + ;
		Alltrim(Transform(nTotDesc,"@E 999.99"))
	oPrintPvt:SayAlign(nLinBloco, nColIni + 5,   "Desconto Especial (%):", oFontBlo,  100, 08, , nPadLeft, )
	oPrintPvt:SayAlign(nLinBloco, nColIni + 105, cTextoDesc,               oFontBloN, 200, 08, , nPadLeft, )
	nLinBloco += 10

	oPrintPvt:Line(nLinBloco + 1, nColIni, nLinBloco + 1, nColFin, )
	nLinBloco += 2

	//Imprimindo informa��es auxiliares
	oPrintPvt:SayAlign(nLinBloco, nColIni + 5,     "Condi��o de Pagamento:", oFontBlo,  100, 08, , nPadLeft, )
	oPrintPvt:SayAlign(nLinBloco, nColIni + 155,   "Data de Emiss�o:",       oFontBlo,  100, 08, , nPadLeft, )
	oPrintPvt:SayAlign(nLinBloco, nColIni + 305,   "Total das Mercadorias:", oFontBlo,  100, 08, , nPadLeft, )
	nLinBloco += 10
	oPrintPvt:SayAlign(nLinBloco, nColIni + 5,     QRY_PED->C7_COND + " - " + QRY_PED->E4_DESCRI,      oFontBloN, 100, 08, , nPadLeft, )
	oPrintPvt:SayAlign(nLinBloco, nColIni + 155,   dToC(QRY_PED->C7_EMISSAO),                          oFontBloN, 100, 08, , nPadLeft, )
	oPrintPvt:SayAlign(nLinBloco, nColIni + 305,   Alltrim(Transform(nValorTot - nTotDesc, cMaskVlr)), oFontBloN, 200, 08, , nPadLeft, )
	nLinBloco += 10

	oPrintPvt:Line(nLinBloco - 21, nColIni + 150, nLinBloco + 1, nColIni + 150, )
	oPrintPvt:Line(nLinBloco - 21, nColIni + 300, nLinBloco + 1, nColIni + 300, )
	oPrintPvt:Line(nLinBloco + 1,  nColIni,       nLinBloco + 1, nColFin, )
	nLinBloco += 2

	//Observa��es e Local de Entrega
	oPrintPvt:SayAlign(nLinBloco, nColIni  + 5,     "Observa��es:",                                     oFontBlo,  100, 08, , nPadLeft, )
	oPrintPvt:SayAlign(nLinBloco, nColMeio + 5,     "Local de Entrega:",                                oFontBlo,  100, 08, , nPadLeft, )
	nLinBloco += 10
	oPrintPvt:SayAlign(nLinBloco, nColMeio + 5,     "Endere�o: " + SM0->M0_ENDENT,                      oFontBloN,  200, 08, , nPadLeft, )
	nLinBloco += 10
	/*oPrintPvt:SayAlign(nLinBloco, nColMeio + 5,     "Complemento: " + SM0->M0_COMPENT,                  oFontBloN,  200, 08, , nPadLeft, )
	nLinBloco += 10*/																																	   
				
	oPrintPvt:SayAlign(nLinBloco, nColMeio + 5,     "Bairro: " + SM0->M0_BAIRENT,                       oFontBloN,  200, 08, , nPadLeft, )
	nLinBloco += 10
	oPrintPvt:SayAlign(nLinBloco, nColMeio + 5,     "CEP: " + SM0->M0_CEPENT,                           oFontBloN,  200, 08, , nPadLeft, )
	nLinBloco += 10
	oPrintPvt:SayAlign(nLinBloco, nColMeio + 5,     Alltrim(SM0->M0_CIDENT) + " / " + SM0->M0_ESTENT,   oFontBloN,  200, 08, , nPadLeft, )
	nLinBloco += 10

	oPrintPvt:Line(nLinBloco - 51, nColMeio, nLinBloco + 1, nColMeio, )
	oPrintPvt:Line(nLinBloco + 1,  nColIni,  nLinBloco + 1, nColFin, )
	//Totais e Outras Informa��es
	oPrintPvt:SayAlign(nLinBloco, nColIni  + 5,     "Tp. Frete:",                                     oFontBlo,  100, 08, , nPadLeft, )
	oPrintPvt:SayAlign(nLinBloco, nColIni  + 55,    cFretePed,                                        oFontBloN, 100, 08, , nPadLeft, )
	oPrintPvt:SayAlign(nLinBloco, nColMeio + 5,     "Frete:",                                         oFontBlo,  100, 08, , nPadLeft, )
	oPrintPvt:SayAlign(nLinBloco, nColMeio + 55,    Alltrim(Transform(nTotFrete, cMaskFrete)),   oFontBloN, 100, 08, , nPadLeft, )
	nLinBloco += 10
	oPrintPvt:SayAlign(nLinBloco, nColIni  + 5,     "IPI:",                                           oFontBlo,  100, 08, , nPadLeft, )
	oPrintPvt:SayAlign(nLinBloco, nColIni  + 55,    Alltrim(Transform(nTotIPI, cMaskVlr)),            oFontBloN, 100, 08, , nPadLeft, )
	oPrintPvt:SayAlign(nLinBloco, nColMeio + 5,     "ICMS:",                                          oFontBlo,  100, 08, , nPadLeft, )
	oPrintPvt:SayAlign(nLinBloco, nColMeio + 55,    Alltrim(Transform(nTotICMS, cMaskVlr)),           oFontBloN, 100, 08, , nPadLeft, )
	nLinBloco += 10
	oPrintPvt:SayAlign(nLinBloco, nColIni  + 5,     "Seguro:",                                        oFontBlo,  100, 08, , nPadLeft, )
	oPrintPvt:SayAlign(nLinBloco, nColIni  + 55,    Alltrim(Transform(SC7->C7_SEGURO, cMaskVlr)),     oFontBloN, 100, 08, , nPadLeft, )
	oPrintPvt:SayAlign(nLinBloco, nColMeio + 5,     "Despesas:",                                      oFontBlo,  100, 08, , nPadLeft, )
	oPrintPvt:SayAlign(nLinBloco, nColMeio + 55,    Alltrim(Transform(SC7->C7_DESPESA, cMaskVlr)),    oFontBloN, 100, 08, , nPadLeft, )
	nLinBloco += 10
	oPrintPvt:SayAlign(nLinBloco, nColIni  + 5,     "Reajuste:",                                      oFontBlo,  100, 08, , nPadLeft, )
	oPrintPvt:SayAlign(nLinBloco, nColIni  + 55,    SC7->C7_REAJUST,                                  oFontBloN, 100, 08, , nPadLeft, )
	nLinBloco += 10

	oPrintPvt:Line(nLinBloco + 1,  nColIni,  nLinBloco + 1, nColFin, )
	nLinBloco += 2

	//Total Final
	oPrintPvt:SayAlign(nLinBloco, nColIni  + 5,     "Peso Total:",                                     oFontBloN, 100, 08, , nPadLeft, )
	oPrintPvt:SayAlign(nLinBloco, nColIni  + 55,    Alltrim(Transform(nTotPeso, cMaskVlr)),            oFontBloN, 100, 08, , nPadLeft, )
	oPrintPvt:SayAlign(nLinBloco, nColMeio + 5,     "Total Geral:",                                    oFontBloN, 100, 08, , nPadLeft, )
	oPrintPvt:SayAlign(nLinBloco, nColMeio + 55,    Alltrim(Transform(nTotGeral, cMaskVlr)),           oFontBloN, 100, 08, , nPadLeft, )
	nLinBloco += 10

	oPrintPvt:Line(nLinBloco - 11, nColMeio, nLinBloco + 2, nColMeio, )
	nLinBloco += 2
	cTexto := ' ' + CRLF
	cTexto += 'CONDI��ES GERAIS:' + CRLF
	cTexto += '1. Todos os itens fornecidos devem estar em conformidade com as especifica��es t�cnicas pre-estabelecidas entre as partes, sendo a divergencia objeto de devolu��o e demerito do fornecedor.' + CRLF
	cTexto += '2. Os prazos de entrega ajustados nesta ordem de compra dever�o ser respeitados e em caso de atraso dever�o ser justicados em at� 48 horas antes da data aprazada para avalia��o do cliente. Se o atraso foi injustificado, o cliente poder� cancelar parte ou totalidade do pedido, mediante aviso escrito ao fornecedor.' + CRLF
	cTexto += '3. Dever� ser indicado na nota fiscal o n�mero desta ordem de compra.' + CRLF
	cTexto += '4. A n�o observ�ncia das diretrizes acarretar� na devolu��o do documento sem o devido registro pela �rea fiscal.' + CRLF
	cTexto += '5. N�o ser�o aceitos T�tulos Banc�rios com instru��o autom�tica de protesto.' + CRLF
	cTexto += '6. Fornecedor optante pelo Simples Nacional dever� enviar a "DECLARA��O DE ENQUADRAMENTO NO SIMPLES NACIONAL".' + CRLF
	nLinBloco += 2
	nLargura := 500
	nAltura := 350
	oPrintPvt:SayAlign(nLinBloco, nColIni  + 5,     cTexto,                                   oFontDetN,  nLargura , nAltura , , nPadLeft, )
Return
