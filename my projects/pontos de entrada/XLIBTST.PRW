USER Function MaLibDoFat( nRegSC6   , nQtdaLib  , lCredito  , lEstoque  , ;
					 lAvCred   , lAvEst    , lLibPar   , lTrfLocal , ;
					 aEmpenho  , bBlock    , aEmpPronto, lTrocaLot , ;
					 lGeraDCF  , nVlrCred  , nQtdalib2 , lLogMsg   , ;
					 lOrdSepLib)

Local aArea    	    := GetArea("SC6")
Local aAreaSA1 	    := SA1->(GetArea())
Local aAreaSF4 	    := SF4->(GetArea())
Local aAreaSC5 	    := {}
Local aAreaSC6 	    := {}
Local nQtdLib  	    := nQtdALib
Local nQtdLib2 	    := nQtdALib2
Local lContinua	    := .T.
Local lLibItPrev    := SuperGetMV( 'MV_FATLBPR', .F., .T. )	//Indica se permite a liberação de Itens previstos do Pedido de Venda

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Integracao SIGAFAT e SIGADPR                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lIFatDpr	 := SuperGetMV("MV_IFATDPR",.F.,.F.)

nQtdLib := nQtdALib
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Seta os parametros defaults                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFAULT nQtdALib   := SC6->C6_QTDLIB
DEFAULT nQtdALib2  := SC6->C6_QTDLIB2
DEFAULT lCredito   := .T.
DEFAULT lEstoque   := .T.
DEFAULT lAvCred    := .T.
DEFAULT lAvEst     := .T.
DEFAULT lGeraDCF   := .T.
DEFAULT lLogMsg    := .F.
DEFAULT lOrdSepLib := .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posiciona Pedido                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(SC6->C6_BLOQUEI) .And. AllTrim(SC6->C6_BLQ)<>"R" .And. !(lOrdSepLib)

	dbSelectArea("SC6")
	If nRegSC6<>0
		aAreaSC6 := GetArea()
		MsGoto(nRegSC6)
	Else
		aAreaSC6 := GetArea("SC6")
	EndIf

	If SB1->B1_FILIAL+SB1->B1_COD <> xFilial('SB1')+SC6->C6_PRODUTO
		SB1->(DbSetOrder(1))
		SB1->(MsSeek(xFilial('SB1')+SC6->C6_PRODUTO))
	Endif
	dbSelectArea("SC5")
	dbSetOrder(1)
	If ( xFilial("SC5")==SC5->C5_FILIAL .And. SC5->C5_NUM==SC6->C6_NUM )
		aAreaSC5 := GetArea("SC5")
	Else
		MsSeek(xFilial("SC5")+SC6->C6_NUM)
		aAreaSC5 := GetArea()
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Integracao com EEC													   ³
	//³Funcao: AvChkStDesp()												   ³
	//³Parametros: Nro do pedido de venda. 									   ³
	//³Retorno: True  - O pedido de venda podera ser liberado visto que as 	   ³
	//³					despesas ja foram integradas.						   ³
	//³         False - O pedido de venda não poderá ser liberado visto que    ³
	//³					existem pendencias para as despesas.				   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(SC5->C5_PEDEXP)
		If FindFunction("AvChkStDesp")
			If !AvChkStDesp(SC5->C5_NUM)
				lContinua := .F.
			EndIf
		EndIf
	EndIf

	//------------------------------------------------------------------------------
	// Verifica o tipo de operação (C6_TPOP) antes de liberar. Itens previstos não
	// podem ser liberados a menos que o parâmetro MV_FATLBPR esteja como .T.
	// Alteração realizada para atender o requisito de Programação de Entrega.
	//------------------------------------------------------------------------------
	If ( SC6->C6_TPOP == "P" ) .And. ( !lLibItPrev )
		lContinua := .F.
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ M_SER004_CRM019_Integraçao_Faturamento_DPR                           ³
	//³ Se o item eh do tipo "Desenvolvimento" nao libera para faturamento   ³
	//³ Autor: Thiago Tavares													   ³
	//³ Data: 25/10/2013															   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lIFatDpr
		If SC6->C6_TPPROD == "2"
			lContinua := .F.
		EndIf
	EndIf

	If lContinua
		If nRegSC6 == 0 .Or. ( RecLock("SC5") .And. RecLock("SC6") )
			If Empty(SC5->C5_BLQ)
				If nQtdALib2 == 0 .And. SC6->C6_UNSVEN <> 0
					nQtdALib2 := SB1->(ConvUm(SC6->C6_PRODUTO,nQtdALib,Nil,2))
					If nQtdALib2 == 0
						If SC6->C6_QTDVEN-SC6->C6_QTDEMP-SC6->C6_QTDENT-nQtdALib==0
							nQtdALib2 := SC6->C6_UNSVEN-SC6->C6_QTDEMP2-SC6->C6_QTDENT2
						Else
							nQtdALib2 := nQtdALib*SC6->C6_UNSVEN/SC6->C6_QTDVEN
						EndIf
					EndIf
					SC6->C6_QTDLIB2:= nQtdALib2
					nQtdALib2 := SC6->C6_QTDLIB2
				EndIf
				SC6->C6_QTDLIB := nQtdALib
				SC6->C6_QTDLIB2:= nQtdALib2
				FatAtuEmpN("-")
				nQtdLib := U_a440GeraC9(@nQtdLib,@lCredito,@lEstoque,lAvCred,lAvEst,lLibPar,lTrfLocal,@aEmpenho,bBlock,aEmpPronto,lTrocaLot,lGeraDCF,@nVlrCred,@nQtdlib2)
				FatAtuEmpN("+")
			EndIf
		EndIf
	Else
		nQtdLib := 0
	EndIf
	RestArea(aAreaSC5)
	RestArea(aAreaSC6)

Else
	nQtdLib := 0
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaura a Entrada                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea(aAreaSA1)
RestArea(aAreaSF4)
RestArea(aArea)
Return(nQtdLib)






USER Function MaGravaSC9(nQtdLib,cBlqCred,cBlqEst,aLocal,aEmpenho,cIdentB6,bBlock,aEmpPronto,nQtdLib2,nVlrCred,cBlqWMS,lGeraDCF)

Static lMA440GrLt
Static cTiposLC

