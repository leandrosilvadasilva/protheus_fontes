#Include 'Totvs.ch'
#include 'topconn.ch'

/*/{Protheus.doc}
Funcao para Geracao do Data Mart contabil
@author Jeferson Silva
@since 02/01/2020
@version 1.0
@return Nil,
@example
u_CI_M150()
/*/
User Function CI_M150(aParam)
Local aArea   	:= GetArea()
Local aInfo     := {}
Local cTitulo 	:= "Geração do Data Mart Contábil."
Local bProcess  := {||}
Local oProcess  := Nil
Local lAuto		:= IsBlind()
Local aTabelas	:= {"CT1","CT2","CTT","CTS","CTH","CTD","CV1"}

Private cPerg   := PadR("CI_M150",10)

If lAuto// Chamada via Schedule
	cMsg := "CI_M150 - Geração do Data Mart Contábil"
	ConOut(cMsg)
	BatchProcess(cTitulo, cTitulo,"CI_M150", { || M150Proc( oProcess,lAuto ) }, { || .F. }  ) 
Else
	//Cria a pergunta de entrada do MarkBrowser
	u_PutSX1( cPerg	, "01"	, "Período de:" 			, "mv_par01", "mv_ch1"	, "D"		, TamSX3('CT2_DATA')[1]		, 0			, "G"		, ""													, ""		, 			,				,				,			,			,			,		, ""		)
	u_PutSX1( cPerg	, "02"	, "Período até:"			, "mv_par02", "mv_ch2"	, "D"		, TamSX3('CT2_DATA')[1]		, 0			, "G"		, ""													, ""		, 			,				,				,			,			,			,		, ""		)
	u_PutSX1( cPerg	, "03"	, "Conta Contábil de:"		, "mv_par03", "mv_ch3"	, "C"		, TamSX3('CT2_DEBITO')[1]	, 0			, "G"		, ""													, "CT1"		,  			,				,				,			,			,			,		, ""		)
	u_PutSX1( cPerg	, "04"	, "Conta Contábil até:"		, "mv_par04", "mv_ch4"	, "C"		, TamSX3('CT2_DEBITO')[1]	, 0			, "G"		, ""													, "CT1"		, 			,				,				,			,			,			,		, ""		)

	/*
	u_PutSX1( cPerg	, "01"	, "N? Pedido de:"			, "mv_par01", "mv_ch1"	, "C"		, TamSX3('C7_NUM')[1]		, 0			, "G"		, ""													, ""		,  			,				,				,			,			,			,		, ""		)
	u_PutSX1( cPerg	, "02"	, "N? Pedido atE:"			, "mv_par02", "mv_ch2"	, "C"		, TamSX3('C7_NUM')[1]		, 0			, "G"		, ""													, ""		, 			,				,				,			,			,			,		, ""		)
	u_PutSX1( cPerg	, "03"	, "Fornecedor de:"			, "mv_par03", "mv_ch3"	, "C"		, TamSX3('A2_COD')[1]		, 0			, "G"		, ""													, "SA2"		, 			,				,				,			,			,			,		, ""		)
	u_PutSX1( cPerg	, "04"	, "Loja de:"	   	    	, "mv_par04", "mv_ch4"	, "C"		, TamSX3('A2_LOJA')[1]  	, 0			, "G"		, ""													,			, 			,				,				,			,			,			,		, ""		)
	u_PutSX1( cPerg	, "05"	, "Fornecedor atE:"			, "mv_par05", "mv_ch5"	, "C"		, TamSX3('A2_COD')[1]		, 0			, "G"		, ""													, "SA2"		, 			,				,				,			,			,			,		, ""		)
	u_PutSX1( cPerg	, "06"	, "Loja atE:"	   	    	, "mv_par06", "mv_ch6"	, "C"		, TamSX3('A2_LOJA')[1] 		, 0			, "G"		, ""													,			, 			,				,				,			,			,			,		, ""		)
	u_PutSX1( cPerg	, "07"	, "Emissao de:" 			, "mv_par07", "mv_ch7"	, "D"		, TamSX3('C7_EMISSAO')[1]	, 0			, "G"		, ""													, ""		, 			,				,				,			,			,			,		, ""		)
	u_PutSX1( cPerg	, "08"	, "Emissao atE:"			, "mv_par08", "mv_ch8"	, "D"		, TamSX3('C7_EMISSAO')[1]	, 0			, "G"		, ""													, ""		, 			,				,				,			,			,			,		, ""		)
	u_PutSX1( cPerg	, "09"	, "Listar PC:"				, "mv_par09", "mv_ch9"	, "C"		, 1							, 0			, "C"		, ""													,			, 			,"Em Aberto"	,"Todos"		,			,			,			,		, ""		)
	u_PutSX1( cPerg	, "10"	, "Relatorio LOG"			, "mv_par10", "mv_cha"	, "C"		, 1							, 0			, "C"		, ""													,			, 			,"Todos"		,"Sem Especificacao"		,			,			,			,		, ""		)
	*/
	Pergunte(cPerg,.F.)

	aAdd( aInfo, { "Cancelar", 	{ |oPanelCenter| oPanelCenter:oWnd:End() },	"CANCEL"  })

	bProcess := { |oProcess| M150Proc( oProcess ) }

	cDescRot := "Esta rotina tem como objetivo gerar o Data Mart Contábil."

	oProcess := TNewProcess():New( "CI_M150", cTitulo, bProcess, cDescRot, cPerg, aInfo,.F., 5,'Processamento', .T.)
Endif

RestArea(aArea)
Return Nil

/*/{Protheus.doc}
Funcao para o processamento do Data Mart Contabil
@author Jeferson Silva
@since 02/01/2020
@version 1.0
@return Nil,
@example
M150Proc()
/*/
Static Function M150Proc( oProcess, lAuto )

//Local aLog  := {}
//Local cLog  := ""
Local cMsg  := ""

Local cFiliais		:= "'  '"
Local cDataExtracao	:= DtoC( Date() ) + " - " + Time()

cMsg := "CI_M150 - Processando o Data Mart Contábil..."

If !lAuto
	oProcess:SetRegua1(7)
	oProcess:IncRegua1('Processando o Data Mart Contábil...')
	oProcess:SetRegua2(7) // Numero de tableas a serem processadas
Else
	ConOut(cMsg)
Endif

TCSQLExec( "DROP TABLE fContabilRealizado" ) // Reestruturacao

If !TCCanOpen( "fContabilRealizado" )
	
	cScript := " create table fContabilRealizado("
	cScript += " Filial varchar("+Str(TamSX3('CT2_FILIAL')[1])+"),"
	cScript += " FilialOrigem varchar("+Str(TamSX3('CT2_FILORI')[1])+"),"
	cScript += " Data varchar(10),"
	cScript += " Lote varchar("+Str(TamSX3('CT2_LOTE')[1])+"),"
	cScript += " SubLote varchar("+Str(TamSX3('CT2_SBLOTE')[1])+"),"
	cScript += " Documento varchar("+Str(TamSX3('CT2_DOC')[1])+"),"
	cScript += " Linha varchar("+Str(TamSX3('CT2_LINHA')[1])+"),"
	cScript += " Historico varchar("+Str(TamSX3('CT2_HIST')[1])+"),"
	cScript += " Conta varchar("+Str(TamSX3('CT2_DEBITO')[1])+"),"
	cScript += " CentroCusto varchar("+Str(TamSX3('CT2_CCD')[1])+"),"
	cScript += " ClasseValor varchar("+Str(TamSX3('CT2_CLVLDB')[1])+"),"
	cScript += " ItemConta varchar("+Str(TamSX3('CT2_ITEMD')[1])+"),"
	cScript += " ValorDebito float(8),"
	cScript += " ValorCredito float(8),"
	cScript += " Chvdes varchar(200),"
	cScript += " PeriodoInicialExtracao varchar(10),"
	cScript += " PeriodoFinalExtracao varchar(10),"
	cScript += " DataExtracao varchar(35)"
	cScript += "  )"
	
	TCSQLExec( cScript )
	
