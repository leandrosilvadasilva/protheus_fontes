#include 'Totvs.ch'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MAH030    ³ Autor ³ Ednei Silva          ³ Data ³26/09/2018³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta uma tela para Alterar informacoes no Pedido de       ³±±
±±³          ³ compra sem desfazer as Liberacoes.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MAHOPITALAR / Compras	                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador  ³ Data   ³ Motivo da Alteracao                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Rafael Filipe ³24/02/22³ Inclusao Alteracao pedido Completo-Ticket 4969³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
User Function MAHA025( cAlias, nReg, nOpcx )

	Local nLinha		:= 010
	Local lGrava		:= .F.
	Local lEdita		:= .F.
	
	Local   aCombo	    := {"1 - Por Item","2 - Por Pedido"}
	Local   oCombo
    Local cTo			:= SuperGetMV("MA_DMAILPC",,"leandro.silva@mahospitalar.com.br")
	Local cMensagem		:= ""
	Local cAssunto		:= ""

	Private _cCombo		:= aCombo[1]
	Private _nCombo		:= 1 
	
	Private oNum		
	Private oItem	    
	Private oProduto	
	Private oEntrega	
    
 	Private cNum		:= (cAlias)->C7_NUM
	Private cItem	    := (cAlias)->C7_ITEM
	Private cProduto	:= (cAlias)->C7_PRODUTO
	Private dEntrega	:= (cAlias)->C7_DATPRF
	Private cDescProd   :=  CriaVar("B1_DESC")

	If	!Empty(cProduto)
		A010ValProd(cProduto)
	EndIf



	If SC7->C7_QUANT>SC7->C7_QUJE
	
		Define MsDialog oDlg01 Title cCadastro  From 000,000 To 350, 520 Pixel
        //Define MsDialog oDlg01 Title cCadastro  From 000,000 To 460, 730 Pixel
	
			@ nLinha + 002, 010 Say OemToAnsi("Pedido") Of oDlg01 Pixel
			@ nLinha, 055 MsGet oNum  Var cNum of oDlg01  Pixel When lEdita  Size 110, 012
	
			@ nLinha + 002, 170 Say OemToAnsi("Item") Of oDlg01 Pixel
			@ nLinha, 190 MsGet oItem Var cItem of oDlg01  Pixel When lEdita  Size 50, 012
			
            nLinha += 018
			@ nLinha + 002, 010 Say OemToAnsi("Produto") Of oDlg01 Pixel
			@ nLinha, 055 MsGet oProduto Var cProduto of oDlg01  Pixel F3 "SB1" Valid A010ValProd(cProduto) When lEdita Size 110, 012
			
            nLinha += 018
            @ nLinha + 002, 10 Say OemToAnsi("Descrição") Of oDlg01  Pixel
            @ nLinha, 055 MsGet oDescProd Var cDescProd of oDlg01  Pixel When lEdita  Size 185, 012
	
	   		nLinha += 018
			@ nLinha + 002, 10 Say OemToAnsi("Data Entrega") Of oDlg01  Pixel
		  	@ nLinha, 055 MsGet oEntrega Var dEntrega Picture "99/99/9999"  of oDlg01  Pixel Valid (!Empty(dEntrega))
		
	   		nLinha += 018
			@ nLinha + 002, 10 Say OemToAnsi("Pedido Total/Item") Of oDlg01  Pixel
			@ nLinha ,55  MSCOMBOBOX oCombo VAR _cCombo ITEMS aCombo SIZE 60 ,11 OF oDlg01:Refresh() PIXEL  VALID (_nCombo:=aScan(aCombo,_cCombo)) 
			
			nLinha += 030
			@ nLinha, 150 Button 'OK'		Size 030,015 Of oDlg01 Pixel Action ( oDlg01:End(), lgrava:= .T. )
			@ nLinha, 090 Button 'CANCELAR'	Size 030,015 Of oDlg01 Pixel Action ( oDlg01:End(), lgrava:= .F. )
	
		Activate MsDialog oDlg01 Centered

		If	lGrava
			If	_nCombo == 1 //Por Item
								
				DbSelectArea(cAlias)
				RecLock(cAlias, .F. )
					//Envia e-mail se a diferença de data for superior a 30 dias
					If DateDiffDay(SC7->C7_DATPRF, dEntrega) >= 30
						cAssunto := "Alteracao de data de entrega no pedido " + SC7->C7_NUM
						cMensagem := "A data de entrega do item " + SC7->C7_ITEM + ", produto " + AllTrim(SC7->C7_PRODUTO) + " do pedido " + SC7->C7_NUM +;
						" está sendo alterada de " + DToC(SC7->C7_DATPRF) + " para " + DToC(dEntrega) + "."
					EndIf
		
					(cAlias)->C7_DATPRF := dEntrega 
				MsUnlock()
                MsgInfo("Data de Entrega atualizada para o Item Selecionado.","Alteração Concluida!") 
				
			ElseIf _nCombo == 2 //por Pedido
							
				SC7->(DbGoTop())
				SC7->(DbSeek(xFilial("SC7")+Alltrim(cNum))) 
				While SC7->(!Eof()) .And. SC7->C7_FILIAL+SC7->C7_NUM == xFilial("SC7")+Alltrim(cNum)
				
                    If SC7->C7_QUANT>SC7->C7_QUJE
						//Envia e-mail se a diferença de data for superior a 30 dias
						If DateDiffDay(SC7->C7_DATPRF, dEntrega) >= 30
							cAssunto := "Alteracao de data de entrega no pedido " + SC7->C7_NUM
							cMensagem += "A data de entrega do item " + SC7->C7_ITEM + ", produto " + AllTrim(SC7->C7_PRODUTO) + " do pedido " + SC7->C7_NUM +;
							" está sendo alterada de " + DToC(SC7->C7_DATPRF) + " para " + DToC(dEntrega) + "." + CRLF
						EndIf

						Reclock("SC7",.F.)
					    	(cAlias)->C7_DATPRF := dEntrega 
						MsUnlock()
					
                    EndIf
					SC7->(DbSkip())
				EndDo
				MsgInfo("Data de Entrega atualizada por Pedido.","Alteração Concluida!")

				If ! Empty(cMensagem)
					u_xTstWFlow(cTo, cAssunto, cMensagem)
				EndIf 
            else
                 MsgInfo("Pedido de Compra não atualizado.","Atenção!") 
			EndIF
             
		EndIf
    Else
    
    	MsgInfo("Pedido de Compra ja atendido, não pode ser alterado.","Atenção!")
    EndIf
Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A010ValProd  ³ Autor ³  Ednei Silva      ³ Data ³27/09/2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Validação Produto                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³  A010ValProd()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cProduto - Produto 				                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A010ValProd(cProduto)

	lRet := .T.

	If !Empty(cProduto)

		DbSelectArea("SB1")
		DbSetOrder(1)

		If	DbSeek(xFilial("SB1")+cProduto)
			cDescProd  := SB1->B1_DESC
		Else

			Aviso("MAHA030","Produto nao Cadastrado!", { "Sair" }, 2)
			lRet := .F.

		EndIf

	EndIf

