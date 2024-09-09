#Include 'Totvs.ch'
#include 'topconn.ch'

/*/{Protheus.doc}
Funcao para Geracao do Data Mart Comercial
@author Jeferson Silva
@since 28/07/2019
@version 1.0
@return Nil,
@example
u_CI_M170()
/*/

User Function CI_M170(aParam)
Local aArea   	:= GetArea()
Local aInfo     := {}
Local cTitulo 	:= "Geração do Data Mart Comercial"
Local bProcess  := {||}
Local oProcess  := Nil
Local lAuto		:= IsBlind()
Local aTabelas	:= {"SA1","SB1","VV1","SD2","SD1","SB2","SB9","SF4"}

Private cPerg   := PadR("CI_M170",10)

If lAuto// Chamada via Schedule
	cMsg := "CI_M170 - Geração do Data Mart Comercial"
	ConOut(cMsg)
	BatchProcess(cTitulo, cTitulo,"CI_M170", { || M170Proc( oProcess,lAuto ) }, { || .F. }  ) 
Else
	//Cria a pergunta de entrada do MarkBrowser
	u_PutSX1( cPerg	, "01"	, "Período de:" 			, "mv_par01", "mv_ch1"	, "D"		, TamSX3('D2_EMISSAO')[1]		, 0			, "G"		, ""													, ""		, 			,				,				,			,			,			,		, ""		)
	u_PutSX1( cPerg	, "02"	, "Período até:"			, "mv_par02", "mv_ch2"	, "D"		, TamSX3('D2_EMISSAO')[1]		, 0			, "G"		, ""													, ""		, 			,				,				,			,			,			,		, ""		)
	
	Pergunte(cPerg,.F.)
	
	aAdd( aInfo, { "Cancelar", 	{ |oPanelCenter| oPanelCenter:oWnd:End() },	"CANCEL"  })
	
	bProcess := { |oProcess| M170Proc( oProcess ) }
	
	cDescRot := "Esta rotina tem o objetivo de gerar o Data Mart Comercial"
	
	oProcess := TNewProcess():New( "CI_M170", cTitulo, bProcess, cDescRot, cPerg, aInfo,.F., 5,'Processamento', .T.)
Endif

RestArea(aArea)

Return Nil

/*/{Protheus.doc}
Funcao para processamento do Data Mart
@author Jeferson Silva
@since 28/07/2019
@version 1.0
@return Nil,
@example
M170Proc()
/*/
Static Function M170Proc( oProcess,lAuto )

Local aLog  := {}
Local cLog  := ""
Local cMsg  := ""

Local cFiliais		:= "'  '"
Local cDataExtracao	:= DtoC( Date() ) + " - " + Time()

If !lAuto
	oProcess:SetRegua1(1)
	oProcess:IncRegua1('Processando do Data Mart Comercial')
	oProcess:SetRegua2(9) // Numero de tabelas processadas
Else
	ConOut('Processando do Data Mart Comercial')
Endif

//TCSQLExec( "DROP TABLE dClientes_Comercial" ) // Reestruturacao

If !TCCanOpen( "dClientes_Comercial" )
	cScript := " create table dClientes_Comercial("
	cScript += " Filial varchar("+Str(TamSX3('A1_FILIAL')[1])+"),"
	cScript += " Codigo varchar("+Str(TamSX3('A1_COD')[1])+"),"
	cScript += " Loja varchar("+Str(TamSX3('A1_LOJA')[1])+"),"
	cScript += " Tipo varchar("+Str(TamSX3('A1_TIPO')[1])+"),"
	cScript += " Pessoa varchar("+Str(TamSX3('A1_PESSOA')[1])+"),"
	cScript += " Nome varchar("+Str(TamSX3('A1_NOME')[1])+"),"
	cScript += " NomeReduzido varchar("+Str(TamSX3('A1_NREDUZ')[1])+"),"
	cScript += " Estado varchar("+Str(TamSX3('A1_EST')[1])+"),"
	cScript += " Municipio varchar("+Str(TamSX3('A1_MUN')[1])+"),"
	cScript += " DataExtracao varchar(35)"
	cScript += "  )"
	TCSQLExec( cScript )
EndIf

//TCSQLExec( "DROP TABLE dProdutos_Comercial" ) // Reestruturacao

If !TCCanOpen( "dProdutos_Comercial" )
	cScript := " create table dProdutos_Comercial("
	cScript += " Filial varchar("+Str(TamSX3('B1_FILIAL')[1])+"),"
	cScript += " Codigo varchar("+Str(TamSX3('B1_COD')[1])+"),"
	cScript += " Descricao varchar("+Str(TamSX3('B1_DESC')[1])+"),"
	cScript += " Tipo varchar("+Str(TamSX3('B1_TIPO')[1])+"),"
	cScript += " CodigoItem varchar("+Str(TamSX3('B1_CODITE')[1])+"),"
	cScript += " UnidadeMedida varchar("+Str(TamSX3('B1_UM')[1])+"),"
	cScript += " Grupo varchar("+Str(TamSX3('B1_GRUPO')[1])+"),"
	cScript += " Marca varchar("+Str(TamSX3('B1_MARCA')[1])+"),"
	cScript += " DataExtracao varchar(35)"
	cScript += "  )"
	TCSQLExec( cScript )
EndIf

//TCSQLExec( "DROP TABLE dVeiculos_Comercial" ) // Reestruturacao

If !TCCanOpen( "dVeiculos_Comercial" )
	cScript := " create table dVeiculos_Comercial("
	cScript += " Filial varchar("+Str(TamSX3('VV1_FILIAL')[1])+"),"
	cScript += " ChassisInterno varchar("+Str(TamSX3('VV1_CHAINT')[1])+"),"
	cScript += " Segmento varchar("+Str(TamSX3('VV1_SEGMOD')[1])+"),"
	cScript += " Placa varchar("+Str(TamSX3('VV1_PLAVEI')[1])+"),"
	cScript += " Chassis varchar("+Str(TamSX3('VV1_CHASSI')[1])+"),"
	cScript += " DataExtracao varchar(35)"
	cScript += "  )"
	TCSQLExec( cScript )
EndIf

TCSQLExec( "DROP TABLE dGrupoProduto_Comercial" ) // Reestruturacao

If !TCCanOpen( "dGrupoProduto_Comercial" )
	cScript := " create table dGrupoProduto_Comercial("
	cScript += " Filial varchar("+Str(TamSX3('BM_FILIAL')[1])+"),"
	cScript += " Grupo varchar("+Str(TamSX3('BM_GRUPO')[1])+"),"
	cScript += " Descricao varchar("+Str(TamSX3('BM_DESC')[1])+"),"
	cScript += " Marca varchar("+Str(TamSX3('BM_CODMAR')[1])+"),"
	cScript += " DataExtracao varchar(35)"
	cScript += "  )"
	TCSQLExec( cScript )
EndIf

TCSQLExec( "DROP TABLE dVendedores_Comercial" ) // Reestruturacao