EndIf

TCSQLExec( "DROP TABLE fOrcamentoContabil" ) // Reestruturacao

If !TCCanOpen( "fOrcamentoContabil" )
	
	cScript := " create table fOrcamentoContabil("
	cScript += " Filial varchar("+Str(TamSX3('CV1_FILIAL')[1])+"),"
	cScript += " CodigoOrcamento varchar("+Str(TamSX3('CV1_ORCMTO')[1])+"),"
	cScript += " DescricaoOrcamento varchar("+Str(TamSX3('CV1_DESCRI')[1])+"),"
	cScript += " Calendario varchar("+Str(TamSX3('CV1_CALEND')[1])+"),"
	cScript += " Moeda varchar("+Str(TamSX3('CV1_MOEDA')[1])+"),"
	cScript += " Revisao varchar("+Str(TamSX3('CV1_REVISA')[1])+"),"
	cScript += " Conta varchar("+Str(TamSX3('CV1_CT1INI')[1])+"),"
	cScript += " CentroCusto varchar("+Str(TamSX3('CV1_CTTINI')[1])+"),"
	cScript += " ItemConta varchar("+Str(TamSX3('CV1_CTDINI')[1])+"),"
	cScript += " ClasseValor varchar("+Str(TamSX3('CV1_CTHINI')[1])+"),"
	cScript += " Periodo varchar("+Str(TamSX3('CV1_PERIOD')[1])+"),"
	cScript += " Data varchar(10),"
	cScript += " ValorOrcado float(8),"
 	cScript += " PeriodoInicialExtracao varchar(10),"
	cScript += " PeriodoFinalExtracao varchar(10),"
	cScript += " DataExtracao varchar(35)"
	cScript += "  )"
	
	TCSQLExec( cScript )
	
EndIf	

TCSQLExec( "DROP TABLE dVisoesGerenciais" ) // Reestruturacao

If !TCCanOpen( "dVisoesGerenciais" )
	
	cScript := " create table dVisoesGerenciais("
	cScript += " Filial varchar("+Str(TamSX3('CTS_FILIAL')[1])+"),"
	cScript += " CodigoVisao varchar("+Str(TamSX3('CTS_CODPLA')[1])+"),"
	cScript += " NomeVisao varchar("+Str(TamSX3('CTS_NOME')[1])+"),"
	cScript += " Ordem varchar("+Str(TamSX3('CTS_ORDEM')[1])+"),"
	cScript += " EntidadeGerencial varchar("+Str(TamSX3('CTS_CONTAG')[1])+"),"
	cScript += " EntidadeSuperior varchar("+Str(TamSX3('CTS_CTASUP')[1])+"),"
	cScript += " DescricaoGerencial varchar("+Str(TamSX3('CTS_DESCCG')[1])+"),"
	cScript += " ClasseEntidade varchar("+Str(TamSX3('CTS_CLASSE')[1])+"),"
	cScript += " Identificador varchar("+Str(TamSX3('CTS_IDENT')[1])+"),"
	cScript += " Linha varchar("+Str(TamSX3('CTS_LINHA')[1])+"),"
	cScript += " Conta varchar("+Str(TamSX3('CTS_CT1INI')[1])+"),"
	cScript += " CentroCusto varchar("+Str(TamSX3('CTS_CTTINI')[1])+"),"
	cScript += " ItemConta varchar("+Str(TamSX3('CTS_CTDINI')[1])+"),"
	cScript += " ClasseValor varchar("+Str(TamSX3('CTS_CTHINI')[1])+"),"
	cScript += " PeriodoInicialExtracao varchar(10),"
	cScript += " PeriodoFinalExtracao varchar(10),"
	cScript += " DataExtracao varchar(35)"
	cScript += "  )"
	
	TCSQLExec( cScript )
	
EndIf	

TCSQLExec( "DROP TABLE dPlanoContas" ) // Reestruturacao

If !TCCanOpen( "dPlanoContas" )
	
	cScript := " create table dPlanoContas("
	cScript += " Filial varchar("+Str(TamSX3('CT1_FILIAL')[1])+"),"
	cScript += " Conta varchar("+Str(TamSX3('CT1_CONTA')[1])+"),"
	cScript += " Descricao varchar("+Str(TamSX3('CT1_DESC01')[1])+"),"
	cScript += " Classe varchar("+Str(TamSX3('CT1_CLASSE')[1])+"),"
	cScript += " ContaSuperior varchar("+Str(TamSX3('CT1_CTASUP')[1])+"),"
	cScript += " PeriodoInicialExtracao varchar(10),"
	cScript += " PeriodoFinalExtracao varchar(10),"
	cScript += " DataExtracao varchar(35)"
	cScript += "  )"
	
	TCSQLExec( cScript )
	
EndIf	

TCSQLExec( "DROP TABLE dCentroCusto" ) // Reestruturacao

If !TCCanOpen( "dCentroCusto" )
	
	cScript := " create table dCentroCusto("
	cScript += " Filial varchar("+Str(TamSX3('CTT_FILIAL')[1])+"),"
	cScript += " CentroCusto varchar("+Str(TamSX3('CTT_CUSTO')[1])+"),"
	cScript += " Descricao varchar("+Str(TamSX3('CTT_DESC01')[1])+"),"
	cScript += " Classe varchar("+Str(TamSX3('CTT_CLASSE')[1])+"),"
	cScript += " CentroCustoSuperior varchar("+Str(TamSX3('CTT_CCSUP')[1])+"),"
	cScript += " PeriodoInicialExtracao varchar(10),"
	cScript += " PeriodoFinalExtracao varchar(10),"
	cScript += " DataExtracao varchar(35)"
	cScript += "  )"
	
	TCSQLExec( cScript )
	
EndIf	

TCSQLExec( "DROP TABLE dItemContabil" ) // Reestruturacao

If !TCCanOpen( "dItemContabil" )
	
	cScript := " create table dItemContabil("
	cScript += " Filial varchar("+Str(TamSX3('CTD_FILIAL')[1])+"),"
	cScript += " ItemContabil varchar("+Str(TamSX3('CTD_ITEM')[1])+"),"
	cScript += " Descricao varchar("+Str(TamSX3('CTD_DESC01')[1])+"),"
	cScript += " Classe varchar("+Str(TamSX3('CTD_CLASSE')[1])+"),"
	cScript += " ItemContabilSuperior varchar("+Str(TamSX3('CTD_ITSUP')[1])+"),"
	cScript += " PeriodoInicialExtracao varchar(10),"
	cScript += " PeriodoFinalExtracao varchar(10),"
	cScript += " DataExtracao varchar(35)"
	cScript += "  )"
	
	TCSQLExec( cScript )
	
EndIf	

TCSQLExec( "DROP TABLE dClasseValor" ) // Reestruturacao

