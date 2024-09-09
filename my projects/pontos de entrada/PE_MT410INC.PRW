#Include "Protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³U_MT410INC³ Autor ³ Expedito Mendonca Jr  ³ Data ³16/09/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Ponto de entrada logo apos a inclusao do pedido de venda.  ³±±
±±³          ³ Utilizado na rotina de Oportunidades de Venda (FATA300)    ³±±
±±³          ³ para gravar a descricao do servico com base no campo       ³±±
±±³          ³ "Descricao Tecnica" informado na oportunidade de venda.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ U_MT410INC()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico para cliente                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                          ULTIMAS ALTERACOES                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ Motivo da Alteracao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
User Function MT410INC()
Local aAreaAnt := GetArea()
Local aAreaSCJ := SCJ->(GetArea())
Local aAreaAD1 := AD1->(GetArea())
Local aAreaADY := ADY->(GetArea())
Local aAreaSC6 := SC6->(GetArea())
Local aAreaSA1 := SA1->(GetArea())
Local nDesco   := 0

Local retorno 
Local mensagem := ""

// Oportunidades de venda via menu ou via Area de Trabalho do vendedor
If Funname() == 'CRMA110' .or. Funname() == 'CRMA290' .or. Funname() == "FATA300" .or. Funname() == "FATA320"
	
	// tabela de orcamento (SCJ) ja se encontra posicionada neste ponto de entrada
	// Posiciona a tabela de cabecalho da oportunidade comercial a partir do orcamento (SCJ)
	AD1->( dbSetOrder(1) )		// ADY_FILIAL+ADY_PROPOS
	AD1->( dbSeek( xFilial("AD1")+SCJ->CJ_NROPOR, .F. ) )
	
	// Posiciona a tabela de cabecalho da proposta comercial a partir do orcamento (SCJ)
	ADY->( dbSetOrder(1) )		// ADY_FILIAL+ADY_PROPOS
	ADY->( dbSeek( xFilial("ADY")+SCJ->CJ_PROPOST, .F. ) )
	
	SA1->( dbSeek(xFilial('SA1')+SC5->C5_CLIENTE+SC5->C5_LOJACLI) )
	
	// Grava a descricao dos servicos (tabela SC5 ja posicionada)
	RecLock('SC5', .F.)
	
	
	// AD1 - PROPOSTA
	// ADY - OPORTUNIDADE
	//SC5->C5_OBSEXPE := MSMM(AD1->AD1_CODMEM,,,,3)  // OBSERVACAO DO PEDIDO DE VENDAS
	SC5->C5_OBSEXPE := ADY->ADY_OBS    // OBSERVACAO DO PEDIDO DE VENDAS
	SC5->C5_PEDCLI  := AD1_PEDCLI      // ORDEM DE COMPRA DO CLIENTE
	SC5->C5_INDPROC := AD1->AD1_INDPRO      // Indicador de Processo
	If Empty(SC5->C5_TPFRETE) .and. !Empty(ADY->ADY_TPFRET)
		SC5->C5_TPFRETE := ADY->ADY_TPFRET // TIPO DE FRETE UTILIZADO
	Endif
	SC5->C5_FORPG   := ADY->ADY_FORPG  // FORMA DE PAGAMENTO
	SC5->C5_NROPOR := AD1->AD1_NROPOR  // NUMERO DA OPORTUNIDADE
	SC5->C5_ZTPLIBE := ADY->ADY_ZTPLIB  // PERMITE FATURAMENTO PARCIAL (SIM OU NAO)
	//SC5->C5_PROPOS  := ADY->ADY_PROPOS
	//SC5->C5_PEDCLI   := ADY->ADY_PEDCLI   // (CRIAR NA ABA ACEITE DA PROPOSTA)
	SC5->( MsUnLock() )
	
	// processa os itens do pedido de venda
	SC6->( dbSeek(xFilial('SC6')+SC5->C5_NUM) )
	
	// Comodato ja tem no fluig
	// revenda 01
	// importacao representada e a mesma coisa
	
	
	
	While SC6->( !Eof() ) .and.  xFilial('SC6')+SC5->C5_NUM == SC6->C6_FILIAL+SC6->C6_NUM
		
		// recalcula os descontos
		nDesco   := (SC6->C6_PRUNIT - SC6->C6_PRCVEN) / SC6->C6_PRUNIT * 100
		RecLock('SC6', .F.)
		
		SC6->C6_VLDESMA := SC6->C6_PRUNIT - SC6->C6_PRCVEN
		SC6->C6_DESCOMA := nDesco
		SC6->C6_PRUNIT  := SC6->C6_PRCVEN
		SC6->C6_COMIS1  := U_MAHG010(SC5->C5_VEND1, SC6->C6_PRODUTO, nDesco)
		SC6->C6_INDPROC := AD1->AD1_INDPRO      // Indicador de Processo
		IF EMPTY(SC6->C6_ENTREG)
			SC6->C6_ENTREG  := dDatabase
		ENDIF
		
		SC6->C6_DESCONT  :=0
		SC6->C6_VALDESC  :=0
		
		SC6->C6_PEDCLI  := AD1->AD1_PEDCLI
		SC6->( MsUnLock() )
		
		SC6->( dbSkip() )
		
	EndDo
	
	// verfica e alerta o usuario caso o cliente seja nao contribuinte
	If SA1->A1_CONTRIB == '1'
		MsgInfo("Pedido será gerado para cliente CONTRIBUINTE!.","ATENÇÃO!")
	Else
		MsgInfo("Pedido será gerado para cliente NAO CONTRIBUINTE!.","ATENÇÃO!")
	EndIf
	