Local aArea    	     := GetArea(Alias())
Local aAreaSA1 	     := SA1->(GetArea())
Local aAreaSB2 	     := SB2->(GetArea())
Local aAreaSF4 	     := SF4->(GetArea())
Local aAreaSB1 	     := SB1->(GetArea())
Local aAuxiliar      := {}
Local aLocaliz       := {}
Local aSaldos        := {}
Local nX             := 0
Local nY             := 0
Local nAuxiliar      := 0
Local nQtdRese       := 0
Local nMCusto        := 0
Local nSaveSX8       := GetSX8Len()
Local nRegEmp        := 0
Local cQuery         := ""
Local cNameQry       := ""
Local cSeqSC9        := "00"
Local cReserva       := ""
Local lAtualiza      := If(aEmpenho==Nil,.T.,.F.)
Local lEstoque       := .F.
Local lCredito       := .F.
Local lHasWMS        := IntWms(SC6->C6_PRODUTO) .And. !Empty(SC6->C6_SERVIC) //-- Soh considera o uso do WMS se houver Servico Preenchido para o Item do SC6
Local lUsaVenc       := .F.
Local lReserva       := .F.
Local lEmpenha       := .F.
Local lContercOk     := .F.
Local lInfLote       := .F.
Local lResEst        := SuperGetMv("MV_RESEST")
Local lIntACD	     := SuperGetMV("MV_INTACD",.F.,"0") == "1"
Local lACDSer        := SuperGetMV("MV_SUBNSER",.F.,'1') $ '2|3'
Local dValidLote     := Ctod( "" )
Local nRecSC9        := 0
Local nPrcVen        := 0
Local nTotSC9        := 0
Local nTotSC9Aux     := 0
Local nDecimal       := TamSx3("C9_PRCVEN")[2]
Local aInsert 	     := {}
Local nLen 		     := 0 
Local nPosPrepared   := 0 
Local cMD5 		     := "" 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento para e-Commerce      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lECommerce     := SuperGetMV("MV_LJECOMM",,.F.)
Local lRetWmsPE      := lHasWMS
Local cSeq           := ""
Local lUseOffBalance := .F.
Local lLibPed  		 := .F.
Local lNSer0End      := .F.
Local lTrvSA1        := .T.

   //Este ponto de entrada é utilizado pelo Nestlé para simular uma integração com o WMS
   //Deve obrigatoriamente ficar neste ponto antes do DEAFAULT para forçar um bloqueio de WMS no pedido
   If ExistBlock("MA440WMS")
      lRetWmsPE := ExecBlock("MA440WMS",.F.,.F.,{lHasWMS})
      lHasWMS   := Iif(ValType(lRetWmsPE)=="L",lRetWmsPE,lHasWMS)
	  cBlqWms   := Iif(lHasWMS,"01","")
   EndIf

DEFAULT cBlqWms    := Iif(lHasWMS,Iif(IsInCallStack("MaDelNFS"),"05","01"),"")
DEFAULT cIdentB6   := ""
DEFAULT lMA440GrLt := ExistBlock("MA440GRLT")
DEFAULT aEmpPronto := {}
DEFAULT cTiposLC   := GetSESTipos({ || ES_SALDUP == "2"},"1")
DEFAULT lGeraDCF   := .T.

If lRskIsAct == Nil
	lRskIsAct := FindFunction( "RskIsActive" )
EndIf

lUseOffBalance := lRskIsAct .And. RskIsActive()

If cPaisLoc == "PAR" .And. SC5->C5_TIPLIB=="2" .And. ValType(aEmpenho) == "A" .And. Len(aEmpenho[1]) == 0
	lAtualiza := .T.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Configura a reserva de estoque quando for e-Commerce                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  lECommerce .AND. !( Empty(SC5->C5_ORCRES) ) .AND. (Posicione("SL1",1,xFilial("SL1")+SC5->C5_ORCRES,"L1_ECFLAG")=="1")
	lResEst := .T.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Baixa as qtdes transferidas para o local do pedido  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( lAtualiza )
	For nX :=1 To Len(aLocal)
		MaTrfLocal(SC6->C6_PRODUTO,aLocal[nX][1],SC6->C6_LOCAL,aLocal[nX][2],SC6->C6_NUM,.F.,@cSeq)
	Next nX
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posiciona Registros                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SF4")
dbSetOrder(1)
MsSeek(xFilial("SF4")+SC6->C6_TES)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica a Sequencia de Liberacao do SC9                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SC9->(dbCommit())
cNameQry := "MAGRAVASC9"

cQuery := "SELECT MAX(C9_SEQUEN) SEQUEN "

Aadd(aInsert, RetSqlName("SC9"))
cQuery +=   "FROM ? SC9 "

Aadd(aInsert, xFilial("SC9"))
cQuery +=   "WHERE C9_FILIAL= ? AND "

Aadd(aInsert, SC6->C6_NUM)
cQuery +=         "C9_PEDIDO= ? AND "

Aadd(aInsert, SC6->C6_ITEM)
cQuery +=         "C9_ITEM= ? AND "

cQuery +=         "SC9.D_E_L_E_T_ = ' '"

nLen := Len(aInsert)
cMD5 := MD5(cQuery) 
If (nPosPrepared := Ascan(__aPrepared,{|x| x[2] == cMD5})) == 0 
	Aadd(__aPrepared,{FWPreparedStatement():New(),cMD5})
	nPosPrepared := Len(__aPrepared)
	__aPrepared[nPosPrepared][1]:SetQuery(ChangeQuery(cQuery))
Endif 
__aPrepared[nPosPrepared][1]:SetUnsafe(1,aInsert[1])
For nX := 2 to nLen
	__aPrepared[nPosPrepared][1]:SetString(nX,aInsert[nX])
Next 
cQuery := __aPrepared[nPosPrepared][1]:getFixQuery()

aInsert := aSize(aInsert,0)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cNameQry,.T.,.T.)
If !Empty(SEQUEN)
	cSeqSC9 := AllTrim(SEQUEN)
EndIf
dbCloseArea()
dbSelectArea("SC9")

cSeqSC9 := Soma1(cSeqSC9,Len(SC9->C9_SEQUEN))

// Tratamento referente ao controle de armazem de terceiros para gravar o lote informado no pedido mesmo com TES que nao atualiza estoque
If FindFunction("EstArmTerc")
	lContercOk := EstArmTerc()	// Verifica se o controle de armazem de terceiros esta habilitado
	If lContercOk .And. SF4->F4_ESTOQUE == "N" .And. SF4->F4_CONTERC == "1"
		lInfLote := .T.
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa as variaveis                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nQtdLib2  := If(nQtdLib2==Nil,SB1->(ConvUm(SC6->C6_PRODUTO,nQtdLib,0,2)),nQtdLib2)
If nQtdLib2 == 0 .And. SC6->C6_UNSVEN <> 0
	If Empty( SC6->C6_QTDVEN-SC6->C6_QTDEMP-SC6->C6_QTDENT-nQtdLib )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se baixou toda a quantidade na primeira UM, baixa totalmente a segunda UM ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nQtdLib2 := SC6->C6_UNSVEN-SC6->C6_QTDEMP2-SC6->C6_QTDENT2
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se nao, baixa proporcionamenre a quantidade baixada na primeira UM     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nQtdLib2 := nQtdLib*SC6->C6_UNSVEN/SC6->C6_QTDVEN
	EndIf
	SC6->C6_QTDLIB2:= nQtdLib2
	nQtdLib2 := SC6->C6_QTDLIB2
