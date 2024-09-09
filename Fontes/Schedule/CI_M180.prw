#Include 'Totvs.ch'
#include 'topconn.ch'      

#DEFINE USADO CHR(0)+CHR(0)+CHR(1)
#DEFINE DATAFLUXO				1
#DEFINE ENTRADAS				2
#DEFINE SAIDAS					3
#DEFINE SALDODIA				4
#DEFINE VARIACAODIA				5
#DEFINE ENTRADASACUMULADAS		6
#DEFINE SAIDASACUMULADAS 		7
#DEFINE SALDOACUMULADO 			8
#DEFINE VARIACAOACUMULADA		9

Static cGetVersao := GetVersao(.f.,.f.)
Static lFWCodFil 	:= .T.
Static aSitCob		:= NIL
Static aPswUser		:= NIL
Static aPswGrupo	:= NIL
Static lConsDtB 	:= .F.
Static nValorPA		:= 0
Static _oFINC0211
Static _oFINC0212
Static _oFINC0213
Static _oFINC0214
Static _oFINC0215
Static _oFINC0216
Static _oFINC0217
Static _oFINC0218
Static _oFINC0219
Static _oFINC021a
Static _oFINC021b
Static _oFINC021c
Static _oFINC021d
Static _oFINC021e
Static _oFINC021f

/*/{Protheus.doc}
Funcao para Geracao do Data Mart fluxo de caixa
@author Jeferson Silva
@since 02/01/2020
@version 1.0
@return Nil,
@example
u_CI_M180()
/*/
User Function CI_M180()
Local aArea   	:= GetArea()
Local aInfo     := {}
Local cTitulo 	:= "Geracao do Data Fluco de Caixa"
Local bProcess  := {||}
Local oProcess  := Nil
Local aTabelas	:= {"SE8","SE1","SE2","SEV","SC5","SC7","SE3"}
Local lSchedule	:= IsBlind()

Private cPerg   := PadR("CI_M180",10)

If lSchedule// Chamada via Schedule
	//If RpcSetEnv(aParam[1],aParam[2],,,"FIN","CI_M180",aTabelas,,,,)

	cMsg := "CI_M180 - Inicio do Processando"
	ConOut(cMsg)
	BatchProcess(cTitulo, cTitulo,"CI_M180", { || M180Proc( oProcess,lSchedule ) }, { || .F. }  )
	//EndIf
	//RpcClearEnv()
Else
	//Cria a pergunta de entrada do MarkBrowser
	u_PutSX1( cPerg	, "01"	, "Periodo de:" 				, "mv_par01", "mv_ch1"	, "D"		, TamSX3('CT2_DATA')[1]		, 0			, "G"		, ""													, ""		, 			,				,				,			,			,			,		, ""		)
	u_PutSX1( cPerg	, "02"	, "Periodo ate:"				, "mv_par02", "mv_ch2"	, "D"		, TamSX3('CT2_DATA')[1]		, 0			, "G"		, ""													, ""		, 			,				,				,			,			,			,		, ""		)

	Pergunte(cPerg,.F.)

	aAdd( aInfo, { "Cancelar", 	{ |oPanelCenter| oPanelCenter:oWnd:End() },	"CANCEL"  })

	bProcess := { |oProcess| M180Proc( oProcess) }

	cDescRot := "Esta rotina tem como objetivo gerar o Data Mart Fluxo de Caixa."

	oProcess := TNewProcess():New( "CI_M180", cTitulo, bProcess, cDescRot, cPerg, aInfo,.F., 5,'Processamento', .T., .F.)
Endif

RestArea(aArea)
Return Nil

/*/{Protheus.doc}
Funcao para o processamento do Data Mart fluxo de caixa
@author Jeferson Silva
@since 02/01/2020
@version 1.0
@return Nil,
@example
Funcao Original Fc021Proc TOTVS - Claudio D. de Souza
u_M180Proc()
/*/
Static Function M180Proc(oProcess,lAuto)

Local cAlias		:= Alias()
Local cCampo		:= Right(cAlias,2)
Local nCaixas		:= 0										// Total em caixa
Local nBancos		:= 0										// Total em bancos
Local lReceber		:= .T.
Local lPagar		:= .T.
Local lComissoes	:= .T.
Local lPedVenda		:= .T.
Local lPedCompra	:= .T.
Local lAplicacoes	:= .T.
Local lSaldoBanc	:= .T.
Local lAnalitico	:= .T.
Local lConsFil		:= .T.
Local lConsDtBase	:= .F.
Local nTamFilial	:= IIf( lFWCodFil, FWGETTAMFILIAL, TamSx3(cCampo+"_FILIAL")[1] )
Local cFilDe		:= Space( nTamFilial )
Local cFilAte		:= Replicate( "Z", nTamFilial )
Local nMoeda		:= 1
Local cMoeda        := '01'
Local cPeriodo		:= '01'
Local nPeriodos		
Local lTitFuturo	:= .T.
Local lCtrc			:= .T.
Local nLimCred		:= 0										// Limite de credito bancario
Local lDMSCompra	:= .T.
Local lDMSVenda		:= .T.
Local aAplic		:= {}
Local cFilterSe1
Local cFilterSe2
Local cPedidos		:= "3"
Local cSinalRA		:= '-'
Local nX			:= 0
Local lSolFundo		:= .T.										//Considera as solicitacoes de fundo
//Variaveis da grid de selecao das situacoes dos titulos
Local lTxMoePed     := .F.

Local aArqTmp								// Nome do arquivo temporario e alias criado aleatoriamente
Local aArqCo								// Nome do arquivo temporario e alias para comiss�es
Local cSavFil								// Salva a Filial atual
Local aCalc									// Calculo de aplicacao
Local aAreaSM0			:= SM0->(GetArea())	// Salva a area do SM0
Local dDataTrab								// Data de trabalho
Local nAplicacao		:= 0				// Valor da aplicacao
Local nEmprestimo		:= 0				// Valor do emprestimo
Local nDias
Local nAtrReceber		:= 0
Local nAtrPagar			:= 0
Local aTmpAnaEmp
Local aTmpAnaApl
Local aTmpAnaCtrc		:= Array(2)
Local aTmpAnaSol		:= Array(2)
Local cAliasEmp
Local cAliasApl
Local cAliasPc
Local cAliasPv
Local cArqAnaPc
Local cAliasChq
Local aTotais			:= {{},{},{},{},{},{},{},{},{},{},{},{},{}}
Local aPeriodo			:= {}
Local aFluxo			:= {}
Local nAscan
Local nRecSeh
Local cAplCotas			:= GetMv("MV_APLCAL4")
Local cAliasDMSCompra
Local cAliasDMSVenda
Local nTotRegs			:= 0
Local lLibCheq			:= GetMv("MV_LIBCHEQ") == "N"	// Para controlar os cheques pendentes de liberacao
Local j					:= 0
Local i					:= 0
Local cFilSEF			:= ""
Local cSelFil			:= ""
Local lMVEffFin         := .F. // GetMV("MV_EFF_FIN",,.F.)
Local nDiasFC			:= SuperGetMV( "ES_DIASFC", .F., 365) // Dias a serem considerados no FC

Local cMsg  := ""

Default cVisaoG			:= ""
Default lSolFundo		:= .F.
Default lTxMoePed       := .F.

//Variaveis da grid de selecao das situacoes dos titulos
Private lFiliais	:= .F.
Private aSelFil		:= {}
Private cLisFil		:= ""

Pergunte("CI_M180",.F.)

If lAuto

	mv_par01 := Date()
	mv_par02 := Date() + nDiasFC
	
Endif

nPeriodos		:= mv_par02 - mv_par01

lConsDtB	:= .F.

nMoeda := Val(Left(cMoeda,2))
nDias  := Val(Left(cPeriodo,2)) * nPeriodos // Calcula quantos dias
If nDias <= 0
   nDias := 1
EndIf

// Gera os registros para todas as datas do periodo, inclusive a database
For nX := 1 To nDias
	If !lConsDtBase
		dDataTrab := (dDataBase + 1) + nX-1
	Else
		dDataTrab := dDataBase + nX-1
    EndIf

	TemFluxoData(dDataTrab,aFluxo)
	TemFluxoData(dDataTrab,aPeriodo)
Next nX
// Monta os periodos na matriz para ser utilizada na simulacao e na projecao
MontaPeriodo(aPeriodo,cPeriodo)

// Inicia o total de registros a srem processados para incrementar a regua
If lReceber
	nTotRegs += SE1->(RecCount())
Endif
If lPagar
	nTotRegs += SE2->(RecCount())
Endif
If lComissoes
	nTotRegs += SE3->(RecCount())
Endif
If lPedVenda
	nTotRegs += SC6->(RecCount())
Endif
If lPedCompra
	nTotRegs += SC7->(RecCount())
Endif
If lAplicacoes
	nTotRegs += SEH->(RecCount())
Endif
If lSaldoBanc
	nTotRegs += SE8->(RecCount())
Endif

cMsg := "CI_M180 - Processando o Data Mart Fluxo de Caixa..."

If !lAuto
	oProcess:SetRegua1(1)
	oProcess:IncRegua1(cMsg)
	oProcess:SetRegua2(nTotRegs) 
Else
	ConOut(cMsg)
Endif

cMsg := "CI_M180 - Criando Estrutura das Tabelas..."

If !lAuto
	oProcess:IncRegua2(cMsg)
Else
	ConOut(cMsg)
Endif
        
TCSQLExec( "DROP TABLE dFiliais" ) // Reestruturacao

If !TCCanOpen( "dFiliais" )
	
	cScript := " create table dFiliais("       
	cScript += " Filial varchar(12),"
	cScript += " NomeFilial varchar(60),"

	cScript += " PeriodoInicialExtracao varchar(10),"
	cScript += " PeriodoFinalExtracao varchar(10),"
	cScript += " DataExtracao varchar(35)"
	cScript += "  )"
	
	TCSQLExec( cScript )
Endif      

TCSQLExec( "DROP TABLE dProcessos" ) // Reestruturacao

If !TCCanOpen( "dProcessos" )
	
	cScript := " create table dProcessos("       
	cScript += " Apelido varchar(10),"
	cScript += " Descricao varchar(100)"
	cScript += "  )"
	
	TCSQLExec( cScript )
Endif      

TCSQLExec( "DROP TABLE fSaldosBancarios" ) // Reestruturacao

If !TCCanOpen( "fSaldosBancarios" )
	
	cScript := " create table fSaldosBancarios("
	
    cScript += " Filial varchar("+Str(TamSX3('E1_FILIAL')[1])+"),"
	cScript += " Data varchar(10),"
	cScript += " Valor float(8),"
    cScript += " BancoSB varchar("+Str(TamSX3('E8_BANCO')[1])+"),"
	cScript += " AgenciaSB varchar("+Str(TamSX3('E8_AGENCIA')[1])+"),"
	cScript += " ContaSB varchar("+Str(TamSX3('E8_CONTA')[1])+"),"
	cScript += " NomeSB varchar("+Str(TamSX3('A6_NOME')[1])+"),"
	cScript += " ChaveSB varchar("+Str(TamSX3('E8_BANCO')[1]+TamSX3('E8_AGENCIA')[1]+TamSX3('E8_CONTA')[1]+TamSX3('A6_NOME')[1]+10)+"),"
	cScript += " PeriodoInicialExtracao varchar(10),"
	cScript += " PeriodoFinalExtracao varchar(10),"
	cScript += " DataExtracao varchar(35)"
	cScript += "  )"
	
	TCSQLExec( cScript )
Endif         


TCSQLExec( "DROP TABLE fFluxodeCaixa" ) // Reestruturacao

If !TCCanOpen( "fFluxodeCaixa" )
	
	cScript := " create table fFluxodeCaixa("
	
    // Dados Gerais
    cScript += " Filial varchar("+Str(TamSX3('E1_FILIAL')[1])+"),"
	cScript += " Chave varchar(40),"
	cScript += " Apelido varchar(10),"
	cScript += " Periodo varchar(25),"	
	cScript += " Data varchar(10),"
	cScript += " Valor float(8),"
    
	// Dados Saldos Bancarios
    //cScript += " BancoSB varchar("+Str(TamSX3('E8_BANCO')[1])+"),"
	//cScript += " AgenciaSB varchar("+Str(TamSX3('E8_AGENCIA')[1])+"),"
	//cScript += " ContaSB varchar("+Str(TamSX3('E8_CONTA')[1])+"),"
	//cScript += " NomeSB varchar("+Str(TamSX3('A6_NOME')[1])+"),"

    // Dados Contas a Pagar
    cScript += " PrefixoCP varchar("+Str(TamSX3('E2_PREFIXO')[1])+"),"
	cScript += " NumeroCP varchar("+Str(TamSX3('E2_NUM')[1])+"),"
	cScript += " ParecelaCP varchar("+Str(TamSX3('E2_PARCELA')[1])+"),"
	cScript += " TipoCP varchar("+Str(TamSX3('E2_TIPO')[1])+"),"
	cScript += " NaturezaCP varchar("+Str(TamSX3('E2_NATUREZ')[1])+"),"
	cScript += " DescricaoNaturezaCP varchar("+Str(TamSX3('ED_DESCRIC')[1])+"),"
	cScript += " FornecedorCP varchar("+Str(TamSX3('E5_CLIFOR')[1])+"),"
	cScript += " NomeFornecedorCP varchar("+Str(TamSX3('A2_NOME')[1])+"),"
	cScript += " LojaCP varchar("+Str(TamSX3('A2_LOJA')[1])+"),"
 
	cScript += " EmissaoCP varchar(10),"
	cScript += " VencimentoCP varchar(10),"
	cScript += " VencimentoRealCP varchar(10),"
	cScript += " HistoricoCP varchar("+Str(TamSX3('E2_HIST')[1])+"),"

	// Dados Contas a Receber
    cScript += " PrefixoCR varchar("+Str(TamSX3('E1_PREFIXO')[1])+"),"
	cScript += " NumeroCR varchar("+Str(TamSX3('E1_NUM')[1])+"),"
	cScript += " ParecelaCR varchar("+Str(TamSX3('E1_PARCELA')[1])+"),"
	cScript += " TipoCR varchar("+Str(TamSX3('E1_TIPO')[1])+"),"
	cScript += " NaturezaCR varchar("+Str(TamSX3('E1_NATUREZ')[1])+"),"
	cScript += " DescricaoNaturezaCR varchar("+Str(TamSX3('ED_DESCRIC')[1])+"),"
	cScript += " ClienteCR varchar("+Str(TamSX3('E5_CLIFOR')[1])+"),"
	cScript += " NomeClienteCR varchar("+Str(TamSX3('A1_NOME')[1])+"),"
	cScript += " LojaCR varchar("+Str(TamSX3('A1_LOJA')[1])+"),"
	cScript += " SituacaoCR varchar(25),"
	cScript += " PortadorCR varchar("+Str(TamSX3('E1_PORTADO')[1])+"),"
	cScript += " AgenciaDepositarioCR varchar("+Str(TamSX3('E1_AGEDEP')[1])+"),"
	cScript += " ContaDepositarioCR varchar("+Str(TamSX3('E1_CONTA')[1])+"),"

	cScript += " EmissaoCR varchar(10),"
	cScript += " VencimentoCR varchar(10),"
	cScript += " VencimentoRealCR varchar(10),"
	cScript += " HistoricoCR varchar("+Str(TamSX3('E1_HIST')[1])+"),"
    
	// Dados Peidos de Compra
    cScript += " NumeroPC varchar("+Str(TamSX3('C7_NUM')[1])+"),"
	cScript += " EmissaoPC varchar(10),"
	cScript += " FornecedorPC varchar("+Str(TamSX3('C7_FORNECE')[1])+"),"
	cScript += " NumeFornecedorPC varchar("+Str(TamSX3('A2_NOME')[1])+"),"
	cScript += " TipoPC float(8),"
	cScript += " ItemPC varchar("+Str(TamSX3('C7_ITEM')[1])+"),"
	cScript += " ProdutoPC varchar("+Str(TamSX3('C7_PRODUTO')[1])+"),"
	cScript += " DescricaoProdutoPC varchar("+Str(TamSX3('B1_DESC')[1])+"),"

	// Dados Peidos de Venda
    cScript += " NumeroPV varchar("+Str(TamSX3('C5_NUM')[1])+"),"
	cScript += " EmissaoPV varchar(10),"
	cScript += " ClientePV varchar("+Str(TamSX3('E5_CLIFOR')[1])+"),"
	cScript += " NumeClientePV varchar("+Str(TamSX3('A1_NOME')[1])+"),"
	cScript += " TipoPV varchar("+Str(TamSX3('C5_TIPO')[1])+"),"
	cScript += " LojaEntradaPV varchar("+Str(TamSX3('C5_LOJAENT')[1])+"),"
	cScript += " LojaClientePV varchar("+Str(TamSX3('C5_LOJACLI')[1])+"),"

	// Dados Comissoes
    cScript += " PrefixoCO varchar("+Str(TamSX3('E3_PREFIXO')[1])+"),"
	cScript += " NumeroCO varchar("+Str(TamSX3('E3_NUM')[1])+"),"
	cScript += " ParcelaCO varchar("+Str(TamSX3('E3_PARCELA')[1])+"),"
	cScript += " VendedorCO varchar("+Str(TamSX3('E3_VEND')[1])+"),"
	cScript += " NomeVendedorCO varchar("+Str(TamSX3('A3_NOME')[1])+"),"

	// Dados Emprestimos
	cScript += " NumeroEMP varchar("+Str(TamSX3('EH_NUMERO')[1])+"),"
	cScript += " BancoEMP varchar("+Str(TamSX3('EH_BANCO')[1])+"),"
	cScript += " AgenciaEMP varchar("+Str(TamSX3('EH_AGENCIA')[1])+"),"
	cScript += " ContaEMP varchar("+Str(TamSX3('EH_CONTA')[1])+"),"
	cScript += " EmissaoEMP varchar(10),"

	// Dados Aplicacao
	cScript += " NumeroAPL varchar("+Str(TamSX3('EH_NUMERO')[1])+"),"
	cScript += " BancoAPL varchar("+Str(TamSX3('EH_BANCO')[1])+"),"
	cScript += " AgenciaAPL varchar("+Str(TamSX3('EH_AGENCIA')[1])+"),"
	cScript += " ContaAPL varchar("+Str(TamSX3('EH_CONTA')[1])+"),"
	cScript += " EmissaoAPL varchar(10),"

	// Dados Cheques
	cScript += " NumeroCHQ varchar("+Str(TamSX3('EF_NUM')[1])+"),"
	cScript += " BancoCHQ varchar("+Str(TamSX3('EF_BANCO')[1])+"),"
	cScript += " AgenciaCHQ varchar("+Str(TamSX3('EF_AGENCIA')[1])+"),"
	cScript += " ContaCHQ varchar("+Str(TamSX3('EF_CONTA')[1])+"),"
	cScript += " EmissaoCHQ varchar(10),"

	// Dados CTRC
	cScript += " FilialDebitoCTR varchar("+Str(TamSX3('DT6_FILDEB')[1])+"),"
	cScript += " FilialDocumentoCTR varchar("+Str(TamSX3('DT6_FILDOC')[1])+"),"
	cScript += " DocumentoCTR varchar("+Str(TamSX3('DT6_DOC')[1])+"),"
	cScript += " SerieCTR varchar("+Str(TamSX3('DT6_SERIE')[1])+"),"
	cScript += " EmissaoCTR varchar(10),"	

	// Dados Solicitacoes de Fundos
	cScript += " SolcitacaoSOL varchar("+Str(TamSX3('FJA_SOLFUN')[1])+"),"
	cScript += " FornecedorSOL varchar("+Str(TamSX3('FJA_FORNEC')[1])+"),"
	cScript += " LojaSOL varchar("+Str(TamSX3('FJA_LOJA')[1])+"),"
	cScript += " PrevisaoPagamentoSOL varchar(10),"	
	
	// Dados Peidos de Compra DMS
    cScript += " CodigoDMSC varchar("+Str(TamSX3('VQ0_CODIGO')[1])+"),"
	cScript += " PedidoDMSC varchar("+Str(TamSX3('VQ0_NUMPED')[1])+"),"
	cScript += " EmissaoDMSC varchar(10),"	
	cScript += " ChassiDMSC varchar("+Str(TamSX3('VQ0_CHASSI')[1])+"),"
	cScript += " ModeloDMSC varchar("+Str(TamSX3('VQ0_MODVEI')[1])+"),"

	// Dados Peidos de Venda DMS
    cScript += " NumeroDMSV varchar("+Str(TamSX3('VV0_NUMTRA')[1])+"),"
	cScript += " ClienteDMSV varchar("+Str(TamSX3('E5_CLIFOR')[1])+"),"
	cScript += " LojaDMSV varchar("+Str(TamSX3('C5_LOJAENT')[1])+"),"
	cScript += " NomeClienteDMSV varchar("+Str(TamSX3('A1_NOME')[1])+"),"
	cScript += " EmissoaDMSV varchar(10),"	

	cScript += " PeriodoInicialExtracao varchar(10),"
	cScript += " PeriodoFinalExtracao varchar(10),"
	cScript += " DataExtracao varchar(35)"
	cScript += "  )"

	TCSQLExec( cScript )
	
EndIf

If lFiliais
	cFilDe  := aSelFil[1]
	cFilAte := aSelFil[Len(aSelFil)]
Endif