If !TCCanOpen( "dClasseValor" )
	
	cScript := " create table dClasseValor("
	cScript += " Filial varchar("+Str(TamSX3('CTH_FILIAL')[1])+"),"
	cScript += " ClasseValor varchar("+Str(TamSX3('CTH_CLVL')[1])+"),"
	cScript += " Descricao varchar("+Str(TamSX3('CTH_DESC01')[1])+"),"
	cScript += " Classe varchar("+Str(TamSX3('CTH_CLASSE')[1])+"),"
	cScript += " ClasseValorSuperior varchar("+Str(TamSX3('CTH_CLSUP')[1])+"),"
	cScript += " PeriodoInicialExtracao varchar(10),"
	cScript += " PeriodoFinalExtracao varchar(10),"
	cScript += " DataExtracao varchar(35)"
	cScript += "  )"
	
	TCSQLExec( cScript )
	
EndIf	

TCSQLExec( "DROP TABLE fSaldosContasMes" ) // Reestruturacao

If !TCCanOpen( "fSaldosContasMes" )
	cScript := " create table  fSaldosContasMes("
	cScript += " Filial        varchar("+Str(TamSX3('CQ0_FILIAL')[1])+"),"
	cScript += " Data          varchar(10),"        //CQ0_DATA
	cScript += " Conta         varchar("+Str(TamSX3('CQ0_CONTA')[1])+"),"
	cScript += " Moeda         varchar("+Str(TamSX3('CQ0_MOEDA')[1])+"),"
	cScript += " TipoSaldo     varchar("+Str(TamSX3('CQ0_TPSALD')[1])+"),"
	cScript += " SldoLPerdas   varchar("+Str(TamSX3('CQ0_LP')[1])+"),"
	cScript += " Status        varchar("+Str(TamSX3('CQ0_STATUS')[1])+"),"
	cScript += " SldBase       varchar("+Str(TamSX3('CQ0_SLBASE')[1])+"),"
	cScript += " ValorDebito   float(8),"          //CQ0_DEBITO   
	cScript += " ValorCredito  float(8),"          //CQ0_CREDIT
	cScript += " DataApuracao  varchar(10),"       //CQ0_DTLP
	cScript += " PeriodoInicialExtracao varchar(10),"
	cScript += " PeriodoFinalExtracao varchar(10),"
	cScript += " DataExtracao varchar(35)"
	cScript += "  )"
	
	TCSQLExec( cScript )
	
EndIf

TCSQLExec( "DROP TABLE fPoderTerceiros" ) // Reestruturacao

If !TCCanOpen( "fPoderTerceiros" )
	cScript := " create table  fPoderTerceiros("
	cScript += " Filial        varchar("+Str(TamSX3('B6_FILIAL')[1])+"),"
	cScript += " CliFor        varchar("+Str(TamSX3('B6_CLIFOR')[1])+"),"
	cScript += " Loja          varchar("+Str(TamSX3('B6_LOJA')[1])+"),"
	cScript += " Produto       varchar("+Str(TamSX3('B6_PRODUTO')[1])+"),"
	cScript += " Local         varchar("+Str(TamSX3('B6_LOCAL')[1])+"),"
	cScript += " DocOriginal   varchar("+Str(TamSX3('B6_DOC')[1])+"),"
	cScript += " Serie         varchar("+Str(TamSX3('B6_SERIE')[1])+"),"
	cScript += " DtEmissao     varchar("+Str(TamSX3('B6_EMISSAO')[1])+"),"
	cScript += " Quantidade    float(8),"          //B6_QUANT   
	cScript += " PrecoUnit     float(8),"          //B6_PRUNIT
	cScript += " TES           varchar(10),"       //B6_TES
	cScript += " Tipo          varchar(10),"       //B6_TIPO
	cScript += " Custo1        float(8),"          //B6_CUSTO1
	cScript += " Custo2        float(8),"          //B6_CUSTO1
	cScript += " Custo3        float(8),"          //B6_CUSTO1
	cScript += " Custo4        float(8),"          //B6_CUSTO1
	cScript += " Custo5        float(8),"          //B6_CUSTO5
	cScript += " UnidMedida    varchar("+Str(TamSX3('B6_UM')[1])+"),"
	cScript += " SeqIndent     varchar("+Str(TamSX3('B6_IDENT')[1])+"),"
	cScript += " TipCliFor     varchar("+Str(TamSX3('B6_TPCF')[1])+"),"
	cScript += " Saldo         float(8),"          //B6_SALDO
	cScript += " PoderTerceiro varchar("+Str(TamSX3('B6_PODER3')[1])+"),"
	cScript += " AtuEstoque    varchar("+Str(TamSX3('B6_ESTOQUE')[1])+"),"
	cScript += " CodVendedor   varchar("+Str(TamSX3('A3_COD')[1])+"),"
	cScript += " NomeVendedor  varchar("+Str(TamSX3('A3_NOME')[1])+"),"
	cScript += " Lote          varchar("+Str(TamSX3('D2_LOTECTL')[1])+"),"
	cScript += " ValidadeLote  varchar(10),"       //D2_DTVALID
	cScript += " DtProced      varchar(10),"       //C5_DPROCED
	cScript += " Paciente      varchar("+Str(TamSX3('C5_PACIENT')[1])+"),"
	cScript += " PeriodoInicialExtracao varchar(10),"
	cScript += " PeriodoFinalExtracao   varchar(10),"
	cScript += " DataExtracao           varchar(35)"
	cScript += "  )"
	
	TCSQLExec( cScript )
	
EndIf

TCSQLExec( "DROP TABLE fInventario" ) // Reestruturacao

If !TCCanOpen( "fInventario" )
	cScript := " create table  fInventario("
	cScript += " Filial        varchar("+Str(TamSX3('ZA3_FILIAL')[1])+"),"
	cScript += " Codigo        varchar("+Str(TamSX3('ZA3_COD')[1])+"),"  
	cScript += " Tipo          varchar("+Str(TamSX3('B1_TIPO')[1])+"),"  
	cScript += " Grupo         varchar("+Str(TamSX3('B1_GRUPO')[1])+"),"  
	cScript += " Marca         varchar("+Str(TamSX3('B1_MARCA')[1])+"),"  
	cScript += " Documento     varchar("+Str(TamSX3('ZA3_DOC')[1])+"),"  
	cScript += " Quantidade    float(8),"          //ZA3_QUANT
	cScript += " Data          varchar(10),"       //ZA3_DATA  
	cScript += " Lote          varchar("+Str(TamSX3('ZA3_LOTECT')[1])+"),"
	cScript += " NumSerie      varchar("+Str(TamSX3('ZA3_NUMSER')[1])+"),"
	cScript += " Endereco      varchar("+Str(TamSX3('ZA3_LOCALI')[1])+"),"
	cScript += " DtValidade    varchar(10),"       //ZA3_DTVALI
	cScript += " FornClien     varchar("+Str(TamSX3('ZA3_FORNEC')[1])+"),"
	cScript += " Loja          varchar("+Str(TamSX3('ZA3_LOJA')[1])+")," 
	cScript += " Vendedor      varchar("+Str(TamSX3('ZA3_VENDED')[1])+"),"
	cScript += " Longitude     varchar("+Str(TamSX3('ZA3_LONG')[1])+"),"
	cScript += " Latitude      varchar("+Str(TamSX3('ZA3_LATI')[1])+"),"
	cScript += " Identificador varchar("+Str(TamSX3('ZA3_IDINV')[1])+"),"
	//cScript += " ZA3_ID        varchar("+Str(TamSX3('ZA3.R_E_C_N_O_')[1])+"),"
	cScript += " PeriodoInicialExtracao varchar(10),"
	cScript += " PeriodoFinalExtracao   varchar(10),"
	cScript += " DataExtracao           varchar(35)"
	cScript += "  )"
	
	TCSQLExec( cScript )
	