EndIf
lReserva  := !Empty(SC6->C6_RESERVA)
lEstoque  := Empty(AllTrim(cBlqEst))
lCredito  := Empty(AllTrim(cBlqCred))

If ( (SF4->F4_ESTOQUE=="S" .Or. lInfLote) .And. nQtdLib > 0 .And. lEstoque .And. (lCredito .Or. lResEst) .And. lAtualiza)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica os novos lotes.                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Rastro(SC6->C6_PRODUTO) .And. !Localiza(SC6->C6_PRODUTO,.T.)
		If Len(aEmpPronto) > 0
			aSaldos := ACLONE(aEmpPronto)
			lEmpenha := .T.
		Else
			aSaldos := {{ "","","","",nQtdLib,nQtdLib2,Ctod(""),"","","",SC6->C6_LOCAL,0}}
		EndIf
		aLocaliz := { aSaldos }
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ponto de Entrada p/ movimentar estoque antes da selecao Lote X Localiz.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lMA440GrLt
			ExecBlock("MA440GRLT",.F.,.F.,{SC6->C6_PRODUTO,SC6->C6_LOCAL,nQtdLib,SC6->C6_LOTECTL,SC6->C6_NUMLOTE,SC6->C6_LOCALIZ,SC6->C6_NUMSERI})
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se devem ser escolhidos Lotes/Sub-Lotes/Localizacao ou nao    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len(aEmpPronto) > 0
			aSaldos := ACLONE(aEmpPronto)
			lEmpenha := .T.
		Else
			lUsaVenc:= If(!Empty(SC6->C6_LOTECTL+SC6->C6_NUMLOTE),.T.,(SuperGetMv('MV_LOTVENC')=='S'))
			If ( !lHasWMS .Or. !Empty(SC6->C6_LOCALIZ+SC6->C6_NUMSERI) ) .And.;
				(!lReserva .Or. (lReserva .And. Rastro(SC6->C6_PRODUTO) .And.;
				(xFilial("SC0")+SC6->C6_RESERVA+SC6->C6_PRODUTO+SC6->C6_LOCAL==SC0->C0_FILIAL+SC0->C0_NUM+SC0->C0_PRODUTO+SC0->C0_LOCAL) .And.;
				Empty(SC0->C0_LOTECTL+SC0->C0_NUMLOTE))) .And.;
				!(IsInCallStack('MATA521A') .And. IntWms(SC6->C6_PRODUTO))
				If lIntACD .And. lACDSer .And. IsInCallStack("MaDelNFS")
					aSaldos:= ACDCB9Ser(SC6->C6_PRODUTO,SC6->C6_LOCAL,nQtdLib,nQtdLib2,SC6->C6_LOTECTL,SC6->C6_NUMLOTE,SC6->C6_LOCALIZ,SC6->C6_NUMSERI,lUsaVenc,dDataBase,SC9->C9_ORDSEP,SC9->C9_PEDIDO)
				Else
					aSaldos := SldPorLote(SC6->C6_PRODUTO,SC6->C6_LOCAL,nQtdLib,nQtdLib2,SC6->C6_LOTECTL,SC6->C6_NUMLOTE,SC6->C6_LOCALIZ,SC6->C6_NUMSERI,NIL,NIL,NIL,lUsaVenc,nil,nil,dDataBase)
				EndIf
				lEmpenha := .T.
			Else
				SC0->( dbSetOrder(1) )
				If !Empty(SC6->C6_RESERVA) .And.;
					(xFilial("SC0")+SC6->C6_RESERVA+SC6->C6_PRODUTO+SC6->C6_LOCAL==SC0->C0_FILIAL+SC0->C0_NUM+SC0->C0_PRODUTO+SC0->C0_LOCAL .Or. ;
					SC0->( dbSeek( xFilial("SC0")+SC6->C6_RESERVA+SC6->C6_PRODUTO+SC6->C6_LOCAL ) ) )

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Pesquisa a data de validade dos lotes                                  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If Rastro(SC6->C6_PRODUTO,"L")
						SB8->( dbSetOrder( 3 ) )
						SB8->( MsSeek( xFilial( "SB8" ) + SC0->C0_PRODUTO + SC0->C0_LOCAL + SC0->C0_LOTECTL ) )
						dValidLote := SB8->B8_DTVALID
					ElseIf Rastro(SC6->C6_PRODUTO,"S")
						SB8->( dbSetOrder( 3 ) )
						SB8->( MsSeek( xFilial( "SB8" ) + SC0->C0_PRODUTO + SC0->C0_LOCAL + SC0->C0_LOTECTL + SC0->C0_NUMLOTE ) )
						dValidLote := SB8->B8_DTVALID
					Else
						dValidLote := Ctod( "" )
					EndIf

					aSaldos := {{ SC0->C0_LOTECTL,SC0->C0_NUMLOTE,SC0->C0_LOCALIZ,SC0->C0_NUMSERI,nQtdLib,nQtdLib2,dValidLote,"","","",SC0->C0_LOCAL,0}}
				Else
					If lHasWMS .And. !lReserva
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Pesquisa a data de validade dos lotes                                  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If Rastro(SC6->C6_PRODUTO,"L")
							SB8->( dbSetOrder( 3 ) )
							SB8->( MsSeek( xFilial( "SB8" ) + SC6->C6_PRODUTO + SC6->C6_LOCAL + SC6->C6_LOTECTL ) )
							dValidLote := SB8->B8_DTVALID
						ElseIf Rastro(SC6->C6_PRODUTO,"S")
							SB8->( dbSetOrder( 3 ) )
							SB8->( MsSeek( xFilial( "SB8" ) + SC6->C6_PRODUTO + SC6->C6_LOCAL + SC6->C6_LOTECTL + SC6->C6_NUMLOTE ) )
							dValidLote := SB8->B8_DTVALID
						Else
							dValidLote := Ctod( "" )
						EndIf
					EndIf

					cReserva := ""
					lReserva := .F.
					aSaldos := {{ SC6->C6_LOTECTL,SC6->C6_NUMLOTE,SC6->C6_LOCALIZ,SC6->C6_NUMSERI,nQtdLib,nQtdLib2,dValidLote,"","","",SC6->C6_LOCAL,0}}
				EndIf
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Aglutina os lotes/sub-lotes iguais                                      ³
		//³Quando ha criacao de reservas na liberacao nao se deve aglutinar as     ³
		//³localizacoes fisicas.                                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ( lCredito .Or. lResEst)
			aAuxiliar := aClone(aSaldos)
			aSaldos   := {}
			For nX := 1 To Len(aAuxiliar)
				
				// Verificar se o usuario preencheu o endereco ou numero de serie
				lNSer0End := IIf(!Empty(SC6->C6_LOCALIZ) .Or.; //Endereço
				                 !Empty(SC6->C6_NUMSERI), ;    //Número de Série)
								 .T., .F.)

				// Caso nao tenha preenchido no pedido de venda o Endereco ou numero de serie para 
				// o produto em questao, vamos verificar se temos algum item nas linhas dos itens 
				// do pedido com o mesmo codigo, lote, sub-lote e armazem
				nAuxiliar := IIf(lNSer0End, 0, aScan(aSaldos,{|x|x[1]==aAuxiliar[nX,1] .And.; // Lote
					                                             x[2]==aAuxiliar[nX,2] .And.; // Sublote
					                                             x[11]==aAuxiliar[nX,11] }))  // Armazem
				
				If ( nAuxiliar == 0 )
					// Foi preenchido Endereco ou Numero de Serie, ou nao foi encontrado
					// um produto com o mesmo preenchimento de lote, sublote e armazem.
					// Entao vamos incluir um novo item no aSaldos para o processamento do SC9.
					AAdd(aSaldos,Array(Len(aAuxiliar[nX])))
					For nY := 1 To Len(aAuxiliar[nX])
						aSaldos[Len(aSaldos)][nY] := aAuxiliar[nX,nY]
					Next nY
					// Limpar os dados de Endereco e numero de serie para realizar a aglutinacao,
					// caso o usuario nao tenha informado Endereco ou Numero de Serie
					If !lNSer0End
						aSaldos[Len(aSaldos)][3] := Space(TamSX3("C6_LOCALIZ")[1])
						aSaldos[Len(aSaldos)][4] := Space(TamSX3("C6_NUMSERI")[1])
					EndIf
					AAdd(aLocaliz,{ aAuxiliar[nX] })
				Else
					// Nao foi preenchido Endereco e Numero de Serie e foi encontrado
					// um produto com o mesmo preenchimento de lote, sublote e armazem no pedido.
					// Entao vamos aglutinar este item que esta sendo processado ao(s) item(ns) 
					// ja existente(s)/aglutinados no aSaldos com mesmo preenchimento de 
					// codigo de produto, lote e sub-lote.
					aSaldos[nAuxiliar][5] += aAuxiliar[nX,5]
					aSaldos[nAuxiliar][6] += aAuxiliar[nX,6]
					AAdd(aLocaliz[nAuxiliar],aAuxiliar[nX])
				EndIf

			Next nX
		Else
			aLocaliz:= { aSaldos }
		EndIf
	EndIf
