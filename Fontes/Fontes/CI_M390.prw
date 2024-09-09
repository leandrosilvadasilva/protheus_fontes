#define CRLF Chr(10) + Chr(13)
#Include 'Totvs.ch'
#include 'topconn.ch'

/*/{Protheus.doc}
Função para Geração do Arquivo Orçamento Contábil Previsto x Realizado
@author Jeferson Silva
@since 18/11/2019
@version 1.0
@return Nil,
@example
u_CI_M390()
/*/
User Function CI_M390()

Local aArea   	:= GetArea()
Local aInfo     := {}
Local cTitulo 	:= "Geração do Arquivo Orçamento Contábil Previsto x Realizado"
Local bProcess  := {||}
Local oProcess  := Nil

Private cPerg   := PadR("CI_M390",10)

//PutSX1( cGrupo, cOrdem, cTexto					, cMVPar	, cVariavel	, cTipoCamp	, nTamanho					, nDecimal	, cTipoPar	, cValid			, cF3		, cPicture	, cDef01		, cDef02		 , cDef03	, cDef04	, cDef05	, cHelp	, cGrpSXG	)
u_PutSX1( cPerg	, "01"	, "Orçamento de:" 	    	, "mv_par01", "mv_ch1"	, "C"		, TamSX3('CV1_ORCMTO')[1]	, 0			, "G"		, 					,"CV1"		, 			,				,				 ,			,			,			,		, 			)
u_PutSX1( cPerg	, "02"	, "Orçamento ate :"			, "mv_par02", "mv_ch2"	, "C"		, TamSX3('CV1_ORCMTO')[1]	, 0			, "G"		, 					,"CV1"		, 			,				,				 ,			,			,			,		, 			)
u_PutSX1( cPerg	, "03"	, "Revisão de:"				, "mv_par03", "mv_ch3"	, "C"		, TamSX3('CV1_REVISA')[1]	, 0			, "G"		, 					,     		, 			,				,				 ,			,			,			,		, 			)
u_PutSX1( cPerg	, "04"	, "Revisão ate:"			, "mv_par04", "mv_ch4"	, "C"		, TamSX3('CV1_REVISA')[1]	, 0			, "G"		, 					,     		, 			,				,				 ,			,			,			,		, 			)
u_PutSX1( cPerg	, "05"	, "Tipo de Realizado:"		, "mv_par05", "mv_ch5"	, "N"		, 1							, 0			, "C"		,   				,			, 			,"Contï¿½bil"     ,"Contï¿½bil + NFE",			,			,			,		,  			)
u_PutSX1( cPerg	, "06"	, "Local de Destino:"		, "mv_par06", "mv_ch6"	, "C"		, 99						, 0			, "G"		, "U_OpenFile('D')"	, 			, 			,				,				 ,			,			,			,		, 			)
u_PutSX1( cPerg	, "07"	, "Da Filial:"				, "mv_par07", "mv_ch7"	, "C"		, TamSX3('CV1_FILIAL')[1]	, 0			, "G"		, 		        	, "XM0"		, 			,				,				,			,			,			,		, 	     	)
u_PutSX1( cPerg	, "08"	, "Até a Filial:"			, "mv_par08", "mv_ch8"	, "C"		, TamSX3('CV1_FILIAL')[1]	, 0			, "G"		, 	        		, "XM0"		, 			,				,				,			,			,			,		,   		)

Pergunte(cPerg,.F.)

aAdd( aInfo, { "Cancelar", 	{ |oPanelCenter| oPanelCenter:oWnd:End() },	"CANCEL"  })

bProcess := { |oProcess| M390Proc( oProcess ) }

cDescRot := "Esta rotina tem o objetivo de gerar um arquivo CSV com as informações do Orçamento Contábil Previsto x Realizado."

oProcess := TNewProcess():New( "CI_M390", cTitulo, bProcess, cDescRot, cPerg, aInfo,.F., 5,'Processamento', .T.,.T.)

RestArea(aArea)
Return Nil

/*/{Protheus.doc}
Funcção para Processamento da Geraçãoo do Arquivo Orçamento Contábil Previsto x Realizado
@author Jeferson Silva
@since 18/11/2019
@version 1.0
@return Nil,
@example
M390Proc()
/*/
Static Function M390Proc( oProcess )

Local cMsg  := ""
Local cArq
Local nHdl
Local cText
Local nRecCV1  := 0
Local cFiliais := "'  '"


