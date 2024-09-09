#include 'protheus.ch'


User Function PE01NFESEFAZ()

Local aArea     := GetArea()
Local aAreaSF2  := SF2->( GetArea() )
Local aAreaSD2  := SD2->( GetArea() )
Local aAreaSF1  := SF1->( GetArea() )
Local aAreaSD1  := SD1->( GetArea() )
Local aAreaSF4  := SF4->( GetArea() )
Local aAreaSB8  := SB8->( GetArea() )
Local aProduto  := PARAMIXB[1]
Local cMensCli  := PARAMIXB[2]
Local aInfoItem := PARAMIXB[6]
Local nI, nT, nP
Local nPos
Local cTipo         := ''
Local aMsgTES       := {}
Local aMsgFormulas  := {}
Local nValorII      := 0
Local aPedVen       := {}
Local aNFOri        := {}
Local cNum          := ""
Local cPro          := ""
Local cTab			:= ""

// uso o CFOP para identificar o tipo da nota fiscal (entrada ou saida)
If aProduto[1,7] >= '5000'
	cTipo := '1'    // saida
Else
	cTipo := '0'    // entrada
EndIf

If cTipo = '1'
	// ===========================================================================
	
	
	
	// informacao do numero do LOTE do produto
	For nI := 1 to Len(aInfoItem)	
		// posiciona
		SC5->( dbSeek(xFilial('SC5')+aInfoItem[nI,1]) )
		cTab:=SC5->C5_TABELA
		SC6->( dbSeek(xFilial('SC6')+aInfoItem[nI,1]+aInfoItem[nI,2]) )
		SD2->( dbSetOrder(3) )   // D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
		SD2->( dbSeek(xFilial('SD2')+SF2->F2_DOC+SF2->F2_SERIE+SC5->C5_CLIENTE+SC5->C5_LOJACLI+SC6->C6_PRODUTO+aInfoItem[nI,4]) )
        
        cPro:=SC6->C6_PRODUTO
		If ! Empty(aProduto[nI, 19])
			SB8->( dbSetOrder(3) )
		   	//	SB8->( dbSeek(xFilial('SD2')+aProduto[nI, 2]+aProduto[nI, 19]) )
			SB8->( dbSeek(xFilial('SD2')+SD2->D2_COD+SD2->D2_LOCAL+SD2->D2_LOTECTL) )
			
			// Ajuste: Marllon - 2015-06-16 - solicitacao: Borges - Retirar a Data de Validade
			aProduto[nI, 4] := AllTrim(aProduto[nI, 4]) + " - LOTE: "+Alltrim(aProduto[nI, 19]) + " - VALID. " + Dtoc(SB8->B8_DTVALID)
		Endif

		//  numero de serie
		SDB->( dbSetOrder(1) )  // DB_FILIAL+DB_PRODUTO+DB_LOCAL+DB_NUMSEQ+DB_DOC+DB_SERIE+DB_CLIFOR+DB_LOJA+DB_ITEM
		If SDB->( dbSeek(xFilial('SDB')+SD2->D2_COD+SD2->D2_LOCAL+SD2->D2_NUMSEQ+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA) )

			aProduto[nI, 4] += " SERIE: "+Alltrim(SDB->DB_NUMSERIE)
		EndIf
		
		//  RMS
		IF !EMPTY(cRMS(cPro))
			aProduto[nI, 4] += " RMS: "+cRMS(cPro)
		EndIf
		
		
		//  TUSS
		IF !EMPTY(AllTrim(cTUSS(cPro)))
			aProduto[nI, 4] += " TUSS: "+AllTrim(cTUSS(cPro))
		EndIf
		
		
		//  Codigo Tipo
		IF !EMPTY(AllTrim(cCODTIP(cTab,cPro)))
			aProduto[nI, 4] += " TC: "+AllTrim(cCODTIP(cTab,cPro))
		endif
		cPro:=''
		cTab:=''

	// ===========================================================================
	// informacao de mensagens das TES
	DbSelectArea("SM4") // * Formulas
	//dbSetOrder(1)
	dbSetOrder(1)

	//SD2->( dbSetOrder(3) )
	//SD2->( dbSeek(xFilial('SD2')+SF2->F2_DOC+SF2->F2_SERIE) )

	//Do While ! SD2->( Eof() ) .and. xFilial('SD2')+SF2->F2_DOC+SF2->F2_SERIE == SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE
		
		SF4->( dbSeek(xFilial('SF4') + SD2->D2_TES) )
		
		aMsgTES := {SF4->F4_FORM1,SF4->F4_FORM2,SF4->F4_FORM3,SF4->F4_FORM4}
		For nT := 1 to Len(aMsgTES)
			If ! Empty(aMsgTES[nT])
				nPos := aScan( aMsgFormulas , aMsgTES[nT] )
				If nPos == 0
					aAdd( aMsgFormulas , aMsgTES[nT] )
					cMensCli += ' '+Iif(Empty(AllTrim(FORMULA(aMsgTES[nT]))), '', AllTrim(FORMULA(aMsgTES[nT])))
				Endif
			Endif
		Next
		
		// informacao do numero do Pedido de Vendas
		If aScan( aPedVen, {|x| x == SD2->D2_PEDIDO} ) <= 0
			aadd(aPedVen, SD2->D2_PEDIDO)
		EndIf
		
		//SD2->( dbSkip() )

	Next

	// informa pedidos de venda
	If Len(aPedVen) > 0
		cMensCli += '  Pedido(s): '
		For nP := 1 To Len(aPedVen)
			cMensCli += aPedVen[nP]+'/'
		Next
	EndIf 
	
	// informa o codigo do cliente
	cMensCli += '  Cliente: ' + SC5->C5_CLIENTE
	
	// Informacoes medicas OPME
	
	If !EMPTY(SC5->C5_NOMMED) 
	      cMensCli += '  Medico/CRM: '   + SC5->C5_NOMMED + "/" + AllTrim(cMedico(SC5->C5_CODMED))
	Endif 
	
	If !EMPTY(SC5->C5_NOMCONV) 
	      cMensCli += '  Convenio/ANS: ' + SC5->C5_NOMCONV + "/" + AllTrim(cConv(SC5->C5_CODCONV))
	endif
	
	If !EMPTY(SC5->C5_PACIENT)      
	      cMensCli += '  Paciente: ' 	 + SC5->C5_PACIENT    
    Endif
    
    If !EMPTY(SC5->C5_DPROCED)      
	      cMensCli += '  Dt. Procedimento: ' + dToC(SC5->C5_DPROCED)   
    Endif
    
    If !EMPTY(SC5->C5_ZDESPRC) 
	      cMensCli += '  Procedimento: ' + AllTrim(SC5->C5_ZCODPRC)+' - '+AllTrim(SC5->C5_ZDESPRC) 
    Endif
    
   
    If !EMPTY(SC5->C5_ZCLIRET) .and. !EMPTY(SC5->C5_ZLOJRET)
	      cMensCli += '  Prestador: ' + cNomSoli( AllTrim(SC5->C5_ZCLIRET), AllTrim(SC5->C5_ZLOJRET) )
    Endif


    