If !TCCanOpen( "dVendedores_Comercial" )
	cScript := " create table dVendedores_Comercial("
	cScript += " Filial varchar("+Str(TamSX3('A3_FILIAL')[1])+"),"
	cScript += " Codigo varchar("+Str(TamSX3('A3_COD')[1])+"),"
	cScript += " Nome varchar("+Str(TamSX3('A3_NOME')[1])+"),"
	cScript += " NomeReduzido varchar("+Str(TamSX3('A3_NREDUZ')[1])+"),"
	cScript += " Gerente varchar("+Str(TamSX3('A3_GEREN')[1])+"),"
	cScript += " Supervisor varchar("+Str(TamSX3('A3_SUPER')[1])+"),"
	cScript += " DataExtracao varchar(35)"
	cScript += "  )"
	TCSQLExec( cScript )
EndIf

TCSQLExec( "DROP TABLE fItensNotaFiscal_Comercial" ) // Reestruturacao

If !TCCanOpen( "fItensNotaFiscal_Comercial" )
	cScript := " create table fItensNotaFiscal_Comercial("
	cScript += " Filial varchar("+Str(TamSX3('D2_FILIAL')[1])+"),"
	cScript += " Data varchar(10),"
	cScript += " NotaFiscal varchar("+Str(TamSX3('D2_DOC')[1])+"),"
	cScript += " Serie varchar("+Str(TamSX3('D2_SERIE')[1])+"),"
	cScript += " Item varchar("+Str(TamSX3('D1_ITEM')[1])+"),"
	cScript += " TipoNotaFiscal varchar("+Str(TamSX3('D2_TIPO')[1])+"),"
	cScript += " CodigoFiscal varchar("+Str(TamSX3('D2_CF')[1])+"),"
	cScript += " DescricaoFiscal varchar("+Str(TamSX3('F4_TEXTO')[1])+"),"
	cScript += " Tes varchar("+Str(TamSX3('D2_TES')[1])+"),"
	cScript += " Produto varchar("+Str(TamSX3('D2_COD')[1])+"),"
	cScript += " GrupoProduto varchar("+Str(TamSX3('D2_GRUPO')[1])+"),"
	cScript += " ItemMaquina varchar("+Str(TamSX3('B1_CODITE')[1])+"),"
	cScript += " Cliente varchar("+Str(TamSX3('D2_CLIENTE')[1])+"),"
	cScript += " LojaCliente varchar("+Str(TamSX3('D2_LOJA')[1])+"),"
	cScript += " Quantidade float(8),"
	cScript += " PrecoVenda float(8),"
	cScript += " ValorTotal float(8),"
	cScript += " ValorIcms float(8),"
	cScript += " ValorPis float(8),"
	cScript += " ValorCofins float(8),"
	cScript += " ValorIss float(8),"
	cScript += " ValorCsll float(8),"

	// DWT Luciano 20230118
	cScript += " ValorIpi float(8),"

	cScript += " ValorSeguro float(8),"
	cScript += " ValorFrete float(8),"
	cScript += " ValorDesconto float(8),"
	cScript += " ValorCusto float(8),"
	cScript += " CentroCusto varchar("+Str(TamSX3('D2_CCUSTO')[1])+"),"
	cScript += " ClasseValor varchar("+Str(TamSX3('D2_CLVL')[1])+"),"
	cScript += " MovimentaFinanceiro varchar("+Str(TamSX3('F4_DUPLIC')[1])+"),"
	cScript += " MovimentaEstoque varchar("+Str(TamSX3('F4_ESTOQUE')[1])+"),"
	cScript += " NotaFiscalOrigem varchar("+Str(TamSX3('D2_NFORI')[1])+"),"
	cScript += " SerieOrigem varchar("+Str(TamSX3('D2_SERIORI')[1])+"),"
	cScript += " Prefixo varchar("+Str(TamSX3('F2_PREFIXO')[1])+"),"
	cScript += " PrefixoOrigem varchar("+Str(TamSX3('F2_PREFORI')[1])+"),"
	cScript += " Vendedor1 varchar("+Str(TamSX3('F2_VEND1')[1])+"),"
	cScript += " Vendedor2 varchar("+Str(TamSX3('F2_VEND2')[1])+"),"
	cScript += " Vendedor3 varchar("+Str(TamSX3('F2_VEND3')[1])+"),"
	cScript += " Vendedor4 varchar("+Str(TamSX3('F2_VEND4')[1])+"),"
	cScript += " Vendedor5 varchar("+Str(TamSX3('F2_VEND5')[1])+"),"
	cScript += " Comissao1 float(8),"
	cScript += " Comissao2 float(8),"
	cScript += " Comissao3 float(8),"
	cScript += " Comissao4 float(8),"
	cScript += " Comissao5 float(8),"
	cScript += " ComissRep float(8),"
	cScript += " Armazem varchar("+Str(TamSX3('D2_LOCAL')[1])+"),"
	cScript += " TipoOperacao varchar(15)," 
	cScript += " BIOperacao varchar("+Str(TamSX3('F4_BIOPERA')[1])+"),"
	cScript += " PeriodoInicialExtracao varchar(10),"
	cScript += " PeriodoFinalExtracao varchar(10),"
	cScript += " DataExtracao varchar(35)"
	cScript += "  )"
	TCSQLExec( cScript )
EndIf

//TCSQLExec( "DROP TABLE fSaldoEstoque_Comercial" ) // Reestruturacao

If !TCCanOpen( "fSaldoEstoque_Comercial" )
	cScript := " create table fSaldoEstoque_Comercial("
	cScript += " Filial varchar("+Str(TamSX3('B2_FILIAL')[1])+"),"
	cScript += " Produto varchar("+Str(TamSX3('B2_COD')[1])+"),"
	cScript += " Local varchar("+Str(TamSX3('B2_LOCAL')[1])+"),"
	cScript += " SaldoAtual float(8),"
	cScript += " CustoUnitario float(8),"
	cScript += " QtdEmpenhada float(8),"
	cScript += " QtdReservada float(8),"
	cScript += " QtdPedidoVenda float(8),"
	cScript += " QtdPrevistaEntrar float(8),"
	cScript += " DataExtracao varchar(35)"
	cScript += "  )"
	TCSQLExec( cScript )
EndIf

//TCSQLExec( "DROP TABLE fFechamentoEstoque_Comercial" ) // Reestruturacao

If !TCCanOpen( "fFechamentoEstoque_Comercial" )
	cScript := " create table fFechamentoEstoque_Comercial("
	cScript += " Filial varchar("+Str(TamSX3('B9_FILIAL')[1])+"),"
	cScript += " Produto varchar("+Str(TamSX3('B9_COD')[1])+"),"
	cScript += " Local varchar("+Str(TamSX3('B9_LOCAL')[1])+"),"
	cScript += " QtdInicioMes float(8),"
	cScript += " CustoUnitario float(8),"
	cScript += " SaldoInicioMes float(8),"
	cScript += " DataFechamento varchar(10),"
	cScript += " PeriodoInicialExtracao varchar(10),"
	cScript += " PeriodoFinalExtracao varchar(10),"
	cScript += " DataExtracao varchar(35)"
	cScript += "  )"
	TCSQLExec( cScript )