Else
	If Len(aEmpPronto) > 0
		aSaldos := ACLONE(aEmpPronto)
		lEmpenha := .T.
	Else
		aSaldos := {{ "","","","",nQtdLib,nQtdLib2,Ctod(""),"","","",SC6->C6_LOCAL,0}}
	EndIf
	aLocaliz:= { aSaldos }
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o Bloqueio de Enderecamento do WMS deve ser efetuado       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 To Len(aSaldos)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Efetua a Gravacao do SC9                                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lAtualiza
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Garante o estoque caso haja bloqueio de credito atraves de uma reserva  ³
		//³de material.                                                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lCredito .And. lResEst .And. SF4->F4_ESTOQUE=="S" .And. !lReserva .And. lEstoque
			cReserva := CriaVar("C0_NUM")
			nQtdRese := aSaldos[nX,5]
			If Empty(cReserva)
				cReserva := NextNumero("SC0",1,"C0_NUM",.T.)
			Else
				While ( GetSX8Len() > nSaveSX8 )
					ConfirmSx8()
				EndDo
			EndIf
			If !a430Reserva({1,"PD",SC5->C5_NUM,"",cFilAnt},@cReserva,;
					SC6->C6_PRODUTO,aSaldos[nX,11],nQtdRese,;
					{aSaldos[nX,2],aSaldos[nX,1],aSaldos[nX,3],aSaldos[nX,4]})
				cReserva := ""
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualiza a qtde em aberto do pedido de venda                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("SB2")
				dbSetOrder(1)
				If ( !MsSeek(xFilial("SB2")+SC6->C6_PRODUTO+aSaldos[nX,11]) )
					CriaSB2( SC6->C6_PRODUTO,aSaldos[nX,11] )
				EndIf
				RecLock("SB2")
				SB2->B2_QPEDVEN -= nQtdRese
				SB2->B2_QPEDVE2 -= ConvUM(SB2->B2_COD, nQtdRese, 0, 2)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualiza o saldo da reserva                                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("SC0")
				dbSetOrder(1)
				If (xFilial("SC0")+cReserva+SC6->C6_PRODUTO+aSaldos[nX,11]==SC0->C0_FILIAL+SC0->C0_NUM+SC0->C0_PRODUTO+SC0->C0_LOCAL .Or. ;
						MsSeek(xFilial("SC0")+cReserva+SC6->C6_PRODUTO+aSaldos[nX,11]) )
					RecLock("SC0")
					SC0->C0_QUANT -= nQtdRese
					SC0->C0_TIPO  := "PD"
					SC0->C0_QTDPED += nQtdRese
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualiza o item do pedidod de venda                          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				RecLock("SC6")
				SC6->C6_QTDRESE += nQtdRese
				SC6->C6_RESERVA := cReserva
			EndIf
		Else
			cReserva := SC6->C6_RESERVA
			nQtdRese := SC6->C6_QTDRESE
		EndIf
		nValor := A410Arred(nQtdLib*SC6->C6_PRCVEN,"C6_PRCVEN")

		If nX == Len(aSaldos) .And. Len(aSaldos) > 1 .And. Empty(SC6->C6_LOTECTL) .And. Rastro(SC6->C6_PRODUTO)
			nPrcVen := noRound(nValor - nTotSC9,nDecimal) / aSaldos[nX,5]
			nPrcVen := A410Arred(nPrcVen,"C6_PRCVEN")
			If ( SuperGetMv("MV_ARREFAT") == "N" )
				nTotSC9Aux := nTotSC9
				nTotSC9 += a410Arred(aSaldos[nX,5] * nPrcVen ,"C9_PRCVEN")
				If nValor - nTotSC9 <> 0
					nPrcVen += a410Arred((nValor-nTotSC9)/aSaldos[nX,5] ,"C6_PRCVEN")
				EndIf
				nTotSC9 := nTotSC9Aux
			EndIf
		EndIf
		RecLock("SC9",.T.)
		SC9->C9_FILIAL := xFilial("SC9")
		SC9->C9_PEDIDO := SC6->C6_NUM
		SC9->C9_ITEM    := SC6->C6_ITEM
		SC9->C9_SEQUEN  := cSeqSC9
		SC9->C9_PRODUTO := SC6->C6_PRODUTO
		SC9->C9_CLIENTE := SC6->C6_CLI
		SC9->C9_LOJA    := SC6->C6_LOJA
		SC9->C9_PRCVEN  := IIF(nPrcVen==0,SC6->C6_PRCVEN,nPrcVen)
		SC9->C9_DATALIB := dDataBase
		SC9->C9_LOTECTL := aSaldos[nX,1]
		SC9->C9_NUMLOTE := aSaldos[nX,2]
		SC9->C9_QTDLIB  := aSaldos[nX,5]
		SC9->C9_QTDLIB2 := aSaldos[nX,6]
		SC9->C9_DTVALID := aSaldos[nX,7]
		SC9->C9_POTENCI := aSaldos[nX,12]
		SC9->C9_BLCRED  := cBlqCred
		SC9->C9_BLEST   := cBlqEst
		SC9->C9_BLWMS   := Iif(SF4->F4_ESTOQUE == "S",cBlqWMS,"")
		SC9->C9_QTDRESE := Min(nQtdRese,SC9->C9_QTDLIB)
		SC9->C9_RESERVA := cReserva
		SC9->C9_AGREG  := &(SuperGetMv("MV_AGREG"))
		SC9->C9_GRUPO  := &(SuperGetMv("MV_GRUPFAT"))
		SC9->C9_IDENTB6:= cIdentB6
		SC9->C9_LOCAL  := aSaldos[nX,11]
		SC9->C9_SERVIC := SC6->C6_SERVIC
		SC9->C9_PROJPMS:= SC6->C6_PROJPMS
		SC9->C9_TASKPMS:= SC6->C6_TASKPMS
		SC9->C9_TRT  	 := SC6->C6_TRT
		SC9->C9_LICITA := SC6->C6_LICITA
		SC9->C9_TPCARGA:= SC5->C5_TPCARGA
		SC9->C9_ENDPAD := SC6->C6_ENDPAD
		SC9->C9_EDTPMS := SC6->C6_EDTPMS
		SC9->C9_DATENT := SC6->C6_ENTREG
		//Grava tipo da Ordem de Produção na liberação
		If ( SC6->C6_TPOP == ' ' ) .Or. ( SC6->C6_TPOP == 'F' )
			SC9->C9_TPOP := '1'
		Else
			SC9->C9_TPOP := '2'
		EndIf
		If !Empty(cSeq)
			SC9->C9_SD3SEQ := cSeq
		Endif

	   nTotSC9 += a410Arred(SC9->C9_QTDLIB * SC9->C9_PRCVEN ,"C9_PRCVEN")
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Regra do WMS, onde: 1=Apanhe por Lote/2=Apanhe por Numero de Serie/3=Apanhe por Data ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SC9->C9_REGWMS := SC6->C6_REGWMS
		If cPaisLoc == "COL" //Tratamento de Terceros em Vendas
			SC9->C9_NIT := SC6->C6_NIT
		Endif
		If cPaisLoc == "BRA"
			SC9->C9_CODISS := SC6->C6_CODISS
		EndIf	

		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1")+SC6->C6_PRODUTO))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³O campo C9_RETOPER é considerado na quebra de Nota Fiscal.(BRASIL)      |
		//³Alguns Clientes que migraram da versao 8 para 10 estao tendo problemas  |
		//³com esta quebra pois na versao 8 esse campo nao possuia um inicializador|
		//³padrao e muitos produtos estao com esse campo em branco.                |
		//³Os campos em branco "" devem ser considerados como "2"=Nao. Assim qdo   |
		//|houver dois produtos ou mais onde alguns estao com os campos em branco e|
		//|e outros com "2" todos devem sair na mesma Nota Fiscal                  |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cPaisLoc == "BRA"
			If !Empty(SB1->B1_RETOPER)
				SC9->C9_RETOPER := SB1->B1_RETOPER
			Else
				SC9->C9_RETOPER := "2"
			Endif
		EndIf	

		//Verifica se o novo DCL está configurado
		If SuperGetMv("MV_DCLNEW",.F.,.F.)
			DCLMTA440C()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ponto de entrada para todos os itens do pedido.     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ElseIf ( ExistTemplate("MTA440C9") )
			ExecTemplate("MTA440C9",.F.,.F.)
		EndIf

		//-- Executa bloco de comandos para montagem de cargas (Oms521Car)
		If ( bBlock <> Nil )
			nRecSC9 := SC9->(Recno())
			Eval(bBlock)
			SC9->(dbGoto(nRecSC9))
			If SoftLock("SC9")
				RecLock("SC9",.F.)
			EndIf
		EndIf

		If ExistBlock("M440SC9I")
			ExecBlock("M440SC9I",.F.,.F.)
		EndIf
		MaAvalSC9("SC9",1,aLocaliz[nX],Nil,Nil,Nil,Nil,Nil,@nVlrCred,,,,lGeraDCF)
		
		/* Integração RISK - TOTVS Mais Negócios
		Preenche a liberação do pedido conforme as regras do risk. */
		lLibPed := IIf(lUseOffBalance, SuperGetMV("MV_RSKNTKT",,.F.), .F.)
		If lUseOffBalance .And. RskEvlCredit( 2, SC5->C5_CONDPAG ) .and. lLibPed
			RskFillSC9() 
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza o orcamento do Televendas, se foi originado a partir³
		//³dele no modulo Call Center (SIGATMK)                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		TkAtuTlv(SC9->C9_PEDIDO,2)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ponto de entrada para todos os itens do pedido.     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ( ExistBlock("MTA440C9") )
			ExecBlock("MTA440C9",.F.,.F.)
		EndIf
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Acumula os dados na variavel aEmpenho                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ( SF4->F4_ESTOQUE == "S" .And. aSaldos[nX,5] > 0 )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza qtde a ser reservada no pedido informado            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SB2")
			dbSetOrder(1)
			MsSeek(xFilial("SB2")+SC6->C6_PRODUTO+aSaldos[nX,11])
			RecLock("SB2")
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se ha bloqueio de estoque                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ( lCredito .And. lEstoque )
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Atualiza os empenhos quando ha localizacao                              ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nRegEmp := aScan(aEmpenho[2],{|x| x[1]==SB2->(RecNo()) .And.;
					x[3] == SC6->C6_LOCALIZ+SC6->C6_NUMSERI+SC6->C6_NUMLOTE+SC6->C6_LOTECTL })
				If ( nRegEmp == 0 )
					AAdd(aEmpenho[2],{ SB2->(RecNo()),aSaldos[nX,5],SC6->C6_LOCALIZ+SC6->C6_NUMSERI+SC6->C6_NUMLOTE+SC6->C6_LOTECTL,aSaldos[nX,6]})
				Else
					aEmpenho[2][nRegEmp][2] += aSaldos[nX,5]
					aEmpenho[2][nRegEmp][4] += aSaldos[nX,6]
				EndIf
			EndIf
		EndIf
		If ( SF4->F4_DUPLIC=="S" .And. !SC5->C5_TIPO$"DB" )
			dbSelectArea("SA1")
			dbSetOrder(1)
			MsSeek(xFilial("SA1")+SC6->C6_CLI+SC6->C6_LOJA)
			lTrvSA1 := IIf(cPaisLoc == "BRA" .And. lFATTRVSA1, ExecBlock("FATTRVSA1", .F., .F., {xFilial("SA1"), SA1->A1_COD, SA1->A1_LOJA}), .T.)
			If lTrvSA1
				RecLock("SA1")
			EndIf
			nMCusto :=  If(SA1->A1_MOEDALC > 0,SA1->A1_MOEDALC,Val(SuperGetMv("MV_MCUSTO")))
			If ( Empty(cBlqCred) )
				nRegEmp := aScan(aEmpenho[1],{|x| x[1]==SA1->(RecNo())})
				If ( nRegEmp == 0 )
					AAdd(aEmpenho[1],{ SA1->(RecNo()),0,0})
					nRegEmp := Len(aEmpenho[1])
				EndIf
				aEmpenho[1][nRegEmp][2] += xMoeda( aSaldos[nX,5] * SC6->C6_PRCVEN , SC5->C5_MOEDA , nMCusto , dDataBase )
				aEmpenho[1][nRegEmp][3] += xMoeda( aSaldos[nX,5] * SC6->C6_PRCVEN , SC5->C5_MOEDA , nMCusto , dDataBase )
			EndIf
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Incrementa o SC9                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSeqSC9 := Soma1(cSeqSC9,Len(SC9->C9_SEQUEN))