EndIf

TCSQLExec( "DROP TABLE fMatrizReposicao" ) // Reestruturacao

If !TCCanOpen( "fMatrizReposicao" )
	cScript := " create table  fMatrizReposicao("
	cScript += " Filial        varchar("+Str(TamSX3('ZA5_FILIAL')[1])+"),"
	cScript += " Cliente       varchar("+Str(TamSX3('ZA5_CLI')[1])+"),"  
	cScript += " Loja          varchar("+Str(TamSX3('ZA5_LOJA')[1])+"),"
	cScript += " NomeCliente   varchar("+Str(TamSX3('ZA5_CLINOM')[1])+"),"
	cScript += " QtdePrevista  float(8),"           //ZA5_QTDPRV
	cScript += " QtdeAtual     float(8),"           //ZA5_QTDATU
	cScript += " QtdeReposicao float(8),"           //ZA5_QTDREP
	cScript += " CodVendedor   varchar("+Str(TamSX3('ZA5_CODVEN')[1])+"),"
	cScript += " NomeVendedor  varchar("+Str(TamSX3('ZA5_NOMVEN')[1])+"),"
	cScript += " TotCusto      varchar("+Str(TamSX3('ZA5_TOTCUS')[1])+"),"
	cScript += " TotVenda      float(8),"           //ZA5_TOTVEN
	cScript += " CodProduto    varchar("+Str(TamSX3('ZA5_CODPRO')[1])+"),"
	cScript += " NomeProduto   varchar("+Str(TamSX3('ZA5_NOMPRO')[1])+"),"
	cScript += " Auditoria     varchar("+Str(TamSX3('ZA5_AUDITO')[1])+"),"
	cScript += " FonteOrigem   varchar("+Str(TamSX3('ZA5_FONTE')[1])+"),"
	cScript += " PeriodoInicialExtracao varchar(10),"
	cScript += " PeriodoFinalExtracao   varchar(10),"
	cScript += " DataExtracao           varchar(35)"
	cScript += "  )"
	
	TCSQLExec( cScript )
	
EndIf

If !lAuto
	Pergunte( cPerg, .F. )
Endif

SM0->( dbSeek( cEmpAnt, .t. ) )
While SM0->( !Eof() ) .and. SM0->M0_CODIGO == cEmpAnt
	cFiliais	+= ",'" + SM0->M0_CODFIL + "'"
	SM0->( dbSkip() )
End
SM0->( dbSeek( cEmpAnt + cFilAnt, .f. ) )

cMsg := "CI_M150 - Início do processamento do Data Mart Contábil..."

If !lAuto
	oProcess:IncRegua1(cMsg)
	oProcess:SaveLog(cMsg)
Else
	ConOut(cMsg)
Endif

//--------------------------------------------------------------
//-- Query para geracao da tabela fContabilRealizado
//--------------------------------------------------------------

cMsg := "CI_M150 - 'Processando tabela dos Lançamentos Contábeis...'"

If !lAuto
	oProcess:IncRegua2(cMsg)   
Else
	ConOut(cMsg)
Endif

TCSQLExec( "Delete From fContabilRealizado" )

DbSelectArea('CT1')
DbSetOrder(1)
DbGotop()
DbSeek( xFilial('CT1') + mv_par03 ,.T.) // Filial+Conta
While !Eof() .And. CT1_FILIAL = xFilial('CT1') .And. CT1_CONTA <= mv_par04
	
	If CT1->CT1_CLASSE <> '2' 
		DbSkip()
		Loop
	Endif

	// Query para inserir dados de (1=débito ou 2=crédito) e o crédito da 3=partida dobrada

	cScript := " Insert Into fContabilRealizado (Filial, FilialOrigem, Data, Lote, SubLote, Documento, Linha, Historico, Conta,  CentroCusto, ClasseValor, ItemConta, ValorDebito, ValorCredito, Chvdes, PeriodoInicialExtracao, PeriodoFinalExtracao, DataExtracao)"
	
	cQuery := " Select Distinct "
	cQuery += " CT2_FILIAL Filial,"
	cQuery += " CT2_FILORI Filialorigem,"                               
	cQuery += " Substring(CT2_DATA,7,2)+'/'+Substring(CT2_DATA,5,2)+'/'+Substring(CT2_DATA,1,4) Data,"
	cQuery += " CT2_LOTE Lote,"
	cQuery += " CT2_SBLOTE Sublote,"
	cQuery += " CT2_DOC Documento,"
	cQuery += " CT2_LINHA Linha,"
	cQuery += " CT2_HIST Historico,"
	cQuery += " '"+CT1->CT1_CONTA+"' Conta,"
	cQuery += " IIF(CT2_DC='1' and CT2_DEBITO = '"+CT1->CT1_CONTA+"',CT2_CCD,CT2_CCC) Centrocusto,"
	cQuery += " IIF(CT2_DC='1' and CT2_DEBITO = '"+CT1->CT1_CONTA+"',CT2_CLVLDB,CT2_CLVLCR) Classevalor,"
	cQuery += " IIF(CT2_DC='1' and CT2_DEBITO = '"+CT1->CT1_CONTA+"',CT2_ITEMD,CT2_ITEMC) Itemconta,"
	cQuery += " IIF(CT2_DC='1' and CT2_DEBITO = '"+CT1->CT1_CONTA+"',Round(CT2_VALOR,2),0) Valordebito,"
	cQuery += " IIF(CT2_DC<>'1' and CT2_CREDIT = '"+CT1->CT1_CONTA+"',Round(CT2_VALOR,2),0) Valorcredito,"
	cQuery += " Concat('CT2',IIF(CT2_DEBITO = '"+CT1->CT1_CONTA+"','D','C'),CT2.R_E_C_N_O_,'"+CT1->CT1_CONTA+"') Chvdes, "
	cQuery += " '"+Dtoc(mv_par01)+"' PeriodoInicialExtracao,"
	cQuery += " '"+Dtoc(mv_par02)+"' PeriodoFinalExtracao,"
	cQuery += " '"+cDataExtracao+"' DataExtracao"
	cQuery += " From "+RetSQLName("CT2")+" CT2"
	//cQuery += " Left Join "+RetSQLName("CV3")+" CV3"
	//cQuery += "  on CV3_FILIAL = CT2_FILIAL and CV3_RECDES = CT2.R_E_C_N_O_ and CV3_RECDES <> '' and CV3.D_E_L_E_T_ = ''"
	cQuery += " Where (CT2_DEBITO = '"+CT1->CT1_CONTA+"' or CT2_CREDIT = '"+CT1->CT1_CONTA+"')"
	cQuery += " and CT2_FILIAL  IN (" + cFiliais + ")"
	cQuery += " and CT2_TPSALD = '1'"
	cQuery += " and CT2_DATA Between '"+Dtos(mv_par01)+"' and '"+Dtos(mv_par02)+"'"
	cQuery += " and CT2.D_E_L_E_T_ = ''"
	cQuery += " and CT2_SBLOTE <> 'ZER' "
	cQuery += " and ((CT2_DTLP <> '' and Substring(CT2_CREDIT,1,1) < '3')  "   // 16/06/21 (Marlovani) incluir movimentos de fechamento no Ativo/Passivo
//	cQuery += "   or (CT2_DTLP <> '' and Substring(CT2_DEBITO,1,1) < '3')  "   // 16/06/21 (Marlovani) incluir movimentos de fechamento no Ativo/Passivo
 	cQuery += "   or (CT2_DTLP  = '' ) ) " 