Else

	For nI := 1 to Len(aInfoItem)	
		aProduto[nI, 4] := AllTrim(aProduto[nI, 4]) + " - LOTE: "+Alltrim(aProduto[nI, 19])
	next
	
	// ===========================================================================
	// informacao de mensagens das TES
	DbSelectArea("SM4") // * Formulas
	dbSetOrder(1)
	DbSelectArea("SF4") // * Tipos de Entrada e Saida
	dbSetOrder(1)

	SD1->( dbSetOrder(1) )
	SD1->( dbSeek(xFilial('SD1')+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA) )

	Do While !Eof() .and. xFilial('SD1')+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA == SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA
		
		  
		SF4->( dbSeek(xFilial('SF4') + SD1->D1_TES) )
		
		aMsgTES := {SF4->F4_FORM1,SF4->F4_FORM2,SF4->F4_FORM3,SF4->F4_FORM4}
		For nI := 1 to Len(aMsgTES)
			If ! Empty(aMsgTES[nI])
				nPos := aScan( aMsgFormulas , aMsgTES[nI] )
				If nPos == 0
					aAdd( aMsgFormulas , aMsgTES[nI] )
					cMensCli += Iif(Empty(AllTrim(FORMULA(aMsgTES[nI]))), '', AllTrim(FORMULA(aMsgTES[nI]))+'/p/')
				Endif
			Endif
		Next
		
		
			
		SD1->( dbSkip() )
		
	EndDo
	
	// verificar se eh nota de importacao
	// localiza o processo de embarque
	If ! Empty(SF1->F1_HAWB)
		SW6->( dbSetOrder(1) )
		If SW6->( dbSeek(xFilial('SW6')+SF1->F1_HAWB) )
			cMensCli += ' Processo: ' + Alltrim(SF1->F1_HAWB)
			If Empty(SW6->W6_DI_NUM)
				cMensCli += ' DIRE: ' + Alltrim(SW6->W6_DIRE) + ' Data da DIRE: ' + Dtoc(SW6->W6_DTREG_D)
			Else
				cMensCli += ' NUM.DI: ' + Alltrim(SW6->W6_DI_NUM) + ' Data da DI: ' + Dtoc(SW6->W6_DTREG_D)
			EndIf
			cMensCli += ' LOCAL DO DESEMBARACO: ' + Alltrim(SW6->W6_LOCALN)
			
			cMensCli += ' II: ' + Alltrim(Str(SF1->F1_II,16,2)) + ' PIS: ' + Alltrim(Str(SF1->F1_VALIMP6,16,2)) + ' COFINS: ' + Alltrim(Str(SF1->F1_VALIMP5,16,2))
			
			//If SWD->( dbSeek(xFilial('SWD')+SF1->F1_HAWB+'419') )
			//	cMensCli += ' TX SISCOMEX: ' + Alltrim(Str(SWD->WD_VALOR_R,16,2))
			//EndIf
			cMensCli += ' TX SISCOMEX: ' + Alltrim(Str(RetSiscomex( SF1->F1_DOC, SF1->F1_SERIE, SF1->F1_FORNECE, SF1->F1_LOJA ),16,2))
			
			If SWD->( dbSeek(xFilial('SWD')+SF1->F1_HAWB+'421') )
				cMensCli += ' AFRMM: ' + Alltrim(Str(SWD->WD_VALOR_R,16,2))
			EndIf
			
		EndIf
    Endif
    