If lAplicacoes
	If lAnalitico
	   aTmpAnaEmp := CriaTmpAna(1) // Cria o arquivo temporario analitico de emprestimos
	   cAliasEmp  := aTmpAnaEmp[1]
	   aTmpAnaApl := CriaTmpAna(2) // Cria o arquivo temporario analitico de aplicacoes
	   cAliasApl  := aTmpAnaApl[1]
	EndIf

	For j := 1 To nDias
		dDataTrab := dDataBase + j - 1
		cSavFil := cFilAnt

		//�����������������������������������������������������������Ŀ
		//� Atribui valores as variaveis ref a filiais                �
		//�������������������������������������������������������������
		If !lConsFil .And. !lFiliais
			cFilDe  := cFilAnt
			cFilAte := cFilAnt
		EndIf

		//������������������������������������������������������������������������Ŀ
		//�Verifica a Disponibilidade Financeira                                   �
		//��������������������������������������������������������������������������
		dbSelectArea( "SM0" )
		dbSetOrder( 1 )
		dbSeek( cEmpAnt + cFilDe, .T. )
		While SM0->(!Eof()) .And. SM0->M0_CODIGO == cEmpAnt .And. IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL ) <= cFilAte
			cFilAnt := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )

			//�����������������������������������������������������Ŀ
			//�Verifica se existe Emprestimo a ser resgatado no dia �
			//�������������������������������������������������������
			dbSelectArea("SEH")
			dbSetOrder(2)
			dbSeek(xFilial("SEH")+"A",.T.)
			nRecSeh := Recno()
			While ( !Eof() .And. SEH->EH_FILIAL == xFilial("SEH") .And. SEH->EH_STATUS == "A" )
				If SEH->EH_APLEMP == "EMP"
					If ( Empty(SEH->EH_DATARES) .And. J==1 ) .Or.;
						( SEH->EH_DATARES == dDataTrab )
						dA181DtApr := dDataTrab
						nA181VlMoed:= RecMoeda(dA181DtApr,SEH->EH_MOEDA)
						nA181SPCP2	:= 0
						nA181SPLP2	:= 0
						nA181SPCP1	:= 0
						nA181SPLP1	:= 0
						nA181SJUR2	:= 0
						nA181SJUR1	:= 0
						nA181SVCLP	:= 0
						nA181SVCCP	:= 0
						nA181SVCJR	:= 0
						nA181VPLP1 	:= 0
						nA181VPCP1 	:= 0
						nA181VJUR1 	:= 0
						nA181VVCLP 	:= 0
						nA181VVCCP 	:= 0
						nA181VVCJR 	:= 0
						nA181VPLP2 	:= 0
						nA181VlDeb  := 0

						aCalculo	  := Fa171Calc(dDataTrab,SEH->EH_SALDO,.F.)
						nA181SPCP2 := Round(SEH->EH_SALDO * SEH->EH_PERCPLP/100 , TamSX3("EH_SALDO")[2])
						nA181SPLP2 := SEH->EH_SALDO - nA181SPCP2
						nA181SPLP1 := SEH->EH_VLCRUZ
						nA181SPCP1 := Round(SEH->EH_VLCRUZ * SEH->EH_PERCPLP/100,TamSX3("EH_SALDO")[2])
						nA181SPLP1 := SEH->EH_VLCRUZ - nA181SPCP1
						nA181SJUR2 := aCalculo[1,2]
						nA181SJUR1 := aCalculo[2,2]
						nA181SVCLP := aCalculo[2,3]
						nA181SVCCP := aCalculo[2,4]
						nA181SVCJR := aCalculo[2,5]
						nA181VlIRF := 0
						nA181VLDES := 0
						nA181VLGAP := 0
						nA181STOT1 := nA181SPLP1+nA181SPCP1+nA181SJUR1+nA181SVCLP+nA181SVCCP+nA181SVCJR
						nA181STOT2 := nA181SPLP2+nA181SPCP2+nA181SJUR2
						nA181VPLP1 := nA181SPLP1
						nA181VPCP1 := nA181SPCP1
						nA181VPLP2 := nA181SPLP2
						nA181VPCP2 := nA181SPCP2
						nA181VJUR1 := nA181SJUR1
						nA181VJUR2 := nA181SJUR2
						nA181VVCLP := nA181SVCLP
						nA181VVCCP := nA181SVCCP
						nA181VVCJR := nA181SVCJR
						nA181VTOT1 := nA181STOT1
						nA181VTOT2 := nA181STOT2

						Fa181Valor(,"DA181DTAPR") // Atualiza as variaveis PRIVATES do calculo do emprestimo
						nEmprestimo := xMoeda(nA181VlDeb,1,nMoeda,dDataTrab)
						// Verifica se esta no periodo solicitado
						nAscan := Ascan(aPeriodo, {|e| e[1] == dDataTrab})
						If nAscan > 0
							aFluxo[nAscan][SAIDAS] += nEmprestimo
						Endif
						If lAnalitico .And. nEmprestimo > 0
							// Pesquisa na matriz de totais, os totais de contas a pagar
							nAscan := Ascan( aTotais[6], {|e| e[1] == dDataTrab})
							If nAscan == 0
								Aadd( aTotais[6], {dDataTrab,nEmprestimo})
							Else
								aTotais[6][nAscan][2] += nEmprestimo // Contabiliza os totais de emprestimos
							Endif
							// Verifica se esta no periodo solicitado
							nAscan := Ascan(aPeriodo, {|e| e[1] == dDataTrab})
							If nAscan > 0 .And. SEH->EH_DATA <= ( dDataBase + nDias )
								RecLock(cAliasEmp,.T.)
								(cAliasEmp)->FILIAL	:= SEH->EH_FILIAL
								(cAliasEmp)->DataX	:= dDataTrab
								(cAliasEmp)->Periodo	:= aPeriodo[nAscan][2]
								(cAliasEmp)->NUMERO	:= SEH->EH_NUMERO
								(cAliasEmp)->BANCO	:= SEH->EH_BANCO
								(cAliasEmp)->AGENCIA	:= SEH->EH_AGENCIA
								(cAliasEmp)->CONTA	:= SEH->EH_CONTA
								(cAliasEmp)->EMISSAO	:= SEH->EH_DATA
								(cAliasEmp)->SALDO	:= nEmprestimo
								(cAliasEmp)->APELIDO	:= "SEH"
								(cAliasEmp)->CHAVE	:= xFilial("SEH")+SEH->EH_NUMERO+SEH->EH_REVISAO
								MsUnlock()
					Endif
							Endif
						Endif
				Else
					If SEH->EH_DATA == dDataTrab .And. SEH->EH_DATA > dDataBase
					   nAscan := Ascan(aPeriodo, {|e| e[1] == dDataTrab})
					   If nAscan > 0
					      aFluxo[nAscan][SAIDAS] += xMoeda(SEH->EH_VALOR,1,nMoeda,dDataTrab)
					   Endif
					Endif
				EndIf
				dbSelectArea("SEH")
				dbSkip()
			EndDo
			DbGoTo(nRecSeh) // Para evitar outro SEEK
			//��������������������������������������������������������Ŀ
			//�Verifica se existe Aplicacoes a serem resgatadas no dia �
			//����������������������������������������������������������

			While ( !Eof() .And. SEH->EH_FILIAL == xFilial("SEH") .And. SEH->EH_STATUS == "A" )
				If SEH->EH_APLEMP == "APL"
			  		If (Empty(SEH->EH_DATARES) .And. J==1) .Or. ((SEH->EH_DATARES < dDataTrab) .And. J==1) .Or. ;
			  			(SEH->EH_DATARES == dDataTrab)
						nAplicacao := xMoeda(SEH->EH_SALDO,1,nMoeda,dDataTrab)
					Else
						nAplicacao := 0
					EndIf
					DbSelectArea("SE9")
					DbSetOrder(1)
					DbSeek(xFilial()+SEH->EH_CONTRAT+SEH->EH_BCOCONT+SEH->EH_AGECONT)
					DbSelectArea("SEH")
					If (Empty(SEH->EH_DATARES) .And. J==1) .Or. ((SEH->EH_DATARES < dDataTrab) .And. J==1) .Or. ;
						(SEH->EH_DATARES == dDataTrab)
						If !SEH->EH_TIPO $ cAplCotas
							aCalc :=	Fa171Calc(dDataTrab)
						Else
							aCalc := {0,0,0,0,0,0}
							DbSelectArea("SE0")
							MsSeek(xFilial("SE0")+SE9->(E9_BANCO+E9_AGENCIA+E9_CONTA+E9_NUMERO))
							Aadd(aAplic,{	SEH->EH_CONTRAT,SEH->EH_BCOCONT,SEH->EH_AGECONT,;
												Transform(SEH->EH_SALDO,"@E 999,999,999.99"),;
												Transform(SE9->E9_VLRCOTA,PesqPict("SE9","E9_VLRCOTA",18)),;
												SE0->E0_VALOR})
							DbSelectArea("SEH")
							nAscan := Ascan(aAplic, {|e|	e[1] == SEH->EH_CONTRAT .And.;
																   e[2] == SEH->EH_BCOCONT .And.;
																   e[3] == SEH->EH_AGECONT})
							If nAscan > 0
								aCalc	:=	Fa171Calc(dDataTrab,SEH->EH_SLDCOTA,,,,SEH->EH_VLRCOTA,aAplic[nAscan][6],(SEH->EH_SLDCOTA * aAplic[nAscan][6]))
							Endif
						EndIf
						nAplicacao += xMoeda((aCalc[5]-aCalc[2]-aCalc[3]-aCalc[4]),;
												    1,nMoeda,dDataTrab)
					EndIf
					// Verifica se esta no periodo solicitado
					nAscan := Ascan(aPeriodo, {|e| e[1] == dDataTrab})
					If nAscan > 0
						aFluxo[nAscan][ENTRADAS] += nAplicacao
					Endif
					If lAnalitico .And. nAplicacao > 0
						// Pesquisa na matriz de totais, os totais de contas a pagar
						nAscan := Ascan( aTotais[7], {|e| e[1] == dDataTrab})
						If nAscan == 0
							Aadd( aTotais[7], {dDataTrab,nAplicacao})
						Else
							aTotais[7][nAscan][2] += nAplicacao // Contabiliza os totais de Aplicacoes
						Endif
						// Verifica se esta no periodo solicitado
						nAscan := Ascan(aPeriodo, {|e| e[1] == dDataTrab})
						If nAscan > 0 .And. SEH->EH_DATA <= ( dDataBase + nDias )
							RecLock(cAliasApl,.T.)
							(cAliasApl)->FILIAL	:= SEH->EH_FILIAL
							(cAliasApl)->DataX	:= dDataTrab
							(cAliasApl)->Periodo	:= aPeriodo[nAscan][2]
							(cAliasApl)->NUMERO	:= SEH->EH_NUMERO
							(cAliasApl)->BANCO	:= SEH->EH_BANCO
							(cAliasApl)->AGENCIA	:= SEH->EH_AGENCIA
							(cAliasApl)->CONTA	:= SEH->EH_CONTA
							(cAliasApl)->EMISSAO	:= SEH->EH_DATA
							(cAliasApl)->SALDO	:= nAplicacao
							(cAliasApl)->APELIDO	:= "SEH"
							(cAliasApl)->CHAVE	:= xFilial("SEH")+SEH->EH_NUMERO+SEH->EH_REVISAO
							MsUnlock()
						Endif
					Endif
				Endif
				dbSelectArea("SEH")
				dbSkip()
			EndDo

            //�����������������������������������������������������������������Ŀ
            //� AAF - Fluxo de caixa para financiamentos originados no SIGAEFF  �
            //�������������������������������������������������������������������
            If lMVEffFin .AND. j == 1
               aRet := EX102FlCaixa(dDataTrab,aPeriodo,nMoeda,lAnalitico)
               For i := 1 To Len(aRet)
                  nVlFluxo := aRet[i][6]
                  // Verifica se esta no periodo solicitado
				  nAscan := Ascan(aPeriodo, {|e| e[1] == aRet[i][11]}) //WHRS 01/08/2017 foi alterado o parameto de compara��o do Ascan de dDataTrab para aRet[i][11] TE-6355 526889 / MTRADE-1262 - Fluxo de caixa com emprestimo do Exporta��o
				  If nAscan > 0
				     aFluxo[nAscan][SAIDAS] += nVlFluxo
                  Endif

				  If lAnalitico .And. nVlFluxo > 0
				     // Pesquisa na matriz de totais, os totais de contas a pagar
					 nAscan := Ascan( aTotais[6], {|e| e[1] == aRet[i][11]}) //WHRS 01/08/2017 foi alterado o parameto de compara��o do Ascan de dDataTrab para aRet[i][11] TE-6355 526889 / MTRADE-1262 - Fluxo de caixa com emprestimo do Exporta��o
					 If nAscan == 0
					    Aadd( aTotais[6], {aRet[i][11],nVlFluxo})
				     Else
						aTotais[6][nAscan][2] += nVlFluxo
					 Endif

					 // Verifica se esta no periodo solicitado
					 nAscan := Ascan(aPeriodo, {|e| e[1] == aRet[i][11]}) //WHRS 01/08/2017 foi alterado o parameto de compara��o do Ascan de dDataTrab para aRet[i][11] TE-6355 526889 / MTRADE-1262 - Fluxo de caixa com emprestimo do Exporta��o
					 If nAscan > 0
						RecLock(cAliasEmp,.T.)
						(cAliasEmp)->DataX	:= aRet[i][11]
						(cAliasEmp)->Periodo:= aPeriodo[nAscan][2]
						(cAliasEmp)->NUMERO	:= aRet[i][1]//SEH->EH_NUMERO
						(cAliasEmp)->BANCO	:= aRet[i][2]//SEH->EH_BANCO
						(cAliasEmp)->AGENCIA:= aRet[i][3]//SEH->EH_AGENCIA
						(cAliasEmp)->CONTA	:= aRet[i][4]//SEH->EH_CONTA
						(cAliasEmp)->EMISSAO:= aRet[i][5]//SEH->EH_DATA
						(cAliasEmp)->SALDO	:= nVlFluxo
						(cAliasEmp)->APELIDO:= aRet[i][7]//"SEH"
						(cAliasEmp)->CHAVE	:= aRet[i][8]
						MsUnlock()
					 Endif
                  Endif

               Next i
            EndIf
            If Empty(FwFilial("SEH"))
				Exit
			Endif
			dbSelectArea("SEH")
			dbSetOrder(1)
			dbSelectArea("SM0")
			dbSkip()
		EndDo
		SM0->(RestArea(aAreaSM0))
		cFilAnt := cSavFil
	Next
Endif

aArqTmp := Array(4)

If lLibCheq // Verifica cheques nao liberados
	cSavFil := cFilAnt

	If lAnalitico
		aTmpAnaChq := CriaTmpAna(6) // Cria o arquivo temporario analitico de emprestimos
		cAliasChq  := aTmpAnachq[1]
	EndIf

	cSelFil := IIf( Len(aSelFil) > 0, ArrayToStr( aSelFil, ';' ), "")

	While SM0->(!Eof()) .And. SM0->M0_CODIGO == cEmpAnt .And. SM0->M0_CODFIL <= cFilAte
		cFilAnt := SM0->M0_CODFIL

		If !cFilAnt $ cSelFil
			SM0->(DBSKIP())
			Loop
		EndIf

		// Tratamento para Gestao corporativa visando garantir que sejam processadas apenas as filiais realmente diferentes.
		// Exemplo:
		// Empresa = Exclusiva
		// U.Negocio = Exclusiva
		// Filial = Compartilhada
		// Somente ao se alterar o valor de xFilial() e que a rotina tem que reprocessar
		If xFilial("SEF") != cFilSEF
			cFilSEF := xFilial("SEF")
		Else
			SM0->(dbSkip())
			Loop
		Endif

		cFiltro := "EF_FILIAL = '" + xFilial("SEF") + "' .And. "
		cFiltro += "EF_NUM <> '" + Space(Len(SEF->EF_NUM)) + "' .And. "
		cFiltro += "!EF_IMPRESS $ 'AC' .And. "
		cFiltro += "EF_LIBER <> 'S' .And. "
		cFiltro += "EF_CART <> 'R' "
		dbSelectArea("SEF")
		cIndTmp := CriaTrab(,.F.)
		IndRegua( "SEF", cIndTmp, "EF_FILIAL+DTOS(EF_DATA)+EF_LIBER", , cFiltro )
		nIndSEF := RetIndex("SEF")
		nIndSEF++

		DbSetOrder(nIndSef)

		While Sef->(!Eof()) .And. SEF->EF_DATA<=dDataBase+nDias-1 .And. SEF->EF_LIBER$" N" .And. SEF->EF_FILIAL == xFilial("SEF")
			// Verifica se esta no periodo solicitado
			If SEF->EF_DATA < dDataBase // Se o cheque nao foi liberado e estiver anterior a data inicial
												 // do fluxo de caixa, assume a data base para exibir este cheque.
				nAscan := 1
			Else
				nAscan := Ascan(aPeriodo, {|e| e[1] == SEF->EF_DATA})
			Endif
			If nAscan > 0
				// Se n�o for cheque sobre titulos, assume como saida de caixa
				If !AllTrim(SEF->EF_ORIGEM) $ "FINA390TIT" .or. lLibCheq .and. SE2->E2_SALDO == 0
					aFluxo[nAscan][SAIDAS] += SEF->EF_VALOR
				Endif
				If lAnalitico
					RecLock(cAliasChq,.T.)
					(cAliasChq)->FILIAL	:= SEF->EF_FILIAL
					(cAliasChq)->DataX	:= If(SEF->EF_DATA < dDataBase,dDataBase,SEF->EF_DATA)
					(cAliasChq)->Periodo	:= aPeriodo[nAscan][2]
					(cAliasChq)->NUMERO	:= SEF->EF_NUM
					(cAliasChq)->BANCO	:= SEF->EF_BANCO
					(cAliasChq)->AGENCIA	:= SEF->EF_AGENCIA
					(cAliasChq)->CONTA	:= SEF->EF_CONTA
					(cAliasChq)->SALDO	:= SEF->EF_VALOR
					(cAliasChq)->APELIDO	:= "SEF"
					(cAliasChq)->CHAVE	:= xFilial("SEF")+SEF->(EF_BANCO+EF_AGENCIA+EF_CONTA+EF_NUM)
					If SEF->EF_DATA < dDataBase // Se o cheque nao foi liberado e estiver anterior a data inicial
														 // do fluxo de caixa, assume a data base para exibir este cheque.
						nAscan := 1
					Else
						nAscan := Ascan( aTotais[8], {|e| e[1] == SEF->EF_DATA})
					Endif
					If nAscan == 0 .Or. Len(aTotais[8]) == 0
						Aadd( aTotais[8], {If(SEF->EF_DATA < dDataBase,dDataBase,SEF->EF_DATA),SEF->EF_VALOR})
					Else
						aTotais[8][nAscan][2] += SEF->EF_VALOR // Contabiliza os totais de cheques pendentes
					Endif
				Endif
			Endif
			DbSelectArea("SEF")
			DbSkip()
		End
		dbSelectArea("SEF")
		dbClearFil()
		RetIndex("SEF")
		If !Empty(cIndTmp)
			FErase (cIndTmp+OrdBagExt())
		Endif
		dbSetOrder(1)
		dbSelectArea("SM0")
		SM0->(dbSkip())
	EndDo
	SM0->(RestArea(aAreaSM0))
	cFilAnt := cSavFil
Endif

If lReceber
	//������������������������������������������������������������������������Ŀ
	//�Processa os titulos a receber                                           �
	//��������������������������������������������������������������������������
	aArqTmp := GeraTmp("SE1",7,Iif(lConsDtBase,dDataBase+nDias-1,dDataBase+nDias),lConsFil,cFilDe,cFilAte,lAnalitico,aFluxo,,,nMoeda,aTotais,aPeriodo,cFilterSe1,lConsDtBase,lTitFuturo, cSinalRA)
Endif
If lPagar
	//�����������������������������Ŀ
	//�Processa os titulos a pagar  �
	//�������������������������������
	aArqTmp := GeraTmp("SE2",3,Iif(lConsDtBase,dDataBase+nDias-1,dDataBase+nDias),lConsFil,cFilDe,cFilAte,lAnalitico,aFluxo,If(aArqTmp!=Nil,aArqTmp[1],Nil),If(aArqTmp!=Nil,aArqTmp[3],Nil),nMoeda,aTotais,aPeriodo,cFilterSe2,lConsDtBase,lTitFuturo, cSinalRA)
Endif
If lPedCompra
	// Variaveis utilizadas pela rotina Fc020Compra()
	aCompras	:= {}
	adCompras	:= {}
	MV_PAR03	:= If( lConsFil .Or. lFiliais, 2, 1 )
	MV_PAR04	:= nMoeda

	// Analitico
	If lAnalitico
		aTmpAna		:= CriaTmpAna(3) // Cria o arquivo temporario analitico
		cAliasPc	:= aTmpAna[1]
		cArqAnaPc	:= aTmpAna[2]
     Endif     
	//�����������������������������Ŀ
	//�Processa os pedidos de compra�
	//�������������������������������
	Fc020Compra(cAliasPc, aTotais, .T., nMoeda, aPeriodo, cFilDe, cFilAte, cPedidos, .F.,, aSelFil)
	For nX := 1 To Len(aCompras)
		//IncProc(STR0028) //"Processando Pedidos de compras"
        cMsg := "CI_M180 - 'Processando Pedidos de compras...'"
        If !lAuto
            oProcess:IncRegua2(cMsg)   
        Else
            ConOut(cMsg)
        Endif

		// Verifica se esta no periodo solicitado
		nAscan := Ascan(aPeriodo, {|e| e[1] == aCompras[nX][1]})
		// Se a data do pedido ja venceu, insere na primeira data do fluxo
		If aCompras[nX][1] < aPeriodo[1][1]
			aCompras[nX][1] := aPeriodo[1][1]
			nAscan := 1
		Endif
		If nAscan > 0
			aFluxo[nAscan][SAIDAS] += iif (cSinalRA='-',aCompras[nX][2]-aCompras[nX][4],aCompras[nX][2])
		Endif
	Next
Endif
If lCtrc
	//������������������������������������������������������������������������Ŀ
	//�Processa os titulos a Doctos. de Transporte										�
	//��������������������������������������������������������������������������
	aTmpAnaCtrc := CriaTmpAna(7) // Cria o arquivo temporario analitico de Doctos. de Transporte
	Fc021Ctrc(aTmpAnaCtrc[1],dDataBase+nDias-1,lConsFil,cFilDe,cFilAte,lAnalitico,aFluxo,nMoeda,aTotais,aPeriodo,lFiliais)
Endif

If lSolFundo
	//---------------------------------------------------------------------------
	// Processa as solicitacoes de fundo aprovadas e nao amarradas a Ordem Pagam.
	//---------------------------------------------------------------------------
	aTmpAnaSol := CriaTmpAna(8) // Cria o arquivo temporario analitico de Solicitacoes de Fundo
	Fc021Solic(aTmpAnaSol[1],dDataBase+nDias-1,lConsFil,cFilDe,cFilAte,lAnalitico,aFluxo,nMoeda,aTotais,aPeriodo)
EndIf

If lPedVenda
	// Variaveis utilizadas pela rotina Fc020Compra()
	aVendas  := {}

	adVendas := {}
	MV_PAR03 := If( lConsFil .Or. lFiliais, 2, 1 )
	MV_PAR04 := nMoeda

	// Analitico
	If lAnalitico
		aTmpAna		:= CriaTmpAna(4) // Cria o arquivo temporario analitico
		cAliasPv	:= aTmpAna[1]
		cArqAnaPv	:= aTmpAna[2]
     Endif

	//�����������������������������Ŀ
	//�Processa os pedidos de venda �
	//�������������������������������
	Fc020Venda(, cAliasPv, aTotais, .T., nMoeda, aPeriodo, cFilDe, cFilAte,,,, aSelFil,,lTxMoePed)
	For nX := 1 To Len(aVendas)
		//ncProc(STR0029) //"Processando Pedidos de vendas"
        cMsg := "CI_M180 - 'PProcessando Pedidos de vendas...'"
        If !lAuto
            oProcess:IncRegua2(cMsg)   
        Else
            ConOut(cMsg)
        Endif
        
		nAscan := Ascan(aPeriodo, {|e| e[1] == aVendas[nX][1]})
		// Se a data do pedido ja venceu, insere na primeira data do fluxo
		If aVendas[nX][1] < aPeriodo[1][1]
			aVendas[nX][1] := aPeriodo[1][1]
			nAscan := 1
		Endif
		If nAscan > 0
			aFluxo[nAscan][ENTRADAS] += iif (cSinalRA='-',aVendas[nX][2]-aVendas[nX][4],aVendas[nX][2])
		Endif
	Next
Endif
aArqCo := Array(4)

If lDMSCompra

	aDMSCompras  := {}
	MV_PAR03 := If( lConsFil, 2, 1 )

	// Analitico
	If lAnalitico
		aTmpAna := CriaTmpAna(09) // Cria o arquivo temporario analitico
		cAliasDMSCompra := aTmpAna[1]
		cArqDMSCompra   := aTmpAna[2]
	Endif
	//������������������������������?
	//�Processa os pedidos de compra?
	//������������������������������?
	Fc020DMSCompra(cAliasDMSCompra,aTotais,.T.,nMoeda,aPeriodo,cFilDe, cFilAte, lConsDtBase, , )
	For nX := 1 To Len(aDMSCompras)
		//IncProc(STR0278) // "Processando Pedido de Compra de M�quinas"
        cMsg := "CI_M180 - 'Processando Pedido de Compra de M�quinas'"
        If !lAuto
            oProcess:IncRegua2(cMsg)   
        Else
            ConOut(cMsg)
        Endif
          
		// Verifica se esta no periodo solicitado
		nAscan := Ascan(aPeriodo, {|e| e[1] == aDMSCompras[nX][1]})
		// Se a data do pedido ja venceu, insere na primeira data do fluxo
		If aDMSCompras[nX][1] < aPeriodo[1][1]
			aDMSCompras[nX][1] := aPeriodo[1][1]
			nAscan := 1
		Endif
		If nAscan > 0
			aFluxo[nAscan][SAIDAS] += aDMSCompras[nX][2]
		EndIf
	Next
EndIf

If lDMSVenda

	aDMSVendas  := {}
	MV_PAR03 := If( lConsFil, 2, 1 )

	// Analitico
	If lAnalitico
		aTmpAna := CriaTmpAna(10) // Cria o arquivo temporario analitico
		cAliasDMSVenda := aTmpAna[1]
		cArqDMSVenda   := aTmpAna[2]
	Endif
	//������������������������������?
	//�Processa os pedidos de Venda ?
	//������������������������������?
	Fc020DMSVenda(cAliasDMSVenda,aTotais,.T.,nMoeda,aPeriodo,cFilDe, cFilAte, lConsDtBase, , )
	For nX := 1 To Len(aDMSVendas)
		//IncProc(STR0279) // "Processando Pedido de Venda de M�quinas"
        cMsg := "CI_M180 - 'Processando Pedido de Venda de M�quinas'"
        If !lAuto
            oProcess:IncRegua2(cMsg)   
        Else
            ConOut(cMsg)
        Endif
 		// Verifica se esta no periodo solicitado
		nAscan := Ascan(aPeriodo, {|e| e[1] == aDMSVendas[nX][1]})
		// Se a data do pedido ja venceu, insere na primeira data do fluxo
		If aDMSVendas[nX][1] < aPeriodo[1][1]
			aDMSVendas[nX][1] := aPeriodo[1][1]
			nAscan := 1
		Endif
		If nAscan > 0
			aFluxo[nAscan][ENTRADAS] += aDMSVendas[nX][2]
		Endif
	Next
Endif

If lComissoes
	aArqCo := Fc021Comis(dDataBase+nDias-1,lConsFil,cFilDe,cFilAte,aFluxo,nMoeda,lAnalitico,aTotais,aPeriodo)
Endif

If aArqTmp == Nil .And. aArqco == Nil
	IW_MSGBOX('CI_M180','� necessario escolher ao menos um tipo','STOP') 
Else
	//FluxoAna(aArqTmp[2], aArqTmp[4], cAliasPc, cAliasPv, aArqCo[4],cAliasEmp,cAliasApl,aTmpAnaCtrc[1],aFluxo[oFluxo:nAt][DATAFLUXO],aFluxo,aTotais,nBancos,nCaixas,nAtrReceber,nAtrPagar,aPeriodo,cAliasChq,oFluxo,nLimCred,aTmpAnaSol[1],cAliasDMSCompra,cAliasDMSVenda)
	M180_GeraFC(aArqTmp[2], aArqTmp[4], cAliasPc, cAliasPv, aArqCo[4],cAliasEmp,cAliasApl,aTmpAnaCtrc[1],cPeriodo,aFluxo,aTotais,nBancos,nCaixas,nAtrReceber,nAtrPagar,aPeriodo,cAliasChq,nLimCred,aTmpAnaSol[1],cAliasDMSCompra,cAliasDMSVenda)

	If cAliasPc != Nil
		(cAliasPc)->(DbCloseArea())

		//Deleta tabela tempor�ria no banco de dados
		If _oFINC0216 <> Nil
			_oFINC0216:Delete()
			_oFINC0216 := Nil
		Endif

	Endif
	If cAliasPv != Nil
		(cAliasPv)->(DbCloseArea())

		//Deleta tabela tempor�ria no banco de dados
		If _oFINC0217 <> Nil
			_oFINC0217:Delete()
			_oFINC0217 := Nil
		Endif

	Endif
    If aArqTmp[2] != Nil .And. Select(aArqTmp[2]) > 0

		(aArqTmp[2])->(DbCloseArea())
		(aArqTmp[4])->(DbCloseArea())

		//Deleta tabelas tempor�rias no banco de dados
		If _oFINC0211 <> Nil
			_oFINC0211:Delete()
			_oFINC0211 := Nil
		Endif

		If _oFINC0212 <> Nil
			_oFINC0212:Delete()
			_oFINC0212 := Nil
		Endif

	Endif
	If aArqCo != Nil
		// Apaga o arquivo sint�tico de comiss�es

		If aArqCo[4] != Nil .And. Select(aArqCo[4]) > 0
			(aArqCo[4])->(DbCloseArea())
			If _oFINC0213 <> Nil
				_oFINC0213:Delete()
				_oFINC0213 := Nil
			Endif
		Endif

	Endif
	If cAliasEmp != Nil
		(cAliasEmp)->(DbCloseArea())


		//Deleta tabela tempor�ria no bano de dados
		If _oFINC0214 <> Nil
			_oFINC0214:Delete()
			_oFINC0214 := Nil
		Endif

	Endif
	If cAliasApl != Nil
		(cAliasApl)->(DbCloseArea())


		//Deleta tabela tempor�ria no banco de dados
		If _oFINC0215 <> Nil
			_oFINC0215:Delete()
			_oFINC0215 := Nil
		Endif

	Endif
	If cAliasChq != Nil
		(cAliasChq)->(DbCloseArea())


		//Deleta tabela tempor�ria no banco de dados
		If _oFINC0218 <> Nil
			_oFINC0218:Delete()
			_oFINC0218 := Nil
		Endif
	Endif
	If aTmpAnaCtrc[1] != Nil
		(aTmpAnaCtrc[1])->(DbCloseArea())
	Endif
	If aTmpAnaSol[1] != Nil
		(aTmpAnaSol[1])->(DbCloseArea())


		//Deleta tabela tempor�ria no banco de dados
		If _oFINC021a <> Nil
			_oFINC021a:Delete()
			_oFINC021a := Nil
		Endif

	Endif

	If cAliasDMSCompra != Nil
		(cAliasDMSCompra)->(DbCloseArea())
		If _oFINC021e <> Nil
			_oFINC021e:Delete()
			_oFINC021e := Nil
		Endif
	Endif

	If cAliasDMSVenda != Nil
		(cAliasDMSVenda)->(DbCloseArea())
		If _oFINC021f <> Nil
			_oFINC021f:Delete()
			_oFINC021f := Nil
		Endif
	Endif