cArq	:= AllTrim( MV_PAR06 ) + If( Right( AllTrim( MV_PAR06 ), 1 ) <> '\', '\', '' ) + 'Orcamento_Previsto_Realizado' + '.csv'

nHdl := fCreate( cArq )

If fError() <> 0
	cMsg := 'Erro ao criar o arquivo ' + cArq + '. Código do erro: ' + Str( fError() )
	oProcess:SaveLog(cMsg)
	Return
EndIf


SM0->( dbSetOrder( 1 ) )
SM0->( dbSeek( cEmpAnt + mv_par07, .T. ) )
While SM0->( !EOF() ) .and. SM0->M0_CODIGO == cEmpAnt .and. SM0->M0_CODFIL <= mv_par08
	
	// monta string para otimizar performance da query
	cFiliais	+= ",'" + SM0->M0_CODFIL + "'"
	
	SM0->( dbSkip() )
End
SM0->( dbSeek( cEmpAnt + cFilAnt, .f. ) )

cCount	:= "select count(*) NRECCV1"
cSelect	:= "select * "
cFrom	:= " from " + RetSqlName( 'CV1' ) + " CV1"
cWhere	:= " where CV1_FILIAL in (" + cFiliais + ")"
cWhere  += " and CV1_ORCMTO between '"+mv_par01+"' and '"+mv_par02+"'"
cWhere  += " and CV1_REVISA between '"+mv_par03+"' and '"+mv_par04+"'"
cWhere	+= " and CV1.D_E_L_E_T_ = ' '"
cOrder	:= " order by CV1_FILIAL, CV1_ORCMTO, CV1_CALEND ,CV1_MOEDA ,CV1_REVISA ,CV1_SEQUEN ,CV1_PERIOD"

dbUseArea( .t., 'TOPCONN', TCGenQry(,,cCount+cFrom+cWhere), 'CV1TEMP', .f., .t. )
nRecCV1	:= CV1TEMP->NRECCV1
CV1TEMP->( dbCloseArea() )
oProcess:SetRegua1(nRecCV1)

dbUseArea( .t., 'TOPCONN', TCGenQry(,,cSelect+cFrom+cWhere+cOrder), 'CV1TEMP', .f., .t. )
TCSetField( 'CV1TEMP', 'CV1_DTINI'	, 'D',  8, 0 )
TCSetField( 'CV1TEMP', 'CV1_DTFIM'	, 'D',  8, 0 )

// Cabeçalho:
cText	:= "Filial do Sistema" + ';'
cText	+= "Codigo do Orcamento" + ';'
cText	+= "Descricao do Orcamento" + ';'
cText	+= "Calendario" + ';'
cText	+= "Moeda" + ';'
cText	+= "Revisao" + ';'
cText	+= "Conta Inicial" + ';'
cText	+= "Desc. Conta Inicial" + ';'
cText	+= "Conta Final" + ';'
cText	+= "Desc. Conta Final" + ';'
cText	+= "Centro de Custo Inicial" + ';'
cText	+= "Centro de Custo Final" + ';'
cText	+= "Item Inicial" + ';'
cText	+= "Item Final" + ';'
cText	+= "Classe de Valor Inicial" + ';'
cText	+= "Classe de Valor  Final" + ';'
cText	+= "Periodo Inicial" + ';'
cText	+= "Periodo Final" + ';'
cText	+= "Valor Orcado" + ';'
cText	+= "Valor Contabilizado" + ';'
cText	+= "Valor NFE nao Contabilizadas" + ';'
cText	+= "Valor Total Realizado" + ';'
cText	+= "Variacao em %" + ';'
cText	+= "Variacao em Real"

fWrite( nHdl , cText + CRLF )

CV1TEMP->( dbGoTop() )

While CV1TEMP->( !Eof() )
	
	// Movimentos
	cText	:= AllTrim( CV1TEMP->CV1_FILIAL ) + ';'
	cText	+= AllTrim( CV1TEMP->CV1_ORCMTO ) + ';'
	cText	+= AllTrim( CV1TEMP->CV1_DESCRI ) + ';'
	cText	+= AllTrim( CV1TEMP->CV1_CALEND ) + ';'
	cText	+= AllTrim( CV1TEMP->CV1_MOEDA ) + ';'
	cText	+= AllTrim( CV1TEMP->CV1_REVISA ) + ';'
	cText	+= AllTrim( CV1TEMP->CV1_CT1INI ) + ';'
	cText	+= AllTrim( Posicione("CT1", 1, xFilial("CT1") + CV1TEMP->CV1_CT1INI, "CT1_DESC01") ) + ';'
	cText	+= AllTrim( CV1TEMP->CV1_CT1FIM ) + ';'
	cText	+= AllTrim( Posicione("CT1", 1, xFilial("CT1") + CV1TEMP->CV1_CT1FIM, "CT1_DESC01") ) + ';'
	cText	+= AllTrim( CV1TEMP->CV1_CTTINI ) + ';'
	cText	+= AllTrim( CV1TEMP->CV1_CTTFIM ) + ';'
	cText	+= AllTrim( CV1TEMP->CV1_CTDINI ) + ';'
	cText	+= AllTrim( CV1TEMP->CV1_CTDFIM ) + ';'
	cText	+= AllTrim( CV1TEMP->CV1_CTHINI ) + ';'
	cText	+= AllTrim( CV1TEMP->CV1_CTHFIM ) + ';'
	cText	+= DtoC( CV1TEMP->CV1_DTINI  ) + ';'
	cText	+= DtoC( CV1TEMP->CV1_DTFIM  ) + ';'
	
	nValorOrcado         := CV1TEMP->CV1_VALOR
	nVlrContabilizado    := M390SldCtb(CV1TEMP->CV1_FILIAL,CV1TEMP->CV1_DTINI,CV1TEMP->CV1_DTFIM,CV1TEMP->CV1_CT1INI,CV1TEMP->CV1_CT1FIM,CV1TEMP->CV1_CTTINI,CV1TEMP->CV1_CTTFIM,CV1TEMP->CV1_CTDINI,CV1TEMP->CV1_CTDFIM,CV1TEMP->CV1_CTHINI,CV1TEMP->CV1_CTHFIM,'1')
	nNfeNaocontabilizado := If(mv_par05=1,0,M390SldSd1(CV1TEMP->CV1_FILIAL,CV1TEMP->CV1_DTINI,CV1TEMP->CV1_DTFIM,CV1TEMP->CV1_CT1INI,CV1TEMP->CV1_CT1FIM,CV1TEMP->CV1_CTTINI,CV1TEMP->CV1_CTTFIM,CV1TEMP->CV1_CTDINI,CV1TEMP->CV1_CTDFIM,CV1TEMP->CV1_CTHINI,CV1TEMP->CV1_CTHFIM,'1'))
	nValorTotalRealizado := nVlrContabilizado + nNfeNaocontabilizado
	nVariacaPercentual   := (nValorTotalRealizado/nValorOrcado) * 100
	nVariacaoReal        := nValorTotalRealizado - nValorOrcado
	
	cText	+= AllTrim( Str ( nValorOrcado ,15,0 ) ) + ';'
	cText	+= AllTrim( Str ( nVlrContabilizado ,15,0 ) ) + ';'
	cText	+= AllTrim( Str ( nNfeNaocontabilizado ,15,0 ) ) + ';'
	cText	+= AllTrim( Str ( nValorTotalRealizado ,15,0 ) ) + ';'
	cText	+= AllTrim( Str ( nVariacaPercentual ,15,0 ) ) + ';'
	cText	+= AllTrim( Str ( nVariacaoReal ,15,0 ) )
	
	fWrite( nHdl , cText + CRLF )
	
	oProcess:IncRegua1('Processando...')
	
	CV1TEMP->( dbSkip() )
End

CV1TEMP->( dbCloseArea() )

fClose( nHdl )

ApMsgInfo ( 'Arquivo ' + AllTrim( cArq ) + ' gerado com sucesso!' )

Return

/*/{Protheus.doc}
Função para Geração do Arquivo Orçamento Contábil Previsto x Realizado
@author Jeferson Silva
@since 18/11/2019
@version 1.0
@return Nil,
@example
u_M390SldCtb()
/*/
Static Function M390SldCtb(cCV1Fil,dDtIni,dDtfim,CT1INI,CT1FIM,CTTINI,CTTFIM,CTDINI,CTDFIM,CTHINI,CTHFIM,cTpSaldo)

Local aArea := GetArea()
If Empty(CTTINI)
	CTTINI := ''
	CTTFIM := 'zzzzzzz'
Endif
If Empty(CTDINI)
	CTDINI := ''
	CTDFIM := 'zzzzzzz'
Endif
If Empty(CTHINI)
	CTHINI := ''
	CTHFIM := 'zzzzzzz'
Endif

//cQuery	:= " select CT2_DC,CT2_DEBITO,CT2_CREDIT,IIF(CT2_DC<>'2' and CT2_DEBITO between '"+CT1INI+"' and '"+CT1FIM+"',SUM(CT2_VALOR),0) VALDEB,IIF(CT2_DC<>'1' and CT2_CREDIT between '"+CT1INI+"' and '"+CT1FIM+"',SUM(CT2_VALOR),0) VALCRE"
cQuery	:= " select CT2_DC,CT2_DEBITO,CT2_CREDIT,"

cQuery	+= "									IIF(CT2_DC<>'2' and (CT2_DEBITO between '"+CT1INI+"' and '"+CT1FIM+"')"
cQuery	+= " 													 and (CT2_CCD between '"+CTTINI+"' and '"+CTTFIM+"')"
cQuery	+= " 													 and (CT2_ITEMD between '"+CTDINI+"' and '"+CTDFIM+"')"
cQuery	+= " 													 and (CT2_CLVLDB between '"+CTHINI+"' and '"+CTHFIM+"')"
cQuery	+= ",SUM(CT2_VALOR),0) VALDEB,"

cQuery	+= "									 IIF(CT2_DC<>'1' and (CT2_CREDIT between '"+CT1INI+"' and '"+CT1FIM+"')"
cQuery	+= " 													 and (CT2_CCC between '"+CTTINI+"' and '"+CTTFIM+"')"
cQuery	+= " 													 and (CT2_ITEMC between '"+CTDINI+"' and '"+CTDFIM+"')"
cQuery	+= " 													 and (CT2_CLVLCR between '"+CTHINI+"' and '"+CTHFIM+"')"
cQuery	+= ",SUM(CT2_VALOR),0) VALCRE"

cQuery	+= " from " + RetSqlName( 'CT2' ) + " CT2"
cQuery	+= " where CT2_FILIAL = '" + cCV1Fil + "'"
cQuery  += " and CT2_DATA between '"+Dtos(dDtIni)+"' and '"+Dtos(dDtfim)+"' "
cQuery  += " and ((CT2_DEBITO between '"+CT1INI+"' and '"+CT1FIM+"') or (CT2_CREDIT between '"+CT1INI+"' and '"+CT1FIM+"'))"
cQuery  += " and ((CT2_CCD between '"+CTTINI+"' and '"+CTTFIM+"') or (CT2_CCC between '"+CTTINI+"' and '"+CTTFIM+"'))"
cQuery  += " and ((CT2_ITEMD between '"+CTDINI+"' and '"+CTDFIM+"') or (CT2_ITEMC between '"+CTDINI+"' and '"+CTDFIM+"'))"
cQuery  += " and ((CT2_CLVLDB between '"+CTHINI+"' and '"+CTHFIM+"') or (CT2_CLVLCR between '"+CTHINI+"' and '"+CTHFIM+"'))"
cQuery	+= " and CT2_TPSALD = '"+cTpSaldo+"'"
cQuery	+= " and CT2_SBLOTE <> 'ZER' "
cQuery	+= " and CT2_DTLP = '' "
cQuery	+= " and CT2.D_E_L_E_T_ = ' '"
cQuery	+= " group by CT2_DC,CT2_DEBITO,CT2_CREDIT,CT2_CCD,CT2_ITEMD,CT2_CLVLDB,CT2_CCC,CT2_ITEMC,CT2_CLVLCR"

nValor := 0

dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery),'CT2TMP',.F.,.T. )
CT2TMP->( dbGoTop() )
While CT2TMP->( !Eof() )
	nValor	+= (CT2TMP->VALDEB - CT2TMP->VALCRE)
	CT2TMP->( dbSkip() )