Endif

// atualiza dados para o NFESEFAZ
PARAMIXB[1]  := aProduto
PARAMIXB[2]  := cMensCli

RestArea( aAreaSF2 )
RestArea( aAreaSD2 )
RestArea( aAreaSF1 )
RestArea( aAreaSD1 )
RestArea( aAreaSF4 )
RestArea( aAreaSB8 )
RestArea( aArea )

Return( PARAMIXB )


/* calcula a despesa do SISCOMEX */
Static Function RetSiscomex( cNota, cSerie, cFornec, cLoja )
Local nValor    := 0
Local cAliasTMP := 'TMP'

BeginSql Alias cAliasTMP
	SELECT SUM(WW_VALOR) as XX_VALOR
	FROM %Table:SWW% SWW
	WHERE WW_FILIAL = %xFilial:SWW% 
	AND WW_NF_COMP  = %Exp:cNota%
	AND WW_SE_NFC   = %Exp:cSerie%
	AND WW_FORNECE  = %Exp:cFornec%
	AND WW_LOJA     = %Exp:cLoja%
	AND SUBSTRING(WW_DESPESA,1,3) = '419'
	AND SWW.%notdel%
EndSql

nValor := (cAliasTMP)->XX_VALOR

(cAliasTMP)->( dbCloseArea() )