Endif

Return

/*/{Protheus.doc}
Verifica se existe dados para a data na matriz de periodos
@author Jeferson Silva
@since 02/01/2020
@version 1.0
@return Nil,
@example
Funcao Original TemFluxoDat TOTVS - Claudio D. de Souza
TemFluxoDat()
/*/
Static Function TemFluxoData(dData, aFluxo)
Local nAscan
	nAscan := Ascan(aFluxo, {|e|e[DATAFLUXO]==dData})
	If nAscan == 0
		Aadd(aFluxo, {dData,0,0,0,0,0,0,0,0,0})
		nAscan := Len(aFluxo)
	Endif
Return nAscan

/*/{Protheus.doc}
Montar os periodos na matriz de periodos
@author Jeferson Silva
@since 02/01/2020
@version 1.0
@return Nil,
@example
Funcao Original MontaPerio TOTVS - Claudio D. de Souza
MontaPerio()
/*/
Static Function MontaPeriodo(aArray,cPeriodos)
Local nX,;
		nY,;
		nInicio := 0,;
		nFim,;
		nPeriodo := Val(Left(cPeriodos,2)),;
		nResto		  	,;
		aCopia := {}	,;
		dDataTrab		,;
		cPer

For nX := 1 TO Len(aArray)
	dDataTrab := aArray[nX][DATAFLUXO]
	Do Case
	Case nPeriodo == 1  // Diario
		nResto := 0
	Case nPeriodo == 7  // Semanal
		// Verifica quantos dias faltam para a proxima semana
		nResto := 6
		If Dow(dDataTrab) != 1
			nResto := 7-Dow(dDataTrab)
		EndIf
	Case nPeriodo == 10 // Decendial
		nResto := 9
		// Verifica quantos dias faltam para o proximo decendio
		If Day(dDataTrab) < 10
			nResto := 10-Day(dDataTrab)
		ElseIf Day(dDataTrab) > 10 .And. Day(dDataTrab) < 20
			nResto := 20-Day(dDataTrab)
		ElseIf Day(dDataTrab) > 20
			nResto := LastDay(dDataTrab)-dDataTrab // Processa at� o ultimo dia do mes
		Endif
	Case nPeriodo == 15 // Quinzenal
		nResto := 14
		// Verifica quantos dias faltam para a proxima quinzena
		If Day(dDataTrab) < 15
			nResto := 15-Day(dDataTrab)
		Else
			nResto := LastDay(dDataTrab)-dDataTrab // Processa at� o ultimo dia do mes
		Endif
	Case nPeriodo == 30 // Mensal
		// Verifica quantos dias faltam para o proximo mes
		nResto := LastDay(dDataTrab)-dDataTrab
	EndCase
	nInicio := nX
	nFim    := (nResto+nX)
	nFim    := If(nFim <= Len(aArray),nFim,Len(aArray))
	nX 	  := nFim
	For nY := nInicio To nFim
		If aArray[nY][1] <= aArray[nX][DATAFLUXO]
			Aadd(aCopia,{aArray[nY][1],cPer})
		Else
			Exit
		Endif
	Next
Next
aArray  := aClone(aCopia)
Return

/*/{Protheus.doc}
Gera dados no arquivo temporario, a partir do arquivo de CR ou CP
@author Jeferson Silva
@since 02/01/2020
@version 1.0
@return Nil,
@example
Funcao Original GeraTmp TOTVS - Claudio D. de Souza
MontaPerio()
/*/
Static FUNCTION GeraTmp(cAlias,nOrdem,dUltData,lConsFil,cFilDe,cFilAte,lAnalitico,;
							   aFluxo,cArqAnaP,cArqAnaR,nMoeda,aTotais,aPeriodo,cFilterUser,;
							   lConsDtBase,lTitFuturo, cSinal)
Local cAliasAnaP
Local cAliasAnaR
Local cAliasAna
Local cAliasTrb
Local cAliasAux
Local nSaldoTit
Local aCposAna
Local aCposSin
Local dDataTrab
Local cCampo		:= Right(cAlias,2)
Local nCampSin		:= If(Upper(cAlias) == "SE1", ENTRADAS, SAIDAS)
Local cCliFor
Local nAscan
Local cAbatim		:= MV_CRNEG+"/"+MV_CPNEG+"/"+MVIRABT+"/"+MVCSABT+"/"+MVCFABT+"/"+MVPIABT+"/"+MVABATIM
Local aSx3Box		:= F021SitCob()
Local cAliasCF		:= ""
Local nCiclos		:= 0
Local nAscanPA		:= 0
Local nX			:= 0
Local lFc021Fil		:= ExistBlock("FC021FIL")
Local dDataVcOri	:= Ctod("//")
Local nDesconto
Local lTxMoeda
Local nDiasRet		:= 0
Local lFC021MAM		:= ExistBlock("FC021MAN")
Local cE1Situaca	:= ""
Local cFils			:= ""
Local lPAFUTFL		:= SuperGetMv("MV_PAFUTFL",.T.,.F.)
//--- Tratamento Gestao Corporativa
Local lGestao		:= Iif( lFWCodFil, FWSizeFilial() > 2, .F. )	// Indica se usa Gestao Corporativa
Local cFilFwSE2		:= IIF( lGestao .And. FindFunction("FwFilial"), FwFilial("SE2") , xFilial("SE2") )
//--- Rastro Financeiro
Local lRastro		:= If(FindFunction("FVerRstFin"),FVerRstFin(),.F.)
Local cAliasRst		:= If( Upper(cAlias) == "SE1" , "FI7" , "FI8" )
Local lNRastDSD		:= SuperGetMV("MV_NRASDSD",.T.,.F.)
Local aData			:= {}
Local nPos			:= 0
Local dDataAux		:= ""
Local lFValAcess	:= ExistFunc('FValAcess')
Local cTipo         := ""
Local lConsFlCx     := .T.
Local lExibVenc     := .T.
Local lExibEmis     := .T.
Local lFc021atrb    := ExistBlock("FC021ATRB")
Local cQuery
Local cQry
Local aStru
Local dDataM2 := Ctod("//")
Local nTxC := 0

DEFAULT cSinal = '-'

cAlias := Upper(cAlias)

cAliasAnaP := "cArqAnaP"  // Alias do arquivo analitico
cAliasAnaR := "cArqAnaR"  // Alias do arquivo analitico
cAliasAna  := If(cAlias=="SE1","cArqAnaR","cArqAnaP")

// Analitico
If lAnalitico .And. (_oFINC0211 == Nil .Or. _oFINC0212 == Nil)
	aCposAna := {}
	Aadd( aCposAna, { "Periodo"  , "C", 25, 0 } )
	Aadd( aCposAna, { "DATAX"    , "D", 08, 0 } )
	Aadd( aCposAna, { "FILIAL"   , "C", IIf( lFWCodFil, FWGETTAMFILIAL, TamSx3(cCampo+"_FILIAL")[1] ), 0 } )
	Aadd( aCposAna, { "PREFIXO"  , "C", TamSx3(cCampo+"_PREFIXO")[1], 0 } )
	Aadd( aCposAna, { "NUM"      , "C", TamSx3(cCampo+"_NUM")[1], 0 } )
	Aadd( aCposAna, { "PARCELA"  , "C", TamSx3(cCampo+"_PARCELA")[1], 0 } )
	Aadd( aCposAna, { "TIPO"     , "C", TamSx3(cCampo+"_TIPO")[1], 0 } )
	Aadd( aCposAna, { "CLIFOR"   , "C", TamSx3("E5_CLIFOR")[1], 0 } )
	Aadd( aCposAna, { "NomCliFor", "C", TamSx3("A1_NOME")[1], 0 } )
	Aadd( aCposAna, { "LOJA"     , "C", TamSx3(cCampo+"_LOJA")[1], 0 } )
	Aadd( aCposAna, { "SALDO"    , "N", Max(TamSx3("E1_SALDO")[1]  ,;
					 					            TamSx3("E2_SALDO")[1]) , TamSx3("E1_SALDO")[2] } )
	If cAlias == "SE1"
		Aadd( aCposAna, { "SITUACAO", "C", 20, 0 } )
		Aadd( aCposAna, { "PORTADO", "C", TamSx3(cCampo+"_PORTADO")[1], 0 } )
		Aadd( aCposAna, { "AGEDEP", "C", TamSx3(cCampo+"_AGEDEP")[1], 0 } )
		Aadd( aCposAna, { "CONTA", "C", TamSx3(cCampo+"_CONTA")[1], 0 } )
	Endif

	Aadd( aCposAna, { "CHAVE"  , "C", 40, 0 } )
	Aadd( aCposAna, { "Apelido", "C", 10, 0 } )
   // Ponto de entrada para criar campos no arquivo temporario
	If ExistBlock("FC021CPO")
		aCposA := ExecBlock("FC021CPO",.F.,.F.,{aCposAna})
		For nX := 1 to len(aCposA)
 			aAdd(aCposAna,aCposA[nX])
	 	Next
	EndIf
	Aadd( aCposAna, { "CampoNulo"	, "C", 1, 0 } )
	Aadd( aCposAna, { "Flag"    	, "L", 1, 0 } )
	Aadd( aCposAna, { "NATUREZA" 	, "C", TamSx3(cCampo+"_NATUREZ")[1], 0 } )  
	Aadd( aCposAna, { "DESCNAT", "C", TamSx3("ED_DESCRIC")[1], 0 } )  
	Aadd( aCposAna, { "EMISSAO"		, "D", 08, 0 } )
	Aadd( aCposAna, { "VENCTO"		, "D", 08, 0 } )
	Aadd( aCposAna, { "VENCREA" 	, "D", 08, 0 } )
	Aadd( aCposAna, { "HIST" 		, "C", TamSx3(cCampo+"_HIST")[1], 0 } ) 

	//------------------
	//Cria��o da tabela temporaria 1
	//------------------
	If _oFINC0211 <> Nil
		_oFINC0211:Delete()
		_oFINC0211 := Nil
	Endif

	If Select(cAliasAnaP) > 0
		(cAliasAnaP)->(DbCloseArea())
	EndIf

	_oFINC0211 := FWTemporaryTable():New( cAliasAnaP )
	_oFINC0211:SetFields(aCposAna)
	_oFINC0211:AddIndex("1", {"DATAX"})
	_oFINC0211:Create()

	//------------------
	//Cria��o da tabela temporaria 2
	//------------------
	If _oFINC0212 <> Nil
		_oFINC0212:Delete()
		_oFINC0212 := Nil
	Endif

	If Select(cAliasAnaR) > 0
		(cAliasAnaR)->(DbCloseArea())
	EndIf

	_oFINC0212 := FWTemporaryTable():New( cAliasAnaR )
	_oFINC0212:SetFields(aCposAna)
	_oFINC0212:AddIndex("1", {"DATAX"})
	_oFINC0212:Create()

Endif

aCposSin :=	{{"DATAX"   , "D" , 08, 0},;
				{"ENTR"    , "N" , 17, 2},;
				{"SAID"    , "N" , 17, 2},;
				{"SALDO"   , "N" , 17, 2},;
				{"ENTRAC"  , "N" , 17, 2},;
				{"SAIDAC"  , "N" , 17, 2},;
				{"SALDOAC" , "N" , 17, 2},;
				{"VARIACAO", "N" ,  9, 2},;
				{"VARIACAC", "N" ,  9, 2},;
				{"FLAG"    , "L" , 1, 0 }}

cFils := FincRetFils() // Retorna filiais que o usuario tem acesso

//�����������������������������������������������������������Ŀ
//� Atribui valores as variaveis ref a filiais                �
//�������������������������������������������������������������
If !lConsFil
	cFilDe  := xFilial(cAlias)
	cFilAte := xFilial(cAlias)
EndIf

aStru     := (cAlias)->(dbStruct())
cAbatim   := FormatIn(cAbatim,"/")
cAliasTrb := "FINC021"
caliasAux := "DESD0BR"
cQuery := ""
aEval(aStru,{|x| cQuery += ","+AllTrim(x[1])})
cQuery := "SELECT "+SubStr(cQuery,2)
cQuery +=         ","+cAlias+".R_E_C_N_O_ TITRECNO "
cQuery += "FROM "+RetSqlName(cAlias)+ " "+ cAlias + " "

cQuery += "WHERE "
If !Empty( cFils ) .and. !("@@" $ cFils)
	// Contas a pagar compartilhado deve observar FILORIG para realizar filtro
	If lConsFil .And. !Empty(cFilAte) //filtro por usu�rio quando n�o possui controle de todas as empresas.
		If Empty( cFilFwSE2 )
			cQuery += cAlias + "." + cCampo + "_FILORIG BETWEEN '" + AllTrim(cFilDe) + "' AND '" + AllTrim(cFilAte) + "' AND "
		Else
			cQuery += cAlias + "." + cCampo + "_FILIAL BETWEEN '" + AllTrim(cFilDe) + "' AND '" + AllTrim(cFilAte) + "' AND "
		EndIf
	Else
		If Empty( cFilFwSE2 )
			cQuery += cAlias + "." + cCampo + "_FILORIG IN " + FormatIn( SubStr( cFils, 1, Len(cFils) - 1 ), "/" ) + " AND "
		Else
			cQuery += cAlias + "." + cCampo + "_FILIAL IN " + FormatIn( SubStr( cFils, 1, Len(cFils) - 1 ), "/" ) + " AND "
		EndIf
	EndIf
Else
	// Contas a pagar compartilhado deve observar FILORIG para realizar filtro
	If !lConsFil .And. Empty( cFilFwSE2 )
		cQuery += cAlias + "." + cCampo + "_FILIAL = '" + xFilial(cAlias) + "' AND "
	Else
		If Empty( cFilFwSE2 )
			cQuery += cAlias + "." + cCampo + "_FILORIG >= '" + cFilDe + "' AND "
			cQuery += cAlias + "." + cCampo + "_FILORIG <= '" + cFilAte+"' AND "
			cQuery += cAlias + "." + cCampo + "_FILIAL = '" + xFilial(cAlias) + "' AND "
		ElseIf lFiliais
			cQuery += cAlias + "." + cCampo + "_FILIAL IN("+cLisFil+") AND "
		Else
			cQuery += cAlias + "." + cCampo + "_FILIAL>='"+cFilDe+"' AND "
			cQuery += cAlias + "." + cCampo + "_FILIAL<='"+cFilAte+"' AND "
		EndIf
	EndIf
Endif
// Modificacao para considerar titulos inadimplentes no FC
/*
If lConsDtBase
	cQuery += cAlias + "." + cCampo + "_VENCREA >= '"+Dtos(dDataBase)+"' AND "
Else
	cQuery += cAlias + "." + cCampo + "_VENCREA > '"+Dtos(dDataBase)+"' AND "
EndIf
*/
cQuery += cAlias + "." + cCampo + "_VENCREA <= '"+Dtos(dUltData)+"' AND "

// Nao considerar titulos emitidos apos a data base, para compatiblizacao
// com FINR140.
If cAlias == "SE1"
	If !lTitFuturo  //Nao considerar titulos com emissao posterior a database
		cQuery += "(E1_EMISSAO <= '"+Dtos(dDataBase) + "' OR E1_TIPO IN " + FormatIn(MVRECANT,"/")+") AND "
	Endif

	If cPaisLoc == "ARG"
		cQuery += "E1_SITUACA IN " + FormatIn(cE1Situaca,"|")+" AND "
	EndIf
Else
	If !lTitFuturo  //Nao considerar titulos com emissao posterior a database
		cQuery += "(E2_EMIS1 <= '"+Dtos(dDataBase) +"' OR E2_TIPO IN " + FormatIn(MVPAGANT,"/")+") AND "
	Endif
Endif
If !lConsDtBase
	cQuery += cAlias + "." + cCampo + "_SALDO > 0 AND "
Endif
cQuery += cAlias + "." + cCampo + "_FLUXO<>'N' AND "
cQuery += cAlias + ".D_E_L_E_T_=' ' "

If lFC021MAM
	cQuery :=  ExecBlock("FC021MAN",.F.,.F.,{cQuery,cAlias,cCampo})
EndIf
cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTrb,.T.,.T.)
aEval(aStru, {|e| If(e[2]!= "C", TCSetField(cAliasTrb, e[1], e[2],e[3],e[4]),Nil)})

While (cAliasTrb)->(!Eof()) //IndRegua
	IncProc('Processando titulos a '+ If(cAlias=="SE1", 'Receber', 'Pagar')) //"Processando titulos a "###"Receber"###"Pagar"
	dDataTrab := (cAliasTrb)->&(cCampo+"_VENCREA")
	//Considera a retencao bancaria, caso o titulo esteja em banco
	If cAlias == "SE1" .And. FN022SITCB( (cAliasTrb)->E1_SITUACA )[2]

		dDataVcOri := (cAliasTrb)->&(cCampo+"_VENCTO")

		//Verifico se o proximo dia util apos o vencimento eh igual ao vencto real do titulo
		//Se for igual e o titulo estiver em cobranca, aplico os dias de retencao do banco
		//Se for diferente e o titulo estiver em cobranca, quer dizer que ja foram aplicados os dias de retencao
		//logo nao aplico novamente.
		If DTOS(DataValida(dDataVcOri)) == DTOS(dDataTrab)
			SA6->(MsSeek(xFilial("SA6",(cAliasTrb)->E1_FILORIG)+(cAliasTrb)->(E1_PORTADO+E1_AGEDEP+E1_CONTA)))
			nDiasRet := SA6->A6_RETENCA
			For nX := 1 To nDiasRet
				dDataTrab := DataValida(dDataTrab+1,.T.)
			Next
		Endif
	Endif

	//����������������������������������������������������������������Ŀ
	//� Se a data de vencto. nao ultrapassar a ultima data da consulta �
	//� e nao for um adiantamento                                      |
	//������������������������������������������������������������������
	cTipo := (cAliasTrb)->&(cCampo+"_TIPO")
	lConsFlCx := dDataTrab <= dUltData
	lExibVenc := .T.
	lExibEmis := .T.

	If lConsFlCx .And. cTipo $ MVRECANT + IIf(!cPaisLoc $"ARG|CHI",MVPAGANT,"")
		If cAlias == "SE2" .And. cTipo $ MVPAGANT
			//Se n�o possui mov banc mostra considera no flux cx a previs�o de pagto do PA, e n�o mostra a emiss�o.
			If F080MovPA(.F., (cAliasTrb)->E2_PREFIXO, (cAliasTrb)->E2_NUM, (cAliasTrb)->E2_PARCELA,(cAliasTrb)->E2_TIPO, (cAliasTrb)->E2_FORNECE, (cAliasTrb)->E2_LOJA, xFilial("SE5", (cAliasTrb)->E2_FILORIG)) == 0
				lExibVenc := .F.
				//lExibVenc := .T.
				lExibEmis := .F.
			Else
				lExibVenc := lPAFUTFL .And. (cAliasTrb)->E2_EMISSAO > dDataBase
				lExibEmis := .T.
			EndIf
		Else
			lConsFlCx := (If(cAlias == "SE2", (cAliasTrb)->E2_EMISSAO, (cAliasTrb)->E1_EMISSAO) > dDataBase)
		EndIf
	EndIf

	If lConsFlCx
		// Posiciona SE1 ou SE2 se for TOP e nao AS400, pois o filtro de usuario e
		// feito sobre o arquivo original.
		If TcSrvType() != "AS/400"
			DbSelectArea(cAlias)
			MsGoto((cAliasTrb)->TITRECNO)
		Endif

		If (cAlias)->&(cCampo+"_DESDOBR") == 'S' .and. lRastro .and. !lNRastDSD

			cQry := " SELECT COUNT(*) AS RESULT FROM " + RetSqlName(cAliasRst)+ " "+ cAliasRst + " "
			cQry += " WHERE "
			cQry +=           cAliasRst + "." + cAliasRst + "_FILIAL = '" + (cAliasTrb)->&(cCampo+"_FILIAL") + "'"
			cQry += " AND " + cAliasRst + "." + cAliasRst + "_PRFDES = '" + (cAliasTrb)->&(cCampo+"_PREFIXO") + "'"
			cQry += " AND " + cAliasRst + "." + cAliasRst + "_NUMDES = '" + (cAliasTrb)->&(cCampo+"_NUM") + "'"
			cQry += " AND " + cAliasRst + "." + cAliasRst + "_PARDES = '" + (cAliasTrb)->&(cCampo+"_PARCELA") + "'"
			cQry += " AND " + cAliasRst + "." + cAliasRst + "_TIPDES = '" + (cAliasTrb)->&(cCampo+"_TIPO") + "'"
			cQry += " AND " + cAliasRst + "." + cAliasRst + "_FORDES = '" + (cAliasTrb)->&(cCampo+"_FORNECE") + "'"
			cQry += " AND " + cAliasRst + "." + cAliasRst + "_LOJDES = '" + (cAliasTrb)->&(cCampo+"_LOJA") + "'"
			cQry := ChangeQuery(cQry)

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasAux,.T.,.T.)

			If (cAliasAux)->RESULT <= 0
				(cAliasAux)->(dbCloseArea())
				(cAliasTrb)->(dbSkip())
				Loop
			Else
				(cAliasAux)->(dbCloseArea())
			EndIf

		EndIf

		DbSelectArea(cAlias)
		If lFc021Fil
			cFilterUser := ExecBlock("FC021FIL", .F., .F., {cAlias} )
		Endif
		// Se nao existir filtro de usuario, ou se o filtro retornar uma expressao
		// valida para o registro atual do titulo, entao processsa o registro.
		If Empty(cFilterUser) .Or. (&cFilterUser)

			nSaldoTit := 0
			dDataAux := DataValida((cAliasTrb)->&(cCampo+"_BAIXA") + nDiasRet,.T.)
			nPos := Ascan(aData, { |x| x[1] == &(cCampo+"_BAIXA") + nDiasRet} )
			If nPos == 0
				dDataAux := DataValida(&(cCampo+"_BAIXA") + nDiasRet)
				aadd(aData, {&(cCampo+"_BAIXA") + nDiasRet, dDataAux})
			EndIf

			If lConsDtBase .AND. dDataAux > dDataBase
					nSaldoTit := SaldoTit(	(cAliasTrb)->&(cCampo+"_PREFIXO"),;
												(cAliasTrb)->&(cCampo+"_NUM"),;
												(cAliasTrb)->&(cCampo+"_PARCELA"),;
												(cAliasTrb)->&(cCampo+"_TIPO"),;
												(cAliasTrb)->&(cCampo+"_NATUREZA"),;
												If(cAlias="SE1","R","P"),;
												(cAliasTrb)->&(cCampo+IF(cAlias="SE1","_CLIENTE","_FORNECE")),;
												nMoeda,(cAliasTrb)->&(cCampo+"_VENCREA"),;
												dDataBase,(cAliasTrb)->&(cCampo+"_LOJA"),,If(cPaisLoc=="BRA",(cAliasTrb)->&(cCampo+"_TXMOEDA"),0),2)

				// Se o titulo foi baixado e a data da baixa eh maior que a database, os campos SDACRES e SDDECRES utilizados na SaldoTit
				// estao zerados pois o titulo foi baixado, entao deve considerar os campos ACRESC e DECRESC do para recompor o saldo.
				nSaldoTit += ( (cAliasTrb)->&(cCampo+"_ACRESC") - (cAliasTrb)->&(cCampo+"_DECRESC") )
			Else
				// Verifica se existe a taxa na data do vencimento do titulo, se nao existir, utiliza a taxa da database
				dDataAux := dDataTrab
				nPos := Ascan(aData, { |x| x[1] == dDataTrab })
				If nPos == 0
					dDataAux := DataValida(dDataTrab,.T.)
					aadd(aData,{dDataTrab, dDataAux})
				EndIf

				If (Empty(dDataAux) .Or. ValType(dDataAux) != "D")
					dDataAux := dDataBase
				EndIf

				lTxMoeda := SM2->(MsSeek(dDataAux)) .And. SM2->&("M2_MOEDA"+Alltrim(Str(nMoeda))) != 0
				dDataM2 := If(lTxMoeda, dDataAux, dDataBase)

				If cAlias == "SE1"
					If cPaisLoc == "BRA"
						nTxC := (cAliasTrb)->E1_TXMOEDA

						If (cAliasTrb)->E1_MOEDA > 1 .And. Empty(nTxC) .And. SM2->(DbSeek(dDataM2))
							nTxC := SM2->(FieldGet(FieldPos("M2_MOEDA" + AllTrim(cValToChar((cAliasTrb)->E1_MOEDA)))))
						EndIf
					EndIf
					nSaldoTit := xMoeda( (cAliasTrb)->(E1_SALDO+E1_SDACRES-E1_SDDECRE), (cAliasTrb)->E1_MOEDA, nMoeda, dDataM2,,nTxC)
				Else
					If cPaisLoc == "BRA"
						nTxC := (cAliasTrb)->E2_TXMOEDA

						If (cAliasTrb)->E2_MOEDA > 1 .And. Empty(nTxC) .And. SM2->(DbSeek(dDataM2))
							nTxC := SM2->(FieldGet(FieldPos("M2_MOEDA" + AllTrim(cValToChar((cAliasTrb)->E2_MOEDA)))))
						EndIf
					EndIf
					nSaldoTit := xMoeda( (cAliasTrb)->(E2_SALDO+E2_SDACRES-E2_SDDECRE), (cAliasTrb)->E2_MOEDA, nMoeda, dDataM2,,nTxC)
				EndIf
			EndIf

			If cAlias == "SE1"
				nDesconto := FaDescFin(cAliasTrb,dDataBase,nSaldoTit,1)
				nSaldoTit -= nDesconto

				// Se titulo do Template Gem
				If HasTemplate("LOT") .And. !Empty(SE1->E1_NCONTR)
					nSaldoTit += CMDtPrc( (cAliasTrb)->E1_PREFIXO,(cAliasTrb)->E1_NUM ,(cAliasTrb)->E1_PARCELA ,(cAliasTrb)->E1_VENCREA ,(cAliasTrb)->E1_VENCREA )[2]
				Endif

				// Calculo valores acess�rios
				If lFValAcess
					nSaldoTit += (cAliasTrb)->(FValAcess(E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA, E1_NATUREZ, !Empty(E1_BAIXA), "", "R", E1_BAIXA))
				Endif
			ElseIf cAlias == "SE2"
				// Calculo valores acess�rios
				If lFValAcess
					nSaldoTit += (cAliasTrb)->(FValAcess(E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, E2_NATUREZ, !Empty(E2_BAIXA), "", "P", E2_BAIXA))
				Endif
			EndIf

			If Abs(nSaldoTit) > 0.0001
				// Verifica a situacao, somente se nao for Contas a Receber.
				If cAlias == "SE2" .Or. !(FN022SITCB( (cAliasTrb)->E1_SITUACA )[3])
					nCiclos	:=	1

					If lExibVenc
						nAscan := TemFluxoData(dDataTrab,aFluxo)

						If ((cTipo $ cAbatim) .Or. (cSinal == '-' .And. cTipo $ cAbatim+"/"+MVRECANT) .Or. (cTipo $ MVPAGANT .And. lExibEmis))
							aFluxo[nAscan][nCampSin] -= nSaldoTit
						Else
							aFluxo[nAscan][nCampSin] += nSaldoTit
						EndIf
					EndIf

					//Movimento Bancario gerado pelo PA (na data de emissao do PA)
					If lExibEmis .And. cAlias == "SE2" .And. cTipo $ MVPAGANT .And. (cAliasTrb)->E2_EMISSAO >= dDataBase .And. (!cPaisLoc $"ARG|CHI" .And. Empty(E2_ORDPAGO))
						nAscanPA := TemFluxoData((cAliasTrb)->E2_EMISSAO,aFluxo)
						aFluxo[nAscanPA][nCampSin] += nSaldoTit

						If lExibVenc
							nCiclos	:= 2
						Else
							If (cAliasTrb)->E2_EMISSAO == dDataBase
								nValorPA	+= 	nSaldoTit
							EndIf
						EndIf
					Endif

					If lAnalitico // Analitico
						For nX := 1 To nCiclos
							cCliFor := (cAliasTrb)->&(cCampo+If(Upper(cAlias)=="SE1","_CLIENTE","_FORNECE"))
							DbSelectArea(StrTran(cAlias,"E","A"))
							DbSetOrder(1)
							MsSeek(xFilial(StrTran(cAlias,"E","A"),(cAliasTrb)->&(cCampo+"_FILORIG"))+cCliFor+(cAliasTrb)->&(cCampo+"_LOJA"))
							DbSelectArea(cAliasTrb)
							RecLock(cAliasAna,.T.)

							If nX == 1 .And. lExibVenc
								nAscan := Ascan(aPeriodo, {|e| e[1] == dDataTrab})
								If nAscan > 0
									(cAliasAna)->DataX   := dDataTrab
									(cAliasAna)->Periodo := aPeriodo[nAscan][2]
								Else
									(cAliasAna)->DataX   := mv_par01
								Endif
							Else
								If nAscanPA := Ascan(aPeriodo, {|e| e[1] == (cAliasTrb)->E2_EMISSAO})
									(cAliasAna)->DataX   := (cAliasTrb)->E2_EMISSAO
									//(cAliasAna)->Periodo := aPeriodo[nAscanPA][2]
								Else
									(cAliasAna)->DataX   := mv_par01
								Endif
							Endif
							SED->(DbSetOrder(1))
							SED->(DbSeek(xFilial('SED')+(cAliasTrb)->&(cCampo+"_NATUREZ")))                            

							(cAliasAna)->FILIAL	 := (cAliasTrb)->&(cCampo+"_FILIAL")
							(cAliasAna)->PREFIXO := (cAliasTrb)->&(cCampo+"_PREFIXO")
							(cAliasAna)->NUM     := (cAliasTrb)->&(cCampo+"_NUM")
							(cAliasAna)->PARCELA := (cAliasTrb)->&(cCampo+"_PARCELA")
							(cAliasAna)->NATUREZA:= (cAliasTrb)->&(cCampo+"_NATUREZ")
							(cAliasAna)->TIPO    := cTipo
							(cAliasAna)->CLIFOR  := cCliFor

							(cAliasAna)->DESCNAT := SED->ED_DESCRIC

							cAliasCF := StrTran(cAlias,"E","A")

							// Se o cadastro de clientes/fornecedores estiver compartilhado,
							// obtem o nome do clientes/fornecedor do cadastro
							If Empty(FwFilial(cAliasCF))
								(cAliasAna)->NOMCLIFOR := (cAliasCF)->&(Right(cAliasCF,2)+"_NOME")
							Else
								(cAliasAna)->NOMCLIFOR := If(cAlias=="SE1", SE1->E1_NOMCLI, SE2->E2_NOMFOR)
							Endif
							(cAliasAna)->LOJA    := (cAliasTrb)->&(cCampo+"_LOJA")
							cIdentific :=	(cAliasTrb)->&(cCampo+"_FILIAL")+;
												(cAliasTrb)->&(cCampo+"_PREFIXO") +;
												(cAliasTrb)->&(cCampo+"_NUM")     +;
												(cAliasTrb)->&(cCampo+"_PARCELA") +;
												cTipo+;
												(cAliasTrb)->&(cCampo+If(Upper(cAlias)=="SE1","_CLIENTE","_FORNECE"))+;
												(cAliasTrb)->&(cCampo+"_LOJA")
							(cAliasAna)->Chave      := cIdentific
							(cAliasAna)->Apelido    := cAlias

							If (cTipo $ MVRECANT .Or. nCiclos == 2) .And. nX == 1
								(cAliasAna)->SALDO := nSaldoTit * -1
							Else
								(cAliasAna)->SALDO := nSaldoTit
							Endif

							If cAlias == "SE1"
								nAscan := Ascan( aSx3Box, { |e| e[2] = (cAlias)->E1_SITUACA } )
								If nAscan > 0
									(cAliasAna)->Situacao  := AllTrim( aSx3Box[nAscan][3] )	// Descricao da situacao.
								Endif
								(cAliasAna)->PORTADO	:= (cAliasTrb)->&(cCampo+"_PORTADO")
								(cAliasAna)->AGEDEP	 	:= (cAliasTrb)->&(cCampo+"_AGEDEP")
								(cAliasAna)->CONTA    	:= (cAliasTrb)->&(cCampo+"_CONTA")
							Endif    
							
							(cAliasAna)->EMISSAO    	:= (cAliasTrb)->&(cCampo+"_EMISSAO")              
							(cAliasAna)->VENCTO    	:= (cAliasTrb)->&(cCampo+"_VENCTO")              
							(cAliasAna)->VENCREA    	:= (cAliasTrb)->&(cCampo+"_VENCREA")              
							(cAliasAna)->HIST    	:= (cAliasTrb)->&(cCampo+"_HIST")   
							
							MsUnlock()
							//Ponto de entrada para atualizar o valor dos novos campos inclusos no arquivo tmp
							If lFc021atrb
								ExecBlock("FC021ATRB",.F.,.F.,{cAliasAna,cAliasTrb,cCampo})
							EndIf

							//Pesquisa na matriz de totais, os totais de contas a pagar ou a receber da data de trabalho.
							nAscan := Ascan( aTotais[If(cAlias=="SE1",2,1)], {|e| e[1] == (cAliasAna)->DataX})

							If nAscan == 0
								If cTipo $ cAbatim
									Aadd( aTotais[If(cAlias=="SE1",2,1)], {(cAliasAna)->DataX,(cAliasAna)->SALDO*-1})
								Else
									Aadd( aTotais[If(cAlias=="SE1",2,1)], {(cAliasAna)->DataX,(cAliasAna)->SALDO})
								Endif
							Else
								If cTipo $ cAbatim
									aTotais[If(cAlias=="SE1",2,1)][nAscan][2] -= (cAliasAna)->SALDO // Contabiliza os totais de titulos
								Else
									aTotais[If(cAlias=="SE1",2,1)][nAscan][2] += (cAliasAna)->SALDO // Contabiliza os totais de titulos
								EndIf
							Endif
						Next
					Endif
				EndIf
			EndIf
		Endif
	Endif
	DbSelectArea(cAliasTrb)
	(cAliasTrb)->(dbSkip())