EndIf

//TCSQLExec( "DROP TABLE fOrdemServico_Comercial" ) // Reestruturacao

If !TCCanOpen( "fOrdemServico_Comercial" )
	cScript := " create table fOrdemServico_Comercial("
	cScript += " Filial varchar("+Str(TamSX3('VO1_FILIAL')[1])+"),"
	cScript += " NumeroOS varchar("+Str(TamSX3('VO1_NUMOSV')[1])+"),"
	cScript += " ChassiVeiculo varchar("+Str(TamSX3('VO1_CHASSI')[1])+"),"
	cScript += " ChassisInterno varchar("+Str(TamSX3('VO1_CHAINT')[1])+"),"
	cScript += " PlacaVeiculo varchar("+Str(TamSX3('VO1_PLAVEI')[1])+"),"
	cScript += " AberturaOS varchar(10),"
	cScript += " PeriodoInicialExtracao varchar(10),"
	cScript += " PeriodoFinalExtracao varchar(10),"
	cScript += " DataExtracao varchar(35)"
	cScript += "  )"
	TCSQLExec( cScript )
EndIf

TCSQLExec( "DROP TABLE fMetasVendas_Comercial" ) // Reestruturacao 

// Observar que alguns campos desta tabela devem ser criados para poder obter uma melhor visão gerencial
If !TCCanOpen( "fMetasVendas_Comercial" )
	
	cScript := " create table fMetasVendas_Comercial("
	cScript += " Filial varchar("+Str(TamSX3('CT_FILIAL')[1])+"),"
	cScript += " Data varchar(10),"
	cScript += " Vendedor varchar("+Str(TamSX3('CT_VEND')[1])+"),"
	cScript += " Gerente varchar("+Str(TamSX3('CT_GERENTE')[1])+"),"
	cScript += " Supervisor varchar("+Str(TamSX3('CT_SUPERVI')[1])+"),"
	cScript += " Regiao varchar("+Str(TamSX3('CT_REGIAO')[1])+"),"
	cScript += " Categoria varchar("+Str(TamSX3('CT_CATEGO')[1])+"),"
	cScript += " Tipo varchar("+Str(TamSX3('CT_TIPO')[1])+"),"
	cScript += " Grupo varchar("+Str(TamSX3('CT_GRUPO')[1])+"),"
	cScript += " Marca varchar("+Str(TamSX3('CT_MARCA')[1])+"),"
	cScript += " Produto varchar("+Str(TamSX3('CT_PRODUTO')[1])+"),"
	cScript += " TipoOperacao varchar("+Str(TamSX3('CT_TPOPER')[1])+"),"
	cScript += " CentroCusto varchar("+Str(TamSX3('CT_CCUSTO')[1])+"),"
	cScript += " ClasseValor varchar("+Str(TamSX3('CT_CLVL')[1])+"),"
	cScript += " ItemConta varchar("+Str(TamSX3('CT_ITEMCC')[1])+"),"
	cScript += " Moeda varchar("+Str(TamSX3('CT_MOEDA')[1])+"),"
	cScript += " Quantidade float(8),"
	cScript += " Valor float(8),"
	cScript += " PeriodoInicialExtracao varchar(10),"
	cScript += " PeriodoFinalExtracao varchar(10),"
	cScript += " DataExtracao varchar(35)"
	cScript += "  )"
	
	TCSQLExec( cScript )
	
EndIf

//TCSQLExec( "DROP TABLE dTipoProduto_Comercial" ) // Reestruturacao

If !TCCanOpen( "dTipoProduto_Comercial" )
	cScript := " create table dTipoProduto_Comercial("
	cScript += " Filial varchar("+Str(TamSX3('X5_FILIAL')[1])+"),"
	cScript += " Codigo varchar("+Str(TamSX3('X5_CHAVE')[1])+"),"
	cScript += " Descricao varchar("+Str(TamSX3('X5_DESCRI')[1])+"),"
	cScript += " DataExtracao varchar(35)"
	cScript += "  )"
	TCSQLExec( cScript )
EndIf

// Exclusivo MA HOSPITALAR

	//TCSQLExec( "DROP TABLE dRegiao_Comercial" ) // Reestruturacao

	If !TCCanOpen( "dRegiao_Comercial" )
		cScript := " create table dRegiao_Comercial("
		cScript += " Filial varchar("+Str(TamSX3('X5_FILIAL')[1])+"),"
		cScript += " Codigo varchar("+Str(TamSX3('X5_CHAVE')[1])+"),"
		cScript += " Descricao varchar("+Str(TamSX3('X5_DESCRI')[1])+"),"
		cScript += " DataExtracao varchar(35)"
		cScript += "  )"
		TCSQLExec( cScript )
	EndIf

	//TCSQLExec( "DROP TABLE dMarca_Comercial" ) // Reestruturacao

	If !TCCanOpen( "dMarca_Comercial" )
		cScript := " create table dMarca_Comercial("
		cScript += " Filial varchar("+Str(TamSX3('X5_FILIAL')[1])+"),"
		cScript += " Codigo varchar("+Str(TamSX3('X5_CHAVE')[1])+"),"
		cScript += " Descricao varchar("+Str(TamSX3('X5_DESCRI')[1])+"),"
		cScript += " DataExtracao varchar(35)"
		cScript += "  )"
		TCSQLExec( cScript )
	EndIf

	//TCSQLExec( "DROP TABLE dCategoria_Comercial" ) // Reestruturacao

	If !TCCanOpen( "dCategoria_Comercial" )
		cScript := " create table dCategoria_Comercial("
		cScript += " Filial varchar("+Str(TamSX3('ACU_FILIAL')[1])+"),"
		cScript += " Codigo varchar("+Str(TamSX3('ACU_COD')[1])+"),"
		cScript += " Descricao varchar("+Str(TamSX3('ACU_DESC')[1])+"),"
		cScript += " DataExtracao varchar(35)"
		cScript += "  )"
		TCSQLExec( cScript )
	EndIf

	//TCSQLExec( "DROP TABLE dTipoVenda_Comercial" ) // Reestruturacao

	If !TCCanOpen( "dTipoVenda_Comercial" )
		cScript := " create table dTipoVenda_Comercial("
		cScript += " Codigo varchar(02),"
		cScript += " Descricao varchar(35)"
		cScript += "  )"
		TCSQLExec( cScript )
	EndIf

	//TCSQLExec( "DROP TABLE dTipoVenda_Comercial" ) // Reestruturacao

	// DWT Luciano - 20231023
	If !TCCanOpen( "dTipoVendaFiscal_Comercial" )
		cScript := " create table dTipoVendaFiscal_Comercial("
		cScript += " Codigo varchar(02),"
		cScript += " Descricao varchar(35)"
		cScript += "  )"
		TCSQLExec( cScript )
	EndIf