Next nX
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaura a entrada da rotina                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea(aAreaSA1)
RestArea(aAreaSB2)
RestArea(aAreaSF4)
RestArea(aAreaSB1)
RestArea(aArea)
Return(.T.)




USER Function a440GeraC9(nQtdLib,lCredito,lEstoque,lAvCred,lAvEst,lLiber,lTransf,aEmpenho,;
							bBlock,aEmpPronto,lTrocaLot,lGeraDCF,nVlrCred,nQtdLib2)

Local aArea     := GetArea(Alias())
Local aAreaSA1  := SA1->(GetArea())
Local aAreaSB2  := SB2->(GetArea())
Local aAreaSF4  := SF4->(GetArea())
Local aSaldos   := {}
Local aLocal    := {}

Local nSldSB6   := 0
Local cBlCred   := ""
Local cBlEst    := ""
Local cAliasSB6 := "SB6"
Local lQuery    := .F.

Local cGeraBlq	     := SuperGetMv("MV_GERABLQ")
Local lGrvBlq2	     := SuperGetMv("MV_GRVBLQ2")

Local lBlqCrd        := GetMv("MV_BLQCRED")
Local lTravas        := .T.

Local nQtdJaLib      := 0
Local nQtdPoder3     := 0
Local nQtdNPT        := 0
Local nQtdNosso      := 0
Local nValAv	     := 0
Local aEmpBN	     := {}
Local nX             := 0
Local nMvTipCrd 	 := SuperGetMV("MV_TIPACRD", .F., 1)
Local cMvLibNodp	 := GetMv("MV_LIBNODP")
Local nVlrTitAbe	 := 0
Local nVlrTitAtr	 := 0
Local cQuery         := ""
Local lUseOffBalance := .F.
Local lRiskCred		 := .F.
Local lRskTermB		 := .T.
Local lLibPed  		 := .F.
Local lTrvSA1        := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ajusta a Entrada da Rotina                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFAULT lAvCred    := .T.
DEFAULT lAvEst     := .T.
DEFAULT lLiber     := .F.
DEFAULT lTransf    := .F.
DEFAULT lGeraDCF   := .T.