Enddo

dbSelectArea(cAliasTrb)
dbCloseArea()
dbSelectArea(cAlias)

Return { cArqAnaP, cAliasAnaP, cArqAnaR, cAliasAnaR }

/*/{Protheus.doc}
Criar os arquivos analiticos do Fluxo de Caixa 
@author Jeferson Silva
@since 02/01/2020
@version 1.0
@return Nil,
@example
Funcao Original CriaTmpAna TOTVS - Claudio D. de Souza
TemFluxoDat()
/*/
Static FUNCTION CriaTmpAna(nArquivo)
Local aCposAna
Local cAliasAna
Local cArqAna
Local aChave
Local aRetDMS

aChave := {"DATAX","NUMERO"}

Do Case
Case nArquivo == 1 // Emprestimos
	aCposAna := {}
	Aadd( aCposAna, { "FILIAL"  , "C", TamSx3("EH_FILIAL")[1], 0 } )
	Aadd( aCposAna, { "Periodo" , "C",  25, 0 } )
	Aadd( aCposAna, { "DATAX"   , "D", 08, 0} )
	Aadd( aCposAna, { "NUMERO"  , "C", TamSx3("EH_NUMERO")[1], 0 } )
	Aadd( aCposAna, { "BANCO"   , "C", TamSx3("EH_BANCO")[1], 0 } )
	Aadd( aCposAna, { "AGENCIA" , "C", TamSx3("EH_AGENCIA")[1], 0 } )
	Aadd( aCposAna, { "CONTA"   , "C", TamSx3("EH_CONTA")[1], 0 } )
	Aadd( aCposAna, { "EMISSAO" , "D",  8, 0 } )
	Aadd( aCposAna, { "SALDO"   , "N", TamSx3("EH_SALDO")[1], TamSx3("EH_SALDO")[2]})
	Aadd( aCposAna, { "CHAVE"   , "C", 40, 0 } )
	Aadd( aCposAna, { "Apelido" , "C", 10, 0 } )
	Aadd( aCposAna, { "CampoNulo", "C", 1, 0 } )
	Aadd( aCposAna, { "Flag"     , "L", 1, 0 } )

	cAliasAna := "cArqAnaEmp"  // Alias do arquivo analitico

	If _oFINC0214 <> Nil
		_oFINC0214:Delete()
		_oFINC0214 := Nil
	Endif

	_oFINC0214 := FWTemporaryTable():New( cAliasAna )
	_oFINC0214:SetFields(aCposAna)
	_oFINC0214:AddIndex("1", aChave )

	//------------------
	//Cria��o da tabela temporaria
	//------------------
	_oFINC0214:Create()

Case nArquivo == 2 // Aplicacoes
	aCposAna := {}
	Aadd( aCposAna, { "FILIAL"  , "C", TamSx3("EH_FILIAL")[1], 0 } )
	Aadd( aCposAna, { "Periodo" , "C",  25, 0 } )
	Aadd( aCposAna, { "DATAX"   , "D", 08, 0} )
	Aadd( aCposAna, { "NUMERO"  , "C", TamSx3("EH_NUMERO")[1], 0 } )
	Aadd( aCposAna, { "BANCO"   , "C", TamSx3("EH_BANCO")[1], 0 } )
	Aadd( aCposAna, { "AGENCIA" , "C", TamSx3("EH_AGENCIA")[1], 0 } )
	Aadd( aCposAna, { "CONTA"   , "C", TamSx3("EH_CONTA")[1], 0 } )
	Aadd( aCposAna, { "EMISSAO" , "D",  8, 0 } )
	Aadd( aCposAna, { "SALDO"   , "N", TamSx3("EH_SALDO")[1], TamSx3("EH_SALDO")[2]})
	Aadd( aCposAna, { "CHAVE"   , "C", 40, 0 } )
	Aadd( aCposAna, { "Apelido" , "C", 10, 0 } )
	Aadd( aCposAna, { "CampoNulo", "C", 1, 0 } )
	Aadd( aCposAna, { "Flag"     , "L", 1, 0 } )

	cAliasAna := "cArqAnaApl"  // Alias do arquivo analitico

	If _oFINC0215 <> Nil
		_oFINC0215:Delete()
		_oFINC0215 := Nil
	Endif

	_oFINC0215 := FWTemporaryTable():New( cAliasAna )
	_oFINC0215:SetFields(aCposAna)
	_oFINC0215:AddIndex("1", aChave )

	//------------------
	//Cria��o da tabela temporaria
	//------------------
	_oFINC0215:Create()

Case nArquivo == 3 // Pedidos de compras
	aCposAna := {}
	Aadd( aCposAna, { "FILIAL"  , "C", TamSx3("C7_FILIAL")[1], 0 } )
	Aadd( aCposAna, { "Periodo", "C",  25, 0 } )
	Aadd( aCposAna, { "DATAX"  , "D", 08, 0} )
	Aadd( aCposAna, { "NUMERO" , "C", TamSx3("C7_NUM")[1], 0 } )
	Aadd( aCposAna, { "EMISSAO", "D",  8, 0 } )
	Aadd( aCposAna, { "CLIFOR" , "C", TamSx3("E5_CLIFOR")[1], 0 } )
	Aadd( aCposAna, { "TIPO"   , "N", TamSx3("C7_TIPO")[1], 0 } )
	Aadd( aCposAna, { "ITEM"   , "C", TamSx3("C7_ITEM")[1], 0 } )
	Aadd( aCposAna, { "NomCliFor", "C", TamSx3("A1_NOME")[1], 0 } )
	Aadd( aCposAna, { "PRODUTO", "C", TamSx3("C7_PRODUTO")[1], 0 } )
	Aadd( aCposAna, { "DESCPRO", "C", TamSx3("B1_DESC")[1], 0 } )
	Aadd( aCposAna, { "SALDO"  , "N", Max(TamSx3("E1_SALDO")[1]  ,;
				 					            	TamSx3("E2_SALDO")[1]) , TamSx3("E1_SALDO")[2] } )
	Aadd( aCposAna, { "VALPAGANT"  , "N", Max(TamSx3("E1_SALDO")[1]  ,;
				 					            	TamSx3("E2_SALDO")[1]) , TamSx3("E1_SALDO")[2] } )
	Aadd( aCposAna, { "CHAVE"  , "C", 40, 0 } )
	Aadd( aCposAna, { "Apelido", "C", 10, 0 } )
	Aadd( aCposAna, { "CampoNulo", "C", 1, 0 } )
	Aadd( aCposAna, { "Flag"     , "L", 1, 0 } )
	cAliasAna := "cArqAnaPc"  // Alias do arquivo analitico

	If _oFINC0216 <> Nil
		_oFINC0216:Delete()
		_oFINC0216 := Nil
	Endif

	_oFINC0216 := FWTemporaryTable():New( cAliasAna )
	_oFINC0216:SetFields(aCposAna)
	_oFINC0216:AddIndex("1", aChave )

	//------------------
	//Cria��o da tabela temporaria
	//------------------
	_oFINC0216:Create()

Case nArquivo == 4 // Pedidos de vendas
	aCposAna := {}
	Aadd( aCposAna, { "FILIAL"  , "C", TamSx3("C5_FILIAL")[1], 0 } )
	Aadd( aCposAna, { "Periodo", "C",  25, 0 } )
	Aadd( aCposAna, { "DATAX"  , "D", 08, 0} )
	Aadd( aCposAna, { "NUMERO" , "C", TamSx3("C5_NUM")[1], 0 } )
	Aadd( aCposAna, { "EMISSAO", "D",  8, 0 } )
	Aadd( aCposAna, { "CLIFOR" , "C", TamSx3("E5_CLIFOR")[1], 0 } )
	Aadd( aCposAna, { "TIPO"   , "C", TamSx3("C5_TIPO")[1], 0 } )
	Aadd( aCposAna, { "NomCliFor", "C", TamSx3("A1_NOME")[1], 0 } )
	Aadd( aCposAna, { "LOJAENT", "C", TamSx3("C5_LOJAENT")[1], 0 } )
	Aadd( aCposAna, { "LOJACLI", "C", TamSx3("C5_LOJAENT")[1], 0 } )
	Aadd( aCposAna, { "SALDO"  , "N", Max(TamSx3("E1_SALDO")[1]  ,;
					 					            TamSx3("E2_SALDO")[1]) , TamSx3("E1_SALDO")[2] } )
	Aadd( aCposAna, { "VALRECANT", "N", Max(TamSx3("E1_SALDO")[1]  ,;
					 					            TamSx3("E2_SALDO")[1]) , TamSx3("E1_SALDO")[2] } )	// Valor Adiantamento.
	Aadd( aCposAna, { "CHAVE"  , "C", 40, 0 } )
	Aadd( aCposAna, { "Apelido", "C", 10, 0 } )
	Aadd( aCposAna, { "CampoNulo", "C", 1, 0 } )
	Aadd( aCposAna, { "Flag"     , "L", 1, 0 } )

	cAliasAna := "cArqAnaPv"  // Alias do arquivo analitico

	If _oFINC0217 <> Nil
		_oFINC0217:Delete()
		_oFINC0217 := Nil
	Endif

	_oFINC0217 := FWTemporaryTable():New( cAliasAna )
	_oFINC0217:SetFields(aCposAna)
	_oFINC0217:AddIndex("1", aChave )

	//------------------
	//Cria��o da tabela temporaria
	//------------------
	_oFINC0217:Create()

Case nArquivo == 6 // Cheques pendentes
	aCposAna := {}
	Aadd( aCposAna, { "FILIAL"  , "C", TamSx3("EF_FILIAL")[1], 0 } )
	Aadd( aCposAna, { "Periodo" , "C",  25, 0 } )
	Aadd( aCposAna, { "DATAX"   , "D", 08, 0} )
	Aadd( aCposAna, { "NUMERO"  , "C", TamSx3("EF_NUM")[1], 0 } )
	Aadd( aCposAna, { "BANCO"   , "C", TamSx3("EF_BANCO")[1], 0 } )
	Aadd( aCposAna, { "AGENCIA" , "C", TamSx3("EF_AGENCIA")[1], 0 } )
	Aadd( aCposAna, { "CONTA"   , "C", TamSx3("EF_CONTA")[1], 0 } )
	Aadd( aCposAna, { "SALDO"   , "N", TamSx3("EF_VALOR")[1], TamSx3("EF_VALOR")[2]})
	Aadd( aCposAna, { "CHAVE"   , "C", 40, 0 } )
	Aadd( aCposAna, { "Apelido" , "C", 10, 0 } )
	Aadd( aCposAna, { "CampoNulo", "C", 1, 0 } )
	Aadd( aCposAna, { "Flag"     , "L", 1, 0 } )

	cAliasAna := "cArqAnaChq"  // Alias do arquivo analitico

	If _oFINC0218 <> Nil
		_oFINC0218:Delete()
		_oFINC0218 := Nil
	Endif

	_oFINC0218 := FWTemporaryTable():New( cAliasAna )
	_oFINC0218:SetFields(aCposAna)
	_oFINC0218:AddIndex("1", aChave )

	//------------------
	//Cria��o da tabela temporaria
	//------------------
	_oFINC0218:Create()

Case nArquivo == 7 // Doctos. Transporte
	aCposAna := {}
	Aadd( aCposAna, { "FILIAL"  , "C", TamSx3("DT6_FILIAL")[1], 0 } )
	Aadd( aCposAna, { "Periodo" , "C",  25, 0 } )
	Aadd( aCposAna, { "DATAX"   , "D", 08, 0} )
	Aadd( aCposAna, { "FILDEB"  , "C", IIf( lFWCodFil, FWGETTAMFILIAL, TamSx3("DT6_FILDEB")[1] ), 0 } )
	Aadd( aCposAna, { "FILDOC"  , "C", IIf( lFWCodFil, FWGETTAMFILIAL, TamSx3("DT6_FILDOC")[1] ), 0 } )
	Aadd( aCposAna, { "DOC"   , "C", TamSx3("DT6_DOC")[1], 0 } )
	Aadd( aCposAna, { "SERIE" , "C", TamSx3("DT6_SERIE")[1], 0 } )
	Aadd( aCposAna, { "EMISSAO" , "D",  8, 0 } )
	Aadd( aCposAna, { "SALDO"   , "N", TamSx3("DT6_VALTOT")[1], TamSx3("DT6_VALTOT")[2]})
	Aadd( aCposAna, { "CHAVE"   , "C", 40, 0 } )
	Aadd( aCposAna, { "Apelido" , "C", 10, 0 } )
	Aadd( aCposAna, { "CampoNulo", "C", 1, 0 } )
	Aadd( aCposAna, { "Flag"     , "L", 1, 0 } )

	cAliasAna := "cArqAnaCtrc"  // Alias do arquivo analitico

	aChave := {"DATAX","FILDOC","DOC","SERIE"}

	If _oFINC0219 <> Nil
		_oFINC0219:Delete()
		_oFINC0219 := Nil
	Endif

	_oFINC0219 := FWTemporaryTable():New( cAliasAna )
	_oFINC0219:SetFields(aCposAna)
	_oFINC0219:AddIndex("1", aChave )

	//------------------
	//Cria��o da tabela temporaria
	//------------------
	_oFINC0219:Create()

Case nArquivo == 8 // Solicitacoes de Fundo
	aCposAna := {}
	Aadd( aCposAna, { "Periodo"	,"C"	,25														,0						} )
	Aadd( aCposAna, { "DATAX"	,"D"	,08														,0						} )
	Aadd( aCposAna, { "FILIAL"  ,"C"	,If(lFWCodFil,FWGETTAMFILIAL,TamSx3("FJA_FILIAL")[1])	,0						} )
	Aadd( aCposAna, { "SOLFUN"	,"C"	,TamSX3("FJA_SOLFUN")[1]								,0						} ) //Codigo da Solic Fundo
	Aadd( aCposAna, { "FORNEC"	,"C"	,TamSX3("FJA_FORNEC")[1]								,0						} ) //Fornecedor
	Aadd( aCposAna, { "LOJA"	,"C"	,TamSX3("FJA_LOJA")[1]									,0						} ) //Loja
	Aadd( aCposAna, { "DATAPR"	,"D"	,08														,0						} ) //Data Prevista Pagamento
	Aadd( aCposAna, { "SALDO"	,"N"	,TamSx3("FJA_VALOR")[1]									,TamSx3("FJA_VALOR")[2]	} )
	Aadd( aCposAna, { "CHAVE"	,"C"	,40														,0						} )
	Aadd( aCposAna, { "Apelido"	,"C"	,10														,0						} )
	Aadd( aCposAna, { "CampoNulo", "C", 1, 0 } )
	Aadd( aCposAna, { "Flag"     , "L", 1, 0 } )

	cAliasAna := "cArqAnaSol"  // Alias do arquivo analitico

	aChave := {"DATAX","SOLFUN"}

	If _oFINC021a <> Nil
		_oFINC021a:Delete()
		_oFINC021a := Nil
	Endif

	_oFINC021a := FWTemporaryTable():New( cAliasAna )
	_oFINC021a:SetFields(aCposAna)
	_oFINC021a:AddIndex("1", aChave )

	//------------------
	//Cria��o da tabela temporaria
	//------------------
	_oFINC021a:Create()

Case nArquivo == 09 // Pedido de Compra de Maquinas - DMS
	aRetDMS := VM210CriaTmpAna("MAQ_COMPRA")
	aCposAna  := aRetDMS[1]
	cAliasAna := aRetDMS[2]

	Aadd( aCposAna, { "CampoNulo", "C", 1, 0 } )
	Aadd( aCposAna, { "Flag"     , "L", 1, 0 } )

	If _oFINC021e <> Nil
		_oFINC021e:Delete()
		_oFINC021e := Nil
	Endif
	_oFINC021e := FWTemporaryTable():New( cAliasAna )
	_oFINC021e:SetFields(aCposAna)
	_oFINC021e:AddIndex("1", aChave )

	//------------------
	//Cria��o da tabela temporaria
	//------------------
	_oFINC021e:Create()

Case nArquivo == 10 // Pedido de Compra de Maquinas - DMS
	aRetDMS := VM210CriaTmpAna("MAQ_VENDA")
	aCposAna  := aRetDMS[1]
	cAliasAna := aRetDMS[2]

	Aadd( aCposAna, { "CampoNulo", "C", 1, 0 } )
	Aadd( aCposAna, { "Flag"     , "L", 1, 0 } )

	If _oFINC021f <> Nil
		_oFINC021f:Delete()
		_oFINC021f := Nil
	Endif
	_oFINC021f := FWTemporaryTable():New( cAliasAna )
	_oFINC021f:SetFields(aCposAna)
	_oFINC021f:AddIndex("1", aChave )

	//------------------
	//Cria��o da tabela temporaria
	//------------------
	_oFINC021f:Create()

EndCase


Return {cAliasAna,cArqAna}


/*/{Protheus.doc}
Gera o Fluxo de Caixa analitico em tabela do banco para ser usado no Power BI
@author Jeferson Silva
@since 02/01/2020
@version 1.0
@return Nil,
@example
Funcao Original FluxoAna  TOTVS - Claudio D. de Souza
M180_GeraFC()
/*/
Static FUNCTION M180_GeraFC(cAliasP,cAliasR,cAliasPc,cAliasPv,cAliasCo,cAliasEmp,;
								 cAliasApl,cAliasCtrc,cPeriodo,aFluxo,aTotais,nBancos,nCaixas,nAtrReceber,;
								 nAtrPagar,aPeriodo,cAliasChq,nLimCred,cAliasSol,;
								 cAliasDMSCompra,cAliasDMSVenda)     
			
Local aArea    		:= GetArea()
Local cDataExtracao	:= DtoC( Date() ) + " - " + Time()
Local cTextoLogQry	:= ''
Local aAlias                                    
                         
//--------------------------------------------------------------
//-- Query para geracao do tabela dFiliais
//--------------------------------------------------------------
	
SM0->( dbSeek( cEmpAnt, .t. ) )
cQuery := ' Values '
While SM0->( !Eof() ) .and. SM0->M0_CODIGO == cEmpAnt
   	cQuery += " ('"+SM0->M0_CODFIL+"','"+SM0->M0_FILIAL+"',"
	cQuery += " '"+Dtoc(mv_par01)+"',"
	cQuery += " '"+Dtoc(mv_par02)+"',"
	cQuery += " '"+cDataExtracao+"'),"
	SM0->( dbSkip() )
End  
SM0->( dbSeek( cEmpAnt + cFilAnt, .f. ) )

cScript := " Insert Into dFiliais (Filial, NomeFilial, PeriodoInicialExtracao, PeriodoFinalExtracao, DataExtracao)"
cQuery := SubStr(cQuery,1,Len(cQuery)-1)