Else

	// Grava a descricao dos servicos (tabela SC5 ja posicionada)
	//RecLock('SC5', .F.)
	
	//SC5->( MsUnLock() )
	
	// processa os itens do pedido de venda
	SC6->( dbSeek(xFilial('SC6')+SC5->C5_NUM) )
	While SC6->( !Eof() ) .and.  xFilial('SC6')+SC5->C5_NUM == SC6->C6_FILIAL+SC6->C6_NUM
		
		RecLock('SC6', .F.)
		
		IF EMPTY(SC6->C6_ENTREG) .OR. SC6->C6_ENTREG<dDatabase
			SC6->C6_ENTREG  := dDatabase
		ENDIF
		
		
		
		SC6->C6_DESCONT  :=0
		SC6->C6_VALDESC  :=0
		
		IF SC6->C6_TES = '611'   //Se for TES de demonstracao o armazem deve ser o 03(Armazem de DEMONSTRACAO)
			SC6->C6_LOCAL := '03'
		ENDIF

		SC6->( MsUnLock() )
				
		
		SC6->( dbSkip() )
		
	EndDo
	

Endif 

	//IATAN EM 25/08/2022
	conout("zoho PE_MT410INC -- 1")
	IF U_checkOper(SC5->C5_FILIAL, SC5->C5_NUM) == .T.
		//alert("PEDIDOS COM OPERACAO 15 E 22 NAO SERAO INTEGRADOS")
	ELSE	
		///IATAN EM 14/07/2022
		//INCLUIDO PARA ATENDER A NECESSIDADE DE ENVIAR O PEDIDO PARA O WMS CASO NÃO EXISTA BLOQUEIO DE CRÉDITO
		//U_MAPWMS07( SC5->(RECNO()), "")
		//IATAN EM 22/06/2023
		conout("zoho PE_MT410INC -- 2")
		retorno := U_MAPWMS07( SC5->(RECNO()), @mensagem)
		conout("zoho PE_MT410INC -- 3")
		IF retorno == .T. .AND. !EMPTY(ALLTRIM(mensagem))
			RecLock("SC5",.F.)
			SC5->C5_XWMS	:= "S"  
			SC5->C5_XMSGWMS	:= mensagem
			SC5->( MsUnlock() )
			conout("zoho PE_MT410INC -- 4")
			//alert("INTEGRADO COM SUCESSO")
		ENDIF
	ENDIF

// Restaura o ambiente
RestArea(aAreaSCJ)
RestArea(aAreaAD1)
RestArea(aAreaADY)
RestArea(aAreaSC6)
RestArea(aAreaSA1)
RestArea(aAreaAnt)

Return
