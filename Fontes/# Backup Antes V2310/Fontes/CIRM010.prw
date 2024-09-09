#include "protheus.ch"
/*
|============================================================================|
|============================================================================|
|||-----------+---------+-------+------------------------+------+----------|||
||| Funcao    | CIRM010 | Autor | CI RESULT              | Data |19/04/2019|||
|||-----------+---------+-------+------------------------+------+----------|||
||| Descricao | Gera inventario para lotes e enderecos sem contagem        |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   | CIRM010()                                                  |||
|||-----------+------------------------------------------------------------|||
||| Parametros|                                                            |||
|||           |                                                            |||
|||-----------+------------------------------------------------------------|||
||| Retorno   | Nenhum                                                     |||
|||-----------+------------------------------------------------------------|||
||| Uso       | Geral                                                      |||
|||-----------+------------------------------------------------------------|||
|||                           ULTIMAS ALTERACOES                           |||
|||-------------+--------+-------------------------------------------------|||
||| Programador | Data   | Motivo da Alteracao                             |||
|||-------------+--------+-------------------------------------------------|||
|||             |        |                                                 |||
|||-------------+--------+-------------------------------------------------|||
|============================================================================|
|============================================================================|*/
User Function CIRM010()

Local cPerg 	:= PadR("CIRM010",10)              
Local dAuxValid := Ctod('')

//PutSX1( cGrupo, cOrdem, cTexto					, cMVPar	, cVariavel	, cTipoCamp	, nTamanho					, nDecimal	, cTipoPar	, cValid	, cF3		, cPicture	, cDef01		, cDef02			, cDef03			, cDef04	, cDef05	, cHelp	, cGrpSXG	, cCnt01		)
u_PutSX1( cPerg	, "01"	, "Data do Inventário ?"	, "mv_par01", "mv_ch1"	, "D"		, 08						, 0			, "G"		, ""		, 	    	, 			, 				, 					, 					,			,			,		, 			, 			)
u_PutSX1( cPerg	, "02"	, "Documento ?"				, "mv_par02", "mv_ch2"	, "C"		, TamSX3('B7_DOC')[1]		, 0			, "G"		, ""		, 			, 			, 				, 					, 					,			,			,		, 			,			)
u_PutSX1( cPerg	, "03"	, "Local de ?"				, "mv_par03", "mv_ch3"	, "C"		, 02						, 0			, "G"		, ""		, "NNR"		, 			, 				, 					, 					,			,			,		, 			,			)
u_PutSX1( cPerg	, "04"	, "Local ate  ?"			, "mv_par04", "mv_ch4"	, "C"		, 02						, 0			, "G"		, ""		, "NNR"	 	, 			, 				, 					, 					,			,			,		, 			, 			)
u_PutSX1( cPerg	, "05"	, "Produto ?"				, "mv_par05", "mv_ch5"	, "C"		, TamSX3('B1_COD')[1]		, 0			, "G"		, ""		, "SB1"    	, 			, 				, 					, 					,			,			,		, 			, 			)

dbSelectArea('SB7')
dbSetOrder(1)

If Pergunte(cPerg, .t.)
	If MV_PAR01 > GetMV('MV_ULMES')
		If dbSeek(xFilial('SB7')+Dtos(MV_PAR01))
			Processa( {|| RunProc() },"Processando produtos com saldo 0 (zero)","Aguarde.." )
		Else
			MsgInfo('Não existe inventário para esta data!')
		EndIf
	Else
		MsgInfo('A Data informada deve ser maior que a data de último fechamento de estoque!')
	EndIf
Endif

Return

Static Function RunProc()

Local nQtdReg 

// contagem de registros
BeginSql alias 'SBFQTD'
	SELECT Count(*) as QTDREG 
	FROM %table:SBF% SBF, %table:SB1% SB1
	WHERE     SBF.BF_FILIAL = %xfilial:SBF%
	      and SBF.BF_LOCAL >= %exp:MV_PAR03%
	      and SBF.BF_LOCAL <= %exp:MV_PAR04%
	      and SBF.BF_QUANT <> 0
	      and SBF.%notDel%
	      and SB1.B1_FILIAL = %xfilial:SB1%
	      and SB1.B1_COD = SBF.BF_PRODUTO
	      and SB1.B1_LOCALIZ = 'S'
	      and SB1.%notDel%
EndSql
nQtdReg := SBFQTD->QTDREG
dbSelectArea('SBFQTD')
dbCloseArea()

ProcRegua(nQtdReg)

BeginSql alias 'SBFTMP'
	
	SELECT BF_PRODUTO, BF_LOCAL, BF_NUMSERI, BF_LOCALIZ, BF_LOTECTL, B1_TIPO 
	FROM %table:SBF% SBF, %table:SB1% SB1
	WHERE     SBF.BF_FILIAL = %xfilial:SBF%
	      and SBF.BF_LOCAL >= %exp:MV_PAR03%
	      and SBF.BF_LOCAL <= %exp:MV_PAR04%
	      and SBF.BF_QUANT <> 0
	      and SBF.%notDel%
	      and SB1.B1_FILIAL = %xfilial:SB1%
	      and SB1.B1_COD = SBF.BF_PRODUTO
	      and SB1.B1_LOCALIZ = 'S'
	      and SB1.%notDel%