TCSQLExec(cScript+cQuery)
cTextoLogQry += cScript + CRLF + cQuery + CRLF             
                                   
                                                    
//--------------------------------------------------------------
//-- Query para geracao do tabela dProcessos
//--------------------------------------------------------------
cScript := " Insert Into dProcessos (Apelido, Descricao)"	
cQuery := " Values "
cQuery += " ('CP','Contas a Pagar'),"
cQuery += " ('CR','Contas a Receber'),"                
cQuery += " ('PC','Pedidos de Compra'),"                
cQuery += " ('PV','Pedidos de Venda'),"                
cQuery += " ('APL','Aplica��es'),"
cQuery += " ('EMP','Empr�stimos'),"
cQuery += " ('SOF','Solicita��es de Fundos'),"
cQuery += " ('DMSC','Compras DMS'),"
cQuery += " ('DMSV','Vendas DMS'),"
cQuery += " ('CTRC','Documentos de Transporte'),"
cQuery += " ('CHQ','Cheques'),"
cQuery += " ('CRI','Inadimpl�ncia Contas a Receber'),"
cQuery += " ('CPI','Inadimpl�ncia Contas a Pagar')"  

TCSQLExec(cScript+cQuery)
cTextoLogQry += cScript + CRLF + cQuery + CRLF             
                                                    
                                                    
//--------------------------------------------------------------
//-- Query para geracao do tabela fSaldosBancarios
//--------------------------------------------------------------
	
cScript := " Insert Into fSaldosBancarios(Filial, BancoSB, AgenciaSB, ContaSB, NomeSB,ChaveSB, Data, Valor, PeriodoInicialExtracao, PeriodoFinalExtracao, DataExtracao)"

cQuery := " Select  "

cQuery += " E8_FILIAL, "       
cQuery += " E8_BANCO, "
cQuery += " E8_AGENCIA, "
cQuery += " E8_CONTA, "   
cQuery += " A6_NOME, "     
cQuery += " Rtrim(A6_NOME)+' - '+E8_BANCO+'-'+E8_AGENCIA+'-'+E8_CONTA ChaveSB, "     
cQuery += " '"+Dtoc(mv_par01-1)+"'  DATAX, "
cQuery += " E8_SALATUA SALDO, "
cQuery += " '"+Dtoc(mv_par01)+"' PeriodoInicialExtracao,"
cQuery += " '"+Dtoc(mv_par02)+"' PeriodoFinalExtracao,"
cQuery += " '"+cDataExtracao+"' DataExtracao "
cQuery += " From "+RetSqlName("SE8")+ " SE8, "+RetSqlName("SA6")+ " SA6 "
cQuery += " Where E8_DTSALAT = (Select Max(E8_DTSALAT) From "+RetSqlName("SE8")+ " SE8_1 " 
cQuery += " 						Where SE8.E8_FILIAL=SE8_1.E8_FILIAL and SE8.E8_BANCO=SE8_1.E8_BANCO and SE8.E8_AGENCIA=SE8_1.E8_AGENCIA and SE8.E8_CONTA=SE8_1.E8_CONTA and E8_DTSALAT < '"+Dtos(mv_par01)+"'"+ " and SE8_1.D_E_L_E_T_ = '')"
cQuery += "   And SE8.D_E_L_E_T_ = '' " 
cQuery += "   And SA6.D_E_L_E_T_ = '' "  
cQuery += "   And SE8.E8_FILIAL = SA6.A6_FILIAL " 
cQuery += "   And SE8.E8_AGENCIA = SA6.A6_AGENCIA " 
cQuery += "   And SE8.E8_BANCO = SA6.A6_COD " 
cQuery += "   And SE8.E8_CONTA = SA6.A6_NUMCON " 
cQuery += "   And SA6.A6_FLUXCAI <> 'N' " 
        
TCSQLExec(cScript+cQuery)
cTextoLogQry += cScript + CRLF + cQuery + CRLF

//--------------------------------------------------------------
//-- Query para geracao do tabela fFluxodeCaixa
//--------------------------------------------------------------
	
If cAliasP != Nil .And. Select(cAliasP) > 0

    cScript := " Insert Into fFluxodeCaixa (Filial, Chave, Apelido, Periodo, Data, Valor, PrefixoCP, NumeroCP, ParecelaCP, TipoCP, NaturezaCP, DescricaoNaturezaCP, FornecedorCP, NomeFornecedorCP, LojaCP, EmissaoCP, VencimentoCP, VencimentoRealCP, HistoricoCP,  PeriodoInicialExtracao, PeriodoFinalExtracao, DataExtracao)"

    cQuery := " Select  "

    cQuery += " FILIAL, "
    cQuery += " CHAVE, "
    cQuery += " IIF( VENCTO < '"+Dtos(mv_par01)+"' , 'CPI','CP') APELIDO, "
    cQuery += " PERIODO, "
    cQuery += " Substring(DATAX,7,2)+'/'+Substring(DATAX,5,2)+'/'+Substring(DATAX,1,4) DATAX, "
    cQuery += " SALDO, "
    
	cQuery += " PREFIXO, "
    cQuery += " NUM, "
    cQuery += " PARCELA, "
    cQuery += " TIPO, "
 	cQuery += " NATUREZA, "
 	cQuery += " DESCNAT, "
    cQuery += " CLIFOR, "
    cQuery += " NOMCLIFOR, "
    cQuery += " LOJA, "

    cQuery += " Substring(EMISSAO,7,2)+'/'+Substring(EMISSAO,5,2)+'/'+Substring(EMISSAO,1,4) EMISSAO, "
    cQuery += " Substring(VENCTO,7,2)+'/'+Substring(VENCTO,5,2)+'/'+Substring(VENCTO,1,4) VENCTO, "
    cQuery += " Substring(VENCREA,7,2)+'/'+Substring(VENCREA,5,2)+'/'+Substring(VENCREA,1,4) VENCREA, "
    cQuery += " HIST, "
    
    cQuery += " '"+Dtoc(mv_par01)+"' PeriodoInicialExtracao,"
    cQuery += " '"+Dtoc(mv_par02)+"' PeriodoFinalExtracao,"
    cQuery += " '"+cDataExtracao+"' DataExtracao"
    cQuery += " From " + _oFINC0211:GetRealName() 

    TCSQLExec(cScript+cQuery)
	cTextoLogQry += cScript + CRLF + cQuery + CRLF
Endif

If cAliasR != Nil .And. Select(cAliasR) > 0
	
	cScript := " Insert Into fFluxodeCaixa (Filial, Chave, Apelido, Periodo, Data, Valor, PrefixoCR, NumeroCR, ParecelaCR, TipoCR, NaturezaCR, DescricaoNaturezaCR, ClienteCR, NomeClienteCR, LojaCR, SituacaoCR, PortadorCR, AgenciaDepositarioCR, ContaDepositarioCR, EmissaoCR, VencimentoCR, VencimentoRealCR, HistoricoCR, PeriodoInicialExtracao, PeriodoFinalExtracao, DataExtracao)"

    cQuery := " Select  "

    cQuery += " FILIAL, "
    cQuery += " CHAVE, "
    cQuery += " IIF( VENCTO < '"+Dtos(mv_par01)+"' , 'CRI','CR') APELIDO, "
    cQuery += " PERIODO, "
    cQuery += " Substring(DATAX,7,2)+'/'+Substring(DATAX,5,2)+'/'+Substring(DATAX,1,4) DATAX, "
    cQuery += " SALDO, "
   
	cQuery += " PREFIXO, "
    cQuery += " NUM, "
    cQuery += " PARCELA, "
    cQuery += " TIPO, "
	cQuery += " NATUREZA, "
	cQuery += " DESCNAT, "
    cQuery += " CLIFOR, "
    cQuery += " NOMCLIFOR, "
    cQuery += " LOJA, "
    cQuery += " SITUACAO, "
    cQuery += " PORTADO, "
    cQuery += " AGEDEP, "
    cQuery += " CONTA, "

    cQuery += " Substring(EMISSAO,7,2)+'/'+Substring(EMISSAO,5,2)+'/'+Substring(EMISSAO,1,4) EMISSAO, "
    cQuery += " Substring(VENCTO,7,2)+'/'+Substring(VENCTO,5,2)+'/'+Substring(VENCTO,1,4) VENCTO, "
    cQuery += " Substring(VENCREA,7,2)+'/'+Substring(VENCREA,5,2)+'/'+Substring(VENCREA,1,4) VENCREA, "
    cQuery += " HIST, "
       
    cQuery += " '"+Dtoc(mv_par01)+"' PeriodoInicialExtracao,"
    cQuery += " '"+Dtoc(mv_par02)+"' PeriodoFinalExtracao,"
    cQuery += " '"+cDataExtracao+"' DataExtracao"
    cQuery += " From " + _oFINC0212:GetRealName()  

    TCSQLExec(cScript+cQuery)
	cTextoLogQry += cScript + CRLF + cQuery + CRLF          
	
Endif

If cAliasPc != Nil .And. Select(cAliasPc) > 0
    
	cScript := " Insert Into fFluxodeCaixa (Filial, Chave, Apelido, Periodo, Data, Valor, NumeroPC, EmissaoPC, FornecedorPC, NumeFornecedorPC, TipoPC, ItemPC, ProdutoPC, DescricaoProdutoPC, PeriodoInicialExtracao, PeriodoFinalExtracao, DataExtracao)"
	
    cQuery := " Select  "

    cQuery += " FILIAL, "
    cQuery += " CHAVE, "
    cQuery += " 'PC' APELIDO, "
    cQuery += " PERIODO, "
    cQuery += " Substring(DATAX,7,2)+'/'+Substring(DATAX,5,2)+'/'+Substring(DATAX,1,4) DATAX, "
    cQuery += " SALDO - VALPAGANT, "

    cQuery += " NUMERO, "
    cQuery += " Substring(EMISSAO,7,2)+'/'+Substring(EMISSAO,5,2)+'/'+Substring(EMISSAO,1,4) EMISSAO, "
    cQuery += " CLIFOR, "
    cQuery += " NOMCLIFOR, "
    cQuery += " TIPO, "
    cQuery += " ITEM, "
    cQuery += " PRODUTO, "
    cQuery += " DESCPRO, "

    cQuery += " '"+Dtoc(mv_par01)+"' PeriodoInicialExtracao,"
    cQuery += " '"+Dtoc(mv_par02)+"' PeriodoFinalExtracao,"
    cQuery += " '"+cDataExtracao+"' DataExtracao"
    cQuery += " From " + _oFINC0216:GetRealName() 

    TCSQLExec(cScript+cQuery)
	cTextoLogQry += cScript + CRLF + cQuery + CRLF   
	
Endif
If cAliasPv != Nil .And. Select(cAliasPv) > 0

	cScript := " Insert Into fFluxodeCaixa (Filial, Chave, Apelido, Periodo, Data, Valor, NumeroPV, EmissaoPV, ClientePV, NumeClientePV, TipoPV, LojaEntradaPV, LojaClientePV, PeriodoInicialExtracao, PeriodoFinalExtracao, DataExtracao)"
 
    cQuery := " Select  "

    cQuery += " FILIAL, "
    cQuery += " CHAVE, "
    cQuery += " 'PV' APELIDO, "
    cQuery += " PERIODO, "
    cQuery += " Substring(DATAX,7,2)+'/'+Substring(DATAX,5,2)+'/'+Substring(DATAX,1,4) DATAX, "
    cQuery += " SALDO - VALRECANT, "

    cQuery += " NUMERO, "
    cQuery += " Substring(EMISSAO,7,2)+'/'+Substring(EMISSAO,5,2)+'/'+Substring(EMISSAO,1,4) EMISSAO, "
    cQuery += " CLIFOR, "
    cQuery += " NOMCLIFOR, "
    cQuery += " TIPO, "
    cQuery += " LOJAENT, "
    cQuery += " LOJACLI, "

    cQuery += " '"+Dtoc(mv_par01)+"' PeriodoInicialExtracao,"
    cQuery += " '"+Dtoc(mv_par02)+"' PeriodoFinalExtracao,"
    cQuery += " '"+cDataExtracao+"' DataExtracao"
    cQuery += " From " + _oFINC0217:GetRealName() 

    TCSQLExec(cScript+cQuery)
	cTextoLogQry += cScript + CRLF + cQuery + CRLF
	
Endif
If cAliasCo != Nil .And. Select(cAliasCo) > 0
	
	cScript := " Insert Into fFluxodeCaixa (Filial, Chave, Apelido, Periodo, Data, Valor, PrefixoCO, NumeroCO, ParcelaCO, VendedorCO, NomeVendedorCO, PeriodoInicialExtracao, PeriodoFinalExtracao, DataExtracao)"
    
	cQuery := " Select  "

    cQuery += " FILIAL, "
    cQuery += " CHAVE, "
    cQuery += " 'CO' APELIDO, "
    cQuery += " PERIODO, "
    cQuery += " Substring(DATAX,7,2)+'/'+Substring(DATAX,5,2)+'/'+Substring(DATAX,1,4) DATAX, "
    cQuery += " SALDO, "

    cQuery += " PREFIXO, "
    cQuery += " NUMERO, "
    cQuery += " PARCELA, "
    cQuery += " VEND, "
    cQuery += " NOMEVEND, "

    cQuery += " '"+Dtoc(mv_par01)+"' PeriodoInicialExtracao,"
    cQuery += " '"+Dtoc(mv_par02)+"' PeriodoFinalExtracao,"
    cQuery += " '"+cDataExtracao+"' DataExtracao"
    cQuery += " From " + _oFINC0213:GetRealName()

    TCSQLExec(cScript+cQuery)
	cTextoLogQry += cScript + CRLF + cQuery + CRLF

Endif
If cAliasEmp != Nil .And. Select(cAliasEmp) > 0
    
	cScript := " Insert Into fFluxodeCaixa (Filial, Chave, Apelido, Periodo, Data, Valor, NumeroEMP, BancoEMP, AgenciaEMP, ContaEMP, EmissaoEMP, PeriodoInicialExtracao, PeriodoFinalExtracao, DataExtracao)"
	
	cQuery := " Select  "

    cQuery += " FILIAL, "
    cQuery += " CHAVE, "
    cQuery += " 'EMP' APELIDO, "
    cQuery += " PERIODO, "
    cQuery += " Substring(DATAX,7,2)+'/'+Substring(DATAX,5,2)+'/'+Substring(DATAX,1,4) DATAX, "
    cQuery += " SALDO, "

    cQuery += " NUMERO, "
    cQuery += " BANCO, "
    cQuery += " AGENCIA, "
    cQuery += " CONTA, "
    cQuery += " Substring(EMISSAO,7,2)+'/'+Substring(EMISSAO,5,2)+'/'+Substring(EMISSAO,1,4) EMISSAO, "

    cQuery += " '"+Dtoc(mv_par01)+"' PeriodoInicialExtracao,"
    cQuery += " '"+Dtoc(mv_par02)+"' PeriodoFinalExtracao,"
    cQuery += " '"+cDataExtracao+"' DataExtracao"
    cQuery += " From " + _oFINC0214:GetRealName()

    TCSQLExec(cScript+cQuery)
	cTextoLogQry += cScript + CRLF + cQuery + CRLF

Endif
If cAliasApl != Nil .And. Select(cAliasApl) > 0
	
	cScript := " Insert Into fFluxodeCaixa (Filial, Chave, Apelido, Periodo, Data, Valor, NumeroAPL, BancoAPL, AgenciaAPL, ContaAPL, EmissaoAPL, PeriodoInicialExtracao, PeriodoFinalExtracao, DataExtracao)"

    cQuery := " Select  "

    cQuery += " FILIAL, "
    cQuery += " CHAVE, "
    cQuery += " 'APL' APELIDO, "
    cQuery += " PERIODO, "
    cQuery += " Substring(DATAX,7,2)+'/'+Substring(DATAX,5,2)+'/'+Substring(DATAX,1,4) DATAX, "
    cQuery += " SALDO, "

    cQuery += " NUMERO, "
    cQuery += " BANCO, "
    cQuery += " AGENCIA, "
    cQuery += " CONTA, "
    cQuery += " Substring(EMISSAO,7,2)+'/'+Substring(EMISSAO,5,2)+'/'+Substring(EMISSAO,1,4) EMISSAO, "

    cQuery += " '"+Dtoc(mv_par01)+"' PeriodoInicialExtracao,"
    cQuery += " '"+Dtoc(mv_par02)+"' PeriodoFinalExtracao,"
    cQuery += " '"+cDataExtracao+"' DataExtracao"
    cQuery += " From " + _oFINC0215:GetRealName()

    TCSQLExec(cScript+cQuery)
	cTextoLogQry += cScript + CRLF + cQuery + CRLF

Endif
If cAliasChq != Nil .And. Select(cAliasChq) > 0

	cScript := " Insert Into fFluxodeCaixa (Filial, Chave, Apelido, Periodo, Data, Valor, NumeroCHQ, BancoCHQ, AgenciaCHQ, EmissaoCHQ, PeriodoInicialExtracao, PeriodoFinalExtracao, DataExtracao)"
	
	cQuery := " Select  "

    cQuery += " FILIAL, "
    cQuery += " CHAVE, "
    cQuery += " 'CHQ' APELIDO, "
    cQuery += " PERIODO, "
    cQuery += " Substring(DATAX,7,2)+'/'+Substring(DATAX,5,2)+'/'+Substring(DATAX,1,4) DATAX, "
    cQuery += " SALDO, "

    cQuery += " NUMERO, "
    cQuery += " BANCO, "
    cQuery += " AGENCIA, "
    cQuery += " CONTA, "
    cQuery += " Substring(EMISSAO,7,2)+'/'+Substring(EMISSAO,5,2)+'/'+Substring(EMISSAO,1,4) EMISSAO, "

    cQuery += " '"+Dtoc(mv_par01)+"' PeriodoInicialExtracao,"
    cQuery += " '"+Dtoc(mv_par02)+"' PeriodoFinalExtracao,"
    cQuery += " '"+cDataExtracao+"' DataExtracao"
    cQuery += " From " + _oFINC0218:GetRealName()

    TCSQLExec(cScript+cQuery)
	cTextoLogQry += cScript + CRLF + cQuery + CRLF

Endif
If cAliasCtrc != Nil .And. Select(cAliasCtrc) > 0

	cScript := " Insert Into fFluxodeCaixa (Filial, Chave, Apelido, Periodo, Data, Valor, FilialDebitoCTR, FilialDocumentoCTR, DocumentoCTR, SerieCTR, EmissaoCTR, PeriodoInicialExtracao, PeriodoFinalExtracao, DataExtracao)"
	
	cQuery := " Select  "

    cQuery += " FILIAL, "
    cQuery += " CHAVE, "
    cQuery += " 'CTRC' APELIDO, "
    cQuery += " PERIODO, "
    cQuery += " Substring(DATAX,7,2)+'/'+Substring(DATAX,5,2)+'/'+Substring(DATAX,1,4) DATAX, "
    cQuery += " SALDO, "

    cQuery += " FILDEB, "
    cQuery += " FILDOC, "
    cQuery += " DOC, "
    cQuery += " SERIE, "
    cQuery += " Substring(EMISSAO,7,2)+'/'+Substring(EMISSAO,5,2)+'/'+Substring(EMISSAO,1,4) EMISSAO, "

    cQuery += " '"+Dtoc(mv_par01)+"' PeriodoInicialExtracao,"
    cQuery += " '"+Dtoc(mv_par02)+"' PeriodoFinalExtracao,"
    cQuery += " '"+cDataExtracao+"' DataExtracao"
    cQuery += " From " + _oFINC0219:GetRealName()

    TCSQLExec(cScript+cQuery)
	cTextoLogQry += cScript + CRLF + cQuery + CRLF

Endif
//-----------------------
// Solicitacoes de Fundo
//-----------------------
If cAliasSol != Nil .And. Select(cAliasSol) > 0

	cScript := " Insert Into fFluxodeCaixa (Filial, Chave, Apelido, Periodo, Data, Valor, SolcitacaoSOL, FornecedorSOL, LojaSOL, PrevisaoPagamentoSOL, PeriodoInicialExtracao, PeriodoFinalExtracao, DataExtracao)"

    cQuery := " Select  "

    cQuery += " FILIAL, "
    cQuery += " CHAVE, "
    cQuery += " 'SOF' APELIDO, "
    cQuery += " PERIODO, "
    cQuery += " Substring(DATAX,7,2)+'/'+Substring(DATAX,5,2)+'/'+Substring(DATAX,1,4) DATAX, "
    cQuery += " SALDO, "

    cQuery += " SOLFUN, "
    cQuery += " FORNEC, "
    cQuery += " LOJA, "
    cQuery += " Substring(DATAPR,7,2)+'/'+Substring(DATAPR,5,2)+'/'+Substring(DATAPR,1,4) DATAPR, "

    cQuery += " '"+Dtoc(mv_par01)+"' PeriodoInicialExtracao,"
    cQuery += " '"+Dtoc(mv_par02)+"' PeriodoFinalExtracao,"
    cQuery += " '"+cDataExtracao+"' DataExtracao"
    cQuery += " From " + _oFINC021a:GetRealName()

    TCSQLExec(cScript+cQuery)
	cTextoLogQry += cScript + CRLF + cQuery + CRLF

Endif

If cAliasDMSCompra != Nil .And. Select(cAliasDMSCompra) > 0

	cScript := " Insert Into fFluxodeCaixa (Filial, Chave, Apelido, Periodo, Data, Valor, CodigoDMSC, PedidoDMSC, EmissaoDMSC, ChassiDMSC, ModeloDMSC, PeriodoInicialExtracao, PeriodoFinalExtracao, DataExtracao)"
    
	cQuery := " Select  "

    cQuery += " FILIAL, "
    cQuery += " CHAVE, "
    cQuery += " 'DMSC' APELIDO, "
    cQuery += " PERIODO, "
    cQuery += " Substring(DATAX,7,2)+'/'+Substring(DATAX,5,2)+'/'+Substring(DATAX,1,4) DATAX, "
    cQuery += " SALDO, "

    cQuery += " NUMERO, "
    cQuery += " PEDFAB, "
    cQuery += " Substring(EMISSAO,7,2)+'/'+Substring(EMISSAO,5,2)+'/'+Substring(EMISSAO,1,4) EMISSAO, "
    cQuery += " CHASSI, "
    cQuery += " MODELO, "

    cQuery += " '"+Dtoc(mv_par01)+"' PeriodoInicialExtracao,"
    cQuery += " '"+Dtoc(mv_par02)+"' PeriodoFinalExtracao,"
    cQuery += " '"+cDataExtracao+"' DataExtracao"
    cQuery += " From " + _oFINC021e:GetRealName()

    TCSQLExec(cScript+cQuery)
	cTextoLogQry += cScript + CRLF + cQuery + CRLF

Endif

If cAliasDMSVenda != Nil .And. Select(cAliasDMSVenda) > 0

	cScript := " Insert Into fFluxodeCaixa (Filial, Chave, Apelido, Periodo, Data, Valor, NumeroDMSV, ClienteDMSV, LojaDMSV, NomeClienteDMSV, EmissoaDMSV, PeriodoInicialExtracao, PeriodoFinalExtracao, DataExtracao)"
    
    cQuery := " Select  "

    cQuery += " FILIAL, "
    cQuery += " CHAVE, "
    cQuery += " 'DMSV' APELIDO, "
    cQuery += " PERIODO, "
    cQuery += " Substring(DATAX,7,2)+'/'+Substring(DATAX,5,2)+'/'+Substring(DATAX,1,4) DATAX, "
    cQuery += " SALDO, "

    cQuery += " NUMERO, "
    cQuery += " CLIFOR, "
    cQuery += " LOJACLI, "
    cQuery += " NOMCLIFOR, "
    cQuery += " Substring(EMISSAO,7,2)+'/'+Substring(EMISSAO,5,2)+'/'+Substring(EMISSAO,1,4) EMISSAO, "

    cQuery += " '"+Dtoc(mv_par01)+"' PeriodoInicialExtracao,"
    cQuery += " '"+Dtoc(mv_par02)+"' PeriodoFinalExtracao,"
    cQuery += " '"+cDataExtracao+"' DataExtracao"
    cQuery += " From " + _oFINC021f:GetRealName()

    TCSQLExec(cScript+cQuery)
	cTextoLogQry += cScript + CRLF + cQuery + CRLF

Endif

Memowrite("QryfFluxodeCaixa.txt",cTextoLogQry)

aAlias := {cAliasP,cAliasR,cAliasPc,cAliasPv,cAliasCo,cAliasEmp,cAliasApl,cAliasChq,cAliasCtrc,cAliasSol,cAliasDMSCompra,cAliasDMSVenda}

// Posiciona no primeiro folder valido

// Limpa os filtros dos arquivos temporarios
For nX := 1 To Len(aAlias)
	If aAlias[nX] != Nil .And. Select(aAlias[nX]) > 0
		DbSelectArea(aAlias[nX])
		(aAlias[nX])->(DbClearFil())
	EndIf
Next

RestArea(aArea)

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �Fc021Comis�Autor  �Claudio D. de Souza � Data �  30/08/01   ���
�������������������������������������������������������������������������͹��
���Desc.     � Gera dados no arquivo temporario, a partir do arquivo de   ���
���          � comissoes												  ���
���          � Parametros:                                                ���
���          � dUltData   -> Ultima data do periodo                       ���
���          � lConsFil   -> Considera filiais                            ���
���          � cFilDe     -> Filial inicial                               ���
���          � cFilAte    -> Filial final                                 ���
���          � aFluxo     -> Matriz que contera os dados do fluxo         ���
���          � nMoeda     -> Codigo da Moeda                              ���
���          � lAnalitico -> Gera dados analiticos                        ���
���          � Retorno:                                                   ���
���          � aRet[1] =                                                  ���
���          � cArqAnaCo -> Nome do arquivo analitico                     ���
���          � cAliasCo  -> Alias do arquivo analitico                    ���
�������������������������������������������������������������������������͹��
���Uso       � Finc021                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

/*/{Protheus.doc}
Gera dados no arquivo temporario, a partir do arquivo de comissoes
@author Jeferson Silva
@since 02/01/2020
@version 1.0
@return Nil,
@example
Funcao Original Fc021Comis  TOTVS - Claudio D. de Souza
Fc021Comis()
/*/
Static Function Fc021Comis( dUltData, lConsFil, cFilDe, cFilAte, aFluxo, nMoeda, lAnalitico, aTotais, aPeriodo, lFiliais )
Local cAliasCo
Local cArqAnaCo
Local aCposAna
Local aCposSin
Local cAliasTrb
Local nSaldoTit
Local dDataTrab
Local nAscan
Local cQuery
Local aStru