//	cQuery += " and CT2_DTLP = '' "              

	Memowrite("QryfContabilRealizado_1.txt",cQuery)
	TCSQLExec(cScript+cQuery)

	// Query para inserir dados de de débito da 3=partida dobrada

	cScript := " Insert Into fContabilRealizado (Filial, FilialOrigem, Data, Lote, SubLote, Documento, Linha, Historico, Conta,  CentroCusto, ClasseValor, ItemConta, ValorDebito, ValorCredito, Chvdes, PeriodoInicialExtracao, PeriodoFinalExtracao, DataExtracao)"
	
	cQuery := " Select Distinct "
	cQuery += " CT2_FILIAL Filial,"
	cQuery += " CT2_FILORI Filialorigem,"                               
	cQuery += " Substring(CT2_DATA,7,2)+'/'+Substring(CT2_DATA,5,2)+'/'+Substring(CT2_DATA,1,4) Data,"
	cQuery += " CT2_LOTE Lote,"
	cQuery += " CT2_SBLOTE Sublote,"
	cQuery += " CT2_DOC Documento,"
	cQuery += " CT2_LINHA Linha,"
	cQuery += " CT2_HIST Historico,"
	cQuery += " '"+CT1->CT1_CONTA+"' Conta,"
	cQuery += " CT2_CCD Centrocusto,"
	cQuery += " CT2_CLVLDB Classevalor,"
	cQuery += " CT2_ITEMD Itemconta,"
	cQuery += " Round(CT2_VALOR,2) Valordebito,"
	cQuery += " 0 Valorcredito,"
	cQuery += " Concat('CT2','D',CT2.R_E_C_N_O_,'"+CT1->CT1_CONTA+"') Chvdes, "
	cQuery += " '"+Dtoc(mv_par01)+"' PeriodoInicialExtracao,"
	cQuery += " '"+Dtoc(mv_par02)+"' PeriodoFinalExtracao,"
	cQuery += " '"+cDataExtracao+"' DataExtracao"
	cQuery += " From "+RetSQLName("CT2")+" CT2"
	cQuery += " Where CT2_DEBITO = '"+CT1->CT1_CONTA+"' 
	cQuery += " and CT2_FILIAL  IN (" + cFiliais + ")"
	cQuery += " and CT2_DC = '3'"
	cQuery += " and CT2_TPSALD = '1'"
	cQuery += " and CT2_DATA Between '"+Dtos(mv_par01)+"' and '"+Dtos(mv_par02)+"'"
	cQuery += " and CT2.D_E_L_E_T_ = ''"
	cQuery += " and CT2_SBLOTE <> 'ZER' "
//	cQuery += " and ((CT2_DTLP <> '' and Substring(CT2_CREDIT,1,1) < '3')  "   // 16/06/21 (Marlovani) incluir movimentos de fechamento no Ativo/Passivo
	cQuery += " and ((CT2_DTLP <> '' and Substring(CT2_DEBITO,1,1) < '3')  "   // 16/06/21 (Marlovani) incluir movimentos de fechamento no Ativo/Passivo
 	cQuery += "   or (CT2_DTLP  = '' ) ) " 
//	cQuery += " and CT2_DTLP = '' "

	Memowrite("QryfContabilRealizado_2.txt",cQuery)
	TCSQLExec(cScript+cQuery)

	CT1->(DbSkip())
End

//--------------------------------------------------------------
//-- Query para geracao do tabela fOrcamentoContabil
//--------------------------------------------------------------
cMsg := "CI_M150 - 'Processando tabela dos Orçamentos Contábeis...'"

If !lAuto
	oProcess:IncRegua2(cMsg)   
Else
	ConOut(cMsg)
Endif

TCSQLExec( "DELETE FROM fOrcamentoContabil"  )

cScript := " Insert Into fOrcamentoContabil (Filial, CodigoOrcamento, DescricaoOrcamento, Calendario, Moeda, Revisao,  Conta,  CentroCusto, ItemConta, ClasseValor , Periodo, Data, ValorOrcado, PeriodoInicialExtracao, PeriodoFinalExtracao, DataExtracao)"
cQuery := " Select Distinct "
cQuery += " CV1_FILIAL Filial,"
cQuery += " CV1_ORCMTO CodigoOrcamento,"
cQuery += " CV1_DESCRI DescricaoOrcamento,"
cQuery += " CV1_CALEND Calendario,"
cQuery += " CV1_MOEDA Moeda,"
cQuery += " CV1_REVISA Revisao,"
cQuery += " CV1_CT1INI Conta,"
cQuery += " CV1_CTTINI Centrocusto,"
cQuery += " CV1_CTDINI Itemconta,"
cQuery += " CV1_CTHINI Classevalor,"
cQuery += " CV1_PERIOD Periodo,"
cQuery += " Substring(CV1_DTINI,7,2)+'/'+Substring(CV1_DTINI,5,2)+'/'+Substring(CV1_DTINI,1,4) Data,"
cQuery += " Round(CV1_VALOR,2) ValorOrcado,"
cQuery += " '"+Dtoc(mv_par01)+"' PeriodoInicialExtracao,"
cQuery += " '"+Dtoc(mv_par02)+"' PeriodoFinalExtracao,"
cQuery += " '"+cDataExtracao+"' DataExtracao"
cQuery += " From "+RetSQLName("CV1")+" CV1"
cQuery += " Where CV1_FILIAL  IN (" + cFiliais + ")"
cQuery += " and CV1.D_E_L_E_T_ = ''"

Memowrite("QryfOrcamentoContabil.txt",cQuery)
TCSQLExec(cScript+cQuery)

//--------------------------------------------------------------
//-- Query para geracao do tabela dVisoesGerenciais
//--------------------------------------------------------------
cMsg := "CI_M150 - 'Processando tabela dos Visões Gerenciais...'"

If !lAuto
	oProcess:IncRegua2(cMsg)   
Else
	ConOut(cMsg)
Endif

cScript := " Insert Into dVisoesGerenciais (Filial, CodigoVisao, NomeVisao, Ordem, EntidadeGerencial, EntidadeSuperior, DescricaoGerencial, ClasseEntidade, Identificador, Linha, Conta,  CentroCusto, ItemConta, ClasseValor, PeriodoInicialExtracao, PeriodoFinalExtracao, DataExtracao)"
cQuery := " Select Distinct "
cQuery += " CTS_FILIAL Filial,"
cQuery += " CTS_CODPLA CodigoVisao,"
cQuery += " CTS_NOME NomeVisao,"
cQuery += " CTS_ORDEM Ordem,"
cQuery += " CTS_CONTAG EntidadeGerencial,"
cQuery += " CTS_CTASUP EntidadeSuperior,"
cQuery += " CTS_DESCCG DescricaoGerencial,"
cQuery += " CTS_CLASSE ClasseEntidade,"
cQuery += " CTS_IDENT Identificador,"
cQuery += " CTS_LINHA Linha,"
cQuery += " CT1_CONTA Conta,"
cQuery += " CTT_CUSTO Centrocusto,"
cQuery += " CTD_ITEM Itemconta,"
cQuery += " CTH_CLVL Classevalor,"
cQuery += " '"+Dtoc(mv_par01)+"' PeriodoInicialExtracao,"
cQuery += " '"+Dtoc(mv_par02)+"' PeriodoFinalExtracao,"
cQuery += " '"+cDataExtracao+"' DataExtracao"
cQuery += " From "+RetSQLName("CTS")+" CTS"