If lMTValAvC == Nil 
	lMTValAvC := ExistBlock("MTVALAVC")
EndIf

If lRskIsAct == Nil
	lRskIsAct := FindFunction( "RskIsActive" )
EndIf

lUseOffBalance := lRskIsAct .And. RskIsActive()

If ( At(SC5->C5_TIPO,"CIP") > 0 )
	lLiber := .F.
EndIf
dbSelectArea("SF4")
dbSetOrder(1)
MsSeek(xFilial("SF4")+SC6->C6_TES)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posiciona Registros                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( At(SC5->C5_TIPO,"DB") == 0 .And. (SF4->F4_DUPLIC=='S' .Or. cMvLibNodp == "S"))
	dbSelectArea("SA1")
	dbSetOrder(1)
	MsSeek(xFilial("SA1")+SC6->C6_CLI+SC6->C6_LOJA)
	lTrvSA1 := IIf(cPaisLoc == "BRA" .And. lFATTRVSA1, ExecBlock("FATTRVSA1", .F., .F., {xFilial("SA1"), SA1->A1_COD, SA1->A1_LOJA}), .T.)
	If lTrvSA1
		lTravas := RecLock("SA1")
	EndIf
EndIf

dbSelectArea("SB2")
dbSetOrder(1)
If ( MsSeek(xFilial("SB2")+SC6->C6_PRODUTO+SC6->C6_LOCAL) .And. lTravas )
	lTravas := RecLock("SB2")
EndIf