// Analitico
If lAnalitico
	aCposAna := {}
	Aadd( aCposAna, { "Periodo" , "C", Iif( Len( DtoC(dDataBase) ) > 8, 23, 20 ), 0 } )
	Aadd( aCposAna, { "DATAX"   , "D", 08, 0} )
	Aadd( aCposAna, { "FILIAL"  , "C", IIf( lFWCodFil, FWGETTAMFILIAL, TamSx3("E3_FILIAL")[1] ), 0 } )
	Aadd( aCposAna, { "PREFIXO" , "C", TamSx3("E3_PREFIXO")[1], 0 } )
	Aadd( aCposAna, { "NUMERO"  , "C", TamSx3("E3_NUM")[1], 0 } )
	Aadd( aCposAna, { "PARCELA" , "C", TamSx3("E3_PARCELA")[1], 0 } )
	Aadd( aCposAna, { "VEND"    , "C", TamSx3("E3_VEND")[1], 0 } )
	Aadd( aCposAna, { "NOMEVEND", "C", TamSx3("A3_NOME")[1], 0 } )
	Aadd( aCposAna, { "SALDO"   , "N", Max(TamSx3("E1_SALDO")[1]  ,;
					 					             TamSx3("E2_SALDO")[1]) , TamSx3("E1_SALDO")[2] } )
	Aadd( aCposAna, { "CHAVE"   , "C", 40, 0 } )
	Aadd( aCposAna, { "Apelido" , "C", 10, 0 } )

	cAliasCo := "cArqAnaCo"  // Alias do arquivo analitico

	//�������������������������������Ŀ
	//� Gera tabela tempor�ria        �
	//���������������������������������

	If _oFINC0213 <> Nil
		_oFINC0213:Delete()
		_oFINC0213 := Nil
	Endif

	_oFINC0213 := FWTemporaryTable():New( cAliasCo )
	_oFINC0213:SetFields(aCposAna)
	_oFINC0213:AddIndex("1", {"DATAX"})

	//------------------
	//Cria��o da tabela temporaria
	//------------------
	_oFINC0213:Create()

Endif

aCposSin:={{"DATAX"   , "D" , 08, 0},;
		    	{"ENTR"    , "N" , 17, 2},;
			 	{"SAID"    , "N" , 17, 2},;
			 	{"SALDO"   , "N" , 17, 2},;
			 	{"ENTRAC"  , "N" , 17, 2},;
			 	{"SAIDAC"  , "N" , 17, 2},;
			 	{"SALDOAC" , "N" , 17, 2},;
			 	{"VARIACAO", "N" ,  9, 2},;
			 	{"VARIACAC", "N" ,  9, 2},;
			 	{"FLAG"    , "L" ,  1, 0 }}

//�����������������������������������������������������������Ŀ
//� Atribui valores as variaveis ref a filiais                �
//�������������������������������������������������������������
If !lConsFil
   cFilDe  := xFilial("SE3")
   cFilAte := xFilial("SE3")
EndIf

aStru     := SE3->(dbStruct())
cAliasTrb := "FINC021"

cQuery := "SELECT * "
cQuery += "FROM " + RetSqlName("SE3") + " SE3 "
cQuery += "WHERE "

If lFiliais //Seleciona Filiais
	cQuery += "SE3.E3_FILIAL IN (" + cLisFil + ") AND "
Else
	cQuery += "SE3.E3_FILIAL >= '" + cFilDe + "' AND "
	cQuery += "SE3.E3_FILIAL <= '" + cFilAte + "' AND "
EndIf

cQuery += "SE3.E3_VENCTO >= '" + Dtos( dDataBase ) + "' AND "
cQuery += "SE3.E3_VENCTO <= '" + Dtos( dUltData ) + "' AND "
cQuery += "SE3.E3_DATA = ' ' AND "
cQuery += "SE3.D_E_L_E_T_= ' ' "

cQuery := ChangeQuery(cQuery)

dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasTrb, .T., .T. )
aEval( aStru, {|e| If(e[2]!= "C", TCSetField( cAliasTrb, e[1], e[2], e[3], e[4] ), Nil ) } )

While (cAliasTrb)->( !Eof() ) //IndRegua
	IncProc('Processando Comiss�es') //"Processando Comiss�es"
	dDataTrab := DataValida((cAliasTrb)->E3_VENCTO,.T.)
	//����������������������������������������������������������������Ŀ
	//� Se a data de vencto. nao ultrapassar a ultima data do relatorio�
	//������������������������������������������������������������������
	If dDataTrab <= dUltData
		nSaldoTit := xMoeda((cAliasTrb)->E3_COMIS,1,nMoeda)
		If Abs(nSaldoTit) > 0.0001
			// Pesquisa a data na matriz com os dados a serem exibidos na tela do fluxo
			nAscan := Ascan(aPeriodo, {|e| e[1] == dDataTrab})
			// Verifica se esta no periodo solicitado
			If nAscan > 0
				aFluxo[nAscan][SAIDAS] += nSaldoTit
			Endif
			If lAnalitico .And. nAscan > 0
				RecLock(cAliasCo,.T.)
				(cAliasCo)->Datax	:= dDataTrab
				(cAliasCo)->Periodo	:= aPeriodo[nAscan][2]
				(cAliasCo)->FILIAL	:= (cAliasTrb)->E3_FILIAL
				(cAliasCo)->PREFIXO	:= (cAliasTrb)->E3_PREFIXO
				(cAliasCo)->NUMERO	:= (cAliasTrb)->E3_NUM
				(cAliasCo)->PARCELA	:= (cAliasTrb)->E3_PARCELA
				(cAliasCo)->VEND		:= (cAliasTrb)->E3_VEND
				DbSelectArea("SA3")
				dbSetOrder(1)
				MsSeek(xFilial("SA3")+(cAliasTrb)->E3_VEND)
				DbSelectArea(cAliasTrb)
				(cAliasCo)->NOMEVEND:= SA3->A3_NOME
				cIdentific :=	xFilial("SE3")+;
								   (cAliasTrb)->E3_PREFIXO +;
								   (cAliasTrb)->E3_NUM     +;
								   (cAliasTrb)->E3_PARCELA +;
								   (cAliasTrb)->E3_SEQ
				(cAliasCo)->Chave     := cIdentific
				(cAliasCo)->SALDO     := nSaldoTit
				(cAliasCo)->Apelido   := "SE3"
				MsUnlock()
				// Pesquisa na matriz de totais, os totais de contas a pagar ou a receber
				// da data de trabalho.
				nAscan := Ascan( aTotais[5], {|e| e[1] == dDataTrab})
				If nAscan == 0
					Aadd( aTotais[5], {dDataTrab,nSaldoTit})
				Else
					aTotais[5][nAscan][2] += nSaldoTit // Contabiliza os totais de comiss�es
				Endif
			Endif
		EndIf
	Endif
	(cAliasTrb)->(dbSkip())
EndDo

dbSelectArea(cAliasTrb)
dbCloseArea()
dbSelectArea("SE3")

Return { ,, cArqAnaCo, cAliasCo }

//-----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FC020COMPR

Monta array com Pedidos de Compra (Fluxos de caixa).
Arquivo original: FINXFUN.PRX

@Author	Wagner Xavier
@since	06/07/1992
/*/
//-----------------------------------------------------------------------------------------------------
Static Function fc020Compra(cAliasPc, aTotais, lRegua, nMoeda, aPeriodo, cFilIni, cFilFin, cPedidos, lConsDtBase, aCCustos, aSelFil, lAnalitic)

Local cNumPed
Local cCond
Local i
Local nPrcCompra
Local dData
Local nValIPILiq
Local nTotDesc
Local cFilDe
Local cFilAte
Local cFilPed
Local cSaveFil		:= cFilAnt
Local nAscan		:= 0
Local dDataFluxo	:= {}
Local aDataAux		:= {}
Local nPosData 		:= 0
Local nValTot		:= 0
Local nValIpi		:= 0
Local aVenc			:= {}
Local nDespFrete	:= 0
Local lFc020Com		:= ExistBlock("FC020COM")
Local lFC020CQR		:= ExistBlock("FC020CQR")
Local lF021DtFl		:= ExistBlock("FC021DTF")
Local nDecimais		:= TamSx3("C7_PRECO")[2]
Local nInc			:= 0
Local aSM0			:= AdmAbreSM0()
Local nTaxaMoed		:= 0
Local cCustos		:= ''
Local nX			:= 0
Local lFinc024		:= FwIsInCallStack("FINC024")
Local nValPagAnt	:= 0
Local lPACalc		:= .F. //Controle do calc do PA, para n�o duplic no fluxo de cx quando o pedid tem mais de um item.
Local nTotRegSC7	:= 0
Local lSE2Excl		:= FwModeAccess("SE2",1) == "E" .And. FwModeAccess("SE2",2) == "E" .And. FwModeAccess("SE2",3) == "E"
Local nParcAd		:= 0
Local nDescont		:= 0
Local nI			:= 0
Local cQuery		:= ""
Local aStru			:= SC7->(dbStruct())
Local aData 		:= {}
Local nPos  		:= 0
Local cTblTmp
Local lTES			:= .F.
Local __oMovPA		:= NIL

Default nMoeda		:= 1
Default cFilIni		:= "  "
Default cFilFin		:= "zz"
Default cPedidos	:= "3" // Todos os pedidos
Default aCCustos	:= {}
Default aSelFil		:= {}
Default lAnalitic	:= .F.

// Verifica o tipo de filtro de filial.
//If empty(aSelFil)
//	bSelFil := {|cFilInc| aScan(aSelFil, cFilInc) > 0}
//Else
	If mv_par03 == 2		// por empresa
		cFilDe	:= cFilIni
		cFilAte	:= cFilFin
	Else					// por filial
		cFilDe	:= cFilAnt
		cFilAte	:= cFilAnt
	Endif
//	bSelFil := {|cFilInc| AllTrim(cFilInc) >= Alltrim(cFilDe) .And. AllTrim(cFilInc) <= Alltrim(cFilAte)}
//Endif

If lFinc024
	For nX := 1 To Len(aCCustos)
		cCustos += "'" + aCCustos[nX] + "',"
	Next nX
	cCustos := Substr(cCustos, 1, Len(cCustos) - 1)
EndIf

For nInc := 1 To Len( aSM0 )
	If aSM0[nInc][1] == cEmpAnt //.And. Eval(bSelFil, aSM0[nInc][2])
		cFilAnt := aSM0[nInc][2]
		//--------------------------
		// Ler Pedidos de Compra
		//--------------------------
		dbSelectArea("SC7")
		SC7->(dbSetOrder(1))
		dbSeek(xFilial())

		If lF021DtFl
			cQuery := "SELECT * "
		Else
			cQuery := "SELECT C7_FILIAL,C7_NUM,C7_COND,C7_TOTAL,C7_VLDESC,C7_RESIDUO,C7_QUANT,C7_QUJE,C7_CONAPRO,C7_FLUXO,C7_PRODUTO,"
			cQuery += "C7_TES,C7_DATPRF,C7_MOEDA,C7_PRECO,C7_TXMOEDA,C7_REAJUST,C7_VALFRE,C7_SEGURO,C7_DESPESA,C7_DESC1,"
			cQuery += "C7_DESC2,C7_DESC3,C7_VLDESC,C7_ITEM,C7_FORNECE,C7_LOJA,C7_EMISSAO,C7_TIPO,C7_SEQUEN,C7_IPI,C7_IPIBRUT "
		EndIf

		cQuery += " FROM " + RetSqlName("SC7")
		cQuery += " WHERE C7_FILIAL = '" + xFilial("SC7") + "'"
		cQuery += " AND D_E_L_E_T_ = ' ' "
		cQuery += " AND C7_QUJE < C7_QUANT"
		cQuery += " AND C7_RESIDUO <> 'S'"
		cQuery += " AND C7_FLUXO   <> 'N'"

		If lFinc024
			cQuery += "AND C7_RATEIO = '2'" //Rateio SCH � filtrado na outra query.
			If !Empty(cCustos)
				cQuery += "AND C7_CC IN (" + cCustos + ")"
			EndIf
		EndIf

		If lFC020CQR
			cQuery += ExecBlock("FC020CQR",.F.,.F.)
		EndIf

		If lFinc024
			cQuery +=	"UNION ALL"

			If lF021DtFl
				cQuery := "SELECT * "
			Else
				cQuery := "SELECT C7_FILIAL,C7_NUM,C7_COND,C7_TOTAL,C7_VLDESC,C7_RESIDUO,C7_QUANT,C7_QUJE,C7_CONAPRO,C7_FLUXO,C7_PRODUTO,"
				cQuery += "C7_TES,C7_DATPRF,C7_MOEDA,C7_PRECO,C7_TXMOEDA,C7_REAJUST,C7_VALFRE,C7_SEGURO,C7_DESPESA,C7_DESC1,"
				cQuery += "C7_DESC2,C7_DESC3,C7_VLDESC,C7_ITEM,C7_FORNECE,C7_LOJA,C7_EMISSAO,C7_TIPO,C7_SEQUEN,C7_IPI,C7_IPIBRUT "
			EndIf

			cQuery += " FROM "+	RetSQLTab("SC7")
			cQuery += " JOIN "+	RetSQLTab("SCH") + " ON SCH.CH_PEDIDO = SC7.C7_NUM AND SCH.CH_ITEMPD = SC7.C7_ITEM "
			If (!Empty(cCustos), cQuery += "AND SCH.CH_CC IN (" + cCustos + ")", Nil)
			cQuery += " WHERE C7_FILIAL = '" + xFilial("SC7") + "'"
			cQuery += " AND C7_QUJE < C7_QUANT"
			cQuery += " AND C7_RESIDUO <> 'S'"
			cQuery += " AND C7_FLUXO   <> 'N' AND "
			cQuery += 	RetSqlCond("SC7,SCH")
		Else
			cQuery += " ORDER BY "+ SqlOrder(IndexKey())
		EndIf
		cQuery := ChangeQuery(cQuery)
		dbSelectArea("SC7")
		dbCloseArea()
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SC7', .F., .T.)

		For nI := 1 to Len(aStru)
			If aStru[nI,2] != 'C'
				TCSetField('SC7', aStru[nI,1], aStru[nI,2],aStru[nI,3],aStru[nI,4])
			Endif
		Next nI

		While SC7->(!Eof())

			cFilPed		:= SC7->C7_FILIAL
			cNumPed		:= SC7->C7_NUM
			nValTot		:= 0
			nValIpi		:= 0
			aVenc		:= {}
			cCond		:= SC7->C7_COND
			nTotDesc	:= SC7->C7_VLDESC
			nDespFrete	:= 0

			While SC7->(!Eof()) .And. SC7->C7_NUM==cNumPed .and. xFilial("SC7") == SC7->C7_FILIAL
				If lRegua != Nil .and. lRegua
					IncProc('Processando Pedidos de compras') // Processando Pedidos de compras
				Endif
				IF SC7->C7_QUJE >= SC7->C7_QUANT .or. SC7->C7_RESIDUO == "S" .or. SC7->C7_FLUXO == "N"
					SC7->(dbSkip())
					Loop
				Endif
				If (SC7->C7_CONAPRO == "B" .And. Left(cPedidos,1) == "1") .Or.;
				   (SC7->C7_CONAPRO != "B" .And. Left(cPedidos,1) == "2")
					SC7->(dbSkip())
					Loop
				Endif

				SB1->(dbSeek( xFilial("SB1") + SC7->C7_PRODUTO)) // Posiciona Produto
				If !Empty(SC7->C7_TES)
					lTES := SF4->(dbSeek( xFilial("SF4") + SC7->C7_TES ))  // Posiciona TES
				Else
					lTES := SF4->(dbSeek( xFilial("SF4") + RetFldProd(SB1->B1_COD,"B1_TE") ))  // Posiciona TES
				Endif

				// Se nao houver TES no Pedido ou Produto serah considerado
				// pois o tes no PC nao eh obrigatorio ou comum.
				IF lTES .and. SF4->F4_DUPLIC == "N"
					dbSelectArea("SC7")
					dbSkip()
					Loop
				Endif

				dbSelectArea("FIE")  // Tabela Pedidos x Adiantamentos
				FIE->(dbSetOrder(1))
				FIE->(dbGoTop())
				FIE->(MsSeek(xFilial("FIE")+"P"+cNumPed))
				While FIE->(!EOF()) .And. FIE->FIE_PEDIDO == cNumPed .And. !lPACalc
					DbSelectArea("SE2")
					Dbsetorder(1)
					If Dbseek(xFilial("SE2")+FIE->FIE_PREFIX+FIE->FIE_NUM+FIE->FIE_PARCEL+FIE->FIE_TIPO+FIE->FIE_FORNEC+FIE->FIE_LOJA)
						IF SE2->E2_MOEDA <> nMoeda
							If SE2->E2_TIPO $ MVPAGANT
								nValPagAnt += SE2->E2_VLCRUZ
							Endif
						Else
					If FIE->FIE_TIPO $ MVPAGANT
						nValPagAnt += FIE->FIE_VALOR  	// Valor do Adiantamento
							EndIf
						Endif
					EndIf
					FIE->(dbSkip())
				EndDo

				//para que o calc da PA n�o seja executado com base na qtd de itens do pedido
				lPACalc := (FunName() == "FINC021" .or. FunName() == "FINA701")

				If lPACalc .And. nValPagAnt > 0 .And. TcSrvType() != "AS/400" .And. nTotRegSC7 == 0 .And. lSE2Excl
					aReaAt := GetArea()

					If __oMovPA == Nil
						cQuery := "SELECT COUNT(DISTINCT SC7.C7_DATPRF) TOTREGSC7 "
						cQuery += "FROM " + RetSqlName("SC7") + " SC7 "
						cQuery += "JOIN " + RetSqlName("FIE") + " FIE "
						cQuery += "ON (SC7.C7_NUM = FIE.FIE_PEDIDO AND SC7.C7_FILIAL = FIE.FIE_FILIAL) "
						cQuery += "JOIN " + RetSqlName("SE2") + " SE2 "
						cQuery += "ON (FIE.FIE_PREFIX = SE2.E2_PREFIXO AND FIE.FIE_NUM = SE2.E2_NUM AND "
						cQuery += "FIE.FIE_PARCEL = SE2.E2_PARCELA AND FIE.FIE_LOJA = SE2.E2_LOJA AND "
						cQuery += "FIE.FIE_FILIAL = SE2.E2_FILIAL AND "
						cQuery += "FIE.FIE_TIPO = SE2.E2_TIPO AND FIE.FIE_FORNEC = SE2.E2_FORNECE ) "
						cQuery += "JOIN " + RetSqlName("SE4") + " SE4 "
						cQuery += "ON (SC7.C7_COND = SE4.E4_CODIGO) "
						cQuery += "WHERE SC7.C7_NUM = ? AND "
						cQuery += "SC7.C7_FILIAL = ? AND "
						cQuery += "FIE.FIE_CART = 'P' AND FIE.FIE_TIPO IN('PA') AND "
						cQuery += "SC7.D_E_L_E_T_ = ' ' AND "
						cQuery += "SE2.D_E_L_E_T_ = ' ' AND "
						cQuery += "FIE.D_E_L_E_T_ = ' ' AND "
						cQuery += "SE4.D_E_L_E_T_ = ' ' "

						cQuery := ChangeQuery(cQuery)
						__oMovPA := FWPreparedStatement():New(cQuery)
					EndIf

					__oMovPA:SetString(1, cNumPed)
					__oMovPA:SetString(2, xFilial("SC7"))

					cQry := __oMovPA:GetFixQuery()
					cTblTmp := MpSysOpenQuery(cQry)

					If (cTblTmp)->(!Eof())
						nTotRegSC7 := (cTblTmp)->TOTREGSC7
					EndIf
					(cTblTmp)->(DbCloseArea())

					If nTotRegSC7 > 1
						nValPagAnt := (nValPagAnt/nTotRegSC7)
					ElseIf nTotRegSC7 == 0
						SC7->(dbSkip())
						Loop
					EndIf

					RestArea(aReaAt)
				EndIf

				dbSelectArea("SC7")

				//------------------------------------------
				// Calcula o reajuste do pedido de compra
				//------------------------------------------
				dData := SC7->C7_DATPRF
				nPos := Ascan(aData, { |x| x[1] == SC7->C7_DATPRF } )
				If nPos == 0
					dData := DataValida(SC7->C7_DATPRF)
					aadd(aData, {SC7->C7_DATPRF, dData})
				Else
					dData := aData[nPos, 2]
				EndIf

				If lF021DtFl
					dData := Execblock("FC021DTF",.F.,.F.,{"SC7","SC7"})
				ElseIf lConsDtBase
					dData := Iif(SC7->C7_DATPRF < dDataBase, dDataBase, dData)
				Endif

				If SC7->C7_MOEDA != nMoeda .or. SC7->C7_MOEDA > 1
					nTaxaMoed:= If(Empty(SC7->C7_TXMOEDA), RecMoeda(dData,SC7->C7_MOEDA), SC7->C7_TXMOEDA)
				EndIf

				nPrcCompra := SC7->C7_PRECO
				If SC7->C7_MOEDA != nMoeda
					nPrcCompra := xMoeda(SC7->C7_PRECO,SC7->C7_MOEDA,nMoeda,dData,nDecimais, nTaxaMoed)
				EndIf

				If !Empty(SC7->C7_REAJUST)
					nPrcCompra := fc020Form(SC7->C7_REAJUST, dData)
				Endif

				nDespFrete := SC7->C7_VALFRE + SC7->C7_SEGURO + SC7->C7_DESPESA
				If SC7->C7_MOEDA != nMoeda
					nDespFrete := xMoeda(SC7->C7_VALFRE + SC7->C7_SEGURO + SC7->C7_DESPESA,SC7->C7_MOEDA,nMoeda,dData,nDecimais, nTaxaMoed)
				EndIf
				nValTot	  := ((SC7->C7_QUANT-SC7->C7_QUJE) * nPrcCompra ) + nDespFrete
				nValIPI	  := 0
				nValIPILiq  := nValTot

				If nTotDesc == 0
					nTotDesc := CalcDesc(nValTot,SC7->C7_DESC1,SC7->C7_DESC2,SC7->C7_DESC3)
				Else
					//-----------------------------------------------------------
					// Proporcionaliza o desconto de pedidos com entrega parcial
					//-----------------------------------------------------------
					nTotDesc := ((SC7->C7_VLDESC * nValTot)/SC7->C7_TOTAL)
				EndIf
				nValTot	  := nValTot - nTotDesc
				IF SC7->C7_IPI > 0
					If SC7->C7_IPIBRUT != "L"
						nBaseIPI := nValTot
					Else
						nBaseIPI := nValIPILiq
					Endif
					IF SF4->F4_BASEIPI > 0
						nBaseIPI *= SF4->F4_BASEIPI / 100
					Endif
					nValIPI := IIf(nBaseIPI = 0, 0, nBaseIPI * SC7->C7_IPI / 100)
				Endif
				nValTot  += nValIPI
				dbSelectArea("SE4")
				dbSeek(xFilial("SE4")+SC7->C7_COND)
				nValTot  *= (SE4->E4_ACRSFIN/100)+1
				dbSelectArea("SC7")
				If lFc020Com		// Retornar a condicao do Item e do Total
					aVenc := ExecBlock("FC020COM",.F.,.F.,{SC7->C7_NUM,SC7->C7_ITEM,nValTot,cCond,nValIpi,dData})
				Else
					aVenc := Condicao(nValTot,cCond,nValIpi,dData)
				Endif

				IF Len(aVenc) > 0
					// Posiciona no fornecedor para buscar a natureza
					DbSelectArea("SA2")
					DbSetOrder(1)
					MsSeek(xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA)
					cNatureza := PAd(If(Empty(SA2->A2_NATUREZ), "PC", SA2->A2_NATUREZ ), Len(SED->ED_CODIGO))

					nParcAd := Len(aVenc)
					nDescont := nValPagAnt / nParcAd

					For i:=1 To Len(aVenc)

						nPosData := Ascan(aDataAux, {|e| e[1] == aVenc[i][1]})
						If nPosData == 0
							dDataFluxo := DataValida(aVenc[i][1])
							AADD(aDataAux, {aVenc[i][1], dDataFluxo})
						Else
							dDataFluxo := aDataAux[nPosData][2]
						Endif

						// Verifico se a data j� foi validada
						If lAnalitic
							nL := Ascan(aCompras, {|e| e[1] == dDataFluxo .And. e[3] == cNatureza .And. e[5] == cNumPed .And. e[6] == cFilPed})
						Else
							nL := Ascan(aCompras, {|e| e[1] == dDataFluxo .And. e[3] == cNatureza } )
						Endif

						IF nL != 0
							aCompras[nL][2] += aVenc[i][2]
							aCompras[nL][4] += nValPagAnt
						Else
							AADD(aCompras, {dDataFluxo, aVenc[i][2], cNatureza, nDescont, cNumPed, cFilPed})
							AADD(adCompras, dDataFluxo)
						Endif

						// Se foi enviado o arquivo temporario para geracao do fluxo
						// de caixa analitico, gera o pedido de compra neste arquivo
						If cAliasPc != Nil
							DbSelectArea(cAliasPc)
							nAscan := Ascan(aPeriodo, {|e| e[1] == dDataFluxo})
							// Se a data do pedido ja venceu, insere na primeira data do fluxo
							If dDataFluxo < aPeriodo[1][1]
								dDataFluxo := aPeriodo[1][1]
								nAscan := 1
							Endif
							If nAscan > 0
								If !dbSeek(dTos(dDataFluxo)+SC7->C7_NUM)
									RecLock(cAliasPc,.T.)
									(cAliasPc)->FILIAL := SC7->C7_FILIAL 
									(cAliasPc)->DATAX  := dDataFluxo
									(cAliasPc)->Periodo:= aPeriodo[nAscan][2]
									(cAliasPc)->NUMERO := SC7->C7_NUM
									(cAliasPc)->EMISSAO:= SC7->C7_EMISSAO
									(cAliasPc)->CLIFOR := SC7->C7_FORNECE
									(cAliasPc)->TIPO   := SC7->C7_TIPO
									(cAliasPc)->ITEM   := SC7->C7_ITEM

									// Posiciona no fornecedor para buscar o nome
									DbSelectArea("SA2")
									DbSetOrder(1)
									MsSeek(xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA)
									DbSelectArea(cAliasPc)
									(cAliasPc)->NOMCLIFOR:= SA2->A2_NOME
									(cAliasPc)->PRODUTO:= SC7->C7_PRODUTO
									(cAliasPc)->DESCPRO:= SB1->B1_DESC
									(cAliasPc)->CHAVE  := xFilial("SC7")+SC7->C7_NUM+SC7->C7_ITEM+SC7->C7_SEQUEN
								Else
									RecLock(cAliasPc,.F.)
								Endif
								(cAliasPc)->SALDO  += aVenc[i][2]
								(cAliasPc)->VALPAGANT := nDescont

								// Pesquisa na matriz de totais, os totais de pedidos de compra
								// da data de trabalho.
								If aTotais # Nil
									nAscan := Ascan( aTotais[3], {|e| e[1] == (cAliasPc)->DATAX})
									If nAscan == 0
										Aadd( aTotais[3], {(cAliasPc)->DATAX,aVenc[i][2]})
									Else
										aTotais[3][nAscan][2] += aVenc[1][2] //(cAliasPc)->SALDO // Totaliza os pedidos de compra
									Endif
								Endif
							Endif
						Endif
					Next i
				Endif
				dbSelectArea("SC7")
				dbSkip()
			Enddo
			nValPagAnt := 0
			lPACalc := .F.
			nTotRegSC7 := 0
			nDescont := 0
			nParcAd := 0
		EndDo

		dbSelectArea("SC7")
		dbCloseArea()
		ChKFile("SC7")
		dbSelectArea("SC7")
		dbSetOrder(1)

		If Empty(xFilial("SC7"))
			Exit
		Endif
	EndIf
Next

If __oMovPA <> Nil
	__oMovPA:Destroy()
EndIf
cFilAnt := cSaveFil // recupera variavel cFilAnt

Return .T.


//-----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FC020VENDA

Monta array com Pedidos de Venda (Fluxos de caixa).
Arquivo original: FINXFUN.PRX

@Author	Wagner Xavier
@since	06/07/1992
/*/
//-----------------------------------------------------------------------------------------------------
Static Function fc020Venda(cMoedas, cAliasPv, aTotais, lRegua, nMoeda, aPeriodo, cFilIni, cFilFin, aCCustos, cRiscoDe, cRiscoAte, aSelFil, lAnalitic,lTxMoePed)

