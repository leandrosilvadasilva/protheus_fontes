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
		
					(cAlias)->C7_DATPRF := dEntrega 
				MsUnlock()
                MsgInfo("Data de Entrega atualizada para o Item Selecionado.","Alteração Concluida!") 
				
			ElseIf _nCombo == 2 //por Pedido
							
				SC7->(DbGoTop())
				SC7->(DbSeek(xFilial("SC7")+Alltrim(cNum))) 
				While SC7->(!Eof()) .And. SC7->C7_FILIAL+SC7->C7_NUM == xFilial("SC7")+Alltrim(cNum)
				
                    If SC7->C7_QUANT>SC7->C7_QUJE

						Reclock("SC7",.F.)
					    	(cAlias)->C7_DATPRF := dEntrega 
						MsUnlock()
					
                    EndIf
					SC7->(DbSkip())
				EndDo
				MsgInfo("Data de Entrega atualizada por Pedido.","Alteração Concluida!") 
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