cQuery += " Left Join "+RetSQLName("CT1")+" CT1"
cQuery += " on CT1_CONTA Between CTS_CT1INI and CTS_CT1FIM and CT1_FILIAL = CTS_FILIAL and CT1.D_E_L_E_T_ = '' "

cQuery += " Left Join "+RetSQLName("CTT")+" CTT"
cQuery += " on CTT_CUSTO Between CTS_CTTINI and CTS_CTTFIM and CTT_FILIAL = CTS_FILIAL and CTT.D_E_L_E_T_ = '' "

cQuery += " Left Join "+RetSQLName("CTD")+" CTD"
cQuery += " on CTD_ITEM Between CTS_CTDINI and CTS_CTDFIM and CTD_FILIAL = CTS_FILIAL and CTD.D_E_L_E_T_ = '' "

cQuery += " Left Join "+RetSQLName("CTH")+" CTH"
cQuery += " on CTH_CLVL Between CTS_CTHINI and CTS_CTHFIM and CTH_FILIAL = CTS_FILIAL and CTH.D_E_L_E_T_ = '' "

cQuery += " Where CTS_FILIAL IN (" + cFiliais + ")"
cQuery += " and CTS.D_E_L_E_T_ = ''"

Memowrite("QrydVisoesGerenciais.txt",cQuery)
TCSQLExec(cScript+cQuery)

//--------------------------------------------------------------
//-- Query para geracao do tabela dPlanoContas            admin	
//--------------------------------------------------------------
cMsg := "CI_M150 - 'Processando tabela de Plano de Contas...'"

If !lAuto
	oProcess:IncRegua2(cMsg)   
Else
	ConOut(cMsg)
Endif

cScript := " Insert Into dPlanoContas (Filial, Conta, Descricao, Classe, ContaSuperior, PeriodoInicialExtracao, PeriodoFinalExtracao, DataExtracao)"
cQuery := " Select Distinct "
cQuery += " CT1_FILIAL Filial,"
cQuery += " CT1_CONTA Conta,"
cQuery += " CT1_DESC01 Descricao,"
cQuery += " CT1_CLASSE Classe,"
cQuery += " CT1_CTASUP ContaSuperior,"
cQuery += " '"+Dtoc(mv_par01)+"' PeriodoInicialExtracao,"
cQuery += " '"+Dtoc(mv_par02)+"' PeriodoFinalExtracao,"
cQuery += " '"+cDataExtracao+"' DataExtracao"
cQuery += " From "+RetSQLName("CT1")+" CT1"
cQuery += " Where CT1_FILIAL IN (" + cFiliais + ")"
cQuery += " and CT1.D_E_L_E_T_ = ''"

Memowrite("QrydPlanoContas.txt",cQuery)
TCSQLExec(cScript+cQuery)


//--------------------------------------------------------------
//-- Query para geracao do tabela dCentroCusto
//--------------------------------------------------------------
cMsg := "CI_M150 - 'Processando tabela de Centro de Custo...'"

If !lAuto
	oProcess:IncRegua2(cMsg)   
Else
	ConOut(cMsg)
Endif

cScript := " Insert Into dCentroCusto (Filial, CentroCusto, Descricao, Classe, CentroCustoSuperior, PeriodoInicialExtracao, PeriodoFinalExtracao, DataExtracao)"
cQuery := " Select Distinct "
cQuery += " CTT_FILIAL Filial,"
cQuery += " CTT_CUSTO CentroCusto,"
cQuery += " CTT_DESC01 Descricao,"
cQuery += " CTT_CLASSE Classe,"
cQuery += " CTT_CCSUP CentroCustoSuperior,"
cQuery += " '"+Dtoc(mv_par01)+"' PeriodoInicialExtracao,"
cQuery += " '"+Dtoc(mv_par02)+"' PeriodoFinalExtracao,"
cQuery += " '"+cDataExtracao+"' DataExtracao"
cQuery += " From "+RetSQLName("CTT")+" CTT"
cQuery += " Where CTT_FILIAL IN (" + cFiliais + ")"
cQuery += " and CTT.D_E_L_E_T_ = ''"

Memowrite("QrydCentroCusto.txt",cQuery)
TCSQLExec(cScript+cQuery)


//--------------------------------------------------------------
//-- Query para geracao do tabela dItemContabil
//--------------------------------------------------------------
cMsg := "CI_M150 - 'Processando tabela de Item Contáil...'"

If !lAuto
	oProcess:IncRegua2(cMsg)   
Else
	ConOut(cMsg)
Endif

// DWT Luciano  - 20231023
cScript := " Insert Into dItemContabil (Filial, ItemContabil, Descricao, Classe, ItemContabilSuperior, PeriodoInicialExtracao, PeriodoFinalExtracao, DataExtracao)"
cQuery := " Select Distinct "
cQuery += " CTD_FILIAL Filial,"
cQuery += " CTD_ITEM ItemContabil,"
cQuery += " CTD_DESC01 Descricao,"
cQuery += " CTD_CLASSE Classe,"
cQuery += " CTD_ITSUP ItemContabilSuperior,"
cQuery += " '"+Dtoc(mv_par01)+"' PeriodoInicialExtracao,"
cQuery += " '"+Dtoc(mv_par02)+"' PeriodoFinalExtracao,"
cQuery += " '"+cDataExtracao+"' DataExtracao"
cQuery += " From "+RetSQLName("CTD")+" CTD"
cQuery += " Where CTD_FILIAL IN (" + cFiliais + ")"
cQuery += " and CTD.D_E_L_E_T_ = ''"

Memowrite("QrydItemContabil.txt",cQuery)
TCSQLExec(cScript+cQuery)

//--------------------------------------------------------------
//-- Query para geracao do tabela dClasseValor
//--------------------------------------------------------------
cMsg := "CI_M150 - 'Processando tabela de Classe de Valor...'"

If !lAuto
	oProcess:IncRegua2(cMsg)   
Else
	ConOut(cMsg)
Endif

cScript := " Insert Into dClasseValor (Filial, ClasseValor, Descricao, Classe, ClasseValorSuperior, PeriodoInicialExtracao, PeriodoFinalExtracao, DataExtracao)"
cQuery := " Select Distinct "
cQuery += " CTH_FILIAL Filial,"
cQuery += " CTH_CLVL ClasseValor,"
cQuery += " CTH_DESC01 Descricao,"
cQuery += " CTH_CLASSE Classe,"
cQuery += " CTH_CLSUP ClasseValorSuperior,"
cQuery += " '"+Dtoc(mv_par01)+"' PeriodoInicialExtracao,"
cQuery += " '"+Dtoc(mv_par02)+"' PeriodoFinalExtracao,"
cQuery += " '"+cDataExtracao+"' DataExtracao"
cQuery += " From "+RetSQLName("CTH")+" CTH"
cQuery += " Where CTH_FILIAL IN (" + cFiliais + ")"
cQuery += " and CTH.D_E_L_E_T_ = ''"

Memowrite("QrydClasseValor.txt",cQuery)
TCSQLExec(cScript+cQuery)

//--------------------------------------------------------------
//-- Query para geracao do tabela fSaldosContasMes - CQ0
//--------------------------------------------------------------
cMsg := "CI_M150 - 'Processando tabela de Saldos Contas Mes...'"

If !lAuto
	oProcess:IncRegua2(cMsg)   
Else
	ConOut(cMsg)
Endif