Local cNumPed
Local cCond
Local nValTot		:= 0
Local nValIpi		:= 0
Local aVenc			:= {}
Local i
Local nPrcVen
Local dData
Local lFc020Vda		:= ExistBlock("FC020VDA")
Local lFc020Vdb		:= ExistBlock("FC020VDB")
Local lFC020VQR		:= ExistBlock("FC020VQR")
Local cFilDe
Local cFilAte
Local cFilPed
Local cSaveFil		:= cFilAnt
Local nAscan
Local dDataFluxo	:= {}
Local aDataAux		:= {}
Local nPosData 		:= 0
Local aDesp			:= {}
Local lPedido		:= .T.
Local lFirst		:= .T.
Local nDespFrete	:= 0
Local lMoedaFre		:= (SuperGetMv("MV_FRETMOE") == "S")
Local nDecimais		:= TamSx3("C6_PRCVEN")[2]
Local cAliasSc6		:= "SC6"
Local nInc			:= 0
Local aSM0			:= AdmAbreSM0()
Local lF021DtFl		:= Existblock("FC021DTF")
Local cCustos		:= ''
Local lFinc024		:= FwIsInCallStack("FINC024")
Local nX			:= 0
Local nI			:= 0
Local aStru			:= SC6->(dbStruct())
Local cQuery
Local nValRecAnt	:= 0
Local nTaxaMoeda    := 0

Default nMoeda		:= 1
Default cFilIni		:= Space( FWGETTAMFILIAL)
Default cFilFin		:= Replicate( "Z", FWGETTAMFILIAL)
Default aCCustos	:= {}
Default cRiscoDe	:= ''
Default cRiscoAte	:= ''
Default lAnalitic   := .F.
Default cMoedas		:= "012345"
Default lTxMoePed   := .F.

// Verifica o tipo de filtro de filial.
//If empty(aSelFil)
//	bSelFil := {|cFilInc| aScan(aSelFil, cFilInc) > 0}
//Else
	If mv_par03 == 2		// por empresa
		cFilDe	:= cFilIni
		cFilAte := cFilFin
	Else					// por filial
		cFilDe	:= cFilAnt
		cFilAte := cFilAnt
	Endif
//	bSelFil := {|cFilInc| AllTrim(cFilInc) >= Alltrim(cFilDe) .And. AllTrim(cFilInc) <= Alltrim(cFilAte)}
//Endif

If lFinc024
	For nX := 1 To Len(aCCustos)
		cCustos += "'" + aCCustos[nX] + "',"
	Next nX
	cCustos := Substr(cCustos, 1, Len(cCustos) - 1)
EndIf

For nInc := 1 To Len( aSM0 )
	If aSM0[nInc][1] == cEmpAnt //.And. Eval(bSelFil, aSM0[nInc][2])
		cFilAnt := aSM0[nInc][2]

		//--------------------------
		// Ler Pedidos de Venda
		//--------------------------
		dbSelectArea("SC6")
		dbSetOrder(1)
		dbSeek(xFilial())

		cAliasSc6 := GetNextAlias()

		If lFinc024
			If lF021DtFl
				cQuery := "SELECT * "
			Else
				cQuery := "SELECT C6_FILIAL, C6_NUM, C6_ITEM, C6_BLQ,C6_QTDENT,C6_QTDVEN, C6_TES, C6_ENTREG, C6_PRODUTO,C6_PRCVEN "
			EndIf

			cQuery += "  FROM "+	RetSqlName("SC5") + " SC5
			//Filtra o cliente pelo risco.
			cQuery += " JOIN "+ RetSqlName("SA1")  + " ON A1_COD = C5_CLIENT AND A1_LOJA = C5_LOJACLI AND "
			cQuery += " A1_RISCO >='" + cRiscoDe  + "' AND "
			cQuery += " A1_RISCO <='" + cRiscoAte +"',"

			cQuery +=           	RetSqlName("SC6") + " SC6 "
			cQuery += " WHERE SC6.C6_FILIAL = '" + xFilial("SC6") + "'"
			cQuery += " AND SC6.C6_BLQ <> 'R'"
			cQuery += " AND SC6.C6_BLQ <> 'S'"
			cQuery += " AND SC6.C6_QTDENT < SC6.C6_QTDVEN"
			cQuery += " AND SC5.C5_FILIAL = '" + xFilial("SC5") + "'"
			cQuery += " AND SC6.C6_NUM = SC5.C5_NUM "
			cQuery += " AND SC6.C6_RATEIO = '2' AND " // N�o filtra itens que tiveram rateio.
			If (!Empty(cCustos), cQuery += " SC6.C6_CCUSTO IN (" + cCustos + ") AND ", Nil)
			cQuery += 	RetSqlCond("SC6,SC5")

			//Faz relacionamento com a tabela AGG para filtrar o centro de custo.
			cQuery += " UNION ALL "

			cQuery += "SELECT C6_FILIAL, C6_NUM, C6_ITEM, C6_BLQ,C6_QTDENT,C6_QTDVEN, C6_TES, C6_ENTREG, C6_PRODUTO, "
			cQuery += "(C6_PRCVEN * AGG_PERC)/100"
			cQuery += "  FROM "+	RetSqlName("SC5") + " SC5
							//Filtra o cliente pelo risco.
			cQuery += " JOIN "+ RetSqlName("SA1")  + " ON A1_COD = C5_CLIENT AND A1_LOJA = C5_LOJACLI AND "
			cQuery += " A1_RISCO >='" + cRiscoDe  + "' AND "
			cQuery += " A1_RISCO <='" + cRiscoAte +"',"

			cQuery +=          	RetSqlName("SC6") + " SC6  "
			cQuery += "  JOIN "+	RetSqlName("AGG") + " AGG ON AGG_PEDIDO = C6_NUM AND AGG_ITEMPD = C6_ITEM "
			If (!Empty(cCustos), cQuery += " AND AGG_CC IN (" + cCustos + ") ", Nil)
			cQuery += " WHERE SC6.C6_FILIAL = '" + xFilial("SC6") + "'"
			cQuery += " AND SC6.C6_BLQ <> 'R'"
			cQuery += " AND SC6.C6_BLQ <> 'S'"
			cQuery += " AND SC6.C6_QTDENT < SC6.C6_QTDVEN"
			cQuery += " AND SC5.C5_FILIAL = '" + xFilial("SC5") + "'"
			cQuery += " AND SC6.C6_NUM = SC5.C5_NUM AND "
			cQuery += 	RetSqlCond("SC6,SC5,AGG")

		Else
			If lF021DtFl
				cQuery := "SELECT * "
			Else
				cQuery := "SELECT DISTINCT C6_FILIAL, C6_NUM, C6_ITEM, C6_BLQ,C6_QTDENT,C6_QTDVEN, C6_TES, C6_PRCVEN, C6_ENTREG, C6_PRODUTO "
			EndIf

			cQuery += "  FROM " +	RetSqlName("SC6") + " SC6, "
			cQuery +=           	RetSqlName("SC5") + " SC5 "
			cQuery += " WHERE SC6.C6_FILIAL = '" + xFilial("SC6") + "'"
			cQuery += " AND SC6.C6_BLQ <> 'R'"
			cQuery += " AND SC6.C6_BLQ <> 'S'"
			cQuery += " AND SC6.C6_QTDENT < SC6.C6_QTDVEN"
			cQuery += " AND SC5.C5_FILIAL = '" + xFilial("SC5") + "'"
			cQuery += " AND SC6.C6_NUM = SC5.C5_NUM "
			cQuery += " AND SC5.D_E_L_E_T_ = ' ' "
			cQuery += " AND SC6.D_E_L_E_T_ = ' ' "
		EndIf

		If lFC020VQR
			cQuery += ExecBlock("FC020VQR",.F.,.F.)
		EndIf

		cQuery += " ORDER BY C6_FILIAL, C6_NUM, C6_ITEM "
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasSc6, .F., .T.)

		For nI := 1 to Len(aStru)
			If aStru[nI,2] != 'C'  .And. FieldPos(aStru[nI,1]) > 0
				TCSetField(cAliasSc6, aStru[nI,1], aStru[nI,2],aStru[nI,3],aStru[nI,4])
			Endif
		Next nI

		While (cAliasSc6)->(!Eof()) .AND. (cAliasSc6)->C6_FILIAL == xFilial("SC6")

			cFilPed := (cAliasSc6)->C6_FILIAL
			cNumPed := (cAliasSc6)->C6_NUM
			nValTot := 0
			nValIpi := 0
			aVenc := {}
			aDesp := {}
			lPedido := .T.
			lFirst:= .T.
			While (cAliasSc6)->(!Eof()) .and. (cAliasSc6)->C6_NUM == cNumPed .and. xFilial("SC6") == (cAliasSc6)->C6_FILIAL
				If lRegua != Nil .And. lRegua
					IncProc('Processando Pedidos de vendas')  // "Processando Pedidos de vendas"
				Endif
				If lFc020Vdb
					SF4->(dbSetOrder(1))
					If SF4->(!dbSeek(xFilial() + (cAliasSc6)->C6_TES, .F.) .Or. F4_DUPLIC == "N")
						(cAliasSc6)->(dbSkip())
						Loop
					Endif
				Endif
				dbSelectArea("SC5")
				SC5->(MsSeek( xFilial("SC5")+cNumPed ))
				If (STR(SC5->C5_MOEDA,1) $ cMoedas)           
					cCond := SC5->C5_CONDPAG
					dbSelectArea("FIE")  // Tabela Pedidos x Adiantamentos
					FIE->(dbSetOrder(1))
					FIE->(dbGoTop())
					FIE->(MsSeek(xFilial("FIE")+"R"+cNumPed))
					While FIE->(!EOF()) .And. FIE->FIE_PEDIDO == cNumPed
						If FIE->FIE_TIPO $ MVRECANT
							nValRecAnt += FIE->FIE_VALOR  	// Valor do Adiantamento
						EndIf
						FIE->(dbSkip())
					EndDo
					If lFc020Vdb
						dbSelectArea(cAliasSc6)

						//----------------------------------------
						// Calcula o reajuste do pedido de venda
						//----------------------------------------
						nPrcVen := (cAliasSc6)->C6_PRCVEN
						If lF021DtFl
							dData := Execblock("FC021DTF",.F.,.F.,{"SC6",cAliasSc6})
						Else
							dData := Iif( (cAliasSc6)->C6_ENTREG < dDataBase, dDataBase, (DataValida((cAliasSc6)->C6_ENTREG)))
						Endif

						IF !Empty(SC5->C5_REAJUST)
							nPrcVen := fc020Form(SC5->C5_REAJUST,dData)
						Endif
						nPrcVen := xMoeda(nPrcVen,SC5->C5_MOEDA,nMoeda,dData,nDecimais)

						nValTot	:= ((cAliasSc6)->(C6_QTDVEN-C6_QTDENT)) * nPrcVen
						cProd 	:= (cAliasSc6)->C6_PRODUTO
						dbSelectArea("SB1")
						dbSeek(xFilial("SB1")+cProd)
						dbSelectArea(cAliasSc6)
						nValIPI	:= 0
						IF SF4->F4_IPI == "S" .And. SB1->B1_IPI > 0
							nBaseIPI :=((cAliasSc6)->(C6_QTDVEN-C6_QTDENT))*nPrcVen
							If SF4->F4_BASEIPI > 0
								nBaseIPI*=(SF4->F4_BASEIPI/100)
							Endif
							nValIpi  :=IIf(nBaseIPI=0,0,(nBaseIPI*SB1->B1_IPI)/100)
						Endif
						nValTot += nValIPI
						nValTot *= (SC5->C5_ACRSFIN/100)+1
						dbSelectArea(cAliasSc6)

						If lFc020Vda // Retornar a condicao do Item e do Total
							aVenc := ExecBlock("FC020VDA",.F.,.F.,{(cAliasSc6)->C6_NUM,(cAliasSc6)->C6_ITEM,nValTot,cCond,nValIpi,dData})
						Else
						  	aVenc := ExecBlock("FC020VDB",.F.,.F.,{(cAliasSc6)->C6_NUM,(cAliasSc6)->C6_ITEM,nValTot,cCond,nValIpi,dData})
						Endif
						If Len(aVenc) > 0
							If lPedido
								//Despesas, Seguro e Frete
								nDespFrete := xMoeda(SC5->C5_FRETE+SC5->C5_SEGURO+SC5->C5_DESPESA,If(lMoedaFre,SC5->C5_MOEDA,1),mv_par04,dData,nDecimais)
								aDesp := Condicao(nDespFrete,cCond,,dData)
								lPedido := .F.
								If Len(aDesp) > 0
									DbSelectArea("SA1")
									DbSetOrder(1)
									MsSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI)
									cNatureza := Pad(If(Empty(SA1->A1_NATUREZ), "PV", SA1->A1_NATUREZ ), Len(SED->ED_CODIGO))
									For i := 1 To Len(aDesp)
										dDataFluxo := DataValida(aDesp[i][1])
										If lAnalitic
											nL := Ascan(aVendas, {|e| e[1] == dDataFluxo .And. e[3] == cNatureza .And. e[5] == cNumPed .And. e[6] == cFilPed})
										Else
											nL := Ascan(aVendas, {|e| e[1] == dDataFluxo .And. e[3] == cNatureza})
										Endif
										IF nL != 0
											aVendas[nL][2]+=aDesp[i][2]
											aVendas[nL][4]+=nValRecAnt
										Else
											AADD(aVendas, {dDataFluxo, aDesp[i][2], cNatureza, nValRecAnt, cNumPed, cFilPed})
											AADD(aDVendas, dDataFluxo)
										Endif
									Next i
								Endif
							Endif
						Endif
					Else
						aVenc := Ma410Fluxo(cNumPed,.F.)						
						For i := 1 To Len(aVenc)
							If SC5->C5_MOEDA != nMoeda .or. SC5->C5_MOEDA > 1
								If lTxMoePed
									nTaxaMoeda := SC5->C5_TXMOEDA
								Else
									nTaxaMoeda := RecMoeda(aVenc[i][1],SC5->C5_MOEDA)
								EndIf
							EndIf
							
							If SC5->C5_MOEDA != nMoeda
								aVenc[i][2] := xMoeda(aVenc[i][2], SC5->C5_MOEDA, nMoeda, aVenc[i][1], nDecimais,nTaxaMoeda)
							Endif
						Next
					Endif

					// Parcelas do Pedido
					DbSelectArea("SA1")
					DbSetOrder(1)
					MsSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI)
					cNatureza := Pad(If(Empty(SA1->A1_NATUREZ), "PV", SA1->A1_NATUREZ ), Len(SED->ED_CODIGO))

					For i := 1 To Len(aVenc)

						nPosData := Ascan(aDataAux, {|e| e[1] == aVenc[i][1]})
						If nPosData == 0
							dDataFluxo := DataValida(aVenc[i][1])
							AADD(aDataAux, {aVenc[i][1], dDataFluxo})
						Else
							dDataFluxo := aDataAux[nPosData][2]
						Endif

						If lAnalitic
							nL := Ascan(aVendas, {|e| e[1] == dDataFluxo .And. e[3] == cNatureza .And. e[5] == cNumPed .And. e[6] == cFilPed})
						Else
							nL := Ascan(aVendas, {|e| e[1] == dDataFluxo .And. e[3] == cNatureza})
						Endif
						IF nL != 0
							aVendas[nL][2]+=aVenc[i][2]
							aVendas[nL][4]+=nValRecAnt
						Else
							AADD(aVendas, {dDataFluxo, aVenc[i][2], cNatureza, nValRecAnt, cNumPed, cFilPed})
							AADD(aDVendas, dDataFluxo)
						Endif

						// Se foi enviado o arquivo temporario para geracao do fluxo
						// de caixa analitico, gera o pedido de venda neste arquivo
						If cAliasPv != Nil
							DbSelectArea(cAliasPv)
							nAscan := Ascan(aPeriodo, {|e| e[1] == dDataFluxo})
							// Se a data do pedido ja venceu, insere na primeira data do fluxo
							If dDataFluxo < aPeriodo[1][1]
								dDataFluxo := aPeriodo[1][1]
								nAscan := 1
							Endif
							If nAscan > 0
								If !dbSeek(dTos(dDataFluxo)+SC5->C5_NUM)
									RecLock(cAliasPv,.T.)
									(cAliasPv)->FILIAL := SC5->C5_FILIAL 
									(cAliasPv)->DATAX  := dDataFluxo
									(cAliasPv)->Periodo:= aPeriodo[nAscan][2]
									(cAliasPv)->NUMERO := SC5->C5_NUM
									(cAliasPv)->EMISSAO:= SC5->C5_EMISSAO
									(cAliasPv)->CLIFOR := SC5->C5_CLIENTE
									(cAliasPv)->LOJAENT:= SC5->C5_LOJAENT
									(cAliasPv)->LOJACLI:= SC5->C5_LOJACLI
									(cAliasPv)->TIPO   := SC5->C5_TIPO
									// Posiciona no cliente para buscar o nome
									If SC5->C5_TIPO=="D"
										DbSelectArea("SA2")
										DbSetOrder(1)
										MsSeek(xFilial("SA2")+SC5->C5_CLIENTE+SC5->C5_LOJACLI)
										DbSelectArea(cAliasPv)
										(cAliasPv)->NOMCLIFOR:= SA2->A2_NOME
										(cAliasPv)->CHAVE  := xFilial("SC5")+SC5->C5_NUM
									Else
										DbSelectArea("SA1")
										DbSetOrder(1)
										MsSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI)
										DbSelectArea(cAliasPv)
										(cAliasPv)->NOMCLIFOR:= SA1->A1_NOME
										(cAliasPv)->CHAVE  := xFilial("SC5")+SC5->C5_NUM
									Endif
								Else
									RecLock(cAliasPv,.F.)
								Endif

								//Somo a despesa/Frete/Seguro relativa a parcela apenas uma vez
								//Se refere ao valor da parcela e nao do item
								IF Len(aDesp) > 0 .and. lFirst
									nValDfs := aDesp[i][2]
									lFirst := .F.
								Else
									nValDfs := 0
								Endif
	         					(cAliasPv)->SALDO  += aVenc[i][2]+ nValDfs
								dbSelectArea("FIE")  // Tabela Pedidos x Adiantamentos
								dbSetOrder(1)
	         					If dbSeek(xFilial("FIE")+"R"+cNumPed)
									If FIE->FIE_TIPO $ MVRECANT
									/* - Moeda do RA for diferente da moeda solicitada na consulta
									   - Posiciono na RA no SE1 para verifica a moeda do RA							    */
										dbSelectArea("SE1")
										dbSetOrder(1)
										If dbSeek(xFilial("SE1")+FIE->FIE_PREFIX+FIE->FIE_NUM+FIE->FIE_PARCEL+FIE->FIE_TIPO)
											If SE1->E1_MOEDA != nMoeda
												nValRecAnt := xMoeda(nValRecAnt, SE1->E1_MOEDA, nMoeda, dDataFluxo)
											EndIf
										Endif
									EndIf
	         					EndIf
	         					(cAliasPv)->VALRECANT := nValRecAnt

								// Pesquisa na matriz de totais, os totais de pedidos de compra
								// da data de trabalho.
								nAscan := Ascan( aTotais[4], {|e| e[1] == (cAliasPv)->DATAX})
								If nAscan == 0
									Aadd( aTotais[4], {(cAliasPv)->DATAX,aVenc[i][2]+ nValDfs})
								Else
									aTotais[4][nAscan][2] += aVenc[i][2]+ nValDfs // Totaliza os pedidos de venda
								Endif
							Endif
						Endif
					Next i
				Endif
				dbSelectArea(cAliasSc6)

				// Vai para o proximo pedido, pois a Ma410Fluxo ja processou todos
				// o itens, e se nao for para proximo pedido, os dados ficarao duplicados
				While (cAliasSc6)->(!Eof()) .And. (cAliasSc6)->C6_NUM == cNumPed .And. xFilial("SC6") == (cAliasSc6)->C6_FILIAL
					dbSkip()
				EndDo

			EndDo
			nValRecAnt := 0
		EndDo

		dbSelectArea(cAliasSc6)
		dbCloseArea()
		dbSelectArea("SC6")
		dbSetOrder(1)

		If Empty(xFilial("SC6"))
			Exit
		Endif
	EndIf
Next nInc

cFilAnt := cSaveFil // recupera variavel cFilAnt

Return .T.

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    � Fc021Ctrc  � Autor � Claudio D. de Souza	� Data � 11/01/05 ���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Processa os documentos de transporte a serem exibidos no    ���
���          � fluxo                                                       ���
��������������������������������������������������������������������������Ĵ��
��� Uso	     � FINC021														���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function Fc021Ctrc( cAliasCtrc, dUltData, lConsFil, cFilDe, cFilAte, lAnalitico, aFluxo, nMoeda, aTotais, aPeriodo, lFiliais )
Local nValDoc
Local cIdentific
Local nAscan

//�����������������������������������������������������������Ŀ
//� Atribui valores as variaveis ref a filiais                �
//�������������������������������������������������������������
If !lConsFil
   cFilDe  := xFilial("DT6")
   cFilAte := xFilial("DT6")
EndIf

aStru     := DT6->( dbStruct() )
cAliasTrb := "FINC021"

cQuery := "SELECT * "
cQuery += "FROM " + RetSqlName( "DT6" ) + " DT6 "
cQuery += "WHERE "

If lFiliais
	cQuery += "DT6.DT6_FILIAL IN(" + cLisFil + ") AND "
Else
	cQuery += "DT6.DT6_FILIAL >= '" + cFilDe + "' AND "
	cQuery += "DT6.DT6_FILIAL <= '" + cFilAte + "' AND "
EndIf

// Doctos. nao faturados
cQuery += "DT6.DT6_PREFIX = '" + Space( Len( DT6->DT6_PREFIX ) ) + "' AND "
cQuery += "DT6.DT6_NUM = '" + Space( Len( DT6->DT6_NUM ) ) + "' AND "
cQuery += "DT6.DT6_TIPO = '" + Space( Len( DT6->DT6_TIPO ) ) + "' AND "
cQuery += "DT6.DT6_MOEDA = " + AllTrim( Str( nMoeda, 2, 0 ) ) + " AND "
cQuery += "DT6.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTrb,.T.,.T.)
aEval(aStru, {|e| If(e[2]!= "C", TCSetField(cAliasTrb, e[1], e[2],e[3],e[4]),Nil)})

While (cAliasTrb)->(!Eof()) //IndRegua
	IncProc("Processando Doctos. de Transporte")
	dDataTrab := DataValida((cAliasTrb)->DT6_VENCTO,.T.)
	//����������������������������������������������������������������Ŀ
	//� Se a data de vencto. nao ultrapassar a ultima data do relatorio�
	//������������������������������������������������������������������
	If dDataTrab <= dUltData
		nValDoc := xMoeda( (cAliasTrb)->DT6_VALTOT, (cAliasTrb)->DT6_MOEDA, nMoeda )
		If Abs(nValDoc) > 0.0001
			// Pesquisa a data na matriz com os dados a serem exibidos na tela do fluxo
			nAscan := Ascan(aPeriodo, {|e| e[1] == dDataTrab})
			// Verifica se esta no periodo solicitado
			If nAscan > 0
				aFluxo[nAscan][ENTRADAS] += nValDoc
			Endif
			If lAnalitico .And. nAscan > 0
				RecLock(cAliasCtrc,.T.)
				(cAliasCtrc)->FILIAL	:= (cAliasTrb)->DT6_FILIAL 
				(cAliasCtrc)->Datax		:= dDataTrab
				(cAliasCtrc)->Periodo	:= aPeriodo[nAscan][2]
				(cAliasCtrc)->FILDEB	:= (cAliasTrb)->DT6_FILDEB
				(cAliasCtrc)->FILDOC	:= (cAliasTrb)->DT6_FILDOC
				(cAliasCtrc)->DOC		:= (cAliasTrb)->DT6_DOC
				(cAliasCtrc)->SERIE		:= (cAliasTrb)->DT6_SERIE
				(cAliasCtrc)->EMISSAO	:= (cAliasTrb)->DT6_DATEMI
				cIdentific :=	xFilial("DT6")+;
								   (cAliasTrb)->DT6_FILDOC	+;
								   (cAliasTrb)->DT6_DOC		+;
								   (cAliasTrb)->DT6_SERIE
				(cAliasCtrc)->Chave     := cIdentific
				(cAliasCtrc)->SALDO     := nValDoc
				(cAliasCtrc)->Apelido   := "DT6"
				MsUnlock()
				// Pesquisa na matriz de totais, os totais de contas a pagar ou a receber
				// da data de trabalho.
				nAscan := Ascan( aTotais[9], {|e| e[1] == dDataTrab})
				If nAscan == 0
					Aadd( aTotais[9], {dDataTrab,nValDoc})
				Else
					aTotais[9][nAscan][2] += nValDoc // Contabiliza os totais de Doctos.
				Endif
			Endif
		EndIf
	Endif
	(cAliasTrb)->(dbSkip())