// Fim das tabelas exclusivas MA HOSPITALAR


SM0->( dbSeek( cEmpAnt, .t. ) )     
cFiliais	+= ",'" + SM0->M0_CODIGO + "'"
While SM0->( !Eof() ) .and. SM0->M0_CODIGO == cEmpAnt
	cFiliais	+= ",'" + SM0->M0_CODFIL + "'"
	SM0->( dbSkip() )
End
SM0->( dbSeek( cEmpAnt + cFilAnt, .f. ) )

If !lAuto
	cMsg := "CI_M170 - Início do processamento."
	oProcess:SaveLog(cMsg)
Else
	ConOut("CI_M170 - Início do processamento.")
Endif

//--------------------------------------------------------------
//-- Query para geracao do tabela dclientes_Comercial
//--------------------------------------------------------------
If !lAuto
	oProcess:IncRegua2('Processando tabela de Clientes')
Else
	ConOut('Processando tabela de Clientes')
Endif

TCSQLExec( "DELETE FROM dClientes_Comercial"  )

cScript := " insert into dClientes_Comercial (Filial, Codigo, Loja, Tipo, Pessoa, Nome, NomeReduzido, Estado, Municipio, DataExtracao)"
cQuery := " Select A1_FILIAL Filial,
cQuery += " A1_COD Codigo, "
cQuery += " A1_LOJA Loja, "
cQuery += " A1_TIPO Tipo, "
cQuery += " A1_PESSOA Pessoa, "
cQuery += " A1_NOME Nome, "
cQuery += " A1_NREDUZ NomeReduzido, "
cQuery += " A1_EST Estado, "
cQuery += " A1_MUN Municipio, "
cQuery += " '"+cDataExtracao+"' DataExtracao"
cQuery += " from "+RetSQLName("SA1")+" SA1 "
cQuery += " where A1_FILIAL IN (" + cFiliais + ")"
cQuery += " and SA1.D_E_L_E_T_ = ''"

Memowrite("Qry_dClientes_Comercial.txt",cQuery)
TCSQLExec(cScript+cQuery)

//--------------------------------------------------------------
//-- Query para geracao do tabela dclientes_Comercial
//--------------------------------------------------------------
If !lAuto
	oProcess:IncRegua2('Processando tabela de Produtos')
Else
	ConOut('Processando tabela de Produtos')
Endif

TCSQLExec( "DELETE FROM dProdutos_Comercial"  )

cScript := " insert into dProdutos_Comercial (Filial, Codigo, Descricao, Tipo, CodigoItem, UnidadeMedida, Grupo, Marca, DataExtracao)"
cQuery := " Select B1_FILIAL Filial,
cQuery += " B1_COD Codigo, "
cQuery += " B1_DESC Descricao, "
cQuery += " B1_TIPO Tipo, "
cQuery += " B1_CODITE CodigoItem, "
cQuery += " B1_UM UnidadeMedida, "
cQuery += " B1_GRUPO Grupo, "
cQuery += " B1_MARCA Marca, "
cQuery += " '"+cDataExtracao+"' DataExtracao"
cQuery += " from "+RetSQLName("SB1")+" SB1 "
cQuery += " where B1_FILIAL IN (" + cFiliais + ")"
cQuery += " and SB1.D_E_L_E_T_ = ''"

Memowrite("Qry_dProdutos_Comercial.txt",cQuery)
TCSQLExec(cScript+cQuery)

//--------------------------------------------------------------
//-- Query para geracao do tabela dVeiculos_Comercial
//--------------------------------------------------------------
If !lAuto
	oProcess:IncRegua2('Processando tabela de Veiculos')
Else
	ConOut('Processando tabela de Veiculos')
Endif
TCSQLExec( "DELETE FROM dVeiculos_Comercial"  )

cScript := " insert into dVeiculos_Comercial (Filial, ChassisInterno, Segmento, Placa, Chassis, DataExtracao)"
cQuery := " Select VV1_FILIAL Filial,
cQuery += " VV1_CHAINT ChassisInterno, "
cQuery += " VV1_SEGMOD Segmento , "
cQuery += " VV1_PLAVEI Placa, "
cQuery += " VV1_CHASSI Chassis, "
cQuery += " '"+cDataExtracao+"' DataExtracao"
cQuery += " from "+RetSQLName("VV1")+" VV1 "
cQuery += " where VV1_FILIAL IN (" + cFiliais + ")"
cQuery += " and VV1.D_E_L_E_T_ = ''"

Memowrite("Qry_dVeiculos_Comerciall.txt",cQuery)
TCSQLExec(cScript+cQuery)


//--------------------------------------------------------------
//-- Query para geracao do tabela dGrupoProduto_Comercial
//--------------------------------------------------------------
If !lAuto
	oProcess:IncRegua2('Processando tabela de Grupo de Produto')
Else
	ConOut('Processando tabela de Grupo de Produto')
Endif

//TCSQLExec( "DELETE FROM dGrupoProduto_Comercial"  )

cScript := " insert into dGrupoProduto_Comercial (Filial, Grupo, Descricao, Marca, DataExtracao)"
cQuery := " Select BM_FILIAL Filial,
cQuery += " BM_GRUPO Grupo, "
cQuery += " BM_DESC Descricao, "
cQuery += " BM_CODMAR Marca, "
cQuery += " '"+cDataExtracao+"' DataExtracao"
cQuery += " from "+RetSQLName("SBM")+" SBM "
cQuery += " where BM_FILIAL IN (" + cFiliais + ")"
cQuery += " and SBM.D_E_L_E_T_ = ''"

Memowrite("Qry_dGrupoProduto_Comercial.txt",cQuery)
TCSQLExec(cScript+cQuery)

//--------------------------------------------------------------
//-- Query para geracao do tabela dVendedores_Comercial
//--------------------------------------------------------------
If !lAuto
	oProcess:IncRegua2('Processando tabela de Vendedores')
Else
	ConOut('Processando tabela de Vendedores')
Endif
TCSQLExec( "DELETE FROM dVendedores_Comercial" )

cScript := " insert into dVendedores_Comercial (Filial, Codigo, Nome, NomeReduzido, Gerente, Supervisor, DataExtracao)"
cQuery := " Select A3_FILIAL Filial,
cQuery += " A3_COD Grupo, "
cQuery += " A3_NOME Nome, "
cQuery += " A3_NREDUZ NomeReduzido, "
cQuery += " A3_GEREN Gerente, "
cQuery += " A3_SUPER Supervisor, "
cQuery += " '"+cDataExtracao+"' DataExtracao"
cQuery += " from "+RetSQLName("SA3")+" SA3 "
cQuery += " where A3_FILIAL IN (" + cFiliais + ")"
cQuery += " and A3_MSBLQL <> '1' "
cQuery += " and SA3.D_E_L_E_T_ = ''"

Memowrite("Qry_dVendedores_Comercial.txt",cQuery)
TCSQLExec(cScript+cQuery)