/* Integração RISK - TOTVS Mais Negócios
Avalia as condições do uso no TOTVS Mais Negócios */
lLibPed := IIf(lUseOffBalance, SuperGetMV("MV_RSKNTKT",,.F.), .F.)
If lUseOffBalance .and. lLibPed
	lRiskCred := RskEvlCredit( 2, SC5->C5_CONDPAG )
	lRskTermB := RskTermB(SA1->A1_COD+SA1->A1_LOJA,SC5->C5_CONDPAG)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o SB2 e o SA1 estao Travados                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( lTravas )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Complementos nao devem ter o Credito ou Estoque Avaliado.               ³
	//³Devolucao de Poder de Terceiro nao deve ter o Credito avaliado.         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( (AT(SC5->C5_TIPO,"CIP") > 0 .AND. ( IIf(cPaisLoc == "BRA" , SC5->C5_TPCOMPL != "2" ,.T.))) .Or. ( SF4->F4_PODER3 == "D" .And. SF4->F4_ESTOQUE=="N") .Or. MaTesSel(SF4->F4_CODIGO) )
		lEstoque := .T.
		lCredito := .T.
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Avaliacao de Estoque                                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ( lAvEst )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Somente avalia-se estoque quando ha movimentacao e nao ha reserva       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ( SF4->F4_ESTOQUE == "S" .And. (Empty(SC6->C6_RESERVA) .OR. (Iif(ExistFunc("LjxValEst"), LjxValEst(SC5->C5_ORCRES), .F. ) .AND. !AtIsRotina("MATA455"))))
				If SuperGetMV("MV_AVALEST")==3 .And. !AtIsRotina("MATA455")
					If !((Rastro(SC6->C6_PRODUTO) .Or. Localiza(SC6->C6_PRODUTO,.T.)) .And. cGeraBlq =="N")
						lEstoque := .F.
						aEmpBN	:= If(FindFunction("A410CarBen"),A410CarBen(SC6->C6_NUM,SC6->C6_ITEM),{})
						For nX := 1 To Len( aEmpBN )
							A410LibBen(1,aEmpBN[nX,1],aEmpBN[nX,2],SC6->C6_QTDVEN,SC6->C6_UNSVEN)
						Next
					Else
						lEstoque := A440VerSB2(@nQtdLib,lLiber,lTransf,@aLocal,@aEmpenho)
					EndIf
				Else
					lEstoque := A440VerSB2(@nQtdLib,lLiber,lTransf,@aLocal,@aEmpenho)
				EndIf
			Else
				If ( !Empty(SC6->C6_RESERVA) )
					lEstoque := .T.

					If cPaisLoc<>"BRA" .AND. SC6->C6_QTDRESE == 0
						nQtdLib := Min(SC6->C6_QTDVEN,nQtdLib)
					Else
						nQtdLib := Min(SC6->C6_QTDRESE,nQtdLib)
					EndIf
				Else
					lEstoque := .T.
				EndIf
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Avaliacao de Credito                                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ( lAvCred )
			If ( !SC5->C5_TIPO $ "DB" )
				If ( SF4->F4_DUPLIC == "S" .Or. cMvLibNodp == "S" )
					If ( lBlqCrd .And. !lEstoque )
						lCredito := .F.
						cBlCred  := "02"
					Else
						If lMTValAvC
							nValAv	:=	ExecBLock("MTValAvC",.F.,.F.,{'A440GERAC9',SC6->C6_PRCVEN*nQtdLib,Nil})
						Else
							nValAv	:=	SC6->C6_PRCVEN*nQtdLib
						Endif
						//A variavel nValItPed (Private) he criada nas funcoes:(A440Grava, A410Grava e a440Proces)
						If nMvTipCrd == 2 .AND. FindFunction("FatCredTools") .AND. Type("nValItPed") <> "U"

							If nValItPed == 0
								//Consulta os titulos em aberto
								nVlrTitAbe := SldCliente(SC9->C9_CLIENTE + SC9->C9_LOJA, Nil, Nil, .F.)
								//Consulta os titulos em atraso
								nVlrTitAtr := CrdXTitAtr(SC9->C9_CLIENTE + SC9->C9_LOJA, Nil, Nil, .F.)
							EndIf

							nValItPed += nValAv

							LJMsgRun(STR0010,,{|| lCredito := FatCredTools(SA1->A1_COD,SA1->A1_LOJA, nValItPed, nVlrTitAbe, nVlrTitAtr)})//"Aguarde... Efetuando Analise de Crédito."
							//lCredito := FatCredTools(SA1->A1_COD,SA1->A1_LOJA, nValItPed, nVlrTitAbe, nVlrTitAtr)
						Else
							/* Integração RISK - TOTVS Mais Negócios
							Se o tipo for full ou off-balance com condicao mais negocio ativada não avalia o crédito. */
							If !lRiskCred .and. lRskTermB
								lCredito := MaAvalCred(SA1->A1_COD,SA1->A1_LOJA,nValAV,SC5->C5_MOEDA,.T.,@cBlCred,@aEmpenho,@nVlrCred)
							EndIf
						EndIf
					EndIf
				Else
					lCredito := .T.
				EndIf
			Else
				lCredito := .T.
			EndIf
		EndIf
	EndIf
EndIf

/* Integração RISK - TOTVS Mais Negócios				
Se o tipo for full ou off-balance com condicao mais negocio 
ativada gera ticket.*/
If lUseOffBalance .And. aEmpenho == Nil .And. !FwIsInCallStack( "RskUpdLibPed" ) .And. !FwIsInCallStack( "MaDelNfs" ) .and. !lCredito
	If lRiskCred
		cBlCred		:= "80"
		lCredito 	:= .F.
	elseif !lRskTermB
		cBlCred		:= "91"  
		lCredito 	:= .F.
	EndIf 
EndIf 