EndSql

Do While ! Eof()
	dbSelectArea('SB7')
	If ! dbSeek(xFilial('SB7')+Dtos(MV_PAR01)+SBFTMP->BF_PRODUTO+SBFTMP->BF_LOCAL+SBFTMP->BF_LOCALIZ+SBFTMP->BF_NUMSERI+SBFTMP->BF_LOTECTL)
	    dAuxValid := Ctod('')
		If !Empty(SBFTMP->BF_LOTECTL)
			dbSelectArea('SB8')
			dbSetOrder(5)
			If dbSeek(xFilial('SB8')+SBFTMP->BF_PRODUTO+SBFTMP->BF_LOTECTL)
	            dAuxValid := SB8->B8_DTVALID
	        Endif
	   	Endif
		If RecLock('SB7', .t.)
			SB7->B7_FILIAL    := xFilial('SB7')
			SB7->B7_COD       := SBFTMP->BF_PRODUTO
			SB7->B7_LOCAL     := SBFTMP->BF_LOCAL
			SB7->B7_TIPO      := SBFTMP->B1_TIPO
			SB7->B7_DOC       := Alltrim(MV_PAR02)
			SB7->B7_QUANT     := 0
			SB7->B7_DATA      := MV_PAR01
			SB7->B7_LOTECTL   := SBFTMP->BF_LOTECTL
			SB7->B7_NUMSERI   := SBFTMP->BF_NUMSERI
			SB7->B7_LOCALIZ   := SBFTMP->BF_LOCALIZ
			SB7->B7_DTVALID   := dAuxValid
		EndIf
		MsUnLock()
	EndIf
    IncProc()
	dbSelectArea('SBFTMP')
	dbSkip()
EndDo

dbSelectArea('SBFTMP')
dbCloseArea()


// contagem de registros
BeginSql alias 'SB8QTD'
	SELECT Count(*) as QTDREG 
	FROM %table:SB8% SB8, %table:SB1% SB1
	WHERE     SB8.B8_FILIAL = %xfilial:SB8%
	      and SB8.B8_LOCAL >= %exp:MV_PAR03%
	      and SB8.B8_LOCAL <= %exp:MV_PAR04%
	      and SB8.B8_SALDO <> 0
	      and SB8.%notDel%
	      and SB1.B1_FILIAL = %xfilial:SB1%
	      and SB1.B1_COD = SB8.B8_PRODUTO
	      and SB1.B1_LOCALIZ <> 'S'
	      and SB1.B1_RASTRO in ( 'L', 'S' ) 
	      and SB1.%notDel%
EndSql
nQtdReg := SB8QTD->QTDREG
dbSelectArea('SB8QTD')
dbCloseArea()

ProcRegua(nQtdReg)

BeginSql alias 'SB8TMP'
	column B8_DTVALID as Date

	SELECT B8_PRODUTO, B8_LOCAL, B8_LOTECTL, B8_DTVALID, B1_TIPO 
	FROM %table:SB8% SB8, %table:SB1% SB1
	WHERE     SB8.B8_FILIAL = %xfilial:SB8%
	      and SB8.B8_LOCAL >= %exp:MV_PAR03%
	      and SB8.B8_LOCAL <= %exp:MV_PAR04%
	      and SB8.B8_SALDO <> 0
	      and SB8.%notDel%
	      and SB1.B1_FILIAL = %xfilial:SB1%
	      and SB1.B1_COD = SB8.B8_PRODUTO
	      and SB1.B1_LOCALIZ <> 'S'
	      and SB1.B1_RASTRO in ( 'L', 'S' ) 
	      and SB1.%notDel%
EndSql

Do While ! Eof()
	dbSelectArea('SB7')
	If ! dbSeek(xFilial('SB7')+Dtos(MV_PAR01)+SB8TMP->B8_PRODUTO+SB8TMP->B8_LOCAL+Space(Len(SB7->B7_LOCALIZ))+Space(Len(SB7->B7_NUMSERI))+SB8TMP->B8_LOTECTL)
		If RecLock('SB7', .t.)
			SB7->B7_FILIAL    := xFilial('SB7')
			SB7->B7_COD       := SB8TMP->B8_PRODUTO
			SB7->B7_LOCAL     := SB8TMP->B8_LOCAL
			SB7->B7_TIPO      := SB1->B1_TIPO
			SB7->B7_DOC       := Alltrim(MV_PAR02)
			SB7->B7_QUANT     := 0
			SB7->B7_DATA      := MV_PAR01
			SB7->B7_LOTECTL   := SB8TMP->B8_LOTECTL
			SB7->B7_DTVALID   := SB8TMP->B8_DTVALID
		EndIf
		MsUnLock()
	EndIf

    IncProc()
	dbSelectArea('SB8TMP')
	dbSkip()
EndDo

dbSelectArea('SB8TMP')
dbCloseArea()


Return

