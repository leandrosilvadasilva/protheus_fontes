#include 'protheus.ch'
/*___________________________________________________________________________
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
||-------------------------------------------------------------------------||
|| Função: CIRM040      || Autor: Luciano Corrêa        || Data: 13/06/19  ||
||-------------------------------------------------------------------------||
|| Descrição: Análise de Saldos Físico x Lote x Endereço                   ||
||-------------------------------------------------------------------------||
|| Melhorias Pendentes: Utilizar constantes para posição arrays            ||
||                      Tratar demais divergências de saldos               ||
||-------------------------------------------------------------------------||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function CIRM040()

Local aSvKeys	:= GetKeys()
Local aObjects	:= {}
Local aPosObj	:= {}
Local aInfo		:= {}
Local aSize		:= {}
Local oDlg
Local aButtons	:= {}
Local aCabSB2	:= { '', 'Produto', 'Descrição', 'Ctrl Lote', 'Ctrl End/Série', 'Armazém', 'Saldo Físico', 'Saldo Lote', 'Saldo End/Série', 'Observação' }
Local aCabSB8	:= { '', 'Lote', 'Saldo Lote', 'Observação' }
Local aCabSBF	:= { '', 'Endereço', 'Núm Série', 'Lote', 'Saldo Endereço', 'Observação' }
Local bRefresh	:= {|| FWMsgRun(, {|oSay| CM040Refr( oSay, .F. ) }, cCadastro, 'Analisando Saldos...' ) }

Private cCadastro	:= 'Análise de Saldos Físico x Lote x Endereço'
Private oBrwSB2
Private aBrwSB2
Private oBrwSB8
Private aBrwSB8
Private aBrwSB8Full
Private oBrwSBF
Private aBrwSBF
Private aBrwSBFFull
Private oOk			:= LoadBitmap( GetResources(), 'br_verde' )
Private oNo			:= LoadBitmap( GetResources(), 'br_vermelho' )

aSize	:= MsAdvSize()
aAdd( aObjects, { 100, 060, .T., .F. } )
aAdd( aObjects, { 100, 100, .T., .T. } )
aAdd( aObjects, { 100, 100, .T., .T. } )
aInfo	:= { aSize[1], aSize[2], aSize[3], aSize[4], 2, 2 }
aPosObj	:= MsObjSize( aInfo, aObjects )

aAdd( aButtons, { 'PENDENTE', bRefresh, 'Refresh' } )

SetKEY( VK_F5, bRefresh )

Define MsDialog oDlg Title cCadastro From aSize[7],00 To aSize[6],aSize[5] Of oMainWnd Pixel

@ aPosObj[1,1]+04, aPosObj[1,2]+01 Say 'Esta rotina irá realizar uma análise dos Saldos Atuais Físico x Lote x Endereço, é recomendável que seja executada em modo exclusivo.' Pixel
@ aPosObj[1,1]+16, aPosObj[1,2]+01 Say 'Serão considerados todos os produtos que possuem saldo e controlam Lote e/ou Endereço/Número de Série.' Pixel
@ aPosObj[1,1]+30, aPosObj[1,2]+01 Say 'Ações disponíveis nesta versão:' Pixel
@ aPosObj[1,1]+42, aPosObj[1,2]+01 Say '- Ajuste do Saldo por Endereço a partir do Saldo por Lote (Núm Lote = Núm Série), não está previso o ajuste de movimentações.' Pixel

oBrwSB2	:= TWBrowse():New( aPosObj[2,1], aPosObj[2,2], aPosObj[2,4], aPosObj[2,3]-aPosObj[2,1],, aCabSB2,, oDlg,,,, {|| CM040Itens( oBrwSB2:nAt ) },,,,,,,,.F.,,.T.,,.F.,,, )

@ aPosObj[3,1]+5,aPosObj[3,4]/2-70 Button 'Ajustar pelo Lote'  Size 50,10 Action ( CM040AjSBF( oBrwSB2:nAt, oBrwSBF:nAt ) ) Of oDlg Pixel

oBrwSB8	:= TWBrowse():New( aPosObj[3,1]+20, aPosObj[3,2], aPosObj[3,4]/2-80, aPosObj[3,3]-aPosObj[3,1]-20,, aCabSB8,, oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,, )

oBrwSBF	:= TWBrowse():New( aPosObj[3,1]+20, aPosObj[3,4]/2-70, aPosObj[3,4]/2+73, aPosObj[3,3]-aPosObj[3,1]-20,, aCabSBF,, oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,, )

FWMsgRun(, {|oSay| CM040Refr( oSay, .F. ) }, cCadastro, 'Analisando Saldos...' )

Activate msDialog oDlg On Init EnchoiceBar( oDlg, { || oDlg:End() }, { || oDlg:End() },, aButtons,,, .F., .F., .F. )

RestKeys( aSvKeys )

Return


********************************************************************************
Static Function CM040Refr( oSay, lForce )

Local aArea		:= GetArea()
Local cPerg		:= 'CIRM040'
Local cQuery

//PutSX1( cGrupo, cOrdem, cTexto					, cMVPar	, cVariavel	, cTipoCamp	, nTamanho					, nDecimal	, cTipoPar	, cValid												, cF3		, cPicture	, cDef01		, cDef02		, cDef03	, cDef04	, cDef05	, cHelp	, cGrpSXG	)
u_PutSX1( cPerg	, "01"	, "Do Produto:"				, "mv_par01", "mv_ch1"	, "C"		, TamSX3('B1_COD')[1]		, 0			, "G"		, ""													, "SB1"		,  			,				,				,			,			,			,		, "030"		)
u_PutSX1( cPerg	, "02"	, "Até o Produto:"			, "mv_par02", "mv_ch2"	, "C"		, TamSX3('B1_COD')[1]		, 0			, "G"		, ""													, "SB1"		, 			,				,				,			,			,			,		, "030"		)
u_PutSX1( cPerg	, "03"	, "Do Grupo:"				, "mv_par03", "mv_ch3"	, "C"		, TamSX3('B1_GRUPO')[1]		, 0			, "G"		, ""													, "SBM"		, 			,				,				,			,			,			,		,			)
u_PutSX1( cPerg	, "04"	, "Até o Grupo:"			, "mv_par04", "mv_ch4"	, "C"		, TamSX3('B1_GRUPO')[1]		, 0			, "G"		, ""													, "SBM"		, 			,				,				,			,			,			,		,			)
u_PutSX1( cPerg	, "05"	, "Do Tipo:"				, "mv_par05", "mv_ch5"	, "C"		, TamSX3('B1_TIPO')[1]		, 0			, "G"		, ""													, "02"		, 			,				,				,			,			,			,		,			)
u_PutSX1( cPerg	, "06"	, "Até o Tipo:"				, "mv_par06", "mv_ch6"	, "C"		, TamSX3('B1_TIPO')[1]		, 0			, "G"		, ""													, "02"		, 			,				,				,			,			,			,		,			)
u_PutSX1( cPerg	, "07"	, "Do Armazém:"				, "mv_par07", "mv_ch7"	, "C"		, TamSX3('B1_LOCPAD')[1]	, 0			, "G"		, ""													, "NNR"		, 			,				,				,			,			,			,		, "024"		)
u_PutSX1( cPerg	, "08"	, "Até o Armazém:"			, "mv_par08", "mv_ch8"	, "C"		, TamSX3('B1_LOCPAD')[1]	, 0			, "G"		, ""													, "NNR"		, 			,				,				,			,			,			,		, "024"		)

If lForce
	
	Pergunte( cPerg, .F. )
	
ElseIf !Pergunte( cPerg, .T. )
	
	Return
EndIf

aBrwSB2   	:= {}

cQuery	:= "select B1_COD, B1_DESC, B1_RASTRO, B1_LOCALIZ, B2_LOCAL, sum( B2_QATU ) B2_QATU, sum( B8_SALDO ) B8_SALDO, sum( BF_QUANT ) BF_QUANT"
cQuery	+= " from ( "
cQuery	+= "select B1_COD, B1_DESC, B1_RASTRO, B1_LOCALIZ, B2_LOCAL, B2_QATU, 0 B8_SALDO, 0 BF_QUANT"
cQuery	+= " from " + RetSqlName( 'SB1' ) + " SB1, " + RetSqlName( 'SB2' ) + " SB2"
cQuery	+= " where B1_FILIAL = '" + xFilial( 'SB1' ) + "'"
cQuery	+= " and B1_COD between '" + mv_par01 + "' and '" + mv_par02 + "'"
cQuery	+= " and B1_GRUPO between '" + mv_par03 + "' and '" + mv_par04 + "'"
cQuery	+= " and B1_TIPO between '" + mv_par05 + "' and '" + mv_par06 + "'"
cQuery	+= " and ( B1_RASTRO in ( 'L', 'S' ) or B1_LOCALIZ = 'S' )"
cQuery	+= " and SB1.D_E_L_E_T_ = ' '"
cQuery	+= " and B2_FILIAL = '" + xFilial( 'SB2' ) + "'"
cQuery	+= " and B2_COD = B1_COD"
cQuery	+= " and B2_LOCAL between '" + mv_par07 + "' and '" + mv_par08 + "'"
//cQuery	+= " and B2_QATU > 0"
cQuery	+= " and SB2.D_E_L_E_T_ = ' '"
cQuery	+= " union all "
cQuery	+= "select B1_COD, B1_DESC, B1_RASTRO, B1_LOCALIZ, B8_LOCAL B2_LOCAL, 0 B2_QATU, sum( B8_SALDO ) B8_SALDO, 0 BF_QUANT"
cQuery	+= " from " + RetSqlName( 'SB1' ) + " SB1, " + RetSqlName( 'SB8' ) + " SB8"
cQuery	+= " where B1_FILIAL = '" + xFilial( 'SB1' ) + "'"
cQuery	+= " and B1_COD between '" + mv_par01 + "' and '" + mv_par02 + "'"
cQuery	+= " and B1_GRUPO between '" + mv_par03 + "' and '" + mv_par04 + "'"
cQuery	+= " and B1_TIPO between '" + mv_par05 + "' and '" + mv_par06 + "'"
cQuery	+= " and B1_RASTRO in ( 'L', 'S' )"
cQuery	+= " and SB1.D_E_L_E_T_ = ' '"
cQuery	+= " and B8_FILIAL = '" + xFilial( 'SB8' ) + "'"
cQuery	+= " and B8_PRODUTO = B1_COD"
cQuery	+= " and B8_LOCAL between '" + mv_par07 + "' and '" + mv_par08 + "'"
//cQuery	+= " and B8_SALDO > 0"
cQuery	+= " and SB8.D_E_L_E_T_ = ' '"
cQuery	+= " group by B1_COD, B1_DESC, B1_RASTRO, B1_LOCALIZ, B8_LOCAL"
cQuery	+= " union all "
cQuery	+= "select B1_COD, B1_DESC, B1_RASTRO, B1_LOCALIZ, BF_LOCAL B2_LOCAL, 0 B2_QATU, 0 B8_SALDO, sum( BF_QUANT ) BF_QUANT"
cQuery	+= " from " + RetSqlName( 'SB1' ) + " SB1, " + RetSqlName( 'SBF' ) + " SBF"
cQuery	+= " where B1_FILIAL = '" + xFilial( 'SB1' ) + "'"
cQuery	+= " and B1_COD between '" + mv_par01 + "' and '" + mv_par02 + "'"
cQuery	+= " and B1_GRUPO between '" + mv_par03 + "' and '" + mv_par04 + "'"
cQuery	+= " and B1_TIPO between '" + mv_par05 + "' and '" + mv_par06 + "'"
cQuery	+= " and B1_LOCALIZ = 'S'"
cQuery	+= " and SB1.D_E_L_E_T_ = ' '"
cQuery	+= " and BF_FILIAL = '" + xFilial( 'SBF' ) + "'"
cQuery	+= " and BF_PRODUTO = B1_COD"
cQuery	+= " and BF_LOCAL between '" + mv_par07 + "' and '" + mv_par08 + "'"
//cQuery	+= " and BF_QUANT > 0"
cQuery	+= " and SBF.D_E_L_E_T_ = ' '"
cQuery	+= " group by B1_COD, B1_DESC, B1_RASTRO, B1_LOCALIZ, BF_LOCAL"
cQuery	+= " union all "
cQuery	+= "select B1_COD, B1_DESC, B1_RASTRO, B1_LOCALIZ, DA_LOCAL B2_LOCAL, 0 B2_QATU, 0 B8_SALDO, sum( DA_SALDO ) BF_QUANT"
cQuery	+= " from " + RetSqlName( 'SB1' ) + " SB1, " + RetSqlName( 'SDA' ) + " SDA"
cQuery	+= " where B1_FILIAL = '" + xFilial( 'SB1' ) + "'"
cQuery	+= " and B1_COD between '" + mv_par01 + "' and '" + mv_par02 + "'"
cQuery	+= " and B1_GRUPO between '" + mv_par03 + "' and '" + mv_par04 + "'"
cQuery	+= " and B1_TIPO between '" + mv_par05 + "' and '" + mv_par06 + "'"
cQuery	+= " and B1_LOCALIZ = 'S'"
cQuery	+= " and SB1.D_E_L_E_T_ = ' '"
cQuery	+= " and DA_FILIAL = '" + xFilial( 'SDA' ) + "'"
cQuery	+= " and DA_PRODUTO = B1_COD"
cQuery	+= " and DA_LOCAL between '" + mv_par07 + "' and '" + mv_par08 + "'"
//cQuery	+= " and DA_SALDO > 0"
cQuery	+= " and SDA.D_E_L_E_T_ = ' '"
cQuery	+= " group by B1_COD, B1_DESC, B1_RASTRO, B1_LOCALIZ, DA_LOCAL"
cQuery	+= ") as TMP"
cQuery	+= " group by B1_COD, B1_DESC, B1_RASTRO, B1_LOCALIZ, B2_LOCAL"
cQuery	+= " order by B1_COD, B2_LOCAL"

dbUseArea( .t., 'TOPCONN', TCGenQry(,,cQuery), 'SB2TMP', .f., .t. )

//TCSetField( 'SD3TMP', 'D3_EMISSAO'	, 'D' )

While SB2TMP->( !Eof() )
	
	
	aAdd( aBrwSB2, {  .T.,;
					SB2TMP->B1_COD,;
					SB2TMP->B1_DESC,;
					SB2TMP->B1_RASTRO,;
					SB2TMP->B1_LOCALIZ,;
					SB2TMP->B2_LOCAL,;
					SB2TMP->B2_QATU,;
					SB2TMP->B8_SALDO,;
					SB2TMP->BF_QUANT,;
					''})
	
	If SB2TMP->B1_RASTRO $ 'LS' .and. aBrwSB2[ Len( aBrwSB2 ), 7 ] <> aBrwSB2[ Len( aBrwSB2 ), 8 ]
		
		aBrwSB2[ Len( aBrwSB2 ), 01 ]	:= .F.
		aBrwSB2[ Len( aBrwSB2 ), 10 ]	:= 'Divergência de Saldo por Lote'
	EndIf
	
	If SB2TMP->B1_LOCALIZ == 'S' .and. aBrwSB2[ Len( aBrwSB2 ), 7 ] <> aBrwSB2[ Len( aBrwSB2 ), 9 ]
		
		If aBrwSB2[ Len( aBrwSB2 ), 01 ]
			
			aBrwSB2[ Len( aBrwSB2 ), 01 ]	:= .F.
			aBrwSB2[ Len( aBrwSB2 ), 10 ]	:= 'Divergência de Saldo por Endereço/Núm Série'
		Else
			aBrwSB2[ Len( aBrwSB2 ), 10 ]	:= 'Divergência de Saldo por Lote e Endereço/Núm Série'
		EndIf
	EndIf
	
	SB2TMP->( dbSkip() )
End

SB2TMP->( dbCloseArea() )

If Empty( aBrwSB2 )
	
	aAdd( aBrwSB2, {  .F. , Space(15), Space(30), Space(10), Space(10), Space(10), 0, 0, 0, '' } )
EndIf

oSay:cCaption	:= ('Analisando Saldo por Lote')
ProcessMessages()

aBrwSB8Full		:= {}

cQuery	:= "select B8_PRODUTO, B8_LOCAL, B8_LOTECTL, B8_SALDO"
cQuery	+= " from " + RetSqlName( 'SB1' ) + " SB1, " + RetSqlName( 'SB8' ) + " SB8"
cQuery	+= " where B1_FILIAL = '" + xFilial( 'SB1' ) + "'"
cQuery	+= " and B1_COD between '" + mv_par01 + "' and '" + mv_par02 + "'"
cQuery	+= " and B1_GRUPO between '" + mv_par03 + "' and '" + mv_par04 + "'"
cQuery	+= " and B1_TIPO between '" + mv_par05 + "' and '" + mv_par06 + "'"
cQuery	+= " and B1_RASTRO in ( 'L', 'S' )"
cQuery	+= " and SB1.D_E_L_E_T_ = ' '"
cQuery	+= " and B8_FILIAL = '" + xFilial( 'SB8' ) + "'"
cQuery	+= " and B8_PRODUTO = B1_COD"
cQuery	+= " and B8_LOCAL between '" + mv_par07 + "' and '" + mv_par08 + "'"
cQuery	+= " and B8_SALDO <> 0"
cQuery	+= " and SB8.D_E_L_E_T_ = ' '"
cQuery	+= " order by B8_PRODUTO, B8_LOCAL, B8_LOTECTL"

dbUseArea( .t., 'TOPCONN', TCGenQry(,,cQuery), 'SB8TMP', .f., .t. )

//TCSetField( 'SD3TMP', 'D3_EMISSAO'	, 'D' )

While SB8TMP->( !Eof() )
	
	aAdd( aBrwSB8Full, { SB8TMP->B8_PRODUTO,;
						SB8TMP->B8_LOCAL,;
						SB8TMP->B8_LOTECTL,;
						SB8TMP->B8_SALDO,;
						''})
	
	SB8TMP->( dbSkip() )
End

SB8TMP->( dbCloseArea() )

oSay:cCaption := ('Analisando Saldo por Endereço')
ProcessMessages()

aBrwSBFFull		:= {}

cQuery	:= "select BF_PRODUTO, BF_LOCAL, BF_LOCALIZ, BF_NUMSERI, BF_LOTECTL, BF_QUANT"
cQuery	+= " from " + RetSqlName( 'SB1' ) + " SB1, " + RetSqlName( 'SBF' ) + " SBF"
cQuery	+= " where B1_FILIAL = '" + xFilial( 'SB1' ) + "'"
cQuery	+= " and B1_COD between '" + mv_par01 + "' and '" + mv_par02 + "'"
cQuery	+= " and B1_GRUPO between '" + mv_par03 + "' and '" + mv_par04 + "'"
cQuery	+= " and B1_TIPO between '" + mv_par05 + "' and '" + mv_par06 + "'"
cQuery	+= " and B1_LOCALIZ = 'S'"
cQuery	+= " and SB1.D_E_L_E_T_ = ' '"
cQuery	+= " and BF_FILIAL = '" + xFilial( 'SBF' ) + "'"
cQuery	+= " and BF_PRODUTO = B1_COD"
cQuery	+= " and BF_LOCAL between '" + mv_par07 + "' and '" + mv_par08 + "'"
cQuery	+= " and BF_QUANT <> 0"
cQuery	+= " and SBF.D_E_L_E_T_ = ' '"
cQuery	+= " union all "
cQuery	+= "select DA_PRODUTO BF_PRODUTO, DA_LOCAL BF_LOCAL, 'A ENDERECAR' BF_LOCALIZ, 'A ENDERECAR' BF_NUMSERI, DA_LOTECTL BF_LOTECTL, DA_SALDO BF_QUANT"
cQuery	+= " from " + RetSqlName( 'SB1' ) + " SB1, " + RetSqlName( 'SDA' ) + " SDA"
cQuery	+= " where B1_FILIAL = '" + xFilial( 'SB1' ) + "'"
cQuery	+= " and B1_COD between '" + mv_par01 + "' and '" + mv_par02 + "'"
cQuery	+= " and B1_GRUPO between '" + mv_par03 + "' and '" + mv_par04 + "'"
cQuery	+= " and B1_TIPO between '" + mv_par05 + "' and '" + mv_par06 + "'"
cQuery	+= " and B1_LOCALIZ = 'S'"
cQuery	+= " and SB1.D_E_L_E_T_ = ' '"
cQuery	+= " and DA_FILIAL = '" + xFilial( 'SDA' ) + "'"
cQuery	+= " and DA_PRODUTO = B1_COD"
cQuery	+= " and DA_LOCAL between '" + mv_par07 + "' and '" + mv_par08 + "'"
cQuery	+= " and DA_SALDO <> 0"
cQuery	+= " and SDA.D_E_L_E_T_ = ' '"
cQuery	+= " order by BF_PRODUTO, BF_LOCAL, BF_LOCALIZ, BF_NUMSERI, BF_LOTECTL"

dbUseArea( .t., 'TOPCONN', TCGenQry(,,cQuery), 'SBFTMP', .f., .t. )

//TCSetField( 'SD3TMP', 'D3_EMISSAO'	, 'D' )

While SBFTMP->( !Eof() )
	
	aAdd( aBrwSBFFull, { SBFTMP->BF_PRODUTO,;
						SBFTMP->BF_LOCAL,;
						SBFTMP->BF_LOCALIZ,;
						SBFTMP->BF_NUMSERI,;
						SBFTMP->BF_LOTECTL,;
						SBFTMP->BF_QUANT,;
						''})
	
	SBFTMP->( dbSkip() )
End

SBFTMP->( dbCloseArea() )

oBrwSB2:SetArray( aBrwSB2 )
oBrwSB2:bLine	:= {||{ If( aBrwSB2[ oBrwSB2:nAt, 01 ], oOk, oNo ),;
						aBrwSB2[ oBrwSB2:nAt, 02 ], ;
						aBrwSB2[ oBrwSB2:nAt, 03 ], ;
						aBrwSB2[ oBrwSB2:nAt, 04 ], ;
						aBrwSB2[ oBrwSB2:nAt, 05 ], ;
						aBrwSB2[ oBrwSB2:nAt, 06 ], ;
						Transform( aBrwSB2[ oBrwSB2:nAt, 07 ], "@E 999,999,999,999.99" ), ;
						Transform( aBrwSB2[ oBrwSB2:nAt, 08 ], "@E 999,999,999,999.99" ), ;
						Transform( aBrwSB2[ oBrwSB2:nAt, 09 ], "@E 999,999,999,999.99" ), ;
						aBrwSB2[ oBrwSB2:nAt, 10 ] }}

oBrwSB2:nAt		:= 1
oBrwSB2:Refresh()

CM040Itens( oBrwSB2:nAt )

RestArea( aArea )

Return

********************************************************************************
Static Function CM040Itens( nRowPos )

Local nI
Local nQtdTmp

CursorWait()

aBrwSB8   	:= {}
nQtdTmp		:= aBrwSB2[ nRowPos, 7 ]

For nI := 1 to Len( aBrwSB8Full )
	
	If aBrwSB8Full[ nI, 1 ] == aBrwSB2[ nRowPos, 2 ] .and. aBrwSB8Full[ nI, 2 ] == aBrwSB2[ nRowPos, 6 ]
		
		aAdd( aBrwSB8, { .T., aBrwSB8Full[ nI, 3 ], aBrwSB8Full[ nI, 4 ], '' } )
		
		nQtdTmp	-= aBrwSB8Full[ nI, 4 ]
	EndIf
Next nI

If aBrwSB2[ nRowPos, 4 ] $ 'L/S' .and. !Empty( nQtdTmp )
	
	aAdd( aBrwSB8, { .F., '??????????', nQtdTmp, 'Saldo Divergente' } )
	
ElseIf Empty( aBrwSB8 )
	
	aAdd( aBrwSB8, { .T., Space(10), 0, '' } )
EndIf

oBrwSB8:SetArray( aBrwSB8 )
oBrwSB8:bLine	:= {||{ If( aBrwSB8[ oBrwSB8:nAt, 01 ], oOk, oNo ),;
						aBrwSB8[ oBrwSB8:nAt, 02 ], ;
						Transform( aBrwSB8[ oBrwSB8:nAt, 03 ], "@E 999,999,999,999.99" ), ;
						aBrwSB8[ oBrwSB8:nAt, 04 ] }}

oBrwSB8:nAt		:= 1
oBrwSB8:Refresh()


aBrwSBF   	:= {}
nQtdTmp		:= aBrwSB2[ nRowPos, 7 ]

For nI := 1 to Len( aBrwSBFFull )
	
	If aBrwSBFFull[ nI, 1 ] == aBrwSB2[ nRowPos, 2 ] .and. aBrwSBFFull[ nI, 2 ] == aBrwSB2[ nRowPos, 6 ]
		
		aAdd( aBrwSBF, { .T., aBrwSBFFull[ nI, 3 ], aBrwSBFFull[ nI, 4 ], aBrwSBFFull[ nI, 5 ], aBrwSBFFull[ nI, 6 ], '' } )
		
		nQtdTmp	-= aBrwSBFFull[ nI, 6 ]
	EndIf
Next nI

If aBrwSB2[ nRowPos, 5 ] = 'S' .and. !Empty( nQtdTmp )
	
	aAdd( aBrwSBF, { .F., '??????????', '??????????', '??????????', nQtdTmp, 'Saldo Divergente' } )
	
ElseIf Empty( aBrwSBF )
	
	aAdd( aBrwSBF, { .T., Space(10), Space(10), Space(10), 0, '' } )
EndIf

oBrwSBF:SetArray( aBrwSBF )
oBrwSBF:bLine	:= {||{ If( aBrwSBF[ oBrwSBF:nAt, 01 ], oOk, oNo ),;
						aBrwSBF[ oBrwSBF:nAt, 02 ], ;
						aBrwSBF[ oBrwSBF:nAt, 03 ], ;
						aBrwSBF[ oBrwSBF:nAt, 04 ], ;
						Transform( aBrwSBF[ oBrwSBF:nAt, 05 ], "@E 999,999,999,999.99" ), ;
						aBrwSBF[ oBrwSBF:nAt, 06 ] }}

oBrwSBF:nAt		:= 1
oBrwSBF:Refresh()

CursorArrow()

Return

********************************************************************************
Static Function CM040AjSBF( nRowPosSB2, nRowPosSBF )

Local oDlg1
Local nI
Local cQuery
Local aEnder	:= {}
Local aButtons	:= {}
Local nOpcX
Local cNumSeq, cCounter

Private cCadastro	:= 'Ajuste Saldo Endereço/Núm Série pelo Lote'
Private cLocaliz
Private oEnder
Private oOk      	:= Loadbitmap( GetResources(), 'LBOK' )
Private oNo      	:= Loadbitmap( GetResources(), 'LBNO' )
Private nQtdTot		:= aBrwSBF[ nRowPosSBF, 05 ]
Private nQtdSel		:= 0

If aBrwSBF[ nRowPosSBF, 1 ]
	
	APMsgStop( 'Este item de Saldo por Endereço/Núm Série não possui divergência.', cCadastro )
	Return
EndIf

SBF->( dbSetOrder( 4 ) )	// BF_FILIAL+BF_PRODUTO+BF_NUMSERI

For nI := 1 to Len( aBrwSB8 )
	
	If aBrwSB8[ nI, 1 ] .and. !Empty( aBrwSB8[ nI, 2 ] ) .and. Left( aBrwSB8[ nI, 2 ], 3 ) <> '???' .and. aBrwSB8[ nI, 3 ] > 0
		
		cQuery	:= "select BF_PRODUTO, BF_LOCAL, BF_LOCALIZ, BF_NUMSERI, BF_LOTECTL, BF_QUANT"
		cQuery	+= " from " + RetSqlName( 'SBF' ) + " SBF"
		cQuery	+= " where BF_FILIAL = '" + xFilial( 'SBF' ) + "'"
		cQuery	+= " and BF_PRODUTO = '" + aBrwSB2[ nRowPosSB2, 2 ] + "'"
		cQuery	+= " and BF_NUMSERI = '" + aBrwSB8[ nI, 2 ] + "'"
		cQuery	+= " and BF_QUANT <> 0"
		cQuery	+= " and SBF.D_E_L_E_T_ = ' '"
		cQuery	+= " union all "
		cQuery	+= "select DA_PRODUTO BF_PRODUTO, DA_LOCAL BF_LOCAL, 'A ENDERECAR' BF_LOCALIZ, 'A ENDERECAR' BF_NUMSERI, DA_LOTECTL BF_LOTECTL, DA_SALDO BF_QUANT"
		cQuery	+= " from " + RetSqlName( 'SDA' ) + " SDA"
		cQuery	+= " where DA_FILIAL = '" + xFilial( 'SDA' ) + "'"
		cQuery	+= " and DA_PRODUTO = '" + aBrwSB2[ nRowPosSB2, 2 ] + "'"
		cQuery	+= " and DA_LOTECTL = '" + aBrwSB8[ nI, 2 ] + "'"
		cQuery	+= " and DA_SALDO <> 0"
		cQuery	+= " and SDA.D_E_L_E_T_ = ' '"
		
		dbUseArea( .t., 'TOPCONN', TCGenQry(,,cQuery), 'SBFTMP', .f., .t. )
				
		If SBFTMP->( EoF() )
			
			aAdd( aEnder, { .F., aBrwSB8[ nI, 2 ], '', aBrwSB8[ nI, 2 ], 1 } )
		EndIf
		
		SBFTMP->( dbCloseArea() )
	EndIf
	
Next nI

If Empty( aEnder )
	
	APMsgStop( 'Não foram localizados Lotes para serem utilizados no ajuste deste Saldo por Endereço/Núm Série.', cCadastro )
	Return
EndIf

SBE->( dbSetOrder( 1 ) )
SBE->( dbSeek( xFilial( 'SBE' ) + aBrwSB2[ nRowPosSB2, 6 ], .T. ) )

cLocaliz	:= SBE->BE_LOCALIZ

Define msDialog oDlg1 From 0,0 To 450,600 Title cCadastro Of oMainWnd Pixel

@ 040,008 Say 'Produto: ' Pixel Of oDlg1
@ 040,048 MsGet aBrwSB2[ nRowPosSB2, 2 ]	When .F.	Size 060,010 of oDlg1 Pixel

@ 040,128 Say 'Descrição: ' Pixel Of oDlg1
@ 040,168 MsGet aBrwSB2[ nRowPosSB2, 3 ]	When .F.	Size 130,010 of oDlg1 Pixel

@ 060,008 Say 'Armazém: ' Pixel Of oDlg1
@ 060,048 MsGet aBrwSB2[ nRowPosSB2, 6 ]	When .F.	Size 040,010 of oDlg1 Pixel

@ 060,128 Say 'Endereço: ' Pixel Of oDlg1
@ 060,168 MsGet cLocaliz	Size 060,010 of oDlg1 Pixel F3 'SBE' Valid ExistCpo( 'SBE', aBrwSB2[ nRowPosSB2, 6 ] + cLocaliz ) Picture PesqPict( 'SDB', 'DB_LOCALIZ' )

@ 080,05 ListBox oEnder ;
         Fields Header  '  ', 'Lote', 'Endereço' ,'Núm Série', 'Quantidade' ;
         Size 290,130 ;
         Pixel Of oDlg1 ;
         On dblClick( aEnder:=CM040AltL( oEnder:nAt, aEnder ), oEnder:Refresh(), oQtdTot:Refresh(), oQtdSel:Refresh() ) 

oEnder:SetArray( aEnder )

oEnder:bLine := { || { If( aEnder[ oEnder:nAt, 1 ], oOk, oNo ), ;
						aEnder[ oEnder:nAt, 2 ], ;
						aEnder[ oEnder:nAt, 3 ], ;
						aEnder[ oEnder:nAt, 4 ], ;
						Transform( aEnder[ oEnder:nAt, 5 ], "@E 999,999,999.99" )}}

oEnder:nAt	:= 1
oEnder:Refresh()

@ 215,008 Say 'Qtd Divergente: ' Pixel Of oDlg1
@ 215,100 Say oQtdTot Var nQtdTot Picture "@E 9,999.99" Pixel Of oDlg1

@ 215,188 Say 'Qtd Selecionada: ' Pixel Of oDlg1
@ 215,280 Say oQtdSel Var nQtdSel Picture "@E 9,999.99" Pixel Of oDlg1

Activate msDialog oDlg1 Centered On Init EnchoiceBar( oDlg1, { || nOpcX := 1, oDlg1:End() }, { || nOpcX := 0, oDlg1:End() },, aButtons,,, .F., .F., .F.)

If nOpcX == 1 .and. nQtdSel > 0
	
	CursorWait()
	
	cNumSeq		:= ProxNum()
	cCounter	:= StrZero( 0, TamSx3('DB_ITEM')[1] )
	
	For nI := 1 to Len( aEnder )
		
		If aEnder[ nI, 1 ]
			
			cCounter := Soma1(cCounter)
			
			CriaSDB( aBrwSB2[ nRowPosSB2, 2 ],;			// Produto
					 aBrwSB2[ nRowPosSB2, 6 ],;			// Armazem
					 aEnder[ nI, 5 ],;					// Quantidade
					 aEnder[ nI, 3 ],;					// Localizacao
					 aEnder[ nI, 4 ],;					// Numero de Serie
					 '',;								// Doc
					 '',;								// Serie
					 '',;								// Cliente / Fornecedor
					 '',;								// Loja
					 '',;								// Tipo NF
					 'ACE',;							// Origem do Movimento
					 dDataBase,;						// Data
					 aEnder[ nI, 2 ],;					// Lote
					 '',;								// Sub-Lote
					 cNumSeq,;							// Numero Sequencial
					 '499',;							// Tipo do Movimento
					 'M',;								// Tipo do Movimento (Distribuicao/Movimento)
					 cCounter,;							// Item
					 .F.,;								// Flag que indica se e' mov. estorno
					 0,;								// Quantidade empenhado
					 ConvUM( aBrwSB2[ nRowPosSB2, 2 ], aEnder[ nI, 5 ], 0 , 2 ) )	// Quantidade segunda UM
			
			GravaSBF( 'SDB' )
			
		EndIf
		
	Next nI
	
	CursorArrow()
	
	FWMsgRun(, {|oSay| CM040Refr( oSay, .T. ) }, cCadastro, 'Atualizando Saldos...' )
	
EndIf

Return

********************************************************************************
Static Function CM040AltL( nIt, aArray )

If !aArray[ nIt, 1 ]
	
	If nQtdSel >= nQtdTot
		
		APMsgStop( 'A quantidade selecionada não pode ser maior que a quantidade divergente.', cCadastro )
	Else
		aArray[ nIt, 1 ] := .T.
		aArray[ nIt, 3 ] := cLocaliz
		
		nQtdSel	+= aArray[ nIt, 5 ]
	EndIf
Else
	aArray[ nIt, 1 ] := .F.
	aArray[ nIt, 3 ] := ''
	
	nQtdSel	-= aArray[ nIt, 5 ]
EndIf

oEnder:Refresh()

Return( aArray )