//--------------------------------------------------------------
//-- Query para geracao do tabela fItensNotaFiscal_Comercial
//--------------------------------------------------------------
If !lAuto
	oProcess:IncRegua2('Processando tabela de Itens de Nota Fiscal - Saídas')
Else
	ConOut('Processando tabela de Itens de Nota Fiscal - Saídas')
Endif

TCSQLExec( "DELETE FROM fItensNotaFiscal_Comercial" )

cScript := " insert into fItensNotaFiscal_Comercial (Filial, Data, NotaFiscal, Serie, Item, TipoNotaFiscal,  "
cScript += " CodigoFiscal, DescricaoFiscal, Tes, Produto, GrupoProduto, ItemMaquina, Cliente, LojaCliente,   "
cScript += " Quantidade, PrecoVenda, ValorTotal, ValorIcms, ValorPis, ValorCofins, ValorIss, ValorCsll, ValorIpi,"
cScript += " ValorSeguro, ValorFrete, ValorDesconto, ValorCusto, CentroCusto, ClasseValor, MovimentaFinanceiro, "
cScript += " MovimentaEstoque, NotaFiscalOrigem, SerieOrigem, Prefixo, PrefixoOrigem, Vendedor1, Vendedor2, "
cScript += " Vendedor3, Vendedor4, Vendedor5, Comissao1, Comissao2, Comissao3, Comissao4, Comissao5, ComissRep, "
cScript += " Armazem, TipoOperacao, BIOperacao, PeriodoInicialExtracao, PeriodoFinalExtracao, DataExtracao)"
cQuery := " Select D2_FILIAL Filial,
cQuery += " SUBSTRING(D2_EMISSAO,7,2)+'/'+SUBSTRING(D2_EMISSAO,5,2)+'/'+SUBSTRING(D2_EMISSAO,1,4) Data, "
cQuery += " D2_DOC NotaFiscal, "
cQuery += " D2_SERIE Serie, "
cQuery += " D2_ITEM Item, "
cQuery += " D2_TIPO TipoNotaFiscal, "
cQuery += " D2_CF CodigoFiscal, "
cQuery += " F4_TEXTO DescricaoFiscal, "
cQuery += " D2_TES Tes, "
cQuery += " D2_COD Produto, "
cQuery += " B1_GRUPO GrupoProduto, "
cQuery += " B1_CODITE ItemMaquina, "
cQuery += " D2_CLIENTE Cliente, "
cQuery += " D2_LOJA LojaCliente, "
cQuery += " D2_QUANT Quantidade, "
cQuery += " D2_PRCVEN PrecoVenda, "
cQuery += " D2_TOTAL ValorTotal, "
cQuery += " D2_VALICM ValorIcms, "
cQuery += " D2_VALIMP6 ValorPis, "
cQuery += " D2_VALIMP5 ValorCofins, "
cQuery += " D2_VALISS ValorIss, "
cQuery += " D2_VALCSL ValorCsll, "

// DWT Luciano - 20240103
cQuery += " D2_VALIPI ValorIpi, "

cQuery += " D2_SEGURO ValorSeguro, "
cQuery += " D2_VALFRE ValorFrete, "
cQuery += " D2_DESCON ValorDesconto, "
cQuery += "			Case  "
cQuery += "			   When F4_BIOPERA ='02' THEN 0 "
cQuery += "			   When F4_BIOPERA<>'02' THEN D2_CUSTO1 "
cQuery += "			end as ValorCusto, "
cQuery += " D2_CCUSTO CentroCusto, "
cQuery += " D2_CLVL ClasseValor, "
cQuery += " F4_DUPLIC MovimentaFinanceiro, "
cQuery += " F4_ESTOQUE MovimentaEstoque, "
cQuery += " D2_NFORI NotaFiscalOrigem, "
cQuery += " D2_SERIORI SerieOrigem, "
cQuery += " F2_PREFIXO Prefixo, "
cQuery += " F2_PREFORI PrefixoOrigem, "
cQuery += " F2_VEND1 Vendedor1, "
cQuery += " F2_VEND2 Vendedor2, "
cQuery += " F2_VEND3 Vendedor3, "
cQuery += " F2_VEND4 Vendedor4, "
cQuery += " F2_VEND5 Vendedor5, "
cQuery += " D2_COMIS1 Comissao1, "
cQuery += " D2_COMIS2 Comissao2, "
cQuery += " D2_COMIS3 Comissao3, "
cQuery += " D2_COMIS4 Comissao4, "
cQuery += " D2_COMIS5 Comissao5, "
cQuery += " C5_PERCREP ComissRep, "
cQuery += " D2_LOCAL Armazem, "
cQuery += " 'Saidas' TipoOperacao, "
cQuery += " F4_BIOPERA BIOperacao, "
cQuery += " '"+Dtoc(mv_par01)+"' PeriodoInicialExtracao,"
cQuery += " '"+Dtoc(mv_par02)+"' PeriodoFinalExtracao,"
cQuery += " '"+cDataExtracao+"' DataExtracao"
cQuery += " from "+RetSQLName("SD2")+" SD2, "+RetSQLName("SB1")+" SB1, "+RetSQLName("SF4")+" SF4, "
cQuery +=         +RetSQLName("SF2")+" SF2, "+RetSQLName("SC5")+" SC5 "
cQuery += " where D2_FILIAL IN (" + cFiliais + ")"
cQuery += " and B1_FILIAL IN (" + cFiliais + ") AND B1_COD = D2_COD "
//cQuery += " and F4_FILIAL IN (" + cFiliais + ") AND F4_CODIGO = D2_TES AND F4_DUPLIC = 'S' "
cQuery += " and F4_FILIAL = D2_FILIAL and F4_CODIGO = D2_TES "
cQuery += " and D2_FILIAL = F2_FILIAL and D2_DOC = F2_DOC and D2_SERIE = F2_SERIE and D2_CLIENTE = F2_CLIENTE and D2_LOJA = F2_LOJA and SF2.D_E_L_E_T_ = ' '"
cQuery += " and D2_FILIAL = C5_FILIAL and D2_PEDIDO = C5_NUM and SC5.D_E_L_E_T_ = ' '"
//cQuery += " and D2_FILIAL = C5_FILIAL and D2_DOC = C5_NOTA and D2_SERIE = C5_SERIE and SC5.D_E_L_E_T_ = ' '"
//cQuery += " and D2_TIPO NOT IN ('D','B') "
cQuery += " and D2_EMISSAO between '"+Dtos(MV_PAR01)+"' and '"+Dtos(MV_PAR02)+"'" 
cQuery += " and SF2.D_E_L_E_T_ = ''"
cQuery += " and SD2.D_E_L_E_T_ = ''"
cQuery += " and SB1.D_E_L_E_T_ = ''"
cQuery += " and SF4.D_E_L_E_T_ = ''"

Memowrite("Qry_fItensNotaFiscal_Comercial_D2.txt",cQuery)
TCSQLExec(cScript+cQuery)