End

CT2TMP->( dbCloseArea() )

RestArea( aArea )
Return(nValor)


Static Function M390SldSD1(cCV1Fil,dDtIni,dDtfim,CT1INI,CT1FIM,CTTINI,CTTFIM,CTDINI,CTDFIM,CTHINI,CTHFIM,cTpSaldo)

Local aArea := GetArea()

cQuery	:= " select D1_CONTA, SUM(D1_TOTAL) VALDEB"
cQuery	+= " from " + RetSqlName( 'SD1' ) + " SD1, " + RetSqlName( 'SF1' ) + " SF1"
cQuery	+= " where D1_FILIAL = '" + cCV1Fil + "'"
cQuery	+= " and D1_FILIAL = F1_FILIAL and D1_DOC = F1_DOC and D1_SERIE = F1_SERIE and D1_FORNECE = F1_FORNECE and D1_LOJA = F1_LOJA and SF1.D_E_L_E_T_ = ' '"
cQuery  += " and D1_DTDIGIT between '"+Dtos(dDtIni)+"' and '"+Dtos(dDtfim)+"' "
cQuery  += " and D1_CONTA between '"+CT1INI+"' and '"+CT1FIM+"'"
If !Empty(CTTINI)
	cQuery  += " and D1_CC between '"+CTTINI+"' and '"+CTTFIM+"'"
Endif
If !Empty(CTDINI)
	cQuery  += " and D1_ITEMCTA between '"+CTDINI+"' and '"+CTDFIM+"'"
Endif
If !Empty(CTHINI)
	cQuery  += " and D1_CLVL between '"+CTHINI+"' and '"+CTHFIM+"'"
Endif
cQuery	+= " and F1_DTLANC = ' '"
cQuery	+= " and SD1.D_E_L_E_T_ = ' '"
cQuery	+= " group by D1_CONTA"

nValor := 0

dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery),'SD1TMP',.F.,.T. )
SD1TMP->( dbGoTop() )
While SD1TMP->( !Eof() )
	nValor	+= (SD1TMP->VALDEB)
	SD1TMP->( dbSkip() )
End

SD1TMP->( dbCloseArea() )

RestArea( aArea )
Return(nValor)