cScript := " Insert Into fSaldosContasMes (Filial,Data,Conta,Moeda,TipoSaldo,SldoLPerdas,Status,SldBase,ValorDebito,ValorCredito,DataApuracao, PeriodoInicialExtracao, PeriodoFinalExtracao, DataExtracao)"
cQuery := " Select Distinct "
cQuery += " CQ0_FILIAL   Filial,"
cQuery += " Substring(CQ0_DATA,7,2)+'/'+Substring(CQ0_DATA,5,2)+'/'+Substring(CQ0_DATA,1,4) Data,"
cQuery += " CQ0_CONTA    Conta,"
cQuery += " CQ0_MOEDA    Moeda,"
cQuery += " CQ0_TPSALD   TipoSaldo,"
cQuery += " CQ0_LP       SldoLPerdas,"
cQuery += " CQ0_STATUS   Status,"
cQuery += " CQ0_SLBASE   SldBase,"
cQuery += " CQ0_DEBITO   ValorDebito,"
cQuery += " CQ0_CREDIT   ValorCredito,"
cQuery += " Substring(CQ0_DTLP,7,2)+'/'+Substring(CQ0_DTLP,5,2)+'/'+Substring(CQ0_DTLP,1,4) DataApuracao,"
cQuery += " '"+Dtoc(mv_par01)+"' PeriodoInicialExtracao,"
cQuery += " '"+Dtoc(mv_par02)+"' PeriodoFinalExtracao,"
cQuery += " '"+cDataExtracao+"'  DataExtracao"
cQuery += " From "+RetSQLName("CQ0")+" CQ0"
cQuery += " Where CQ0_FILIAL IN (" + cFiliais + ")"
cQuery += " and CQ0.D_E_L_E_T_ = ''"

Memowrite("QryfSaldosContasMes.txt",cQuery)
TCSQLExec(cScript+cQuery)

//--------------------------------------------------------------
//-- Query para geracao do tabela fPoderTerceiros - SB6
//--------------------------------------------------------------
cMsg := "CI_M150 - 'Processando tabela de Poder de Terceiros...'"

If !lAuto
	oProcess:IncRegua2(cMsg)   
Else
	ConOut(cMsg)
Endif

cScript := " Insert Into fPoderTerceiros (Filial,CliFor,Loja,Produto,Local,DocOriginal,Serie,DtEmissao,Quantidade,PrecoUnit,TES,Tipo, "
cScript += " Custo1,Custo2,Custo3,Custo4,Custo5,UnidMedida,SeqIndent,TipCliFor,Saldo,PoderTerceiro,AtuEstoque,CodVendedor,NomeVendedor, "
cScript += " Lote,ValidadeLote,DtProced,Paciente,PeriodoInicialExtracao, PeriodoFinalExtracao, DataExtracao)"
cQuery := " SELECT B6_FILIAL    Filial,"
cQuery += "        B6_CLIFOR    Clifor,"
cQuery += "        B6_LOJA      Loja,"
cQuery += "        B6_PRODUTO   Produto,"
cQuery += "        B6_LOCAL     Local,"
cQuery += "        B6_DOC       DocOriginal,"
cQuery += "        B6_SERIE     Serie,"
cQuery += "        B6_EMISSAO   DtEmissao,"
cQuery += "        B6_QUANT     Quantidade,"
cQuery += "        B6_PRUNIT    PrecoUnit,"
cQuery += "        B6_TES       TES,"
cQuery += "        B6_TIPO      Tipo,"
cQuery += "        B6_CUSTO1    Custo1,"
cQuery += "        B6_CUSTO2    Custo2,"
cQuery += "        B6_CUSTO3    Custo3,"
cQuery += "        B6_CUSTO4    Custo4,"
cQuery += "        B6_CUSTO5    Custo5,"
cQuery += "        B6_UM        UnidMedida,"
cQuery += "        B6_IDENT     SeqIndent,"
cQuery += "        B6_TPCF      TipCliFor, "
cQuery += "        B6_SALDO     Saldo,"
cQuery += "        B6_PODER3    PoderTerceiro,"
cQuery += "        B6_ESTOQUE   AtuEstoque,"
cQuery += "        A3_COD       CodVendedor, "
cQuery += "        A3_NOME      NomeVendedor, "
cQuery += "        D2_LOTECTL   Lote, "
cQuery += "        Substring(D2_DTVALID,7,2)+'/'+Substring(D2_DTVALID,5,2)+'/'+Substring(D2_DTVALID,1,4) ValidadeLote,"
cQuery += "        C5_DPROCED   DtProced, "
cQuery += "        C5_PACIENT   Paciente, "
cQuery += " '"+Dtoc(mv_par01)+"' PeriodoInicialExtracao,"
cQuery += " '"+Dtoc(mv_par02)+"' PeriodoFinalExtracao,"
cQuery += " '"+cDataExtracao+"'  DataExtracao"
cQuery += " FROM " + RetSQLName("SB6")+ " SB6 "
cQuery += " INNER JOIN  " + RetSQLName("SD2") + " SD2 ON (SD2.D2_DOC=SB6.B6_DOC       AND SD2.D2_SERIE=SB6.B6_SERIE   AND SD2.D2_CLIENTE=SB6.B6_CLIFOR    AND SD2.D2_LOJA=SB6.B6_LOJA AND SD2.D2_IDENTB6=SB6.B6_IDENT AND SD2.D_E_L_E_T_<>'*')  "  
cQuery += " INNER JOIN  " + RetSQLName("SC5") + " SC5 ON (SD2.D2_PEDIDO=SC5.C5_NUM    and SD2.D2_FILIAL=SC5.C5_FILIAL AND  SD2.D_E_L_E_T_<>'*') "    
cQuery += " INNER JOIN  " + RetSQLName("SA1") + " SA1 ON (SC5.C5_CLIENTE=SA1.A1_COD   AND SC5.C5_LOJACLI=SA1.A1_LOJA  AND SA1.D_E_L_E_T_<>'*') "  
cQuery += " INNER JOIN  " + RetSQLName("SA3") + " SA3 ON (SA3.A3_COD=SC5.C5_VEND1     AND SA3.D_E_L_E_T_<>'*')        JOIN SB1010 SB1 ON (SB6.B6_PRODUTO=SB1.B1_COD AND  SB1.D_E_L_E_T_<>'*') "    
cQuery += " INNER JOIN  " + RetSQLName("SF4") + " SF4 ON (SB6.B6_FILIAL=SF4.F4_FILIAL AND SB6.B6_TES=SF4.F4_CODIGO    AND SF4.D_E_L_E_T_<>'*') "
cQuery += " WHERE SB6.D_E_L_E_T_ <> '*'"
cQuery += " AND SB6.B6_SALDO>0  "
cQuery += " AND SB6.B6_TIPO = 'E' "  

Memowrite("QryfPoderTerceiros.txt",cQuery)
TCSQLExec(cScript+cQuery)

//--------------------------------------------------------------
//-- Query para geracao do tabela fInventario - ZA3
//--------------------------------------------------------------
cMsg := "CI_M150 - 'Processando tabela de Inventario...'"

If !lAuto
	oProcess:IncRegua2(cMsg)   
Else
	ConOut(cMsg)
Endif