//--------------------------------------------------------------
//-- Query para geracao do tabela fItensNotaFiscal_Comercial
//--------------------------------------------------------------
If !lAuto
	oProcess:IncRegua2('Processando tabela de Itens de Nota Fiscal - Entradas')
Else
	ConOut('Processando tabela de Itens de Nota Fiscal - Entradas')
Endif

cScript := " insert into fItensNotaFiscal_Comercial (Filial, Data, NotaFiscal, Serie, Item, TipoNotaFiscal, CodigoFiscal, DescricaoFiscal, Tes, Produto, GrupoProduto, ItemMaquina, Cliente, LojaCliente, Quantidade, PrecoVenda, ValorTotal, ValorIcms, ValorPis, ValorIss, ValorCsll, ValorCofins, ValorIpi, ValorSeguro, ValorFrete, ValorDesconto, ValorCusto, CentroCusto, ClasseValor, MovimentaFinanceiro, MovimentaEstoque, NotaFiscalOrigem, SerieOrigem, Prefixo, PrefixoOrigem, Vendedor1, Vendedor2, Vendedor3, Vendedor4, Vendedor5, Comissao1, Comissao2, Comissao3, Comissao4, Comissao5, ComissRep, Armazem, TipoOperacao, BIOperacao, PeriodoInicialExtracao, PeriodoFinalExtracao, DataExtracao)"
cQuery := " Select D1_FILIAL Filial,
cQuery += " SUBSTRING(D1_EMISSAO,7,2)+'/'+SUBSTRING(D1_EMISSAO,5,2)+'/'+SUBSTRING(D1_EMISSAO,1,4) Data, "
cQuery += " D1_DOC NotaFiscal, "
cQuery += " D1_SERIE Serie, "
cQuery += " D1_ITEM Item, "
cQuery += " D1_TIPO TipoNotaFiscal, "
cQuery += " D1_CF CodigoFiscal, "
cQuery += " F4_TEXTO DescricaoFiscal, "
cQuery += " D1_TES Tes, "
cQuery += " D1_COD Produto, "
cQuery += " B1_GRUPO GrupoProduto, "
cQuery += " B1_CODITE ItemMaquina, "
cQuery += " D1_FORNECE Cliente, "
cQuery += " D1_LOJA LojaCliente, "
cQuery += " D1_QUANT Quantidade, "
cQuery += " D1_VUNIT PrecoVenda, "
cQuery += " D1_TOTAL ValorTotal, "
cQuery += " D1_VALICM ValorIcms, "
cQuery += " D1_VALIMP6 ValorPis, "
cQuery += " D1_VALISS ValorIss, "
cQuery += " D1_VALCSL ValorCsll, "
cQuery += " D1_VALIMP5 ValorCofins, "

// DWt Luciano - 20240103
cQuery += " D1_VALIPI ValorIpi, "

cQuery += " D1_SEGURO ValorSeguro, "
cQuery += " D1_VALFRE ValorFrete, "
cQuery += " D1_VALDESC ValorDesconto, "
cQuery += "			Case  "
cQuery += "			   When F4_BIOPERA ='02' THEN 0 "
cQuery += "			   When F4_BIOPERA<>'02' THEN D1_CUSTO "
cQuery += "			end as ValorCusto, "
cQuery += " D1_CC CentroCusto, "
cQuery += " D1_CLVL ClasseValor, "
cQuery += " F4_DUPLIC MovimentaFinanceiro, "
cQuery += " F4_ESTOQUE MovimentaEstoque, "
cQuery += " D1_NFORI NotaFiscalOrigem, "
cQuery += " D1_SERIORI SerieOrigem, "
cQuery += " F1_PREFIXO Prefixo, "
cQuery += " ' ' PrefixoOrigem, "
cQuery += " ' ' Vendedor1, "
cQuery += " ' ' Vendedor2, "
cQuery += " ' ' Vendedor3, "
cQuery += " ' ' Vendedor4, "
cQuery += " ' ' Vendedor5, "
cQuery += " 0 Comissao1, "
cQuery += " 0 Comissao2, "
cQuery += " 0 Comissao3, "
cQuery += " 0 Comissao4, "
cQuery += " 0 Comissao5, "
cQuery += " 0 ComissRep, "
cQuery += " D1_LOCAL Armazem, "
cQuery += " 'Entradas' TipoOperacao, "
cQuery += " F4_BIOPERA BIOperacao, "
cQuery += " '"+Dtoc(MV_PAR01)+"' PeriodoInicialExtracao,"
cQuery += " '"+Dtoc(MV_PAR02)+"' PeriodoFinalExtracao,"
cQuery += " '"+cDataExtracao+"' DataExtracao"
cQuery += " from "+RetSQLName("SD1")+" SD1, "+RetSQLName("SB1")+" SB1, "+RetSQLName("SF4")+" SF4, "+RetSQLName("SF1")+" SF1 "
cQuery += " where D1_FILIAL IN (" + cFiliais + ")"
cQuery += " and B1_FILIAL IN (" + cFiliais + ") and B1_COD = D1_COD "
cQuery += " and F4_FILIAL = D1_FILIAL and F4_CODIGO = D1_TES "
//cQuery += " and F4_FILIAL IN (" + cFiliais + ") AND F4_CODIGO = D1_TES AND F4_DUPLIC = 'S' "
//cQuery += " and D1_TIPO = 'D' "                       
cQuery += " and D1_FILIAL = F1_FILIAL and D1_DOC = F1_DOC and D1_SERIE = F1_SERIE and D1_FORNECE = F1_FORNECE and D1_LOJA = F1_LOJA "
cQuery += " and D1_EMISSAO between '"+Dtos(MV_PAR01)+"' and '"+Dtos(MV_PAR02)+"'"
cQuery += " and SD1.D_E_L_E_T_ = ''"
cQuery += " and SB1.D_E_L_E_T_ = ''"
cQuery += " and SF4.D_E_L_E_T_ = ''"
cQuery += " and SF1.D_E_L_E_T_ = ''"

Memowrite("Qry_fItensNotaFiscal_Comercial_D1_1.txt",cScript)
Memowrite("Qry_fItensNotaFiscal_Comercial_D1.txt",cQuery)
TCSQLExec(cScript+cQuery)

//--------------------------------------------------------------
//-- Query para geracao do tabela fMetasVendas_Comercial
//--------------------------------------------------------------
If !lAuto
	oProcess:IncRegua2('Processando tabela de Metas de Vendas')
Else
	ConOut('Processando tabela de Metas de Vendas')
Endif

TCSQLExec( "DELETE FROM fMetasVendas_Comercial"  )