Return( nValor )



/* Nome do cliente solicitante */
Static Function cNomSoli( cCliSol,cLojSol)
Local cNomSol    := ""
Local cAliasTMP1 := 'TMP1'

BeginSql Alias cAliasTMP1
	SELECT A1_NOME 
	FROM %Table:SA1% SA1
	WHERE A1_FILIAL = %xFilial:SA1% 
	AND   A1_COD    = %Exp:cCliSol%
	AND   A1_LOJA   = %Exp:cLojSol%
	AND   SA1.%notdel%
EndSql

cNomSol := (cAliasTMP1)->A1_NOME

(cAliasTMP1)->( dbCloseArea() )

Return( cNomSol )



/* CRM do Medico */
Static Function cMedico( cCodMed)
Local cCRM    := ""
Local cAliasTMP1 := 'TMP1'

BeginSql Alias cAliasTMP1
	SELECT ZA1_CRM 
	FROM %Table:ZA1% ZA1
	WHERE ZA1_FILIAL = %xFilial:ZA1% 
	AND ZA1_CODIGO  = %Exp:cCodMed%
	AND ZA1.%notdel%
EndSql

cCRM := (cAliasTMP1)->ZA1_CRM

(cAliasTMP1)->( dbCloseArea() )

Return( cCRM )

/* ANS do Convenio */
Static Function cConv( cCodConv)
Local cANS    := ""
Local cAliasTMP2 := 'TMP2'

BeginSql Alias cAliasTMP2
	SELECT ZA2_ANS 
	FROM %Table:ZA2% ZA2 
	WHERE ZA2_FILIAL = %xFilial:ZA2% 
	AND ZA2_CODIGO  = %Exp:cCodConv%
	AND ZA2.%notdel%
EndSql

cANS := (cAliasTMP2)->ZA2_ANS

(cAliasTMP2)->( dbCloseArea() )

Return( cANS )


/* RMS PRODUTO */
Static Function cRMS( cCodPro)
Local cNRMS    := ""
Local cAliasTMP3 := 'TMP3'

BeginSql Alias cAliasTMP3
	SELECT B1_NRANVIS 
	FROM %Table:SB1% SB1 
	WHERE B1_FILIAL = %xFilial:SB1% 
	AND B1_COD      = %Exp:cCodPro%
	AND SB1.%notdel%
EndSql

cNRMS := AllTrim((cAliasTMP3)->B1_NRANVIS)

(cAliasTMP3)->( dbCloseArea() )

Return( cNRMS )

/* TUSS PRODUTO */
Static Function cTUSS( cCodPro)
Local cCTUSS     := ""
Local cAliasTMP4 := 'TMP4'

BeginSql Alias cAliasTMP4
	SELECT B1_ZCDTUSS 
	FROM %Table:SB1% SB1 
	WHERE B1_FILIAL = %xFilial:SB1% 
	AND B1_COD      = %Exp:cCodPro%
	AND SB1.%notdel%
EndSql

cCTUSS := AllTrim((cAliasTMP4)->B1_ZCDTUSS)

(cAliasTMP4)->( dbCloseArea() )

Return( cCTUSS )

/* TIPO CODIGO PRODUTO */
Static Function cCODTIP(cTabela,cCodPro)
Local cCdTp      := ""
Local cAliasTMP5 := 'TMP5'

BeginSql Alias cAliasTMP5
	SELECT DA1_CODTIP 
	FROM %Table:DA1% DA1 
	WHERE DA1_FILIAL = %xFilial:DA1% 
	AND DA1_CODTAB   = %Exp:cTabela%
	AND DA1_CODPRO   = %Exp:cCodPro%
	AND DA1.%notdel%
EndSql

cCdTp := AllTrim((cAliasTMP5)->DA1_CODTIP)

(cAliasTMP5)->( dbCloseArea() )

Return( cCdTp )