cScript := " Insert Into fInventario (Filial,Codigo,Tipo,Grupo,Marca,Documento,Quantidade,Data,Lote,NumSerie,Endereco,DtValidade, "
cScript += " FornClien,Loja,Vendedor,Longitude,Latitude,Identificador,PeriodoInicialExtracao,PeriodoFinalExtracao,DataExtracao)"
cQuery := " SELECT "  
cQuery += " ZA3.ZA3_FILIAL     Filial, "
cQuery += " ZA3.ZA3_COD        Codigo, "
cQuery += " B1_TIPO            Tipo, "  
cQuery += " B1_GRUPO           Grupo, "  
cQuery += " B1_MARCA           Marca, "  
cQuery += " ZA3.ZA3_DOC        Documento, "  
cQuery += " ZA3.ZA3_QUANT      Quantidade,  "
cQuery += " Substring(ZA3.ZA3_DATA,7,2)+'/'+Substring(ZA3.ZA3_DATA,5,2)+'/'+Substring(ZA3.ZA3_DATA,1,4) Data,"
cQuery += " ZA3.ZA3_LOTECT     Lote, "
cQuery += " ZA3.ZA3_NUMSER     NumSerie,  "
cQuery += " ZA3.ZA3_LOCAL      Endereco, "
cQuery += " Substring(ZA3.ZA3_DTVALI,7,2)+'/'+Substring(ZA3.ZA3_DTVALI,5,2)+'/'+Substring(ZA3.ZA3_DTVALI,1,4) DtValidade,"
cQuery += " ZA3.ZA3_FORNEC     FornClien, "
cQuery += " ZA3.ZA3_LOJA       Loja, "  
cQuery += " ZA3.ZA3_VENDED     Vendedor, "
cQuery += " ZA3.ZA3_LONG       Longitude,  "
cQuery += " ZA3.ZA3_LATI       Latitude,  "
cQuery += " ZA3.ZA3_IDINV      Identificador,  "
//cQuery += " ZA3.R_E_C_N_O_     ZA3_ID,  "
cQuery += " '"+Dtoc(mv_par01)+"' PeriodoInicialExtracao,"
cQuery += " '"+Dtoc(mv_par02)+"' PeriodoFinalExtracao,"
cQuery += " '"+cDataExtracao+"'  DataExtracao"
cQuery += " FROM ZA3010  ZA3 "
cQuery += " INNER JOIN SB1010 SB1 ON (ZA3.ZA3_COD=SB1.B1_COD AND SB1.D_E_L_E_T_<>'*') "
cQuery += " INNER JOIN (SELECT  "
cQuery += " ZA3_FILIAL,  "
cQuery += " ZA3_COD, "      
cQuery += " MAX(ZA3_DATA) ZA3_DATA, "  
cQuery += " ZA3_LOTECT, "
cQuery += " ZA3_NUMSER, "
cQuery += " ZA3_LOCAL, "
cQuery += " ZA3_DTVALI, "
cQuery += " ZA3_FORNEC, "
cQuery += " ZA3_LOJA,   "
cQuery += " ZA3_VENDED, "
cQuery += " MAX(ZA3.R_E_C_N_O_) ZA3_ID  "
cQuery += " FROM ZA3010  ZA3  "
cQuery += " WHERE ZA3.D_E_L_E_T_<>'*' "
cQuery += " GROUP BY "
cQuery += " ZA3_FILIAL,  "
cQuery += " ZA3_COD,  "  
cQuery += " ZA3_DOC, "
cQuery += " ZA3_LOTECT,  "
cQuery += " ZA3_NUMSER,  "
cQuery += " ZA3_LOCAL,  "
cQuery += " ZA3_DTVALI,  "
cQuery += " ZA3_FORNEC, "
cQuery += " ZA3_LOJA,   "
cQuery += " ZA3_VENDED) AS GZA3   "
cQuery += " ON (GZA3.ZA3_FILIAL=ZA3.ZA3_FILIAL AND  "
cQuery += " GZA3.ZA3_COD    =ZA3.ZA3_COD AND   "
cQuery += " GZA3.ZA3_LOTECT = ZA3.ZA3_LOTECT AND "
cQuery += " GZA3.ZA3_NUMSER = ZA3.ZA3_NUMSER AND  "
cQuery += " GZA3.ZA3_LOCAL  = ZA3.ZA3_LOCAL AND "
cQuery += " GZA3.ZA3_DTVALI = ZA3.ZA3_DTVALI AND "
cQuery += " GZA3.ZA3_FORNEC = ZA3.ZA3_FORNEC AND "
cQuery += " GZA3.ZA3_LOJA   = ZA3.ZA3_LOJA AND "
cQuery += " GZA3.ZA3_DATA   = ZA3.ZA3_DATA AND "
cQuery += " GZA3.ZA3_ID     = ZA3.R_E_C_N_O_) "

Memowrite("QryfInventario.txt",cQuery)
TCSQLExec(cScript+cQuery)

//--------------------------------------------------------------
//-- Query para geracao do tabela fMatrizReposicao -ZA5
//--------------------------------------------------------------
cMsg := "CI_M150 - 'Processando tabela de fMatrizReposicao...'"

If !lAuto
	oProcess:IncRegua2(cMsg)   
Else
	ConOut(cMsg)
Endif

cScript := " Insert Into fMatrizReposicao (Filial,Cliente,Loja,NomeCliente,QtdePrevista,QtdeAtual,QtdeReposicao,CodVendedor,NomeVendedor, "
cScript += " TotCusto,TotVenda,CodProduto,NomeProduto,Auditoria,FonteOrigem,PeriodoInicialExtracao, PeriodoFinalExtracao, DataExtracao)"
cQuery := " SELECT   "
cQuery += " ZA5.ZA5_FILIAL  Filial, "
cQuery += " ZA5.ZA5_CLI     Cliente, "  
cQuery += " ZA5.ZA5_LOJA    Loja, "
cQuery += " ZA5.ZA5_CLINOM  NomeCliente, "
cQuery += " ZA5.ZA5_QTDPRV  QtdePrevista, "
cQuery += " ZA5.ZA5_QTDATU  QtdeAtual, "
cQuery += " ZA5.ZA5_QTDREP  QtdeReposicao, "
cQuery += " ZA5.ZA5_CODVEN  CodVendedor, "
cQuery += " ZA5.ZA5_NOMVEN  NomeVendedor, "
cQuery += " ZA5.ZA5_TOTCUS  TotCusto,   "
cQuery += " ZA5.ZA5_TOTVEN  TotVenda, "  
cQuery += " ZA5.ZA5_CODPRO  CodProduto, "
cQuery += " ZA5.ZA5_NOMPRO  NomeProduto, "
cQuery += " ZA5.ZA5_AUDITO  Auditoria, "
cQuery += " ZA5.ZA5_FONTE   FonteOrigem,"
cQuery += " '"+Dtoc(mv_par01)+"' PeriodoInicialExtracao,"
cQuery += " '"+Dtoc(mv_par02)+"' PeriodoFinalExtracao,"
cQuery += " '"+cDataExtracao+"'  DataExtracao"
cQuery += " FROM " + RetSQLName("ZA5") + " ZA5 "
cQuery += " WHERE ZA5.D_E_L_E_T_ <>'*'"

Memowrite("QryfMatrizReposicao.txt",cQuery)
TCSQLExec(cScript+cQuery)

//------------------------------------------------------------
cMsg := "CI_M150 - Fim do processamento do Data Mart Contábil"

If !lAuto
	oProcess:SaveLog(cMsg)
Else
	ConOut(cMsg)
Endif

Return                            

/*___________________________________________________________________________
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
||-------------------------------------------------------------------------||
|| Função: SchedDef     || Autor: Jeferson Silva        || Data: 11/07/19  ||
||-------------------------------------------------------------------------||
|| Descrição: Função para configuração de Parâmetros no Agendamento        ||
||-------------------------------------------------------------------------||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function SchedDef()

Local aOrd		:= {}
Local aParam	:= {}

aParam	:= { "P", "CI_M150", "", aOrd, }

Return( aParam )


