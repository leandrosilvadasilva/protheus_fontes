

User Function MAHC160()

Local cCadastro := OemtoAnsi("Geração Conciliação Automática")
Local aSays	    := {}
Local aButtons  := {}
Local nOpca     := 0
Private cPerg   := "MAHC160"

//..  Grupo Ordem Perguntas                     Var     Tip Tm  Dc    GSC Vl F3           Variavel  01 02 03 04 05
PutSx1(cPerg,"01","Da Filial ?         ","","","mv_ch1","C",002,00,00,"G","",""   ,"","","MV_PAR01","","","","","","","","","","","","","","","","","")
PutSx1(cPerg,"02","Até Filial ?        ","","","mv_ch2","C",002,00,00,"G","",""   ,"","","MV_PAR02","","","","","","","","","","","","","","","","","")
PutSx1(cPerg,"03","Da Data ?           ","","","mv_ch3","D",008,00,00,"G","",""   ,"","","MV_PAR03","","","","","","","","","","","","","","","","","")
PutSx1(cPerg,"04","Até Data ?          ","","","mv_ch4","D",008,00,00,"G","",""   ,"","","MV_PAR04","","","","","","","","","","","","","","","","","")
PutSx1(cPerg,"05","Do Lote ?           ","","","mv_ch5","C",006,00,00,"G","",""   ,"","","MV_PAR05","","","","","","","","","","","","","","","","","")
PutSx1(cPerg,"06","Até Lote ?          ","","","mv_ch6","C",006,00,00,"G","",""   ,"","","MV_PAR06","","","","","","","","","","","","","","","","","")
PutSx1(cPerg,"07","Da Conta ?          ","","","mv_ch7","C",020,00,00,"G","","CT2","","","MV_PAR07","","","","","","","","","","","","","","","","","")
PutSx1(cPerg,"08","Até Conta ?         ","","","mv_ch8","C",020,00,00,"G","","CT2","","","MV_PAR08","","","","","","","","","","","","","","","","","")
PutSx1(cPerg,"09","Arquivo Exportação ?","","","mv_ch9","C",060,00,00,"G","","DIR","","","MV_PAR09","","","","","","","","","","","","","","","","","")

AAdd(aSays,OemToAnsi("Esta rotina ira Gerar um arquivo .CSV para a: "))
AAdd(aSays,OemToAnsi("Conciliação Automática") )

AADD( aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T. ) } } )
AAdd( aButtons, { 1,.T.,{|o| nOpca := 1,FechaBatch() }} )
AAdd( aButtons, { 2,.T.,{|o| nOpca := 0,FechaBatch() }} )

FormBatch( cCadastro, aSays, aButtons )
	
If nOpca == 1
	Processa( {|| PROCMAHC160(.T.) },"Conciliação Automática","Aguarde...." )
EndIf

Return

/*
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
*/

Static Function PROCMAHC160()

Local nTamLin, cLin, cCpo

Private cArqTxt
Private nHdl
Private cEOL    := CHR(13)+CHR(10)

Pergunte(cPerg,.F. )

cArqTxt := MV_PAR09
nHdl    := fCreate(cArqTxt)

