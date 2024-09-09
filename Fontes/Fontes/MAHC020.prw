#Include "Totvs.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � MAHC020  � Autor �Giovanni Melo          � Data �08/06/2016��� 
�������������������������������������������������������������������������Ĵ��
���Descricao �Visualizacao Multi Filiais de saldo disponivel do produto   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �u_MahC20()                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �Especifico MA Hospitalar                                    ���
�������������������������������������������������������������������������Ĵ��
���                          ULTIMAS ALTERACOES                           ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � Motivo da Alteracao                             ���
�������������������������������������������������������������������������Ĵ��
���            �        �                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function MAHC020(_cChave)
	
	// Label
	Local oLbCod		
	Local oLbDescr
	Local oLbObsNfs
	Local oLbObsExp
	Local oLbMnNota
	Local oLbPrev
	Local oLbTotal
	Local oLbStatPv

	// Fields
	Local oTxCod
	Local oTxDescr
	Local oTxObsNfs
	Local oTxObsExp
	Local oTxMnNota
	Local oTxPrev
	Local oTxTotal
	Local oTxStatPv
	
	Local oDialog
	Local oGrid	
	Local oBtFechar
	
	Local cCod		:= ""
	Local cDescr	:= ""
	Local cObsNfs	:= ""
	Local cObsExp	:= ""
	Local cMnNota	:= ""
	Local cPrev		:= ""
	Local cStatPv	:= ""
	Local cTotal	:= ""
	Local cTxt		:= ""
		
	Local nWidth	:= 685
	Local nHeight	:= 535
	Local nLine		:= 10
	Local nX		:= 0
	Local nLinCnt	:= 0
	
	Local aData		:= {{"",""}}
	Local aArea		:= GetArea()
	Local aAreaSB1	:= SB1->( GetArea() )
	Local aAreaSB2	:= SB2->( GetArea() )
	Local aAreaSC5	:= SC5->( GetArea() )
	Local aAreaSC9	:= SC9->( GetArea() )
	Local aAreaSC6	:= SC6->( GetArea() )
	

	If _cChave <> NIL  .And. _cChave <> "SC9"
		dbSelectArea("SC9")
		dbSetOrder(1)
		dbSeek(xFilial("SC9")+_cChave)
	
		dbSelectArea("SC6")
		dbSetOrder(1)
		dbSeek(xFilial("SC6")+_cChave)
	Else
		dbSelectArea("SC6")
		dbSetOrder(1)
		dbSeek(xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM)
	Endif
	
	dbSelectArea("SB1")
	dbSetOrder(1)
	dbSeek(xFilial("SB1")+SC6->C6_PRODUTO)
	
	dbSelectArea("SC5")
	dbSetOrder(1)
	dbSeek(xFilial("SC5")+SC6->C6_NUM)
	
	
	// Carrega os dados do produto
	cCod 	:= SC6->C6_PRODUTO
	cDescr	:= AllTrim(SB1->B1_DESC)
	
	// Carrega o Memo C5_OBSNFSE
	cTxt 	:= AllTrim(SC5->C5_OBSNFSE)
	nLinCnt := MlCount( cTxt )
	For nX := 1 To nLinCnt
		cObsNfs += MemoLine( AllTrim(cTxt), 80, nX)
	Next nX	
	
	// Carrega o Memo C5_OBSEXPE
	cTxt 	:= AllTrim(SC5->C5_OBSEXPE)
	nLinCnt := MlCount( cTxt )
	For nX := 1 To nLinCnt
		cObsExp += MemoLine( AllTrim(cTxt), 80, nX)
	Next nX	
	
	// Carrega o Memo C5_MENNOTA
	cTxt 	:= AllTrim(SC5->C5_MENNOTA)
	nLinCnt := MlCount( cTxt )
	For nX := 1 To nLinCnt
		cMnNota += MemoLine( AllTrim(cTxt), 80, nX)
	Next nX

	// Previsao de entrada
	cPrev 	:= u_MahC021( cCod )
	
	// Status Pedido de Venda
	cStatPv := u_C010StPv( SC5->C5_FILIAL, SC6->C6_NUM, SC6->C6_ITEM, SC9->(RecNo()) )[1]
	
	// Montagem do array de saldos
	C20GetSld( @aData, @cTotal, cCod )
	
	oDialog := MSDialog():New( 0, 0, nHeight, nWidth, OemToAnsi("Saldos Dispon�veis de Produto Multi Filiais"),,,,,,,,,.T.,,, )
	
	oLbCod 		:= TSay():New( nLine+2	 , 10 	,{||"C�digo:"}		,oDialog,,,,,,.T.,,,200,20 )
	oTxCod 		:= TGet():New( nLine	 , 50	,{||cCod}			,oDialog,  50, 10, "@!",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,"",,,, )
	
	oLbDescr	:= TSay():New( nLine+2	 ,105 	,{||"Descri��o:"}	,oDialog,,,,,,.T.,,,200,20 )
	oTxDescr	:= TGet():New( nLine	 ,135	,{||cDescr}			,oDialog, 200, 10, "@!",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,"",,,, )
	
	nLine += 16
	oLbObsNfs	:= TSay():New( nLine	 , 10	,{||"Obs. Serv.:"}	,oDialog,,,,,,.T.,,,200,20 )
	oTxObsNfs	:= TMultiget():New( nLine, 50	,{||cObsNfs}		,oDialog, 285, 35,,,,,,.T.,,,,,,.T. )
	
	nLine += 40
	oLbObsExp	:= TSay():New( nLine	 , 10	,{||"Obs. Exp.:"}	,oDialog,,,,,,.T.,,,200,20 )
	oTxObsExp	:= TMultiget():New( nLine, 50	,{||cObsExp}		,oDialog, 285, 35,,,,,,.T.,,,,,,.T. )
	
	nLine += 40
	oLbMnNota	:= TSay():New( nLine	 , 10	,{||"Mens P/Nota:"}	,oDialog,,,,,,.T.,,,200,20 )
	oTxMnNota	:= TMultiget():New( nLine, 50	,{||cMnNota}		,oDialog, 285, 35,,,,,,.T.,,,,,,.T. )
	
	nLine += 40
	oLbPrev		:= TSay():New( nLine	 , 10	,{||"Prev. PC:"}	,oDialog,,,,,,.T.,,,200,20 )
	oTxPrev		:= TGet():New( nLine	 , 50	,{||cPrev}			,oDialog,  50, 10, PesqPict("SC7", "C7_QUANT"),,,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,"",,,, )
	
	oLbStatPv	:= TSay():New( nLine+2	 , 200	,{||"Status PV:"}	,oDialog,,,,,,.T.,,,200,20 )
	oTxStatPv	:= TGet():New( nLine	 , 230	,{||cStatPv}		,oDialog,  105, 10, "@!",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,"",,,, )
	
	
	// Montagem do Grid de Saldos
	nLine	+= 20
	nWidth	:= 325
	nHeight	:= 70	
	oGrid 	:= TWBrowse():New( nLine, 10, nWidth, nHeight,,,, oDialog,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
	oGrid:aHeaders  := {"Filial", "Saldo do Produto"}
	oGrid:aColSizes := {50, 100}
	oGrid:SetArray( aData )
	oGrid:bLine := @{||{ aData[oGrid:nAt,01], aData[oGrid:nAt,02] } }	
	
	nLine += 75
	oBtFechar  	:= TButton():New( nLine, 10, "&Fechar", oDialog, {|| oDialog:End()}, 50, 15 ,,,.F.,.T.,.F.,,.F.,,,.F. )
	
	// Totalizador
	oLbTotal	:= TSay():New( nLine+2	 , 260 	,{||"Total = "}		,oDialog,,,,,,.T.,,,200,20 )
	oTxTotal	:= TGet():New( nLine	 , 280	,{||cTotal}			,oDialog,  55, 10, PesqPict("SB2", "B2_QATU"),,,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,"",,,, )
	
	oDialog:lCentered := .T.
	oDialog:Activate()
	
	RestArea( aArea )
	RestArea( aAreaSB1 )
	RestArea( aAreaSB2 )
	RestArea( aAreaSC5 )	
	RestArea( aAreaSC9 )	
	RestArea( aAreaSC6 )	

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �C20GetSld | Autor �Giovanni Melo          � Data �08/06/2016��� 
�������������������������������������������������������������������������Ĵ��
���Descricao � Monta um array com os saldos de cada filial do produto     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function C20GetSld( aData, cTotSld, cCodProd )

	Local cQuery 	:= ""
	Local cAliasTmp	:= GetNextAlias()
	Local nTotal	:= 0
	Local nSaldo	:= 0
	Local cFilSld	:= SuperGetMv( "MA_FILSLDE",.F.,"" )
	Local cLocSld	:= SuperGetMv( "MA_LOCSLDE",.F.,"" )
	
	cQuery := " SELECT B2_FILIAL, B2_LOCAL "
	cQuery += " FROM " + RetSqlName("SB2")
	cQuery += " WHERE B2_FILIAL IN " + FormatIn(cFilSld,"|")
	cQuery += "   AND B2_COD = '" + cCodProd + "' "
	cQuery += "   AND B2_LOCAL IN " + FormatIn(cLocSld,"|")
	cQuery += "   AND D_E_L_E_T_ = ' ' "
	cQuery += " GROUP BY B2_FILIAL, B2_LOCAL "
	cQuery += " ORDER BY B2_FILIAL, B2_LOCAL "
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.F.,.T. )

	If (cAliasTmp)->(!EoF())
	
		aData := {}
		
		While (cAliasTmp)->(!Eof())
		    
			dbSelectArea("SB2")
			dbSetOrder(1)			
			dbSeek( (cAliasTmp)->B2_FILIAL + cCodProd + (cAliasTmp)->B2_LOCAL )
			nSaldo := SaldoSb2()
			nTotal += nSaldo
			  
			If (nScan := aScan( aData, { |x| x[1] == (cAliasTmp)->B2_FILIAL  } )) == 0
				aAdd ( aData, { (cAliasTmp)->B2_FILIAL, nSaldo })
			Else
				aData[nScan][2] += nSaldo
			EndIf
			
			(cAliasTmp)->(dbSkip())
			                           
		EndDo
		
	EndIf
	
	// Formatacao da coluna Saldo
	For nX := 1 To Len(aData)
		aData[nX][2] := Transform(aData[nX][2], PesqPict("SB2", "B2_QATU"))
	Next	
	
	// Atribui o total de saldos ao campo totalizador
	cTotSld := nTotal
	
	( cAliasTmp )->( dbCloseArea() )
	
Return