Return(lRet)

/*/{Protheus.doc}xTstWFlow
Envia e-mail
/*/
User Function xTstWFlow(cTo, cAssunto, cMensagem, aAnexos, cMailFrom, lExibeMsg, cCC, cCO)
	Local 	oServer
	Local	oMessage
	Local 	cMailServer		:= SuperGetMv("MV_RELSERV", , "smtp.office365.com") //smtp.office365.com
	Local 	nMailPorta		:= 587
	Local 	cMailConta		:= SuperGetMV("MV_RELACNT",,"")
	Local 	cMailSenha		:= SuperGetMV("MV_RELAPSW",,"")
	Local 	lUseSSL			:= SuperGetMV("MV_RELSSL",,.F.)
	Local 	lUseTLS			:= SuperGetMV("MV_RELTLS",,.T.)
	Local 	lMailAuth		:= SuperGetMV("MV_RELAUTH",,.T.)
    Local   nErro           := -1
    Local   lContinue       := .T.
	Local nI				:= 0

	Default cTo				:= "leandro.silva@mahospitalar.com.br"
	Default cAssunto		:= "Exemplo de Assunto"
	Default cMensagem		:= "Exemplo de Mensagem"
	Default aAnexos			:= {}
	Default cMailFrom		:= "" //'E-mail automatico, nao responder<leandro.silva@mahospitalar.com.br>'
	Default	lExibeMsg		:= .F.
	 
	// Prepara conexao com o servidor de e-mails.
	oServer := TMailManager():New()
	oServer:SetUseSSL(lUseSSL)
	oServer:SetUseTLS(lUseTLS)
	oServer:Init("", cMailServer, cMailConta, cMailSenha,0,nMailPorta)
	oServer:SetSmtpTimeOut(60)
	nErro := oServer:SMTPConnect()

	If nErro != 0
		lContinue := .F.
        Help(,, 'Falha',, "N o foi poss vel conectar no servidor de e-mail: " + cMailServer, 1, 0,,,,,.F.,{oServer:GetErrorString(nErro)})
	EndIf

	If lContinue .And. lMailAuth
		nErro := oServer:SMTPAuth(AllTrim(cMailConta), AllTrim(cMailSenha))
		If nErro != 0
			lContinue := .F.
		    Help(,, 'Falha',, "[AUTH] Erro na autenticacao por conta e senha ", 1, 0,,,,,.F.,{oServer:GetErrorString(nErro)})
        EndIf
	EndIf

    If lContinue
        oMessage := TMailMessage():New()
        //Limpa o objeto
        oMessage:Clear()
        //Popula com os dados de envio
        oMessage:cFrom  := cMailFrom
        oMessage:cTo 	:= AllTrim(cTo)
		oMessage:CCC 	:= AllTrim(cCC)
		oMessage:CBCC 	:= AllTrim(cCO)
        oMessage:cSubject := 	OemToAnsi(cAssunto)
        oMessage:cBody 	:= cMensagem

		If Len(aAnexos) > 0
			For nI := 1 To Len(aAnexos)
				xRet := oMessage:AttachFile( aAnexos[nI] )
  				if xRet < 0
    				Help(,, 'Falha',, "Falha ao anexar arquivo", 1, 0)
				endif
			Next nI
		EndIf

        //Envia o e-mail
        nErro := oMessage:Send(oServer)
        If nErro != 0
            Help(,, 'Falha',, "Falha no envio do e-mail ", 1, 0,,,,,.F.,{oServer:GetErrorString(nErro)})
        Else
            //If lExibeMsg
				Help(,, 'Sucesso',, "E-mail de teste enviado com sucesso ", 1, 0,,,,,.F.,{oServer:GetErrorString(nErro)})
			//EndIf
        EndIf

        //Desconecta do servidor
        oServer:SmtpDisconnect()
    EndIf

Return