cScript := " insert into fMetasVendas_Comercial (Filial, Data, Vendedor, Gerente, Supervisor, Regiao, Categoria, Tipo, Grupo, Marca, Produto, TipoOperacao, CentroCusto, ClasseValor, ItemConta, Moeda, Quantidade, Valor, PeriodoInicialExtracao, PeriodoFinalExtracao,  DataExtracao)"
cQuery := " Select CT_FILIAL Filial,
cQuery += " SUBSTRING(CT_DATA,7,2)+'/'+SUBSTRING(CT_DATA,5,2)+'/'+SUBSTRING(CT_DATA,1,4) Data, "
cQuery += " CT_VEND Vendedor, "
cQuery += " CT_GERENTE Gerente, "
cQuery += " CT_SUPERVI Supervisor, "
cQuery += " CT_REGIAO Regiao, "
cQuery += " CT_CATEGO Categoria, "
cQuery += " CT_TIPO Tipo, "
cQuery += " CT_GRUPO Grupo, "
cQuery += " CT_MARCA Marca, "
cQuery += " CT_PRODUTO Produto, "
cQuery += " CT_TPOPER TipoOperacao, "
cQuery += " CT_CCUSTO CentroCusto, "
cQuery += " CT_CLVL ClasseValor, "
cQuery += " CT_ITEMCC ItemConta, "
cQuery += " CT_MOEDA Moeda, "
cQuery += " CT_QUANT Quantidade, "
cQuery += " CT_VALOR Valor, "
cQuery += " '"+Dtoc(MV_PAR01)+"' PeriodoInicialExtracao,"
cQuery += " '"+Dtoc(MV_PAR02)+"' PeriodoFinalExtracao,"
cQuery += " '"+cDataExtracao+"' DataExtracao"
cQuery += " from "+RetSQLName("SCT")+" SCT "
cQuery += " where CT_FILIAL IN (" + cFiliais + ")"
cQuery += " and SCT.D_E_L_E_T_ = ''"

Memowrite("Qry_fMetasVendas_Comercial.txt",cQuery)
TCSQLExec(cScript+cQuery)


//--------------------------------------------------------------
//-- Query para geracao do tabela fSaldoEstoque_Comercial
//--------------------------------------------------------------
If !lAuto
	oProcess:IncRegua2('Processando tabela de Saldos de Estoque')
Else
	ConOut('Processando tabela de Saldos de Estoque')
Endif

TCSQLExec( "DELETE FROM fSaldoEstoque_Comercial"  )

cScript := " insert into fSaldoEstoque_Comercial (Filial, Produto, Local, SaldoAtual, CustoUnitario, QtdEmpenhada, QtdReservada, QtdPedidoVenda, QtdPrevistaEntrar, DataExtracao)"
cQuery := " Select B2_FILIAL Filial,
cQuery += " B2_COD Produto, "
cQuery += " B2_LOCAL Local, "
cQuery += " B2_QATU SaldoAtual, "
cQuery += " B2_CM1 CustoUnitario, "
cQuery += " B2_QEMP QtdEmpenhada, "
cQuery += " B2_RESERVA QtdReservada, "
cQuery += " B2_QPEDVEN QtdPedidoVenda, "
cQuery += " B2_SALPEDI QtdPrevistaEntrar, "
cQuery += " '"+cDataExtracao+"' DataExtracao"
cQuery += " from "+RetSQLName("SB2")+" SB2 "
cQuery += " where B2_FILIAL IN (" + cFiliais + ")"
cQuery += " and SB2.D_E_L_E_T_ = ''"

Memowrite("Qry_fSaldoEstoque_Comercial.txt",cQuery)
TCSQLExec(cScript+cQuery)

//--------------------------------------------------------------
//-- Query para geracao do tabela fSaldoEstoque_Comercial
//--------------------------------------------------------------
If !lAuto
	oProcess:IncRegua2('Processando tabela de Fechamento de Estoque')
Else
	ConOut('Processando tabela de Fechamento de Estoque')
Endif

TCSQLExec( "DELETE FROM fFechamentoEstoque_Comercial"  )

cScript := " insert into fFechamentoEstoque_Comercial (Filial, Produto, Local, QtdInicioMes, CustoUnitario, SaldoInicioMes, DataFechamento, PeriodoInicialExtracao, PeriodoFinalExtracao, DataExtracao)"
cQuery := " Select B9_FILIAL Filial,
cQuery += " B9_COD Produto, "
cQuery += " B9_LOCAL Local, "
cQuery += " B9_QINI QtdInicioMes, "
cQuery += " B9_CM1 CustoUnitario, "
cQuery += " B9_VINI1 SaldoInicioMes, "
cQuery += " SUBSTRING(B9_DATA,7,2)+'/'+SUBSTRING(B9_DATA,5,2)+'/'+SUBSTRING(B9_DATA,1,4) DataFechamento, "
cQuery += " '"+Dtoc(MV_PAR01)+"' PeriodoInicialExtracao,"
cQuery += " '"+Dtoc(MV_PAR02)+"' PeriodoFinalExtracao,"
cQuery += " '"+cDataExtracao+"' DataExtracao"
cQuery += " from "+RetSQLName("SB9")+" SB9 "
cQuery += " where B9_FILIAL IN (" + cFiliais + ")"
cQuery += " and B9_DATA between '"+Dtos(MV_PAR01)+"' and '"+Dtos(MV_PAR02)+"'"
cQuery += " and SB9.D_E_L_E_T_ = ''"

Memowrite("Qry_fFechamentoEstoque_Comercial.txt",cQuery)
TCSQLExec(cScript+cQuery)

//--------------------------------------------------------------
//-- Query para geracao do tabela fOrdemServico_Comercial
//--------------------------------------------------------------
If !lAuto
	oProcess:IncRegua2('Processando tabela de Ordem de Servico Veiculo')
Else
	ConOut('Processando tabela de Ordem de Servico Veiculo')
Endif


TCSQLExec( "DELETE FROM fOrdemServico_Comercial"  )

cScript := " insert into fOrdemServico_Comercial (Filial, NumeroOS, ChassiVeiculo, ChassisInterno, PlacaVeiculo, AberturaOS, PeriodoInicialExtracao, PeriodoFinalExtracao, DataExtracao)"
cQuery := " Select VO1_FILIAL Filial,
cQuery += " VO1_NUMOSV NumeroOS, "
cQuery += " VO1_CHASSI ChassiVeiculo, "
cQuery += " VO1_CHAINT ChassisInterno, "
cQuery += " VO1_PLAVEI PlacaVeiculo, "
cQuery += " SUBSTRING(VO1_DATABE,7,2)+'/'+SUBSTRING(VO1_DATABE,5,2)+'/'+SUBSTRING(VO1_DATABE,1,4) AberturaOS, "
cQuery += " '"+Dtoc(MV_PAR01)+"' PeriodoInicialExtracao,"
cQuery += " '"+Dtoc(MV_PAR02)+"' PeriodoFinalExtracao,"
cQuery += " '"+cDataExtracao+"' DataExtracao"
cQuery += " from "+RetSQLName("VO1")+" VO1 "
cQuery += " where VO1_FILIAL IN (" + cFiliais + ")"
cQuery += " and VO1_DATABE between '"+Dtos(MV_PAR01)+"' and '"+Dtos(MV_PAR02)+"'"
cQuery += " and VO1.D_E_L_E_T_ = ''"

