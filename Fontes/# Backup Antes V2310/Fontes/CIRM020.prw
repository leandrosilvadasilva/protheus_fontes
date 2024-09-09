#include "protheus.ch"
/*
|============================================================================|
|============================================================================|
|||-----------+---------+-------+------------------------+------+----------|||
||| Funcao    | CIRM020 | Autor | CI RESULT              | Data |19/04/2019|||
|||-----------+---------+-------+------------------------+------+----------|||
||| Descricao | Gera movimentação de ajuste na tabela SD3 para corrigir    |||
|||           | as diferenças de saldo entre as tabelas SB2xSB8 e SB2xSBF  |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   | CIRM020()                                                  |||
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
User Function CIRM020()

Local cPerg  := PadR("CIRM020",10)

//PutSX1( cGrupo, cOrdem, cTexto					, cMVPar	, cVariavel	, cTipoCamp	, nTamanho					, nDecimal	, cTipoPar	, cValid	, cF3		, cPicture	, cDef01		, cDef02			, cDef03			, cDef04	, cDef05	, cHelp	, cGrpSXG	, cCnt01		)
u_PutSX1( cPerg	, "01"	, "Data do Movimentação ?"	, "mv_par01", "mv_ch1"	, "D"		, 08						, 0			, "G"		, ""		, 	    	, 			, 				, 					, 					,			,			,		, 			, 			)
u_PutSX1( cPerg	, "02"	, "Documento ?"				, "mv_par02", "mv_ch2"	, "C"		, TamSX3('D3_DOC')[1]		, 0			, "G"		, ""		, 			, 			, 				, 					, 					,			,			,		, 			,			)
u_PutSX1( cPerg	, "03"	, "Local de ?"				, "mv_par03", "mv_ch3"	, "C"		, 02						, 0			, "G"		, ""		, 			, 			, 				, 					, 					,			,			,		, 			,			)
u_PutSX1( cPerg	, "04"	, "Local ate  ?"			, "mv_par04", "mv_ch4"	, "C"		, 02						, 0			, "G"		, ""		, 	    	, 			, 				, 					, 					,			,			,		, 			, 			)
u_PutSX1( cPerg	, "05"	, "Produto ?"				, "mv_par05", "mv_ch5"	, "C"		, TamSX3('B1_COD')[1]		, 0			, "G"		, ""		, "SB1"    	, 			, 				, 					, 					,			,			,		, 			, 			)

dbSelectArea('SB7')
dbSetOrder(1)

If Pergunte(cPerg, .t.)
	If MV_PAR01 > GetMV('MV_ULMES')
		Processa( {|| RunProc() },"Processando produtos para ajuste dos saldos","Aguarde.." )
	Else
		MsgInfo('A Data informada deve ser maior que a data de último fechamento de estoque!')
	EndIf
Endif

Return

Static Function RunProc()

Local nQtdReg := 0
Local nQuant  := 0

ProcRegua(nQtdReg)

// Analise e ajuste das diferencas de saldos entre as tabelas SB2 x SBF

BeginSql alias 'SBFTMP'

SELECT  B2_FILIAL, B2_COD, B2_LOCAL, ROUND( SUM( B2_QATU ), 2 ) B2_QATU, ROUND( SUM( BF_QUANT ), 2 ) BF_QUANT
 FROM ( SELECT B2_FILIAL, B2_COD, B2_LOCAL, B2_QATU, 0 BF_QUANT
         FROM %table:SB2% SB2, %table:SB1% SB1
         WHERE SB2.B2_FILIAL = %xfilial:SB2%
         and SB2.%notDel%
         and SB1.B1_FILIAL = %xfilial:SB1%
         and B1_COD = B2_COD
         and B1_LOCALIZ = 'S'
         and SB1.%notDel%
        UNION ALL
        SELECT BF_FILIAL B2_FILIAL, BF_PRODUTO B2_COD, BF_LOCAL B2_LOCAL, 0 B2_QATU, sum( BF_QUANT ) BF_QUANT
         FROM %table:SBF% SBF, %table:SB1% SB1
         WHERE SBF.BF_FILIAL = %xfilial:SBF%
         and SBF.%notDel%
         and SB1.B1_FILIAL = %xfilial:SB1%
         and B1_COD = BF_PRODUTO
         and B1_LOCALIZ = 'S'
         and SB1.%notDel%
        GROUP BY BF_FILIAL, BF_PRODUTO, BF_LOCAL
        UNION ALL
        SELECT DA_FILIAL B2_FILIAL, DA_PRODUTO B2_COD, DA_LOCAL B2_LOCAL, 0 B2_QATU, sum( DA_SALDO ) BF_QUANT
         FROM %table:SDA% SDA
         WHERE SDA.DA_FILIAL = %xfilial:SDA%
         and DA_SALDO > 0
         and SDA.%notDel%
        GROUP BY DA_FILIAL, DA_PRODUTO, DA_LOCAL
 ) as TMP
 GROUP BY B2_FILIAL, B2_COD, B2_LOCAL
 HAVING ROUND( SUM( B2_QATU ), 2 ) <> ROUND( SUM( BF_QUANT ), 2 )
 ORDER BY B2_FILIAL, B2_COD, B2_LOCAL

EndSql

Do While ! Eof()

	SB1->( dbSeek( xFilial( 'SB1' ) + SBFTMP->B2_COD, .f. ) )
		
	nQuant := SBFTMP->B2_QATU-SBFTMP->BF_QUANT

	aCM := PegaCMAtu(SBFTMP->B2_COD,SBFTMP->B2_LOCAL)
	RecLock("SD3",.T.)
	SD3->D3_FILIAL  := xFilial("SD3")
	SD3->D3_COD     := SB1->B1_COD
	SD3->D3_QUANT   := If(nQuant<0,nQuant*(-1),nQuant)
	SD3->D3_CF      := If(nQuant<0,"DE0","RE0")
	SD3->D3_CHAVE   := "E0"
	SD3->D3_LOCAL   := SBFTMP->B2_LOCAL
	SD3->D3_DOC     := MV_PAR02
	SD3->D3_EMISSAO := MV_PAR01
	SD3->D3_UM      := SB1->B1_UM
	SD3->D3_GRUPO   := SB1->B1_GRUPO
	SD3->D3_TIPO    := SB1->B1_TIPO
	SD3->D3_NUMSEQ  := ProxNum()
	SD3->D3_QTSEGUM := ConvUm(SB1->B1_COD,If(nQuant<0,nQuant*(-1),nQuant),0,2)
	SD3->D3_SEGUM   := SB1->B1_SEGUM
	SD3->D3_TM      := If(nQuant<0,"499","999")
	SD3->( MsUnLock() ) // Ver a necessidade da função neste local devido a atualizao do custo
	aCusto := GravaCusD3(aCM)
	B2AtuComD3(aCusto)

    IncProc()
	dbSelectArea('SBFTMP')
	dbSkip()
EndDo

dbSelectArea('SBFTMP')
dbCloseArea()


// Analise e ajuste das diferencas de saldos entre as tabelas SB2 x SB8

BeginSql alias 'SB8TMP'

SELECT  B2_FILIAL, B2_COD, B2_LOCAL, ROUND( SUM( B2_QATU ), 2 ) B2_QATU, ROUND( SUM( B8_SALDO ), 2 ) B8_SALDO
 FROM ( SELECT B2_FILIAL, B2_COD, B2_LOCAL, B2_QATU, 0 B8_SALDO
         FROM %table:SB2% SB2, %table:SB1% SB1
         WHERE SB2.B2_FILIAL = %xfilial:SB2%
         and SB2.%notDel%
         and SB1.B1_FILIAL = %xfilial:SB1%
         and B1_COD = B2_COD
         and B1_LOCALIZ <> 'S'
         and B1_RASTRO in ( 'L', 'S' )
         and SB1.%notDel%
        UNION ALL
        SELECT B8_FILIAL B2_FILIAL, B8_PRODUTO B2_COD, B8_LOCAL B2_LOCAL, 0 B2_QATU, sum( B8_SALDO ) B8_SALDO
         FROM %table:SB8% SB8, %table:SB1% SB1
         WHERE SB8.B8_FILIAL = %xfilial:SB8%
         and SB8.%notDel%
         and SB1.B1_FILIAL = %xfilial:SB1%
         and B1_COD = B8_PRODUTO
         and B1_LOCALIZ <> 'S'
         and B1_RASTRO in ( 'L', 'S' )
         and SB1.%notDel%
        GROUP BY B8_FILIAL, B8_PRODUTO, B8_LOCAL
 ) as TMP
 GROUP BY B2_FILIAL, B2_COD, B2_LOCAL
 HAVING ROUND( SUM( B2_QATU ), 2 ) <> ROUND( SUM( B8_SALDO ), 2 )
 ORDER BY B2_FILIAL, B2_COD, B2_LOCAL

EndSql

Do While ! Eof()

	SB1->( dbSeek( xFilial( 'SB1' ) + SB8TMP->B2_COD, .f. ) )
		
	nQuant := SB8TMP->B2_QATU-SB8TMP->B8_SALDO

	aCM := PegaCMAtu(SB8TMP->B2_COD,SB8TMP->B2_LOCAL)
	RecLock("SD3",.T.)
	SD3->D3_FILIAL  := xFilial("SD3")
	SD3->D3_COD     := SB1->B1_COD
	SD3->D3_QUANT   := If(nQuant<0,nQuant*(-1),nQuant)
	SD3->D3_CF      := If(nQuant<0,"DE0","RE0")
	SD3->D3_CHAVE   := "E0"
	SD3->D3_LOCAL   := SB8TMP->B2_LOCAL
	SD3->D3_DOC     := MV_PAR02
	SD3->D3_EMISSAO := MV_PAR01
	SD3->D3_UM      := SB1->B1_UM
	SD3->D3_GRUPO   := SB1->B1_GRUPO
	SD3->D3_TIPO    := SB1->B1_TIPO
	SD3->D3_NUMSEQ  := ProxNum()
	SD3->D3_QTSEGUM := ConvUm(SB1->B1_COD,If(nQuant<0,nQuant*(-1),nQuant),0,2)
	SD3->D3_SEGUM   := SB1->B1_SEGUM
	SD3->D3_TM      := If(nQuant<0,"499","999")
	SD3->( MsUnLock() ) // Ver a necessidade da função neste local devido a atualizao do custo
	aCusto := GravaCusD3(aCM)
	B2AtuComD3(aCusto)

    IncProc()
	dbSelectArea('SB8TMP')
	dbSkip()
EndDo

dbSelectArea('SB8TMP')
dbCloseArea()

Aviso("Processamento", "Processamento finalizado!",  {"Ok"}, 3)

Return