cQuery := ""
cQuery += "SELECT 	CT2_DATA 				AS TB_DATA, " + Chr(13) + Chr(10)
cQuery += "			CT2_CREDIT 				AS TB_CONTA, " + Chr(13) + Chr(10)
cQuery += "			CAST(CT2_VALOR AS REAL) AS TB_VALOR, " + Chr(13) + Chr(10)
cQuery += "			'C' 					AS TB_DC, " + Chr(13) + Chr(10)
cQuery += "			CT2_HIST 				AS TB_HIST, " + Chr(13) + Chr(10)
cQuery += "			ISNULL((SELECT CT2_HIST " + cEol
cQuery += "					FROM   " + RetSqlName("CT2") + " CT2B " + cEol
cQuery += "					WHERE  CT2B.CT2_FILIAL = CT2.CT2_FILIAL " + cEol
cQuery += "					AND    CT2B.CT2_FILORI = CT2.CT2_FILORI " + cEol
cQuery += "					AND    CT2B.CT2_DATA   = CT2.CT2_DATA " + cEol
cQuery += "					AND    CT2B.CT2_LOTE   = CT2.CT2_LOTE " + cEol
cQuery += "					AND    CT2B.CT2_SBLOTE = CT2.CT2_SBLOTE " + cEol
cQuery += "					AND    CT2B.CT2_DOC    = CT2.CT2_DOC " + cEol
cQuery += "					AND    CT2B.CT2_SEQHIS = '002' " + cEol
cQuery += "					AND    CT2B.CT2_SEQLAN = CT2.CT2_SEQLAN " + cEol
cQuery += "					AND    CT2B.CT2_DC     = '4' " + cEol
cQuery += "					AND    CT2B.D_E_L_E_T_ = ''),'') AS TB_HIST2,  " + cEol
cQuery += "			ISNULL((SELECT CT2_HIST " + cEol
cQuery += "					FROM   " + RetSqlName("CT2") + " CT2C " + cEol
cQuery += "					WHERE  CT2C.CT2_FILIAL = CT2.CT2_FILIAL " + cEol
cQuery += "					AND    CT2C.CT2_FILORI = CT2.CT2_FILORI " + cEol
cQuery += "					AND    CT2C.CT2_DATA   = CT2.CT2_DATA " + cEol
cQuery += "					AND    CT2C.CT2_LOTE   = CT2.CT2_LOTE " + cEol
cQuery += "					AND    CT2C.CT2_SBLOTE = CT2.CT2_SBLOTE " + cEol
cQuery += "					AND    CT2C.CT2_DOC    = CT2.CT2_DOC " + cEol
cQuery += "					AND    CT2C.CT2_SEQHIS = '003' " + cEol
cQuery += "					AND    CT2C.CT2_SEQLAN = CT2.CT2_SEQLAN " + cEol
cQuery += "					AND    CT2C.CT2_DC     = '4' " + cEol
cQuery += "					AND    CT2C.D_E_L_E_T_ = ''),'') AS TB_HIST3,  " + cEol
cQuery += "			CT2_DEBITO 				AS TB_CONTRA, " + Chr(13) + Chr(10)
cQuery += "			CT2_LOTE 				AS TB_LOTE, " + Chr(13) + Chr(10)
cQuery += "			CT2_SBLOTE 				AS TB_SLOTE, " + Chr(13) + Chr(10)
cQuery += "			CT2_DOC 				AS TB_DOC, " + Chr(13) + Chr(10)
cQuery += "			CT2_LINHA 				AS TB_LINHA " + Chr(13) + Chr(10)
cQuery += "FROM 	"+RetSqlName("CT2") + " CT2 " + Chr(13) + Chr(10)
cQuery += "WHERE 	CT2_FILIAL	= 	'' " + Chr(13) + Chr(10)
cQuery += "AND		CT2_DATA 	>= 	'" + DTOS(MV_PAR03) + "' " + Chr(13) + Chr(10)
cQuery += "AND 		CT2_DATA	<=	'" + DTOS(MV_PAR04) + "' " + Chr(13) + Chr(10)
cQuery += "AND		CT2_LOTE 	>= 	'" + MV_PAR05 + "' " + Chr(13) + Chr(10)
cQuery += "AND 		CT2_LOTE	<=	'" + MV_PAR06 + "' " + Chr(13) + Chr(10)
cQuery += "AND		CT2_CREDIT	>=	'" + MV_PAR07       + "' " + Chr(13) + Chr(10)
cQuery += "AND		CT2_CREDIT	<=	'" + MV_PAR08       + "' " + Chr(13) + Chr(10)
cQuery += "AND   	CT2_FILORI	>= 	'" + MV_PAR01 + "' " + Chr(13) + Chr(10)
cQuery += "AND		CT2_FILORI	<=	'" + MV_PAR02 + "' " + Chr(13) + Chr(10)
cQuery += "AND		CT2_DC      IN  ('2','3')" + cEol
cQuery += "AND		D_E_L_E_T_	=	'' " + Chr(13) + Chr(10)
cQuery += "UNION ALL " + Chr(13) + Chr(10)
cQuery += "SELECT 	CT2_DATA 				AS TB_DATA, " + Chr(13) + Chr(10)
cQuery += "			CT2_DEBITO 				AS TB_CONTA, " + Chr(13) + Chr(10)
cQuery += "			CAST(CT2_VALOR AS REAL) AS TB_VALOR, " + Chr(13) + Chr(10)
cQuery += "			'D' 					AS TB_DC, " + Chr(13) + Chr(10)
cQuery += "			CT2_HIST 				AS TB_HIST, " + Chr(13) + Chr(10)
cQuery += "			ISNULL((SELECT CT2_HIST " + cEol
cQuery += "					FROM   " + RetSqlName("CT2") + " CT2B " + cEol
cQuery += "					WHERE  CT2B.CT2_FILIAL = CT2.CT2_FILIAL " + cEol
cQuery += "					AND    CT2B.CT2_FILORI = CT2.CT2_FILORI " + cEol
cQuery += "					AND    CT2B.CT2_DATA   = CT2.CT2_DATA " + cEol
cQuery += "					AND    CT2B.CT2_LOTE   = CT2.CT2_LOTE " + cEol
cQuery += "					AND    CT2B.CT2_SBLOTE = CT2.CT2_SBLOTE " + cEol
cQuery += "					AND    CT2B.CT2_DOC    = CT2.CT2_DOC " + cEol
cQuery += "					AND    CT2B.CT2_SEQHIS = '002' " + cEol
cQuery += "					AND    CT2B.CT2_SEQLAN = CT2.CT2_SEQLAN " + cEol
cQuery += "					AND    CT2B.CT2_DC     = '4' " + cEol
cQuery += "					AND    CT2B.D_E_L_E_T_ = ''),'') AS TB_HIST2,  " + cEol
cQuery += "			ISNULL((SELECT CT2_HIST " + cEol
cQuery += "					FROM   " + RetSqlName("CT2") + " CT2C " + cEol
cQuery += "					WHERE  CT2C.CT2_FILIAL = CT2.CT2_FILIAL " + cEol
cQuery += "					AND    CT2C.CT2_FILORI = CT2.CT2_FILORI " + cEol
cQuery += "					AND    CT2C.CT2_DATA   = CT2.CT2_DATA " + cEol
cQuery += "					AND    CT2C.CT2_LOTE   = CT2.CT2_LOTE " + cEol
cQuery += "					AND    CT2C.CT2_SBLOTE = CT2.CT2_SBLOTE " + cEol
cQuery += "					AND    CT2C.CT2_DOC    = CT2.CT2_DOC " + cEol
cQuery += "					AND    CT2C.CT2_SEQHIS = '003' " + cEol
cQuery += "					AND    CT2C.CT2_SEQLAN = CT2.CT2_SEQLAN " + cEol
cQuery += "					AND    CT2C.CT2_DC     = '4' " + cEol
cQuery += "					AND    CT2C.D_E_L_E_T_ = ''),'') AS TB_HIST3,  " + cEol
cQuery += "			CT2_CREDIT 				AS TB_CONTRA, " + Chr(13) + Chr(10)
cQuery += "			CT2_LOTE 				AS TB_LOTE, " + Chr(13) + Chr(10)
cQuery += "			CT2_SBLOTE 				AS TB_SLOTE, " + Chr(13) + Chr(10)
cQuery += "			CT2_DOC 				AS TB_DOC, " + Chr(13) + Chr(10)
cQuery += "			CT2_LINHA 				AS TB_LINHA " + Chr(13) + Chr(10)
cQuery += "FROM 	"+RetSqlName("CT2") + " CT2 " + Chr(13) + Chr(10)
cQuery += "WHERE 	CT2_FILIAL	= 	'' " + Chr(13) + Chr(10)
cQuery += "AND		CT2_DATA 	>= 	'" + DTOS(MV_PAR03) + "' " + Chr(13) + Chr(10)
cQuery += "AND 		CT2_DATA	<=	'" + DTOS(MV_PAR04) + "' " + Chr(13) + Chr(10)
cQuery += "AND		CT2_LOTE 	>= 	'" + MV_PAR05 + "' " + Chr(13) + Chr(10)
cQuery += "AND 		CT2_LOTE	<=	'" + MV_PAR06 + "' " + Chr(13) + Chr(10)
cQuery += "AND		CT2_DEBITO	>=	'" + MV_PAR07       + "' " + Chr(13) + Chr(10)
cQuery += "AND		CT2_DEBITO	<=	'" + MV_PAR08       + "' " + Chr(13) + Chr(10)
cQuery += "AND   	CT2_FILORI	>= 	'" + MV_PAR01 + "' " + Chr(13) + Chr(10)
cQuery += "AND		CT2_FILORI	<=	'" + MV_PAR02 + "' " + Chr(13) + Chr(10)
cQuery += "AND		CT2_DC      IN  ('1')" + cEol
cQuery += "AND 		D_E_L_E_T_	=	'' " + Chr(13) + Chr(10)
cQuery += "ORDER BY TB_DATA, TB_LOTE, TB_SLOTE, TB_DOC, TB_LINHA  " + Chr(13) + Chr(10)
MemoWrite("\_Queries\ARTC020.SQL",cQuery)
DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), "TRB01", .T., .T.)
TcSetField("TRB01", "TB_DATA", "D")
DbSelectArea('TRB01')
If !EOF()
	If nHdl == -1
		MsgAlert("O arquivo de nome "+cArqTxt+" nao pode ser executado! Verifique os parametros.","Atencao!")
		DbCloseArea()
		Return
	EndIf
	cLin := "Data;"
	cLin += "Conta;"
	cLin += "Valor;"
	cLin += "D/C;"
	cLin += "Historico;"
	cLin += "Contra Partida;"
	cLin += "Lote;"
	cLin += "SubLote;"
	cLin += "Documento;"
	cLin += "Linha;"
	cLin += cEOL
	If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
		If !Msg("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
			DbCloseArea()
			fClose(nHdl)
			Return
		EndIf
	EndIf
	nRegQry := 0
	Count To nRegQry
	ProcRegua(nRegQry)
	DbGoTop()
	Do While !Eof()
		IncProc()
		cLin :=        DTOC(TRB01->TB_DATA)           + ";"
		cLin +=             TRB01->TB_CONTA           + ";"
		cLin += StrTran(Str(TRB01->TB_VALOR),".",",") + ";"
		cLin +=             TRB01->TB_DC              + ";"
		cLin +=     AllTrim(TRB01->TB_HIST)
		cLin +=     AllTrim(TRB01->TB_HIST2)
		cLin +=     AllTrim(TRB01->TB_HIST3)          + ";"
		cLin +=             TRB01->TB_CONTRA          + ";"
		cLin +=             TRB01->TB_LOTE            + ";"
		cLin +=             TRB01->TB_SLOTE           + ";"
		cLin +=             TRB01->TB_DOC             + ";"
		cLin +=             TRB01->TB_LINHA           + ";"
		cLin += cEOL
		If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
			If !Msg("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
				Exit
			EndIf
		EndIf
		DbSelectArea("TRB01")
		DbSkip()
	EndDo
	fClose(nHdl)
EndIf

DbCloseArea()

Return

/*
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
*/