Memowrite("Qry_fOrdemServico_Comercial.txt",cQuery)
TCSQLExec(cScript+cQuery)

//--------------------------------------------------------------
//-- Query para geracao do tabela dTipoProduto_Comercial
//--------------------------------------------------------------
If !lAuto
	oProcess:IncRegua2('Processando tabela de Tipos de Produto')
Else
	ConOut('Processando tabela de Tipos de Produto')
Endif
TCSQLExec( "DELETE FROM dTipoProduto_Comercial"  )

cScript := " insert into dTipoProduto_Comercial (Filial, Codigo, Descricao, DataExtracao)"
cQuery := " Select X5_FILIAL Filial,
cQuery += " X5_CHAVE Codigo, "
cQuery += " X5_DESCRI Descricao , "
cQuery += " '"+cDataExtracao+"' DataExtracao"
cQuery += " from "+RetSQLName("SX5")+" SX5 "
cQuery += " where X5_FILIAL IN (" + cFiliais + ")"
cQuery += " and X5_TABELA = '02'"
cQuery += " and SX5.D_E_L_E_T_ = ''"

Memowrite("Qry_dTipoProduto_Comercial.txt",cQuery)
TCSQLExec(cScript+cQuery)

// Tabelas Especificas MA HOSPITALAR

	//--------------------------------------------------------------
	//-- Query para geracao do tabela dRegiao_Comercial
	//--------------------------------------------------------------
	If !lAuto
		oProcess:IncRegua2('Processando tabela de Regioes')
	Else
		ConOut('Processando tabela de Regioes')
	Endif
	TCSQLExec( "DELETE FROM dRegiao_Comercial"  )

	cScript := " insert into dRegiao_Comercial (Filial, Codigo, Descricao, DataExtracao)"
	cQuery := " Select X5_FILIAL Filial,
	cQuery += " X5_CHAVE Codigo, "
	cQuery += " X5_DESCRI Descricao , "
	cQuery += " '"+cDataExtracao+"' DataExtracao"
	cQuery += " from "+RetSQLName("SX5")+" SX5 "
	cQuery += " where X5_FILIAL IN (" + cFiliais + ")"
	cQuery += " and X5_TABELA = 'A2'"
	cQuery += " and SX5.D_E_L_E_T_ = ''"

	Memowrite("Qry_dRegiao_Comercial.txt",cQuery)
	TCSQLExec(cScript+cQuery)


	//--------------------------------------------------------------
	//-- Query para geracao do tabela dMarca_Comercial
	//--------------------------------------------------------------
	If !lAuto
		oProcess:IncRegua2('Processando tabela de Marcas')
	Else
		ConOut('Processando tabela de Marcas')
	Endif
	TCSQLExec( "DELETE FROM dMarca_Comercial"  )

	cScript := " insert into dMarca_Comercial (Filial, Codigo, Descricao, DataExtracao)"
	cQuery := " Select X5_FILIAL Filial,
	cQuery += " X5_CHAVE Codigo, "
	cQuery += " X5_DESCRI Descricao , "
	cQuery += " '"+cDataExtracao+"' DataExtracao"
	cQuery += " from "+RetSQLName("SX5")+" SX5 "
	cQuery += " where X5_FILIAL IN (" + cFiliais + ")"
	cQuery += " and X5_TABELA = 'ZX'"
	cQuery += " and SX5.D_E_L_E_T_ = ''"

	Memowrite("Qry_dMarca_Comercial.txt",cQuery)
	TCSQLExec(cScript+cQuery)


	//--------------------------------------------------------------
	//-- Query para geracao do tabela dCategoria_Comercial
	//--------------------------------------------------------------
	If !lAuto
		oProcess:IncRegua2('Processando tabela de Gategorias')
	Else
		ConOut('Processando tabela de Categorias')
	Endif
	TCSQLExec( "DELETE FROM dCategoria_Comercial"  )

	cScript := " insert into dCategoria_Comercial (Filial, Codigo, Descricao, DataExtracao)"
	cQuery := " Select ACU_FILIAL Filial,
	cQuery += " ACU_COD Codigo, "
	cQuery += " ACU_DESC Descricao , "
	cQuery += " '"+cDataExtracao+"' DataExtracao"
	cQuery += " from "+RetSQLName("ACU")+" ACU "
	cQuery += " where ACU_FILIAL IN (" + cFiliais + ")"
	cQuery += " and ACU.D_E_L_E_T_ = ''"

	Memowrite("Qry_dCategoria_Comercial.txt",cQuery)
	TCSQLExec(cScript+cQuery)       
	
	//--------------------------------------------------------------
	//-- Query para geracao do tabela dTipoVenda_Comercial
	//--------------------------------------------------------------
	If !lAuto
		oProcess:IncRegua2('Processando tabela de Tipo de Venda')
	Else
		ConOut('Processando tabela de Tipo de Venda')
	Endif
	TCSQLExec( "DELETE FROM dTipoVenda_Comercial"  ) 
	
	cScript := " Insert Into dTipoVenda_Comercial (Codigo, Descricao)"	
	cQuery := " Values "
	cQuery += " ('01','Revenda'),"
	cQuery += " ('02','Representação')"                
  
	Memowrite("Qry_dTipoVenda_Comercial.txt",cQuery)
	TCSQLExec(cScript+cQuery)       
                                               

	//--------------------------------------------------------------
	//-- Query para geracao do tabela dTipoVendaFiscal_Comercial
	//--------------------------------------------------------------
	If !lAuto
		oProcess:IncRegua2('Processando tabela de Tipo de Venda Fiscal')
	Else
		ConOut('Processando tabela de Tipo de Venda Fiscal')
	Endif
	TCSQLExec( "DELETE FROM dTipoVendaFiscal_Comercial"  ) 
	
	cScript := " Insert Into dTipoVendaFiscal_Comercial (Codigo, Descricao)"	
	cQuery := " Values "
	cQuery += " ('01','Revenda'),"
	cQuery += " ('02','Representação'),"                
	cQuery += " ('03','Serviços'),"                
	cQuery += " ('04','Locação'),"                
	cQuery += " ('05','Transferência'),"                
	cQuery += " ('06','Remessas'),"                
	cQuery += " ('07','Devolução'),"              
	cQuery += " ('08','Entrada de Mercadorias'),"              
	cQuery += " ('09','Retorno'),"              
	cQuery += " ('10','Saída de Mercadorias')"              
	  
  
	Memowrite("Qry_dTipoVendaFiscal_Comercial.txt",cQuery)
	TCSQLExec(cScript+cQuery)       

// Fim das Tabelas Especificas MA HOSPITALAR

If !lAuto
	cMsg := "CI_M170 - Fim da execução do Data Mart Comercial"
	oProcess:SaveLog(cMsg)
Else
	ConOut("CI_M170 - Fim da execução do Data Mart Comercial")
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

aParam	:= { "P", "CI_M170", "", aOrd, }

Return( aParam )

