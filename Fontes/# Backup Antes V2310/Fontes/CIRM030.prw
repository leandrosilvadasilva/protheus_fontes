#include 'rwmake.ch'
/*___________________________________________________________________________
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
||-------------------------------------------------------------------------||
|| FunÁ„o: CIRM030      || Autor: CI Result             || Data: 19/04/19  ||
||-------------------------------------------------------------------------||
|| DescriÁ„o: Inclus„o de Pedido de Venda a partir do Saldo Atual          ||
||-------------------------------------------------------------------------||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
ØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØ*/
User Function CIRM030()

Local nOpcA		:= 0
Local cPerg		:= 'CIRM030'

Private cCadastro	:= 'Pedido de Venda a partir do Saldo Atual'

//PutSX1( cGrupo, cOrdem, cTexto					, cMVPar	, cVariavel	, cTipoCamp	, nTamanho					, nDecimal	, cTipoPar	, cValid												, cF3		, cPicture	, cDef01		, cDef02		, cDef03	, cDef04	, cDef05	, cHelp	, cGrpSXG	)
u_PutSX1( cPerg	, "01"	, "Do Produto:"				, "mv_par01", "mv_ch1"	, "C"		, TamSX3('B2_COD')[1]		, 0			, "G"		, ""													, "SB1"		,  			,				,				,			,			,			,		, "030"		)
u_PutSX1( cPerg	, "02"	, "AtÈ o Produto:"			, "mv_par02", "mv_ch2"	, "C"		, TamSX3('B2_COD')[1]		, 0			, "G"		, ""													, "SB1"		, 			,				,				,			,			,			,		, "030"		)
u_PutSX1( cPerg	, "03"	, "Do ArmazÈm:"				, "mv_par03", "mv_ch3"	, "C"		, TamSX3('B2_LOCAL')[1]		, 0			, "G"		, ""													, "NNR"		, 			,				,				,			,			,			,		, "024"		)
u_PutSX1( cPerg	, "04"	, "AtÈ o ArmazÈm:"			, "mv_par04", "mv_ch4"	, "C"		, TamSX3('B2_LOCAL')[1]		, 0			, "G"		, ""													, "NNR"		, 			,				,				,			,			,			,		, "024"		)
u_PutSX1( cPerg	, "05"	, "Cliente:"				, "mv_par05", "mv_ch5"	, "C"		, TamSX3('C5_CLIENTE')[1]	, 0			, "G"		, "NaoVazio().and.ExistCpo('SA1',mv_par05,1)"			, "SA1"		, 			,				,				,			,			,			,		, "001"		)
u_PutSX1( cPerg	, "06"	, "Loja:"					, "mv_par06", "mv_ch6"	, "C"		, TamSX3('C5_LOJACLI')[1]	, 0			, "G"		, "NaoVazio().and.ExistCpo('SA1',mv_par05+mv_par06,1)"	,			, 			,				,				,			,			,			,		, "002"		)
u_PutSX1( cPerg	, "07"	, "Cond Pagto:"				, "mv_par07", "mv_ch7"	, "C"		,  3						, 0			, "G"		, "NaoVazio().and.ExistCpo('SE4',mv_par07,1)"			, "SE4"		, 			,				,				,			,			,			,		, 			)
u_PutSX1( cPerg	, "08"	, "TES:"					, "mv_par08", "mv_ch8"	, "C"		,  3						, 0			, "G"		, "NaoVazio().and.ExistCpo('SF4',mv_par08,1)"			, "SF4"		, 			,				,				,			,			,			,		, 			)

Pergunte( cPerg, .f. )

FormBatch( cCadastro, {'Esta rotina ir· inclur um Pedido de Venda a partir do Saldo Atual dos Produtos','conforme os par‚metros informados.' }, ;
	{{ 5, .T., {|o| Pergunte( cPerg, .t. ) }}, ;
	{ 1, .T., {|o| nOpcA:=1, If( gpconfOK(), FechaBatch(), nOpca:=0 ) } }, ;
	{ 2, .T., {|o| o:oWnd:End() }}} )