Enddo

dbSelectArea(cAliasTrb)
dbCloseArea()
dbSelectArea("DT6")

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Fc021Solic�Autor  �Microsiga           � Data �  10/09/12   ���
�������������������������������������������������������������������������͹��
���Desc.     � Processa as solicitacoes de fundos a serem exibidas no     ���
���          � fluxo                                                      ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAFIN - Argentina                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Fc021Solic( cAliasSol, dUltData, lConsFil, cFilDe, cFilAte, lAnalitico, aFluxo, nMoeda, aTotais, aPeriodo, lFiliais )
Local nValSol		:= 0
Local nAscan		:= 0

//�����������������������������������������������������������Ŀ
//� Atribui valores as variaveis ref a filiais                �
//�������������������������������������������������������������
If !lConsFil
   cFilDe  := xFilial("FJA")
   cFilAte := xFilial("FJA")
Endif

aStru     := FJA->(DbStruct())
cAliasTrb := "FINC021"

cQuery := "SELECT * "
cQuery += "FROM " + RetSqlName("FJA") + " FJA "
cQuery += "WHERE "

If lFiliais
	cQuery += "	FJA.FJA_FILIAL IN	(" + cLisFil + ") AND "
Else
	cQuery += "	FJA.FJA_FILIAL	>=	'" + cFilDe + "' AND "
	cQuery += "	FJA.FJA_FILIAL	<=	'" + cFilAte + "' AND "
EndIf

cQuery += "	FJA.D_E_L_E_T_	=	' ' AND "
cQuery += "	FJA.FJA_DATAPR	>=	'" + DToS(dDataBase) + "' AND "
cQuery += "	FJA.FJA_DATAPR	<=	'" + DToS(dUltData) + "' AND "
cQuery += "	(FJA.FJA_ESTADO	= '1' OR FJA.FJA_ESTADO	= '2') AND "	// Solicitacoes pendentes e aprovadas
cQuery += "	FJA.FJA_ORDPAG	=	' ' AND "	// Nao associadas a Ordem de Pagamento
cQuery += "	FJA.FJA_MOEDA	=	'" + AllTrim(StrZero(nMoeda,2)) +"'"

cQuery := ChangeQuery(cQuery)

DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTrb,.T.,.T.)
aEval(aStru, {|e| If(e[2]!= "C", TCSetField(cAliasTrb, e[1], e[2],e[3],e[4]),Nil)})

While (cAliasTrb)->(!Eof()) //IndRegua
	IncProc('Processando Solicita��es de Fundo') //"Processando Solicita��es de Fundo"
	dDataTrab := DataValida((cAliasTrb)->FJA_DATAPR,.T.)
	//����������������������������������������������������������������Ŀ
	//� Se a data de vencto. nao ultrapassar a ultima data do relatorio�
	//������������������������������������������������������������������
	If dDataTrab <= dUltData
		nValSol := xMoeda((cAliasTrb)->FJA_VALOR,Val((cAliasTrb)->FJA_MOEDA),nMoeda)
		If Abs(nValSol) > 0.0001
			// Pesquisa a data na matriz com os dados a serem exibidos na tela do fluxo
			nAscan := Ascan(aPeriodo, {|e| e[1] == dDataTrab})
			// Verifica se esta no periodo solicitado
			If nAscan > 0
				aFluxo[nAscan][ENTRADAS] += nValSol
			Endif
			If lAnalitico .And. nAscan > 0
				RecLock(cAliasSol,.T.)
				(cAliasSol)->PERIODO	:= aPeriodo[nAscan][2]
				(cAliasSol)->DATAX		:= dDataTrab
				(cAliasSol)->FILIAL		:= (cAliasTrb)->FJA_FILIAL
				(cAliasSol)->SOLFUN		:= (cAliasTrb)->FJA_SOLFUN
				(cAliasSol)->FORNEC		:= (cAliasTrb)->FJA_FORNEC
				(cAliasSol)->LOJA		:= (cAliasTrb)->FJA_LOJA
				(cAliasSol)->DATAPR		:= (cAliasTrb)->FJA_DATAPR
				(cAliasSol)->SALDO		:= nValSol
				(cAliasSol)->CHAVE		:= xFilial("FJA")+(cAliasTrb)->(FJA_FORNEC+FJA_LOJA+FJA_SOLFUN)
				(cAliasSol)->APELIDO	:= "FJA"
				MsUnlock()
				// Pesquisa na matriz de totais, os totais de contas a pagar ou a receber
				// da data de trabalho.
				nAscan := Ascan( aTotais[10], {|e| e[1] == dDataTrab})
				If nAscan == 0
					Aadd( aTotais[10], {dDataTrab,nValSol})
				Else
					aTotais[10][nAscan][2] += nValSol // Contabiliza os totais de Solicitacoes.
				Endif
			Endif
		EndIf
	Endif
	(cAliasTrb)->(dbSkip())
Enddo

DbSelectArea(cAliasTrb)
DbCloseArea()
DbSelectArea("FJA")

Return Nil

Static Function FC020DMSCOMPRA(cAliasDMSCompra,aTotais,lRegua,nMoeda,aPeriodo,cFilIni,cFilFin,lConsDtBase,lFiliais,aSelFil,nPosTotal )

	LOCAL cNumPed
	Local nValTot :=0
	Local nValIpi :=0
	Local nPrcCompra
	LOCAL dData
	LOCAL cFilDe
	LOCAL cFilAte
	LOCAL cSaveFil := cFilAnt
	LOCAL nAscan
	Local dDataFluxo
	LOCAL nDespFrete := 0
	LOCAL nInc		 := 0

	LOCAL aSM0		:= AdmAbreSM0()
	Local cLstFiliais := ""
	Local aCachDt	:= {}

	LOCAL nI := 0
	LOCAL cQuery
	LOCAL aStru := VQ0->(dbStruct())
	LOCAL lVQ0_FLUXO := ( VQ0->(FieldPos("VQ0_FLUXO")) > 0 )
	
	Local dDatRef := ctod("")
	Local aData := {}
	Local nPos  := 0
	
	Local cMV_GRUVEI := Padr(GetMv("MV_GRUVEI"),TamSX3("B1_GRUPO")[1])

	DEFAULT nMoeda := 1
	DEFAULT cFilIni := Space( FWGETTAMFILIAL)
	DEFAULT cFilFin := Replicate( "Z", FWGETTAMFILIAL)
	DEFAULT lConsDtBase := .f.
	DEFAULT lFiliais := .F.
	DEFAULT aSelFil := {}
	DEFAULT nPosTotal := 11

	//----------------------------------//
	If mv_par03 == 2		// por empresa
		cFilDe := cFilIni
		cFilAte := cFilFin
	Else						// por filial
		cFilDe := cFilAnt
		cFilAte := cFilAnt
	Endif

	If cGetVersao < "12"
		nPosTotal := 12
		If lFiliais
			cLstFiliais := ArrayToStr(aSelFil)
		EndIf
	EndIf

	For nInc := 1 To Len( aSM0 )
		If aSM0[nInc][1] == cEmpAnt .AND. ;
			If( EMPTY(cLstFiliais),;
				(Alltrim(aSM0[nInc][2]) >= Alltrim(cFilDe) .and. Alltrim(aSM0[nInc][2]) <= Alltrim(cFilAte)),;
				(aSM0[nInc][2] $ cLstFiliais);
				)

			cFilAnt := aSM0[nInc][2]
			//???????????????????????????????????????????????????????????????
			//?Ler Pedidos de Compra													  ?
			//????????????????????????????????????????????????????????????????
			dbSelectArea("VQ0")
			VQ0->(dbSetOrder(1))
			cQuery := "SELECT VQ0.* "
			cQuery += "  FROM " + RetSqlName("VQ0") + " VQ0"
			cQuery += "  LEFT JOIN " + RetSqlName("SB1") + " SB1"
			cQuery += "    ON  SB1.B1_FILIAL = '" + xFilial("SB1") + "'"
			cQuery += "    AND SB1.B1_GRUPO = '"+cMV_GRUVEI+"'"
			cQuery += "    AND SB1.B1_CODITE = VQ0.VQ0_CHAINT"
			cQuery += "    AND SB1.D_E_L_E_T_ = ' ' "
			cQuery += "  WHERE VQ0.VQ0_FILIAL = '" + xFilial("VQ0") + "'"
			cQuery += "    AND VQ0.VQ0_FILPED = '" + cFilAnt + "'"
			If lVQ0_FLUXO
				cQuery += "    AND VQ0.VQ0_FLUXO IN (' ','S') "
			EndIf			
			cQuery += "    AND VQ0.D_E_L_E_T_ = ' ' "
			cQuery += "    AND ( SB1.B1_COD IS NULL "  
			cQuery += "     OR SB1.B1_COD NOT IN "
			cQuery += "      ( SELECT SD1.D1_COD "
			cQuery += "          FROM " + RetSqlName("SD1") + " SD1"
			cQuery += "          JOIN " + RetSqlName("SF4") + " SF4"
			cQuery += "            ON  SF4.F4_FILIAL = '" + xFilial("SF4") + "'"
			cQuery += "            AND SF4.F4_CODIGO = SD1.D1_TES"
			cQuery += "            AND SF4.F4_OPEMOV = '01'"
			cQuery += "            AND SF4.D_E_L_E_T_ = ' ' "
			cQuery += "          WHERE SD1.D1_COD = SB1.B1_COD " // QUALQUER FILIAL - BUSCA SOMENTE PELO CODIGO DO PRODUTO VEICULO
			cQuery += "            AND SD1.D_E_L_E_T_ = ' ' )"
			cQuery += "      )"

			dbSelectArea("VQ0")
			dbCloseArea()
			dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'VQ0', .F., .T.)

			For nI := 1 to Len(aStru)
				If aStru[nI,2] != 'C'
					TCSetField('VQ0', aStru[nI,1], aStru[nI,2],aStru[nI,3],aStru[nI,4])
				Endif
			Next

			While VQ0->(!Eof()) .and. VQ0->VQ0_FILIAL == xFilial("VQ0")

				cNumPed := VQ0->VQ0_NUMPED
				nValTot := 0
				nDespFrete := 0

				If lRegua != Nil .and. lRegua
					IncProc("Processando Pedidos de Compra de Maquinas") // "Processando Pedidos de Compra de Maquinas"
				Endif

				If lVQ0_FLUXO
					dDatRef := VQ0->VQ0_DATFLU // Data para entrar no Fluxo
				Else
					dDatRef := VQ0->VQ0_DATPED // Data do Pedido
				EndIf

				dData := dDatRef
				nPos := Ascan(aData, { |x| x[1] == dDatRef } )
				If nPos == 0
					dData := DataValida(dDatRef)
					aadd(aData, {dDatRef, dData})
				EndIf

				If !lConsDtBase
					If nPos > 0
						dData := adata[nPos][2]
					Endif
				Else
					dData := Iif( dDatRef < dDataBase, dDataBase, dData )
				Endif

				nPrcCompra 	:= VQ0->VQ0_VALCUS

				nDespFrete := 0
				nValTot	  := ( nPrcCompra ) + nDespFrete
				nValIPI	  := 0

				nValTot  += nValIPI

				nL := Ascan(aDMSCompras,{|e| e[1] == dData } )
				IF nL == 0
					AADD(aDMSCompras,{ dData , nValTot })
				Else
					aDMSCompras[nL][2] += nValTot
				EndIf

				// Se foi enviado o arquivo temporario para geracao do fluxo
				// de caixa analitico, gera o pedido de compra neste arquivo
				If cAliasDMSCompra != Nil
					DbSelectArea(cAliasDMSCompra)
					dDataFluxo := dData
					nAscan := Ascan(aPeriodo, {|e| e[1] == dDataFluxo})
					// Se a data do pedido ja venceu, insere na primeira data do fluxo
					If dDataFluxo < aPeriodo[1][1]
						dDataFluxo := aPeriodo[1][1]
						nAscan := 1
					Endif
					If nAscan > 0
						If !dbSeek(dTos(dDataFluxo) + VQ0->VQ0_CODIGO)
							RecLock(cAliasDMSCompra,.T.)
							(cAliasDMSCompra)->FILIAL  := VQ0->VQ0_FILIAL
							(cAliasDMSCompra)->DATAX  := dDataFluxo
							(cAliasDMSCompra)->Periodo:= aPeriodo[nAscan][2]

							(cAliasDMSCompra)->NUMERO  := VQ0->VQ0_CODIGO
							(cAliasDMSCompra)->PEDFAB  := VQ0->VQ0_NUMPED
							(cAliasDMSCompra)->EMISSAO := dDatRef
							(cAliasDMSCompra)->CHASSI  := VQ0->VQ0_CHASSI
							(cAliasDMSCompra)->MODELO  := VQ0->VQ0_CODMAR+" "+VQ0->VQ0_MODVEI

						Else
							RecLock(cAliasDMSCompra,.F.)
						Endif
						(cAliasDMSCompra)->SALDO += VQ0->VQ0_VALCUS

						// Pesquisa na matriz de totais, os totais de pedidos de compra
						// da data de trabalho.
						If aTotais # Nil
							nAscan := Ascan( aTotais[nPosTotal], {|e| e[1] == (cAliasDMSCompra)->DATAX})
							If nAscan == 0
								Aadd( aTotais[nPosTotal], { (cAliasDMSCompra)->DATAX , VQ0->VQ0_VALCUS })
							Else
								aTotais[nPosTotal][nAscan][2] += VQ0->VQ0_VALCUS //(cAliasPc)->SALDO // Totaliza os pedidos de compra
							Endif
						Endif
					Endif
				EndIf

				VQ0->(dbSkip())

			Enddo
			dbSelectArea("VQ0")
			dbCloseArea()
			ChKFile("VQ0")
			dbSelectArea("VQ0")
			dbSetOrder(1)
		EndIf
	Next

	cFilAnt := cSaveFil // recupera variavel cFilAnt

	aSize(aData, 0 )
	aData := NIL
	aSize(aCachDt, 0)
	aCachDt := NIL

Return .T.


Static Function FC020DMSVENDA(cAliasDMSVenda,aTotais,lRegua,nMoeda,aPeriodo,cFilIni,cFilFin,lConsDtBase,lFiliais,aSelFil,nPosTotal)

	LOCAL cNumPed
	Local nValTot :=0
	Local nValIpi :=0
	LOCAL dData
	LOCAL cFilDe
	LOCAL cFilAte
	LOCAL cSaveFil := cFilAnt
	LOCAL nAscan
	LOCAL nDespFrete := 0
	LOCAL nInc		 := 0

	LOCAL aSM0		:= AdmAbreSM0()
	Local cLstFiliais := ""
	Local aCachDt	:= {}

	LOCAL nI := 0
	LOCAL cQuery
	LOCAL aStru := VS9->(dbStruct())
	LOCAL lVV0_FLUXO  := ( VV0->(FieldPos("VV0_FLUXO"))  > 0 )
	LOCAL lVV0_TIPDOC := ( VV0->(FieldPos("VV0_TIPDOC")) > 0 )

	Local aData := {}
	Local nPos  := 0

	DEFAULT nMoeda := 1
	DEFAULT cFilIni := "  "
	DEFAULT cFilFin := "zz"
	DEFAULT lConsDtBase := .f.
	DEFAULT lFiliais := .F.
	DEFAULT aSelFil := {}
	DEFAULT nPosTotal := 12

	//----------------------------------//
	If mv_par03 == 2		// por empresa
		cFilDe := cFilIni
		cFilAte := cFilFin
	Else						// por filial
		cFilDe := cFilAnt
		cFilAte := cFilAnt
	Endif

	If cGetVersao < "12"
		nPosTotal := 13
	EndIf

	If lFiliais
		cLstFiliais := ArrayToStr(aSelFil)
	EndIf

	For nInc := 1 To Len( aSM0 )
		If aSM0[nInc][1] == cEmpAnt .AND. ;
			If( EMPTY(cLstFiliais),;
				(Alltrim(aSM0[nInc][2]) >= Alltrim(cFilDe) .and. Alltrim(aSM0[nInc][2]) <= Alltrim(cFilAte)),;
				(aSM0[nInc][2] $ cLstFiliais);
				)

			cFilAnt := aSM0[nInc][2]
			//???????????????????????????????????????????????????????????????
			//?Ler Pedidos de Compra													  ?
			//????????????????????????????????????????????????????????????????
			dbSelectArea("VS9")
			VS9->(dbSetOrder(1))
			cQuery := "SELECT VS9.* , VV9.VV9_CODCLI , VV9.VV9_LOJA , VV9.VV9_NOMVIS , SA1.A1_NOME "
			cQuery += " FROM " + RetSQLName("VV0") + " VV0" 
			cQuery += " JOIN " + RetSQLName("VS9") + " VS9 "
			cQuery += "     ON  VS9.VS9_FILIAL = '" + xFilial("VS9" ) + "' " 
			cQuery += "     AND VS9.VS9_TIPOPE = 'V' "
			cQuery += "     AND VS9.VS9_NUMIDE = VV0.VV0_NUMTRA "
			cQuery += "     AND VS9.D_E_L_E_T_ = ' ' "
			cQuery += " JOIN " + RetSQLName("VV9") + " VV9 "
			cQuery += "     ON  VV9.VV9_FILIAL = VV0.VV0_FILIAL "
			cQuery += "     AND VV9.VV9_NUMATE = VV0.VV0_NUMTRA "
			cQuery += "     AND VV9.VV9_STATUS <> 'C' "
			cQuery += "     AND VV9.D_E_L_E_T_ = ' ' "
			cQuery += " LEFT JOIN " + RetSQLName("SA1") + " SA1 "
			cQuery += "     ON  SA1.A1_FILIAL = '" + xFilial("SA1") + "' "
			cQuery += "     AND SA1.A1_COD = VV9.VV9_CODCLI "
			cQuery += "     AND SA1.A1_LOJA = VV9.VV9_LOJA "
			cQuery += "     AND SA1.D_E_L_E_T_ = ' ' "
			cQuery += " WHERE VV0.VV0_FILIAL = '" + xFilial("VV0") + "' "
			cQuery += "     AND VV0.VV0_OPEMOV = '0'"
			cQuery += "     AND VV0.VV0_NUMNFI = ' '"
			cQuery += "     AND VV0.VV0_SERNFI = ' '"
			If lVV0_FLUXO
				cQuery += " AND VV0.VV0_FLUXO  = 'S'"
			EndIf
			If lVV0_TIPDOC
				cQuery += " AND VV0.VV0_TIPDOC <> '2'"
			EndIf
			cQuery += "     AND VV0.D_E_L_E_T_ = ' '"
			cQuery += " ORDER BY VS9.VS9_DATPAG , VS9.VS9_NUMIDE , VS9.VS9_TIPPAG"
			dbSelectArea("VS9")
			dbCloseArea()
			dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'VS9', .F., .T.)

			For nI := 1 to Len(aStru)
				If aStru[nI,2] != 'C'
					TCSetField('VS9', aStru[nI,1], aStru[nI,2],aStru[nI,3],aStru[nI,4])
				Endif
			Next

			While VS9->(!Eof()) .and. VS9->VS9_FILIAL == xFilial("VS9")

				cNumPed := VS9->VS9_NUMIDE
				nValTot := 0
				nDespFrete := 0

				If lRegua != Nil .and. lRegua
					IncProc("Processando Pedidos de Venda de Maquinas") // "Processando Pedidos de Venda de Maquinas"
				Endif

				dData := VS9->VS9_DATPAG
				nPos := Ascan(aData, { |x| x[1] == VS9->VS9_DATPAG } )
				If nPos == 0
					dData := DataValida(VS9->VS9_DATPAG)
					aadd(aData, {VS9->VS9_DATPAG, dData})
				EndIf

				If !lConsDtBase
					If nPos > 0
						dData := adata[nPos][2]
					Endif
				Else
					dData := Iif( VS9->VS9_DATPAG < dDataBase, dDataBase, dData )
				Endif

				nDespFrete := 0
				nValTot	  := VS9->VS9_VALPAG
				nValIPI	  := 0

				nValTot  += nValIPI

				nL := Ascan(aDMSVendas,{|e| e[1] == dData } )
				IF nL == 0
					AADD(aDMSVendas,{ dData , nValTot })
				Else
					aDMSVendas[nL][2] += nValTot
				EndIf

				// Se foi enviado o arquivo temporario para geracao do fluxo
				// de caixa analitico, gera o pedido de compra neste arquivo
				If cAliasDMSVenda != Nil
					DbSelectArea(cAliasDMSVenda)
					dDataFluxo := dData
					nAscan := Ascan(aPeriodo, {|e| e[1] == dDataFluxo})
					// Se a data do pedido ja venceu, insere na primeira data do fluxo
					If dDataFluxo < aPeriodo[1][1]
						dDataFluxo := aPeriodo[1][1]
						nAscan := 1
					Endif
					If nAscan > 0
						If !dbSeek(dTos(dDataFluxo) + VS9->VS9_NUMIDE)
							RecLock(cAliasDMSVenda,.T.)
							(cAliasDMSVenda)->FILIAL    := VS9->VS9_FILIAL
							(cAliasDMSVenda)->DATAX  := dDataFluxo
							(cAliasDMSVenda)->Periodo:= aPeriodo[nAscan][2]
							(cAliasDMSVenda)->NUMERO    := VS9->VS9_NUMIDE
							(cAliasDMSVenda)->EMISSAO   := VS9->VS9_DATPAG
							(cAliasDMSVenda)->CLIFOR    := VS9->VV9_CODCLI
							(cAliasDMSVenda)->LOJACLI   := VS9->VV9_LOJA
							(cAliasDMSVenda)->NomCliFor := IIf(!Empty(VS9->A1_NOME),VS9->A1_NOME,VS9->VV9_NOMVIS)
						Else
							RecLock(cAliasDMSVenda,.F.)
						Endif
						(cAliasDMSVenda)->SALDO += VS9->VS9_VALPAG

						// Pesquisa na matriz de totais, os totais de pedidos de compra
						// da data de trabalho.
						If aTotais # Nil
							nAscan := Ascan( aTotais[nPosTotal], {|e| e[1] == (cAliasDMSVenda)->DATAX})
							If nAscan == 0
								Aadd( aTotais[nPosTotal], { (cAliasDMSVenda)->DATAX , VS9->VS9_VALPAG })
							Else
								aTotais[nPosTotal][nAscan][2] += VS9->VS9_VALPAG //(cAliasPc)->SALDO // Totaliza os pedidos de venda
							Endif
						Endif
					Endif
				EndIf

				VS9->(dbSkip())

			Enddo
			dbSelectArea("VS9")
			dbCloseArea()
			ChKFile("VS9")
			dbSelectArea("VS9")
			dbSetOrder(1)
		EndIf
	Next

	cFilAnt := cSaveFil // recupera variavel cFilAnt

	aSize(aData, 0 )
	aData := NIL
	aSize(aCachDt, 0)
	aCachDt := NIL

Return .T.


Static Function VM210CriaTmpAna(cTipo)

	Local aCposArquivo := {}
	Local cAliasAna := ""

	Do Case
	Case cTipo == "MAQ_COMPRA"
		Aadd( aCposArquivo , { "FILIAL" , "C", TamSx3("VQ0_FILIAL")[1], 0 } )
		Aadd( aCposArquivo , { "Periodo", "C",  25, 0 } )
		Aadd( aCposArquivo , { "DATAX"  , "D", 08, 0} )
		Aadd( aCposArquivo , { "NUMERO" , "C", TamSx3("VQ0_CODIGO")[1], 0 } )
		Aadd( aCposArquivo , { "PEDFAB" , "C", TamSx3("VQ0_NUMPED")[1], 0 } )
		Aadd( aCposArquivo , { "EMISSAO", "D",  8, 0 } )
		Aadd( aCposArquivo , { "CHASSI" , "C", TamSx3("VQ0_CHASSI")[1], 0 } )
		Aadd( aCposArquivo , { "MODELO" , "C", TamSx3("VQ0_MODVEI")[1], 0 } )
		Aadd( aCposArquivo , { "SALDO"  , "N", TamSx3("VQ0_VALCUS")[1]  , TamSx3("VQ0_VALCUS")[2] } )
		Aadd( aCposArquivo , { "CHAVE"  , "C", 40, 0 } )
		Aadd( aCposArquivo , { "Apelido", "C", 10, 0 } )

		cAliasAna := "cArqAnaDMSCp"  // Alias do arquivo analitico

	Case cTipo == "MAQ_VENDA"

		Aadd( aCposArquivo , { "FILIAL" , "C", TamSx3("VV0_FILIAL")[1], 0 } )
		Aadd( aCposArquivo , { "Periodo", "C",  25, 0 } )
		Aadd( aCposArquivo , { "DATAX"  , "D", 08, 0} )
		Aadd( aCposArquivo , { "NUMERO" , "C", TamSx3("VV0_NUMTRA")[1], 0 } )
		Aadd( aCposArquivo , { "CLIFOR" , "C", TamSx3("E5_CLIFOR")[1], 0 } )
		Aadd( aCposArquivo , { "LOJACLI", "C", TamSx3("C5_LOJAENT")[1], 0 } )
		Aadd( aCposArquivo , { "NomCliFor", "C", TamSx3("A1_NOME")[1], 0 } )
		Aadd( aCposArquivo , { "EMISSAO", "D",  8, 0 } )
		Aadd( aCposArquivo , { "SALDO"  , "N", TamSx3("VQ0_VALCUS")[1]  , TamSx3("VQ0_VALCUS")[2] } )
		Aadd( aCposArquivo , { "CHAVE"  , "C", 40, 0 } )
		Aadd( aCposArquivo , { "Apelido", "C", 10, 0 } )

		cAliasAna := "cArqAnaDMSVd"  // Alias do arquivo analitico
	End Do

Return { aCposArquivo , cAliasAna }       

/*___________________________________________________________________________
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
||-------------------------------------------------------------------------||
|| Fun��o: SchedDef     || Autor: Luciano Corr�a        || Data: 11/07/19  ||
||-------------------------------------------------------------------------||
|| Descri��o: Fun��o para configura��o de Par�metros no Agendamento        ||
||-------------------------------------------------------------------------||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
���������������������������������������������������������������������������*/
Static Function SchedDef()

Local aOrd		:= {}
Local aParam	:= {}

aParam	:= { "P", "CI_M180", "", aOrd, }

Return( aParam )