//Para Orcamento com origem do SigaLoja verifica regra de bloqueio de crédito especifica
If (! Empty(SC5->C5_ORCRES) .Or. ! Empty(SC5->C5_PEDECOM)) 
	If ExistFunc("LjxjPedBlq")
		LjxjPedBlq( SC5->C5_ORCRES , @cBlCred , @lCredito)
	ElseIf SuperGetMV("MV_LJECOMM",,.F.) .And. SuperGetMV("MV_LJECOMO",,.F.) .And. Val(SC5->C5_PEDECOM) > 0
		cBlCred  := "02"
		lCredito := .F.
	EndIf	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Neste momento eh gerado os empenhos e o SC9 dependendo do caso          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( lTravas .And. (SC5->C5_TIPO$"CIP" .Or. nQtdLib > 0 .Or. MaTesSel(SF4->F4_CODIGO)) )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Busca dados ref. ao Beneficiamento no SB6 para gerar Registros no SC9 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( SF4->F4_PODER3=='D' .And. !(SC5->C5_TIPO$"CIPD") )
		nQtdPoder3 := nQtdLib
	Else
		If lCredito .And. lEstoque
			aSaldos := MaNeedP3(nQtdLib)
			nQtdNosso := aSaldos[1]
			nQtdPoder3:= aSaldos[2]
			nQtdNPT   := aSaldos[3]
		Else
			nQtdNosso := nQtdLib
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica os codigos de bloqueio                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( Empty(cBlCred) )
		If ( !lCredito )
			If At(SC5->C5_TIPO,"DB") == 0 .And. SF4->F4_DUPLIC == 'S' .And. SC5->C5_TIPLIB == "2" .And.;
				( !Empty(SA1->A1_VENCLC) .And. SA1->A1_VENCLC < dDataBase ) .And. nVlrCred <= 0
				cBlCred := "04"		//Vencimento do Limite de Credito
			Else
				cBlCred := "01"
			EndIf
		EndIf
	EndIf
	If ( Empty(cBlEst) )
		If ( !lEstoque )
			cBlEst := "02"
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tratamento da quantidade a ser liberada do poder de terceiros           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nQtdPoder3 > 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Posiciona Registros                                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SB6")
		If Empty(SC6->C6_IDENTB6)
			dbSetOrder(1)
		Else
			dbSetOrder(3)
		EndIf
		cAliasSB6 := "A440GERAC9"
		lQuery    := .T.
		aStruSB6  := SB6->(dbStruct())
		SB6->(dbCommit())

		cQuery := "SELECT B6_FILIAL,B6_CLIFOR,B6_LOJA,B6_IDENT,B6_PRODUTO,"
		cQuery += "B6_QULIB,B6_SALDO "
		cQuery += "FROM "+RetSqlName("SB6")+" SB6 "
		cQuery += "WHERE SB6.B6_FILIAL='"+xFilial("SB6")+"' AND "
		cQuery += "SB6.B6_PRODUTO='"+SC6->C6_PRODUTO+"' AND "
		If !Empty(SC6->C6_IDENTB6)
			cQuery += "SB6.B6_IDENT='"+SC6->C6_IDENTB6+"' AND "
		EndIf
		cQuery += "(SB6.B6_SALDO-SB6.B6_QULIB)>0 AND "
		cQuery += "SB6.D_E_L_E_T_=' ' "
		cQuery += "ORDER BY "+SqlOrder(SB6->(IndexKey()))

		cQuery := ChangeQuery(cQuery)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSB6,.T.,.T.)
		For nX := 1 To Len(aStruSB6)
			If aStruSB6[nX][2] <> "C" 
				TcSetField(cAliasSB6,aStruSB6[nX][1],aStruSB6[nX][2],aStruSB6[nX][3],aStruSB6[nX][4])
			EndIf
		Next nX
		
		While (!Eof() .And.  xFilial("SB6") == (cAliasSB6)->B6_FILIAL .And.;
				IIf(Empty(SC6->C6_IDENTB6),.T.,;
				SC6->C6_IDENTB6==(cAliasSB6)->B6_IDENT) .And.;
				SC6->C6_PRODUTO==(cAliasSB6)->B6_PRODUTO .And.;
				nQtdPoder3 > 0 )
			nSldSB6 := ( (cAliasSB6)->B6_SALDO - (cAliasSB6)->B6_QULIB )
			If ( nSldSB6 > 0 )
				nSldSb6 := Min(nSldSB6,nQtdPoder3)
				If !( ( Rastro(SC6->C6_PRODUTO).Or.Localiza(SC6->C6_PRODUTO,.T.) ) .And.;
						cGeraBlq =="N" .And. !lEstoque )
					U_MaGravaSc9(nSldSb6,cBlCred,cBlEst,@aLocal,@aEmpenho,(cAliasSB6)->B6_IDENT,bBlock,aEmpPronto,nQtdLib2,@nVlrCred)
					nQtdJaLib += nSldSb6
				EndIf
				nQtdPoder3 -= nSldSB6
			EndIf
			dbSelectArea(cAliasSB6)
			dbSkip()
		EndDo
		If lQuery
			dbSelectArea(cAliasSB6)
			dbCloseArea()
			dbSelectArea("SB6")
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tratamento da quantidade a ser liberada - Nossa em Terceiros            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nQtdNPT > 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verificacao do Parametro MV_GERABLQ                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !( (Rastro(SC6->C6_PRODUTO) .Or. Localiza(SC6->C6_PRODUTO,.T.)) .And.;
				cGeraBlq =="N" .And. !lEstoque )
			U_MaGravaSc9(nQtdNPT,cBlCred,cBlEst,@aLocal,@aEmpenho,,bBlock,aEmpPronto,,@nVlrCred)
			nQtdJaLib += nQtdNPT
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tratamento da quantidade a ser liberada - Nosso Poder                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If nQtdNosso > 0 .Or. MaTesSel(SF4->F4_CODIGO)	.Or. Ma440Compl()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verificacao do Parametro MV_GERABLQ                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !( (Rastro(SC6->C6_PRODUTO) .Or. Localiza(SC6->C6_PRODUTO,.T.)) .And.;
				cGeraBlq =="N" .And. !lEstoque )
			U_MaGravaSc9(nQtdNosso,cBlCred,cBlEst,@aLocal,@aEmpenho,,bBlock,aEmpPronto,nQtdLib2,@nVlrCred,,lGeraDCF)
			nQtdJaLib += nQtdNosso
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verificacao do Parametro MV_GRVBLQ2                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ( lGrvBlq2 .And. aEmpenho == Nil ) .And. cGeraBlq =="S"
			If ( nQtdLib <> SC6->C6_QTDLIB ) .OR. ( SC6->C6_QTDLIB <> 0 ) 
				nQtdLib := SC6->C6_QTDLIB
				If ( nQtdLib <> 0 )
					If !lCredito
						lAvEst := .F.
						lEstoque := .F.
					Else
						lAvEst := .T.
					EndIf
					nQtdJaLib += a440GeraC9(nQtdLib,lCredito,lEstoque,lAvCred,lAvEst,lLiber,lTransf,@aEmpenho,bBlock,aEmpPronto,lTrocaLot,lGeraDCF,@nVlrCred)
				EndIf
			EndIf
		EndIf
	EndIf
EndIf
If ( lTravas )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza a quantidade liberada para zero                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( aEmpenho == Nil )
		SC6->C6_QTDLIB  := 0
		SC6->C6_QTDLIB2 := 0
	EndIf
EndIf
If ( !lTravas )
	lCredito := .F.
	lEstoque := .F.
	nQtdLib  := 0
EndIf
RestArea(aAreaSA1)
RestArea(aAreaSB2)
RestArea(aAreaSF4)
RestArea(aArea)
Return(nQtdJaLib)