If ( nOpcA == 1 )
	
	FWMsgRun(, {|oSay| CM030Proc( oSay ) }, cCadastro, 'Selecionando Dados...' )
EndIf

Return

********************************************************************************
Static Function CM030Proc( oSay )

Local aArea		:= GetArea()
Local cQuery
Local nItens	:= 0
Local aAutoCab		:= {}
Local aAutoItens	:= {}
Local aItem			:= {}
Local cItem			:= '00'

Private lMsHelpAuto 	:= .T.	// Habilita a captura das mensagens de erro
Private lMsErroAuto 	:= .F.	// Indica de se houve erro n„o fatal durante a execuÁ„o

aAutoCab	:= {{ 'C5_TIPO'		, 'N'				, Nil }, ;
				{ 'C5_CLIENTE'	, mv_par05			, Nil }, ;
				{ 'C5_LOJACLI'	, mv_par06			, Nil }, ;
				{ 'C5_CONDPAG'	, mv_par07			, Nil }, ;
				{ 'C5_NATUREZ'	, '811101'	 		, Nil }, ;
				{ 'C5_TPFRETE'	, 'S'				, Nil }}


cQuery	:= "select B2_FILIAL, B2_LOCAL, B2_COD, SB2.R_E_C_N_O_ RECSB2"
cQuery	+= " from " + RetSqlName( 'SB2' ) + " SB2"
cQuery	+= " where B2_FILIAL = '" + xFilial( 'SB2' ) + "'"
cQuery	+= " and B2_COD between '" + mv_par01 + "' and '" + mv_par02 + "'"
cQuery	+= " and B2_LOCAL between '" + mv_par03 + "' and '" + mv_par04 + "'"
cQuery	+= " and B2_QATU > 0"
cQuery	+= " and SB2.D_E_L_E_T_ = ' '"
cQuery	+= " order by B2_FILIAL, B2_LOCAL, B2_COD"

dbUseArea( .t., 'TOPCONN', TCGenQry(,,cQuery), 'SB2TMP', .f., .t. )

//TCSetField( 'SD3TMP', 'D3_EMISSAO'	, 'D' )

SB2->( dbSetOrder( 1 ) )

While SB2TMP->( !Eof() )
	
	SB2->( dbGoTo( SB2TMP->RECSB2 ) )
	
	nItens	++
	
	aItem	:= {{ 'C6_ITEM'		, cItem := Soma1( cItem, 2 )					, Nil }, ;
				{ 'C6_PRODUTO'	, SB2->B2_COD									, Nil }, ;
				{ 'C6_LOCAL'	, SB2->B2_LOCAL									, Nil }, ;
				{ 'C6_TES'		, mv_par08										, Nil }, ;
				{ 'C6_QTDVEN'	, SB2->B2_QATU									, Nil }, ;
				{ 'C6_QTDLIB'	, SB2->B2_QATU									, Nil }, ;
				{ 'C6_PRCVEN'	, If( !Empty( SB2->B2_CM1 ), SB2->B2_CM1, 1 )	, Nil }}

	
	aAdd( aAutoItens, aItem )
	
	SB2TMP->( dbSkip() )
End

SB2TMP->( dbCloseArea() )

oSay:cCaption := ('Incluindo Pedido de Venda')
ProcessMessages()

lMsErroAuto := .f.

MsExecAuto( {|x,y,z| Mata410( x, y, z ) }, aAutoCab, aAutoItens, 3 )

If lMsErroAuto
	
	MostraErro()
Else
	ApMsgInfo ( 'IncluÌdo o Pedido ' + SC5->C5_NUM + ' com ' + AllTrim( Transform( nItens, '@E 999,999' ) ) + If( nItens > 1, ' itens.', ' item.' ) )
EndIf

RestArea( aArea )

Return
