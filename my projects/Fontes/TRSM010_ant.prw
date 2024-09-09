#Include "Totvs.ch"              
#Include "Fileio.ch"    
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ TRSM010 ³ Autor ³ Denis Rodrigues      ³ Data ³ 06/10/2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Exportador de tabelas do Protheus para CSV                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TRSM010( ExpA01 )                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA01 = Indica se a rotina esta sendo executada via       ³±±
±±³          ³ schedule ou via menu                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente TOTVS RS                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                          ULTIMAS ALTERACOES                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ Motivo da Alteracao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Gregory A  ³18/01/17³ Compactar arquivos por .bat e enviar para https ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function TRSM010( aParam )

	Local lAuto       := ( ValType(aParam) = "A" )
	Local cCadastro   := "Exportador de tabelas"
	Local cDescRot    := ""
	Local aInfoCustom := {}
	Local aTabelas    :={"SA1", "SA3", "SC5", "SC6", "SF2", "SD2"}
	Local bProcess    :={||}
	Local oProcess
	
	Private cPerg := "" 
	
	If lAuto// Chamada via Schedule
				
		If RpcSetEnv(aParam[1],aParam[2],,,"FAT","TRSM010",aTabelas,,,,)
			
			ConOut("Inicio do processo de Exportacao de Tabelas para o GoodData - TRSM010")	
			
			BatchProcess(	cCadastro, cCadastro, "TRSM010", { || M010EXEC(oProcess,lAuto) }, { || .F. }  )

			ConOut("Fimdo processo de Exportacao de Tabelas para o GoodData - TRSM010")	

		EndIf


		RpcClearEnv()

	Else
	
		cPerg := PadR( "TRSM010_", Len( SX1->X1_GRUPO ), "" )
	
		M010CriaSX1( cPerg )
		
		Pergunte( cPerg, .F. )
		
		aAdd( aInfoCustom, { "Cancelar", { |oPanelCenter| oPanelCenter:oWnd:End() }, 	"CANCEL"	})

		bProcess := {|oProcess| M010EXEC(oProcess, lAuto ) }

		cDescRot := " Este programa tem o objetivo, exportar para CSV as tabelas de Clientes, Pedidos de Venda, Financeiro"
		cDescRot += " e Nota Fiscal de Saida para um diretório no Protheus_Data"

		oProcess := tNewProcess():New("TRSM010",cCadastro,bProcess,cDescRot,cPerg,aInfoCustom, .T.,5, "", .T. )

	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ M010EXEC ³ Autor ³ Denis Rodrigues     ³ Data ³  06/10/2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Processa uma das rotinas selecionadas                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ M010EXEC( oExp1,lExp1 )                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oExp1 - Propriedades do objeto tNewProcess                 ³±±
±±³          ³ lExp1 - Se esta sendo executado por schedule ou manual     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function M010EXEC(oProcess, lAuto )

	Local cMsg	:= ""
	
	Set(_SET_DATEFORMAT, 'dd/mm/yyyy') // Data com QUATRO digitos para Ano
	
	//Cria o diretorio caso nao exista no Protheus_Data
	If !ExistDir( "\m010Exporta" )
		MakeDir( "\m010Exporta" )
	EndIf
	
	If !lAuto
		oProcess:SaveLog("Inicio da Execucao")
	EndIf
	//+------------------------------------------+
	//| EXPORTACAO DO CADASTRO DE CLIENTES - SA1 |
	//+------------------------------------------+
	If lAuto//Via Schedule
		If GetMV("ES_EXPCLI") == 1
			cMsg += M010Cliente(oProcess,lAuto)
		EndIf		
	Else	//Via Menu
		If MV_PAR06 == 1//1-Executa/2-Nao executa	
			cMsg += M010Cliente(oProcess,lAuto)
		EndIf		
	EndIf
	
	//+--------------------------------------------+
	//| EXPORTACAO DO CADASTRO DE VENDEDORES - SA3 |
	//+--------------------------------------------+
	If lAuto//Via Schedule	
		If GetMV("ES_EXPVEND") == 1
			cMsg += M010Vendedores(oProcess,lAuto)
		EndIf		
	Else//Via Menu
		If MV_PAR07 == 1//1-Executa/2-Nao executa	
			cMsg += M010Vendedores(oProcess,lAuto)
		EndIf
	EndIf
	
	//+------------------------------------------+
	//| EXPORTACAO DO CADASTRO DE PRODUTOS - SB1 |
	//+------------------------------------------+
	If lAuto//Via Schedule	
		If GetMV("ES_EXPPROD") == 1
			cMsg += M010Produtos(oProcess,lAuto)
		EndIf		
	Else//Via Menu	
		If MV_PAR08 == 1//1-Executa/2-Nao executa	
			cMsg += M010Produtos(oProcess,lAuto)
		EndIf
	EndIf

	//+-----------------------------------------+                                                  
	//| EXPORTACAO DO PEDIDO DE VENDA - SC5/SC6 |
	//+-----------------------------------------+
	If lAuto//Via Schedule	
		If GetMV("ES_EXPPEDV") == 1
			cMsg += M010PedidoVenda(oProcess,lAuto)
		EndIf		
	Else//Via Menu	
		If MV_PAR09 == 1//1-Executa/2-Nao executa	
			cMsg += M010PedidoVenda(oProcess,lAuto)
		EndIf
	EndIf
	
	//+--------------------------------------------+
	//| EXPORTACAO DO CADASTRO DE FORNECEDOR - SA2 |
	//+--------------------------------------------+
	If lAuto//Via Schedule
		If GetMV("ES_EXPFOR") == 1
			cMsg += M010Fornecedor(oProcess,lAuto)
		EndIf		
	Else	//Via Menu
		If MV_PAR10 == 1//1-Executa/2-Nao executa	
			cMsg += M010Fornecedor(oProcess,lAuto)
		EndIf		
	EndIf						
	 
	//+--------------------+
	//| EXPORTACAO DO CRM  |
	//+--------------------+
/*
	If lAuto//Via Schedule	
		If GetMV("ES_EXPCRM") == 1
			cMsg += M010ExpCRM(oProcess,lAuto)
		EndIf		
	Else//Via Menu	
		If MV_PAR11 == 1//1-Executa/2-Nao executa	
			cMsg += M010ExpCRM(oProcess,lAuto)
		EndIf	
	EndIf
*/	

/*		
	//+-----------------------------+
	//| EXPORTACAO DO STATUS PV     |
	//+-----------------------------+
	If lAuto//Via Schedule	
		If GetMV("ES_EXPSPV") == 1
			cMsg += M010ExpSPV(oProcess,lAuto)
		EndIf		
	Else//Via Menu	
		If MV_PAR12 == 1//1-Executa/2-Nao executa	
			cMsg += M010ExpSPV(oProcess,lAuto)
		EndIf
	EndIf
  
*/

	//+-----------------------------+
	//| EXPORTACAO DO FATURAMENTO   |
	//+-----------------------------+
	If lAuto//Via Schedule	
		If GetMV("ES_EXPFAT") == 1
			cMsg += M010ExpFAT(oProcess,lAuto)
		EndIf		
	Else//Via Menu	
		If MV_PAR13 == 1//1-Executa/2-Nao executa	
			cMsg += M010ExpFAT(oProcess,lAuto)
		EndIf	
	EndIf


/* INICIO - PARAMETRO EXCLUIDO POR GABRIEL.COSTA EM 19/08/22, SOLICITAÇÃO PEDIDO FABIO */
/*
	//+--------------------------------------+
	//| EXPORTACAO DO CONTAS A RECEBER - SE1 |
	//+--------------------------------------+
	If lAuto//Via Schedule	
		If GetMV("ES_EXPSE1") == 1
			cMsg += M010SE1Exp(oProcess,lAuto)
		EndIf		
	Else//Via Menu	
		If MV_PAR14 == 1//1-Executa/2-Nao executa	
			cMsg += M010SE1Exp(oProcess,lAuto)
		EndIf	
	EndIf	

	//+------------------------------------+
	//| EXPORTACAO DO CONTAS A PAGAR - SE2 |
	//+------------------------------------+
	If lAuto//Via Schedule	
		If GetMV("ES_EXPSE2") == 1
			cMsg += M010SE2Exp(oProcess,lAuto)
		EndIf		
	Else//Via Menu	
		If MV_PAR15 == 1//1-Executa/2-Nao executa	
			cMsg += M010SE2Exp(oProcess,lAuto)
		EndIf	
	EndIf
		
	//+---------------------------------------------+
	//| EXPORTACAO DA MOVIMENTACAO FINANCEIRA - SE5 |
	//+---------------------------------------------+
	If lAuto//Via Schedule	
		If GetMV("ES_EXPSE5") == 1
			cMsg += M010SE5Exp(oProcess,lAuto)
		EndIf		
	Else//Via Menu	
		If MV_PAR16 == 1//1-Executa/2-Nao executa	
			cMsg += M010SE5Exp(oProcess,lAuto)
		EndIf	
	EndIf
*/
/* FIM - PARAMETRO EXCLUIDO POR GABRIEL.COSTA EM 19/08/22, SOLICITAÇÃO PEDIDO FABIO */

	//+-----------------------------------------+
	//| EXPORTACAO DO LANCAMENTO CONTABIL - CT2 |
	//+-----------------------------------------+
	/*
	If lAuto//Via Schedule	
		If GetMV("ES_EXPCT2") == 1
			cMsg += M010CT2Exp(oProcess,lAuto)
		EndIf		
	Else//Via Menu	
		If MV_PAR17 == 1//1-Executa/2-Nao executa	
			cMsg += M010CT2Exp(oProcess,lAuto)
		EndIf	
	EndIf
	*/

	//+-------------------------------------+
	//| EXPORTACAO DO PLANO DE CONTAS - CT1 |
	//+-------------------------------------+
	If lAuto//Via Schedule	
		If GetMV("ES_EXPCT1") == 1
			cMsg += M010CT1Exp(oProcess,lAuto)
		EndIf		
	Else//Via Menu	
		If MV_PAR18 == 1//1-Executa/2-Nao executa	
			cMsg += M010CT1Exp(oProcess,lAuto)
		EndIf	
	EndIf
					
	//+---------------------------------------+
	//| EXPORTACAO DAS VISOES GERENCIAS - CTS |
	//+---------------------------------------+
	/*
	If lAuto//Via Schedule	
		If GetMV("ES_EXPCTS") == 1
			cMsg += M010CTSExp(oProcess,lAuto)
		EndIf		
	Else//Via Menu	
		If MV_PAR19 == 1//1-Executa/2-Nao executa	
			cMsg += M010CTSExp(oProcess,lAuto)
		EndIf	
	EndIf
	*/      

	//+---------------------------------+
	//| EXPORTACAO DOS ORCAMENTOS - CV1 |
	//+---------------------------------+
	/*
	If lAuto//Via Schedule	
		If GetMV("ES_EXPCV1") == 1
			cMsg += M010CV1Exp(oProcess,lAuto)
		EndIf		
	Else//Via Menu	
		If MV_PAR20 == 1//1-Executa/2-Nao executa	
			cMsg += M010CV1Exp(oProcess,lAuto)
		EndIf	
	EndIf
	*/      

	//+-------------------------+
	//| EXPORTACAO DA TES - SF4 |
	//+-------------------------+
	If lAuto//Via Schedule	
		If GetMV("ES_EXPSF4") == 1
			cMsg += M010SF4Exp(oProcess,lAuto)
		EndIf		
	Else//Via Menu	
		If MV_PAR21 == 1//1-Executa/2-Nao executa	
			cMsg += M010SF4Exp(oProcess,lAuto)
		EndIf	
	EndIf

	//+---------------------------------------+
	//| EXPORTACAO DOS CENTRO DE CUSTOS - CTT |
	//+---------------------------------------+
	If lAuto//Via Schedule	
		If GetMV("ES_EXPCTT") == 1
			cMsg += M010CTTExp(oProcess,lAuto)
		EndIf		
	Else//Via Menu	
		If MV_PAR22 == 1//1-Executa/2-Nao executa	
			cMsg += M010CTTExp(oProcess,lAuto)
		EndIf	
	EndIf
			
	//+------------------------------------+
	//| EXPORTACAO DA META DE VENDAS - SCT |
	//+------------------------------------+
	If lAuto//Via Schedule	
		If GetMV("ES_EXPSCT") == 1
			cMsg += M010SCTExp(oProcess,lAuto)
		EndIf		
	Else//Via Menu	
		If MV_PAR23 == 1//1-Executa/2-Nao executa	
			cMsg += M010SCTExp(oProcess,lAuto)
		EndIf	
	EndIf
				
	//+------------------------------------------+
	//| EXPORTACAO DA TABELA DE PRECOS - DA0/DA1 |
	//+------------------------------------------+
	If lAuto//Via Schedule	
		If GetMV("ES_EXPDA0") == 1
			cMsg += M010DA0Exp(oProcess,lAuto)
		EndIf		
	Else//Via Menu	
		If MV_PAR24 == 1//1-Executa/2-Nao executa	
			cMsg += M010DA0Exp(oProcess,lAuto)
		EndIf	
	EndIf				

	//+-------------------------------------+
	//| EXPORTACAO DA TABELA DE FILIAIS SM0 |
	//+-------------------------------------+
	If lAuto//Via Schedule	
		If GetMV("ES_EXPSM0") == 1
			cMsg += M010SM0Exp(oProcess,lAuto)
		EndIf		
	Else//Via Menu	
		If MV_PAR25 == 1//1-Executa/2-Nao executa	
			cMsg += M010SM0Exp(oProcess,lAuto)
		EndIf	
	EndIf

	//+-----------------------------------------+
	//| EXPORTACAO DOCUMENTO DE ENTRADA SD1 SF1 |
	//+-----------------------------------------+
	If lAuto//Via Schedule	
		If GetMV("ES_EXPSF1") == 1
			cMsg += M010SF1Exp(oProcess,lAuto)
		EndIf		
	Else//Via Menu	
		If MV_PAR26 == 1//1-Executa/2-Nao executa	
			cMsg += M010SF1Exp(oProcess,lAuto)
		EndIf	
	EndIf

	//+------------------------------------------+
	//| EXPORTACAO SALDO FISICO E FINANCEIRO SB2 |
	//+------------------------------------------+
	If lAuto//Via Schedule	
		If GetMV("ES_EXPSB2") == 1
			cMsg += M010SB2Exp(oProcess,lAuto)
		EndIf		
	Else//Via Menu	
		If MV_PAR27 == 1//1-Executa/2-Nao executa	
			cMsg += M010SB2Exp(oProcess,lAuto)
		EndIf	
	EndIf
		
	//+-------------------------------+
	//| EXPORTACAO SALDO POR LOTE SB8 |
	//+-------------------------------+
	If lAuto//Via Schedule	
		If GetMV("ES_EXPSB8") == 1
			cMsg += M010SB8Exp(oProcess,lAuto)
		EndIf		
	Else//Via Menu	
		If MV_PAR28 == 1//1-Executa/2-Nao executa	
			cMsg += M010SB8Exp(oProcess,lAuto)
		EndIf	
	EndIf

	//+-----------------------------------+
	//| EXPORTACAO PODER DE TERCEIROS SB6 |
	//+-----------------------------------+
	If lAuto//Via Schedule	
		If GetMV("ES_EXPSB6") == 1
			cMsg += M010SB6Exp(oProcess,lAuto)
		EndIf		
	Else//Via Menu	
		If MV_PAR29 == 1//1-Executa/2-Nao executa	
			cMsg += M010SB6Exp(oProcess,lAuto)
		EndIf	
	EndIf			
			  
	//+--------------------------------------+
	//| EXPORTACAO TIPOS DE MOVIMENTACAO SF5 |
	//+--------------------------------------+
	If lAuto//Via Schedule	
		If GetMV("ES_EXPSF5") == 1
			cMsg += M010SF5Exp(oProcess,lAuto)
		EndIf		
	Else//Via Menu	
		If MV_PAR30 == 1//1-Executa/2-Nao executa	
			cMsg += M010SF5Exp(oProcess,lAuto)
		EndIf	
	EndIf

	//+----------------------------------+
	//| EXPORTACAO TABELA DE ARMAZEM NNR |
	//+----------------------------------+
	If lAuto//Via Schedule	
		If GetMV("ES_EXPNNR") == 1
			cMsg += M010NNRExp(oProcess,lAuto)
		EndIf		
	Else//Via Menu	
		If MV_PAR31 == 1//1-Executa/2-Nao executa	
			cMsg += M010NNRExp(oProcess,lAuto)
		EndIf	
	EndIf

	//+---------------------------------------+
	//| EXPORTACAO MOVIMENTACOES INTERNAS SD3 |
	//+---------------------------------------+
	If lAuto//Via Schedule	
		If GetMV("ES_EXPSD3") == 1
			cMsg += M010SD3Exp(oProcess,lAuto)
		EndIf		
	Else//Via Menu	
		If MV_PAR32 == 1//1-Executa/2-Nao executa	
			cMsg += M010SD3Exp(oProcess,lAuto)
		EndIf	
	EndIf		

	//+---------------------------------+
	//| EXPORTACAO PEDIDO DE COMPRA SC7 |
	//+---------------------------------+
	If lAuto//Via Schedule	
		If GetMV("ES_EXPSC7") == 1
			cMsg += M010SC7Exp(oProcess,lAuto)
		EndIf		
	Else//Via Menu	
		If MV_PAR33 == 1//1-Executa/2-Nao executa	
			cMsg += M010SC7Exp(oProcess,lAuto)
		EndIf	
	EndIf	

	//+----------------------------------------+
	//| EXPORTACAO DA NATUREZA DE OPERACAO SED |
	//+----------------------------------------+
	If lAuto//Via Schedule	
		If GetMV("ES_EXPSED") == 1
			cMsg += M010SEDExp(oProcess,lAuto)
		EndIf		
	Else//Via Menu	
		If MV_PAR34 == 1//1-Executa/2-Nao executa	
			cMsg += M010SEDExp(oProcess,lAuto)
		EndIf	
	EndIf
		

	//+-----------------------------------------+
	//| EXPORTACAO DA TABELA BASE DE ATENDIMENTO|
	//+-----------------------------------------+
	/*
	If lAuto//Via Schedule	
		If GetMV("ES_EXPAA3") == 1
			cMsg += M010AA3Exp(oProcess,lAuto)
		EndIf		
	Else//Via Menu	
		If MV_PAR35 == 1//1-Executa/2-Nao executa	
			cMsg += M010AA3Exp(oProcess,lAuto)
		EndIf	
	EndIf
    */  

	//+------------------------------------------------+
	//| EXPORTACAO DA TABELA DE SOLICITACAO AO ARMAZEM |
	//+------------------------------------------------+
	If lAuto//Via Schedule	
		If GetMV("ES_EXPSCP") == 1
			cMsg += M010SCPExp(oProcess,lAuto)
		EndIf		
	Else//Via Menu	
		If MV_PAR36 == 1//1-Executa/2-Nao executa	
			cMsg += M010SCPExp(oProcess,lAuto)
		EndIf	
	EndIf
	
	//+----------------------------------+
	//| EXPORTACAO DA TABELA DE TECNICOS |
	//+----------------------------------+
	If lAuto//Via Schedule	
		If GetMV("ES_EXPAA1") == 1
			cMsg += M010AA1Exp(oProcess,lAuto)
		EndIf		
	Else//Via Menu	
		If MV_PAR37 == 1//1-Executa/2-Nao executa	
			cMsg += M010AA1Exp(oProcess,lAuto)
		EndIf	
	EndIf			

	//+-----------------------------------------+
	//| EXPORTACAO DA TABELA DE CHAMADO TECNICO |
	//+-----------------------------------------+
	If lAuto//Via Schedule	
		If GetMV("ES_EXPAB1") == 1
			cMsg += M010AB1Exp(oProcess,lAuto)
		EndIf		
	Else//Via Menu	
		If MV_PAR38 == 1//1-Executa/2-Nao executa	
			cMsg += M010AB1Exp(oProcess,lAuto)
		EndIf	
	EndIf
		
	//+-------------------------------------------+
	//| EXPORTACAO DA TABELA DE ORCAMENTO TECNICO |
	//+-------------------------------------------+
	If lAuto//Via Schedule	
		If GetMV("ES_EXPAB3") == 1
			cMsg += M010AB3Exp(oProcess,lAuto)
		EndIf		
	Else//Via Menu	
		If MV_PAR39 == 1//1-Executa/2-Nao executa	
			cMsg += M010AB3Exp(oProcess,lAuto)
		EndIf	
	EndIf
			
	//+-------------------------------------------+
	//| EXPORTACAO DA TABELA DE REQUISICAO DE OS  |
	//+-------------------------------------------+
	If lAuto//Via Schedule	
		If GetMV("ES_EXPABF") == 1
			cMsg += M010ABFExp(oProcess,lAuto)
		EndIf		
	Else//Via Menu	
		If MV_PAR40 == 1//1-Executa/2-Nao executa	
			cMsg += M010ABFExp(oProcess,lAuto)
		EndIf	
	EndIf
	
	//+-------------------------------------------+
	//| EXPORTACAO DA TABELA DE ORDEM DE SERVICO  |
	//+-------------------------------------------+
	If lAuto//Via Schedule	
		If GetMV("ES_EXPAB6") == 1
			cMsg += M010AB6Exp(oProcess,lAuto)
		EndIf		
	Else//Via Menu	
		If MV_PAR41 == 1//1-Executa/2-Nao executa	
			cMsg += M010AB6Exp(oProcess,lAuto)
		EndIf	
	EndIf	
	
	//+-------------------------------------+
	//| EXPORTACAO DA TABELA DE MOEDAS		|
	//+-------------------------------------+
	If lAuto//Via Schedule	
		If GetMV("ES_EXPMOE") == 1
			cMsg += M010MOEExp(oProcess,lAuto)
		EndIf		
	Else//Via Menu	
		If MV_PAR42 == 1//1-Executa/2-Nao executa	
			cMsg += M010MOEExp(oProcess,lAuto)
		EndIf	
	EndIf					
				  
	
	
	//+-------------------------------------+
	//| EXPORTACAO DA TABELA DE COMODATOS	|
	//+-------------------------------------+
	If lAuto//Via Schedule	
		If GetMV("ES_EXPZ30") == 1
			cMsg += M010Z30Exp(oProcess,lAuto)
		EndIf		
	Else//Via Menu	
		If MV_PAR43 == 1//1-Executa/2-Nao executa	
			cMsg += M010Z30Exp(oProcess,lAuto)
		EndIf	
	EndIf
	
	
	//+---------------------------------------------+
	//| EXPORTACAO DA TABELA DE Fechamento Estoque	|
	//+---------------------------------------------+
	If lAuto//Via Schedule	
		If GetMV("ES_EXPFEC") == 1
			cMsg += M010FechaEstoque(oProcess,lAuto)
		EndIf		
	Else//Via Menu	
		If MV_PAR44 == 1//1-Executa/2-Nao executa	
			cMsg += M010FechaEstoque(oProcess,lAuto)
		EndIf	
	EndIf
	
	//+---------------------------------------------+
	//| EXPORTACAO DA TABELA DE INVENTARIO			|
	//+---------------------------------------------+
	If lAuto //Via Schedule	
		If GetMV("ES_EXPINV") == 1
			cMsg += M010InvOn(oProcess,lAuto)
		EndIf		
	Else    //Via Menu	
		If MV_PAR45 == 1//1-Executa/2-Nao executa	
			cMsg += M010InvOn(oProcess,lAuto)
		EndIf	
	EndIf
	
	
	//+---------------------------------------------+
	//| Matriz de Reposicao							|
	//+---------------------------------------------+
	If lAuto //Via Schedule	
		If GetMV("ES_EXPAZ5") == 1
			cMsg += M010ZA5Exp(oProcess,lAuto)
		EndIf		
	Else    //Via Menu	
		If MV_PAR46 == 1//1-Executa/2-Nao executa	
			cMsg += M010ZA5Exp(oProcess,lAuto)
		EndIf	
	EndIf
	
	
	
	//+------------------------------------+
	//| EXPORTACAO DO ARQUIVO ZIP PARA FTP |
	//+------------------------------------+	
	If lAuto//Se for via schedule
		If GetMV("ES_EXPFTP")
	   		cMsg +=	M010FTP(oProcess, "extracao.zip", lAuto )//Envia o arquivo para o FTP
		EndIf
	Else//Se for rotina manual
		If MV_PAR01 == 1//Faz o Upload do arquivo para o FTP
			cMsg += M010FTP(oProcess, "extracao.zip", lAuto )//Envia o arquivo para o FTP
		EndIf
	EndIf
	
									
	//---- Finalização ----
	If !lAuto
		Aviso( "Exportacao finalizada.", cMsg, {"OK"},3)
		oProcess:SaveLog("Fim da Execucao Total")
	EndIf
   	   		        		
Return



/*
|============================================================================|
|============================================================================|
|||-----------+----------+-------+-----------------------+------+----------|||
||| Funcao    |M010ZA5Exp| Autor | Ednei Silva           | Data |02/11/2020|||
|||-----------+----------+-------+-----------------------+------+----------|||
||| Descricao | Processa a Extracao Matriz Reposicao consignado Permanente |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   | M010ZA5Exp(ExpO01,ExpL01)                                  |||
|||-----------+------------------------------------------------------------|||
||| Parametros|ExpO01 - Objeto do TnewProcess                              |||
|||           |Expl01 - Indica se era gerado pela rotina automatica        |||
|||-----------+------------------------------------------------------------|||
||| Retorno   |                                                            |||
|||-----------+------------------------------------------------------------|||
|============================================================================|
|============================================================================|*/
Static Function M010ZA5Exp(oProcess,lAuto)

Local cAliasT	:= GetNextAlias()
Local cQuery 	:= ""
Local cMsg 	   	:= ""
Local cExtracao	:= DtoC( Date() ) + " - " + Time()
Local nCont	   	:= 0
Local nHandle	:= 0
Local nX	    := 0
Local nNumRec   := 0

If !lAuto
	oProcess:SaveLog("Inicio da Extração da Matriz de Reposicao)")
	oProcess:SetRegua1( 0 )
Else
	ConOut("Inicio da Extracao da Tabela de Matriz de Reposicao - SCHEDULE")
EndIf
U_MAH0179A()	
cQuery := " SELECT  	"
cQuery += " ZA5.ZA5_FILIAL, " 
cQuery += " ZA5.ZA5_CLI, "  
cQuery += " ZA5.ZA5_LOJA, 	" 
cQuery += " ZA5.ZA5_CLINOM, 	"
cQuery += " ZA5.ZA5_QTDPRV, 	"
cQuery += " ZA5.ZA5_QTDATU, 	"
cQuery += " ZA5.ZA5_QTDREP, 	"
cQuery += " ZA5.ZA5_CODVEN, "
cQuery += " ZA5.ZA5_NOMVEN,   "
cQuery += " ZA5.ZA5_TOTCUS,   "
cQuery += " ZA5.ZA5_TOTVEN,  "  
cQuery += " ZA5.ZA5_CODPRO, "
cQuery += " ZA5.ZA5_NOMPRO, "
cQuery += " ZA5.ZA5_AUDITO, "
cQuery += " ZA5.ZA5_FONTE "
cQuery += " FROM " + RetSQLName("ZA5") + " ZA5 "
cQuery += " WHERE ZA5.D_E_L_E_T_ <>'*'"

cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T. )

If ( cAliasT )->( !Eof() )
	
	nHandle := fCreate("\m010Exporta\MATRIZREPOSICAO_ZA5.csv", FC_NORMAL)
	
	//Titulo das colunas do arquivo
	FWRITE(	nHandle,"MATRIZREPOSICAO_KEY"		+ ";" + ;	
				" ZA5_FILIAL"   + ";" + ;
				" ZA5_CLI"   	+ ";" + ;
				" ZA5_LOJA"     + ";" + ;
				" ZA5_CLINOM"   + ";" + ;
				" ZA5_QTDPRV"   + ";" + ;
				" ZA5_QTDATU"   + ";" + ;
				" ZA5_QTDREP"   + ";" + ;
				" ZA5_CODVEN"   + ";" + ;
				" ZA5_NOMVEN"   + ";" + ;
				" ZA5_TOTCUS"   + ";" + ;
				" ZA5_TOTVEN"   + ";" + ;
				" ZA5_CODPRO"   + ";" + ;
				" ZA5_NOMPRO"   + ";" + ;
				" ZA5_AUDITO"   + ";" + ;
				" ZA5_FONTE "   + ";" + ;
				"PRODUTO_KEY"	+ ";" + ;			       		
			    "CLIENTE_KEY"   + ";" + ;
			    "VENDEDOR_KEY"	+ ";" + ;
				"DATA_EXTRACAO"	 + CRLF )

	
	nCont++
	nNumRec   := 0
	While ( cAliasT )->( !Eof() )
		
		FWRITE(	nHandle,AllTrim( ( cAliasT )->ZA5_FILIAL)  + AllTrim( ( cAliasT )->ZA5_CLI) + AllTrim( ( cAliasT )->ZA5_LOJA) + ";" + ;
		AllTrim( ( cAliasT )->ZA5_FILIAL)		          		   							+ ";" + ;
		AllTrim( ( cAliasT )->ZA5_CLI)		          		   							    + ";" + ;
		AllTrim( ( cAliasT )->ZA5_LOJA )		          		   							+ ";" + ;
		AllTrim( ( cAliasT )->ZA5_CLINOM )		          									+ ";" + ;
		AllTrim( Str( ( cAliasT )->ZA5_QTDPRV )) 		          							+ ";" + ;
		AllTrim( Str( ( cAliasT )->ZA5_QTDATU )) 	          								+ ";" + ;
		AllTrim( Str( ( cAliasT )->ZA5_QTDREP )) 		          							+ ";" + ;
		AllTrim( ( cAliasT )->ZA5_CODVEN )		          									+ ";" + ;
		AllTrim( ( cAliasT )->ZA5_NOMVEN )		       			    						+ ";" + ;
		AllTrim( Str( ( cAliasT )->ZA5_TOTCUS )) 		          		   					+ ";" + ;
		AllTrim( Str( ( cAliasT )->ZA5_TOTVEN ))	         		    					+ ";" + ;
		AllTrim( ( cAliasT )->ZA5_CODPRO )	     	          								+ ";" + ;
		AllTrim( ( cAliasT )->ZA5_NOMPRO )		          	  		   						+ ";" + ;
		AllTrim( ( cAliasT )->ZA5_AUDITO )		              								+ ";" + ;
		AllTrim( ( cAliasT )->ZA5_FONTE )		          									+ ";" + ;
		AllTrim( xFilial("SB1") ) + AllTrim( ( cAliasT )->ZA5_CODPRO)	+ ";" + ;
		AllTrim( xFilial("SA1") ) + AllTrim( ( cAliasT )->ZA5_CLI ) 	+ AllTrim( ( cAliasT )->ZA5_LOJA ) + ";" + ;
		AllTrim( xFilial("SA3") ) + AllTrim( ( cAliasT )->ZA5_CODVEN )	+ ";" + ;
		cExtracao + CRLF )
		nCont++
		( cAliasT )->( dbSkip() )
	EndDo
	
	cMsg += "Registros exportados da Tabela de Matriz de reposicao ZA5 : " + cValToChar( nCont ) + CRLF
	
EndIf

( cAliasT )->( dbCloseArea() )

fClose( nHandle )

If !lAuto
	oProcess:SaveLog( "Fim da Exportacaoda Tabela de Matriz de reposicao ZA5 " )
EndIf

Return( cMsg )






/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ M010SB6Exp ³ Autor ³ Denis Rodrigues  ³ Data ³  13/03/2017 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Processa a exportacao da Tabela Poder de terceiros SB6     ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function M010InvOn(oProcess,lAuto)

	Local cAliasT		:= GetNextAlias()
	Local cQuery 		:= ""
	Local cMsg 		:= ""
	Local cExtracao	:= DtoC( Date() ) + " - " + Time()
	Local cChvCli		:= ""
	Local cChvFor		:= ""
	Local nCont		:= 0
	Local nHandle		:= 0

	If !lAuto		
		oProcess:SaveLog("Inicio da Exportacao da Tabela App Inventario (ZA3)")
		oProcess:SetRegua1( 0 )
	Else
		ConOut("Inicio da Exportacao da Tabela App Inventario (ZA3) - SCHEDULE")	
	EndIf
	
	
	
	cQuery := " SELECT "   	 
	cQuery += " ZA3.ZA3_FILIAL, " 
	cQuery += " ZA3.ZA3_COD, "   
	cQuery += " B1_TIPO, "   
	cQuery += " B1_GRUPO, "  
	cQuery += " B1_MARCA, "  
	cQuery += " ZA3.ZA3_DOC,  "  
	cQuery += " ZA3.ZA3_QUANT,  "
	cQuery += " ZA3.ZA3_DATA , "  
	cQuery += " ZA3.ZA3_LOTECT, "
	cQuery += " ZA3.ZA3_NUMSER,  "
	cQuery += " ZA3.ZA3_LOCAL, "
	cQuery += " ZA3.ZA3_DTVALI, "
	cQuery += " ZA3.ZA3_FORNEC, "
	cQuery += " ZA3.ZA3_LOJA, "  
	cQuery += " ZA3.ZA3_VENDED, "
	cQuery += " ZA3.ZA3_LONG,  " 
	cQuery += " ZA3.ZA3_LATI,  " 
	cQuery += " ZA3.ZA3_IDINV,  "
	cQuery += " ZA3.ZA3_SLDSB6,  "
	cQuery += " ZA3.R_E_C_N_O_ ZA3_ID  "
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
	cQuery += " GZA3.ZA3_COD=ZA3.ZA3_COD AND   "
	cQuery += " GZA3.ZA3_LOTECT= ZA3.ZA3_LOTECT AND "
	cQuery += " GZA3.ZA3_NUMSER = ZA3.ZA3_NUMSER AND  "
	cQuery += " GZA3.ZA3_LOCAL = ZA3.ZA3_LOCAL AND "
	cQuery += " GZA3.ZA3_DTVALI = ZA3.ZA3_DTVALI AND "
	cQuery += " GZA3.ZA3_FORNEC = ZA3.ZA3_FORNEC AND "
	cQuery += " GZA3.ZA3_LOJA = ZA3.ZA3_LOJA AND "
	cQuery += " GZA3.ZA3_DATA = ZA3.ZA3_DATA AND "
	cQuery += " GZA3.ZA3_ID = ZA3.R_E_C_N_O_)	"	
	
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T. )	
	If ( cAliasT )->( !Eof() )
	
		nHandle := fCreate("\m010Exporta\inventario_app_za3.csv", FC_NORMAL)

		//Titulo das colunas do arquivo
		FWRITE(	nHandle, "APPINVENTARIO_KEY"	+ "|" + ;
			       		 "DOCUMENTO_ZA3"		+ "|" + ;
			       		 "TIPO_ZA3"			    + "|" + ;
			       		 "MARCA_ZA3"			+ "|" + ;
			       		 "QUANTIDADE_ZA3"		+ "|" + ;
			       		 "DATA_ZA3"				+ "|" + ;
			       		 "LOTE_ZA3"	    		+ "|" + ;
			       		 "SERIE_ZA3"	        + "|" + ;
			       		 "VALIDADE_ZA3"	        + "|" + ;
			       		 "LATITUDE_ZA3"	        + "|" + ;
			       		 "LONGITUDE_ZA3"	    + "|" + ;
			       		 "GEO_ZA3"	            + "|" + ;
			       		 "LOG_INVENTARIO_ZA3"	+ "|" + ;
			       		 "PRODUTO_KEY"			+ "|" + ;			       		
			       		 "ARMAZEM_KEY"			+ "|" + ;
			       		 "ESTABELECIMENTO_KEY"	+ "|" + ;
			       		 "CLIENTE_KEY"          + "|" + ;
			       		 "VENDEDOR_KEY"			+ "|" + ;
						  "SALDO3_ZA3"			+ "|" + ;	
			       		 "DATA_EXTRACAO"		+ CRLF )
		nCont++
			
		While ( cAliasT )->( !Eof() )

			If !lAuto
				oProcess:IncRegua1("Exportando Tabela de Inventario..." )
			EndIf
			
							
			FWRITE(	nHandle,	( cAliasT )->ZA3_FILIAL + Str(( cAliasT )->ZA3_ID) + "|" + ;
			       			AllTrim( ( cAliasT )->ZA3_DOC )							+ "|" + ;
			       			AllTrim( ( cAliasT )->B1_TIPO )							+ "|" + ;
			       			AllTrim( ( cAliasT )->B1_MARCA )							+ "|" + ;
			       			AllTrim( Str( ( cAliasT )->ZA3_QUANT ) )							+ "|" + ;
			       			If( Empty( ( cAliasT )->ZA3_DATA)	,"",AllTrim( DtoC( StoD( ( cAliasT )->ZA3_DATA ) ) ) ) 	+ "|" + ;
			       			AllTrim( ( cAliasT )->ZA3_LOTECT )							+ "|" + ;
			       			AllTrim( ( cAliasT )->ZA3_NUMSER )								+ "|" + ;
			       			If( Empty( ( cAliasT )->ZA3_DTVALI)	,"",AllTrim( DtoC( StoD( ( cAliasT )->ZA3_DTVALI ) ) ) ) 	+ "|" + ;
			       			AllTrim( ( cAliasT )->ZA3_LATI )								+ "|" + ;
			       			AllTrim( ( cAliasT )->ZA3_LONG )						   		+ "|" + ;			       			
			       			AllTrim( AllTrim(( cAliasT )->ZA3_LATI )+";"+AllTrim(( cAliasT )->ZA3_LONG )) + "|" + ;
			       			AllTrim( ( cAliasT )->ZA3_IDINV )							+ "|" + ;
			       			AllTrim( xFilial("SB1") ) + AllTrim( ( cAliasT )->ZA3_COD )	+ "|" + ;
			       			AllTrim( ( cAliasT )->ZA3_FILIAL ) + AllTrim( ( cAliasT )->ZA3_LOCAL )	+ "|" + ;
			       			AllTrim( ( cAliasT )->ZA3_FILIAL)							+ "|" + ;
			       			AllTrim( xFilial("SA1") ) + AllTrim( ( cAliasT )->ZA3_FORNEC ) 	+ AllTrim( ( cAliasT )->ZA3_LOJA ) + "|" + ;
			       			AllTrim( xFilial("SA3") ) + AllTrim( ( cAliasT )->ZA3_VENDED )	+ "|" + ;
							AllTrim( Str( ( cAliasT )->ZA3_SLDSB6 ) )							+ "|" + ;   
			       			cExtracao + CRLF )
		       			
			nCont++			       		
	
			( cAliasT )->( dbSkip() )
		
		EndDo

		cMsg += "Registros exportados da Tabela App Inventario (ZA3): " + cValToChar( nCont ) + CRLF
		
		fClose( nHandle )		
	
	EndIf
		
	If !lAuto
		oProcess:SaveLog( "Fim da Exportacao da Tabela App Inventario (ZA3)" )
	EndIf
		
Return( cMsg )




/*
|============================================================================|
|============================================================================|
|||-----------+----------+-------+-----------------------+------+----------|||
||| Funcao    |M010Z80Exp| Autor | Ednei Silva           | Data |22/04/2019|||
|||-----------+----------+-------+-----------------------+------+----------|||
||| Descricao | Processa a Extracao do Historico de clientes Z80		   |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   | M010Z80Exp(ExpO01,ExpL01)                                  |||
|||-----------+------------------------------------------------------------|||
||| Parametros|ExpO01 - Objeto do TnewProcess                              |||
|||           |Expl01 - Indica se era gerado pela rotina automatica        |||
|||-----------+------------------------------------------------------------|||
||| Retorno   |                                                            |||
|||-----------+------------------------------------------------------------|||
|============================================================================|
|============================================================================|*/
Static Function M010Z80Exp(oProcess,lAuto)

Local cAliasT	:= GetNextAlias()
Local cQuery 	:= ""
Local cMsg 	   	:= ""
Local cExtracao	:= DtoC( Date() ) + " - " + Time()
Local nCont	   	:= 0
Local nHandle	:= 0
Local nX	    := 0
Local nNumRec   := 0

If !lAuto
	oProcess:SaveLog("Inicio da Extração da Tabela de Comodatos (Z80)")
	oProcess:SetRegua1( 0 )
Else
	ConOut("Inicio da Extracao da Tabela de historico de clientes (Z80) - SCHEDULE")
EndIf

cQuery := " SELECT  	"
cQuery += " Z80.Z80_FILIAL, "  
cQuery += " Z80.Z80_ID, 	" 
cQuery += " Z80.Z80_DATA, 	"
cQuery += " Z80.Z80_HORA, 	"
cQuery += " Z80.Z80_HFIM, 	"
cQuery += " Z80.Z80_USER, 	"
cQuery += " Z80.Z80_CLIENT, "
cQuery += " Z80.Z80_LOJA,   "
cQuery += " Z80.Z80_CNPJ,   "
cQuery += " Z80.Z80_PRIORI, "
cQuery += " Z80.Z80_TPCONT, "
cQuery += " Z80.Z80_SOLI01, "
cQuery += " Z80.Z80_SOLI02, "
cQuery += " Z80.Z80_SOLU01, "
cQuery += " Z80.Z80_SOLU02, "
cQuery += " Z80.Z80_CODVEN, "
cQuery += " Z80.Z80_NOME,   "
cQuery += " Z80.Z80_EMAIL,  "
cQuery += " Z80.Z80_OPP,    "
cQuery += " Z80.Z80_DTFECH, "
cQuery += " Z80.Z80_TEL,    "
cQuery += " Z80.Z80_CONTAC, "
cQuery += " Z80.Z80_OBS,    "
cQuery += " Z80.Z80_CAMPAN, "
cQuery += " Z80.Z80_DESCAM, "
cQuery += " Z80.Z80_MOTIVO  "
cQuery += " FROM " + RetSQLName("Z80") + " Z80 "
cQuery += " WHERE Z80.D_E_L_E_T_ <>'*'"

cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T. )

If ( cAliasT )->( !Eof() )
	
	nHandle := fCreate("\m010Exporta\historico_z80.csv", FC_NORMAL)
	
	//Titulo das colunas do arquivo
	FWRITE(	nHandle,"COMODATO_KEY"		+ ";" + ;	
	"Z80.Z80_FILIAL" + ";" + ;
	"Z80.Z80_DATA"   + ";" + ;
	"Z80.Z80_HORA"   + ";" + ;
	"Z80.Z80_HFIM"   + ";" + ;
	"Z80.Z80_USER"   + ";" + ;
	"Z80.Z80_PRIORI" + ";" + ;	
	"Z80.Z80_TPCONT" + ";" + ;
	"Z80.Z80_SOLI01" + ";" + ;
	"Z80.Z80_SOLI02" + ";" + ;
	"Z80.Z80_SOLU01" + ";" + ;
	"Z80.Z80_SOLU02" + ";" + ;
	"Z80.Z80_EMAIL"  + ";" + ;
	"Z80.Z80_OPP"    + ";" + ;
	"Z80.Z80_DTFECH" + ";" + ;
	"Z80.Z80_TEL"    + ";" + ;
	"Z80.Z80_CONTAC" + ";" + ;
	"Z80.Z80_OBS"    + ";" + ;
	"Z80.Z80_MOTIVO" + ";" + ;	
	"CLIENTE_KEY"	 + ";" + ;
	"CAMPANHA_KEY"	 + ";" + ;
	"VENDEDOR_KEY"	 + ";" + ;
	"DATA_EXTRACAO"	 + CRLF )

	
	nCont++
	nNumRec   := 0
	While ( cAliasT )->( !Eof() )
		
		FWRITE(	nHandle,AllTrim( ( cAliasT )->Z80_FILIAL)  + AllTrim( ( cAliasT )->Z80_ID)  + ";" + ;
		AllTrim( DtoS( Stod( ( cAliasT )->Z80_DATA ) ) )  		   							+ ";" + ;
		AllTrim( ( cAliasT )->Z80_HORA )		          		   							+ ";" + ;
		AllTrim( ( cAliasT )->Z80_HFIM )		          		   							+ ";" + ;
		AllTrim( ( cAliasT )->Z80_USER )		          		   							+ ";" + ;
		AllTrim( ( cAliasT )->Z80_PRIORI )		          									+ ";" + ;
		AllTrim( ( cAliasT )->Z80_TPCONT )		          									+ ";" + ;
		AllTrim( ( cAliasT )->Z80_SOLI01 )		          									+ ";" + ;
		AllTrim( ( cAliasT )->Z80_SOLI02 )		          									+ ";" + ;
		AllTrim( ( cAliasT )->Z80_SOLU01 )		          									+ ";" + ;
		AllTrim( ( cAliasT )->Z80_SOLU02 )		       			    						+ ";" + ;
		AllTrim( ( cAliasT )->Z80_NOME )		          		   							+ ";" + ;
		AllTrim( ( cAliasT )->Z80_EMAIL )		          		    						+ ";" + ;
		AllTrim( ( cAliasT )->Z80_OPP )	     	          									+ ";" + ;
		AllTrim( DtoS( Stod( ( cAliasT )->Z80_DTFECH ) ) )									+ ";" + ;
		AllTrim( ( cAliasT )->Z80_TEL )		          	  		   							+ ";" + ;
		AllTrim( ( cAliasT )->Z80_OBS )		              									+ ";" + ;
		AllTrim( ( cAliasT )->Z80_CAMPAN )		          									+ ";" + ;
		AllTrim( ( cAliasT )->Z80_MOTIVO )		          									+ ";" + ;
		AllTrim( ( cAliasT )->Z80_FILIAL+( cAliasT )->Z80_CLIENT +( cAliasT )->Z80_LOJA )	+ ";" + ;
		AllTrim( ( cAliasT )->Z80_CAMPAN) 				  									+ ";" + ;
		AllTrim( ( cAliasT )->Z80_FILIAL+( cAliasT )->Z80_CODVEN) 							+ ";" + ;
		cExtracao + CRLF )
		nCont++
		( cAliasT )->( dbSkip() )
	EndDo
	
	cMsg += "Registros exportados da Tabela de historico Z80 : " + cValToChar( nCont ) + CRLF
	
EndIf

( cAliasT )->( dbCloseArea() )

fClose( nHandle )

If !lAuto
	oProcess:SaveLog( "Fim da Exportação da Tabela de Historico Z80 " )
EndIf

Return( cMsg )







//-----------------




/*
|============================================================================|
|============================================================================|
|||-----------+----------+-------+-----------------------+------+----------|||
||| Funcao    |M010Z30Exp| Autor | Ednei Silva           | Data |15/01/2019|||
|||-----------+----------+-------+-----------------------+------+----------|||
||| Descricao | Processa a Fechamento Estoque							   |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   | M010FechaEstoque(ExpO01,ExpL01)                            |||
|||-----------+------------------------------------------------------------|||
||| Parametros|ExpO01 - Objeto do TnewProcess                              |||
|||           |Expl01 - Indica se era gerado pela rotina automatica        |||
|||-----------+------------------------------------------------------------|||
||| Retorno   |                                                            |||
|||-----------+------------------------------------------------------------|||
|============================================================================|
|============================================================================|*/

Static Function M010FechaEstoque(oProcess,lAuto)

Local cAliasT	:= GetNextAlias()
Local cQuery 	:= ""
Local cMsg 	   	:= ""
Local cDtValid  := ""
Local cExtracao	:= DtoC( Date() ) + " - " + Time()
Local nCont	   	:= 0
Local nHandle	:= 0
Local nX	    := 0
Local nNumRec   := 0

If !lAuto
	oProcess:SaveLog("Inicio da Extração Fechamento de Estoque")
	oProcess:SetRegua1( 0 )
Else
	ConOut("Inicio da Extracao Fechamento de Estoque - SCHEDULE")
EndIf




cQuery := " SELECT BJ_FILIAL,"
cQuery += "        BJ_LOCAL,"
cQuery += "        BJ_DATA,"
cQuery += "        BJ_DTVALID,"
cQuery += "        B1_COD ,"
cQuery += "        B1_DESC,"
cQuery += "        BJ_LOTECTL,"
cQuery += "		   BJ_NUMLOTE," 
cQuery += "        B1_MARCA,"
cQuery += "        B1_DESCMAR,"
cQuery += "        BJ_QINI      BJ_QINI,"
cQuery += "        SUM(B9_CM1)  B2_CM1,"
cQuery += "        SUM(B9_CM1*BJ_QINI) BJ_CUSTOT, "

cQuery += "       (SELECT COUNT(*) " 

cQuery += "	      FROM " + RetSqlName("SBJ") + " SBJ2 "  

cQuery += "	      WHERE "    
cQuery += "       SBJ2.D_E_L_E_T_    <>'*' "    
cQuery += " 	  AND SBJ2.BJ_QINI    >0   "
cQuery += "       AND SBJ2.BJ_COD     =SB1.B1_COD  "
cQuery += "       AND SBJ2.BJ_FILIAL  =SBJPAI.BJ_FILIAL  "
cQuery += "       AND SBJ2.BJ_LOTECTL =SBJPAI.BJ_LOTECTL " 
cQuery += "       AND SBJ2.BJ_LOCAL   =SBJPAI.BJ_LOCAL   " 
cQuery += "       AND SBJ2.BJ_DTVALID =SBJPAI.BJ_DTVALID " 

cQuery += "       AND SBJ2.BJ_DATA>= CONVERT( char, convert(DATE,CAST(DATEADD(MONTH, -5,SBJPAI.BJ_DATA) AS DATE), 112 ), 112 ) AND SBJ2.BJ_DATA<=SBJPAI.BJ_DATA AND SBJ2.D_E_L_E_T_<>'*') AS BJ_GIRO1, " 




cQuery += "        (SELECT ISNULL(SUM(D2_QUANT),0) FROM SF2010 AS SF2 "
cQuery += "        INNER JOIN " + RetSqlName("SD2") + " SD2 ON (SF2.F2_DOC = SD2.D2_DOC AND SF2.F2_SERIE = SD2.D2_SERIE AND SF2.F2_FILIAL = SD2.D2_FILIAL    "
cQuery += "        AND SF2.F2_CLIENTE = SD2.D2_CLIENTE AND SF2.F2_LOJA = SD2.D2_LOJA AND SD2.D2_LOTECTL=SBJPAI.BJ_LOTECTL AND SD2.D2_LOCAL=SBJPAI.BJ_LOCAL "
cQuery += "        AND SD2.D2_COD=B1_COD AND SD2.D_E_L_E_T_<>'*' AND SD2.D2_DTVALID=SBJPAI.BJ_DTVALID AND SD2.D2_FILIAL=SBJPAI.BJ_FILIAL )          "
cQuery += "        INNER JOIN " + RetSqlName("SF4") + " SF4 ON (SD2.D2_TES= SF4.F4_CODIGO AND  SD2.D2_FILIAL= SF4.F4_FILIAL AND SF4.F4_BIOPERA='01' ) "
cQuery += "        WHERE " 
cQuery += "        D2_EMISSAO	  	  >= CONVERT( char, convert(DATE,CAST(DATEADD( month, -5,BJ_DATA) AS DATE), 112 ), 112 ) "	 
cQuery += "        AND		D2_EMISSAO	  <=BJ_DATA "	 
cQuery += "        AND		D2_ORIGLAN	  <> 'LF'   "
cQuery += "        AND		D2_TIPO		  <> 'D'    "
cQuery += "        AND		SF2.F2_FILIAL   = D2_FILIAL       "
cQuery += "        AND		SF2.F2_DOC      = SD2.D2_DOC      "
cQuery += "        AND		SF2.F2_SERIE    = SD2.D2_SERIE    "
cQuery += "        AND		SF2.F2_CLIENTE  = SD2.D2_CLIENTE  "
cQuery += "        AND		SF2.F2_LOJA     = SD2.D2_LOJA     "
cQuery += "        AND		SD2.D_E_L_E_T_  = '' "
cQuery += "        AND		SF2.D_E_L_E_T_  = '' "
cQuery += "        AND		SF4.D_E_L_E_T_  = '') AS BJ_GIRO6 "



cQuery += " FROM " + RetSQLName("SBJ") + " SBJPAI "
cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1 ON (SB1.B1_COD=SBJPAI.BJ_COD) "
cQuery += " INNER JOIN " + RetSqlName("SB9") + " SB9 ON (SB9.B9_COD=SBJPAI.BJ_COD AND SB9.B9_FILIAL=SBJPAI.BJ_FILIAL AND SB9.B9_LOCAL=SBJPAI.BJ_LOCAL AND SB9.B9_DATA=SBJPAI.BJ_DATA) "


cQuery += " WHERE     SB9.D_E_L_E_T_<>'*'   "
cQuery += " 	  AND SB1.D_E_L_E_T_<>'*'   "
cQuery += " 	  AND SBJPAI.D_E_L_E_T_<>'*'   "
cQuery += "       AND SBJPAI.BJ_QINI>0 "
cQuery += "       AND B9_QINI>0 "

cQuery += " GROUP BY "

cQuery += " BJ_FILIAL,  "
cQuery += " BJ_LOCAL,   "		
cQuery += " BJ_DATA,    "			
cQuery += " BJ_DTVALID, "
cQuery += " B1_COD,     "
cQuery += " B1_DESC,    " 
cQuery += " BJ_LOTECTL, "
cQuery += " BJ_NUMLOTE, "    
cQuery += " B1_MARCA,	"	
cQuery += " B1_DESCMAR,	"
cQuery += " BJ_QINI "	

cQuery += " ORDER BY BJ_FILIAL, BJ_DATA "

cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T. )

If ( cAliasT )->( !Eof() )
	
	nHandle := fCreate("\m010Exporta\FechamentoEstoque.csv", FC_NORMAL)
	
	//Titulo das colunas do arquivo
	FWRITE(	nHandle,"FECHAMENTOEST_KEY"		+ ";" + ;
	"FECHAMENTO_FILIAL"   					+ ";" + ;
	"FECHAMENTO_ARMAZEM"   					+ ";" + ;
	"FECHAMENTO_DTFECHAMENTO"				+ ";" + ;
	"FECHAMENTO_VALIDADE"					+ ";" + ;
	"FECHAMENTO_DTFECHAMENTOESTOQUE"		+ ";" + ;
	"FECHAMENTO_DTVALIDADELOTE"				+ ";" + ;
	"FECHAMENTO_PRODUTO"					+ ";" + ;
	"FECHAMENTO_DESCRICAO"					+ ";" + ;
	"FECHAMENTO_LOTE"						+ ";" + ;
	"FECHAMENTO_NUMLOTE"					+ ";" + ;
	"FECHAMENTO_MARCA"						+ ";" + ;
	"FECHAMENTO_DESCMARCA"					+ ";" + ;
	"FECHAMENTO_SALDOFECHAMENTO"			+ ";" + ;
	"FECHAMENTO_CUSTOUNITARIO"				+ ";" + ;
	"FECHAMENTO_CUSTOTOTAL"					+ ";" + ;
	"FECHAMENTO_GIRO1MES"					+ ";" + ;
	"FECHAMENTO_GIRO6MESES"					+ ";" + ;	
	"FECHAMENTO_PRODUTO_KEY"           		+ ";" + ;
	"FECHAMENTO_LOTE_KEY" 			 		+ ";" + ; 		
    "FECHAMENTO_ARMAZEM_KEY"			 	+ ";" + ; 
    "FECHAMENTO_SLD_SB2_KEY" + CRLF )
 	//"DATA_EXTRACAO"		+ CRLF )
	
	nCont++
	nNumRec   := 0
	While ( cAliasT )->( !Eof() )
            
			If !lAuto
				oProcess:IncRegua1("Exportando Tabela de Fechamento de Estoque..." )
			EndIf
			
			If  Year( StoD( ( cAliasT )->BJ_DTVALID ) ) > 2050
				cDtValid := "31/12/2050" 
			Else
				cDtValid := If( Empty( ( cAliasT )->BJ_DTVALID )	,"",AllTrim( DtoC( StoD( ( cAliasT )->BJ_DTVALID ) ) ) )
			EndIf
			
			FWRITE(	nHandle,AllTrim( ( cAliasT )->BJ_FILIAL ) + AllTrim( ( cAliasT )->BJ_DATA) + ( cAliasT )->B1_COD + ( cAliasT )->BJ_LOCAL + ( cAliasT )->BJ_DTVALID + ( cAliasT )->BJ_LOTECTL + ( cAliasT )->BJ_NUMLOTE + ";" + ;
			AllTrim( ( cAliasT )->BJ_FILIAL )  + ";" + ;
		    AllTrim( ( cAliasT )->BJ_LOCAL )  + ";" + ;
		    AllTrim( DtoC( Stod( ( cAliasT )->BJ_DATA ) ) )  + ";" + ;
			cDtValid + ";" + ;
			AllTrim( DtoC( Stod( ( cAliasT )->BJ_DATA ) ) )  + ";" + ;
			cDtValid + ";" + ;
			AllTrim( ( cAliasT )->B1_COD )		 + ";" + ;
			AllTrim( StrTran(( cAliasT )->B1_DESC ,";"," "))+ ";" + ;
			AllTrim( ( cAliasT )->BJ_LOTECTL)		 + ";" + ;
			AllTrim( ( cAliasT )->BJ_NUMLOTE)		 + ";" + ;
			AllTrim( ( cAliasT )->B1_MARCA )	     + ";" + ;
			AllTrim( StrTran(( cAliasT )->B1_DESCMAR ,";"," "))+ ";" + ;
			AllTrim( Transform(( cAliasT )->BJ_QINI,"@R 999999") ) + ";" + ;
			AllTrim( Transform(( cAliasT )->B2_CM1,"@R 999999999.99")) + ";" + ;
			AllTrim( Transform(( cAliasT )->BJ_CUSTOT,"@R 999999999.99")) + ";" + ;
			AllTrim( Transform(( cAliasT )->BJ_GIRO1,"@R 999999") ) + ";" + ;
			AllTrim( Transform(( cAliasT )->BJ_GIRO6,"@R 999999") ) + ";" + ;
			AllTrim(AllTrim(xFilial("SB1")) + AllTrim( ( cAliasT )->B1_COD )) 	+ ";" + ;
			AllTrim(( cAliasT )->BJ_FILIAL   + ( cAliasT )->B1_COD + ( cAliasT )->BJ_LOCAL + ( cAliasT )->BJ_DTVALID + ( cAliasT )->BJ_LOTECTL + ( cAliasT )->BJ_NUMLOTE) + ";" + ;
 			AllTrim(( cAliasT )->BJ_FILIAL ) + AllTrim( ( cAliasT )->BJ_LOCAL ) + ";" + ;   
			AllTrim(( cAliasT )->BJ_FILIAL  + ( cAliasT )->B1_COD +  ( cAliasT )->BJ_LOCAL)  + CRLF ) 
			//cExtracao + CRLF )
			nCont++
		
			       		
		( cAliasT )->( dbSkip() )
	EndDo
	
	cMsg += "Registros exportados da Tabela de Fechamento do Estoque : " + cValToChar( nCont ) + CRLF
	
EndIf

( cAliasT )->( dbCloseArea() )

fClose( nHandle )

If !lAuto
	oProcess:SaveLog( "Fim da Exportação da Tabela de Fechamento do Estoque " )
EndIf

Return( cMsg ) 





//-----------------




/*
|============================================================================|
|============================================================================|
|||-----------+----------+-------+-----------------------+------+----------|||
||| Funcao    |M010Z30Exp| Autor | Ednei Silva           | Data |12/03/2018|||
|||-----------+----------+-------+-----------------------+------+----------|||
||| Descricao | Processa a Extracao da tabela Comodadtos Z30			   |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   | M010Z30Exp(ExpO01,ExpL01)                                  |||
|||-----------+------------------------------------------------------------|||
||| Parametros|ExpO01 - Objeto do TnewProcess                              |||
|||           |Expl01 - Indica se era gerado pela rotina automatica        |||
|||-----------+------------------------------------------------------------|||
||| Retorno   |                                                            |||
|||-----------+------------------------------------------------------------|||
|============================================================================|
|============================================================================|*/
Static Function M010Z30Exp(oProcess,lAuto)

Local cAliasT	:= GetNextAlias()
Local cQuery 	:= ""
Local cMsg 	   	:= ""
Local cExtracao	:= DtoC( Date() ) + " - " + Time()
Local nCont	   	:= 0
Local nHandle	:= 0
Local nX	    := 0
Local nNumRec   := 0

If !lAuto
	oProcess:SaveLog("Inicio da Extracao da Tabela de Comodatos (Z30)")
	oProcess:SetRegua1( 0 )
Else
	ConOut("Inicio da Extracao da Tabela de Comodatos (Z30) - SCHEDULE")
EndIf

cQuery := " SELECT Z30.Z30_FILIAL,"
cQuery += "        Z30.Z30_CODGRU,"
cQuery += "        Z30.Z30_DESCRI,"
cQuery += "        Z30.Z30_CODCLI,"
cQuery += "        Z30.Z30_QUANT,"
cQuery += "        Z30.Z30_LOJA,"
cQuery += "        Z30.Z30_MARCA,"
cQuery += "        Z30.Z30_DESMAR,"
cQuery += "        Z30.Z30_NOME,"
cQuery += "        Z30.Z30_VALOR,"
cQuery += "        Z30.Z30_DTINIC,"
cQuery += "        Z30.Z30_QTDCOM,"
cQuery += "        Z30.Z30_PRVCOM," // ALTERADO DE Z30_PRVCOM PARA Z30_XQTDAJ EM 30/08/22 // CHAMADO 5065
cQuery += "        Z30.Z30_DTFIM "

cQuery += " FROM " + RetSQLName("Z30") + " Z30 "
cQuery += " WHERE Z30.D_E_L_E_T_ <>'*'"

cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T. )

If ( cAliasT )->( !Eof() )
	
	nHandle := fCreate("\m010Exporta\comodatos_z30.csv", FC_NORMAL)
	
	//Titulo das colunas do arquivo
	FWRITE(	nHandle,"COMODATO_KEY"		+ ";" + ;
	"Z30_FILIAL"   		+ ";" + ;
	"Z30_CODGRU"   		+ ";" + ;
	"Z30_DESCRI"		+ ";" + ;
	"Z30_CODCLI"		+ ";" + ;
	"Z30_LOJA"			+ ";" + ;
	"Z30_NOME"			+ ";" + ;
	"Z30_QUANT"			+ ";" + ;
	"Z30_MARCA"			+ ";" + ;
	"Z30_DESMAR"		+ ";" + ;
	"Z30_VALOR"			+ ";" + ;
	"Z30_DTINIC"		+ ";" + ;
	"Z30_QTDCOM"		+ ";" + ;
	"Z30_PRVCOM"		+ ";" + ;
	"CLIENTE_KEY"		+ ";" + ;
	"DATA_EXTRACAO"		+ CRLF )
	
	nCont++
	nNumRec   := 0
	While ( cAliasT )->( !Eof() )
		
	    nNumRec:=DateDiffMonth( sToD(( cAliasT )->Z30_DTINIC) , sToD(( cAliasT )->Z30_DTFIM)  ) 
		For nX:=0 to nNumRec
			FWRITE(	nHandle,AllTrim( ( cAliasT )->Z30_FILIAL ) + AllTrim( ( cAliasT )->Z30_CODCLI );
			+AllTrim( ( cAliasT )->Z30_LOJA   )+ AllTrim( DtoS( Stod( ( cAliasT )->Z30_DTINIC ) ) ) ;
		    +AllTrim( DtoS( Stod( ( cAliasT )->Z30_DTFIM ) ) )  + ";" + ;
			AllTrim( ( cAliasT )->Z30_FILIAL )		 + ";" + ;
			AllTrim( ( cAliasT )->Z30_CODGRU )		 + ";" + ;
			AllTrim( StrTran(( cAliasT )->Z30_DESCRI ,";"," "))+ ";" + ;
			AllTrim( ( cAliasT )->Z30_CODCLI )		 + ";" + ;
			AllTrim( ( cAliasT )->Z30_LOJA )	     + ";" + ;
			AllTrim( StrTran(( cAliasT )->Z30_NOME  ,";"," "))+ ";" + ;
			AllTrim( Str( ( cAliasT )->Z30_QUANT ) ) + ";" + ;
			AllTrim( ( cAliasT )->Z30_MARCA      )   + ";" + ;
			AllTrim( StrTran( (cAliasT )->Z30_DESMAR  ,";"," "))+ ";" + ;
			AllTrim( Str( ( cAliasT )->Z30_VALOR ) ) + ";" + ;
			AllTrim( DtoC( MonthSum(Stod( ( cAliasT )->Z30_DTINIC ),nX) ) ) + ";" + ;
			AllTrim( Str( ( cAliasT )->Z30_QTDCOM ))	     + ";" + ;
			AllTrim( Str( ( cAliasT )->Z30_PRVCOM ))	     + ";" + ;
			AllTrim( ( cAliasT )->Z30_CODCLI +( cAliasT )->Z30_LOJA )		+ ";" + ;
			cExtracao + CRLF )
			nCont++
		next nX
		( cAliasT )->( dbSkip() )
	EndDo
	
	cMsg += "Registros exportados da Tabela de Comodatos Z30 : " + cValToChar( nCont ) + CRLF
	
EndIf

( cAliasT )->( dbCloseArea() )

fClose( nHandle )

If !lAuto
	oProcess:SaveLog( "Fim da Exportacao da Tabela de Comodatos Z30 " )
EndIf

Return( cMsg )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ M010Cliente ³ Autor ³ Denis Rodrigues  ³ Data ³  06/10/2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Processa a exportacao do cadastro de clientes              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function M010Cliente(oProcess,lAuto)

	Local cAliasT	:= GetNextAlias()
	Local cQuery 	:= ""
	Local cMsg 		:= ""
	Local cDscTip	:= ""	
	Local cExtracao	:= DtoC( Date() ) + " - " + Time()
	Local nCont		:= 0
	Local nHandle	:= 0

	aSldCli()
	
	If !lAuto		
		oProcess:SaveLog("Inicio da Exportacao da Tabela de Clientes (SA1)")
		oProcess:SetRegua1( 0 )	
	Else
		ConOut("Inicio da Exportacao da Tabela de Clientes (SA1) - SCHEDULE")
	EndIf
	
	cQuery := " SELECT A1_FILIAL,"
	cQuery += "        A1_COD,"
	cQuery += "        A1_LOJA,"
	cQuery += "        A1_NOME,"
	cQuery += "        A1_TIPO,"
	cQuery += "        A1_EST,"
	cQuery += "        A1_MUN, "
	cQuery += "    	   A1_SALPEDL, "
	cQuery += "        A1_LC, "
	cQuery += "        A1_CGC, "
	cQuery += "        A1_ZLCREM, "
	cQuery += "        A1_ZSALREM, "
	cQuery += "        A1_SALDUP, "
	cQuery += "    	   A1_SALPED "
	cQuery += " FROM " + RetSQLName("SA1")
	cQuery += " WHERE D_E_L_E_T_<>'*'"
	cQuery += " ORDER BY A1_FILIAL, A1_COD, A1_LOJA"
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T. )
	
	If ( cAliasT )->( !Eof() )
	
		nHandle := fCreate("\m010Exporta\clientes_sa1.csv", FC_NORMAL)
	
		//Titulo das colunas do arquivo
		FWRITE(	nHandle, "CLIENTE_KEY"		+ ";" + ;
			       		"A1_FILIAL" 		+ ";" + ;
			       		"A1_COD" 			+ ";" + ;
			       		"A1_LOJA"			+ ";" + ;
			       		"A1_NOME"			+ ";" + ;
			       		"A1_TIPO"			+ ";" + ;
			       		"A1_DESCTIPO"		+ ";" + ;
			       		"A1_EST"			+ ";" + ;
			       		"A1_MUN"			+ ";" + ;
			       		"A1_SALPEDL"        + ";" + ;
			      		"A1_LC"				+ ";" + ;	
			      		"A1_ZLCREM"         + ";" + ;
			      		"A1_ZSALREM"        + ";" + ; 
			      		"A1_SALDUP"         + ";" + ;
			      		"A1_SALPED"         + ";" + ;
			      		"A1_CGC"            + ";" + ;
			       		"DATA_EXTRACAO"	+ CRLF )
		nCont++			       		
	
		While ( cAliasT )->( !Eof() )
		
			If !lAuto
				oProcess:IncRegua1("Exportando Clientes..." )
			EndIf
			
			//Retorna a descricao do Tipo do cliente
			cDscTip := X3Combo( "A1_TIPO",( cAliasT )->A1_TIPO )
					
			FWRITE(	nHandle,	AllTrim( ( cAliasT )->A1_FILIAL ) + AllTrim( ( cAliasT )->A1_COD ) + AllTrim( ( cAliasT )->A1_LOJA ) + ";" + ;
			       			AllTrim( ( cAliasT )->A1_FILIAL ) 			+ ";" + ;
			       			AllTrim( ( cAliasT )->A1_COD )	  			+ ";" + ;
			       			AllTrim( ( cAliasT )->A1_LOJA )	  			+ ";" + ;
			       			AllTrim( ( cAliasT )->A1_NOME )	  			+ ";" + ;
			       			AllTrim( ( cAliasT )->A1_TIPO )	  			+ ";" + ;
			       			AllTrim( cDscTip )	  						+ ";" + ;
			       			AllTrim( ( cAliasT )->A1_EST )	 	 		+ ";" + ;
			       			AllTrim( ( cAliasT )->A1_MUN )	  			+ ";" + ;		
			       			AllTrim( Str( ( cAliasT )->A1_SALPEDL ) ) + ";" + ;
			       			AllTrim( Str( ( cAliasT )->A1_LC ) ) + ";" + ;
			       			AllTrim( Str( ( cAliasT )->A1_ZLCREM ) ) + ";" + ;
			       			AllTrim( Str( ( cAliasT )->A1_ZSALREM ) ) + ";" + ;
			       			AllTrim( Str( ( cAliasT )->A1_SALDUP ) ) + ";" + ;
			       			AllTrim( Str( ( cAliasT )->A1_SALPED ) ) + ";" + ;
			       			AllTrim( ( cAliasT )->A1_CGC )	  			+ ";" + ;
			       			cExtracao + CRLF )	       			
			nCont++
		
			( cAliasT )->( dbSkip() )
			
		EndDo
	
		cMsg += "Registros exportados do Cadastro de Clientes (SA1): " + cValToChar( nCont ) + CRLF
		
	EndIf
	
	( cAliasT )->( dbCloseArea() )
	
	fClose( nHandle )
	
	If !lAuto
		oProcess:SaveLog( "Fim da Exportacao da Tabela de Clientes (SA1)" )
	EndIf

Return( cMsg )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ M010Fornecedor ³ Autor ³Denis Rodrigues  ³ Data ³03/12/2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Processa a exportacao do cadastro de Fornecedores          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function M010Fornecedor(oProcess,lAuto)

	Local cAliasT	:= GetNextAlias()
	Local cQuery 	:= ""
	Local cMsg 		:= ""
	Local cDscTip	:= ""
	Local cExtracao	:= DtoC( Date() ) + " - " + Time()
	Local nCont		:= 0
	Local nHandle	:= 0

	If !lAuto		
		oProcess:SaveLog("Inicio da Exportacao da Tabela de Fornecedores (SA2)")
		oProcess:SetRegua1( 0 )	
	Else
		ConOut("Inicio da Exportacao da Tabela de Fornecedores (SA2) - SCHEDULE")
	EndIf
	
	cQuery := " SELECT A2_FILIAL,"
	cQuery += "        A2_COD,"
	cQuery += "        A2_LOJA,"
	cQuery += "        A2_NOME,"
	cQuery += "        A2_TIPO,"
	cQuery += "        A2_EST,"
	cQuery += "        A2_MUN"
	cQuery += " FROM " + RetSQLName("SA2")
	cQuery += " WHERE D_E_L_E_T_<>'*'"
	cQuery += " ORDER BY A2_FILIAL, A2_COD, A2_LOJA"
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T. )
	
	If ( cAliasT )->( !Eof() )
	
		nHandle := fCreate("\m010Exporta\fornecedores_sa2.csv", FC_NORMAL)
	
		//Titulo das colunas do arquivo
		FWRITE(	nHandle,"FORNECEDOR_KEY"	+ ";" + ;
			       		"A2_FILIAL" 		+ ";" + ;
			       		"A2_COD" 			+ ";" + ;
			       		"A2_LOJA"			+ ";" + ;
			       		"A2_NOME"			+ ";" + ;
			       		"A2_TIPO"			+ ";" + ;
			       		"A2_DESCTIPO"		+ ";" + ;
			       		"A2_EST"			+ ";" + ;
			       		"A2_MUN"			+ ";" + ;
			       		"DATA_EXTRACAO"	+ CRLF )
		nCont++			       		
	
		While ( cAliasT )->( !Eof() )
		
			If !lAuto
				oProcess:IncRegua1("Exportando Fornecedores..." )
			EndIf
			
			//Retorna a descricao do Tipo do fornecedor
			cDscTip := X3Combo( "A2_TIPO",( cAliasT )->A2_TIPO )
					
			FWRITE(	nHandle,	AllTrim( ( cAliasT )->A2_FILIAL ) + AllTrim( ( cAliasT )->A2_COD ) + AllTrim( ( cAliasT )->A2_LOJA )	+ ";" + ;
			       			AllTrim( ( cAliasT )->A2_FILIAL ) 	+ ";" + ;
			       			AllTrim( ( cAliasT )->A2_COD )	  	+ ";" + ;
			       			AllTrim( ( cAliasT )->A2_LOJA )	  	+ ";" + ;
			       			AllTrim( ( cAliasT )->A2_NOME )	  	+ ";" + ;
			       			AllTrim( ( cAliasT )->A2_TIPO )	  	+ ";" + ;
			       			AllTrim( cDscTip )	  				+ ";" + ;
			       			AllTrim( ( cAliasT )->A2_EST )	  	+ ";" + ;
			       			AllTrim( ( cAliasT )->A2_MUN )	  	+ ";" + ;		
			       			cExtracao + CRLF )	       			
			nCont++
		
			( cAliasT )->( dbSkip() )
			
		EndDo
	
		cMsg += "Registros exportados do Cadastro de Fornecedores (SA2): " + cValToChar( nCont ) + CRLF
		
	EndIf
	
	( cAliasT )->( dbCloseArea() )
	
	fClose( nHandle )
	
	If !lAuto
		oProcess:SaveLog( "Fim da Exportacao da Tabela de Fornecedores (SA2)" )
	EndIf
	
Return( cMsg )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ M010Vendedores ³ Autor ³ Denis Rodrigues ³ Data ³06/10/2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Processa a exportacao do cadastro de Vendedores            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function  M010Vendedores(oProcess,lAuto)

	Local cAliasT		:= GetNextAlias()
	Local cQuery		:= ""
	Local cMsg		:= ""
	Local cDscTip		:= ""
	Local cExtracao	:= DtoC( Date() ) + " - " + Time()
	Local nCont 		:= 0 
	Local nHandle		:= 0

	//+--------------------------------------+
	//| EXPORTACAO DO CADASTRO DE VENDEDORES |
	//+--------------------------------------+
	If !lAuto
		oProcess:SaveLog("Inicio da Exportacao da Tabela de Vendedores (SA3)")
		oProcess:SetRegua1( 0 )
	Else
		ConOut("Inicio da Exportacao da Tabela de Vendedores (SA3) - SCHEDULE")
	EndIf

	cQuery := " SELECT A3_FILIAL,"
	cQuery += "        A3_COD,"
	cQuery += "        A3_NOME,"
	cQuery += "        A3_EST,"
	cQuery += "        A3_MUN,"
	cQuery += "        A3_TIPO"
	cQuery += " FROM " + RetSQLName("SA3")
	cQuery += " WHERE D_E_L_E_T_<>'*'"
	cQuery += " ORDER BY A3_FILIAL, A3_COD"
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T. )
	
	If ( cAliasT )->( !Eof() )
	
		nHandle := fCreate("\m010Exporta\vendedores_sa3.csv", FC_NORMAL)
	
		//Titulo das colunas do arquivo
		FWRITE(	nHandle, "VENDEDOR_KEY"	+ ";" + ;
			       		"A3_FILIAL" 		+ ";" + ;
			       		"A3_COD" 			+ ";" + ;
			       		"A3_NOME"			+ ";" + ;
			       		"A3_EST"			+ ";" + ;
			       		"A3_MUN"			+ ";" + ;
			       		"A3_TIPO"			+ ";" + ;
			       		"A3_DESCTIPO"		+ ";" + ;
			       		"DATA_EXTRACAO"	+ CRLF )
		nCont++			       		
	
		While ( cAliasT )->( !Eof() )
		
			If !lAuto
				oProcess:IncRegua1("Exportando Vendedores..." )
			EndIf
			
			//Retorna a descricao do tipo
			cDscTip := X3Combo( "A3_TIPO",( cAliasT )->A3_TIPO ) 
					
			FWRITE(	nHandle, AllTrim( ( cAliasT )->A3_FILIAL ) + ( cAliasT )->A3_COD	+ ";" + ;
			       			AllTrim( ( cAliasT )->A3_FILIAL ) 				+ ";" + ;
			       			AllTrim( ( cAliasT )->A3_COD )	  				+ ";" + ;
			       			AllTrim( ( cAliasT )->A3_NOME )	  				+ ";" + ;
			       			AllTrim( ( cAliasT )->A3_EST )	  				+ ";" + ;
			       			AllTrim( ( cAliasT )->A3_MUN )	  				+ ";" + ;
			       			AllTrim( ( cAliasT )->A3_TIPO )	  				+ ";" + ;
			       			AllTrim( cDscTip )								+ ";" + ;
			       			cExtracao + CRLF )

			nCont++
		
			( cAliasT )->( dbSkip() )
			
		EndDo
	
		cMsg += "Registros exportados do Cadastro de Vendedores (SA3): " + cValToChar( nCont ) + CRLF
		
	EndIf
	
	( cAliasT )->( dbCloseArea() )
	
	fClose( nHandle )
	
	If !lAuto
		oProcess:SaveLog( "Fim da Exportacao da Tabela de Vendedores (SA3)" )
	EndIf

Return( cMsg )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ M010Produtos ³ Autor ³ Denis Rodrigues ³ Data ³  06/10/2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Exporta o cadastro de Produtos (SB1)                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente TOTVS RS                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function M010Produtos(oProcess,lAuto)

	Local cAliasT		:= GetNextAlias()
	Local cQuery 		:= ""
	Local cMsg		:= ""
	Local cDscGrp		:= ""
	Local cDscTip		:= ""
	Local cExtracao	:= DtoC( Date() ) + " - " + Time()
	Local nCont		:= 0
	Local nHandle		:= 0
	
	//+------------------------------------+
	//| EXPORTACAO DO CADASTRO DE PRODUTOS |
	//+------------------------------------+
	If !lAuto
		oProcess:SaveLog("Inicio da Exportacao da Tabela de Produtos (SB1)")
		oProcess:SetRegua1( 0 )
	Else
		ConOut("Inicio da Exportacao da Tabela de Produtos (SB1) - SCHEDULE")
	EndIf
	
	cQuery := " SELECT B1_FILIAL,"
	cQuery += "        B1_COD,"
	cQuery += "        B1_DESC,"
	cQuery += "        B1_TIPO,"
	cQuery += "        B1_LOCPAD,"
	cQuery += "        B1_GRUPO,"
	cQuery += "        B1_MARCA,"
	cQuery += "        SUBSTRING(B1_GRTRIB,1,3) AS B1_GRTRIB,"
	cQuery += "        B1_DESCMAR"
	cQuery += " FROM " + RetSQLName("SB1")
	cQuery += "   WHERE D_E_L_E_T_<>'*'"
	cQuery += " ORDER BY B1_FILIAL, B1_COD"
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T. )
	
	If ( cAliasT )->( !Eof() )
	
		nHandle := fCreate("\m010Exporta\produtos_sb1.csv", FC_NORMAL)
	
		//Titulo das colunas do arquivo
		FWRITE(	nHandle, "PRODUTO_KEY" 	+ ";" + ;
			       		"B1_FILIAL" 		+ ";" + ;
			       		"B1_COD" 			+ ";" + ;
			       		"B1_DESC"			+ ";" + ;
			       		"B1_TIPO"			+ ";" + ;
			       		"B1_DSCTIPO"		+ ";" + ;
			       		"B1_LOCPAD"		    + ";" + ;
			       		"B1_GRUPO"		    + ";" + ;
			       		"B1_DSCGRUPO"		+ ";" + ;
			       		"B1_MARCA"		    + ";" + ;
			       		"B1_DESCMAR"		+ ";" + ;
			       		"B1_GRTRIB"		    + ";" + ;
			       		"DATA_EXTRACAO"	+ CRLF )
		nCont++			       		
	
		While ( cAliasT )->( !Eof() )
		
			If !lAuto
				oProcess:IncRegua1("Exportando Produtos..." )
			EndIf
			
			//Busca a descricao do grupo de Produtos
			dbSelectArea("SBM")
			dbSetOrder(1)//BM_FILIAL+BM_GRUPO
			If dbSeek( xFilial("SBM") + ( cAliasT )->B1_GRUPO )
				cDscGrp := AllTrim( SBM->BM_DESC )
			EndIf
			
			//Busca a descricao do Tipo do Produto
			dbSelectArea("SX5")
			dbSetOrder(1)//X5_FILIAL+X5_TABELA+X5_CHAVE
			If dbSeek( xFilial("SX5") + "02" + ( cAliasT )->B1_TIPO )
				cDscTip := SX5->X5_DESCRI
			EndIf
			
			FWRITE(	nHandle, AllTrim( ( cAliasT )->B1_FILIAL ) + AllTrim( ( cAliasT )->B1_COD )	+ ";" + ;
			       			AllTrim( ( cAliasT )->B1_FILIAL ) 	+ ";" + ;
			       			AllTrim( ( cAliasT )->B1_COD )	  	+ ";" + ;
			       			AllTrim( ( cAliasT )->B1_DESC )	  	+ ";" + ;
			       			AllTrim( ( cAliasT )->B1_TIPO )	  	+ ";" + ;
			       			AllTrim( cDscTip )				  	+ ";" + ;
			       			AllTrim( ( cAliasT )->B1_LOCPAD ) 	+ ";" + ;
			       			AllTrim( ( cAliasT )->B1_GRUPO )  	+ ";" + ;
			       			AllTrim( cDscGrp )  				+ ";" + ;
			       			AllTrim( ( cAliasT )->B1_MARCA )	+ ";" + ;
			       			AllTrim( ( cAliasT )->B1_DESCMAR )	+ ";" + ;
			       			AllTrim( ( cAliasT )->B1_GRTRIB )	+ ";" + ;
			       			cExtracao	 + CRLF )

			nCont++
		
			( cAliasT )->( dbSkip() )
			
		EndDo
	
		cMsg += "Registros exportados do Cadastro de Produtos (SB1): " + cValToChar( nCont ) + CRLF
		
	EndIf
	
	( cAliasT )->( dbCloseArea() )
	
	fClose( nHandle )
	
	If !lAuto
		oProcess:SaveLog( "Fim da Exportacao da Tabela de Produtos (SB1)" )
	EndIf
    
Return( cMsg )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³M010PedidoVenda³ Autor ³ Denis Rodrigues ³ Data ³06/10/2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Exporta o Pedido de Venda (SC5 - SC6)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente TOTVS RS                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function M010PedidoVenda(oProcess,lAuto)

	Local cAliasT				:= GetNextAlias()
	Local cQuery 				:= ""
	Local cMsg	   				:= ""
	Local cStsPV	   			:= "" //Status do pedido de venda
	Local cExtracao				:= DtoC( Date() ) + " - " + Time()
	Local aDtEmis				:= StrTokArr( GetMV("TRS_M010PV"),"|" ) 
	Local nCont					:= 0
	Local nHandle				:= 0
	Local nDPREVISTO			:= 0
	Local nDEFETIVO				:= 0
	Local nSPREVISTO			:= 0
	Local nSEFETIVO				:= 0
	Local nSldReser             := 0
	If !lAuto
		oProcess:SaveLog("Inicio da Exportacao do Pedido de Venda (SC5 - SC6)")	
		oProcess:SetRegua1( 0 )
	Else
		ConOut("Inicio da Exportacao do Pedido de Venda (SC5 - SC6) - SCHEDULE")
	EndIf
	
	cQuery := " SELECT  SC5.C5_FILIAL,"
	cQuery += "         SC5.C5_NUM,"
	cQuery += "         SC5.C5_TIPO,"
	cQuery += "         SC5.C5_CLIENTE,"
	cQuery += "         SC5.C5_LOJACLI,"
	cQuery += "         SC5.C5_VEND1,"
	cQuery += "         SC5.C5_VEND2,"
	cQuery += "         SC5.C5_VEND3,"
	cQuery += "         SC5.C5_VEND4,"
	cQuery += "         SC5.C5_VEND5,"
	cQuery += "         SC5.C5_EMISSAO,"
	cQuery += "         SC5.C5_MOEDA,"
	cQuery += "         SC5.C5_LIBEROK,"
	cQuery += "         SC5.C5_ZTPLIBE,"
	cQuery += "         CASE "
    cQuery += "             WHEN SC5.C5_IDFLUIG<>'' THEN SC5.C5_IDFLUIG "
    cQuery += "             WHEN SC5.C5_IDFLUIG= '' THEN SC5.C5_CODZHO   "
    cQuery += "         ELSE '' "
    cQuery += "         END C5_IDFLUIG, " 
	cQuery += "         SC5.C5_LICITA,"
	cQuery += "         SC6.C6_COMIS1,"
	cQuery += "         SC6.C6_COMIS2,"
	cQuery += "         SC6.C6_COMIS3,"
	cQuery += "         SC6.C6_COMIS4,"
	cQuery += "         SC6.C6_COMIS5,"		
	cQuery += "         SC6.C6_NOTA,"
	cQuery += "         SC6.C6_SERIE,"
	cQuery += "         SC6.C6_ITEM,"
	cQuery += "         SC6.C6_PRODUTO,"
	cQuery += "         SC6.C6_UM,"
	cQuery += "         SC6.C6_QTDVEN,"
	cQuery += "         SC6.C6_QTDENT,"
	cQuery += "         C6_SALDO = CASE WHEN SC6.C6_QTDENT > SC6.C6_QTDVEN THEN 0 ELSE SC6.C6_QTDVEN - SC6.C6_QTDENT END,"
	cQuery += "         SC6.C6_QTDEMP,"
	cQuery += "         SC6.C6_BLQ,"
	cQuery += "         SC6.C6_PRCVEN,"
	cQuery += "         SC6.C6_VALOR,"
	cQuery += "         SC6.C6_TES,"
	cQuery += "         SC6.C6_LOCAL,"
	cQuery += "         SC6.C6_DESCOMA,"
	cQuery += "         SC6.C6_VLDESMA,"
	cQuery += "         SC5.C5_PEDCLI,"
	cQuery += "         SC6.C6_ENTREG," 
	cQuery += "         SC6.C6_DATFAT,"
	cQuery += "         SC6.C6_STPESTQ," 
	cQuery += "         SC5.C5_CODMED,"
	cQuery += "         SC5.C5_NOMMED,"           
	cQuery += "         SC5.C5_CODCONV," 
	cQuery += "         SC5.C5_NOMCONV,"
	cQuery += "         SC5.C5_PACIENT," 
	cQuery += "         SC5.C5_DPROCED," 
	cQuery += "         SC5.C5_ZLOJRET," 
	cQuery += "         SC5.C5_ZCLIRET," 
	cQuery += "         ISNULL((SELECT A1_NOME FROM SA1010 SA1 WHERE SA1.A1_COD=SC5.C5_ZCLIRET AND SA1.A1_LOJA=SC5.C5_ZLOJRET AND SA1.D_E_L_E_T_<>'*'),'') C5_ZNOMRET, "
	cQuery += "(select top 1 C9_BLCRED from SC9010 SC9 where SC9.D_E_L_E_T_='' and SC6.C6_FILIAL = SC9.C9_FILIAL AND SC6.C6_NUM = SC9.C9_PEDIDO AND SC6.C6_ITEM = SC9.C9_ITEM AND SC6.C6_CLI = SC9.C9_CLIENTE AND SC6.C6_LOJA = SC9.C9_LOJA AND SC6.C6_PRODUTO = SC9.C9_PRODUTO ORDER BY SC9.C9_SEQUEN DESC) as C9_BLCRED, "
	cQuery += "(select top 1 C9_BLEST from SC9010 SC9 where SC9.D_E_L_E_T_='' and SC6.C6_FILIAL = SC9.C9_FILIAL AND SC6.C6_NUM =  SC9.C9_PEDIDO AND SC6.C6_ITEM = SC9.C9_ITEM AND SC6.C6_CLI = SC9.C9_CLIENTE AND SC6.C6_LOJA = SC9.C9_LOJA AND SC6.C6_PRODUTO = SC9.C9_PRODUTO ORDER BY SC9.C9_SEQUEN DESC) as C9_BLEST, "
	cQuery += "(select top 1 C9_BLWMS from SC9010 SC9 where SC9.D_E_L_E_T_='' and SC6.C6_FILIAL = SC9.C9_FILIAL AND SC6.C6_NUM =  SC9.C9_PEDIDO AND SC6.C6_ITEM = SC9.C9_ITEM AND SC6.C6_CLI = SC9.C9_CLIENTE AND SC6.C6_LOJA = SC9.C9_LOJA AND SC6.C6_PRODUTO = SC9.C9_PRODUTO ORDER BY SC9.C9_SEQUEN DESC) as C9_BLWMS "

	cQuery += " FROM (" + RetSQLName("SC5") + " SC5 inner join " + RetSQLName("SC6") + " SC6 "
	cQuery += " ON SC5.C5_FILIAL = SC6.C6_FILIAL and SC5.C5_NUM = SC6.C6_NUM ) "
	//cQuery += " left outer join  SC9010 SC9 "
	//cQuery += "	ON SC6.C6_FILIAL = SC9.C9_FILIAL AND C6_NUM = C9_PEDIDO AND C6_ITEM = C9_ITEM)
	
	cQuery += " WHERE SC5.C5_EMISSAO BETWEEN '" + aDtEmis[1] + "' AND '" + aDtEmis[2] + "'"
  	cQuery += " AND SC5.D_E_L_E_T_ = '' AND SC6.D_E_L_E_T_ =''" //AND SC9.D_E_L_E_T_ =''"
	cQuery += " ORDER BY SC5.C5_FILIAL, SC5.C5_NUM"
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T. )
	
	If ( cAliasT )->( !Eof() )
	
		nHandle := fCreate("\m010Exporta\pedidovenda_sc5_sc6.csv", FC_NORMAL)
	
		//Titulo das colunas do arquivo
		FWRITE(	nHandle, "PEDIDO_KEY" 			+ ";" + ;
			       		"ESTABELECIMENTO_KEY"	+ ";" + ;
			       		"C5_NUM" 				+ ";" + ;
			       		"C5_TIPO"				+ ";" + ;			       		
			       		"C5_EMISSAO"			+ ";" + ;			       		
			       		"C5_MOEDA"				+ ";" + ;			       			       					       		
			       		"C6_PEDCLI"				+ ";" + ;
						"C6_COMIS1"				+ ";" + ;			       					       		
						"C6_COMIS2"				+ ";" + ;
						"C6_COMIS3"				+ ";" + ;
						"C6_COMIS4"				+ ";" + ;
						"C6_COMIS5"				+ ";" + ;									       		
			       		"C6_NOTA"				+ ";" + ;
			       		"C6_SERIE"				+ ";" + ;
			       		"C6_ITEM"				+ ";" + ;
			       		"C6_UM"					+ ";" + ;
			       		"C6_QTDVEN"				+ ";" + ;
			       		"C6_QTDENT"				+ ";" + ;
			       		"C6_SALDO"				+ ";" + ;
			       		"C6_QTDEMP"				+ ";" + ;
			       		"C6_BLQ"				+ ";" + ;
			       		"C6_PRCVEN"				+ ";" + ;
			       		"C6_VALOR"				+ ";" + ;
			       		"TES_KEY"				+ ";" + ;
			       		"ARMAZEM_KEY"			+ ";" + ;
			       		"C6_DESCONT"			+ ";" + ;
			       		"C6_VALDESC"			+ ";" + ;
			       		"C6_ENTREG"				+ ";" + ;
			       		"C6_DATFAT"				+ ";" + ;
			       		"DIAS_ENTREG_PREV"		+ ";" + ;
						"DIAS_ENTREG_EFET"		+ ";" + ;
						"SALDO_ENTREG_PREV"		+ ";" + ;
						"SALDO_ENTREG_EFET"		+ ";" + ;
			       		"PRODUTO_KEY"			+ ";" + ;
			       		"CLIENTE_KEY"			+ ";" + ;
			       		"VENDEDOR_KEY"	  		+ ";" + ;			       		
			       		"MOEDA_KEY"		  		+ ";" + ;  
			       		"SITUACAO_PV"			+ ";" + ;
			       		"SITUACAO_PRODUTO"		+ ";" + ;
			       		"IDFLUIG"				+ ";" + ;
			       		"LICITACAO"				+ ";" + ;
			       		"COD_MEDICO_PV"         + ";" + ;
			       		"NOM_MEDICO_PV"         + ";" + ;
			       		"COD_CONVENIO_PV"       + ";" + ;
			       		"NOM_CONVENIO_PV"       + ";" + ;
			       		"NOM_PACIENTE_PV"       + ";" + ;
			       		"DT_PROCEDIMETO"        + ";" + ;
						"COD_PRESTADOR"         + ";" + ;
						"LOJ_PRESTADOR"         + ";" + ;
						"NOM_PRESTADOR"         + ";" + ; 
			       		"DATA_EXTRACAO"	 		+ CRLF )
		nCont++			       		
	
		While ( cAliasT )->( !Eof() )
		
			If !lAuto
				oProcess:IncRegua1("Exportando Pedidos de Venda..." )
			EndIf
		   	
		   	nDPREVISTO	:= 0
			nDEFETIVO	:= 0
			nSPREVISTO	:= 0
			nSEFETIVO	:= 0 
           
		    If Year( StoD( ( cAliasT )->C6_ENTREG ) ) > 1900
				nDPREVISTO := DateDiffDay( Stod( ( cAliasT )->C5_EMISSAO ) , Stod( ( cAliasT )->C6_ENTREG ) )
            EndIf

			If Year( StoD( ( cAliasT )->C6_DATFAT ) ) > 1900                                             
				nDEFETIVO := DateDiffDay( Stod( ( cAliasT )->C5_EMISSAO ) , Stod( ( cAliasT )->C6_DATFAT ) )
			EndIf
			
			If Empty( ( cAliasT )->C6_DATFAT ) .and. Year( StoD( ( cAliasT )->C6_ENTREG ) ) > 1900 
				nSPREVISTO := DateDiffDay( Stod( ( cAliasT )->C6_ENTREG ) , Date() )
			EndIf
			                                  
			If Year( StoD( ( cAliasT )->C6_DATFAT ) ) > 1900 .and. Year( StoD( ( cAliasT )->C6_ENTREG ) ) > 1900
				nSEFETIVO := DateDiffDay( Stod( ( cAliasT )->C6_ENTREG ) , Stod( ( cAliasT )->C6_DATFAT ))
				If StoD( ( cAliasT )->C6_DATFAT ) < StoD( ( cAliasT )->C6_ENTREG )
					nSEFETIVO := nSEFETIVO * -1
				EndIf	
			EndIf        
			
			If AllTrim( ( cAliasT )->C6_BLQ ) == 'R'
				nDPREVISTO	:= 0
				nDEFETIVO	:= 0
				nSPREVISTO	:= 0
				nSEFETIVO	:= 0
			EndIf
	        
			cStsPv :=""
			nSldReser:=0
			If ( cAliasT )->C5_LIBEROK <> 'S' .And. Empty(( cAliasT )->C6_NOTA)  .And. ( cAliasT )->C6_STPESTQ != "R"
				cStsPv := "Incluido"
			ElseIf !Empty(( cAliasT )->C6_NOTA) .And. ( cAliasT )->C9_BLEST == "10" .And.  (( cAliasT )->C6_QTDVEN = ( cAliasT )->C6_QTDENT)
				cStsPv := "Faturado"
			ElseIf ( cAliasT )->C9_BLCRED $ "01|04|09"  .And. Empty(( cAliasT )->C6_NOTA) 
				cStsPv := "Bloqueado Credito"
			ElseIf ( cAliasT )->C9_BLEST $ "02|03"  .And. ( cAliasT )->C6_STPESTQ == "P" // estoque pendente 
				cStsPv := "Estoque Pendente"
				nSldReser:=sSldReserv(( cAliasT )->C5_FILIAL,( cAliasT )->C5_NUM,( cAliasT )->C6_ITEM,( cAliasT )->C6_PRODUTO)
			ElseIf ( cAliasT )->C5_LIBEROK <> 'S' .And. ( cAliasT )->C6_STPESTQ == "R" // estoque representado 
				cStsPv := "Representada"
			ElseIf ( cAliasT )->C9_BLEST $ "02|03"   // .And. Empty(cC6_NOTA) 
				cStsPv := "Bloqueado Estoque"
			ElseIf Empty(( cAliasT )->C9_BLCRED) .And. Empty(( cAliasT )->C9_BLEST) .And. Empty(( cAliasT )->C9_BLWMS) .And. Empty(( cAliasT )->C6_NOTA)
				
				DO CASE
  				
  				CASE lLibFat(( cAliasT )->C5_NUM,( cAliasT )->C5_FILIAL)=.F. .And. ( cAliasT )->C5_ZTPLIBE="2"
     				cStsPv :="Reservado Aguardando outro Item"
     	
  				CASE lLibFat(( cAliasT )->C5_NUM,( cAliasT )->C5_FILIAL)=.F. .And. ( cAliasT )->C5_ZTPLIBE<>"2"
     				cStsPv := "Aguardando Faturamento"
   
   				CASE lLibFat(( cAliasT )->C5_NUM,( cAliasT )->C5_FILIAL)=.T. .And. ( cAliasT )->C5_ZTPLIBE<>"2"
					cStsPv := "Aguardando Faturamento"
		
  				OTHERWISE
    				cStsPv :="Aguardando Faturamento"
	
		   		ENDCASE
				
					
			ElseIf !Empty(( cAliasT )->C6_NOTA) .And. ( cAliasT )->C9_BLEST == "10" .And. (( cAliasT )->C6_QTDVEN <> ( cAliasT )->C6_QTDENT)
				cStsPv := "Faturamento Parcial" 
			Else 
				If Empty(cStsPv)
				   cStsPv := "Sem Status"
				endif   
        	Endif
	
			 
			IF cStsPv ="Reservado Aguardando outro Item" .or. cStsPv ="Aguardando Faturamento" 
			   		nSldReser:=sSldReserv(( cAliasT )->C5_FILIAL,( cAliasT )->C5_NUM,( cAliasT )->C6_ITEM,( cAliasT )->C6_PRODUTO)
			Endif
			

			FWRITE(	nHandle,	( cAliasT )->C5_FILIAL + ( cAliasT )->C5_NUM + ( cAliasT )->C6_ITEM	+ ( cAliasT )->C6_PRODUTO + ";" + ;
							AllTrim( ( cAliasT )->C5_FILIAL )							+ ";" + ;
			       			AllTrim( ( cAliasT )->C5_NUM ) 								+ ";" + ;
			       			AllTrim( ( cAliasT )->C5_TIPO )	  							+ ";" + ;
			       			If( Empty( ( cAliasT )->C5_EMISSAO ) ,"",AllTrim( DtoC( Stod( ( cAliasT )->C5_EMISSAO ) ) ) )  + ";" + ;			       						       						       			
			       			AllTrim( Str(( cAliasT )->C5_MOEDA ))						+ ";" + ;
			       			AllTrim( ( cAliasT )->C5_PEDCLI )							+ ";" + ;
			       			AllTrim( Str ( ( cAliasT )->C6_COMIS1 * ( cAliasT )->C6_VALOR /100 )) + ";" + ;//Valor de Comissão
			       			AllTrim( Str ( ( cAliasT )->C6_COMIS2))						+ ";" + ;
			       			AllTrim( Str ( ( cAliasT )->C6_COMIS3))						+ ";" + ;
			       			AllTrim( Str ( ( cAliasT )->C6_COMIS4))						+ ";" + ;
			       			AllTrim( Str ( ( cAliasT )->C6_COMIS1))						+ ";" + ;//Percentual de Comissão
			       			AllTrim( ( cAliasT )->C6_NOTA )								+ ";" + ;
			       			AllTrim( ( cAliasT )->C6_SERIE )							+ ";" + ;
			       			AllTrim( ( cAliasT )->C6_ITEM )								+ ";" + ;
			       			AllTrim( ( cAliasT )->C6_UM )								+ ";" + ;
			       			AllTrim( Str ( ( cAliasT )->C6_QTDVEN))						+ ";" + ;
			       			AllTrim( Str ( ( cAliasT )->C6_QTDENT))						+ ";" + ;
			       			AllTrim( Str ( ( cAliasT )->C6_SALDO))						+ ";" + ;
			       			AllTrim( Str ( nSldReser))	 								+ ";" + ;
			       			AllTrim( ( cAliasT )->C6_BLQ )								+ ";" + ;
			       			AllTrim( Str ( ( cAliasT )->C6_PRCVEN))						+ ";" + ;
			       		   	AllTrim( Str ( ( cAliasT )->C6_VALOR ))						+ ";" + ;
			       			AllTrim( ( cAliasT )->C5_FILIAL ) + AllTrim( ( cAliasT )->C6_TES ) 		+ ";" + ;			       			
			       			AllTrim( ( cAliasT )->C5_FILIAL ) + AllTrim( ( cAliasT )->C6_LOCAL ) 	+ ";" + ;			       			
			       			AllTrim( Str ( ( cAliasT )->C6_DESCOMA))						+ ";" + ;
			       			AllTrim( Str ( ( cAliasT )->C6_VLDESMA))						+ ";" + ;
			       			If( Empty( ( cAliasT )->C6_ENTREG ) ,"",AllTrim( DtoC( Stod( ( cAliasT )->C6_ENTREG ) ) ) )  + ";" + ;
							If( Empty( ( cAliasT )->C6_DATFAT ) ,"",AllTrim( DtoC( Stod( ( cAliasT )->C6_DATFAT ) ) ) )  + ";" + ;
							AllTrim( Str (nDPREVISTO))		+ ";" + ;
							AllTrim( Str (nDEFETIVO))		+ ";" + ;
							AllTrim( Str (nSPREVISTO))		+ ";" + ;
							AllTrim( Str (nSEFETIVO))		+ ";" + ;
			       			AllTrim( xFilial("SB1") ) + AllTrim( ( cAliasT )->C6_PRODUTO )	+ ";" + ;
			       			AllTrim( xFilial("SA1") ) + AllTrim( ( cAliasT )->C5_CLIENTE ) 	+ AllTrim( ( cAliasT )->C5_LOJACLI ) + ";" + ;
			       			AllTrim( xFilial("SA3") ) + AllTrim( ( cAliasT )->C5_VEND1 )	+ ";" + ;
			       			AllTrim( Str(( cAliasT )->C5_MOEDA ))							+ ";" + ; 
			       			cStsPv															+ ";" + ;
			       			cStsPv															+ ";" + ;
			       			AllTrim( ( cAliasT )->C5_IDFLUIG )								+ ";" + ;
			       			AllTrim( ( cAliasT )->C5_LICITA)								+ ";" + ;			       						       			
			       			AllTrim( ( cAliasT )->C5_CODMED)								+ ";" + ;
			       			AllTrim( ( cAliasT )->C5_NOMMED)								+ ";" + ;
			       			AllTrim( ( cAliasT )->C5_CODCONV)								+ ";" + ;
			       			AllTrim( ( cAliasT )->C5_NOMCONV)								+ ";" + ;
			       			AllTrim( ( cAliasT )->C5_PACIENT)								+ ";" + ;
			       			If( Empty( ( cAliasT )->C5_DPROCED ) ,"",AllTrim( DtoC( Stod( ( cAliasT )->C5_DPROCED ) ) ) )  + ";" + ;
							AllTrim( ( cAliasT )->C5_ZLOJRET)								+ ";" + ;
			       			AllTrim( ( cAliasT )->C5_ZCLIRET)								+ ";" + ;
			       			AllTrim( ( cAliasT )->C5_ZNOMRET)								+ ";" + ;   
			       			cExtracao + CRLF )
			       			
			nCont++
		
			( cAliasT )->( dbSkip() )
			
		EndDo
	
		cMsg += "Registros exportados do Pedido de Venda (SC5 - SC6): " + cValToChar( nCont ) + CRLF
		
	EndIf
	
	( cAliasT )->( dbCloseArea() )
	
	fClose( nHandle )
	
	If !lAuto
		oProcess:SaveLog( "Fim da Exportacao da Tabela de Pedidos de Venda (SC5 - SC6)" )
	EndIf
    
Return( cMsg )



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³M010ExpCRM³ Autor ³ Denis Rodrigues       ³ Data ³17/10/2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Exportacao CRM                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function M010ExpCRM(oProcess,lAuto)

	Local cAliasT		:= GetNextAlias()
	Local cAliasT2		:= GetNextAlias()
	Local cQuery2		:= ""
	Local cQuery		:= ""
	Local cMsg			:= ""
	Local nCont 		:= 0 
	Local nHandle		:= 0
	Local cExtracao	:= DtoC( Date() ) + " - " + Time()

	If !lAuto
		oProcess:SaveLog("Inicio da Exportacao do CRM")
		oProcess:SetRegua1( 0 )
	Else
		ConOut("Inicio da Exportacao do CRM - SCHEDULE")
	EndIf

	
	//cQuery2 := " EXEC ATUALIZA_TAB_BIONEXO  "
	//TCSPEXEC(cQuery2)
	
	
	
	
	
	cQuery := " SELECT " 
	cQuery += "        	ADZ.ADZ_FILIAL AS Filial"
	cQuery += "        	,(SELECT A3_COD FROM " + RetSQLName("SA3") + " SA3 "
	
	//cQuery += "          	WHERE SA3.D_E_L_E_T_ = '' AND SA3.A3_FILIAL = '"+xFilial("SA3")+"' AND A3_COD = ADY.ADY_VEND) AS Vendedor"
	cQuery += "          	WHERE SA3.D_E_L_E_T_ = '' AND A3_COD = ADY.ADY_VEND) AS Vendedor"
	
	cQuery += "        	,(SELECT A1_COD FROM " + RetSQLName("SA1") + " SA1 "
	
	//cQuery += "         	WHERE SA1.D_E_L_E_T_ = '' AND SA1.A1_FILIAL = '"+xFilial("SA1")+"'" 
	cQuery += "         	WHERE SA1.D_E_L_E_T_ = ''"
	
	cQuery += "         	AND A1_COD = ADY.ADY_CODIGO"
	cQuery += "         	AND A1_LOJA = ADY.ADY_LOJA) AS Cliente"
	cQuery += "        	,ADY.ADY_OPORTU AS Oportunidade"
	cQuery += "        	,(SELECT AD1_DESCRI FROM " + RetSQLName("AD1") + " AD1 "
	
	//cQuery += " 	   		WHERE AD1.D_E_L_E_T_ = '' AND AD1.AD1_FILIAL = '"+xFilial("AD1")+"'" 
	cQuery += " 	   		WHERE AD1.D_E_L_E_T_ = ''"
	
	cQuery += "   			AND AD1_NROPOR = ADY.ADY_OPORTU"
	cQuery += "   			AND AD1_REVISA = ADY.ADY_REVISA) AS Descricao_Oportunidade"
	
	cQuery += "        	,(SELECT AD1_DATA FROM " + RetSQLName("AD1") + " AD1 "
	
	//cQuery += " 	   		WHERE AD1.D_E_L_E_T_ = '' AND AD1.AD1_FILIAL = '"+xFilial("AD1")+"'" 
	cQuery += " 	   		WHERE AD1.D_E_L_E_T_ = ''"
	
	cQuery += "   			AND AD1_NROPOR = ADY.ADY_OPORTU"
	cQuery += "   			AND AD1_REVISA = ADY.ADY_REVISA) AS dEmissao_Oportunidade"    
	cQuery += "        	,(SELECT AD1_FEELIN FROM " + RetSQLName("AD1") + " AD1 "
	
	//cQuery += " 	   		WHERE AD1.D_E_L_E_T_ = '' AND AD1.AD1_FILIAL = '"+xFilial("AD1")+"'" 
	cQuery += " 	   		WHERE AD1.D_E_L_E_T_ = ''"
	
	cQuery += "   			AND AD1_NROPOR = ADY.ADY_OPORTU"
	cQuery += "   			AND AD1_REVISA = ADY.ADY_REVISA) AS Probabilidade_Sucesso"    
	cQuery += "   		,(SELECT AC1_DESCRI"  
	cQuery += "     		FROM " + RetSQLName("AC1")+ " AC1 "
	cQuery += "     		INNER JOIN " + RetSQLName("AD1")+ " AD1 "
	cQuery += "     		ON AC1_FILIAL = AD1_FILIAL"
	cQuery += "     		AND AC1_PROVEN = AD1_PROVEN"
	
	//cQuery += "     		WHERE AC1.D_E_L_E_T_ = '' AND AC1.AC1_FILIAL = '"+xFilial("AC1")+"'" 
	//cQuery += " 	   	 	AND AD1.D_E_L_E_T_ = '' AND AD1.AD1_FILIAL = '"+xFilial("AD1")+"'"
	cQuery += "     		WHERE AC1.D_E_L_E_T_ = ''" 
	cQuery += " 	   	 	AND AD1.D_E_L_E_T_ = ''"
	
	cQuery += "    	 	   	AND AD1_NROPOR = ADY.ADY_OPORTU"
	cQuery += "       		AND AD1_REVISA = ADY.ADY_REVISA)	 AS Processo_Vendas"
	cQuery += "   		,(SELECT AC2_DESCRI"  
	cQuery += "     		FROM " + RetSQLName("AC2")+ " AC2 "
	cQuery += "     		INNER JOIN " + RetSQLName("AD1")+ " AD1 "
	cQuery += "     		ON  AC2_FILIAL = AD1_FILIAL"
	cQuery += "     		AND AC2_PROVEN = AD1_PROVEN"
	cQuery += "     		AND AC2_STAGE  = AD1_STAGE"
	 
	//cQuery += "     		WHERE AC2.D_E_L_E_T_ = '' AND AC2.AC2_FILIAL = '"+xFilial("AC2")+"'" 
	//cQuery += "        		AND AD1.D_E_L_E_T_ ='' AND AD1.AD1_FILIAL = '"+xFilial("AD1")+"'"

	cQuery += "     		WHERE AC2.D_E_L_E_T_ = ''" 
	cQuery += "        		AND AD1.D_E_L_E_T_ =''"	
	
	cQuery += "        		AND AD1_NROPOR = ADY.ADY_OPORTU"
	cQuery += "       		AND AD1_REVISA = ADY.ADY_REVISA) AS Estagio_Vendas"
	cQuery += "  		,ADZ.ADZ_PRODUT AS Codigo_Produto"
	cQuery += "   		,(SELECT B1_COD FROM " + RetSQLName("SB1") + " SB1 "
	cQuery += "     		WHERE D_E_L_E_T_ = '' AND SB1.B1_FILIAL = '"+xFilial("SB1")+"'" 
	cQuery += "       		AND B1_COD = ADZ.ADZ_PRODUT) AS Descricao_Produto"
	cQuery += "   		,(SELECT B1_TIPO FROM " + RetSQLName("SB1") + " SB1 "
	cQuery += "     		WHERE D_E_L_E_T_ = '' AND SB1.B1_FILIAL = '"+xFilial("SB1")+"'" 
	cQuery += "       		AND B1_COD = ADZ.ADZ_PRODUT) AS Tipo_Produto"
	cQuery += "   		,(SELECT X5_DESCRI" 
	cQuery += "     		FROM " + RetSQLName("SX5")
	cQuery += "     		WHERE D_E_L_E_T_ = ''" 
	cQuery += "       		AND X5_TABELA  = 'ZX'"
	cQuery += "       		AND X5_CHAVE   = (SELECT B1_MARCA FROM " + RetSQLName("SB1")
	 
	//cQuery += "             WHERE D_E_L_E_T_ = '' AND B1_FILIAL = '"+xFilial("SB1")+"'"
	cQuery += "             WHERE D_E_L_E_T_ = ''"
	 
	cQuery += "             AND B1_COD = ADZ.ADZ_PRODUT"
	cQuery += "             AND B1_COD = ADZ.ADZ_PRODUT)) AS Marca_Produto"
	cQuery += "   		,(SELECT BM_DESC"
	cQuery += "     		FROM " + RetSQLName("SBM")
	cQuery += "     		WHERE D_E_L_E_T_ = '' AND BM_FILIAL = '"+xFilial("SBM") +"'" 
	cQuery += "       		AND BM_GRUPO = (SELECT B1_GRUPO FROM " + RetSQLName("SB1")
	 
	//cQuery += "            	WHERE D_E_L_E_T_ = '' AND B1_FILIAL = '"+xFilial("SB1") +"'"
	cQuery += "            	WHERE D_E_L_E_T_ = ''"
	 
	cQuery += "             AND B1_COD = ADZ.ADZ_PRODUT"
	cQuery += "          AND B1_COD = ADZ.ADZ_PRODUT)) AS Grupo_Produto"
	cQuery += "   		,ADZ.ADZ_PROPOS AS Proposta"
	cQuery += "   		,ADZ.ADZ_REVISA AS Revisao"
	cQuery += "   		,ADZ.ADZ_DESCRI AS Descricao_Proposta"
	cQuery += "   		,ADZ.ADZ_ITEM   AS Item"
	cQuery += "   		,ADZ.ADZ_MOEDA  AS Moeda"
	cQuery += "   		,CASE (SELECT AD1_STATUS" 
	cQuery += "          	FROM " + RetSQLName("AD1")
	
	//cQuery += "          	WHERE D_E_L_E_T_ = '' AND AD1_FILIAL = '"+xFilial("AD1") +"'"
	cQuery += "          	WHERE D_E_L_E_T_ = ''"
	
	cQuery += "            	AND AD1_NROPOR = ADY.ADY_OPORTU"
	cQuery += "            	AND AD1_REVISA = ADY.ADY_REVISA)"
	cQuery += "            	WHEN '1' THEN 'Aberta'"
	cQuery += "            	WHEN '2' THEN 'Perdido'"
	cQuery += "  			WHEN '3' THEN 'Suspenso'"
	cQuery += "            	WHEN '9' THEN 'Ganha'"
	cQuery += "            	END AS Status_Oportunidade"
	cQuery += "   		,ADY.ADY_STATUS AS Status_Proposta"
	cQuery += "   		,CASE (SELECT AD1_TPPROP" 
	//cQuery += "   	,CASE (SELECT AD1_TABELA"
	cQuery += "          	FROM " + RetSQLName("AD1")
	
	//cQuery += "          	WHERE D_E_L_E_T_ = '' AND AD1_FILIAL = '"+xFilial("AD1") +"'"
	cQuery += "          	WHERE D_E_L_E_T_ = ''"
	
	cQuery += "            	AND AD1_NROPOR = ADY.ADY_OPORTU"
	cQuery += "            	AND AD1_REVISA = ADY.ADY_REVISA)"
	cQuery += "            	WHEN '1' THEN 'Revenda'"
	cQuery += "            	WHEN '2' THEN 'Representada'"
	cQuery += "            	WHEN '3' THEN 'Importacao Direta'"
	cQuery += "            	WHEN '4' THEN 'Locacao'"
	cQuery += "            	WHEN '5' THEN 'Contrato Manutencao'"
	cQuery += "            	WHEN '6' THEN 'Comodato'"
	cQuery += "            	END AS Tipo_Processo"
	//-------------------Ednei 11-02-20 Visibilidade tipo de licitacao--------------
	cQuery += "        	,CASE (SELECT AD1_LICITA" 
	cQuery += "            FROM " + RetSQLName("AD1") + " AD1 "
	cQuery += " 	   		WHERE AD1.D_E_L_E_T_ = ''"
	cQuery += "   			AND AD1_NROPOR = ADY.ADY_OPORTU"
	cQuery += "   			AND AD1_REVISA = ADY.ADY_REVISA) "
	cQuery += "            	WHEN '1' THEN 'PUBLICO'"
	cQuery += "            	WHEN '2' THEN 'PRIVADO'"
	cQuery += "            	WHEN '3' THEN 'BIONEXO'"
	cQuery += "            	WHEN '4' THEN 'OUTROS'"
	cQuery += "				ELSE '' "
	cQuery += "            	END AS AD1_LICITACAO"
    //------------------------------------------------------------------------------
	
	
	cQuery += "   		,ADY.ADY_DATA   AS dEmissao_Proposta"
	cQuery += "   		,ADY.ADY_DTAPRO AS dAprovacao_Proposta"
	cQuery += "   		,ADY.ADY_DTFAT  AS dFaturamento_Proposta"
	cQuery += "   		,ADY.ADY_DTREPR AS dReprovacao_Proposta"
	cQuery += "   		,ADY.ADY_DTPDV  AS dGeracao_Pedido"
	cQuery += "   		,ADY.ADY_CODIGO+ADY.ADY_LOJA  AS CodLoj_Cliente"
	cQuery += "   		,ADZ.ADZ_QTDVEN AS Quantidade"
	cQuery += "   		,ADZ.ADZ_PRCTAB AS Preco_Tabela"
	cQuery += "   		,ADZ.ADZ_PRCVEN AS Preco_Venda"
	cQuery += "   		,ADZ.ADZ_TOTAL  AS Valor_Total"  
	cQuery += "   		,ADY.ADY_SINCPR  AS Sincronismo_Proposta"  
	cQuery += " FROM " + RetSQLName("ADZ") + " ADZ "
	cQuery += " INNER JOIN " + RetSQLName("ADY") + " ADY"
	cQuery += " ON ADZ.ADZ_FILIAL  = ADY.ADY_FILIAL"
	cQuery += " AND ADZ.ADZ_PROPOS = ADY.ADY_PROPOS"
	//cQuery += " AND ADY.ADY_SINCPR = 'T' "  //Removido dia 09/12/2017, pois não exportava as Oportunidades Perdidas...

	//cQuery += " WHERE ADZ.D_E_L_E_T_ = '' and ADZ.ADZ_FILIAL = '"+xFilial("ADZ")+"'"
	//cQuery += "   AND ADY.D_E_L_E_T_ = '' and ADY.ADY_FILIAL = '"+xFilial("ADY")+"'"

	cQuery += " WHERE ADZ.D_E_L_E_T_ = ''"
	cQuery += "   AND ADY.D_E_L_E_T_ = ''"	
	
	cQuery += "   AND ADZ.ADZ_REVISA = (SELECT MAX(ADZ_REVISA)" 
	cQuery += "                         FROM " + RetSQLName("ADZ")
	cQuery += "                         WHERE D_E_L_E_T_ = ''" 
	cQuery += "                           AND ADZ_FILIAL = ADZ.ADZ_FILIAL"
	cQuery += "                           AND ADZ_PROPOS = ADZ.ADZ_PROPOS )"
	//cQuery += "   UNION
	//cQuery += "   SELECT * FROM OPP_BIONEXO
	//cQuery += "   ORDER BY OPORTUNIDADE
	cQuery := ChangeQuery( cQuery )
	MemoWrite('CRM.SQL',cQuery)
	dbUseArea( .T., "TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T. )
	
	If ( cAliasT )->( !Eof() )
	
		nHandle := fCreate("\m010Exporta\tabela_crm.csv", FC_NORMAL)
	
		//Titulo das colunas do arquivo
		FWRITE(	nHandle,	"FILIAL" 					+ ";" + ;
			       		"OPORTUNIDADE"			+ ";" + ;
			       		"DESCRICAO_OPORTUNIDADE"	+ ";" + ;
			       		"EMISSAO_OPORTUNIDADE"		+ ";" + ;
			       		"PROCESSO_VENDAS"			+ ";" + ;
			       		"ESTAGIO_VENDAS"			+ ";" + ;
			       		"PROPOSTA"				+ ";" + ;
			       		"REVISAO"					+ ";" + ;
			       		"DESCRICAO_PROPOSTA"		+ ";" + ;
			       		"ITEM"					+ ";" + ;
			       		"MOEDA"					+ ";" + ;
			       		"STATUS_OPORTUNIDADE"		+ ";" + ;
			       		"STATUS_PROPOSTA"			+ ";" + ;
			       		"TIPO_PROCESSO"			+ ";" + ;
			       		"EMISSAO_PROPOSTA"			+ ";" + ;
			       		"DTPEDIDO_PROPOSTA"		+ ";" + ;
			       		"QUANTIDADE"				+ ";" + ;
			       		"PRECO_TABELA"			+ ";" + ;
			       		"PRECO_VENDA"				+ ";" + ;
			       		"VALOR_TOTAL"				+ ";" + ;
			       		"SINCRONISMO_PROPOSTA" 	+ ";" + ;
			       		"PROBABILIDADE_SUCESSO"	+ ";" + ;
   						"LICITACAO_OPORTUNIDADE"+ ";" + ;
   						"PRODUTO_KEY"  	 		+ ";" + ;
			       		"CLIENTE_KEY"  			+ ";" + ;
			       		"VENDEDOR_KEY"  			+ ";" + ;
			       		"MOEDA_KEY"  			+ ";" + ;
			       		"DATA_EXTRACAO"			+ CRLF ) 

		nCont++			       		
     
		// Recupera o valor das moedas para conversao do valor
		nM2  := 1
		nM3  := 1
		nM4  := 1
		nM5  := 1    
		
		("SM2")->(DbGotop())
		dDataAux:=dDatabase   
		
		While .T.
			If ("SM2")->(Eof())
				Exit
			Endif 
			("SM2")->(dbSeek(dDataAux))
			If SM2->M2_MOEDA2 <> 0
				nM2  := SM2->M2_MOEDA2
				nM3  := SM2->M2_MOEDA3
				nM4  := SM2->M2_MOEDA4
				nM5  := SM2->M2_MOEDA5
				Exit
			Else    
				dDataAux -= 1
			Endif            
		End         
		
		nAuxPrcVen := 0
		nAuxPrcTot := 0
		
		While ( cAliasT )->( !Eof() )
			
			If !lAuto
				oProcess:IncRegua1( "Exportando CRM..." )
			EndIf			
			
			If ( cAliasT )->MOEDA = '1'
					nAuxPrcVen := ( cAliasT )->PRECO_VENDA 
					nAuxPrcTot := ( cAliasT )->VALOR_TOTAL 
			ElseIf ( cAliasT )->MOEDA = '2'
					nAuxPrcVen := ( cAliasT )->PRECO_VENDA * nM2
					nAuxPrcTot := ( cAliasT )->VALOR_TOTAL * nM2
			ElseIf ( cAliasT )->MOEDA = '3'
					nAuxPrcVen := ( cAliasT )->PRECO_VENDA * nM3
					nAuxPrcTot := ( cAliasT )->VALOR_TOTAL * nM3
			ElseIf ( cAliasT )->MOEDA = '4'
					nAuxPrcVen := ( cAliasT )->PRECO_VENDA * nM4
					nAuxPrcTot := ( cAliasT )->VALOR_TOTAL * nM4
			ElseIf ( cAliasT )->MOEDA = '5'
					nAuxPrcVen := ( cAliasT )->PRECO_VENDA * nM5
					nAuxPrcTot := ( cAliasT )->VALOR_TOTAL * nM5
			Endif  
			
			cAuxProbabilidade := ''
			
			If ( cAliasT )->Probabilidade_Sucesso = '1'
					cAuxProbabilidade := '30%'
			ElseIf ( cAliasT )->Probabilidade_Sucesso = '2'
					cAuxProbabilidade := '60%'
			ElseIf ( cAliasT )->Probabilidade_Sucesso = '3'
					cAuxProbabilidade := '90%'
			Endif
			
			FWRITE(	nHandle,	( cAliasT )->FILIAL										   		+ ";" + ;
							AllTrim( StrTran(( cAliasT )->OPORTUNIDADE,";"," "))				+ ";" + ;
							AllTrim( StrTran(( cAliasT )->DESCRICAO_OPORTUNIDADE,";"," "))		+ ";" + ;							
							If(Empty((cAliasT )->DEMISSAO_OPORTUNIDADE),"",AllTrim( DtoC( Stod(( cAliasT )->DEMISSAO_OPORTUNIDADE ) ) ) ) + ";" + ;
							AllTrim( StrTran(( cAliasT )->PROCESSO_VENDAS,";"," "))		  		+ ";" + ;
							AllTrim( StrTran(( cAliasT )->ESTAGIO_VENDAS,";"," "))	  			+ ";" + ;
							AllTrim( StrTran(( cAliasT )->PROPOSTA,";"," "))					+ ";" + ;
							AllTrim( StrTran(( cAliasT )->REVISAO,";"," "))			  	  		+ ";" + ;
							AllTrim( StrTran(( cAliasT )->DESCRICAO_PROPOSTA,";"," "))			+ ";" + ;
							AllTrim( StrTran(( cAliasT )->ITEM,";"," "))						+ ";" + ;
							AllTrim( StrTran(( cAliasT )->MOEDA,";"," "))						+ ";" + ;
							AllTrim( StrTran(( cAliasT )->STATUS_OPORTUNIDADE,";"," "))			+ ";" + ;
							AllTrim( StrTran(( cAliasT )->STATUS_PROPOSTA,";"," "))	 	   		+ ";" + ;
				  			AllTrim( StrTran(( cAliasT )->TIPO_PROCESSO,";"," "))				+ ";" + ;
							If(Empty((cAliasT )->DEMISSAO_PROPOSTA),"",AllTrim( DtoC( Stod(( cAliasT )->DEMISSAO_PROPOSTA ) ) ) ) + ";" + ;	
							If(Empty((cAliasT )->DGERACAO_PROPOSTA),"",AllTrim( DtoC( Stod(( cAliasT )->DGERACAO_PROPOSTA ) ) ) ) + ";" + ;
			       			AllTrim(  Str(( cAliasT )->QUANTIDADE,12,2  )) 				  		+ ";" + ;
			       			AllTrim(  Str(( cAliasT )->PRECO_TABELA,12,2)) 				  		+ ";" + ;			       			
			       			AllTrim(  Str(nAuxPrcVen,12,2))								  		+ ";" + ;
			       			AllTrim(  Str(nAuxPrcTot,12,2))								   		+ ";" + ; 
			       			AllTrim( StrTran(( cAliasT )->SINCRONISMO_PROPOSTA,";"," "))   		+ ";" + ;
							AllTrim( StrTran(Alltrim(cAuxProbabilidade),";"," "))  		   		+ ";" + ;
							AllTrim( StrTran(( cAliasT )->AD1_LICITACAO,";"," "))				+ ";" + ;
					  		AllTrim( xFilial("SB1") ) + AllTrim( ( cAliasT )->Codigo_Produto )	+ ";" + ;
					  		AllTrim( xFilial("SA1") ) + AllTrim( ( cAliasT )->CodLoj_Cliente )	+ ";" + ;
					  		AllTrim( xFilial("SA3") ) + AllTrim( ( cAliasT )->Vendedor )		+ ";" + ;
					  		AllTrim( StrTran(( cAliasT )->MOEDA,";"," "))						+ ";" + ;
					  		cExtracao + CRLF )

			nCont++
		
			( cAliasT )->( dbSkip() )
			
		EndDo  
		
		cMsg += "Registros exportados do CRM e BIONEXO: " + cValToChar( nCont ) + CRLF
		
	EndIf
	
	( cAliasT )->( dbCloseArea() )
	
	fClose( nHandle )
	
	If !lAuto
		oProcess:SaveLog( "Fim da Exportacao do CRM" )
	EndIf
    
Return( cMsg )                    
                    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ M010ExpSPV     ³ Autor | Giovanni Melo   ³ Data ³17/10/2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Exportacao Status PV                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function M010ExpSPV(oProcess,lAuto)

	Local cQuery			:= ""
	Local cMsg				:= ""
	Local cExtracao			:= DtoC( Date() ) + " - " + Time()
	Local cNomTransp		:= ""
	Local nCont 			:= 0 
	Local nHandle			:= 0
	Local nX				:= 0
	Local nSaldo 			:= 0       
	Local nQtdePrev			:= 0
	Local nSaldoFil			:= 0  
	Local nVlPedMIPI 		:= 0                                 
	Local nVlrIpi  			:= 0
	Local aProdutos 		:= {} // array dos produtos para montagem de saldos disponiveis e quantidade prevista
	Local aDtEmis			:= StrTokArr( GetMV("TRS_M010SP"),"|" )
	Local aFiliais			:= {}
	Local lPedInclui 		:= .T. // considera pedidos incluidos
	Local lPedBlqCre  		:= .T. // considera pedidos bloqueado credito
	Local lPedBlqEst  		:= .T. // considera pedidos bloqueado estoque
	Local lPedAguFat  		:= .T. // considera pedidos aguardando faturamento
	Local lPedFatura  		:= .F. // considera pedidos faturados
	Local lPedEstPen  		:= .T. // considera pedidos com estoque pendente
	Local lPedEstRep  		:= .T. // considera pedidos com estoque representado  
	Local lPedFatPar  		:= .T. // considera pedidos faturados parcialmente
	
	Local cEmpAux			:= cEmpAnt
	Local cFilAux 			:= cFilAnt
	Local nCnt				:= 0
	
	dbSelectArea( "SM0" )
	dbSetOrder( 1 )
	dbGoTop()
	While SM0->( !EOF() )
	
		aAdd( aFiliais, { SM0->M0_CODFIL, AllTrim( SM0->M0_CGC ) })
		SM0->( dbSkip() )
		
	EndDo

   	SM0->( dbSeek(cEmpAnt+cFilAnt) )

	//Cria o arquivo
	nHandle := fCreate("\m010Exporta\status_pedidos.csv", FC_NORMAL)
	
	
	For nCnt := 1 To Len( aFiliais )
			
		cFilAnt := aFiliais[nCnt][1]

		//+--------------------------------------+
		//| EXPORTACAO DO CADASTRO DE STATUS PV  |
		//+--------------------------------------+
		If !lAuto
			oProcess:SaveLog("Inicio da Exportacao do Status PV - " + aFiliais[nCnt][1])
			oProcess:SetRegua1( 0 )
		Else
			ConOut("Inicio da Exportacao do Status PV - SCHEDULE")
		EndIf
	
		/*cQuery := " SELECT SC5.C5_FILIAl, SC5.R_E_C_N_O_ C5_RECNO, C5_NUM, C6_NUM, C6_ITEM, C5_EMISSAO, C5_CLIENTE, C5_LOJACLI, C5_VEND1, C5_VEND2, C5_VEND3, " 
		cQuery += "        C5_VEND4, C5_VEND5, C5_NATUREZ, B1_DESC, C6_ENTREG, C6_VALOR, B1_IPI, C6_PEDCLI, C5_TRANSP,C5_LIBEROK, A1_NOME, "
		cQuery += "        C5_BLQ, C6_PRODUTO,  C9_QTDLIB, C9_BLWMS, C9_BLCRED, C9_BLEST, C9_PEDIDO, C9_ITEM, C6_NOTA, C6_VALDESC, C6_DATFAT, "*/
		cQuery := " SELECT SC5.C5_FILIAl, C5_NUM, C6_NUM, C6_ITEM, C5_EMISSAO, C5_CLIENTE, C5_LOJACLI, C5_VEND1, C5_VEND2, C5_VEND3,C5_ZTPLIBE, "
		cQuery += "        C5_VEND4, C5_VEND5,C6_ENTREG, C6_VALOR, C5_LIBEROK, "
		cQuery += "        C6_PRODUTO, C9_BLWMS, C9_BLCRED, C9_BLEST, C9_PEDIDO, C9_ITEM, C6_NOTA, C6_DATFAT, "
		cQuery += "        C6_TES, C6_PRCVEN, C6_QTDVEN, C6_QTDENT, C6_STPESTQ, C6_LOCAL "
		cQuery += " FROM " + RetSqlName("SC5") + " SC5 " 
		cQuery += " INNER JOIN " + RetSqlName("SC6") + " SC6 ON C6_FILIAL = '" + xFilial("SC6") + "' AND C6_NUM = C5_NUM "
		cQuery += " LEFT  OUTER JOIN " + RetSqlName("SC9") + " SC9 ON C9_FILIAL = '" + xFilial("SC9") + "' AND C9_PEDIDO = C6_NUM AND C9_ITEM = C6_ITEM AND SC9.D_E_L_E_T_ = ' '"
		cQuery += " INNER JOIN " + RetSqlName("SA1") + " SA1 ON A1_FILIAL = '" + xFilial("SA1") + "' AND A1_COD = C5_CLIENTE AND A1_LOJA = C5_LOJACLI "
		cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1 ON B1_FILIAL = '" + xFilial("SB1") + "' AND B1_COD = C6_PRODUTO "
		cQuery += " INNER JOIN " + RetSqlName("SF4") + " SF4 ON F4_FILIAL = '" + xFilial("SF4") + "' AND F4_CODIGO = C6_TES "
		cQuery += "   WHERE C5_EMISSAO BETWEEN '" + aDtEmis[1] + "' AND '" + aDtEmis[2] + "'"
		
		cQuery += "      AND C5_FILIAL = '" + xFilial("SC5") + "'"			
		cQuery += "   AND C6_BLQ <> 'R' " // FILTRA OS PEDIDOS ELIMINADOS POR RESIDUO
		
		cQuery += "   AND SC5.D_E_L_E_T_ = ' ' "
		cQuery += "   AND SC6.D_E_L_E_T_ = ' ' "
		cQuery += "   AND SA1.D_E_L_E_T_ = ' ' "
		cQuery += "   AND SB1.D_E_L_E_T_ = ' ' "
		cQuery += "   AND SF4.D_E_L_E_T_ = ' ' "
	
		cQuery := ChangeQuery(cQuery)                           
	
		dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQuery), "PEDIDOS", .F., .T.) // executa query
	    
		If PEDIDOS->( !Eof() )
	
			//nHandle := fCreate("\m010Exporta\status_pedidos.csv", FC_NORMAL)		
	          
			If nCnt == 1//Para colocar o cabecalho apenas umas vez

				//Titulo das colunas do arquivo
				FWRITE(	nHandle,"ESTABELECIMENTO_KEY"	+ ";" + ;	
								"NUM_PV" 				+ ";" + ;
					       		"ITEM_PV" 			+ ";" + ;          
					       		"SALDO_DISP"           + ";" + ;
					       		"QTDE_PREV"    		+ ";" + ;
					       		"DT_ENTREGA"      		+ ";" + ;
					       		"VLR_PV_COM_IPI" 		+ ";" + ;
					       		"DT_EMISSAO"   		+ ";" + ;
					       		"SITUACAO_PV" 		+ ";" + ;
					       		"NUM_NF"  			+ ";" + ;
					       		"DT_FATURAMENTO"		+ ";" + ;
					       		"TRANSPORTADORA"    	+ ";" + ;
					       		"QTD_VENDIDA"     		+ ";" + ;
					       		"SALDO_DISP_FILIAL"	+ ";" + ;			       		
					       		"PRODUTO_KEY"  		+ ";" + ;
					       		"CLIENTE_KEY"  		+ ";" + ;
					       		"VENDEDOR_KEY"  		+ ";" + ;
					       		"TES_KEY"		  		+ ";" + ;			       		
					       		"QTD_ENTREGUE"  		+ ";" + ;
					       		"DATA_EXTRACAO"		+ CRLF )
			EndIf
		
			While PEDIDOS->( !Eof() )
		                               
				If !lAuto
					oProcess:IncRegua1( "Exportando Status PV..." )
				EndIf	          
		          
				aDadosPV := { PEDIDOS->C5_LIBEROK,;
							PEDIDOS->C6_NOTA,;
							PEDIDOS->C9_BLCRED,;
							PEDIDOS->C9_BLEST,;
							PEDIDOS->C6_STPESTQ,;
							PEDIDOS->C9_BLWMS,;
							PEDIDOS->C6_QTDVEN,;
							PEDIDOS->C6_QTDENT,; 
							PEDIDOS->C5_ZTPLIBE,;
							PEDIDOS->C5_NUM,;
							PEDIDOS->C5_FILIAL}
				
				aSitPedVen := U_C010StPV( Nil, Nil, Nil, Nil, aDadosPV ) // funcao para verificar o status do pedido de venda
				cSitPedido := aSitPedVen[1] 
				nStatus    := aSitPedVen[2]
		
				lSeleciona	:= .f.
				lSeleciona	:= lPedInclui .and. nStatus == 1 // considera pedidos incluidos? s/n	-- status 1
			
				If !lSeleciona		
					lSeleciona	:= lPedFatura .and. nStatus == 2 // considera pedidos faturados? s/n	-- status 2
				EndIf
			
				If !lSeleciona		
					lSeleciona	:= lPedBlqCre .and. nStatus == 3 // considera pedidos com bloqueio credito? s/n	-- status 3
				EndIf
			
				If !lSeleciona			
					lSeleciona	:= lPedEstPen .and. nStatus == 4 // considera pedidos com estoque pendente? s/n	-- status 4
				EndIf
				
				If !lSeleciona			
					lSeleciona	:= lPedEstRep .and. nStatus == 5 // considera pedidos com estoque representado? s/n	-- status 5
				EndIf
		
				If !lSeleciona			
					lSeleciona	:= lPedBlqEst .and. nStatus == 6 // considera pedidos com estoque bloqueado? s/n -- status 6
				EndIf
				
				If !lSeleciona			
					lSeleciona	:= lPedAguFat .and. nStatus == 7 // considera pedidos aguardando faturamento? s/n	-- status 7
				EndIf
			
				If !lSeleciona			
					lSeleciona	:= lPedFatPar .and. nStatus == 8 // considera pedidos faturamento parcial? s/n	-- status 8
				EndIf
			
				If lSeleciona
			
					// Transportadora
					cNomTransp	:= ""
					If SA4->( DbSeek(xFilial("SA4") + PadR(PEDIDOS->C5_NUM, TamSx3("A4_COD")[1]) ))			
						cNomTransp	:= AllTrim(SA4->A4_NOME)
					EndIf
			
					// Vendedores
					For nX := 1 to 5	
						
						&("cVend" + Str(nX,1)) := ""
				
						If !Empty(&("PEDIDOS->C5_VEND" + Str(nX,1)))
						
							SA3->( DbSeek(xFilial("SA3") + PadR( &("PEDIDOS->C5_VEND" + Str(nX,1) ), TamSx3("A3_COD")[1] ) ))
							&("cVend" + Str(nX,1)) := SA3->A3_NOME
							
						EndIf
						
					Next nX
			                                              
					nVlrIpi    := CalcIPI(PEDIDOS->C5_CLIENTE,  PEDIDOS->C5_LOJACLI,  PEDIDOS->C6_PRODUTO, PEDIDOS->C6_TES, PEDIDOS->C6_QTDVEN, PEDIDOS->C6_PRCVEN , PEDIDOS->C6_VALOR)  
			  		nVlPedMIPI := PEDIDOS->C6_VALOR  + nVlrIpi
			  		
			  		If (nScan := AsCan( aProdutos, { |X| X[1] == PEDIDOS->C6_PRODUTO })) == 0
			  		
				  		nSaldo     := C20GetSld( PEDIDOS->C6_PRODUTO )
						nQtdePrev  := U_MAHC021( PEDIDOS->C6_PRODUTO )
						nSaldoFil  := 0
						If SB2->( DbSeek( xFilial("SB2") + PEDIDOS->C6_PRODUTO + PEDIDOS->C6_LOCAL ))	
							nSaldoFil := SaldoSb2()
						EndIf
						
						aAdd ( aProdutos, { PEDIDOS->C6_PRODUTO, nSaldo, nQtdePrev, nSaldoFil  } )
						
					Else
									
				  		nSaldo     := aProdutos[nScan][2]
						nQtdePrev  := aProdutos[nScan][3]
						nSaldoFil  := aProdutos[nScan][4]
						
					EndIf	  		
		
				EndIf
			    
		   		FWRITE(	nHandle,AllTrim( StrTran(PEDIDOS->C5_FILIAL,","," ") )					+ ";" + ;	
								AllTrim( StrTran(PEDIDOS->C5_NUM,","," ") ) 					+ ";" + ;			
								AllTrim( StrTran(PEDIDOS->C6_ITEM,","," ") )					+ ";" + ; 		
								AllTrim( Str(nSaldo) )										+ ";" + ;
								AllTrim( Str(nQtdePrev) )									+ ";" + ;
								If(Empty(PEDIDOS->C6_ENTREG),"",AllTrim( DtoC( Stod(PEDIDOS->C6_ENTREG) ) ) ) 	+ ";" + ;							
								AllTrim( Str(nVlPedMIPI) )									+ ";" + ;
								If(Empty(PEDIDOS->C5_EMISSAO),"",AllTrim( DtoC( Stod(PEDIDOS->C5_EMISSAO) ) ) )	+ ";" + ;
								AllTrim( StrTran(cSitPedido,","," ") )						+ ";" + ;
								AllTrim( StrTran(PEDIDOS->C6_NOTA,","," ") )					+ ";" + ;
								If(Empty(PEDIDOS->C6_DATFAT),"",AllTrim( DtoC( Stod(PEDIDOS->C6_DATFAT) ) ) )		+ ";" + ;
								AllTrim( StrTran(cNomTransp,","," ") )	   					+ ";" + ;										
								AllTrim( Str(PEDIDOS->C6_QTDVEN	) )							+ ";" + ;
								AllTrim( Str(nSaldoFil) )									+ ";" + ;								
								AllTrim( xFilial("SB1") ) + AllTrim( PEDIDOS->C6_PRODUTO )		+ ";" + ;
								AllTrim( xFilial("SA1") ) + AllTrim( PEDIDOS->C5_CLIENTE ) + AllTrim( PEDIDOS->C5_LOJACLI ) + ";" + ;
								AllTrim( xFilial("SA3") ) + AllTrim( PEDIDOS->C5_VEND1 )		+ ";" + ;
								AllTrim( StrTran(PEDIDOS->C5_FILIAL,","," ") ) + AllTrim( PEDIDOS->C6_TES ) 		+ ";" + ;								
								AllTrim( Str(PEDIDOS->C6_QTDENT) )							+ ";" + ;
								cExtracao													+ CRLF )
	     
				nCont++
			
				PEDIDOS->( dbSkip() )
				
			EndDo	    
			
			//cMsg += "Registros exportados do Status Pedidos de Vendas: " + cValToChar( nCont ) + CRLF
		
		EndIf
		
		PEDIDOS->( dbCloseArea() )
				
		If !lAuto
			oProcess:SaveLog( "Fim da Exportacao do Status Pedidos de Vendas" )
		EndIf
	
	Next nCnt
	
	cMsg += "Registros exportados do Status Pedidos de Vendas: " + cValToChar( nCont ) + CRLF

	fClose( nHandle )
		
	cEmpAnt := cEmpAux 
	cFilAnt := cFilAux		
    
Return( cMsg )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³CalcIPI   ³ Autor ³ Joao Mattos           ³ Data ³09.06.2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Calcula IPI                                                ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CalcIPI(cliente,loja,produto,tes,qtde,unit,total)          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC01 - Codigo do cliente                                 ³±±
±±³          ³ ExpC02 - loja do cliente                                   ³±±
±±³          ³ ExpC03 - codigo do produto                                 ³±±
±±³          ³ ExpC04 - TES                                               ³±±
±±³          ³ ExpN05 - Quantidade                                        ³±±
±±³          ³ ExpN06 - Preco unitario                                    ³±±
±±³          ³ ExpN07 - Valor total                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpN01 - Valor do IPI                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico MA Hospitalar                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                          ULTIMAS ALTERACOES                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CalcIPI (cCLIENTE, cLOJA, cProduto, cTes, nQuant, nPruni, nTotal)

	Private aRelImp     := MaFisRelImp("MT100",{"SF2","SD2"})
	Private cNfOri      := ""
	Private cSeriOri    := ""
	Private nRecnoSD2   := 0      
	Private nIT_ALIQIPI := "" 
	Private nIT_VALIPI  := ""  
	
	MaFisClear()      
	
	MaFisIni(cCLIENTE,;	// 01-Codigo Cliente/Fornecedor
			 cLOJA,;		// 02-Loja do Cliente/Fornecedor
	         "C",;		// 03-C:Cliente , F:Fornecedor
			 "N",;		// 04-Tipo da NF
			 "R",;		// 05-Tipo do Cliente/Fornecedor
			 aRelImp,;	// 06-Relacao de Impostos que suportados no arquivo
			  ,;			// 07-Tipo de complemento
			  ,;			// 08-Permite Incluir Impostos no Rodape .T./.F.
		  	 "SB1",;		// 09-Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)
	    	 "MATA461")		// 10-Nome da rotina que esta utilizando a funcao
	               
	MaFisAdd(cProduto,;	// 01-Codigo do' Produto ( Obrigatorio )
	 		 cTes,;		// 02-Codigo do TES ( Opcional )
	 		 nQuant,;		// 03-Quantidade ( Obrigatorio )
			 nPruni,;		// 04-Preco Unitario ( Obrigatorio )
			 0,;			// 005-Valor do Desconto ( Opcional )
			 cNfOri,;		// 06-Numero da NF Original ( Devolucao/Benef )
			 cSeriOri,;	// 07-Seri''e da NF Original ( Devolucao/Benef )
			 nRecnoSD2,;	// 08-RecNo da NF Original no arq SD1/SD2
			 0,;			// 09-Valor do Frete do Item ( Opcional )
			 0,;			// 10-Valor da Despesa do item ( Opcional )
			 0,;			// 11-Valor do Seguro do item ( Opcional )
			 0,;			// 12-Valor do Frete Autonomo ( Opcional )
			 nTotal,;		// 13-Valor da Mercadoria ( Obrigatorio )
			 0,;			// 14-Valor da Embalagem ( Opiconal )
			 0,;			// 15-RecNo do SB1
			 0,;			// 16-RecNo do SF4   
			 1)				// 17-Nro item
			 
	nIT_ALIQIPI := MaFisRet(1,"IT_ALIQIPI") 
	nIT_VALIPI  := MaFisRet(1,"IT_VALIPI")  
Return ( nIT_VALIPI )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³C20GetSld ³ Autor ³ Joao Mattos           ³ Data ³09.06.2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Saldo Disponivel do produto por local                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ C20GetSld( produto )                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC01 - codigo do produto                                 ³±±
±±³          ³ ExpN02 - Numero da linha                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico MA Hospitalar                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                          ULTIMAS ALTERACOES                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function C20GetSld( cCodProd )

	Local aArea     := GetArea()
	Local aAreaSB2  := SB2->(GetArea())
	Local cQuery    := ""
	Local cAliasTmp := GetNextAlias()
	Local nTotal    := 0
	Local cFilSld   := SuperGetMv( "MA_FILSLDE",.F.,"" )
	Local cLocSld   := SuperGetMv( "MA_LOCSLDE",.F.,"" )

	SB2->( DbSetOrder(1) ) 

	cQuery := " SELECT B2_FILIAL, B2_LOCAL "
	cQuery += " FROM " + RetSqlName("SB2" ) + " SB2 "
	cQuery += " WHERE SB2.B2_FILIAL IN " + FormatIn(cFilSld,"|")
	cQuery += "   AND SB2.B2_COD = '" + cCodProd + "' "
	cQuery += "   AND SB2.B2_LOCAL IN " + FormatIn(cLocSld,"|")
	cQuery += "   AND SB2.D_E_L_E_T_ = ' ' "
	cQuery += " GROUP BY B2_FILIAL, B2_LOCAL "
	cQuery += " ORDER BY B2_FILIAL, B2_LOCAL "
  
	cQuery := ChangeQuery( cQuery )
 	dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.F.,.T. )

	If (cAliasTmp)->(!EoF())

       While (cAliasTmp)->(!Eof())
        
 			dbSelectArea("SB2")
 			dbSetOrder(1)
			dbSeek( (cAliasTmp)->B2_FILIAL + cCodProd + (cAliasTmp)->B2_LOCAL )
			nTotal += SaldoSb2()

			(cAliasTmp)->(dbSkip())
			
        EndDo
        
  	EndIf 

  	( cAliasTmp )->( dbCloseArea() )

	RestArea( aAreaSB2 )
	RestArea( aArea )

Return ( nTotal )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ M010ExpFAT     ³ Autor | Giovanni Melo   ³ Data ³01/11/2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Exportacao Faturamento                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/   
Static Function M010ExpFAT(oProcess,lAuto)

	Local cQuery		:= ""
	Local cMsg	 		:= ""
	Local nCont 		:= 0 
	Local nHandle		:= 0
	Local aDtEmis		:= StrTokArr( GetMV("TRS_M010FT"),"|" )
	Local cExtracao		:= DtoC( Date() ) + " - " + Time()       
	Local nCustoUnit	:= 0 

	
	//+----------------------------------------------+
	//| EXPORTACAO DO CADASTRO DO DOCUMENTO DE SAIDA |
	//+----------------------------------------------+
	If !lAuto
		oProcess:SaveLog("Inicio da Exportacao do Documento de Saida")
		oProcess:SetRegua1( 0 )
	Else
		ConOut("Inicio da Exportacao do Documento de Saida - SCHEDULE")
	EndIf
	 
	cQuery := " SELECT		D2_FILIAL Filial,"
	cQuery += "			D2_EST Estado,"
	cQuery += "			D2_TIPO	TipoNota,"
	cQuery += "			D2_SERIE SerieNota,"
	cQuery += "			D2_DOC NroNota,"
	cQuery += "			D2_ITEM	Item,"
	cQuery += "			D2_COD CodProduto,"
/*	cQuery += "			REPLACE(B1_DESC,',','') DescProduto,"*/
	cQuery += "			D2_LOCAL LocalProduto,"
	cQuery += "			D2_TES TES,"
	cQuery += "			F4_CF+'-'+F4_TEXTO CFOP,"
	cQuery += "			F4_DUPLIC GeraDuplicata,"
/*	cQuery += "			D2_TP TipoProduto,"
	cQuery += "			D2_GRUPO GrupoProduto,"*/
	cQuery += "			D2_CONTA ContaContabil,"
	cQuery += "			D2_EMISSAO DataEmissao,"
	cQuery += "			SUBSTRING(D2_EMISSAO,1,6) DataReserva,"
	cQuery += "			D2_QUANT Quantidade,"
	cQuery += "			D2_TOTAL ValorTotal,"
	cQuery += "			D2_VALBRUT ValorBruto,"
	cQuery += "			Case  "
    cQuery += "			   When F4_BIOPERA ='02' THEN 0 "
	cQuery += "			   When F4_BIOPERA<>'02' THEN D2_CUSTO1 "
    cQuery += "			end as ValorCusto, "
	cQuery += "			D2_VALIPI ValorIPI,"
	cQuery += "			D2_PRCVEN PrecoVenda,"
	cQuery += "			D2_CLIENTE CodCliente,"
/*	cQuery += "			A1_NOME+A1_LOJA	NomeCliente,"*/
	cQuery += "			D2_LOJA	LojaCliente,"
	cQuery += "			A3_COD	Vendedor,"
	cQuery += "			F2_MOEDA Moeda,"
	cQuery += "			F2_TXMOEDA TaxaMoeda,"
	/*cQuery += "			B1_MARCA MarcaProduto,"*/
	cQuery += "			D2_VALICM+D2_VALIMP1+D2_VALIMP2+D2_VALIMP3+D2_VALIMP4+D2_VALIMP5+D2_VALIMP6 ValorImpostos,"   
	cQuery += "			D2_PRUNIT PrecoUnitario,"	
	cQuery += "			D2_PEDIDO NumeroPedidoVenda,"
	cQuery += "			D2_ITEMPV ItemPedidoVenda,"
	cQuery += "			D2_LOTECTL LoteProduto,"	
	cQuery += "			D2_QTDEDEV  D2QtdDevolvida,"
	cQuery += "			D2_VALDEV  D2Valdevolvido,"
	cQuery += "			D2_NUMSERI NumeroSerieProduto"
	cQuery += " FROM	" + 	RetSqlName("SD2") + " SD2, " 
	cQuery += 			RetSqlName("SF2") + " SF2, " 
	cQuery += 			RetSqlName("SB1") + " SB1, " 
	cQuery += 			RetSqlName("SA1") + " SA1, " 
	cQuery += 			RetSqlName("SA3") + " SA3, " 
	cQuery += 			RetSqlName("SF4") + " SF4"
	cQuery += " WHERE	D2_EMISSAO	  	  >= '" + aDtEmis[1] + "'"
	cQuery += " AND		D2_EMISSAO	  <= '" + aDtEmis[2] + "'" 
	cQuery += " AND		D2_ORIGLAN	  <> 'LF'"
	cQuery += " AND		D2_TIPO		  <> 'D'"
	cQuery += " AND		SF2.F2_FILIAL   = D2_FILIAL" 
	cQuery += " AND		SF2.F2_DOC      = SD2.D2_DOC"
	cQuery += " AND		SF2.F2_SERIE    = SD2.D2_SERIE" 
	cQuery += " AND		SF2.F2_CLIENTE  = SD2.D2_CLIENTE"
	cQuery += " AND		SF2.F2_LOJA     = SD2.D2_LOJA"
	cQuery += " AND		SB1.B1_FILIAL   = '" + xFilial("SB1") + "'"
	cQuery += " AND		SB1.B1_COD      = SD2.D2_COD"
	cQuery += " AND		SA1.A1_FILIAL   = '" + xFilial("SA1") + "'"
	cQuery += " AND		SA1.A1_COD      = SD2.D2_CLIENTE"	
	cQuery += " AND		SA1.A1_LOJA     = SD2.D2_LOJA"
	cQuery += " AND		SA3.A3_FILIAL   = '" + xFilial("SA3") + "'"
	cQuery += " AND		SA3.A3_COD      = SF2.F2_VEND1"
	cQuery += " AND		SF4.F4_FILIAL   = D2_FILIAL"
	cQuery += " AND		F4_CODIGO       = D2_TES"
	cQuery += " AND		SD2.D_E_L_E_T_  = ''"
	cQuery += " AND		SF2.D_E_L_E_T_  = ''"
	cQuery += " AND		SA1.D_E_L_E_T_  = ''"
	cQuery += " AND		SB1.D_E_L_E_T_  = ''"
	cQuery += " AND		SA3.D_E_L_E_T_  = ''"
	cQuery += " AND		SF4.D_E_L_E_T_  = ''"	
    MEMOWRITE ("NF_F2.SQL", cQuery)
	cQuery := ChangeQuery(cQuery)                           
	dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQuery), "FAT", .F., .T.) // executa query
    
	If FAT->( !Eof() )

		nHandle := fCreate("\m010Exporta\documentosaida.csv", FC_NORMAL)		

		//Titulo das colunas do arquivo
		FWRITE(	nHandle,	"ESTABELECIMENTO_KEY"	+ ";" + ;
			       		"ESTADO" 				+ ";" + ;
			       		"TIPO_NOTA"			+ ";" + ;
			       		"SERIE_NOTA"    		+ ";" + ;          
			       		"NRO_NOTA"	         + ";" + ;
			       		"ITEM"  	  			+ ";" + ;
			       		"ARMAZEM_KEY"  		+ ";" + ;
			       		"TES_KEY"		     	+ ";" + ;
			       		"CFOP"		 		+ ";" + ;
			       		"GERA_DUPLICATA"		+ ";" + ;
			       		"DATA_EMISSAO"	    	+ ";" + ;
			       		"DATA_RESERVA"		+ ";" + ;
			       		"QUANTIDADE"			+ ";" + ;
			       		"VALOR_TOTAL"          + ";" + ;
			       		"VALOR_BRUTO"      	+ ";" + ;
			       		"VALOR_CUSTO"  		+ ";" + ;
			       		"VALOR_IPI"     		+ ";" + ;
			       		"PRECO_VENDA"			+ ";" + ;
			       		"MOEDA"				+ ";" + ;
			       		"TAXA_MOEDA"			+ ";" + ;
			       		"VALOR_IMPOSTOS"  		+ ";" + ;
						"VALOR_PRECOUNIT"  		+ ";" + ;
						"VALOR_CUSTOUNIT"  		+ ";" + ;
						"NUMERO_PEDIDO_VENDA"	+ ";" + ;
						"ITEM_PEDIDO_VENDA"		+ ";" + ;
						"LOTE_PRODUTO"			+ ";" + ;
						"NUMERO_SERIE"			+ ";" + ;
						"D2QtdDevolvida"		+ ";" + ;
						"D2ValDevolvido"		+ ";" + ;
						"COD_MOT_DEVOLUCAO"		+ ";" + ;
						"DES_MOT_DEVOLUCAO"		+ ";" + ;
						"PRODUTO_KEY" 	 		+ ";" + ;
			       		"CLIENTE_KEY"  			+ ";" + ;
			       		"VENDEDOR_KEY"  		+ ";" + ;
			       		"PLANOCONTAS_KEY" 		+ ";" + ;
			       		"MOEDA_KEY"				+ ";" + ;			       		
			       		"DATA_EXTRACAO"		+ CRLF )
	
		While FAT->( !Eof() )
	                               
			If !lAuto
				oProcess:IncRegua1( "Exportando Faturamento..." )
			EndIf
		 		                                 
/*			DbSelectArea('SX5')
			DbSetOrder(1)
			DbSeek(xFilial("SX5") + 'ZX' + FAT->MarcaProduto )
			cAuxMarca := SX5->X5_DESCRI*/	                                                              
			  
			DbSelectArea('FAT')
                                 
	        nCustoUnit = FAT->ValorCusto / FAT->Quantidade;
       
	   		FWRITE(	nHandle,	AllTrim( StrTran(FAT->Filial,","," ") ) 									+ ";" + ;			
							AllTrim( StrTran(FAT->Estado,","," ") )											+ ";" + ;
							AllTrim( StrTran(FAT->TipoNota,","," ") )			  							+ ";" + ;
							AllTrim( StrTran(FAT->SerieNota,","," ") )			  							+ ";" + ;
							AllTrim( StrTran(FAT->NroNota,","," ") )			  							+ ";" + ;
							AllTrim( StrTran(FAT->Item,","," ") )				 							+ ";" + ;
							AllTrim( StrTran(FAT->Filial,","," ") ) + AllTrim( StrTran(FAT->LocalProduto,","," ") )		+ ";" + ;
							AllTrim( StrTran(FAT->Filial,","," ") ) + AllTrim( StrTran(FAT->TES,","," ") )		 		+ ";" + ;
							AllTrim( StrTran(FAT->CFOP,","," ") )				   							+ ";" + ;
							AllTrim( StrTran(FAT->GeraDuplicata,","," ") )		   							+ ";" + ;
							If(Empty(FAT->DataEmissao),"",AllTrim( DtoC( Stod(FAT->DataEmissao) ) )) 		+ ";" + ;
							If(Empty(FAT->DataReserva),"",AllTrim( DtoC( Stod(FAT->DataReserva) ) ))		+ ";" + ;
							AllTrim( Str(FAT->Quantidade) ) 				  								+ ";" + ;
							AllTrim( Str(FAT->ValorTotal) )								   					+ ";" + ;
							AllTrim( Str(FAT->ValorBruto) )													+ ";" + ;
							AllTrim( Str(FAT->ValorCusto) )						  							+ ";" + ;
							AllTrim( Str(FAT->ValorIPI) )													+ ";" + ;
							AllTrim( Str(FAT->PrecoVenda) )													+ ";" + ;
							AllTrim( Str(FAT->Moeda) )														+ ";" + ;
							AllTrim( Str(FAT->TaxaMoeda) )													+ ";" + ;
							AllTrim( Str(FAT->ValorImpostos) )												+ ";" + ;  							
							AllTrim( Str(FAT->PrecoUnitario) )												+ ";" + ;
							AllTrim( Str(nCustoUnit))  														+ ";" + ;
							AllTrim( StrTran(FAT->NumeroPedidoVenda,","," ") )								+ ";" + ;
							AllTrim( StrTran(FAT->ItemPedidoVenda,","," ") )			  					+ ";" + ; 
							AllTrim( StrTran(FAT->LoteProduto,","," ") )			  						+ ";" + ;
							AllTrim( StrTran(FAT->NumeroSerieProduto,","," ") )			  					+ ";" + ;
							AllTrim( Str(FAT->D2QtdDevolvida) )			     								+ ";" + ;
							AllTrim( Str(FAT->D2ValDevolvido) )			     								+ ";" + ;
							AllTrim( 'N/A' )											  					+ ";" + ;
							AllTrim( 'N/A' )			  													+ ";" + ;
							AllTrim( xFilial("SB1") ) + AllTrim( FAT->CodProduto )							+ ";" + ;
							AllTrim( xFilial("SA1") ) + AllTrim( FAT->CodCliente ) + AllTrim( FAT->LojaCliente ) + ";" + ;
							AllTrim( xFilial("SA3") ) + AllTrim( FAT->Vendedor )	   						+ ";" + ;
							AllTrim( xFilial("CT1") ) + AllTrim( FAT->ContaContabil )  						+ ";" + ;
							AllTrim( Str(FAT->Moeda) )														+ ";" + ; 								 								 
 			       	 		cExtracao + CRLF )
    
			nCont++
		
			FAT->( dbSkip() )
			
		EndDo	    
  		FAT->( dbCloseArea() )     
  		
	EndIf	

	cQuery := " SELECT	D1_FILIAL Filial,"
	cQuery += "			F1_EST Estado,"
	cQuery += "			D1_TIPO	TipoNota,"
	cQuery += "			D1_SERIE SerieNota,"
	cQuery += "			D1_DOC NroNota,"
	cQuery += "			D1_ITEM	Item,"
	cQuery += "			D1_COD CodProduto,"
/*	cQuery += "			REPLACE(B1_DESC,',','') DescProduto,"*/
	cQuery += "			D1_LOCAL LocalProduto,"
	cQuery += "			D1_TES TES,"
	cQuery += "			F4_CF+'-'+F4_TEXTO CFOP,"
	cQuery += "			F4_DUPLIC GeraDuplicata,"
/*	cQuery += "			D1_TP TipoProduto,"
	cQuery += "			D1_GRUPO GrupoProduto,"*/
	cQuery += "			D1_CONTA ContaContabil,"
	cQuery += "			D1_EMISSAO DataEmissao,"
	cQuery += "			SUBSTRING(D1_EMISSAO,1,6) DataReserva,"
	cQuery += "			D1_QUANT Quantidade,"
	cQuery += "			D1_TOTAL ValorTotal,"
	cQuery += "			D1_TOTAL ValorBruto,"
	cQuery += "			Case  "
    cQuery += "			   When F4_BIOPERA ='02' THEN 0 "
	cQuery += "			   When F4_BIOPERA<>'02' THEN D1_CUSTO "
    cQuery += "			end as ValorCusto, "
	cQuery += "			D1_VALIPI ValorIPI,"
	cQuery += "			D1_VUNIT PrecoVenda,"
	cQuery += "			D1_FORNECE CodCliente,"
/*	cQuery += "			A1_NOME+A1_LOJA	NomeCliente,"*/
	cQuery += "			D1_LOJA	LojaCliente,"
	cQuery += "			(SELECT F2_VEND1  FROM SF2010 WHERE F2_FILIAL=D1_FILORI AND F2_DOC=D1_NFORI AND F2_SERIE=D1_SERIORI AND F2_CLIENTE=F1_FORNECE AND F2_LOJA=F1_LOJA AND D_E_L_E_T_<>'*')	Vendedor,"
	cQuery += "			F1_MOEDA Moeda,"
	cQuery += "			F1_TXMOEDA TaxaMoeda,"
	/*cQuery += "			B1_MARCA MarcaProduto,"*/
	cQuery += "			D1_NFORI NFOri,"
	cQuery += "			D1_SERIORI SeriOri,"
	cQuery += "			D1_VALIMP1 ValorImpostos,"
	cQuery += "			D1_LOTECTL LoteProduto,"
	cQuery += "			F1_ZMOTDEV COD_MOT_DEVOLUCAO,"
	cQuery += "			F1_ZDESMOT DES_MOT_DEVOLUCAO"
	cQuery += " FROM	" + 	RetSqlName("SD1") + " SD1, " 
	cQuery += 			RetSqlName("SF1") + " SF1, " 
	cQuery += 			RetSqlName("SB1") + " SB1, " 
	cQuery += 			RetSqlName("SA1") + " SA1, " 
	cQuery += 			RetSqlName("SF4") + " SF4"
	cQuery += " WHERE	D1_EMISSAO		>= '" + aDtEmis[1] + "'"
	cQuery += " AND		D1_EMISSAO		<= '" + aDtEmis[2] + "'" 
	cQuery += " AND		D1_ORIGLAN		<> 'LF'"
	cQuery += " AND		D1_TIPO		= 'D'"
	cQuery += " AND		SF1.F1_FILIAL	= D1_FILIAL" 
	cQuery += " AND		SF1.F1_DOC      = SD1.D1_DOC"
	cQuery += " AND		SF1.F1_SERIE    = SD1.D1_SERIE" 
	cQuery += " AND		SF1.F1_FORNECE   = SD1.D1_FORNECE"
	cQuery += " AND		SF1.F1_LOJA		= SD1.D1_LOJA"
	cQuery += " AND		SB1.B1_FILIAL	= '" + xFilial("SB1") + "'"
	cQuery += " AND		SB1.B1_COD		= SD1.D1_COD"
	cQuery += " AND		SA1.A1_FILIAL	= '" + xFilial("SA1") + "'"
	cQuery += " AND		SA1.A1_COD		= SD1.D1_FORNECE"	
	cQuery += " AND		SA1.A1_LOJA		= SD1.D1_LOJA"
	cQuery += " AND		SF4.F4_FILIAL	= D1_FILIAL"
	cQuery += " AND		F4_CODIGO		= D1_TES"
	cQuery += " AND		SD1.D_E_L_E_T_	= ''"
	cQuery += " AND		SF1.D_E_L_E_T_	= ''"
	cQuery += " AND		SA1.D_E_L_E_T_	= ''"
	cQuery += " AND		SB1.D_E_L_E_T_	= ''"
	cQuery += " AND		SF4.D_E_L_E_T_	= ''"	
    MEMOWRITE ("NF_F1.SQL", cQuery)
	cQuery := ChangeQuery(cQuery)                           

	dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQuery), "FAT", .F., .T.) // executa query        
	
	While FAT->( !Eof() )
                               
		If !lAuto
			oProcess:IncRegua1( "Exportando Faturamento..." )
		EndIf                    
            //cAuxVend :=""
  		   //	cAuxVend :=cVendNF(FAT->Filial + FAT->NFOri + FAT->SeriOri + FAT->CodCliente + FAT->LojaCliente)
			
			//DbSelectArea('SF2')
			//DbSetOrder(1)
			//DbSeek(FAT->Filial + FAT->NFOri + FAT->SeriOri + FAT->CodCliente + FAT->LojaCliente)	 
			//cAuxVend := SF2->F2_VEND1	                                                              

			DbSelectArea('FAT')
                                
		    nCustoUnit 	= FAT->ValorCusto / FAT->Quantidade;  
    
	   		FWRITE(	nHandle,AllTrim( StrTran(FAT->Filial,","," ") ) 					+ ";" + ;			
							AllTrim( StrTran(FAT->Estado,","," ") )					+ ";" + ;
							AllTrim( StrTran(FAT->TipoNota,","," ") )					+ ";" + ;
							AllTrim( StrTran(FAT->SerieNota,","," ") )				+ ";" + ;
							AllTrim( StrTran(FAT->NroNota,","," ") )					+ ";" + ;
							AllTrim( StrTran(FAT->Item,","," ") )					+ ";" + ;
							AllTrim( StrTran(FAT->Filial,","," ") ) + AllTrim( StrTran(FAT->LocalProduto,","," ") )		+ ";" + ;
							AllTrim( StrTran(FAT->Filial,","," ") ) + AllTrim( StrTran(FAT->TES,","," ") )			+ ";" + ;
							AllTrim( StrTran(FAT->CFOP,","," ") )					+ ";" + ;
							AllTrim( StrTran(FAT->GeraDuplicata,","," ") )			+ ";" + ;
							If(Empty(FAT->DataEmissao),"",AllTrim( DtoC( Stod(FAT->DataEmissao) ) )) 			+ ";" + ;
							If(Empty(FAT->DataReserva),"",AllTrim( DtoC( Stod(FAT->DataReserva) ) )) 			+ ";" + ;
							AllTrim( Str(FAT->Quantidade) ) 				  									+ ";" + ;
							AllTrim( Str(FAT->ValorTotal) )						  								+ ";" + ;
							AllTrim( Str(FAT->ValorBruto) )						  								+ ";" + ;
							AllTrim( Str(FAT->ValorCusto) )						 								+ ";" + ;
							AllTrim( Str(FAT->ValorIPI) )														+ ";" + ;
							AllTrim( Str(FAT->PrecoVenda) )														+ ";" + ;
							AllTrim( Str(FAT->Moeda) )						   									+ ";" + ;
							AllTrim( Str(FAT->TaxaMoeda) )					   									+ ";" + ;
							AllTrim( Str(FAT->ValorImpostos) )				  									+ ";" + ;  
							AllTrim( Str(FAT->PrecoVenda) )	   				  									+ ";" + ;
							AllTrim( Str(nCustoUnit) )	 					 									+ ";" + ;
							AllTrim( StrTran("",","," ") )					 									+ ";" + ;
							AllTrim( StrTran("",","," ") )			  		  									+ ";" + ;														
							AllTrim( StrTran(FAT->LoteProduto,","," ") )		 								+ ";" + ; 
							AllTrim( StrTran("",","," ") )						   								+ ";" + ;
							AllTrim( '0' )				 					 									+ ";" + ;
							AllTrim( '0' )				 					 									+ ";" + ;
					   		AllTrim( StrTran(FAT->COD_MOT_DEVOLUVAO,","," ") )	   								+ ";" + ;
					   		AllTrim( StrTran(FAT->DES_MOT_DEVOLUCAO,","," ") )	   								+ ";" + ;
							AllTrim( xFilial("SB1") ) + AllTrim( FAT->CodProduto )								+ ";" + ;
							AllTrim( xFilial("SA1") ) + AllTrim( FAT->CodCliente ) + AllTrim( FAT->LojaCliente )+ ";" + ;
							AllTrim( xFilial("SA3") ) + AllTrim( FAT->Vendedor )	+ ";" + ;
							AllTrim( xFilial("CT1") ) + AllTrim( FAT->ContaContabil ) 	+ ";" + ;
							AllTrim( Str(FAT->Moeda) )								+ ";" + ;
							cExtracao + CRLF )
      
			nCont++
		
			FAT->( dbSkip() )
			
	EndDo
	
	cMsg += "Registros exportados do Documento de Saida: " + cValToChar( nCont ) + CRLF
	
	FAT->( dbCloseArea() )
	
	fClose( nHandle )
	
	If !lAuto
		oProcess:SaveLog( "Fim da Exportacao do Documento de Saida" )
	EndIf	
    
Return( cMsg )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ M010SE1Exp ³ Autor ³ Denis Rodrigues  ³ Data ³  19/12/2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Processa a exportacao do Contas a Receber SE1              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function M010SE1Exp(oProcess,lAuto)

	Local cAliasT		:= GetNextAlias()
	Local cQuery 		:= ""	
	Local cMsg 	 		:= ""
	Local cExtracao		:= DtoC( Date() ) + " - " + Time()	
	Local nCont	   		:= 0
	Local nHandle		:= 0
	Local aDtEmis		:= StrTokArr( GetMV("TRS_M010CR"),"|" ) 
	Local aDadosSE5		:={}  
	Local nValorTit		:= 0
	Local nSaldoTit		:= 0 

	If !lAuto		
		oProcess:SaveLog("Inicio da Exportacao da Tabela do Contas a Receber (SE1)")
		oProcess:SetRegua1( 0 )	
	Else
		ConOut("Inicio da Exportacao da Tabela do Contas a Receber (SE1) - SCHEDULE")
	EndIf
	
	cQuery := " SELECT E1_FILIAL,"
	cQuery += "        E1_PREFIXO,"
	cQuery += "        E1_NUM,"
	cQuery += "        E1_PARCELA,"
	cQuery += "        E1_TIPO,"
	cQuery += "        E1_NATUREZ,"	
	cQuery += "        E1_PORTADO,"
	cQuery += "        E1_CLIENTE,"
	cQuery += "        E1_LOJA,"
	cQuery += "        E1_EMISSAO,"
	cQuery += "        E1_VENCTO,"
	cQuery += "        E1_VENCREA,"
	cQuery += "        E1_VALOR,"
	cQuery += "        E1_BASEIRF,"
	cQuery += "        E1_IRRF,"
	cQuery += "        E1_ISS,"
	cQuery += "        E1_INSS,"
	cQuery += "        E1_PIS,"
	cQuery += "        E1_COFINS,"
	cQuery += "        E1_CSLL,"
	cQuery += "        E1_BAIXA,"
	cQuery += "        E1_SITUACA,"
	cQuery += "        E1_SALDO,"
	cQuery += "        E1_VENCORI,"
	cQuery += "        E1_VEND1,"
	cQuery += "        E1_MOEDA,"
	cQuery += "        E1_BASCOM1,"
	cQuery += "        E1_TITPAI"
	cQuery += " FROM " + RetSQLName("SE1")
	cQuery += "   WHERE E1_EMISSAO BETWEEN '" + aDtEmis[1] + "' AND '" + aDtEmis[2] +"'"
	cQuery += "   AND D_E_L_E_T_<>'*'"
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T. )
	
	If ( cAliasT )->( !Eof() )
	
		nHandle := fCreate("\m010Exporta\contasreceber_se1.csv", FC_NORMAL)
	
		//Titulo das colunas do arquivo
		FWRITE(	nHandle, "ARECEBER_KEY"			+ ";" + ;
			       		"E1_FILIAL" 				+ ";" + ;
			       		"E1_PREFIXO"				+ ";" + ;
			       		"E1_NUM"					+ ";" + ;
						"E1_PARCELA"				+ ";" + ;
						"E1_TIPO"					+ ";" + ;
						"NATUREZA_OPERACAO_KEY"	+ ";" + ;
						"E1_PORTADO"				+ ";" + ;
						"E1_EMISSAO"				+ ";" + ;
						"E1_VENCTO"				+ ";" + ;
						"E1_VENCREA"				+ ";" + ;
						"E1_VALOR"				+ ";" + ;
						"E1_BASEIRF"				+ ";" + ;
						"E1_IRRF"					+ ";" + ;
						"E1_ISS"					+ ";" + ;
						"E1_INSS"					+ ";" + ;
						"E1_PIS"					+ ";" + ;
						"E1_COFINS"					+ ";" + ;
						"E1_CSLL"					+ ";" + ;
						"E1_BAIXA"					+ ";" + ;
						"MOTIVO_BAIXA"				+ ";" + ;
						"E1_SITUACA"				+ ";" + ;
						"E1_SALDO"					+ ";" + ;
						"E1_VENCORI"				+ ";" + ;
						"E1_MOEDA"					+ ";" + ;
						"E1_BASCOM1"				+ ";" + ;
						"CLIENTE_KEY"				+ ";" + ;
						"VENDEDOR_KEY"				+ ";" + ;
						"MOEDA_KEY"					+ ";" + ;
						"DATA_EXTRACAO"			+ CRLF )
		nCont++			       		
	
		While ( cAliasT )->( !Eof() )
		
			If !lAuto
				oProcess:IncRegua1("Exportando Contas a Receber..." )
			EndIf
		           
			aDadosSE5 := SE5MOTBX( ( cAliasT )->E1_FILIAL,;
							 ( cAliasT )->E1_PREFIXO,;
							 ( cAliasT )->E1_NUM,;
							 ( cAliasT )->E1_PARCELA,;
							 ( cAliasT )->E1_TIPO,;
							 ( cAliasT )->E1_CLIENTE,;
							 ( cAliasT )->E1_LOJA )//Funcao para retorno Motivo Baixa        
							 
			If ('-' $ ( cAliasT )->E1_TIPO) .or. ('RA' $ ( cAliasT )->E1_TIPO) .or. ('NCC' $ ( cAliasT )->E1_TIPO)
				nValorTit := ( cAliasT )->E1_VALOR *(-1)
				nSaldoTit := ( cAliasT )->E1_SALDO *(-1)  
			Else
				nValorTit := ( cAliasT )->E1_VALOR 
				nSaldoTit := ( cAliasT )->E1_SALDO 
			EndIf  
				
							 
			FWRITE(	nHandle,( cAliasT )->E1_FILIAL + ( cAliasT )->E1_PREFIXO + ( cAliasT )->E1_NUM + ( cAliasT )->E1_PARCELA + ( cAliasT )->E1_TIPO + ";" + ;
			       			AllTrim( ( cAliasT )->E1_FILIAL ) 			   																+ ";" + ;
			       			AllTrim( ( cAliasT )->E1_PREFIXO )			   																+ ";" + ;
			       			AllTrim( ( cAliasT )->E1_NUM )	  			   																+ ";" + ;
			       			AllTrim( ( cAliasT )->E1_PARCELA )			   																+ ";" + ;
			       			AllTrim( ( cAliasT )->E1_TIPO )	  																			+ ";" + ;
			       			Iif( Empty( ( cAliasT )->E1_NATUREZ ), "", AllTrim( xFilial("SED") ) + AllTrim( ( cAliasT )->E1_NATUREZ ) )	+ ";" + ;			       			
			       			AllTrim( ( cAliasT )->E1_PORTADO )			   																+ ";" + ;
			       			If( Empty( ( cAliasT )->E1_EMISSAO ),"",AllTrim( DtoC( Stod( ( cAliasT )->E1_EMISSAO ) ) ) ) 				+ ";" + ;
			       			If( Empty( ( cAliasT )->E1_VENCTO ) ,"",AllTrim( DtoC( Stod( ( cAliasT )->E1_VENCTO ) ) ) ) 				+ ";" + ;
			       			If( Empty( ( cAliasT )->E1_VENCREA ),"",AllTrim( DtoC( Stod( ( cAliasT )->E1_VENCREA ) ) ) ) 				+ ";" + ;	
			       			AllTrim( Str( nValorTit ) )																				 	+ ";" + ;
			       			AllTrim( Str( ( cAliasT )->E1_BASEIRF ) )		 															+ ";" + ;
			       			AllTrim( Str( ( cAliasT )->E1_IRRF ) )	   																	+ ";" + ;
			       			AllTrim( Str( ( cAliasT )->E1_ISS ) )	 	  																+ ";" + ;
			       			AllTrim( Str( ( cAliasT )->E1_INSS ) )	 	  																+ ";" + ;
			       			AllTrim( Str( ( cAliasT )->E1_PIS ) )	 	  																+ ";" + ;
			       			AllTrim( Str( ( cAliasT )->E1_COFINS ) )	 	  															+ ";" + ;
			       			AllTrim( Str( ( cAliasT )->E1_CSLL ) )	 	  																+ ";" + ;
			       			If( Empty( ( cAliasT )->E1_BAIXA ),"",AllTrim( DtoC( Stod( ( cAliasT )->E1_BAIXA ) ) ) ) 					+ ";" + ;
			       			aDadosSE5[1]																								+ ";" + ;
			       			AllTrim( ( cAliasT )->E1_SITUACA )																			+ ";" + ;
			       			AllTrim( Str( nSaldoTit ) )																	 				+ ";" + ;
			       			If( Empty( ( cAliasT )->E1_VENCORI ),"",AllTrim( DtoC( Stod( ( cAliasT )->E1_VENCORI ) ) ) ) 				+ ";" + ;
			       			AllTrim( Str( ( cAliasT )->E1_MOEDA ) )																		+ ";" + ; 
			       			AllTrim( Str( ( cAliasT )->E1_BASCOM1 ) )																	+ ";" + ;
			       			AllTrim( xFilial("SA1") ) + AllTrim( ( cAliasT )->E1_CLIENTE ) + AllTrim( ( cAliasT )->E1_LOJA ) 			+ ";" + ;
			       			AllTrim( xFilial("SA3") ) + AllTrim( ( cAliasT )->E1_VEND1 )									 			+ ";" + ; 
			       			AllTrim( Str( ( cAliasT )->E1_MOEDA ) )																		+ ";" + ; 
			       			cExtracao + CRLF )
			nCont++
		
			( cAliasT )->( dbSkip() )
			
		EndDo
	
		cMsg += "Registros exportados do Contas a Receber (SE1): " + cValToChar( nCont ) + CRLF
		
	EndIf
	
	( cAliasT )->( dbCloseArea() )
	
	fClose( nHandle )
	
	If !lAuto
		oProcess:SaveLog( "Fim da Exportacao da Tabela do Contas a Receber (SE1)" )
	EndIf
	
Return( cMsg )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ M010SE2Exp ³ Autor ³ Denis Rodrigues  ³ Data ³  19/12/2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Processa a exportacao do Contas a Pagar SE2                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function M010SE2Exp(oProcess,lAuto)

	Local cAliasT		:= GetNextAlias()
	Local cQuery 		:= ""
	Local cMsg 			:= ""
	Local cExtracao		:= DtoC( Date() ) + " - " + Time()
	Local nCont			:= 0
	Local nHandle		:= 0	
	Local aDtEmis		:= StrTokArr( GetMV("TRS_M010CP"),"|" )
	Local aDadosSE5		:= {}
	Local nValorTit		:= 0
	Local nSaldoTit		:= 0

	If !lAuto		
		oProcess:SaveLog("Inicio da Exportacao da Tabela do Contas a Pagar (SE2)")
		oProcess:SetRegua1( 0 )
	Else
		ConOut("Inicio da Exportacao da Tabela do Contas a Pagar (SE2) - SCHEDULE")	
	EndIf
	
	cQuery := " SELECT E2_FILIAL,"
	cQuery += "        E2_PREFIXO,"
	cQuery += "        E2_NUM,"
	cQuery += "        E2_PARCELA,"
	cQuery += "        E2_TIPO,"
	cQuery += "        E2_NATUREZ,"
	cQuery += "        E2_PORTADO,"
	cQuery += "        E2_FORNECE,"
	cQuery += "        E2_LOJA,"
	cQuery += "        E2_EMISSAO,"
	cQuery += "        E2_VENCTO,"
	cQuery += "        E2_VENCREA,"
	cQuery += "        E2_VALOR,"
	cQuery += "        E2_IRRF,"
	cQuery += "        E2_ISS,"
	cQuery += "        E2_INSS,"
	cQuery += "        E2_PIS,"
	cQuery += "        E2_COFINS,"
	cQuery += "        E2_CSLL,"
	cQuery += "        E2_SALDO,"
	cQuery += "        E2_VENCORI,"   
	cQuery += "        E2_BAIXA,"   
	cQuery += "        E2_MOEDA,"
	cQuery += "        E2_ACRESC"		
	cQuery += " FROM " + RetSQLName("SE2")
	cQuery += "   WHERE E2_EMISSAO BETWEEN '" + aDtEmis[1] + "' AND '" + aDtEmis[2] + "'"
	cQuery += "   AND D_E_L_E_T_<>'*'"
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T. )
	
	If ( cAliasT )->( !Eof() )
	
		nHandle := fCreate("\m010Exporta\contasapagar_se2.csv", FC_NORMAL)
	
		//Titulo das colunas do arquivo
		FWRITE(	nHandle, "APAGAR_KEY"				+ ";" + ;
			       		"E2_FILIAL" 				+ ";" + ;
			       		"E2_PREFIXO"				+ ";" + ;
			       		"E2_NUM"					+ ";" + ;
						"E2_PARCELA"				+ ";" + ;
						"E2_TIPO"					+ ";" + ;
						"NATUREZA_OPERACAO_KEY"	+ ";" + ;
						"E2_PORTADO"				+ ";" + ;
						"E2_EMISSAO"				+ ";" + ;
						"E2_VENCTO"				+ ";" + ;
						"E2_VENCREA"				+ ";" + ;
						"E2_VALOR"				+ ";" + ;
						"E2_IRRF"					+ ";" + ;
						"E2_ISS"					+ ";" + ;
						"E2_INSS"					+ ";" + ;
						"E2_PIS"					+ ";" + ;
						"E2_COFINS"					+ ";" + ;
						"E2_CSLL"					+ ";" + ;
						"E2_SALDO"				+ ";" + ;
						"E2_VENCORI"				+ ";" + ;
						"E2_BAIXA"					+ ";" + ; 
						"E2_ACRESC"					+ ";" + ;
						"MOTIVO_BAIXA"				+ ";" + ;
						"E2_MOEDA"					+ ";" + ;
						"FORNECEDOR_KEY"			+ ";" + ;
						"MOEDA_KEY"					+ ";" + ;
						"DATA_EXTRACAO"			+ CRLF )
		nCont++			       		
	
		While ( cAliasT )->( !Eof() )
		
			If !lAuto
				oProcess:IncRegua1("Exportando Contas a Pagar..." )
			EndIf

			aDadosSE5 := SE5MOTBX( ( cAliasT )->E2_FILIAL,;
							 ( cAliasT )->E2_PREFIXO,;
							 ( cAliasT )->E2_NUM,;
							 ( cAliasT )->E2_PARCELA,;
							 ( cAliasT )->E2_TIPO,;
							 ( cAliasT )->E2_FORNECE,;
							 ( cAliasT )->E2_LOJA )//Funcao para retorno Motivo Baixa    
		                    
			If ('-' $ ( cAliasT )->E2_TIPO)
				nValorTit := ( cAliasT )->E2_VALOR *(-1)
				nSaldoTit := ( cAliasT )->E2_SALDO *(-1)  
			Else
				nValorTit := ( cAliasT )->E2_VALOR 
				nSaldoTit := ( cAliasT )->E2_SALDO 
			EndIf  

		
			FWRITE(	nHandle,( cAliasT )->E2_FILIAL + ( cAliasT )->E2_PREFIXO + ( cAliasT )->E2_NUM + ( cAliasT )->E2_PARCELA + ( cAliasT )->E2_TIPO + ( cAliasT )->E2_FORNECE + ( cAliasT )->E2_LOJA + ";" + ;
			       			AllTrim( ( cAliasT )->E2_FILIAL ) 				+ ";" + ;
			       			AllTrim( ( cAliasT )->E2_PREFIXO )  				+ ";" + ;
			       			AllTrim( ( cAliasT )->E2_NUM )	  				+ ";" + ;
			       			AllTrim( ( cAliasT )->E2_PARCELA )				+ ";" + ;
			       			AllTrim( ( cAliasT )->E2_TIPO )	  				+ ";" + ;
			       			Iif( Empty( ( cAliasT )->E2_NATUREZ ), "", AllTrim( xFilial("SED") ) + AllTrim( ( cAliasT )->E2_NATUREZ ) )	+ ";" + ;
			       			AllTrim( ( cAliasT )->E2_PORTADO )				+ ";" + ;
			       			If( Empty( ( cAliasT )->E2_EMISSAO ),"",AllTrim( DtoC( Stod( ( cAliasT )->E2_EMISSAO ) ) ) ) + ";" + ;
			       			If( Empty( ( cAliasT )->E2_VENCTO ) ,"",AllTrim( DtoC( Stod( ( cAliasT )->E2_VENCTO ) ) ) ) + ";" + ;
			       			If( Empty( ( cAliasT )->E2_VENCREA ),"",AllTrim( DtoC( Stod( ( cAliasT )->E2_VENCREA ) ) ) ) + ";" + ;			       						       						       						       			
			       			AllTrim( Str( nValorTit ) )						+ ";" + ;
			       			AllTrim( Str( ( cAliasT )->E2_IRRF ) )			+ ";" + ;
			       			AllTrim( Str( ( cAliasT )->E2_ISS ) )	 		+ ";" + ;
			       			AllTrim( Str( ( cAliasT )->E2_INSS ) )	 		+ ";" + ;
			       			AllTrim( Str( ( cAliasT )->E2_PIS ) )	 		+ ";" + ;
			       			AllTrim( Str( ( cAliasT )->E2_COFINS ) ) 		+ ";" + ;
			       			AllTrim( Str( ( cAliasT )->E2_CSLL ) )	 		+ ";" + ;
			       			AllTrim( Str( nSaldoTit ) )						+ ";" + ;
			       			If( Empty( ( cAliasT )->E2_VENCORI ),"",AllTrim( DtoC( Stod( ( cAliasT )->E2_VENCORI ) ) ) ) 		+ ";" + ;
			       			If( Empty( ( cAliasT )->E2_BAIXA ),"",AllTrim( DtoC( Stod( ( cAliasT )->E2_BAIXA ) ) ) ) 		+ ";" + ;
			       			AllTrim( Str( ( cAliasT )->E2_ACRESC ) ) 		+ ";" + ;
			       			aDadosSE5[1]									+ ";" + ;
			       			AllTrim( Str( ( cAliasT )->E2_MOEDA ) )			+ ";" + ;
			       			AllTrim( xFilial("SA2") ) + AllTrim( ( cAliasT )->E2_FORNECE ) + AllTrim( ( cAliasT )->E2_LOJA )	+ ";" + ;
			       			AllTrim( Str( ( cAliasT )->E2_MOEDA ) )			+ ";" + ;
			       			cExtracao + CRLF )
			nCont++
		
			( cAliasT )->( dbSkip() )
			
		EndDo
	
		cMsg += "Registros exportados do Contas a Pagar (SE2): " + cValToChar( nCont ) + CRLF
		
	EndIf
	
	( cAliasT )->( dbCloseArea() )
	
	fClose( nHandle )
	
	If !lAuto
		oProcess:SaveLog( "Fim da Exportacao da Tabela do Contas a Pagar (SE2)" )
	EndIf
	
Return( cMsg )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ M010SE5Exp ³ Autor ³ Denis Rodrigues  ³ Data ³  19/12/2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Processa a exportacao da Tabela Mov. Financeira SE5        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function M010SE5Exp(oProcess,lAuto)

	Local cAliasT		:= GetNextAlias()
	Local cQuery 		:= ""
	Local cMsg 	   		:= ""
	Local cExtracao		:= DtoC( Date() ) + " - " + Time()
	Local cCliLoj		:= ""
	Local cForLoj		:= ""
	Local nCont			:= 0
	Local nHandle		:= 0
	Local aDtEmis		:= StrTokArr( GetMV("TRS_M010MF"),"|" )

	If !lAuto		
		oProcess:SaveLog("Inicio da Exportacao da Tabela de Movimentação Financeira (SE5)")
		oProcess:SetRegua1( 0 )	
	Else
		ConOut("Inicio da Exportacao da Tabela de Movimentação Financeira (SE5) - SCHEDULE")
	EndIf
	
	cQuery := " SELECT E5_FILIAL,"
	cQuery += "        E5_DTDISPO,"
	cQuery += "        E5_DATA,"
	cQuery += "        E5_TIPO,"
	cQuery += "        E5_MOEDA,"
	cQuery += "        E5_VALOR,"
	cQuery += "        E5_NATUREZ,"
	cQuery += "        E5_BANCO,"
	cQuery += "        E5_AGENCIA,"
	cQuery += "        E5_CONTA,"
	cQuery += "        E5_VENCTO,"
	cQuery += "        E5_TIPODOC,"
	cQuery += "        E5_VLMOED2,"
	cQuery += "        E5_SITUACA,"
	cQuery += "        E5_PREFIXO,"
	cQuery += "        E5_NUMERO,"
	cQuery += "        E5_PARCELA,"
	cQuery += "        E5_FORNECE AS FORNECEDOR,"
	cQuery += "        E5_CLIENTE AS CLIENTE,"
	cQuery += "        E5_LOJA AS LOJA,"	
	cQuery += "        E5_DTDIGIT,"	
	cQuery += "        E5_RECPAG,"
	cQuery += "        E5_MOTBX"
	cQuery += " FROM " + RetSQLName("SE5")
	cQuery += "   WHERE E5_DTDISPO BETWEEN '" + aDtEmis[1] + "' AND '" + aDtEmis[2] + "'"
	cQuery += "   AND D_E_L_E_T_<>'*'"
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T. )
	
	If ( cAliasT )->( !Eof() )
	
		nHandle := fCreate("\m010Exporta\movfinanceira_se5.csv", FC_NORMAL)
	
		//Titulo das colunas do arquivo
		FWRITE(	nHandle, "MOVFINANCEIRA_KEY"		+ ";" + ;
			       		"E5_FILIAL" 				+ ";" + ;
			       		"E5_DTDISPO"				+ ";" + ;
			       		"E5_TIPO"					+ ";" + ;
						"E5_MOEDA"				+ ";" + ;
						"E5_VALOR"				+ ";" + ;
						"NATUREZA_OPERACAO_KEY"	+ ";" + ;
						"E5_BANCO"				+ ";" + ;
						"E5_AGENCIA"				+ ";" + ;
						"E5_CONTA"				+ ";" + ;
						"E5_VENCTO"				+ ";" + ;
						"E5_TIPODOC"				+ ";" + ;
						"E5_VLMOED2"				+ ";" + ;
						"E5_SITUACA"				+ ";" + ;
						"E5_PREFIXO"				+ ";" + ;
						"E5_NUMERO"				+ ";" + ;
						"E5_PARCELA"				+ ";" + ;
						"E5_DTDIGIT"				+ ";" + ;
						"FORNECEDOR_KEY"			+ ";" + ;
						"CLIENTE_KEY"				+ ";" + ;
						"E5_RECPAG"				+ ";" + ;
						"E5_MOTBX"				+ ";" + ;
						"MOEDA_KEY"				+ ";" + ;
						"DATA_EXTRACAO"			+ CRLF )
		nCont++			       		
	
		While ( cAliasT )->( !Eof() )
		
			If !lAuto
				oProcess:IncRegua1("Exportando Movimentações Financeiras..." )
			EndIf
			
			If Empty( ( cAliasT )->FORNECEDOR)    
				If !Empty( ( cAliasT )->CLIENTE )
					cCliLoj := AllTrim( xFilial("SA1") ) + AllTrim( ( cAliasT )->CLIENTE ) + AllTrim( ( cAliasT )->LOJA )
					cForLoj := ""
				EndIf
			
			EndIf
			
			If Empty( ( cAliasT )->CLIENTE )
				If !Empty( ( cAliasT )->FORNECEDOR )
					cCliLoj := "" 
					cForLoj := AllTrim( xFilial("SA2") ) + AllTrim( ( cAliasT )->FORNECEDOR ) + AllTrim( ( cAliasT )->LOJA )
				EndIf	
			EndIf
	
			FWRITE(	nHandle,( cAliasT )->E5_FILIAL + ( cAliasT )->E5_DATA + ( cAliasT )->E5_BANCO + ( cAliasT )->E5_AGENCIA + ( cAliasT )->E5_CONTA + ( cAliasT )->E5_PREFIXO + ( cAliasT )->E5_NUMERO + ( cAliasT )->E5_PARCELA +  ";" + ;
			       			AllTrim( ( cAliasT )->E5_FILIAL ) 			+ ";" + ;
			       			If( Empty( ( cAliasT )->E5_DTDISPO ) ,"",AllTrim( DtoC( Stod( ( cAliasT )->E5_DTDISPO ) ) ) )  + ";" + ;
			       			AllTrim( ( cAliasT )->E5_TIPO )	  		   		+ ";" + ;
			       			AllTrim(  ( cAliasT )->E5_MOEDA  )	 			+ ";" + ;
			       			AllTrim( Str( ( cAliasT )->E5_VALOR ) )	  		+ ";" + ;			       			
			       			Iif( Empty( ( cAliasT )->E5_NATUREZ ), "", AllTrim( xFilial("SED") ) + AllTrim( ( cAliasT )->E5_NATUREZ ) )	+ ";" + ;
			       			AllTrim( ( cAliasT )->E5_BANCO )		  		+ ";" + ;
			       			AllTrim( ( cAliasT )->E5_AGENCIA )		   		+ ";" + ;
			       			AllTrim( ( cAliasT )->E5_CONTA )		   		+ ";" + ;
							If( Empty( ( cAliasT )->E5_VENCTO ) ,"",AllTrim( DtoC( Stod( ( cAliasT )->E5_VENCTO ) ) ) )  + ";" + ;			       						       			
			       			AllTrim( ( cAliasT )->E5_TIPODOC )		   		+ ";" + ;
			       			AllTrim( Str( ( cAliasT )->E5_VLMOED2 ) )	 	+ ";" + ;
			       			AllTrim( ( cAliasT )->E5_SITUACA )		  		+ ";" + ;
			       			AllTrim( ( cAliasT )->E5_PREFIXO )		  		+ ";" + ;
			       			AllTrim( ( cAliasT )->E5_NUMERO )		  		+ ";" + ;
			       			AllTrim( ( cAliasT )->E5_PARCELA )		  		+ ";" + ;
			       			If( Empty( ( cAliasT )->E5_DTDIGIT ) ,"",AllTrim( DtoC( Stod( ( cAliasT )->E5_DTDIGIT ) ) ) )  	+ ";" + ;			       			
			       			cCliLoj								 			+ ";" + ;
			       			cForLoj 										+ ";" + ;
			       			AllTrim( ( cAliasT )->E5_RECPAG )		 		+ ";" + ;
							AllTrim( ( cAliasT )->E5_MOTBX )		 		+ ";" + ; 
							AllTrim( ( cAliasT )->E5_MOEDA )				+ ";" + ;
			       			cExtracao + CRLF )
			nCont++
		
			( cAliasT )->( dbSkip() )
			
		EndDo
	
		cMsg += "Registros exportados da  Movimentação Financeira (SE5): " + cValToChar( nCont ) + CRLF
		
	EndIf
	
	( cAliasT )->( dbCloseArea() )
	
	fClose( nHandle )
	
	If !lAuto
		oProcess:SaveLog( "Fim da Exportacao da Mov.Financeira (SE5)" )
	EndIf
	
Return( cMsg )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ M010CT2Exp ³ Autor ³ Denis Rodrigues  ³ Data ³  20/12/2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Processa a exportacao do Lancamento Contabil CT2           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function M010CT2Exp(oProcess,lAuto)

	Local cAliasT		:= GetNextAlias()
	Local cQuery 		:= ""
	Local cMsg 		:= ""
	Local cExtracao	:= DtoC( Date() ) + " - " + Time()
	Local nCont		:= 0
	Local nHandle		:= 0	
	Local aDtEmis		:= StrTokArr( GetMV("TRS_M010LC"),"|" )

	If !lAuto		
		oProcess:SaveLog("Inicio da Exportacao da Tabela de Lanc. Contabil (CT2)")
		oProcess:SetRegua1( 0 )
	Else
		ConOut("Inicio da Exportacao da Tabela de Lanc. Contabil (CT2) - SCHEDULE")	
	EndIf
	
	cQuery := " SELECT CT2_FILIAL,"
	cQuery += "        CT2_DATA,"			
	cQuery += "        CT2_LOTE,"			
	cQuery += "        CT2_SBLOTE,"			
	cQuery += "        CT2_DOC,"			
	cQuery += "        CT2_LINHA,"			
	cQuery += "        CT2_MOEDLC,"			
	cQuery += "        CT2_DC,"
	cQuery += "        CT2_ITEMD AS ITEM,"
	cQuery += "        CT2_CCD  AS CENTROCUSTO,"
	cQuery += "        'DEBITO' AS LANCAMENTO,"			
	cQuery += "        CT2_DEBITO AS CONTA,"			
	cQuery += "        CT2_CREDIT AS CONTRA_PARTIDA,"			
	cQuery += "        CT2_VALOR"			
	cQuery += " FROM " + RetSQLName("CT2")				
	cQuery += " WHERE D_E_L_E_T_ <>'*'"	
	cQuery += "   AND CT2_DATA BETWEEN '" + aDtEmis[1] + "' AND '" + aDtEmis[2] + "'"		
	cQuery += "   AND CT2_DEBITO > ''"
						 
	cQuery += " UNION ALL"

	cQuery += " SELECT CT2_FILIAL,"			
	cQuery += "        CT2_DATA,"			
	cQuery += "        CT2_LOTE,"			
	cQuery += "        CT2_SBLOTE,"			
	cQuery += "        CT2_DOC,"			
	cQuery += "        CT2_LINHA,"			
	cQuery += "        CT2_MOEDLC,"			
	cQuery += "        CT2_DC,"	
	cQuery += "        CT2_ITEMC AS ITEM,"
	cQuery += "        CT2_CCC  AS CENTROCUSTO,"				
	cQuery += "        'CREDITO'as LANCAMENTO,"			
	cQuery += "        CT2_CREDIT as CONTA,"			
	cQuery += "        CT2_DEBITO as CONTRA_PARTIDA,"			
	cQuery += "        CT2_VALOR"			
	cQuery += " FROM " + RetSQLName("CT2")			
	cQuery += " WHERE D_E_L_E_T_ <>'*'"			
	cQuery += "   AND CT2_DATA BETWEEN '" + aDtEmis[1] + "' AND '" + aDtEmis[2] + "'"
	cQuery += "   AND CT2_CREDIT > ''" 	
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T. )
	
	If ( cAliasT )->( !Eof() )
	
		nHandle := fCreate("\m010Exporta\lanccontabil_ct2.csv", FC_NORMAL)
	
		//Titulo das colunas do arquivo
		FWRITE(	nHandle, "LANCONTABIL_KEY" 	+ ";" + ;
			       		"CT2_FILIAL" 		+ ";" + ;
			       		"CT2_DATA"		+ ";" + ;
			       		"CT2_LOTE"		+ ";" + ;
			       		"CT2_SBLOTE"		+ ";" + ;
			       		"CT2_DOC"			+ ";" + ;
			       		"CT2_LINHA"		+ ";" + ;
			       		"CT2_MOEDLC"		+ ";" + ;
			       		"CT2_DC"			+ ";" + ;			       		
			       		"ITEM"			+ ";" + ;
			       		"CENTROCUSTO_KEY"	+ ";" + ;
			       		"LANCAMENTO"		+ ";" + ;
			       		"CONTRA_PARTIDA"	+ ";" + ;
			       		"CT2_VALOR"		+ ";" + ;
			       		"PLANOCONTAS1_KEY"	+ ";" + ;
			       		"DATA_EXTRACAO"	+ CRLF )
		nCont++			       		
	
		While ( cAliasT )->( !Eof() )
		
			If !lAuto
				oProcess:IncRegua1("Exportando Lançamento Contabil..." )
			EndIf
		
			FWRITE(	nHandle,	( cAliasT )->CT2_FILIAL + ( cAliasT )->CT2_DATA + ( cAliasT )->CT2_LOTE + ( cAliasT )->CT2_SBLOTE + ( cAliasT )->CT2_DOC + ( cAliasT )->CT2_LINHA + ";" + ;
			       			AllTrim( ( cAliasT )->CT2_FILIAL )								+ ";" + ;
			       			If( Empty( ( cAliasT )->CT2_DATA ) ,"",AllTrim( DtoC( Stod( ( cAliasT )->CT2_DATA ) ) ) )  + ";" + ;			       			
			       			AllTrim( ( cAliasT )->CT2_LOTE )								+ ";" + ;
			       			AllTrim( ( cAliasT )->CT2_SBLOTE )								+ ";" + ;
			       			AllTrim( ( cAliasT )->CT2_DOC )	 								+ ";" + ;
			       			AllTrim( ( cAliasT )->CT2_LINHA )								+ ";" + ;
			       			AllTrim( ( cAliasT )->CT2_MOEDLC )								+ ";" + ;
			       			AllTrim( ( cAliasT )->CT2_DC )									+ ";" + ;			       			
			       			AllTrim( ( cAliasT )->ITEM )									+ ";" + ;
			       			AllTrim( xFilial("CTT") ) + AllTrim( ( cAliasT )->CENTROCUSTO )		+ ";" + ;			       			
			       			AllTrim( ( cAliasT )->LANCAMENTO )								+ ";" + ;
			       			AllTrim( ( cAliasT )->CONTRA_PARTIDA )							+ ";" + ;
			       			AllTrim( Str( ( cAliasT )->CT2_VALOR ) )							+ ";" + ;			       			
			       			AllTrim( xFilial("CT1") ) + AllTrim( ( cAliasT )->CONTA )			+ ";" + ;			       			
			       			cExtracao + CRLF )

			nCont++
		
			( cAliasT )->( dbSkip() )
			
		EndDo
	
		cMsg += "Registros exportados do Lancamento Contabil (CT2): " + cValToChar( nCont ) + CRLF
		
	EndIf
	
	( cAliasT )->( dbCloseArea() )
	
	fClose( nHandle )
	
	If !lAuto
		oProcess:SaveLog( "Fim da Exportacao do Lançamento Contabil (CT2)" )
	EndIf
      
Return( cMsg )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ M010CT1Exp ³ Autor ³ Denis Rodrigues  ³ Data ³  20/12/2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Processa a exportacao do Lancamento Contabil CT2           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function M010CT1Exp(oProcess,lAuto)

	Local cAliasT		:= GetNextAlias()
	Local cQuery 		:= ""
	Local cMsg 	   		:= ""
	Local cExtracao		:= DtoC( Date() ) + " - " + Time()
	Local nCont	   		:= 0
	Local nHandle		:= 0
	Local cNatureza		:= ""

	If !lAuto		
		oProcess:SaveLog("Inicio da Exportacao da Tabela de Plano de Contas (CT1)")
		oProcess:SetRegua1( 0 )	
	Else
		ConOut("Inicio da Exportacao da Tabela de Plano de Contas (CT1) - SCHEDULE")
	EndIf
	
	cQuery := " SELECT CT1_FILIAL,"
	cQuery += "        CT1_CONTA,"			
	cQuery += "        CT1_DESC01,"			
	cQuery += "        CT1_CLASSE,"
	cQuery += "        CT1_NTSPED"
	cQuery += " FROM " + RetSQLName("CT1")
	cQuery += " WHERE D_E_L_E_T_<>'*'" 			 	
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T. )
	
	If ( cAliasT )->( !Eof() )
	
		nHandle := fCreate("\m010Exporta\planodecontas_ct1.csv", FC_NORMAL)
	
		//Titulo das colunas do arquivo
		FWRITE(	nHandle, "PLANOCONTAS_KEY" 	+ ";" + ;
			       		"CT1_FILIAL" 		+ ";" + ;
			       		"CT1_CONTA"		+ ";" + ;
			       		"CT1_DESC01"		+ ";" + ;
			       		"CT1_CLASSE"		+ ";" + ;
			       		"CT1_NTSPED"		+ ";" + ;
			       		"DATA_EXTRACAO"	+ CRLF )
		nCont++			       		
	
		While ( cAliasT )->( !Eof() )
		
			If !lAuto
				oProcess:IncRegua1("Exportando Plano de Contas..." )
			EndIf
			  
			Do case 
				Case (AllTrim( ( cAliasT )->CT1_NTSPED ) == "01")
					cNatureza := "ATIVO"
				Case (AllTrim( ( cAliasT )->CT1_NTSPED ) == "02")
					cNatureza := "PASSIVO"
				Case (AllTrim( ( cAliasT )->CT1_NTSPED ) == "03")
					cNatureza := "PATRIMONIO LIQUIDO"
				Case (AllTrim( ( cAliasT )->CT1_NTSPED ) == "04")
					cNatureza := "RESULTADO"
				Case (AllTrim( ( cAliasT )->CT1_NTSPED ) == "05")
					cNatureza := "COMPENSACAO"
				Case (AllTrim( ( cAliasT )->CT1_NTSPED ) == "09")
					cNatureza := "OUTROS"
			End case			
		
			FWRITE(	nHandle,	AllTrim( ( cAliasT )->CT1_FILIAL ) + AllTrim( ( cAliasT )->CT1_CONTA ) + ";" + ;
			       			AllTrim( ( cAliasT )->CT1_FILIAL )	+ ";" + ;
			       			AllTrim( ( cAliasT )->CT1_CONTA )	+ ";" + ;
			       			AllTrim( ( cAliasT )->CT1_DESC01 )	+ ";" + ;
			       			AllTrim( ( cAliasT )->CT1_CLASSE )	+ ";" + ;
			       			cNatureza + ";" + ;
			       			cExtracao + CRLF )
			nCont++
		
			( cAliasT )->( dbSkip() )
			
		EndDo
	
		cMsg += "Registros exportados do Plano de Contas (CT1): " + cValToChar( nCont ) + CRLF
		
	EndIf
	
	( cAliasT )->( dbCloseArea() )
	
	fClose( nHandle )
	
	If !lAuto
		oProcess:SaveLog( "Fim da Exportacao do Plano de Contas (CT1)" )
	EndIf
	
Return( cMsg )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ M010CTSExp ³ Autor ³ Denis Rodrigues  ³ Data ³  20/12/2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Processa a exportacao da Visoes Gerenciais CTS             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function M010CTSExp(oProcess,lAuto)

	Local cAliasT		:= GetNextAlias()
	Local cQuery 		:= ""
	Local cMsg 		:= ""
	Local cExtracao	:= DtoC( Date() ) + " - " + Time()
	Local nCont		:= 0
	Local nHandle		:= 0

	If !lAuto		
		oProcess:SaveLog("Inicio da Exportacao da Tabela de Visões Gerenciais (CTS)")
		oProcess:SetRegua1( 0 )
	Else
		ConOut("Inicio da Exportacao da Tabela de Visões Gerenciais (CTS) - SCHEDULE")	
	EndIf
	
	cQuery := " SELECT CTS_FILIAL,"
	cQuery += "        CTS_CODPLA,"			
	cQuery += "        CTS_ORDEM,"			
	cQuery += "        CTS_NORMAL,"
	cQuery += "        CTS_COLUNA,"
	cQuery += "        CTS_CLASSE,"
	cQuery += "        CTS_IDENT,"
	cQuery += "        CTS_NOME,"
	cQuery += "        CTS_CT1INI,"
	cQuery += "        CTS_CT1FIM"				
	cQuery += " FROM " + RetSQLName("CTS")
	cQuery += " WHERE D_E_L_E_T_<>'*'" 			 	
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T. )
	
	If ( cAliasT )->( !Eof() )
	
		nHandle := fCreate("\m010Exporta\visoesgerenciais_cts.csv", FC_NORMAL)
	
		//Titulo das colunas do arquivo
		FWRITE(	nHandle, "VISOESGERENCIAIS_KEY" + ";" + ;
			       		"CTS_FILIAL" 			+ ";" + ;
			       		"CTS_CODPLA"			+ ";" + ;
			       		"CTS_ORDEM"			+ ";" + ;
			       		"CTS_NORMAL"			+ ";" + ;
			       		"CTS_COLUNA"			+ ";" + ;
			       		"CTS_CLASSE"			+ ";" + ;
			       		"CTS_IDENT"			+ ";" + ;
			       		"CTS_NOME"			+ ";" + ;
			       		"CTS_CT1INI"			+ ";" + ;
			       		"CTS_CT1FIM"			+ ";" + ;
			       		"PLANOCONTAS1_KEY"		+ ";" + ;
			       		"PLANOCONTAS2_KEY"		+ ";" + ;
			       		"DATA_EXTRACAO"		+ CRLF )
		nCont++			       		
	
		While ( cAliasT )->( !Eof() )
		
			If !lAuto
				oProcess:IncRegua1("Exportando Visões Gerenciais..." )
			EndIf
		
			FWRITE(	nHandle,	( cAliasT )->CTS_FILIAL + ( cAliasT )->CTS_CODPLA + ( cAliasT )->CTS_ORDEM + ";" + ;
			       			AllTrim( ( cAliasT )->CTS_FILIAL )		+ ";" + ;
			       			AllTrim( ( cAliasT )->CTS_CODPLA )		+ ";" + ;
			       			AllTrim( ( cAliasT )->CTS_ORDEM )		+ ";" + ;
			       			AllTrim( ( cAliasT )->CTS_NORMAL )		+ ";" + ;
			       			AllTrim( Str( ( cAliasT )->CTS_COLUNA ) )	+ ";" + ;
			       			AllTrim( ( cAliasT )->CTS_CLASSE )		+ ";" + ;
			       			AllTrim( ( cAliasT )->CTS_IDENT )		+ ";" + ;
			       			AllTrim( ( cAliasT )->CTS_NOME )		+ ";" + ;
			       			AllTrim( ( cAliasT )->CTS_CT1INI )		+ ";" + ;
			       			AllTrim( ( cAliasT )->CTS_CT1FIM )		+ ";" + ;
			       			( cAliasT )->CTS_CT1INI 				+ ";" + ;
			       			( cAliasT )->CTS_CT1FIM 				+ ";" + ;
			       			cExtracao + CRLF )
			nCont++
		
			( cAliasT )->( dbSkip() )
			
		EndDo
	
		cMsg += "Registros exportados do Visões Gerenciais (CTS): " + cValToChar( nCont ) + CRLF
		
	EndIf
	
	( cAliasT )->( dbCloseArea() )
	
	fClose( nHandle )
	
	If !lAuto
		oProcess:SaveLog( "Fim da Exportacao do Visões Gerenciais (CTS)" )
	EndIf
	 
Return( cMsg )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ M010CV1Exp ³ Autor ³ Denis Rodrigues  ³ Data ³  20/12/2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Processa a exportacao dos Orçamentos CV1                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function M010CV1Exp(oProcess,lAuto)

	Local cAliasT		:= GetNextAlias()
	Local cQuery 		:= ""
	Local cMsg 		:= ""
	Local cExtracao	:= DtoC( Date() ) + " - " + Time()
	Local nCont		:= 0
	Local nHandle		:= 0

	If !lAuto		
		oProcess:SaveLog("Inicio da Exportacao da Tabela de Orçamentos (CV1)")
		oProcess:SetRegua1( 0 )
	Else
		ConOut("Inicio da Exportacao da Tabela de Orçamentos (CV1) - SCHEDULE")	
	EndIf
	
	cQuery := " SELECT CV1_FILIAL,"
	cQuery += "        CV1_ORCMTO,"			
	cQuery += "        CV1_DESCRI,"			
	cQuery += "        CV1_STATUS,"
	cQuery += "        CV1_CALEND,"
	cQuery += "        CV1_MOEDA,"
	cQuery += "        CV1_REVISA,"
	cQuery += "        CV1_SEQUEN,"
	cQuery += "        CV1_CT1INI,"
	cQuery += "        CV1_CT1FIM,"
	cQuery += "        CV1_CTTINI,"
	cQuery += "        CV1_CTTFIM,"
	cQuery += "        CV1_CTDINI,"
	cQuery += "        CV1_CTDFIM,"
	cQuery += "        CV1_CTHINI,"
	cQuery += "        CV1_CTHFIM,"
	cQuery += "        CV1_PERIOD,"
	cQuery += "        CV1_DTINI,"
	cQuery += "        CV1_DTFIM,"
	cQuery += "        CV1_VALOR,"
	cQuery += "        CV1_APROVA"				
	cQuery += " FROM " + RetSQLName("CV1")
	cQuery += " WHERE D_E_L_E_T_<>'*'" 			 	
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T. )
	
	If ( cAliasT )->( !Eof() )
	
		nHandle := fCreate("\m010Exporta\orcamentos_cv1.csv", FC_NORMAL)
	
		//Titulo das colunas do arquivo
		FWRITE(	nHandle, "ORCAMENTO_KEY" 		+ ";" + ;
			       		"CV1_FILIAL" 			+ ";" + ;
			       		"CV1_ORCMTO"			+ ";" + ;
			       		"CV1_DESCRI"			+ ";" + ;
			       		"CV1_STATUS"			+ ";" + ;
			       		"CV1_CALEND"			+ ";" + ;
			       		"CV1_MOEDA"			+ ";" + ;
			       		"CV1_REVISA"			+ ";" + ;
			       		"CV1_SEQUEN"			+ ";" + ;			       		
						"CENTROCUSTO_KEY"		+ ";" + ;	       		
			       		"CV1_PERIOD"			+ ";" + ;
			       		"CV1_DTINI"			+ ";" + ;			       		
			       		"CV1_VALOR"			+ ";" + ;
			       		"CV1_APROVA"			+ ";" + ;
			       		"PLANOCONTAS_INI_KEY"	+ ";" + ;
			       		"DATA_EXTRACAO"		+ CRLF )
		nCont++			       		
	
		While ( cAliasT )->( !Eof() )
		
			If !lAuto
				oProcess:IncRegua1("Exportando Orçamentos..." )
			EndIf
		
			FWRITE(	nHandle,	( cAliasT )->CV1_FILIAL + ( cAliasT )->CV1_ORCMTO + ( cAliasT )->CV1_CALEND + ( cAliasT )->CV1_MOEDA + ( cAliasT )->CV1_REVISA + ( cAliasT )->CV1_SEQUEN + ( cAliasT )->CV1_PERIOD + ";" + ;
			       			AllTrim( ( cAliasT )->CV1_FILIAL )							+ ";" + ;
			       			AllTrim( ( cAliasT )->CV1_ORCMTO )							+ ";" + ;
			       			AllTrim( ( cAliasT )->CV1_DESCRI )							+ ";" + ;
			       			AllTrim( ( cAliasT )->CV1_STATUS )							+ ";" + ;
			       			AllTrim( ( cAliasT )->CV1_CALEND )							+ ";" + ;
			       			AllTrim( ( cAliasT )->CV1_MOEDA )							+ ";" + ;
			       			AllTrim( ( cAliasT )->CV1_REVISA )							+ ";" + ;
			       			AllTrim( ( cAliasT )->CV1_SEQUEN )							+ ";" + ;
							AllTrim( xFilial("CTT") ) + AllTrim( ( cAliasT )->CV1_CTTINI )	+ ";" + ;
			       			AllTrim( ( cAliasT )->CV1_PERIOD )							+ ";" + ;		       						       						       			
			       			If( Empty( ( cAliasT )->CV1_DTINI ) ,"",AllTrim( DtoC( Stod( ( cAliasT )->CV1_DTINI ) ) ) )  + ";" + ;			       		
			       			AllTrim( Str( ( cAliasT )->CV1_VALOR ) )						+ ";" + ;
			       			AllTrim( ( cAliasT )->CV1_APROVA )							+ ";" + ;			       			
			       		    	AllTrim( xFilial("CT1") ) + AllTrim( ( cAliasT )->CV1_CT1INI )	+ ";" + ;			       			
			       			cExtracao + CRLF )
			nCont++
		
			( cAliasT )->( dbSkip() )
			
		EndDo
	
		cMsg += "Registros exportados do Orçamentos (CV1): " + cValToChar( nCont ) + CRLF
		
	EndIf
	
	( cAliasT )->( dbCloseArea() )
	
	fClose( nHandle )
	
	If !lAuto
		oProcess:SaveLog( "Fim da Exportacao dos Orçamentos (CV1)" )
	EndIf
		
Return( cMsg )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ M010SF4Exp ³ Autor ³ Denis Rodrigues  ³ Data ³  24/01/2017 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Processa a exportacao da Tabela de TES                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function M010SF4Exp(oProcess,lAuto)

	Local cAliasT		:= GetNextAlias()
	Local cQuery 		:= ""
	Local cMsg 		:= ""
	Local cBiReMes	:= ""
	Local cCodFisc	:= ""
	Local cExtracao	:= DtoC( Date() ) + " - " + Time()
	Local nCont		:= 0
	Local nHandle		:= 0

	If !lAuto		
		oProcess:SaveLog("Inicio da Exportacao da Tabela de TES (SF4)")
		oProcess:SetRegua1( 0 )
	Else
		ConOut("Inicio da Exportacao da Tabela de TES (SF4) - SCHEDULE")	
	EndIf
	
	cQuery := " SELECT F4_FILIAL,"
	cQuery += "        F4_CODIGO,"			
	cQuery += "        F4_TIPO,"			
	cQuery += "        F4_TEXTO,"
	cQuery += "        F4_CF,"
	cQuery += "        F4_ICM,"
	cQuery += "        F4_IPI,"
	cQuery += "        F4_CREDICM,"
	cQuery += "        F4_CREDIPI,"
	cQuery += "        F4_DUPLIC,"
	cQuery += "        F4_ESTOQUE,"	
	
	//Campos Customizados do cliente
	cQuery += "        F4_BIOPERA,"	
	cQuery += "        F4_BIREMES,"	
	cQuery += "        F4_PODER3,"
	cQuery += "        F4_ZVFUTUR,"
	cQuery += "        F4_ZRFUTUR"	
	//-----------------------------
				
	cQuery += " FROM " + RetSQLName("SF4")
	cQuery += " WHERE D_E_L_E_T_<>'*'" 			 	
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T. )
	
	If ( cAliasT )->( !Eof() )
	
		nHandle := fCreate("\m010Exporta\tes_sf4.csv", FC_NORMAL)
	
		//Titulo das colunas do arquivo
		FWRITE(	nHandle, "TES_KEY" 		+ ";" + ;
			       		"F4_FILIAL" 		+ ";" + ;
			       		"F4_CODIGO"		+ ";" + ;
			       		"F4_TIPO"			+ ";" + ;
			       		"F4_TEXTO"		+ ";" + ;
			       		"F4_CF"			+ ";" + ;
			       		"F4_ICM"			+ ";" + ;
			       		"F4_IPI"			+ ";" + ;
			       		"F4_CREDICM"		+ ";" + ;
			       		"F4_CREDIPI"		+ ";" + ;
			       		"F4_DUPLIC"		+ ";" + ;
						"F4_ESTOQUE"		+ ";" + ;
						"F4_BIOPERA"		+ ";" + ;
						"F4_BIREMES"		+ ";" + ;
						"F4_PODER3"		+ ";" + ;
						"F4_ZVFUTUR"		+ ";" + ;
						"F4_ZRFUTUR"		+ ";" + ;
			       		"DATA_EXTRACAO"	+ CRLF )
		nCont++			       		
	
		While ( cAliasT )->( !Eof() )
		
			If !lAuto
				oProcess:IncRegua1("Exportando TES..." )
			EndIf
			
			//+------------------------------+
			//| Descricao do Tipo de Remessa |
			//+------------------------------+
			dbSelectArea("SX5")
			dbSetOrder(1)//X5_FILIAL+X5_TABELA+X5_CHAVE
			If dbSeek( xFilial("SX5") + "ZY" + ( cAliasT )->F4_BIREMES )
				cBiRemes := AllTrim( SX5->X5_DESCRI )
			Else
				cBiReMes := ""
			EndIf
			
			//+----------------------------+
			//| Descricao do Codigo Fiscal |
			//+----------------------------+
			dbSelectArea("SX5")
			dbSetOrder(1)//X5_FILIAL+X5_TABELA+X5_CHAVE
			If dbSeek( xFilial("SX5") + "13" + ( cAliasT )->F4_CF )
				cCodFisc := AllTrim( SX5->X5_DESCRI )
			Else
				cCodFisc := ""
			EndIf			
					
			FWRITE(	nHandle,	AllTrim( ( cAliasT )->F4_FILIAL ) + AllTrim( ( cAliasT )->F4_CODIGO )	+ ";" + ;
							AllTrim( ( cAliasT )->F4_FILIAL )							+ ";" + ;
			       			AllTrim( ( cAliasT )->F4_CODIGO )							+ ";" + ;
			       			AllTrim( X3Combo( "F4_TIPO",( cAliasT )->F4_TIPO ) )			+ ";" + ;
			       			AllTrim( ( cAliasT )->F4_TEXTO )							+ ";" + ;
			       			AllTrim( cCodFisc )										+ ";" + ;
			       			AllTrim( X3Combo( "F4_ICM",( cAliasT )->F4_ICM ) )				+ ";" + ;
			       			AllTrim( X3Combo( "F4_IPI",( cAliasT )->F4_IPI ) )				+ ";" + ;
			       			AllTrim( X3Combo( "F4_CREDICM",( cAliasT )->F4_CREDICM ) )		+ ";" + ;
			       			AllTrim( X3Combo( "F4_CREDIPI",( cAliasT )->F4_CREDIPI ) )		+ ";" + ;
			       			AllTrim( X3Combo( "F4_DUPLIC",( cAliasT )->F4_DUPLIC ) )		+ ";" + ;
			       			AllTrim( X3Combo( "F4_ESTOQUE",( cAliasT )->F4_ESTOQUE ) )		+ ";" + ;
			       			AllTrim( X3Combo( "F4_BIOPERA",( cAliasT )->F4_BIOPERA ) )		+ ";" + ;   			
			       			AllTrim( cBiRemes )										+ ";" + ;
			       			AllTrim( X3Combo( "F4_PODER3",( cAliasT )->F4_PODER3 ) )		+ ";" + ;
			       			AllTrim( X3Combo( "F4_ZVFUTUR",( cAliasT )->F4_ZVFUTUR ) )		+ ";" + ;
			       			AllTrim( X3Combo( "F4_ZRFUTUR",( cAliasT )->F4_ZRFUTUR ) )		+ ";" + ;
			       			cExtracao + CRLF )
			nCont++
		
			( cAliasT )->( dbSkip() )
			
		EndDo
	
		cMsg += "Registros exportados da TES (SF4): " + cValToChar( nCont ) + CRLF
		
	EndIf
	
	( cAliasT )->( dbCloseArea() )
	
	fClose( nHandle )
	
	If !lAuto
		oProcess:SaveLog( "Fim da Exportacao da TES (SF4)" )
	EndIf
		
Return( cMsg )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ M010CTTExp ³ Autor ³ Denis Rodrigues  ³ Data ³  25/01/2017 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Processa a exportacao da Tabela de Centro de Custos        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function M010CTTExp(oProcess,lAuto)

	Local cAliasT		:= GetNextAlias()
	Local cQuery 		:= ""
	Local cMsg 		:= ""
	Local cExtracao	:= DtoC( Date() ) + " - " + Time()
	Local nCont		:= 0
	Local nHandle		:= 0

	If !lAuto		
		oProcess:SaveLog("Inicio da Exportacao da Tabela de Centro de Custos (CTT)")
		oProcess:SetRegua1( 0 )
	Else
		ConOut("Inicio da Exportacao da Tabela de Centro de Custos (CTT) - SCHEDULE")	
	EndIf
	
	cQuery := " SELECT CTT_FILIAL,"
	cQuery += "        CTT_CUSTO,"			
	cQuery += "        CTT_CLASSE,"			
	cQuery += "        CTT_NORMAL,"
	cQuery += "        CTT_DESC01,"
	cQuery += "        CTT_DESC02,"
	cQuery += "        CTT_DESC03,"
	cQuery += "        CTT_BLOQ,"
	cQuery += "        CTT_DTEXIS,"
	cQuery += "        CTT_CCLP,"
	cQuery += "        CTT_CCSUP"				
	cQuery += " FROM " + RetSQLName("CTT")
	cQuery += " WHERE D_E_L_E_T_<>'*'" 			 	
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T. )
	
	If ( cAliasT )->( !Eof() )
	
		nHandle := fCreate("\m010Exporta\centrocustos_ctt.csv", FC_NORMAL)
	
		//Titulo das colunas do arquivo
		FWRITE(	nHandle, "CENTROCUSTO_KEY"	+ ";" + ;
			       		"CTT_FILIAL" 		+ ";" + ;
			       		"CTT_CUSTO"		+ ";" + ;
			       		"CTT_CLASSE"		+ ";" + ;
			       		"CTT_NORMAL"		+ ";" + ;
			       		"CTT_DESC01"		+ ";" + ;
			       		"CTT_DESC02"		+ ";" + ;
			       		"CTT_DESC03"		+ ";" + ;
			       		"CTT_BLOQ"		+ ";" + ;
			       		"CTT_DTEXIS"		+ ";" + ;
			       		"CTT_CCLP"		+ ";" + ;
						"CTT_CCSUP"		+ ";" + ;
			       		"DATA_EXTRACAO"	+ CRLF )
		nCont++			       		
	
		While ( cAliasT )->( !Eof() )
		
			If !lAuto
				oProcess:IncRegua1("Exportando Centro de Custos..." )
			EndIf
		
			FWRITE(	nHandle,	AllTrim( ( cAliasT )->CTT_FILIAL ) + AllTrim( ( cAliasT )->CTT_CUSTO )	+ ";" + ;
			       			AllTrim( ( cAliasT )->CTT_FILIAL )				+ ";" + ;
			       			AllTrim( ( cAliasT )->CTT_CUSTO )				+ ";" + ;
			       			AllTrim( ( cAliasT )->CTT_CLASSE )				+ ";" + ;
			       			AllTrim( ( cAliasT )->CTT_NORMAL )				+ ";" + ;
			       			AllTrim( ( cAliasT )->CTT_DESC01 )				+ ";" + ;
			       			AllTrim( ( cAliasT )->CTT_DESC02 )				+ ";" + ;
			       			AllTrim( ( cAliasT )->CTT_DESC03 )				+ ";" + ;
			       			AllTrim( ( cAliasT )->CTT_BLOQ )				+ ";" + ;
			       			If( Empty( ( cAliasT )->CTT_DTEXIS ) ,"",AllTrim( DtoC( Stod( ( cAliasT )->CTT_DTEXIS ) ) ) )  + ";" + ;//If( Empty( ( cAliasT )->CTT_DTEXIS ) ,"",AllTrim( DtoC( GravaData( Stod( ( cAliasT )->CTT_DTEXIS ),.T.,5 ) ) ) )  + ";" + ;			       			
			       			AllTrim( ( cAliasT )->CTT_CCLP )				+ ";" + ;	       			
			       			AllTrim( ( cAliasT )->CTT_CCSUP )				+ ";" + ;
			       			cExtracao + CRLF )
			nCont++
		
			( cAliasT )->( dbSkip() )
			
		EndDo
	
		cMsg += "Registros exportados do Centro de Custos (CTT): " + cValToChar( nCont ) + CRLF
		
	EndIf
	
	( cAliasT )->( dbCloseArea() )
	
	fClose( nHandle )
	
	If !lAuto
		oProcess:SaveLog( "Fim da Exportacao do Centro de Custos (CTT)" )
	EndIf
		
Return( cMsg )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ M010SCTExp ³ Autor ³ Denis Rodrigues  ³ Data ³  25/01/2017 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Processa a exportacao da Tabela de Meta de Vendas          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function M010SCTExp(oProcess,lAuto)

	Local cAliasT		:= GetNextAlias()
	Local cQuery 		:= ""
	Local cMsg 		:= ""
	Local cNomReg		:= ""
	Local cNomCat		:= ""
	Local cExtracao	:= DtoC( Date() ) + " - " + Time()
	Local cCodProd	:= ""
	Local nCont		:= 0
	Local nHandle		:= 0

	If !lAuto		
		oProcess:SaveLog("Inicio da Exportacao da Tabela de Meta de Vendas (SCT)")
		oProcess:SetRegua1( 0 )
	Else
		ConOut("Inicio da Exportacao da Tabela de Meta de Vendas (SCT) - SCHEDULE")	
	EndIf
	
	cQuery := " SELECT CT_FILIAL,"
	cQuery += "        CT_DOC,"			
	cQuery += "        CT_SEQUEN,"			
	cQuery += "        CT_DESCRI,"
	cQuery += "        CT_DATA,"
	cQuery += "        CT_VEND,"
	cQuery += "        CT_REGIAO,"
	cQuery += "        CT_CATEGO,"
	cQuery += "        CT_TIPO,"
	cQuery += "        CT_GRUPO,"
	cQuery += "        CT_PRODUTO,"				
	cQuery += "        CT_QUANT,"
	cQuery += "        CT_VALOR,"
	cQuery += "        CT_MARCA,"
	cQuery += "        CT_DESMARC,"
	cQuery += "        CT_GERENTE,"
	cQuery += "        CT_SUPERVI,"
	cQuery += "        CT_TPOPER,"
	cQuery += "        CT_VALOR2,"
	cQuery += "        CT_NOMGER,"
	cQuery += "        CT_NOMSUP,"
	cQuery += "        CT_ITEMCC,"
	cQuery += "        CT_CCUSTO,"
	cQuery += "        CT_MOEDA"
	cQuery += " FROM " + RetSQLName("SCT")
	cQuery += " WHERE D_E_L_E_T_<>'*'" 			 	
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T. )
	
	If ( cAliasT )->( !Eof() )
	
		nHandle := fCreate("\m010Exporta\metadevendas_sct.csv", FC_NORMAL)
	
		//Titulo das colunas do arquivo
		FWRITE(	nHandle, "METADEVENDAS_KEY"	+ ";" + ;
			       		"CT_FILIAL" 		+ ";" + ;
			       		"CT_DOC"			+ ";" + ;
			       		"CT_SEQUEN"		+ ";" + ;
			       		"CT_DESCRI"		+ ";" + ;
			       		"CT_DATA"			+ ";" + ;
			       		"VENDEDOR_KEY"	+ ";" + ;
			       		"CT_REGIAO"		+ ";" + ;
			       		"CT_CATEGO"		+ ";" + ;
			       		"CT_TIPO"			+ ";" + ;			       		
						"PRODUTO_KEY"		+ ";" + ;
						"CT_QUANT"		+ ";" + ;
						"CT_VALOR"		+ ";" + ;
						"CT_MOEDA"		+ ";" + ;
						"CT_MARCA"		+ ";" + ;
						"CT_DESMARC"	+ ";" + ;
						"CT_GERENTE"	+ ";" + ;
						"CT_NOMEGERNTE"	+ ";" + ;
						"CT_SUPERVI"	+ ";" + ;
						"CT_NOMESUPERVISOR"	+ ";" + ;
						"CT_TPOPER"		+ ";" + ;
						"CT_VALOR2"		+ ";" + ;
						"CT_GRUPO"		+ ";" + ;
						"CT_ITEMCC"		+ ";" + ;
						"CT_CCUSTO"		+ ";" + ;
			       		"DATA_EXTRACAO"	+ CRLF )
		nCont++			       		
	
		While ( cAliasT )->( !Eof() )
		
			If !lAuto
				oProcess:IncRegua1("Exportando Meta de Vendas..." )
			EndIf
			
			//+-------------------------------+
			//| Retorna a descricao da Regiao |
			//+-------------------------------+
			dbSelectArea("SX5")
			dbSetOrder(1)//X5_FILIAL+X5_TABELA+X5_CHAVE
			If dbSeek( xFilial("SX5") + "A2" + ( cAliasT )->CT_REGIAO )
				cNomReg := AllTrim( SX5->X5_DESCRI )
			Else
				cNomReg := ""
			EndIf
			
			//+----------------------------------+
			//| Retorna a descricao da Categoria |
			//+----------------------------------+
			dbSelectArea("ACU")
			dbSetOrder(1)//ACU_FILIAL+ACU_COD
			If dbSeek( xFilial("ACU") + ( cAliasT )->CT_CATEGO )
				cNomCat := AllTrim( ACU->ACU_DESC )
			Else
				cNomCat := ""
			EndIf
			
			If !Empty( ( cAliasT )->CT_PRODUTO )
				cCodProd := AllTrim( xFilial("SB1") ) + AllTrim( ( cAliasT )->CT_PRODUTO )				
			EndIf
					
			FWRITE(	nHandle,	( cAliasT )->CT_FILIAL + ( cAliasT )->CT_DOC + ( cAliasT )->CT_SEQUEN	+ ";" + ;
			       			AllTrim( ( cAliasT )->CT_FILIAL )			+ ";" + ;
			       			AllTrim( ( cAliasT )->CT_DOC )				+ ";" + ;
			       			AllTrim( ( cAliasT )->CT_SEQUEN )			+ ";" + ;
			       			AllTrim( ( cAliasT )->CT_DESCRI )			+ ";" + ;
			       			If( Empty( ( cAliasT )->CT_DATA ) ,"",AllTrim( DtoC( Stod( ( cAliasT )->CT_DATA ) ) ) )  + ";" + ;
			       			AllTrim( xFilial("SA3") ) + AllTrim( ( cAliasT )->CT_VEND )		+ ";" + ;
			       			cNomReg									+ ";" + ;
			       			cNomCat									+ ";" + ;
			       			AllTrim( ( cAliasT )->CT_TIPO )				+ ";" + ;			       				       			
			       			cCodprod									+ ";" + ;			       			
			       			AllTrim( Str( ( cAliasT )->CT_QUANT ) )		+ ";" + ;
			       			AllTrim( Str( ( cAliasT )->CT_VALOR ) )		+ ";" + ;
			       			AllTrim( Str( ( cAliasT )->CT_MOEDA ) )		+ ";" + ;
			       			AllTrim( ( cAliasT )->CT_MARCA )			+ ";" + ;
							AllTrim( ( cAliasT )->CT_DESMARC )			+ ";" + ;
							AllTrim( ( cAliasT )->CT_GERENTE )			+ ";" + ;
							AllTrim( ( cAliasT )->CT_NOMGER )			+ ";" + ;
							AllTrim( ( cAliasT )->CT_SUPERVI )			+ ";" + ;
							AllTrim( ( cAliasT )->CT_NOMSUP )			+ ";" + ;
							AllTrim( ( cAliasT )->CT_TPOPER )			+ ";" + ;
							AllTrim( Str( ( cAliasT )->CT_VALOR2 ) )	+ ";" + ;
							AllTrim( ( cAliasT )->CT_GRUPO )			+ ";" + ;
							AllTrim( ( cAliasT )->CT_ITEMCC )			+ ";" + ;
							AllTrim( ( cAliasT )->CT_CCUSTO )			+ ";" + ;
							cExtracao + CRLF )
			nCont++
		
			( cAliasT )->( dbSkip() )
			
		EndDo
	
		cMsg += "Registros exportados da Meta de Vendas (SCT): " + cValToChar( nCont ) + CRLF
		
	EndIf
	
	( cAliasT )->( dbCloseArea() )
	
	fClose( nHandle )
	
	If !lAuto
		oProcess:SaveLog( "Fim da Exportacao da Meta de Vendas (SCT)" )
	EndIf
		
Return( cMsg )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ M010DA0Exp ³ Autor ³ Denis Rodrigues  ³ Data ³  21/02/2017 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Processa a exportacao da Tabela de Precos                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function M010DA0Exp(oProcess,lAuto)

	Local cAliasT		:= GetNextAlias()
	Local cQuery 		:= ""
	Local cMsg 		:= ""
	Local cCodProd	:= ""
	Local cExtracao	:= DtoC( Date() ) + " - " + Time()
	Local nCont		:= 0

	If !lAuto		
		oProcess:SaveLog("Inicio da Exportacao da Tabela de Preços (DA0/DA1)")
		oProcess:SetRegua1( 0 )
	Else
		ConOut("Inicio da Exportacao da Tabela de Precos (DA0/DA1) - SCHEDULE")	
	EndIf
	
    // --- Atualiza a tabela 024 preco de custo ---
	 U_MAH0181()
    // --------------------------------------------
	cQuery := " SELECT DA0.DA0_FILIAL,"
	cQuery += "        DA0.DA0_CODTAB,"
	cQuery += "        DA0.DA0_DESCRI,"
	cQuery += "        DA1.DA1_CODPRO,"
	cQuery += "        DA1.DA1_PRCVEN,"
	cQuery += "        DA1.DA1_ITEM,"
	cQuery += "        DA1.DA1_MOEDA"
	cQuery += " FROM " + RetSQLName("DA0") + " DA0"
	cQuery += " INNER JOIN " + RetSQLName("DA1") + " DA1"
	cQuery += " ON DA0.DA0_FILIAL = DA1.DA1_FILIAL"
	cQuery += " AND DA0_CODTAB = DA1.DA1_CODTAB"
	cQuery += " WHERE DA0.D_E_L_E_T_ <> '*'"
	cQuery += "   AND DA1.D_E_L_E_T_ <> '*'"
	cQuery += "   AND DA0.DA0_ATIVO = '1' "
	cQuery += "   AND DA1.DA1_ITEM=(SELECT MAX(DA1MAX.DA1_ITEM) FROM DA1010 DA1MAX WHERE DA1.DA1_CODTAB=DA1MAX.DA1_CODTAB AND DA1.DA1_CODPRO=DA1MAX.DA1_CODPRO AND DA1MAX.D_E_L_E_T_<>'*')
	//cQuery += "   AND DA1.DA1_MOEDA = '1'"
	 			 	
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T. )
	
	If ( cAliasT )->( !Eof() )
	
		nHandle := fCreate("\m010Exporta\tabelaprecos_da0da1.csv", FC_NORMAL)
	
		//Titulo das colunas do arquivo
		FWRITE(	nHandle, "TABELAPRECO_KEY"	+ ";" + ;
			       		"DA0_FILIAL" 		+ ";" + ;
			       		"DA0_CODTAB"		+ ";" + ;
			       		"DA0_DESCRI"		+ ";" + ;
			       		"DA1_ITEM"	   		+ ";" + ;
			       		"PRODUTO_KEY"		+ ";" + ;
			       		"DA1_PRCVEN"		+ ";" + ;
			       		"MOEDA_KEY"			+ ";" + ;			       		
			       		"DATA_EXTRACAO"	+ CRLF )
		nCont++			       		
	
		While ( cAliasT )->( !Eof() )
		
			If !lAuto
				oProcess:IncRegua1("Exportando Tabela de Preços..." )
			EndIf
			
			dbSelectArea("SB1")
			dbSetOrder(1)//B1_FILIAL+B1_COD
			If dbSeek( xFilial("SB1") + ( cAliasT )->DA1_CODPRO )
				cCodProd := AllTrim( xFilial("SB1") ) + AllTrim( ( cAliasT )->DA1_CODPRO )				
			EndIf
					
			FWRITE(	nHandle,	( cAliasT )->DA0_FILIAL + ( cAliasT )->DA0_CODTAB + ( cAliasT )->DA1_ITEM + ( cAliasT )->DA1_CODPRO + ";" + ;
							AllTrim( ( cAliasT )->DA0_FILIAL )				+ ";" + ;
			       			AllTrim( ( cAliasT )->DA0_CODTAB )				+ ";" + ;
			       			AllTrim( ( cAliasT )->DA0_DESCRI )				+ ";" + ;			       			
			       			AllTrim( ( cAliasT )->DA1_ITEM )				+ ";" + ;			       						       			
			       			cCodProd										+ ";" + ;			       						       			
			       			AllTrim( Str( ( cAliasT )->DA1_PRCVEN ) )			+ ";" + ; 
			       			AllTrim( Str( ( cAliasT )->DA1_MOEDA ) )			+ ";" + ;
			       			cExtracao + CRLF )
			nCont++
		
			( cAliasT )->( dbSkip() )
			
		EndDo
	
		cMsg += "Registros exportados da Tabela de Preços (DA0/DA1): " + cValToChar( nCont ) + CRLF
		
	EndIf
	
	( cAliasT )->( dbCloseArea() )
	
	fClose( nHandle )
	
	If !lAuto
		oProcess:SaveLog( "Fim da Exportacao da Tabela de Preços (DA0/DA1)" )
	EndIf
		
Return( cMsg )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ M010SM0Exp ³ Autor ³ Denis Rodrigues  ³ Data ³  21/02/2017 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Processa a exportacao da Tabela de Filiais do Sistema      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function M010SM0Exp(oProcess,lAuto)

	Local cMsg 		:= ""
	Local cExtracao	:= DtoC( Date() ) + " - " + Time()
	Local nCont		:= 0
	Local nHandle		:= 0

	If !lAuto		
		oProcess:SaveLog("Inicio da Exportacao da Tabela de Filiais (SM0)")
		oProcess:SetRegua1( 0 )
	Else
		ConOut("Inicio da Exportacao da Tabela de Filiais (SM0) - SCHEDULE")	
	EndIf
	
	dbSelectArea("SM0")
	
	nHandle := fCreate("\m010Exporta\estabelecimento_sm0.csv", FC_NORMAL)

	//Titulo das colunas do arquivo
	FWRITE(	nHandle, "ESTABELECIMENTO_KEY"	+ ";" + ;
		       		"GRUPO_EMPRESA" 		+ ";" + ;
		       		"EMPRESA"				+ ";" + ;
		       		"CODIGO"				+ ";" + ;
		       		"DESCRICAO"			+ ";" + ;
		       		"DATA_EXTRACAO"		+ CRLF )
	nCont++
			
	While SM0->( !Eof() )

		If !lAuto
			oProcess:IncRegua1("Exportando Tabela de Filiais..." )
		EndIf
					
		FWRITE(	nHandle,	AllTrim( SM0->M0_CODFIL )				+ ";" + ;
		       			AllTrim( SM0->M0_CODIGO )				+ ";" + ;
		       			AllTrim( SM0->M0_CODIGO )				+ ";" + ;
		       			AllTrim( SubStr( SM0->M0_CODFIL, 3, 2 ) )	+ ";" + ;
		       			AllTrim( SM0->M0_FILIAL )				+ ";" + ;
		       			cExtracao + CRLF )
		nCont++			       		
	
		SM0->( dbSkip() )
		
	EndDo
	
	cMsg += "Registros exportados da Tabela de Filiais (SM0): " + cValToChar( nCont ) + CRLF
			
	fClose( nHandle )
	
	If !lAuto
		oProcess:SaveLog( "Fim da Exportacao da Tabela de Filiais (SM0)" )
	EndIf
		
Return( cMsg )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Original  ³ M010ExpFAT     ³ Autor | Giovanni Melo   ³ Data ³01/11/2016³±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ M010SF1Exp     ³ Autor | Denis Rodrigues ³ Data ³13/03/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Exportacao Documento de Entrada                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/   
Static Function M010SF1Exp(oProcess,lAuto)

	Local cQuery		:= ""
	Local cMsg			:= ""
	Local nCont 		:= 0 
	Local nHandle		:= 0
	Local aDtEmis		:= StrTokArr( GetMV("TRS_M010FT"),"|" )
	Local cExtracao	:= DtoC( Date() ) + " - " + Time()
	//Local cAuxVend	:= ""
	
	//+---------------------------------------+
	//| EXPORTACAO DO CADASTRO DE NOTA ENTRADA|
	//+---------------------------------------+
	If !lAuto
		oProcess:SaveLog("Inicio da Exportacao do Documento de Entrada (SF1)")
		oProcess:SetRegua1( 0 )
	Else
		ConOut("Inicio da Exportacao do Documento de Entrada (SF1) - SCHEDULE")
	EndIf
	 
	cQuery := " SELECT		D2_FILIAL Filial,"
	cQuery += "			D2_EST Estado,"
	cQuery += "			D2_TIPO	TipoNota,"
	cQuery += "			D2_SERIE SerieNota,"
	cQuery += "			D2_DOC NroNota,"
	cQuery += "			D2_ITEM	Item,"
	cQuery += "			D2_COD CodProduto,"
/*	cQuery += "			REPLACE(B1_DESC,',','') DescProduto,"*/
	cQuery += "			D2_LOCAL LocalProduto,"
	cQuery += "			D2_TES TES,"
	cQuery += "			F4_CF+'-'+F4_TEXTO CFOP,"
	cQuery += "			F4_DUPLIC GeraDuplicata,"
/*	cQuery += "			D2_TP TipoProduto,"
	cQuery += "			D2_GRUPO GrupoProduto,"*/
	cQuery += "			D2_CONTA ContaContabil,"
	cQuery += "			D2_EMISSAO DataEmissao,"
	cQuery += "			SUBSTRING(D2_EMISSAO,1,6) DataReserva,"
	cQuery += "			D2_QUANT Quantidade,"
	cQuery += "			D2_TOTAL ValorTotal,"
	cQuery += "			D2_VALBRUT ValorBruto,"
	cQuery += "			Case  "
    cQuery += "			   When F4_BIOPERA ='02' THEN 0 "
	cQuery += "			   When F4_BIOPERA<>'02' THEN D2_CUSTO1 "
    cQuery += "			end as ValorCusto, "
	cQuery += "			D2_VALIPI ValorIPI,"
	cQuery += "			D2_PRCVEN PrecoVenda,"
	cQuery += "			D2_CLIENTE CodCliente,"
	/*cQuery += "			A1_NOME+A1_LOJA	NomeCliente,"*/
	cQuery += "			D2_LOJA	LojaCliente,"
	cQuery += "			A3_COD	Vendedor,"
	cQuery += "			F2_MOEDA Moeda,"
	cQuery += "			F2_TXMOEDA TaxaMoeda,"
	/*cQuery += "			B1_MARCA MarcaProduto,"*/
	cQuery += "			D2_VALICM+D2_VALIMP1+D2_VALIMP2+D2_VALIMP3+D2_VALIMP4+D2_VALIMP5+D2_VALIMP6 ValorImpostos"
	cQuery += " FROM	" +	RetSqlName("SD2") + " SD2, " 
	cQuery += 			RetSqlName("SF2") + " SF2, " 
	cQuery += 			RetSqlName("SB1") + " SB1, " 
	cQuery += 			RetSqlName("SA1") + " SA1, " 
	cQuery += 			RetSqlName("SA3") + " SA3, " 
	cQuery += 			RetSqlName("SF4") + " SF4"
	cQuery += " WHERE	D2_EMISSAO	  	  >= '" + aDtEmis[1] + "'"
	cQuery += " AND		D2_EMISSAO	  <= '" + aDtEmis[2] + "'" 
	cQuery += " AND		D2_ORIGLAN	  <> 'LF'"
	cQuery += " AND		D2_TIPO		  = 'D'"
	cQuery += " AND		SF2.F2_FILIAL   = D2_FILIAL" 
	cQuery += " AND		SF2.F2_DOC      = SD2.D2_DOC"
	cQuery += " AND		SF2.F2_SERIE    = SD2.D2_SERIE" 
	cQuery += " AND		SF2.F2_CLIENTE  = SD2.D2_CLIENTE"
	cQuery += " AND		SF2.F2_LOJA     = SD2.D2_LOJA"
	cQuery += " AND		SB1.B1_FILIAL   = '" + xFilial("SB1") + "'"
	cQuery += " AND		SB1.B1_COD      = SD2.D2_COD"
	cQuery += " AND		SA1.A1_FILIAL   = '" + xFilial("SA1") + "'"
	cQuery += " AND		SA1.A1_COD      = SD2.D2_CLIENTE"	
	cQuery += " AND		SA1.A1_LOJA     = SD2.D2_LOJA"
	cQuery += " AND		SA3.A3_FILIAL   = '" + xFilial("SA3") + "'"
	cQuery += " AND		SA3.A3_COD      = SF2.F2_VEND1"
	cQuery += " AND		SF4.F4_FILIAL   = D2_FILIAL"
	cQuery += " AND		F4_CODIGO       = D2_TES"
	cQuery += " AND		SD2.D_E_L_E_T_  = ''"
	cQuery += " AND		SF2.D_E_L_E_T_  = ''"
	cQuery += " AND		SA1.D_E_L_E_T_  = ''"
	cQuery += " AND		SB1.D_E_L_E_T_  = ''"
	cQuery += " AND		SA3.D_E_L_E_T_  = ''"
	cQuery += " AND		SF4.D_E_L_E_T_  = ''"	

	cQuery := ChangeQuery(cQuery)                           
	dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQuery), "FAT", .F., .T.) // executa query
    
	If FAT->( !Eof() )

		nHandle := fCreate("\m010Exporta\documentoentrada_SF1.csv", FC_NORMAL)		

		//Titulo das colunas do arquivo
		FWRITE(	nHandle,	"ESTABELECIMENTO_KEY"	+ ";" + ;
			       		"ESTADO" 				+ ";" + ;
			       		"TIPO_NOTA"			+ ";" + ;
			       		"SERIE_NOTA"    		+ ";" + ;          
			       		"NRO_NOTA"	         + ";" + ;
			       		"ITEM"  	  			+ ";" + ;
			       		"ARMAZEM_KEY"  		+ ";" + ;
			       		"TES_KEY"		     	+ ";" + ;
			       		"CFOP"		 		+ ";" + ;
			       		"GERA_DUPLICATA"		+ ";" + ;
			       		"DATA_EMISSAO"	    	+ ";" + ;
			       		"DATA_RESERVA"		+ ";" + ;
			       		"QUANTIDADE"			+ ";" + ;
			       		"VALOR_TOTAL"          + ";" + ;
			       		"VALOR_BRUTO"      	+ ";" + ;
			       		"VALOR_CUSTO"  		+ ";" + ;
			       		"VALOR_IPI"     		+ ";" + ;
			       		"PRECO_VENDA"			+ ";" + ;
			       		"MOEDA"				+ ";" + ;
			       		"TAXA_MOEDA"			+ ";" + ;
			       		"VALOR_IMPOSTOS"  		+ ";" + ;			       		
			       		"PRODUTO_KEY"  		+ ";" + ;
			       		"VENDEDOR_KEY"  		+ ";" + ;
			       		"PLANOCONTAS_KEY" 		+ ";" + ;			       		
			       		"FORNECEDOR_KEY"		+ ";" + ;
			       		"NUMPEDCOMPRA"		+ ";" + ;
			       		"ITEMPEDCOMPRA"		+ ";" + ;
			       		"MOEDA_KEY"			+ ";" + ;
			       		"DATA_EXTRACAO"		+ CRLF ) 
	
		While FAT->( !Eof() )
	                               
			If !lAuto
				oProcess:IncRegua1( "Exportando Documento de Entrada..." )
			EndIf
		 		                                 
			/*DbSelectArea('SX5')
			DbSetOrder(1)
			DbSeek(xFilial("SX5") + 'ZX' + FAT->MarcaProduto )
			cAuxMarca := SX5->X5_DESCRI	                       */                                       
			  
			DbSelectArea('FAT')
       
	   		FWRITE(	nHandle,	AllTrim( StrTran(FAT->Filial,","," ") ) 											+ ";" + ;			
							AllTrim( StrTran(FAT->Estado,","," ") )											+ ";" + ;
							AllTrim( StrTran(FAT->TipoNota,","," ") )											+ ";" + ;
							AllTrim( StrTran(FAT->SerieNota,","," ") )										+ ";" + ;
							AllTrim( StrTran(FAT->NroNota,","," ") )											+ ";" + ;
							AllTrim( StrTran(FAT->Item,","," ") )											+ ";" + ;
							AllTrim( StrTran(FAT->Filial,","," ") ) + AllTrim( StrTran(FAT->LocalProduto,","," ") )				+ ";" + ;
							AllTrim( StrTran(FAT->Filial,","," ") ) + AllTrim( StrTran(FAT->TES,","," ") )					+ ";" + ;
							AllTrim( StrTran(FAT->CFOP,","," ") )											+ ";" + ;
							AllTrim( StrTran(FAT->GeraDuplicata,","," ") )									+ ";" + ;
							If(Empty(FAT->DataEmissao),"",AllTrim( DtoC( Stod(FAT->DataEmissao) ) )) 				+ ";" + ;
							If(Empty(FAT->DataReserva),"",AllTrim( DtoC( Stod(FAT->DataReserva) ) )) 				+ ";" + ;
							AllTrim( Str(FAT->Quantidade) ) 												+ ";" + ;
							AllTrim( Str(FAT->ValorTotal) )													+ ";" + ;
							AllTrim( Str(FAT->ValorBruto) )													+ ";" + ;
							AllTrim( Str(FAT->ValorCusto) )													+ ";" + ;
							AllTrim( Str(FAT->ValorIPI) )													+ ";" + ;
							AllTrim( Str(FAT->PrecoVenda) )													+ ";" + ;
							AllTrim( Str(FAT->Moeda) )														+ ";" + ;
							AllTrim( Str(FAT->TaxaMoeda) )													+ ";" + ;
							AllTrim( Str(FAT->ValorImpostos) )												+ ";" + ;  							
							AllTrim( xFilial("SB1") ) + AllTrim( FAT->CodProduto )								+ ";" + ;
							AllTrim( xFilial("SA3") ) + AllTrim( FAT->Vendedor )								+ ";" + ;
							AllTrim( xFilial("CT1") ) + AllTrim( FAT->ContaContabil ) 							+ ";" + ;
							AllTrim( xFilial("SA2") ) + AllTrim( FAT->CodCliente ) + AllTrim( FAT->LojaCliente )	+ ";" + ;
							""						   													+ ";" + ;
							""																			+ ";" + ;
							AllTrim( Str(FAT->Moeda) )														+ ";" + ; 								 								 
 			       	 		cExtracao + CRLF )
    
			nCont++
		
			FAT->( dbSkip() )
			
		EndDo	    
  		FAT->( dbCloseArea() )     
  		
	EndIf	

	cQuery := " SELECT	D1_FILIAL Filial,"
	cQuery += "			F1_EST Estado,"
	cQuery += "			D1_TIPO	TipoNota,"
	cQuery += "			D1_SERIE SerieNota,"
	cQuery += "			D1_DOC NroNota,"
	cQuery += "			D1_ITEM	Item,"
	cQuery += "			D1_COD CodProduto,"
/*	cQuery += "			REPLACE(B1_DESC,',','') DescProduto,"*/
	cQuery += "			D1_LOCAL LocalProduto,"
	cQuery += "			D1_TES TES,"
	cQuery += "			F4_CF+'-'+F4_TEXTO CFOP,"
	cQuery += "			F4_DUPLIC GeraDuplicata,"
/*	cQuery += "			D1_TP TipoProduto,"
	cQuery += "			D1_GRUPO GrupoProduto,"*/
	cQuery += "			D1_CONTA ContaContabil,"
	cQuery += "			D1_EMISSAO DataEmissao,"
	cQuery += "			SUBSTRING(D1_EMISSAO,1,6) DataReserva,"
	cQuery += "			D1_QUANT Quantidade,"
	cQuery += "			D1_TOTAL ValorTotal,"
	cQuery += "			D1_TOTAL ValorBruto,"
	cQuery += "			Case  "
    cQuery += "			   When F4_BIOPERA ='02' THEN 0 "
	cQuery += "			   When F4_BIOPERA<>'02' THEN D1_CUSTO "
    cQuery += "			end as ValorCusto, "
	cQuery += "			D1_VALIPI ValorIPI,"
	cQuery += "			D1_VUNIT PrecoVenda,"
	cQuery += "			D1_FORNECE CodCliente,"
/*	cQuery += "			A1_NOME+A1_LOJA	NomeCliente,"*/
	cQuery += "			D1_LOJA	LojaCliente,"
	cQuery += "			' '	Vendedor,"
	cQuery += "			F1_MOEDA Moeda,"
	cQuery += "			F1_TXMOEDA TaxaMoeda,"
/*	cQuery += "			B1_MARCA MarcaProduto,"*/
	cQuery += "			D1_NFORI NFOri,"
	cQuery += "			D1_SERIORI SeriOri,"
	cQuery += "			D1_VALIMP1 ValorImpostos,"
	
	cQuery += "			D1_PEDIDO NumPedCompra,"
	cQuery += "			D1_ITEMPC ItemPedCompra"
	
	cQuery += " FROM	" +	RetSqlName("SD1")	+ " SD1, " 
	cQuery += 			RetSqlName("SF1")	+ " SF1, " 
	cQuery += 			RetSqlName("SB1")	+ " SB1, " 
	cQuery += 			RetSqlName("SA1")	+ " SA1, " 
	cQuery += 			RetSqlName("SF4")	+ " SF4"
	cQuery += " WHERE	D1_EMISSAO			>= '" + aDtEmis[1] + "'"
	cQuery += " AND		D1_EMISSAO		<= '" + aDtEmis[2] + "'" 
	cQuery += " AND		D1_ORIGLAN		<> 'LF'"
	cQuery += " AND		D1_TIPO			<> 'D'"
	cQuery += " AND		SF1.F1_FILIAL		= D1_FILIAL" 
	cQuery += " AND		SF1.F1_DOC      	= SD1.D1_DOC"
	cQuery += " AND		SF1.F1_SERIE    	= SD1.D1_SERIE" 
	cQuery += " AND		SF1.F1_FORNECE	= SD1.D1_FORNECE"
	cQuery += " AND		SF1.F1_LOJA		= SD1.D1_LOJA"
	cQuery += " AND		SB1.B1_FILIAL		= '" + xFilial("SB1") + "'"
	cQuery += " AND		SB1.B1_COD		= SD1.D1_COD"
	cQuery += " AND		SA1.A1_FILIAL		= '" + xFilial("SA1") + "'"
	cQuery += " AND		SA1.A1_COD		= SD1.D1_FORNECE"	
	cQuery += " AND		SA1.A1_LOJA		= SD1.D1_LOJA"
	cQuery += " AND		SF4.F4_FILIAL		= D1_FILIAL"
	cQuery += " AND		F4_CODIGO			= D1_TES"
	cQuery += " AND		SD1.D_E_L_E_T_	= ''"
	cQuery += " AND		SF1.D_E_L_E_T_	= ''"
	cQuery += " AND		SA1.D_E_L_E_T_	= ''"
	cQuery += " AND		SB1.D_E_L_E_T_	= ''"
	cQuery += " AND		SF4.D_E_L_E_T_	= ''"	

	cQuery := ChangeQuery(cQuery)                           
	dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQuery), "FAT", .F., .T.) // executa query        
	
	While FAT->( !Eof() )
                               
		If !lAuto
			oProcess:IncRegua1( "Exportando Documento de Entrada..." )
		EndIf                    
  
/*			DbSelectArea('SF2')
			DbSetOrder(1)
			DbSeek(xFilial("SF2") + FAT->NFOri + FAT->SeriOri + FAT->CodCliente + FAT->LojaCliente)	 
			cAuxVend := SF2->F2_VEND1	                                                              
	
			DbSelectArea('SA3')
			DbSetOrder(1)
			DbSeek(xFilial("SA3") + cAuxVend)
			cAuxVend := SA3->A3_NOME	                                                              
			                                 
			DbSelectArea('SX5')
			DbSetOrder(1)
			DbSeek(xFilial("SX5") + 'ZX' + FAT->MarcaProduto )
			cAuxMarca := SX5->X5_DESCRI*/	                                                              
			  
			DbSelectArea('FAT')
    
	   		FWRITE(	nHandle,	AllTrim( StrTran(FAT->Filial,","," ") ) 											+ ";" + ;			
							AllTrim( StrTran(FAT->Estado,","," ") )											+ ";" + ;
							AllTrim( StrTran(FAT->TipoNota,","," ") )											+ ";" + ;
							AllTrim( StrTran(FAT->SerieNota,","," ") )										+ ";" + ;
							AllTrim( StrTran(FAT->NroNota,","," ") )											+ ";" + ;
							AllTrim( StrTran(FAT->Item,","," ") )											+ ";" + ;
							AllTrim( StrTran(FAT->Filial,","," ") ) + AllTrim( StrTran(FAT->LocalProduto,","," ") )				+ ";" + ;
							AllTrim( StrTran(FAT->Filial,","," ") ) + AllTrim( StrTran(FAT->TES,","," ") )					+ ";" + ;
							AllTrim( StrTran(FAT->CFOP,","," ") )											+ ";" + ;
							AllTrim( StrTran(FAT->GeraDuplicata,","," ") )									+ ";" + ;
							If(Empty(FAT->DataEmissao),"",AllTrim( DtoC( Stod(FAT->DataEmissao) ) )) 				+ ";" + ;
							If(Empty(FAT->DataReserva),"",AllTrim( DtoC( Stod(FAT->DataReserva) ) )) 				+ ";" + ;
							AllTrim( Str(FAT->Quantidade) ) 												+ ";" + ;
							AllTrim( Str(FAT->ValorTotal) )													+ ";" + ;
							AllTrim( Str(FAT->ValorBruto) )													+ ";" + ;
							AllTrim( Str(FAT->ValorCusto) )													+ ";" + ;
							AllTrim( Str(FAT->ValorIPI) )													+ ";" + ;
							AllTrim( Str(FAT->PrecoVenda) )													+ ";" + ;
							AllTrim( Str(FAT->Moeda) )														+ ";" + ;
							AllTrim( Str(FAT->TaxaMoeda) )													+ ";" + ;
							AllTrim( Str(FAT->ValorImpostos) )												+ ";" + ;  
					   		AllTrim( xFilial("SB1") ) + AllTrim( FAT->CodProduto )								+ ";" + ;
							AllTrim( xFilial("SA3") ) + AllTrim( FAT->Vendedor )								+ ";" + ;
							AllTrim( xFilial("CT1") ) + AllTrim( FAT->ContaContabil ) 							+ ";" + ;
							AllTrim( xFilial("SA2") ) + AllTrim( FAT->CodCliente ) + AllTrim( FAT->LojaCliente )	+ ";" + ;
							AllTrim( FAT->NumPedCompra )   													+ ";" + ;
							AllTrim( FAT->ItemPedCompra )													+ ";" + ;
							AllTrim( Str(FAT->Moeda) )														+ ";" + ;
							cExtracao + CRLF )
      
			nCont++
		
			FAT->( dbSkip() )
			
	EndDo
	
	cMsg += "Registros exportados do Documento de Entrada: " + cValToChar( nCont ) + CRLF
	
	FAT->( dbCloseArea() )
	
	fClose( nHandle )
	
	If !lAuto
		oProcess:SaveLog( "Fim da Exportacao do Documento de Entrada" )
	EndIf	
    
Return( cMsg )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ M010SB2Exp ³ Autor ³ Denis Rodrigues  ³ Data ³  13/03/2017 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Processa a exportacao da Tabela Saldo Fisico e Financeiro  ³±±
±±³          ³ SB2                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function M010SB2Exp(oProcess,lAuto)

	Local cAliasT		:= GetNextAlias()
	Local cQuery 		:= ""
	Local cMsg 		:= ""
	Local cExtracao	:= DtoC( Date() ) + " - " + Time()
	Local nCont		:= 0
	Local nHandle		:= 0

	If !lAuto		
		oProcess:SaveLog("Inicio da Exportacao da Tabela Saldo Fisicos e Financeiros (SB2)")
		oProcess:SetRegua1( 0 )
	Else
		ConOut("Inicio da Exportacao da Tabela de Saldo Fisicos e Financeiros (SB2) - SCHEDULE")	
	EndIf
	
	cQuery := " SELECT B2_FILIAL,"
	cQuery += "        B2_COD,"
	cQuery += "        (SELECT SUM(BJ_QINI) FROM SBJ010 WHERE BJ_COD=SB2.B2_COD AND BJ_FILIAL=SB2.B2_FILIAL AND BJ_LOCAL=SB2.B2_LOCAL AND BJ_DATA=(SELECT MAX(BJ_DATA) FROM SBJ010 WHERE SBJ010.D_E_L_E_T_<>'*') ) B2_QFIM,"
	cQuery += "        B2_LOCAL,"
	cQuery += "        B2_QATU,"
	cQuery += "        B2_VFIM1,"
	cQuery += "        B2_VATU1,"
	cQuery += "        B2_CM1"
	cQuery += " FROM " + RetSQLName("SB2")+ " SB2 " 	
	cQuery += " WHERE D_E_L_E_T_ <> '*'"
	 			 	
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T. )
	
	If ( cAliasT )->( !Eof() )
	
		nHandle := fCreate("\m010Exporta\saldosfisicofinanceiro_sb2.csv", FC_NORMAL)

		//Titulo das colunas do arquivo
		FWRITE(	nHandle,"SALDOFISICOFINANCEIRO_KEY"	+ ";" + ;
			       		"ESTABELECIMENTO_KEY"		+ ";" + ;
			       		"PRODUTO_KEY"				+ ";" + ;
			       		"ARMAZEM_KEY"				+ ";" + ;
			       		"B2_QFIM"					+ ";" + ;			       		
			       		"B2_QATU"					+ ";" + ;
			       		"B2_VFIM1"					+ ";" + ;
			       		"B2_VATU1"					+ ";" + ;
			       		"B2_CM1"					+ ";" + ;
			       		"DATA_EXTRACAO"			+ CRLF )
		nCont++
			
		While ( cAliasT )->( !Eof() )

			If !lAuto
				oProcess:IncRegua1("Exportando Tabela de Saldos Fisicos e Financeiros..." )
			EndIf
					
			FWRITE(	nHandle,( cAliasT )->B2_FILIAL + ( cAliasT )->B2_COD + ( cAliasT )->B2_LOCAL  + ";" + ;
			       			AllTrim( ( cAliasT )->B2_FILIAL )							+ ";" + ;
			       			AllTrim( xFilial("SB1") ) + AllTrim( ( cAliasT )->B2_COD )	+ ";" + ;
			       			AllTrim( ( cAliasT )->B2_FILIAL ) + AllTrim( ( cAliasT )->B2_LOCAL )	+ ";" + ;
			       			AllTrim( Str( ( cAliasT )->B2_QFIM ) )						+ ";" + ;
			       			AllTrim( Str( ( cAliasT )->B2_QATU ) )						+ ";" + ;
			       			AllTrim( Str( ( cAliasT )->B2_VFIM1 ) )						+ ";" + ;
			       			AllTrim( Str( ( cAliasT )->B2_VATU1 ) )						+ ";" + ;
			       			AllTrim( Str( ( cAliasT )->B2_CM1 ) )						+ ";" + ;
			       			cExtracao + CRLF )
		       			
			nCont++			       		
	
			( cAliasT )->( dbSkip() )
		
		EndDo

		cMsg += "Registros exportados da Tabela de Saldos Fisicos e Financeiros (SB2): " + cValToChar( nCont ) + CRLF
		
		fClose( nHandle )		
	
	EndIf
		
	If !lAuto
		oProcess:SaveLog( "Fim da Exportacao da Tabela de Saldos Fisicos e Financeiros (SB2)" )
	EndIf
		
Return( cMsg )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ M010SB8Exp ³ Autor ³ Denis Rodrigues  ³ Data ³  13/03/2017 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Processa a exportacao da Tabela Saldo por Lote SB8         ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function M010SB8Exp(oProcess,lAuto)

	Local cAliasT		:= GetNextAlias()
	Local cQuery 		:= ""
	Local cMsg 		:= ""
	Local cExtracao	:= DtoC( Date() ) + " - " + Time()
	Local cDtValid	:= ""
	Local nCont		:= 0
	Local nHandle		:= 0

	If !lAuto		
		oProcess:SaveLog("Inicio da Exportacao da Tabela de Saldo por Lote (SB8)")
		oProcess:SetRegua1( 0 )
	Else
		ConOut("Inicio da Exportacao da Tabela de Saldos por Lote (SB8) - SCHEDULE")	
	EndIf
	
	cQuery := " SELECT B8_FILIAL,"
	cQuery += "        B8_PRODUTO,"
	cQuery += "        B8_LOCAL,"
	cQuery += "        B8_DATA,"
	cQuery += "        B8_DTVALID,"
	cQuery += "        B8_SALDO,"
	cQuery += "        B8_LOTECTL,"
	cQuery += "        B8_NUMLOTE,"
	cQuery += "        B8_CLIFOR,"
	cQuery += "        B8_LOJA"
	cQuery += " FROM " + RetSQLName("SB8") 	
	cQuery += " WHERE D_E_L_E_T_ <> '*'"
	 			 	
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T. )
	
	If ( cAliasT )->( !Eof() )
	
		nHandle := fCreate("\m010Exporta\saldoporlote_sb8.csv", FC_NORMAL)

		//Titulo das colunas do arquivo
		FWRITE(	nHandle,"SALDOPORLOTE_KEY"		+ ";" + ;
			       		"ESTABELECIMENTO_KEY" 	+ ";" + ;
			       		"PRODUTO_KEY"			+ ";" + ;
			       		"ARMAZEM_KEY"			+ ";" + ;
			       		"B8_DATA"				+ ";" + ;			       		
			       		"B8_DTVALID"			+ ";" + ;
			       		"B8_SALDO"			+ ";" + ;
			       		"B8_LOTECTL"			+ ";" + ;
			       		"B8_NUMLOTE"			+ ";" + ;			       		
			       		"DATA_EXTRACAO"		+ CRLF )
		nCont++
			
		While ( cAliasT )->( !Eof() )

			If !lAuto
				oProcess:IncRegua1("Exportando Tabela de Saldos por Lote..." )
			EndIf
			
			If  Year( StoD( ( cAliasT )->B8_DTVALID ) ) > 2050
				cDtValid := "31/12/2050" 
			Else
				cDtValid := If( Empty( ( cAliasT )->B8_DTVALID )	,"",AllTrim( DtoC( StoD( ( cAliasT )->B8_DTVALID ) ) ) )
			EndIf	
					
			FWRITE(	nHandle,( cAliasT )->B8_FILIAL + ( cAliasT )->B8_PRODUTO + ( cAliasT )->B8_LOCAL + ( cAliasT )->B8_DTVALID + ( cAliasT )->B8_LOTECTL + ( cAliasT )->B8_NUMLOTE + ";" + ;
			       			AllTrim( ( cAliasT )->B8_FILIAL )														+ ";" + ;
			       			AllTrim( xFilial("SB1") ) + AllTrim( ( cAliasT )->B8_PRODUTO )								+ ";" + ;
			       			AllTrim( ( cAliasT )->B8_FILIAL ) + AllTrim( ( cAliasT )->B8_LOCAL )								+ ";" + ;
			       			If( Empty( ( cAliasT )->B8_DATA )	,"",AllTrim( DtoC( StoD( ( cAliasT )->B8_DATA ) ) ) ) 		+ ";" + ;
			       			cDtValid																				+ ";" + ;
			       			AllTrim( Str( ( cAliasT )->B8_SALDO ) )													+ ";" + ;
			       			AllTrim( ( cAliasT )->B8_LOTECTL )														+ ";" + ;
			       			AllTrim( ( cAliasT )->B8_NUMLOTE )														+ ";" + ;
			       			cExtracao + CRLF )
		       			
			nCont++			       		
	
			( cAliasT )->( dbSkip() )
		
		EndDo

		cMsg += "Registros exportados da Tabela de Saldos por Lote (SB8): " + cValToChar( nCont ) + CRLF
		
		fClose( nHandle )		
	
	EndIf
		
	If !lAuto
		oProcess:SaveLog( "Fim da Exportacao da Tabela de Saldos por Lote (SB8)" )
	EndIf
		
Return( cMsg )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ M010SB6Exp ³ Autor ³ Denis Rodrigues  ³ Data ³  13/03/2017 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Processa a exportacao da Tabela Poder de terceiros SB6     ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function M010SB6Exp(oProcess,lAuto)

	Local cAliasT   := GetNextAlias()
	Local cQuery    := ""
	Local cMsg      := ""
	Local cExtracao := DtoC( Date() ) + " - " + Time()
	Local cChvCli   := ""
	Local cChvFor   := ""
	Local nCont     := 0
	Local nHandle   := 0

	atuB6BI()
	If !lAuto		
		oProcess:SaveLog("Inicio da Exportacao da Tabela de Poder de Terceiros (SB6)")
		oProcess:SetRegua1( 0 )
	Else
		ConOut("Inicio da Exportacao da Tabela de Poder de Terceiros (SB6) - SCHEDULE")	
	EndIf
	
	cQuery := " SELECT B6_FILIAL,"
	cQuery += "        B6_CLIFOR,"
	cQuery += "        B6_LOJA,"
	cQuery += "        B6_IDENT,"
	cQuery += "        B6_PRODUTO,"
	cQuery += "        B6_LOCAL,"
	cQuery += "        B6_DOC,"
	cQuery += "        B6_SERIE,"
	cQuery += "        B6_TES,"
	cQuery += "        B6_EMISSAO,"
	cQuery += "        B6_QUANT,"
	cQuery += "        B6_PRUNIT,"
	cQuery += "        B6_TIPO,"
	cQuery += "        B6_SALDO,"
	cQuery += "        B6_PODER3,"
	cQuery += "        B6_ESTOQUE,"	
	cQuery += "        B6_CUSTO1,"
	cQuery += "        B6_CUSTO2,"
	cQuery += "        B6_CUSTO3,"
	cQuery += "        B6_CUSTO4,"
	cQuery += "        B6_CUSTO5,"
	cQuery += "        B6_TPCF, "
	cQuery += "        A3_COD,  "
	cQuery += "        A3_NOME, "
	cQuery += "        D2_LOTECTL, "
	cQuery += "        C5_PACIENT, "
	cQuery += "        C5_DPROCED, "
	cQuery += "        D2_DTVALID "
	cQuery += " FROM " + RetSQLName("SB6")+ " SB6 " 	
	cQuery += " INNER JOIN  " + RetSQLName("SD2") + " SD2 ON (SD2.D2_DOC=SB6.B6_DOC AND SD2.D2_SERIE=SB6.B6_SERIE AND SD2.D2_CLIENTE=SB6.B6_CLIFOR    AND SD2.D2_LOJA=SB6.B6_LOJA AND SD2.D2_IDENTB6=SB6.B6_IDENT AND SD2.D_E_L_E_T_<>'*')  "  
	cQuery += " INNER JOIN  " + RetSQLName("SC5") + " SC5 ON (SD2.D2_PEDIDO=SC5.C5_NUM and SD2.D2_FILIAL=SC5.C5_FILIAL AND  SD2.D_E_L_E_T_<>'*') "    
	cQuery += " INNER JOIN  " + RetSQLName("SA1") + " SA1 ON (SC5.C5_CLIENTE=SA1.A1_COD AND SC5.C5_LOJACLI=SA1.A1_LOJA AND SA1.D_E_L_E_T_<>'*') "   
	cQuery += " INNER JOIN  " + RetSQLName("SA3") + " SA3 ON (SA3.A3_COD=SC5.C5_VEND1 AND SA3.D_E_L_E_T_<>'*')    JOIN SB1010 SB1 ON (SB6.B6_PRODUTO=SB1.B1_COD AND  SB1.D_E_L_E_T_<>'*') "    
	cQuery += " INNER JOIN  " + RetSQLName("SF4") + " SF4 ON (SB6.B6_FILIAL=SF4.F4_FILIAL AND SB6.B6_TES=SF4.F4_CODIGO AND SF4.D_E_L_E_T_<>'*') "
	cQuery += " WHERE SB6.D_E_L_E_T_ <> '*'"
	cQuery += " AND SB6.B6_SALDO>0  "
	cQuery += " AND SB6.B6_TIPO = 'E' "  	 	
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T. )
	
	If ( cAliasT )->( !Eof() )
	
		nHandle := fCreate("\m010Exporta\poderdeterceiros_sb6.csv", FC_NORMAL)

		//Titulo das colunas do arquivo
		FWRITE(	nHandle, "PODERTERCEIROS_KEY"	+ ";" + ;
			       		"ESTABELECIMENTO_KEY"	+ ";" + ;
			       		"B6_IDENT"			+ ";" + ;
			       		"PRODUTO_KEY"			+ ";" + ;			       		
			       		"ARMAZEM_KEY"			+ ";" + ;
			       		"B6_DOC"				+ ";" + ;
			       		"B6_SERIE"			+ ";" + ;
			       		"TES_KEY"				+ ";" + ;
			       		"B6_EMISSAO"			+ ";" + ;
			       		"B6_QUANT"			+ ";" + ;
			       		"B6_PRUNIT"			+ ";" + ;
			       		"B6_TIPO"				+ ";" + ;
			       		"B6_SALDO"			+ ";" + ;
			       		"B6_PODER3"			+ ";" + ;
			       		"B6_ESTOQUE"			+ ";" + ;			       		
			       		"B6_CUSTO1"			+ ";" + ;
			       		"B6_CUSTO2"			+ ";" + ;
			       		"B6_CUSTO3"			+ ";" + ;
			       		"B6_CUSTO4"			+ ";" + ;
			       		"B6_CUSTO5"			+ ";" + ;
			       		"B6_TOTAL"			+ ";" + ;
			       		"B6_LOTE"			+ ";" + ;
			       		"B6_VALIDADE"			+ ";" + ;  			       		
			       		"CLIENTE_KEY"			+ ";" + ;
			       		"FORNECEDOR_KEY"		+ ";" + ;
			       		"VENDEDOR_KEY"			+ ";" + ;
						"B6_PACIENTE"			+ ";" + ;
						"B6_DTPROCED"			+ ";" + ;    
			       		"DATA_EXTRACAO"		+ CRLF )
		nCont++
			
		While ( cAliasT )->( !Eof() )

			If !lAuto
				oProcess:IncRegua1("Exportando Tabela de Poder de Terceiros..." )
			EndIf
			
			
			If AllTrim( ( cAliasT )->B6_TPCF ) == "C"//Se for de Cliente
			
				cChvCli := AllTrim( xFilial("SA1") ) + AllTrim( ( cAliasT )->B6_CLIFOR ) + AllTrim( ( cAliasT )->B6_LOJA )
				cChvFor := ""
			
			Else// Se for de Fornecedor

				cChvCli := ""
				cChvFor := AllTrim( xFilial("SA2") ) + AllTrim( ( cAliasT )->B6_CLIFOR ) + AllTrim( ( cAliasT )->B6_LOJA )			
			
			EndIf
					
			FWRITE(	nHandle,	( cAliasT )->B6_FILIAL + ( cAliasT )->B6_PRODUTO + ( cAliasT )->B6_CLIFOR + ( cAliasT )->B6_LOJA + ( cAliasT )->B6_IDENT + ";" + ;
			       			AllTrim( ( cAliasT )->B6_FILIAL )							+ ";" + ;
			       			AllTrim( ( cAliasT )->B6_IDENT )							+ ";" + ;
			       			AllTrim( xFilial("SB1") ) + AllTrim( ( cAliasT )->B6_PRODUTO )	+ ";" + ;
			       			AllTrim( ( cAliasT )->B6_FILIAL ) + AllTrim( ( cAliasT )->B6_LOCAL )	+ ";" + ;
			       			AllTrim( ( cAliasT )->B6_DOC )								+ ";" + ;
			       			AllTrim( ( cAliasT )->B6_SERIE )							+ ";" + ;
			       			AllTrim( xFilial("SF4") ) + AllTrim( ( cAliasT )->B6_TES )		+ ";" + ;
			       			If( Empty( ( cAliasT )->B6_EMISSAO )	,"",AllTrim( DtoC( StoD( ( cAliasT )->B6_EMISSAO ) ) ) ) 	+ ";" + ;
			       			AllTrim( Str( ( cAliasT )->B6_QUANT ) )					 		+ ";" + ;
			       			AllTrim( Str( ( cAliasT )->B6_PRUNIT ) )						+ ";" + ;
			       			AllTrim( ( cAliasT )->B6_TIPO )									+ ";" + ;
			       			AllTrim( Str( ( cAliasT )->B6_SALDO ))							+ ";" + ;
			       			AllTrim( ( cAliasT )->B6_PODER3 )								+ ";" + ;
			       			AllTrim( ( cAliasT )->B6_ESTOQUE )						   		+ ";" + ;			       			
			       			AllTrim( Str( ( cAliasT )->B6_CUSTO1 ) )						+ ";" + ;
			       			AllTrim( Str( ( cAliasT )->B6_CUSTO2 ) )						+ ";" + ;
			       			AllTrim( Str( ( cAliasT )->B6_CUSTO3 ) )						+ ";" + ;
			       			AllTrim( Str( ( cAliasT )->B6_CUSTO4 ) )						+ ";" + ;
			       			AllTrim( Str( ( cAliasT )->B6_CUSTO5 ) )						+ ";" + ;			       			
			       			AllTrim( Str( ( cAliasT )->B6_QUANT * ( cAliasT )->B6_PRUNIT ) )	+ ";" + ;
			       			AllTrim( ( cAliasT )->D2_LOTECTL )							+ ";" + ;
			       			If( Empty( ( cAliasT )->D2_DTVALID )	,"",AllTrim( DtoC( StoD( ( cAliasT )->D2_DTVALID ) ) ) ) 	+ ";" + ;
							cChvCli													+ ";" + ;
			       			cChvFor													+ ";" + ;
			       			AllTrim( xFilial("SA3")) + ( cAliasT )->A3_COD					+ ";" + ;
			       			AllTrim( ( cAliasT )->C5_PACIENT )								+ ";" + ;
							If( Empty( ( cAliasT )->C5_DPROCED )	,"",AllTrim( DtoC( StoD( ( cAliasT )->C5_DPROCED ) ) ) )    + ";" + ;
							cExtracao + CRLF )
		       			
			nCont++			       		
	
			( cAliasT )->( dbSkip() )
		
		EndDo

		cMsg += "Registros exportados da Tabela de Poder de Terceiros (SB6): " + cValToChar( nCont ) + CRLF
		
		fClose( nHandle )		
	
	EndIf
		
	If !lAuto
		oProcess:SaveLog( "Fim da Exportacao da Tabela de Poder de Terceiros (SB6)" )
	EndIf
		
Return( cMsg )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ M010SF5Exp ³ Autor ³ Denis Rodrigues  ³ Data ³  13/03/2017 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Processa a exportacao da Tabela de Tipos de Movimentacao   ³±±
±±³          ³ SF5                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function M010SF5Exp(oProcess,lAuto)

	Local cAliasT		:= GetNextAlias()
	Local cQuery 		:= ""
	Local cMsg 		:= ""
	Local cExtracao	:= DtoC( Date() ) + " - " + Time()
	Local nCont		:= 0
	Local nHandle		:= 0

	If !lAuto		
		oProcess:SaveLog("Inicio da Exportacao da Tabela de Tipos de Movimentacao (SF5)")
		oProcess:SetRegua1( 0 )
	Else
		ConOut("Inicio da Exportacao da Tabela de Tipos de Movimentacao (SF5) - SCHEDULE")	
	EndIf
	
	cQuery := " SELECT F5_FILIAL,"
	cQuery += "        F5_CODIGO,"
	cQuery += "        F5_TIPO,"
	cQuery += "        F5_TEXTO,"
	cQuery += "        F5_APROPR,"
	cQuery += "        F5_ATUEMP,"
	cQuery += "        F5_TRANMOD,"
	cQuery += "        F5_VAL,"
	cQuery += "        F5_ENVCQPR,"
	cQuery += "        F5_LIBPVPR,"
	cQuery += "        F5_QTDZERO,"
	cQuery += "        F5_AGREGCU,"
	cQuery += "        F5_CODLAN,"
	cQuery += "        F5_GERAATF,"
	cQuery += "        F5_TEATF"
	cQuery += " FROM " + RetSQLName("SF5") 	
	cQuery += " WHERE D_E_L_E_T_ <> '*'"
	 			 	
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T. )
	
	If ( cAliasT )->( !Eof() )
	
		nHandle := fCreate("\m010Exporta\tiposmovimentacao_sf5.csv", FC_NORMAL)

		//Titulo das colunas do arquivo
		FWRITE(	nHandle, "TIPOSMOVIMENTACAO_KEY"	+ ";" + ;
			       		"F5_FILIAL" 				+ ";" + ;
			       		"F5_CODIGO"					+ ";" + ;
			       		"F5_TIPO"					+ ";" + ;
			       		"F5_TEXTO"					+ ";" + ;
			       		"F5_APROPR"					+ ";" + ;			       		
			       		"F5_ATUEMP"					+ ";" + ;
			       		"F5_TRANMOD"				+ ";" + ;
			       		"F5_VAL"					+ ";" + ;
			       		"F5_ENVCQPR"				+ ";" + ;
			       		"F5_LIBPVPR"				+ ";" + ;
			       		"F5_QTDZERO"				+ ";" + ;
			       		"F5_AGREGCU"				+ ";" + ;
			       		"F5_CODLAN"					+ ";" + ;
			       		"F5_GERAATF"				+ ";" + ;
			       		"F5_TEATF"					+ ";" + ;
			       		"DATA_EXTRACAO"	+ CRLF )
		nCont++
			
		While ( cAliasT )->( !Eof() )

			If !lAuto
				oProcess:IncRegua1("Exportando Tabela de Tipos de Movimentacao..." )
			EndIf
					
			FWRITE(	nHandle,( cAliasT )->F5_FILIAL + ( cAliasT )->F5_CODIGO	+ ";" + ;
			       			AllTrim( ( cAliasT )->F5_FILIAL )				+ ";" + ;
			       			AllTrim( ( cAliasT )->F5_CODIGO )			+ ";" + ;
			       			AllTrim( ( cAliasT )->F5_TIPO )				+ ";" + ;
			       			AllTrim( ( cAliasT )->F5_TEXTO )			+ ";" + ;
			       			AllTrim( ( cAliasT )->F5_APROPR )			+ ";" + ;
			       			AllTrim( ( cAliasT )->F5_ATUEMP )			+ ";" + ;
			       			AllTrim( ( cAliasT )->F5_TRANMOD )			+ ";" + ;
			       			AllTrim( ( cAliasT )->F5_VAL )				+ ";" + ;
			       			AllTrim( ( cAliasT )->F5_ENVCQPR )			+ ";" + ;
			       			AllTrim( ( cAliasT )->F5_LIBPVPR )			+ ";" + ;
			       			AllTrim( ( cAliasT )->F5_QTDZERO )			+ ";" + ;
							AllTrim( ( cAliasT )->F5_AGREGCU )			+ ";" + ;
							AllTrim( ( cAliasT )->F5_CODLAN )			+ ";" + ;
							AllTrim( ( cAliasT )->F5_GERAATF )			+ ";" + ;
							AllTrim( ( cAliasT )->F5_TEATF )			+ ";" + ;
			       			cExtracao + CRLF )
		       			
			nCont++			       		
	
			( cAliasT )->( dbSkip() )
		
		EndDo

		cMsg += "Registros exportados da Tabela de Tipos de Movimentacao (SF5): " + cValToChar( nCont ) + CRLF
		
		fClose( nHandle )		
	
	EndIf
		
	If !lAuto
		oProcess:SaveLog( "Fim da Exportacao da Tabela de Tipos de Movimentacao (SF5)" )
	EndIf
		
Return( cMsg )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ M010NNRExp ³ Autor ³ Denis Rodrigues  ³ Data ³  13/03/2017 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Processa a exportacao da Tabela de Armazens NNR            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function M010NNRExp(oProcess,lAuto)

	Local cAliasT		:= GetNextAlias()
	Local cQuery 		:= ""
	Local cMsg 		:= ""
	Local cExtracao	:= DtoC( Date() ) + " - " + Time()
	Local nCont		:= 0
	Local nHandle		:= 0

	If !lAuto		
		oProcess:SaveLog("Inicio da Exportacao da Tabela de Armazens (NNR)")
		oProcess:SetRegua1( 0 )
	Else
		ConOut("Inicio da Exportacao da Tabela de Armazens (NNR) - SCHEDULE")	
	EndIf
	
	cQuery := " SELECT NNR_FILIAL,"
	cQuery += "        NNR_CODIGO,"
	cQuery += "        NNR_DESCRI,"
	cQuery += "        NNR_CODCLI,"
	cQuery += "        NNR_LOJCLI,"
	cQuery += "        NNR_TIPO,"
	cQuery += "        NNR_CTRAB,"
	cQuery += "        NNR_INTP,"
	cQuery += "        NNR_MRP"
	cQuery += " FROM " + RetSQLName("NNR") 	
	cQuery += " WHERE D_E_L_E_T_ <> '*'"
	 			 	
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T. )
	
	If ( cAliasT )->( !Eof() )
	
		nHandle := fCreate("\m010Exporta\armazens_nnr.csv", FC_NORMAL)

		//Titulo das colunas do arquivo
		FWRITE(	nHandle, "ARMAZEM_KEY"		+ ";" + ;
			       		"NNR_FILIAL" 		+ ";" + ;
			       		"NNR_CODIGO"		+ ";" + ;
			       		"NNR_DESCRI"		+ ";" + ;
			       		"NNR_CODCLI"		+ ";" + ;
			       		"NNR_LOJCLI"		+ ";" + ;			       		
			       		"NNR_TIPO"			+ ";" + ;
			       		"NNR_CTRAB"			+ ";" + ;
			       		"NNR_INTP"			+ ";" + ;
			       		"NNR_MRP"			+ ";" + ;
			       		"DATA_EXTRACAO"		+ CRLF )
		nCont++
			
		While ( cAliasT )->( !Eof() )

			If !lAuto
				oProcess:IncRegua1("Exportando Tabela de Armazens..." )
			EndIf
					
			FWRITE(	nHandle,AllTrim( ( cAliasT )->NNR_FILIAL ) + AllTrim( ( cAliasT )->NNR_CODIGO )	+ ";" + ;
			       			AllTrim( ( cAliasT )->NNR_FILIAL )				+ ";" + ;
			       			AllTrim( ( cAliasT )->NNR_CODIGO )				+ ";" + ;
			       			AllTrim( ( cAliasT )->NNR_DESCRI )				+ ";" + ;
			       			AllTrim( ( cAliasT )->NNR_CODCLI )				+ ";" + ;
			       			AllTrim( ( cAliasT )->NNR_LOJCLI )				+ ";" + ;
			       			AllTrim( ( cAliasT )->NNR_TIPO )				+ ";" + ;
			       			AllTrim( ( cAliasT )->NNR_CTRAB )				+ ";" + ;
			       			AllTrim( ( cAliasT )->NNR_INTP )				+ ";" + ;
			       			AllTrim( ( cAliasT )->NNR_MRP )					+ ";" + ;
			       			cExtracao + CRLF )
		       			
			nCont++			       		
	
			( cAliasT )->( dbSkip() )
		
		EndDo

		cMsg += "Registros exportados da Tabela de Armazens (NNR): " + cValToChar( nCont ) + CRLF
		
		fClose( nHandle )		
	
	EndIf
		
	If !lAuto
		oProcess:SaveLog( "Fim da Exportacao da Tabela de Armazens (NNR)" )
	EndIf
		
Return( cMsg )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ M010SD3Exp ³ Autor ³ Denis Rodrigues  ³ Data ³  13/03/2017 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Processa a exportacao da Tabela Movimentacao Interna SD3   ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function M010SD3Exp(oProcess,lAuto)

	Local cAliasT		:= GetNextAlias()
	Local cQuery 		:= ""
	Local cMsg 		:= ""
	Local cExtracao	:= DtoC( Date() ) + " - " + Time()
	Local nCont		:= 0
	Local nHandle		:= 0

	If !lAuto		
		oProcess:SaveLog("Inicio da Exportacao da Tabela de Movimentacao Interna (SD3)")
		oProcess:SetRegua1( 0 )
	Else
		ConOut("Inicio da Exportacao da Tabela de Movimentacao Interna (SD3) - SCHEDULE")	
	EndIf
	
	cQuery := " SELECT D3_FILIAL,"
	cQuery += "        D3_TM,"
	cQuery += "        D3_COD,"
	cQuery += "        D3_UM,"
	cQuery += "        D3_QUANT,"
	cQuery += "        D3_CF,"
	cQuery += "        D3_CONTA,"
	cQuery += "        D3_OP,"
	cQuery += "        D3_LOCAL,"
	cQuery += "        D3_DOC,"
	cQuery += "        D3_EMISSAO,"
	cQuery += "        D3_GRUPO,"
	cQuery += "        D3_CUSTO1,"
	cQuery += "        D3_CC"
	cQuery += " FROM " + RetSQLName("SD3") 	
	cQuery += " WHERE D_E_L_E_T_ <> '*'"
	 			 	
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T. )
	
	If ( cAliasT )->( !Eof() )
	
		nHandle := fCreate("\m010Exporta\movimentacaointerna_sd3.csv", FC_NORMAL)

		//Titulo das colunas do arquivo
		FWRITE(	nHandle,"MOVIMENTACAOINTERNA_KEY"	+ ";" + ;
			       		"ESTABELECIMENTO_KEY"		+ ";" + ;
			       		"D3_TM"						+ ";" + ;
			       		"PRODUTO_KEY"				+ ";" + ;
			       		"D3_UM"						+ ";" + ;
			       		"D3_QUANT"					+ ";" + ;			       		
			       		"D3_CF"						+ ";" + ;
			       		"PLANOCONTAS_KEY"			+ ";" + ;
			       		"D3_OP"						+ ";" + ;
			       		"ARMAZEM_KEY"				+ ";" + ;
			       		"D3_DOC"					+ ";" + ;
			       		"D3_EMISSAO"				+ ";" + ;
			       		"D3_CUSTO1"					+ ";" + ;
			       		"CENTROCUSTO_KEY"			+ ";" + ;
			       		"DATA_EXTRACAO"	+ CRLF )
		nCont++
			
		While ( cAliasT )->( !Eof() )

			If !lAuto
				oProcess:IncRegua1("Exportando Tabela de Armazens..." )
			EndIf
					
			FWRITE(	nHandle,( cAliasT )->D3_FILIAL + ( cAliasT )->D3_OP + ( cAliasT )->D3_COD + ( cAliasT )->D3_LOCAL	+ ";" + ;							
			       			AllTrim( ( cAliasT )->D3_FILIAL )								+ ";" + ;
			       			AllTrim( ( cAliasT )->D3_TM )									+ ";" + ;
			       			AllTrim( xFilial("SB1") ) + AllTrim( ( cAliasT )->D3_COD )		+ ";" + ;
			       			AllTrim( ( cAliasT )->D3_UM )									+ ";" + ;
			       			AllTrim( Str( ( cAliasT )->D3_QUANT ) )							+ ";" + ;
			       			AllTrim( ( cAliasT )->D3_CF )									+ ";" + ;
			       			AllTrim( xFilial("CT1") ) + AllTrim( ( cAliasT )->D3_CONTA )	+ ";" + ;
			       			AllTrim( ( cAliasT )->D3_OP )									+ ";" + ;
			       			AllTrim( ( cAliasT )->D3_FILIAL ) + AllTrim( ( cAliasT )->D3_LOCAL )	+ ";" + ;
			       			AllTrim( ( cAliasT )->D3_DOC )											+ ";" + ;
			       			If( Empty( ( cAliasT )->D3_EMISSAO )	,"",AllTrim( DtoC( StoD( ( cAliasT )->D3_EMISSAO ) ) ) )	+ ";" + ;
			       			AllTrim( Str( ( cAliasT )->D3_CUSTO1 ) )						+ ";" + ;
			       			AllTrim( xFilial("CTT") ) + AllTrim( ( cAliasT )->D3_CC )		+ ";" + ;
			       			cExtracao + CRLF )
		       			
			nCont++			       		
	
			( cAliasT )->( dbSkip() )
		
		EndDo

		cMsg += "Registros exportados da Tabela Movimentacao Interna (SD3): " + cValToChar( nCont ) + CRLF
		
		fClose( nHandle )		
	
	EndIf
		
	If !lAuto
		oProcess:SaveLog( "Fim da Exportacao da Tabela de Movimentacao Interna (SD3)" )
	EndIf
		
Return( cMsg )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ M010SC7Exp ³ Autor ³ Denis Rodrigues  ³ Data ³  27/04/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descricao ³ Extrai os dados da tabela de Pedido de Compra SC7      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function M010SC7Exp( oProcess,lAuto )

	Local cAliasT		:= GetNextAlias()
	Local cQuery 		:= ""
	Local cMsg 	   		:= ""
	Local cExtracao		:= DtoC( Date() ) + " - " + Time()
	Local cDscTip		:= ""
	Local cTES 	   		:= ""
	Local cLOCAL		:= "" 
	Local cDtPRF 		:= ""
	Local cData	  		:= ""	
	Local nCont	  		:= 0
	Local nHandle		:= 0
	Local aDadosSD1		:= {}
	Local nDPREVISTO	:= 0
	Local nDEFETIVO		:= 0
	Local nSPREVISTO	:= 0
	Local nSEFETIVO		:= 0
	Local dDTNFENTRADA	:= ""

	If !lAuto		
		oProcess:SaveLog("Inicio da Exportacao da Tabela de Pedido de Compra (SC7)")
		oProcess:SetRegua1( 0 )	
	Else
		ConOut("Inicio da Exportacao da Tabela de Pedido de Compra (SC7) - SCHEDULE")
	EndIf
	
	cQuery := " SELECT C7_FILIAL,"
	cQuery += "        C7_TIPO,"
	cQuery += "        C7_ITEM,"
	cQuery += "        C7_PRODUTO,"
	cQuery += "        C7_UM,"
	cQuery += "        C7_QUANT,"
	cQuery += "        C7_PRECO,"
	cQuery += "        C7_TOTAL,"
	cQuery += "        C7_IPI,"
	cQuery += "        C7_DATPRF,"
	cQuery += "        C7_LOCAL AS LOCAL_KEY,"
	cQuery += "        C7_FORNECE,"
	cQuery += "        C7_CC,"
	cQuery += "        C7_CONTA,"
	cQuery += "        C7_ITEMCTA,"
	cQuery += "        C7_LOJA,"
	cQuery += "        C7_EMISSAO,"
	cQuery += "        C7_NUM,"
	cQuery += "        C7_QUJE,"
	cQuery += "        C7_RESIDUO,"
	cQuery += "        C7_FRETE,"
	cQuery += "        C7_TES AS TES_KEY,"
	cQuery += "        C7_MOEDA"	
	cQuery += " FROM " + RetSQLName("SC7")
	cQuery += " WHERE D_E_L_E_T_<>'*'"
	cQuery += " ORDER BY C7_NUM, C7_ITEM"
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T. )
	
	If ( cAliasT )->( !Eof() )
	
		nHandle := fCreate("\m010Exporta\pedidocompra_sc7.csv", FC_NORMAL)
	
		//Titulo das colunas do arquivo
		FWRITE(	nHandle,"PEDIDOCOMPRA_KEY"		+ ";" + ;
			       		"ESTABELECIMENTO_KEY" 	+ ";" + ;
			       		"C7_TIPO" 				+ ";" + ;
			       		"C7_ITEM"				+ ";" + ;
			       		"PRODUTO_KEY"			+ ";" + ;
			       		"C7_UM"					+ ";" + ;
			       		"C7_QUANT"				+ ";" + ;
			       		"C7_PRECO"				+ ";" + ;
			       		"C7_TOTAL"				+ ";" + ;
			       		"C7_IPI"				+ ";" + ;
			       		"C7_DATPRF"				+ ";" + ;
			       		"ARMAZEN_KEY"			+ ";" + ;
			       		"FORNECEDOR_KEY"		+ ";" + ;
			       		"C7_CC"					+ ";" + ;
			       		"C7_CONTA"				+ ";" + ;
			       		"C7_ITEMCTA"			+ ";" + ;
			       		"C7_EMISSAO"			+ ";" + ;
			       		"C7_NUM"				+ ";" + ;
			       		"C7_QUJE"				+ ";" + ;
			       		"C7_RESIDUO"			+ ";" + ;
			       		"C7_FRETE"				+ ";" + ;
			       		"TES_KEY"				+ ";" + ;
			       		"C7_MOEDA"				+ ";" + ;
			       		"NOTA_FISCAL_ENTRADA"	+ ";" + ;
			       		"DATA_NF_ENTRADA"		+ ";" + ;
			       		"DIAS_RECEB_PREV"		+ ";" + ;
						"DIAS_RECEB_EFET"		+ ";" + ;
						"SALDO_RECEB_PREV"		+ ";" + ;
						"SALDO_RECEB_EFET"		+ ";" + ;
						"MOEDA_KEY"				+ ";" + ;			       		
			       		"DATA_EXTRACAO"			+ CRLF )
		nCont++			       		
	
		While ( cAliasT )->( !Eof() )
		
			If !lAuto
				oProcess:IncRegua1("Exportando Pedido de Compras..." )
			EndIf
			
			If !Empty( ( cAliasT )->TES_KEY )
				cTES := AllTrim( ( cAliasT )->C7_FILIAL ) + AllTrim(  ( cAliasT )->TES_KEY  ) 

			EndIf
			
			If !Empty( ( cAliasT )->LOCAL_KEY )
				cLOCAL := AllTrim( ( cAliasT )->C7_FILIAL ) + AllTrim( ( cAliasT )->LOCAL_KEY ) 
			
			EndIf
			
			//Retorna a descricao do Tipo 
			cDscTip := X3Combo( "C7_TIPO",( cAliasT )->C7_TIPO ) 
			
			If  Year( StoD( ( cAliasT )->C7_DATPRF ) ) > 2050
				cDtPRF := "31/12/2050" 
			Else
				cDtPRF := If( Empty( ( cAliasT )->C7_DATPRF )	,"",AllTrim( DtoC( StoD( ( cAliasT )->C7_DATPRF ) ) ) ) 
			EndIf      
			
			If  Year( StoD( ( cAliasT )->C7_EMISSAO ) ) > 2050
				cData := "31/12/2050" 
			Else
				cData := If( Empty( ( cAliasT )->C7_EMISSAO )	,"",AllTrim( DtoC( StoD( ( cAliasT )->C7_EMISSAO ) ) ) )
			EndIf

			aDadosSD1 := SC7RetSD1( ( cAliasT )->C7_FILIAL,;
								 ( cAliasT )->C7_NUM,;
								 ( cAliasT )->C7_ITEM,;
								 ( cAliasT )->C7_FORNECE,;
								 ( cAliasT )->C7_LOJA )//Funcao para retorna o Numero e Emissao da Nota Fiscal de Entrada
			              
			dDTNFENTRADA = StoD( substring(aDadosSD1[2],7,4) + substring(aDadosSD1[2],4,2) + substring(aDadosSD1[2],1,2))
			 /*
			If nCont < 5      
				alert(aDadosSD1[1])
				alert(dDTNFENTRADA)
				alert(Stod(dDTNFENTRADA))
				alert(Stod( ( cAliasT )->C7_EMISSAO ))
			EndIf
			*/
			nDPREVISTO	:= 0
			nDEFETIVO	:= 0
			nSPREVISTO	:= 0
			nSEFETIVO	:= 0 

		    If Year( StoD( ( cAliasT )->C7_DATPRF ) ) > 1900
				nDPREVISTO := DateDiffDay( Stod( ( cAliasT )->C7_EMISSAO ) , Stod( ( cAliasT )->C7_DATPRF ) )
            EndIf

			If Year( dDTNFENTRADA ) > 1900                                             
				nDEFETIVO := DateDiffDay( Stod( ( cAliasT )->C7_EMISSAO ) , dDTNFENTRADA )
			EndIf
			
			If Empty( dDTNFENTRADA ) .and. Year( StoD( ( cAliasT )->C7_DATPRF ) ) > 1900 
				nSPREVISTO := DateDiffDay( Stod( ( cAliasT )->C7_DATPRF ) , Date() )
			EndIf
			                                  
			If Year( dDTNFENTRADA ) > 1900 .and. Year( StoD( ( cAliasT )->C7_DATPRF ) ) > 1900
				nSEFETIVO := DateDiffDay( Stod( ( cAliasT )->C7_DATPRF ) , dDTNFENTRADA)
				If dDTNFENTRADA < StoD( ( cAliasT )->C7_DATPRF )
					nSEFETIVO := nSEFETIVO * -1
				EndIf	
			EndIf        
			
			If AllTrim( ( cAliasT )->C7_RESIDUO ) == 'S' .or. dDTNFENTRADA <= Stod( ( cAliasT )->C7_EMISSAO )
				nDPREVISTO	:= 0
				nDEFETIVO	:= 0
				nSPREVISTO	:= 0
				nSEFETIVO	:= 0
			EndIf
			
					
			FWRITE(	nHandle,AllTrim( ( cAliasT )->C7_FILIAL ) + AllTrim( ( cAliasT )->C7_NUM ) + AllTrim( ( cAliasT )->C7_ITEM ) + AllTrim( ( cAliasT )->C7_PRODUTO ) + ";" + ;
			       			AllTrim( ( cAliasT )->C7_FILIAL ) 										+ ";" + ;
			       			AllTrim( cDscTip )				  										+ ";" + ;
			       			AllTrim( ( cAliasT )->C7_ITEM )	  										+ ";" + ;
			       			AllTrim( xFilial("SB1") ) + AllTrim( ( cAliasT )->C7_PRODUTO )			+ ";" + ;
			       			AllTrim( ( cAliasT )->C7_UM )	  										+ ";" + ;
			       			AllTrim( Str( ( cAliasT )->C7_QUANT ) )									+ ";" + ;
			       			AllTrim( Str( ( cAliasT )->C7_PRECO ) )									+ ";" + ;
			       			AllTrim( Str( ( cAliasT )->C7_TOTAL ) )									+ ";" + ;
			       			AllTrim( Str( ( cAliasT )->C7_IPI 	) )									+ ";" + ;
			       			cDtPRF							  										+ ";" + ;
			       			cLOCAL														  			+ ";" + ;		
			       			AllTrim( xFilial("SA2") ) + AllTrim( ( cAliasT )->C7_FORNECE ) + AllTrim( ( cAliasT )->C7_LOJA ) + ";" + ;
			       			AllTrim( ( cAliasT )->C7_CC ) 	 										+ ";" + ;
			       			AllTrim( ( cAliasT )->C7_CONTA ) 										+ ";" + ;
			       			AllTrim( ( cAliasT )->C7_ITEMCTA ) 										+ ";" + ;
			       			cData							 										+ ";" + ;
			       			AllTrim( ( cAliasT )->C7_NUM ) 											+ ";" + ;			       			
			       			AllTrim( Str( ( cAliasT )->C7_QUJE ) )									+ ";" + ;
			       			AllTrim( ( cAliasT )->C7_RESIDUO ) 										+ ";" + ;
			       			AllTrim( Str( ( cAliasT )->C7_FRETE ) )									+ ";" + ;
							cTES																	+ ";" + ;
					   		AllTrim( Str(( cAliasT )->C7_MOEDA ))									+ ";" + ;
					   		aDadosSD1[1]															+ ";" + ;//DOC + SERIE
					   		aDadosSD1[2]															+ ";" + ;//EMISSAO 
					   		AllTrim( Str (nDPREVISTO))												+ ";" + ;
							AllTrim( Str (nDEFETIVO))	 											+ ";" + ;
							AllTrim( Str (nSPREVISTO))	 											+ ";" + ;
							AllTrim( Str (nSEFETIVO))												+ ";" + ;
							AllTrim( Str(( cAliasT )->C7_MOEDA ))									+ ";" + ;
			       			cExtracao + CRLF )	       			
			nCont++
		
			( cAliasT )->( dbSkip() )
			
		EndDo
	
		cMsg += "Registros exportados do Pedido de Compras (SC7): " + cValToChar( nCont ) + CRLF
		
	EndIf
	
	( cAliasT )->( dbCloseArea() )
	
	fClose( nHandle )
	
	If !lAuto
		oProcess:SaveLog( "Fim da Exportacao do Pedido de Compras (SC7)" )
	EndIf

Return( cMsg )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ SC7RETSD1 ³ Autor ³ Denis Rodrigues    ³ Data ³  19/06/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function SC7RETSD1( cSC7Fil,cNumPC,cItemPC,cCodForn,cLojaForn )

	Local aRet 	:= {}
	Local cQuery	:= ""
	Local cAliasT	:= GetNextAlias()
	
	cQuery := " SELECT D1_FILIAL,"
	cQuery += "        D1_DOC,"
	cQuery += "        D1_SERIE,"
	cQuery += "        D1_EMISSAO"
	cQuery += " FROM " + RetSQLName("SD1")
	cQuery += " WHERE D1_FILIAL  = '" + cSC7Fil   + "'"
	cQuery += "   AND D1_PEDIDO  = '" + cNumPC    + "'"
	cQuery += "   AND D1_ITEMPC  = '" + cItemPC   + "'"
	cQuery += "   AND D1_FORNECE = '" + cCodForn  + "'"
	cQuery += "   AND D1_LOJA    = '" + cLojaForn + "'"
	cQuery += "   AND D_E_L_E_T_<>'*'"
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T. )
	
	If ( cAliasT )->( !Eof() )
	
		While ( cAliasT )->( !Eof() )
		
			aAdd( aRet, ( cAliasT )->D1_DOC + " - " + ( cAliasT )->D1_SERIE )
			aAdd( aRet, DtoC( StoD( ( cAliasT )->D1_EMISSAO ) ) )
		
			( cAliasT )->( dbSkip() )
			
		EndDo
		
	Else
	
		aAdd( aRet, "" )
		aAdd( aRet, "" )
	
	EndIf
	
	( cAliasT )->( dbCloseArea() )
	
Return( aRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ M010SEDExp ³ Autor ³ Denis Rodrigues  ³ Data ³  19/06/2017 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Processa a exportacao da Natureza de Operacao              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function M010SEDExp(oProcess,lAuto)

	Local cAliasT		:= GetNextAlias()
	Local cQuery 		:= ""
	Local cMsg 		:= ""
	Local cDscTip		:= ""	
	Local cExtracao	:= DtoC( Date() ) + " - " + Time()
	Local nCont		:= 0
	Local nHandle		:= 0

	If !lAuto		
		oProcess:SaveLog("Inicio da Exportacao da Tabela de Naturezas de Operacao (SED)")
		oProcess:SetRegua1( 0 )	
	Else
		ConOut("Inicio da Exportacao da Tabela de Naturezas de Operacao (SED) - SCHEDULE")
	EndIf
	
	cQuery := " SELECT ED_FILIAL,"
	cQuery += "        ED_CODIGO,"
	cQuery += "        ED_DESCRIC,"
	cQuery += "        ED_CALCIRF,"
	cQuery += "        ED_CALCISS,"
	cQuery += "        ED_CALCINS,"
	cQuery += "        ED_CALCCSL,"
	cQuery += "        ED_CALCCOF,"
	cQuery += "        ED_CALCPIS"	    
	cQuery += " FROM " + RetSQLName("SED")
	cQuery += " WHERE D_E_L_E_T_<>'*'"
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T. )
	
	If ( cAliasT )->( !Eof() )
	
		nHandle := fCreate("\m010Exporta\natureza_operacao_sed.csv", FC_NORMAL)
	
		//Titulo das colunas do arquivo
		FWRITE(	nHandle, "NATUREZA_OPERACAO_KEY"	+ ";" + ;
			       		"ED_FILIAL"		 		+ ";" + ;
			       		"ED_CODIGO" 				+ ";" + ;
			       		"ED_DESCRIC"				+ ";" + ;
			       		"ED_CALCIRF"				+ ";" + ;
			       		"ED_CALCISS"				+ ";" + ;
			       		"ED_CALCINS"				+ ";" + ;
			       		"ED_CALCCSL"				+ ";" + ;
			       		"ED_CALCCOF"				+ ";" + ;
			       		"ED_CALCPIS"				+ ";" + ;
			       		"DATA_EXTRACAO"	+ CRLF )
		nCont++			       		
	
		While ( cAliasT )->( !Eof() )
		
			If !lAuto
				oProcess:IncRegua1("Exportando Naturezas..." )
			EndIf
							
			FWRITE(	nHandle,	AllTrim( ( cAliasT )->ED_FILIAL ) + AllTrim( ( cAliasT )->ED_CODIGO ) + ";" + ;
			       			AllTrim( ( cAliasT )->ED_FILIAL ) 				+ ";" + ;
			       			AllTrim( ( cAliasT )->ED_CODIGO )				+ ";" + ;
			       			AllTrim( ( cAliasT )->ED_DESCRIC )				+ ";" + ;
			       			X3Combo( "ED_CALCIRF", ( cAliasT )->ED_CALCIRF )	+ ";" + ;
			       			X3Combo( "ED_CALCISS", ( cAliasT )->ED_CALCISS )	+ ";" + ;
			       			X3Combo( "ED_CALCINS", ( cAliasT )->ED_CALCINS )	+ ";" + ;
			       			X3Combo( "ED_CALCCSL", ( cAliasT )->ED_CALCCSL )	+ ";" + ;			       			
			       			X3Combo( "ED_CALCCOF", ( cAliasT )->ED_CALCCOF )	+ ";" + ;
			       			X3Combo( "ED_CALCPIS", ( cAliasT )->ED_CALCPIS )	+ ";" + ;
			       			cExtracao + CRLF )	       			
			nCont++
		
			( cAliasT )->( dbSkip() )
			
		EndDo
	
		cMsg += "Registros exportados da Tabela de Naturezas de Operações (SED): " + cValToChar( nCont ) + CRLF
		
	EndIf
	
	( cAliasT )->( dbCloseArea() )
	
	fClose( nHandle )
	
	If !lAuto
		oProcess:SaveLog( "Fim da Exportacao da Tabela de Naturezas de Operacoes (SED)" )
	EndIf

Return( cMsg )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ SE5MOTBX ³ Autor ³ Douglas Garcia      ³ Data ³  19/09/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function SE5MOTBX( cSFilial,cPrefixo,cNumTit,cParcela,cTipo,cCliFor,cLoja )

	Local aRet 	:= {}
	Local cQuery	:= ""
	Local cAliasT	:= GetNextAlias()
	
	cQuery := " SELECT E5_FILIAL,"
	cQuery += " E5_MOTBX "
	cQuery += " FROM " + RetSQLName("SE5")
	cQuery += " WHERE E5_FILIAL   = '" + cSFilial   + "'"
	cQuery += "   AND E5_PREFIXO  = '" + cPrefixo    + "'"
	cQuery += "   AND E5_NUMERO   = '" + cNumTit   + "'"
	cQuery += "   AND E5_PARCELA  = '" + cParcela  + "'"
	cQuery += "   AND E5_TIPO     = '" + cTipo + "'"
	cQuery += "   AND E5_CLIFOR   = '" + cCliFor + "'"
	cQuery += "   AND E5_LOJA     = '" + cLoja + "'"
	cQuery += "   AND D_E_L_E_T_=''"
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T. )
	
	If ( cAliasT )->( !Eof() )
	
		While ( cAliasT )->( !Eof() )
		
			aAdd( aRet, ( cAliasT )->E5_MOTBX )
		
			( cAliasT )->( dbSkip() )
			
		EndDo
		
	Else
	
		aAdd( aRet, "" )
	
	EndIf
	
	( cAliasT )->( dbCloseArea() )
	
Return( aRet )

/*
|============================================================================|
|============================================================================|
|||-----------+----------+-------+-----------------------+------+----------|||
||| Funcao    |M010AA3Exp| Autor | Denis Rodrigues       | Data |23/11/2017|||
|||-----------+----------+-------+-----------------------+------+----------|||
||| Descricao | Processa a Extracao da tabela de Base de Atendimento AA3   |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   | M010AA3EXP(ExpO01,ExpL01)                                  |||
|||-----------+------------------------------------------------------------|||
||| Parametros|ExpO01 - Objeto do TnewProcess                              |||
|||           |Expl01 - Indica se era gerado pela rotina automatica        |||
|||-----------+------------------------------------------------------------|||
||| Retorno   |                                                            |||
|||-----------+------------------------------------------------------------|||
|============================================================================|
|============================================================================|*/
Static Function M010AA3Exp(oProcess,lAuto)

	Local cAliasT		:= GetNextAlias()
	Local cQuery 		:= ""
	Local cMsg 	   		:= ""
	Local cExtracao		:= DtoC( Date() ) + " - " + Time()
	Local nCont	   		:= 0
	Local nHandle		:= 0
	Local cNatureza		:= ""

	If !lAuto		
		oProcess:SaveLog("Inicio da Extracao da Tabela de Base de Atendimento (AA3)")
		oProcess:SetRegua1( 0 )	
	Else
		ConOut("Inicio da Extracao da Tabela de Base de Atendimento (AA3) - SCHEDULE")
	EndIf
	
	cQuery := " SELECT AA3_FILIAL,"
	cQuery += "        AA3_CODCLI,"			
	cQuery += "        AA3_LOJA,"			
	cQuery += "        AA3_CODPRO,"
	cQuery += "        AA3_NUMSER,"
	cQuery += "        AA3_DTVEND,"
	cQuery += "        AA3_DTINST,"
	cQuery += "        AA3_DTGAR,"
	cQuery += "        AA3_CBASE,"
	cQuery += "        AA3_ITEM,"
	cQuery += "        AA3_CHAPA,"
	cQuery += "        AA3_CODTEC,"
	cQuery += "        AA3_NFVEND,"
	cQuery += "        AA3_VLRCTR,"
	cQuery += "        AA3_HORDIA,"
	cQuery += "        AA3_STATUS,"
	cQuery += "        AA3_STAANT,"
	cQuery += "        AA3_EQALOC,"
	cQuery += "        AA3_MANPRE,"
	cQuery += "        AA3_EXIGNF,"
	cQuery += "        AA3_EQ3,"
	cQuery += "        AA3_FILORI,"
	cQuery += "        AA3_OSMONT,"
	cQuery += "        AA3_HMEATV"
	cQuery += " FROM " + RetSQLName("AA3")
	cQuery += " WHERE D_E_L_E_T_<>'*'" 			 	
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T. )
	
	If ( cAliasT )->( !Eof() )
	
		nHandle := fCreate("\m010Exporta\gestao_servicos_aa3.csv", FC_NORMAL)
	
		//Titulo das colunas do arquivo
		FWRITE(	nHandle,"GESTAO_SERVICO_KEY" + ";" + ;
			       		"ESTABELECIMENTO_KEY"+ ";" + ;			       		
			       		"AA3_NUMSER"		 + ";" + ;			       		
			       		"AA3_DTVEND"		 + ";" + ;
			       		"AA3_DTINST"		 + ";" + ;
			       		"AA3_DTGAR"			 + ";" + ;
			       		"AA3_CBASE"		 	 + ";" + ;
			       		"AA3_ITEM"		 	 + ";" + ;
			       		"AA3_CHAPA"		 	 + ";" + ;
			       		"TECNICO_KEY"		 + ";" + ;
			       		"AA3_NFVEND"		 + ";" + ;
			       		"AA3_VLRCTR"		 + ";" + ;
			       		"AA3_HORDIA"		 + ";" + ;			       		
			       		"AA3_STATUS"		 + ";" + ;
			       		"AA3_STAANT"		 + ";" + ;
			       		"AA3_EQALOC"		 + ";" + ;
			       		"AA3_MANPRE"		 + ";" + ;			       		
			       		"AA3_EXIGNF"		 + ";" + ;
			       		"AA3_EQ3"		 	 + ";" + ;
			       		"AA3_FILORI"		 + ";" + ;
			       		"AA3_OSMONT"		 + ";" + ;
			       		"AA3_HMEATV"		 + ";" + ;
			       		"PRODUTO_KEY"		 + ";" + ;
			       		"CLIENTE_KEY"		 + ";" + ;
			       		"DATA_EXTRACAO"		 + CRLF )
		nCont++			       		
	
		While ( cAliasT )->( !Eof() )
		
			If !lAuto
				oProcess:IncRegua1("Extraindo Gestao de Serviços..." )
			EndIf

			If  Year( StoD( ( cAliasT )->AA3_DTVEND ) ) > 2050
				cDtVend := "31/12/2050" 
			Else
				cDtVend := If( Empty( ( cAliasT )->AA3_DTVEND )	,"",AllTrim( DtoC( StoD( ( cAliasT )->AA3_DTVEND ) ) ) )
			EndIf

			If  Year( StoD( ( cAliasT )->AA3_DTINST ) ) > 2050
				cDtInst := "31/12/2050" 
			Else
				cDtInst := If( Empty( ( cAliasT )->AA3_DTINST )	,"",AllTrim( DtoC( StoD( ( cAliasT )->AA3_DTINST ) ) ) )
			EndIf
						
			If  Year( StoD( ( cAliasT )->AA3_DTGAR ) ) > 2050
				cDtGar := "31/12/2050" 
			Else
				cDtGar := If( Empty( ( cAliasT )->AA3_DTGAR )	,"",AllTrim( DtoC( StoD( ( cAliasT )->AA3_DTGAR ) ) ) )
			EndIf									
			
			  		
			FWRITE(	nHandle,AllTrim( ( cAliasT )->AA3_FILIAL ) + AllTrim( ( cAliasT )->AA3_CODCLI ) + AllTrim( ( cAliasT )->AA3_LOJA ) + AllTrim( ( cAliasT )->AA3_CODPRO ) + AllTrim( ( cAliasT )->AA3_NUMSER ) + ";" + ;
			       			AllTrim( ( cAliasT )->AA3_FILIAL )			+ ";" + ;			       						
			       			AllTrim( ( cAliasT )->AA3_NUMSER )			+ ";" + ;
			       			cDtVend										+ ";" + ;
			       			cDtInst										+ ";" + ;
			       			cDtGar										+ ";" + ;
			       			AllTrim( ( cAliasT )->AA3_CBASE )			+ ";" + ;
			       			AllTrim( ( cAliasT )->AA3_ITEM )			+ ";" + ;			       			
			       			AllTrim( ( cAliasT )->AA3_CHAPA )			+ ";" + ;
			       			AllTrim( xFilial("AA1") ) + AllTrim( ( cAliasT )->AA3_CODTEC )	+ ";" + ;
			       			AllTrim( ( cAliasT )->AA3_NFVEND )			+ ";" + ;			       			
			       			AllTrim( Str( ( cAliasT )->AA3_VLRCTR ) )	+ ";" + ;
			       			AllTrim( Str( ( cAliasT )->AA3_HORDIA ) )	+ ";" + ;			       						       						       			
			       			AllTrim( ( cAliasT )->AA3_STATUS )			+ ";" + ;
			       			AllTrim( ( cAliasT )->AA3_STAANT )			+ ";" + ;
			       			AllTrim( ( cAliasT )->AA3_EQALOC )			+ ";" + ;
			       			AllTrim( ( cAliasT )->AA3_MANPRE )			+ ";" + ;
			       			AllTrim( ( cAliasT )->AA3_EXIGNF )			+ ";" + ;
			       			AllTrim( ( cAliasT )->AA3_EQ3 )				+ ";" + ;			       			
			       			AllTrim( ( cAliasT )->AA3_FILORI )			+ ";" + ;
			       			AllTrim( ( cAliasT )->AA3_OSMONT )			+ ";" + ;
			       			AllTrim( ( cAliasT )->AA3_HMEATV )			+ ";" + ;			       			
			       			AllTrim( xFilial("SB1") ) + AllTrim( ( cAliasT )->AA3_CODPRO ) 										+ ";" + ;
			       			AllTrim( xFilial("SA1") ) + AllTrim( ( cAliasT )->AA3_CODCLI ) + AllTrim( ( cAliasT )->AA3_LOJA ) 	+ ";" + ;
			       			cExtracao + CRLF )
			nCont++
		
			( cAliasT )->( dbSkip() )
			
		EndDo
	
		cMsg += "Registros exportados da Gestão de Serviços (AA3): " + cValToChar( nCont ) + CRLF
		
	EndIf
	
	( cAliasT )->( dbCloseArea() )
	
	fClose( nHandle )
	
	If !lAuto
		oProcess:SaveLog( "Fim da Exportação da Gestão de Serviços (AA3)" )
	EndIf
	
Return( cMsg )

/*
|============================================================================|
|============================================================================|
|||-----------+----------+-------+-----------------------+------+----------|||
||| Funcao    |M010SCPExp| Autor | Denis Rodrigues       | Data |23/11/2017|||
|||-----------+----------+-------+-----------------------+------+----------|||
||| Descricao | Funcao de Extracao da tabela de Solicitacao ao Armazem SCP |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   | M010SCPEXP(ExpO01,ExpL01)                                  |||
|||-----------+------------------------------------------------------------|||
||| Parametros|ExpO01 - Objeto do TnewProcess                              |||
|||           |Expl01 - Indica se era gerado pela rotina automatica        |||
|||-----------+------------------------------------------------------------|||
||| Retorno   |                                                            |||
|||-----------+------------------------------------------------------------|||
|============================================================================|
|============================================================================|*/
Static Function M010SCPExp( oProcess,lAuto )

	Local cAliasT	:= GetNextAlias()
	Local cQuery 	:= ""
	Local cMsg 		:= ""
	Local cExtracao	:= DtoC( Date() ) + " - " + Time()
	Local cDtPrf	:= ""	
	Local cDtEmiss	:= ""
	Local nCont		:= 0
	Local nHandle	:= 0

	If !lAuto		
		oProcess:SaveLog("Inicio da Exportacao da Tabela de Solicitação ao Armazém (SCP)")
		oProcess:SetRegua1( 0 )
	Else
		ConOut("Inicio da Exportacao da Tabela de Solicitação ao Armazém (SCP) - SCHEDULE")	
	EndIf
	
	cQuery := " SELECT CP_FILIAL,"
	cQuery += "        CP_NUM,"
	cQuery += "        CP_ITEM,"
	cQuery += "        CP_PRODUTO,"
	cQuery += "        CP_DESCRI,"
	cQuery += "        CP_UM,"
	cQuery += "        CP_QUANT,"
	cQuery += "        CP_DATPRF,"
	cQuery += "        CP_LOCAL,"
	cQuery += "        CP_EMISSAO,"
	cQuery += "        CP_SOLICIT,"
	cQuery += "        CP_QUJE,"
	cQuery += "        CP_PREREQU,"
	cQuery += "        CP_STATUS,"
	cQuery += "        CP_NUMOS,"
	cQuery += "        CP_SEQRC,"
	cQuery += "        CP_STATSA,"
	cQuery += "        CP_SALBLQ,"
	cQuery += "        CP_VUNIT"
	cQuery += " FROM " + RetSQLName("SCP") 	
	cQuery += " WHERE D_E_L_E_T_ <> '*'"
	 			 	
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T. )
	
	If ( cAliasT )->( !Eof() )
	
		nHandle := fCreate("\m010Exporta\solicitacao_armazem_scp.csv", FC_NORMAL)

		//Titulo das colunas do arquivo
		FWRITE(	nHandle,"SOLICIT_ARMAZEM_KEY"	+ ";" + ;
			       		"ESTABELECIMENTO_KEY"	+ ";" + ;
			       		"CP_NUM"				+ ";" + ;
			       		"CP_ITEM"				+ ";" + ;
			       		"CP_DESCRI"				+ ";" + ;			       		
			       		"CP_UM"					+ ";" + ;
			       		"CP_QUANT"				+ ";" + ;
			       		"CP_DATPRF"				+ ";" + ;			       		
			       		"CP_EMISSAO"			+ ";" + ;
			       		"CP_SOLICIT"			+ ";" + ;
			       		"CP_QUJE"				+ ";" + ;
			       		"CP_PREREQU"			+ ";" + ;
			       		"CP_STATUS"				+ ";" + ;			       		
			       		"CP_NUMOS"				+ ";" + ;
			       		"CP_SEQRC"				+ ";" + ;
			       		"CP_STATSA"				+ ";" + ;
			       		"CP_SALBLQ"				+ ";" + ;
			       		"CP_VUNIT"				+ ";" + ;
			       		"PRODUTO_KEY"			+ ";" + ;				       		
			       		"ARMAZEM_KEY"			+ ";" + ;			       		
			       		"DATA_EXTRACAO"		+ CRLF )
		nCont++
			
		While ( cAliasT )->( !Eof() )

			If !lAuto
				oProcess:IncRegua1("Exportando Tabela de Solicitação ao Armazem..." )
			EndIf
			
			If  Year( StoD( ( cAliasT )->CP_DATPRF ) ) > 2050
				cDtPrf := "31/12/2050" 
			Else
				cDtPrf := If( Empty( ( cAliasT )->CP_DATPRF ) ,"",AllTrim( DtoC( StoD( ( cAliasT )->CP_DATPRF ) ) ) )
			EndIf
			
			If  Year( StoD( ( cAliasT )->CP_EMISSAO ) ) > 2050
				cDtEmiss := "31/12/2050" 
			Else
				cDtEmiss := If( Empty( ( cAliasT )->CP_EMISSAO ) ,"",AllTrim( DtoC( StoD( ( cAliasT )->CP_EMISSAO ) ) ) )
			EndIf	
					
			FWRITE(	nHandle,AllTrim( ( cAliasT )->CP_FILIAL ) + AllTrim( ( cAliasT )->CP_NUM ) + AllTrim( ( cAliasT )->CP_ITEM ) + AllTrim( ( cAliasT )->CP_EMISSAO ) + ";" + ;
			       			AllTrim( ( cAliasT )->CP_FILIAL )								+ ";" + ;
			       			AllTrim( ( cAliasT )->CP_NUM )									+ ";" + ;
			       			AllTrim( ( cAliasT )->CP_ITEM )									+ ";" + ;
			       			StrTran( AllTrim( ( cAliasT )->CP_DESCRI ),";" )				+ ";" + ;
			       			AllTrim( ( cAliasT )->CP_UM )									+ ";" + ;			       			
			       			AllTrim( Str( ( cAliasT )->CP_QUANT ) )							+ ";" + ;			       			
			       			cDtPrf															+ ";" + ;
			       			cDtEmiss														+ ";" + ;
			       			AllTrim( ( cAliasT )->CP_SOLICIT )								+ ";" + ;			       			
			       			AllTrim( Str( ( cAliasT )->CP_QUJE ) )							+ ";" + ;
			       			AllTrim( ( cAliasT )->CP_PREREQU )								+ ";" + ;
			       			AllTrim( ( cAliasT )->CP_STATUS )								+ ";" + ;
			       			AllTrim( ( cAliasT )->CP_NUMOS )								+ ";" + ;
			       			AllTrim( ( cAliasT )->CP_SEQRC )								+ ";" + ;
			       			AllTrim( ( cAliasT )->CP_STATSA )								+ ";" + ;
			       			AllTrim( ( cAliasT )->CP_SALBLQ )								+ ";" + ;			       			
			       			AllTrim( Str( ( cAliasT )->CP_VUNIT ) )							+ ";" + ;
			       			AllTrim( xFilial("SB1") ) + AllTrim( ( cAliasT )->CP_PRODUTO )	+ ";" + ;			       			
			       			AllTrim( xFilial("SCP") ) + AllTrim( ( cAliasT )->CP_LOCAL )	+ ";" + ;
			       			cExtracao + CRLF )
		       			
			nCont++			       		
	
			( cAliasT )->( dbSkip() )
		
		EndDo

		cMsg += "Registros exportados da Tabela de Solicitação ao Armazem (SCP): " + cValToChar( nCont ) + CRLF
		
		fClose( nHandle )		
	
	EndIf
		
	If !lAuto
		oProcess:SaveLog( "Fim da Exportacao da Tabela de Solicitação ao Armazem (SCP)" )
	EndIf
		
Return( cMsg )

/*
|============================================================================|
|============================================================================|
|||-----------+----------+-------+-----------------------+------+----------|||
||| Funcao    |M010AA1Exp| Autor | Denis Rodrigues       | Data |06/12/2017|||
|||-----------+----------+-------+-----------------------+------+----------|||
||| Descricao | Processa a Extracao da tabela de Base de Atendimento AA1   |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   | M010AA1EXP(ExpO01,ExpL01)                                  |||
|||-----------+------------------------------------------------------------|||
||| Parametros|ExpO01 - Objeto do TnewProcess                              |||
|||           |Expl01 - Indica se era gerado pela rotina automatica        |||
|||-----------+------------------------------------------------------------|||
||| Retorno   |                                                            |||
|||-----------+------------------------------------------------------------|||
|============================================================================|
|============================================================================|*/
Static Function M010AA1Exp(oProcess,lAuto)

	Local cAliasT		:= GetNextAlias()
	Local cQuery 		:= ""
	Local cMsg 	   		:= ""
	Local cExtracao		:= DtoC( Date() ) + " - " + Time()
	Local nCont	   		:= 0
	Local nHandle		:= 0

	If !lAuto		
		oProcess:SaveLog("Inicio da Extracao da Tabela de Tenicos (AA1)")
		oProcess:SetRegua1( 0 )	
	Else
		ConOut("Inicio da Extracao da Tabela de Tecnicos (AA1) - SCHEDULE")
	EndIf
	
	cQuery := " SELECT AA1_FILIAL,"
	cQuery += "        AA1_CODTEC,"			
	cQuery += "        AA1_NOMTEC,"			
	cQuery += "        AA1_FUNCAO,"
	cQuery += "        AA1_CC,"
	cQuery += "        AA1_NREDUZ"
	cQuery += " FROM " + RetSQLName("AA1")
	cQuery += " WHERE D_E_L_E_T_<>'*'" 			 	
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T. )
	
	If ( cAliasT )->( !Eof() )
	
		nHandle := fCreate("\m010Exporta\tecnicos_aa1.csv", FC_NORMAL)
	
		//Titulo das colunas do arquivo
		FWRITE(	nHandle,"TECNICOS_KEY"	+ ";" + ;			       		
			       		"AA1_FILIAL"	+ ";" + ;			       		
			       		"AA1_CODTEC"	+ ";" + ;
			       		"AA1_NOMTEC"	+ ";" + ;
			       		"AA1_FUNCAO"	+ ";" + ;
			       		"AA1_CC"		+ ";" + ;
			       		"AA1_NREDUZ"	+ ";" + ;
			       		"DATA_EXTRACAO"		 + CRLF )
		nCont++			       		
	
		While ( cAliasT )->( !Eof() )
		
			If !lAuto
				oProcess:IncRegua1("Extraindo Técnicos..." )
			EndIf
			  		
			FWRITE(	nHandle,AllTrim( ( cAliasT )->AA1_FILIAL ) + AllTrim( ( cAliasT )->AA1_CODTEC ) + ";" + ;
			       			AllTrim( ( cAliasT )->AA1_FILIAL )			+ ";" + ;			       						
			       			AllTrim( ( cAliasT )->AA1_CODTEC )			+ ";" + ;
			       			AllTrim( ( cAliasT )->AA1_NOMTEC )			+ ";" + ;
			       			AllTrim( ( cAliasT )->AA1_FUNCAO )			+ ";" + ;			       			
			       			AllTrim( ( cAliasT )->AA1_CC )				+ ";" + ;
			       			AllTrim( ( cAliasT )->AA1_NREDUZ )			+ ";" + ;
			       			cExtracao + CRLF )
			nCont++
		
			( cAliasT )->( dbSkip() )
			
		EndDo
	
		cMsg += "Registros exportados de Técnicos (AA1): " + cValToChar( nCont ) + CRLF
		
	EndIf
	
	( cAliasT )->( dbCloseArea() )
	
	fClose( nHandle )
	
	If !lAuto
		oProcess:SaveLog( "Fim da Exportação de Técnicos (AA1)" )
	EndIf
	
Return( cMsg )

/*
|============================================================================|
|============================================================================|
|||-----------+----------+-------+-----------------------+------+----------|||
||| Funcao    |M010AB1Exp| Autor | Denis Rodrigues       | Data |19/12/2017|||
|||-----------+----------+-------+-----------------------+------+----------|||
||| Descricao | Processa a Extracao da tabela de Chamada Técnico AB1 - AB2 |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   | M010AB1EXP(ExpO01,ExpL01)                                  |||
|||-----------+------------------------------------------------------------|||
||| Parametros|ExpO01 - Objeto do TnewProcess                              |||
|||           |Expl01 - Indica se era gerado pela rotina automatica        |||
|||-----------+------------------------------------------------------------|||
||| Retorno   |                                                            |||
|||-----------+------------------------------------------------------------|||
|============================================================================|
|============================================================================|*/
Static Function M010AB1Exp(oProcess,lAuto)

	Local cAliasT	:= GetNextAlias()
	Local cQuery 	:= ""
	Local cMsg 	   	:= ""
	Local cExtracao	:= DtoC( Date() ) + " - " + Time()
	Local cDtEmiss1	:= ""
	Local cDtEmiss2	:= ""
	Local nCont	   	:= 0
	Local nHandle	:= 0

	If !lAuto		
		oProcess:SaveLog("Inicio da Extração da Tabela de Chamado Técnico (AB1/AB2)")
		oProcess:SetRegua1( 0 )	
	Else
		ConOut("Inicio da Extracao da Tabela de Chamado Técnico (AB1/AB2) - SCHEDULE")
	EndIf
	
	cQuery := " SELECT AB1.AB1_FILIAL,"
	cQuery += "        AB1.AB1_NRCHAM,"
	cQuery += "        AB1.AB1_EMISSA,"
	cQuery += "        AB1.AB1_CODCLI,"
	cQuery += "        AB1.AB1_LOJA,"
	cQuery += "        AB1.AB1_HORA,"
	cQuery += "        AB1.AB1_HORAF,"
	cQuery += "        AB1.AB1_CONTAT,"
	cQuery += "        AB1.AB1_TEL,"
	cQuery += "        AB1.AB1_ATEND,"
	cQuery += "        AB1.AB1_STATUS,"
	cQuery += "        AB1.AB1_OK,"
	cQuery += "        AB1.AB1_REGIAO,"
	cQuery += "        AB1.AB1_NUMTMK,"	
	cQuery += "        AB1.AB1_LOCAL,"
	cQuery += "        AB1.AB1_GARANT,"
	cQuery += "        AB2.AB2_ITEM,"
	cQuery += "        AB2.AB2_TIPO,"
	cQuery += "        AB2.AB2_CLASSI,"
	cQuery += "        AB2.AB2_CODPRO,"
	cQuery += "        AB2.AB2_NUMSER,"
	cQuery += "        AB2.AB2_CODPRB,"
	cQuery += "        AB2.AB2_NUMOS,"
	cQuery += "        AB2.AB2_NUMORC,"
	cQuery += "        AB2.AB2_CODFAB,"
	cQuery += "        AB2.AB2_LOJAFA,"
	cQuery += "        AB2.AB2_BXDATA,"
	cQuery += "        AB2.AB2_BXHORA,"
	cQuery += "        AB2.AB2_NUMHDE,"
	cQuery += "        AB2.AB2_CODFNC,"
	cQuery += "        AB2.AB2_FNCREV"	
	cQuery += " FROM " + RetSQLName("AB1") + " AB1,"
	cQuery +=            RetSQLName("AB2") + " AB2"	
	cQuery += " WHERE AB1.D_E_L_E_T_ <> '*'"
	cQuery += "   AND AB2.AB2_FILIAL = AB1.AB1_FILIAL"
	cQuery += "   AND AB2.AB2_NRCHAM = AB1.AB1_NRCHAM"
	cQuery += "   AND AB2.D_E_L_E_T_ <>'*'"
	 
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T. )
	
	If ( cAliasT )->( !Eof() )
	
		nHandle := fCreate("\m010Exporta\chamadotecnico_ab1ab2.csv", FC_NORMAL)
	
		//Titulo das colunas do arquivo
		FWRITE(	nHandle,"CHAMADOTECNICO_KEY"	+ ";" + ;			       		
			       		"AB1_FILIAL"			+ ";" + ;			       		
			       		"AB1_NRCHAM"			+ ";" + ;
			       		"AB1_EMISSA"			+ ";" + ;
			       		"AB1_HORA"				+ ";" + ;
			       		"AB1_HORAF"				+ ";" + ;
			       		"AB1_CONTAT"			+ ";" + ;
			       		"AB1_TEL"				+ ";" + ;
						"AB1_ATEND"				+ ";" + ;
						"AB1_STATUS"			+ ";" + ;
						"AB1_OK"				+ ";" + ;
						"AB1_REGIAO"			+ ";" + ;
						"AB1_NUMTMK"			+ ";" + ;
						"AB1_LOCAL"				+ ";" + ;
						"AB1_GARANT"			+ ";" + ;
						"AB2_ITEM"				+ ";" + ;
						"AB2_TIPO"				+ ";" + ;
						"AB2_CLASSI"			+ ";" + ;						
						"AB2_NUMSER"			+ ";" + ;
						"AB2_CODPRB"			+ ";" + ;
						"AB2_NUMOS"				+ ";" + ;
						"AB2_NUMORC"			+ ";" + ;
						"AB2_CODFAB"			+ ";" + ;
						"AB2_LOJAFA"			+ ";" + ;
						"AB2_BXDATA"			+ ";" + ;
						"AB2_BXHORA"			+ ";" + ;
						"AB2_NUMHDE"			+ ";" + ;
						"AB2_CODFNC"			+ ";" + ;
						"AB2_FNCREV"			+ ";" + ;
						"PRODUTO_KEY"			+ ";" + ;
						"CLIENTE_KEY"			+ ";" + ;
			       		"DATA_EXTRACAO"		 	+ CRLF )
		nCont++			       		
	
		While ( cAliasT )->( !Eof() )
		
			If !lAuto
				oProcess:IncRegua1("Extraindo Chamado técnico..." )
			EndIf

			If Year( StoD( ( cAliasT )->AB1_EMISSA ) ) > 2050
				cDtEmiss1 := "31/12/2050" 
			Else
				cDtEmiss1 := If( Empty( ( cAliasT )->AB1_EMISSA ) ,"",AllTrim( DtoC( StoD( ( cAliasT )->AB1_EMISSA ) ) ) )
			EndIf

			If Year( StoD( ( cAliasT )->AB2_BXHORA ) ) > 2050
				cDtEmiss2 := "31/12/2050" 
			Else
				cDtEmiss2 := If( Empty( ( cAliasT )->AB2_BXHORA ) ,"",AllTrim( DtoC( StoD( ( cAliasT )->AB2_BXHORA ) ) ) )
			EndIf
			
									
			  		
			FWRITE(	nHandle,AllTrim( ( cAliasT )->AB1_FILIAL ) + AllTrim( ( cAliasT )->AB1_NRCHAM ) + AllTrim( ( cAliasT )->AB2_ITEM ) + ";" + ;
			       			AllTrim( ( cAliasT )->AB1_FILIAL )			+ ";" + ;			       						
			       			AllTrim( ( cAliasT )->AB1_NRCHAM )			+ ";" + ;
			       			cDtEmiss1									+ ";" + ;			       			
			       			AllTrim( ( cAliasT )->AB1_HORA )			+ ";" + ;
			       			AllTrim( ( cAliasT )->AB1_HORAF )			+ ";" + ;
			       			AllTrim( ( cAliasT )->AB1_CONTAT )			+ ";" + ;
			       			AllTrim( ( cAliasT )->AB1_TEL )				+ ";" + ;
			       			AllTrim( ( cAliasT )->AB1_ATEND )			+ ";" + ;
			       			AllTrim( ( cAliasT )->AB1_STATUS )			+ ";" + ;
			       			AllTrim( ( cAliasT )->AB1_OK )				+ ";" + ;
			       			AllTrim( ( cAliasT )->AB1_REGIAO )			+ ";" + ;
			       			AllTrim( ( cAliasT )->AB1_NUMTMK )			+ ";" + ;
			       			AllTrim( ( cAliasT )->AB1_LOCAL )			+ ";" + ;
			       			AllTrim( ( cAliasT )->AB1_GARANT )			+ ";" + ;
			       			AllTrim( ( cAliasT )->AB2_ITEM )			+ ";" + ;
			       			AllTrim( ( cAliasT )->AB2_TIPO )			+ ";" + ;
			       			AllTrim( ( cAliasT )->AB2_CLASSI )			+ ";" + ;			       			
			       			AllTrim( ( cAliasT )->AB2_NUMSER )			+ ";" + ;
			       			AllTrim( ( cAliasT )->AB2_CODPRB )			+ ";" + ;			       			
			       			AllTrim( ( cAliasT )->AB2_NUMOS )			+ ";" + ;
			       			AllTrim( ( cAliasT )->AB2_NUMORC )			+ ";" + ;			       			
			       			AllTrim( ( cAliasT )->AB2_CODFAB )			+ ";" + ;
			       			AllTrim( ( cAliasT )->AB2_LOJAFA )			+ ";" + ;
			       			cDtEmiss2									+ ";" + ;
			       			AllTrim( ( cAliasT )->AB2_BXHORA )			+ ";" + ;
			       			AllTrim( ( cAliasT )->AB2_NUMHDE )			+ ";" + ;
			       			AllTrim( ( cAliasT )->AB2_CODFNC )			+ ";" + ;
			       			AllTrim( ( cAliasT )->AB2_FNCREV )			+ ";" + ;
			       			AllTrim( xFilial("SB1") ) + AllTrim( ( cAliasT )->AB2_CODPRO ) + ";" + ;
			       			AllTrim( xFilial("SA1") ) + AllTrim( ( cAliasT )->AB1_CODCLI ) + AllTrim( ( cAliasT )->AB1_LOJA ) + ";" + ;
			       			cExtracao + CRLF )
			nCont++
		
			( cAliasT )->( dbSkip() )
			
		EndDo
	
		cMsg += "Registros exportados do Chamado Tecnico (AB1/AB2): " + cValToChar( nCont ) + CRLF
		
	EndIf
	
	( cAliasT )->( dbCloseArea() )
	
	fClose( nHandle )
	
	If !lAuto
		oProcess:SaveLog( "Fim da Exportação do Chamado Técnico (AB1/AB2)" )
	EndIf
	
Return( cMsg )


/*
|============================================================================|
|============================================================================|
|||-----------+----------+-------+-----------------------+------+----------|||
||| Funcao    |M010AB3Exp| Autor | Denis Rodrigues       | Data |19/12/2017|||
|||-----------+----------+-------+-----------------------+------+----------|||
||| Descricao | Processa a Extracao da tabela de Orçamento AB3/AB4/AB5     |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   | M010AB1EXP(ExpO01,ExpL01)                                  |||
|||-----------+------------------------------------------------------------|||
||| Parametros|ExpO01 - Objeto do TnewProcess                              |||
|||           |Expl01 - Indica se era gerado pela rotina automatica        |||
|||-----------+------------------------------------------------------------|||
||| Retorno   |                                                            |||
|||-----------+------------------------------------------------------------|||
|============================================================================|
|============================================================================|*/
Static Function M010AB3Exp(oProcess,lAuto)

	Local cAliasT	:= GetNextAlias()
	Local cQuery 	:= ""
	Local cMsg 	   	:= ""
	Local cExtracao	:= DtoC( Date() ) + " - " + Time()
	Local cDtEmiss1	:= ""
	Local cData1	:= ""
	Local cData2	:= ""
	Local cData3	:= ""
	Local cData4	:= ""
	Local cBxData	:= ""
	Local nCont	   	:= 0
	Local nHandle	:= 0

	If !lAuto		
		oProcess:SaveLog("Inicio da Extração da Tabela de Orçamento Técnicos (AB3/AB4/AB5)")
		oProcess:SetRegua1( 0 )	
	Else
		ConOut("Inicio da Extracao da Tabela de Orçamento Técnicos (AB3/AB4/AB5) - SCHEDULE")
	EndIf
	
	cQuery := " SELECT AB3_FILIAL,"
	cQuery += "        AB3_NUMORC,"
	cQuery += "        AB3_CODCLI,"
	cQuery += "        AB3_LOJA,"
	cQuery += "        AB3_EMISSA,"
	cQuery += "        AB3_ATEND,"
	cQuery += "        AB3_STATUS,"
	cQuery += "        AB3_CONPAG,"
	cQuery += "        AB3_DESC1,"
	cQuery += "        AB3_DESC2,"
	cQuery += "        AB3_DESC3,"
	cQuery += "        AB3_DESC4,"
	cQuery += "        AB3_TABELA,"
	cQuery += "        AB3_PARC1,"
	cQuery += "        AB3_DATA1,"
	cQuery += "        AB3_PARC2,"
	cQuery += "        AB3_DATA2,"
	cQuery += "        AB3_PARC3,"
	cQuery += "        AB3_DATA3,"
	cQuery += "        AB3_PARC4,"
	cQuery += "        AB3_DATA4,"
	cQuery += "        AB3_OK,"
	cQuery += "        AB3_HORA,"
	cQuery += "        AB3_REGIAO,"
	cQuery += "        AB3_MOEDA,"
	cQuery += "        AB3_TXMOED,"
	cQuery += "        AB3_FASE,"  
	cQuery += "(SELECT A1_VEND FROM SA1010 where D_E_L_E_T_='' and A1_COD = AB3.AB3_CODCLI and A1_LOJA = AB3.AB3_LOJA) as Vendedor,"
	
	cQuery += "        AB4_ITEM,"
	cQuery += "        AB4_TIPO,"
	cQuery += "        AB4_CODPRO,"
	cQuery += "        AB4_NUMSER,"
	cQuery += "        AB4_CODPRB,"
	cQuery += "        AB4_NRCHAM,"
	cQuery += "        AB4_NUMOS,"
	cQuery += "        AB4_CODFAB,"
	cQuery += "        AB4_LOJAFA,"
	cQuery += "        AB4_BXDATA,"
	cQuery += "        AB4_BXHORA,"
	cQuery += "        AB4_OSORIG,"
	
	cQuery += "        AB5_ITEM,"
	cQuery += "        AB5_SUBITE,"
	cQuery += "        AB5_CODPRO,"
	//cQuery += "        AB5_DESPRO,"
	cQuery += "        AB5_CODSER,"
	cQuery += "        AB5_QUANT,"
	cQuery += "        AB5_VUNIT,"
	cQuery += "        AB5_TOTAL,"
	cQuery += "        AB5_PRCLIS"
	cQuery += " FROM (" + RetSQLName("AB3") + " AB3 INNER JOIN " + RetSQLName("AB4") + " AB4"
	cQuery += " ON  AB3.AB3_FILIAL = AB4.AB4_FILIAL"
	cQuery += " AND AB3.AB3_NUMORC = AB4.AB4_NUMORC)" 
	cQuery += " INNER JOIN " + RetSQLName("AB5") + " AB5" 
	cQuery += " ON AB4.AB4_FILIAL  = AB5.AB5_FILIAL"
	cQuery += " AND AB4.AB4_NUMORC = AB5.AB5_NUMORC"
	cQuery += " AND AB4.AB4_ITEM   = AB5.AB5_ITEM"
	cQuery += " WHERE AB3.D_E_L_E_T_ <> '*'"
	cQuery += "   AND AB4.D_E_L_E_T_ <> '*'"
	cQuery += "   AND AB5.D_E_L_E_T_ <> '*'"
		 
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T. )
	
	If ( cAliasT )->( !Eof() )
	
		nHandle := fCreate("\m010Exporta\orcamentotecnico_ab3ab4ab5.csv", FC_NORMAL)
	
		//Titulo das colunas do arquivo
		FWRITE(	nHandle,"ORCAMENTO_KEY"	+ ";" + ;		
					 	"AB3_FILIAL"	+ ";" + ;
						"AB3_NUMORC"	+ ";" + ;
						"AB3_EMISSA"	+ ";" + ;
						"AB3_ATEND"		+ ";" + ;
						"AB3_STATUS"	+ ";" + ;
						"AB3_DESC1"		+ ";" + ;
						"AB3_DESC2"		+ ";" + ;
						"AB3_DESC3"		+ ";" + ;
						"AB3_DESC4"		+ ";" + ;
						"AB3_TABELA"	+ ";" + ;
						"AB3_PARC1"		+ ";" + ;
						"AB3_DATA1"		+ ";" + ;
						"AB3_PARC2"		+ ";" + ;
						"AB3_DATA2"		+ ";" + ;
						"AB3_PARC3"		+ ";" + ;
						"AB3_DATA3"		+ ";" + ;
						"AB3_PARC4"		+ ";" + ;
						"AB3_DATA4"		+ ";" + ;
						"AB3_OK"		+ ";" + ;
						"AB3_HORA"		+ ";" + ;
						"AB3_REGIAO"	+ ";" + ;
						"AB3_MOEDA"		+ ";" + ;
						"AB3_TXMOED"	+ ";" + ;    
						"AB3_FASE"		+ ";" + ;
						"AB4_ITEM"		+ ";" + ;
						"AB4_TIPO"		+ ";" + ;
						"AB4_NUMSER"	+ ";" + ;
						"AB4_CODPRB"	+ ";" + ;
						"AB4_NRCHAM"	+ ";" + ;
						"AB4_NUMOS"		+ ";" + ;
						"AB4_CODFAB"	+ ";" + ;
						"AB4_LOJAFA"	+ ";" + ;
						"AB4_BXDATA"	+ ";" + ;
						"AB4_BXHORA"	+ ";" + ;
						"AB4_OSORIG"	+ ";" + ;
						"AB5_ITEM"		+ ";" + ;
						"AB5_SUBITE"	+ ";" + ;
						"AB5_CODSER"	+ ";" + ;
						"AB5_QUANT"		+ ";" + ;
						"AB5_VUNIT"		+ ";" + ;
						"AB5_TOTAL"		+ ";" + ;
						"AB5_PRCLIS"	+ ";" + ;
						"CONDPAG_KEY"	+ ";" + ;
						"PRODUTO_KEY"	+ ";" + ;
						"EQUIPAMENTO_KEY"	+ ";" + ;
						"CLIENTE_KEY"	+ ";" + ;
						"MOEDA_KEY"		+ ";" + ;  
						"VENDEDOR_KEY"	+ ";" + ;
			       		"DATA_EXTRACAO"	+ CRLF )
		nCont++			       		
	
		While ( cAliasT )->( !Eof() )
		
			If !lAuto
				oProcess:IncRegua1("Extraindo Orçamento Técnico..." )
			EndIf

			If Year( StoD( ( cAliasT )->AB3_EMISSA ) ) > 2050
				cDtEmiss1 := "31/12/2050" 
			Else
				cDtEmiss1 := If( Empty( ( cAliasT )->AB3_EMISSA ) ,"",AllTrim( DtoC( StoD( ( cAliasT )->AB3_EMISSA ) ) ) )
			EndIf				

			If Year( StoD( ( cAliasT )->AB3_DATA1 ) ) > 2050
				cData1 := "31/12/2050" 
			Else
				cData1 := If( Empty( ( cAliasT )->AB3_DATA1 ) ,"",AllTrim( DtoC( StoD( ( cAliasT )->AB3_DATA1 ) ) ) )
			EndIf

			If Year( StoD( ( cAliasT )->AB3_DATA2 ) ) > 2050
				cData2 := "31/12/2050" 
			Else
				cData2 := If( Empty( ( cAliasT )->AB3_DATA2 ) ,"",AllTrim( DtoC( StoD( ( cAliasT )->AB3_DATA2 ) ) ) )
			EndIf

			If Year( StoD( ( cAliasT )->AB3_DATA3 ) ) > 2050
				cData3 := "31/12/2050" 
			Else
				cData3 := If( Empty( ( cAliasT )->AB3_DATA3 ) ,"",AllTrim( DtoC( StoD( ( cAliasT )->AB3_DATA3 ) ) ) )
			EndIf

			If Year( StoD( ( cAliasT )->AB3_DATA4 ) ) > 2050
				cData4 := "31/12/2050" 
			Else
				cData4 := If( Empty( ( cAliasT )->AB3_DATA4 ) ,"",AllTrim( DtoC( StoD( ( cAliasT )->AB3_DATA4 ) ) ) )
			EndIf
																	
			If Year( StoD( ( cAliasT )->AB4_BXHORA ) ) > 2050
				cBxData := "31/12/2050" 
			Else
				cBxData := If( Empty( ( cAliasT )->AB4_BXHORA ) ,"",AllTrim( DtoC( StoD( ( cAliasT )->AB4_BXHORA ) ) ) )
			EndIf																
			  		
			FWRITE(	nHandle,AllTrim( ( cAliasT )->AB3_FILIAL ) + AllTrim( ( cAliasT )->AB3_NUMORC ) + ";" + ;
			       			AllTrim( ( cAliasT )->AB3_FILIAL )			+ ";" + ;			       						
			       			AllTrim( ( cAliasT )->AB3_NUMORC )			+ ";" + ;
			       			cDtEmiss1 									+ ";" + ;			       			
			       			AllTrim( ( cAliasT )->AB3_ATEND )			+ ";" + ;
			       			AllTrim( ( cAliasT )->AB3_STATUS )			+ ";" + ;			       			
			       			AllTrim( Str( ( cAliasT )->AB3_DESC1 ) )	+ ";" + ;
							AllTrim( Str( ( cAliasT )->AB3_DESC2 ) )	+ ";" + ;
							AllTrim( Str( ( cAliasT )->AB3_DESC3 ) )	+ ";" + ;
							AllTrim( Str( ( cAliasT )->AB3_DESC4 ) )	+ ";" + ;			       			
			       			AllTrim( ( cAliasT )->AB3_TABELA )			+ ";" + ;			       			
			       			AllTrim( Str( ( cAliasT )->AB3_PARC1 ) )	+ ";" + ;			       			
			       			cData1										+ ";" + ;			       			
			       			AllTrim( Str( ( cAliasT )->AB3_PARC2 ) )	+ ";" + ;
			       			cData2										+ ";" + ;			       			
			       			AllTrim( Str( ( cAliasT )->AB3_PARC3 ) )	+ ";" + ;			       						       			
			       			cData3										+ ";" + ;			       			
			       			AllTrim( Str( ( cAliasT )->AB3_PARC4 ) )	+ ";" + ;
			       			cData4										+ ";" + ;			       			
			       			AllTrim( ( cAliasT )->AB3_OK )				+ ";" + ;			       			
			       			AllTrim( ( cAliasT )->AB3_HORA )			+ ";" + ;
			       			AllTrim( ( cAliasT )->AB3_REGIAO )			+ ";" + ;			       						       		
			       			AllTrim( Str( ( cAliasT )->AB3_MOEDA ) )	+ ";" + ;
			       			AllTrim( Str( ( cAliasT )->AB3_TXMOED ) )	+ ";" + ;			       			
			       			AllTrim( ( cAliasT )->AB3_FASE  )			+ ";" + ;
			       			AllTrim( ( cAliasT )->AB4_ITEM )			+ ";" + ;
			       			AllTrim( ( cAliasT )->AB4_TIPO )			+ ";" + ;
			       			AllTrim( ( cAliasT )->AB4_NUMSER )			+ ";" + ;
			       			AllTrim( ( cAliasT )->AB4_CODPRB )			+ ";" + ;
			       			AllTrim( xFilial("AB1") ) + AllTrim( ( cAliasT )->AB4_NRCHAM )			+ ";" + ;
			       			AllTrim( ( cAliasT )->AB4_NUMOS )			+ ";" + ;
			       			AllTrim( ( cAliasT )->AB4_CODFAB )			+ ";" + ;
			       			AllTrim( ( cAliasT )->AB4_LOJAFA )			+ ";" + ;			       			
			       			cBxData										+ ";" + ;			       			
			       			AllTrim( ( cAliasT )->AB4_BXHORA )			+ ";" + ;
			       			AllTrim( ( cAliasT )->AB4_OSORIG )			+ ";" + ;
			       			AllTrim( ( cAliasT )->AB5_ITEM )			+ ";" + ;
			       			AllTrim( ( cAliasT )->AB5_SUBITE )			+ ";" + ;
			       			AllTrim( ( cAliasT )->AB5_CODSER )			+ ";" + ;			       			
			       			AllTrim( Str( ( cAliasT )->AB5_QUANT ) )	+ ";" + ;
			       			AllTrim( Str( ( cAliasT )->AB5_VUNIT ) )	+ ";" + ;			       			
			       			AllTrim( Str( ( cAliasT )->AB5_TOTAL ) )	+ ";" + ;
			       			AllTrim( Str( ( cAliasT )->AB5_PRCLIS ) )	+ ";" + ;
			       			AllTrim( xFilial("SE4") ) + AllTrim( ( cAliasT )->AB3_CONPAG ) + ";" + ;
			       			AllTrim( xFilial("SB1") ) + AllTrim( ( cAliasT )->AB5_CODPRO ) + ";" + ; 
			       			AllTrim( xFilial("SB1") ) + AllTrim( ( cAliasT )->AB4_CODPRO ) + ";" + ;
			       			AllTrim( xFilial("SA1") ) + AllTrim( ( cAliasT )->AB3_CODCLI ) + AllTrim( ( cAliasT )->AB3_LOJA ) + ";" + ; 
			       			AllTrim( Str( ( cAliasT )->AB3_MOEDA ) )	+ ";" + ;
			       			AllTrim( ( cAliasT )->Vendedor )			+ ";" + ;
			       			cExtracao + CRLF )
			nCont++
		
			( cAliasT )->( dbSkip() )
			
		EndDo
	
		cMsg += "Registros exportados da Tabela de Orçamento Técnico (AB3/AB4/AB5): " + cValToChar( nCont ) + CRLF
		
	EndIf
	
	( cAliasT )->( dbCloseArea() )
	
	fClose( nHandle )
	
	If !lAuto
		oProcess:SaveLog( "Fim da Exportação da Tabela de Orçamento Técnico (AB3/AB4/AB5)" )
	EndIf
	
Return( cMsg )

/*
|============================================================================|
|============================================================================|
|||-----------+----------+-------+-----------------------+------+----------|||
||| Funcao    |M010ABFExp| Autor | Denis Rodrigues       | Data |19/12/2017|||
|||-----------+----------+-------+-----------------------+------+----------|||
||| Descricao | Processa a Extracao da tabela de Requisicao de OS ABF/ABG  |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   | M010ABFExp(ExpO01,ExpL01)                                  |||
|||-----------+------------------------------------------------------------|||
||| Parametros|ExpO01 - Objeto do TnewProcess                              |||
|||           |Expl01 - Indica se era gerado pela rotina automatica        |||
|||-----------+------------------------------------------------------------|||
||| Retorno   |                                                            |||
|||-----------+------------------------------------------------------------|||
|============================================================================|
|============================================================================|*/
Static Function M010ABFEXP(oProcess,lAuto)

	Local cAliasT	:= GetNextAlias()
	Local cQuery 	:= ""
	Local cMsg 	   	:= ""
	Local cExtracao	:= DtoC( Date() ) + " - " + Time()
	Local cDtEmiss	:= ""
	Local nCont	   	:= 0
	Local nHandle	:= 0

	If !lAuto		
		oProcess:SaveLog("Inicio da Extração da Tabela de Requisição de OS (ABF/ABG)")
		oProcess:SetRegua1( 0 )	
	Else
		ConOut("Inicio da Extracao da Tabela de Requisição de OS (ABF/ABG) - SCHEDULE")
	EndIf
	
	cQuery := " SELECT ABF.ABF_FILIAL,"
	cQuery += "        ABF.ABF_EMISSA,"
	cQuery += "        ABF.ABF_NUMOS,"
	cQuery += "        ABF.ABF_ITEMOS,"
	cQuery += "        ABF.ABF_SEQRC,"
	cQuery += "        ABF.ABF_CODTEC,"
	cQuery += "        ABF.ABF_SOLIC,"
	cQuery += "        ABG.ABG_NUMOS,"
	cQuery += "        ABG.ABG_ITEMOS,"
	cQuery += "        ABG.ABG_ITEM,"
	cQuery += "        ABG.ABG_CODPRO,"
	cQuery += "        ABG.ABG_QUANT,"
	cQuery += "        ABG.ABG_UM,"
	cQuery += "        ABG.ABG_CODSER,"
	cQuery += "        ABG.ABG_QSEGUM,"
	cQuery += "        ABG.ABG_SEGUM,"
	cQuery += "        ABG.ABG_NUMSA,"
	cQuery += "        ABG.ABG_ITEMSA,"
	cQuery += "        ABG.ABG_CODTEC,"
	cQuery += "        ABG.ABG_SEQ"	
	cQuery += " FROM " + RetSQLName("ABF") + " ABF INNER JOIN " + RetSQLName("ABG") + " ABG"
	cQuery += " ON ABF.ABF_FILIAL  = ABG.ABG_FILIAL"
	cQuery += " AND ABF.ABF_NUMOS  = ABG.ABG_NUMOS"
	cQuery += " AND ABF.ABF_ITEMOS = ABG.ABG_ITEMOS"
	cQuery += " AND ABF.ABF_SEQRC  = ABG.ABG_SEQRC"
	cQuery += " WHERE ABF.D_E_L_E_T_<>'*'"
	cQuery += "   AND ABG.D_E_L_E_T_<>'*'"
		 
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T. )
	
	If ( cAliasT )->( !Eof() )
	
		nHandle := fCreate("\m010Exporta\requisicaoos_abfabg.csv", FC_NORMAL)		
	
		//Titulo das colunas do arquivo
		FWRITE(	nHandle,"REQUISICAO_KEY" + ";" + ;		
					 	"ABF_FILIAL"	 + ";" + ;
						"ABF_EMISSA"	 + ";" + ;
						"ABF_NUMOS"		 + ";" + ;
						"ABF_ITEMOS"	 + ";" + ;
						"ABF_SEQRC"		 + ";" + ;
						"ABF_SOLIC"		 + ";" + ;
						"ABG_NUMOS"		 + ";" + ;
						"ABG_ITEMOS"	 + ";" + ;
						"ABG_ITEM"		 + ";" + ;
						"ABG_QUANT"		 + ";" + ;
						"ABG_UM"	 	 + ";" + ;
						"ABG_CODSER"	 + ";" + ;
						"ABG_QSEGUM"	 + ";" + ;
						"ABG_SEGUM"		 + ";" + ;
						"ABG_NUMSA"		 + ";" + ;
						"ABG_ITEMSA"	 + ";" + ;
						"ABG_CODTEC"	 + ";" + ;
						"ABG_SEQ"		 + ";" + ;
						"PRODUTO_KEY"	 + ";" + ;
						"TECNICOS_KEY"	 + ";" + ;
			       		"DATA_EXTRACAO"	 + CRLF )
		nCont++			       		
	
		While ( cAliasT )->( !Eof() )
		
			If !lAuto
				oProcess:IncRegua1("Extraindo Requisição de OS..." )
			EndIf
			
			If Year( StoD( ( cAliasT )->ABF_EMISSA ) ) > 2050
				cDtEmiss := "31/12/2050" 
			Else
				cDtEmiss := If( Empty( ( cAliasT )->ABF_EMISSA ) ,"",AllTrim( DtoC( StoD( ( cAliasT )->ABF_EMISSA ) ) ) )
			EndIf			
			  		
			FWRITE(	nHandle,AllTrim( ( cAliasT )->ABF_FILIAL ) + AllTrim( ( cAliasT )->ABF_NUMOS ) + AllTrim( ( cAliasT )->ABF_ITEMOS ) + AllTrim( ( cAliasT )->ABF_SEQRC ) + ";" + ;
			       			AllTrim( ( cAliasT )->ABF_FILIAL )			+ ";" + ;			       						
			       			cDtEmiss									+ ";" + ;
			       			AllTrim( ( cAliasT )->ABF_NUMOS )			+ ";" + ;			       			
			       			AllTrim( ( cAliasT )->ABF_ITEMOS )			+ ";" + ;
			       			AllTrim( ( cAliasT )->ABF_SEQRC )			+ ";" + ;
			       			AllTrim( ( cAliasT )->ABF_SOLIC )			+ ";" + ;
			       			AllTrim( ( cAliasT )->ABG_NUMOS )			+ ";" + ;
			       			AllTrim( ( cAliasT )->ABG_ITEMOS )			+ ";" + ;
			       			AllTrim( ( cAliasT )->ABG_ITEM )			+ ";" + ;
			       			AllTrim( Str( ( cAliasT )->ABG_QUANT ) )	+ ";" + ;			       			
			       			AllTrim( ( cAliasT )->ABG_UM )				+ ";" + ;
			       			AllTrim( ( cAliasT )->ABG_CODSER )			+ ";" + ;
			       			AllTrim( Str( ( cAliasT )->ABG_QSEGUM ) )	+ ";" + ;			       			
			       			AllTrim( ( cAliasT )->ABG_SEGUM )			+ ";" + ;
			       			AllTrim( ( cAliasT )->ABG_NUMSA )			+ ";" + ;
			       			AllTrim( ( cAliasT )->ABG_ITEMSA )			+ ";" + ;
			       			AllTrim( ( cAliasT )->ABG_CODTEC )			+ ";" + ;
			       			AllTrim( ( cAliasT )->ABG_SEQ )				+ ";" + ;
			       			AllTrim( xFilial("SB1") ) + AllTrim( ( cAliasT )->ABG_CODPRO ) + ";" + ;
			       			AllTrim( xFilial("AA1") ) + AllTrim( ( cAliasT )->ABF_CODTEC ) + ";" + ;
			       			cExtracao + CRLF )
			nCont++
		
			( cAliasT )->( dbSkip() )
			
		EndDo
	
		cMsg += "Registros exportados da Tabela de Requisição de OS (ABF/ABG): " + cValToChar( nCont ) + CRLF
		
	EndIf
	
	( cAliasT )->( dbCloseArea() )
	
	fClose( nHandle )
	
	If !lAuto
		oProcess:SaveLog( "Fim da Exportação da Tabela de Requisição de OS (ABF/ABG)" )
	EndIf
	
Return( cMsg )


/*
|============================================================================|
|============================================================================|
|||-----------+----------+-------+-----------------------+------+----------|||
||| Funcao    |M010AB6Exp| Autor | Denis Rodrigues       | Data |19/12/2017|||
|||-----------+----------+-------+-----------------------+------+----------|||
||| Descricao | Processa a Extracao da tabela de Ordem Serviço AB6/AB7/AB8 |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   | M010AB6Exp(ExpO01,ExpL01)                                  |||
|||-----------+------------------------------------------------------------|||
||| Parametros|ExpO01 - Objeto do TnewProcess                              |||
|||           |Expl01 - Indica se era gerado pela rotina automatica        |||
|||-----------+------------------------------------------------------------|||
||| Retorno   |                                                            |||
|||-----------+------------------------------------------------------------|||
|============================================================================|
|============================================================================|*/
Static Function M010AB6Exp(oProcess,lAuto)

	Local cAliasT	:= GetNextAlias()
	Local cQuery 	:= ""
	Local cMsg 	   	:= ""
	Local cExtracao	:= DtoC( Date() ) + " - " + Time()
	Local cDtEmiss	:= ""
	Local cData1	:= ""
	Local cData2	:= ""
	Local cData3	:= ""
	Local cData4	:= ""
	Local nCont	   	:= 0
	Local nHandle	:= 0

	If !lAuto		
		oProcess:SaveLog("Inicio da Extração da Tabela de Ordem de Serviço (AB6/AB7/AB8)")
		oProcess:SetRegua1( 0 )	
	Else
		ConOut("Inicio da Extracao da Tabela de Ordem de Serviço (AB6/AB7/AB8) - SCHEDULE")
	EndIf
	
	cQuery := " SELECT AB6.AB6_FILIAL,"
	cQuery += "        AB6.AB6_NUMOS,"
	cQuery += "        AB6.AB6_CODCLI,"
	cQuery += "        AB6.AB6_LOJA,"
	cQuery += "        AB6.AB6_EMISSA,"
	cQuery += "        AB6.AB6_ATEND,"
	cQuery += "        AB6.AB6_STATUS,"
	cQuery += "        AB6.AB6_CONPAG,"
	cQuery += "        AB6.AB6_DESC1,"
	cQuery += "        AB6.AB6_DESC2,"
	cQuery += "        AB6.AB6_DESC3,"
	cQuery += "        AB6.AB6_DESC4,"
	cQuery += "        AB6.AB6_TABELA,"
	cQuery += "        AB6.AB6_PARC1,"
	cQuery += "        AB6.AB6_DATA1,"
	cQuery += "        AB6.AB6_PARC2,"
	cQuery += "        AB6.AB6_DATA2,"
	cQuery += "        AB6.AB6_PARC3,"
	cQuery += "        AB6.AB6_DATA3,"
	cQuery += "        AB6.AB6_PARC4,"
	cQuery += "        AB6.AB6_DATA4,"
	cQuery += "        AB6.AB6_OK,"
	cQuery += "        AB6.AB6_HORA,"
	cQuery += "        AB6.AB6_REGIAO,"
	cQuery += "        AB6.AB6_MSG,"
	cQuery += "        AB6.AB6_MOEDA,"
	cQuery += "        AB6.AB6_TXMOED,"
	cQuery += "        AB6.AB6_NUMLOJ,"
	cQuery += "        AB6.AB6_TPCONT,"
	cQuery += "        AB6.AB6_CONTRT,"
	cQuery += "        AB6.AB6_SITPEC,"
	cQuery += "(SELECT A1_VEND FROM SA1010 where D_E_L_E_T_='' and A1_COD = AB6.AB6_CODCLI and A1_LOJA = AB6.AB6_LOJA) as Vendedor,"
	
	cQuery += "        AB7.AB7_ITEM,"
	cQuery += "        AB7.AB7_TIPO,"
	cQuery += "        AB7.AB7_CODPRO,"
	cQuery += "        AB7.AB7_NUMSER,"
	cQuery += "        AB7.AB7_CODPRB,"
	cQuery += "        AB7.AB7_NRCHAM,"
	cQuery += "        AB7.AB7_NUMORC,"
	cQuery += "        AB7.AB7_CODFAB,"
	cQuery += "        AB7.AB7_LOJAFA,"
	cQuery += "        AB7.AB7_CODCLI,"
	cQuery += "        AB7.AB7_LOJA,"
	cQuery += "        AB7.AB7_EMISSA,"
	cQuery += "        AB7.AB7_NUMHDE,"
	cQuery += "        AB7.AB7_CODCON,"
	cQuery += "        AB7.AB7_TMKLST,"
	
	cQuery += "        AB8.AB8_FILIAL,"
	cQuery += "        AB8.AB8_SUBITE,"
	cQuery += "        AB8.AB8_CODPRO,"
	cQuery += "        AB8.AB8_DESPRO,"
	cQuery += "        AB8.AB8_CODSER,"
	cQuery += "        AB8.AB8_QUANT,"
	cQuery += "        AB8.AB8_VUNIT,"
	cQuery += "        AB8.AB8_TOTAL,"
	cQuery += "        AB8.AB8_ENTREG,"
	cQuery += "        AB8.AB8_DTGAR,"
	cQuery += "        AB8.AB8_NUMPV,"
	cQuery += "        AB8.AB8_PRCLIS,"
	cQuery += "        AB8.AB8_CODPRD,"
	cQuery += "        AB8.AB8_NUMSER,"
	cQuery += "        AB8.AB8_NUMPVF,"
	cQuery += "        AB8.AB8_LOCAL,"
	cQuery += "        AB8.AB8_LOCALI"
	cQuery += " FROM ( " + RetSQLName("AB6") + " AB6 INNER JOIN " + RetSQLName("AB7") + " AB7"
	cQuery += " ON AB6.AB6_FILIAL = AB7.AB7_FILIAL"
	cQuery += " AND AB6.AB6_NUMOS = AB7.AB7_NUMOS)" 
	cQuery += " INNER JOIN " + RetSQLName("AB8")+ " AB8" 
	cQuery += " ON AB7.AB7_FILIAL = AB8.AB8_FILIAL"
	cQuery += " AND AB7.AB7_NUMOS = AB8.AB8_NUMOS"
	cQuery += " AND AB7.AB7_ITEM  = AB8.AB8_ITEM"
	cQuery += " WHERE AB6.D_E_L_E_T_ <>'*'"
	cQuery += "   AND AB7.D_E_L_E_T_ <>'*'"
	cQuery += "   AND AB8.D_E_L_E_T_ <>'*'"
		 
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T. )
	
	If ( cAliasT )->( !Eof() )
	
		nHandle := fCreate("\m010Exporta\ordemservico_ab6ab7ab8.csv", FC_NORMAL)
	
		//Titulo das colunas do arquivo
		FWRITE(	nHandle,"REQUISICAO_KEY"	+ ";" + ;		
					 	"AB6_FILIAL"		+ ";" + ;
						"AB6_NUMOS"			+ ";" + ;
						"AB6_EMISSA"		+ ";" + ;
						"AB6_ATEND"			+ ";" + ;
						"AB6_STATUS"		+ ";" + ;
						"AB6_DESC1"			+ ";" + ;
						"AB6_DESC2"			+ ";" + ;
						"AB6_DESC3"			+ ";" + ;
						"AB6_DESC4"			+ ";" + ;
						"AB6_TABELA"		+ ";" + ;
						"AB6_PARC1"			+ ";" + ;
						"AB6_DATA1"			+ ";" + ;
						"AB6_PARC2"			+ ";" + ;
						"AB6_DATA2"			+ ";" + ;
						"AB6_PARC3"			+ ";" + ;
						"AB6_DATA3"			+ ";" + ;
						"AB6_PARC4"			+ ";" + ;
						"AB6_DATA4"			+ ";" + ;
						"AB6_OK"			+ ";" + ;
						"AB6_HORA"			+ ";" + ;
						"AB6_REGIAO"		+ ";" + ;
						"AB6_MSG"			+ ";" + ;
						"AB6_MOEDA"			+ ";" + ;
						"AB6_TXMOED"		+ ";" + ;
						"AB6_NUMLOJ"		+ ";" + ;
						"AB6_TPCONT"		+ ";" + ;
						"AB6_CONTRT"		+ ";" + ;
						"AB6_SITPEC"		+ ";" + ;						
						"AB7_ITEM"			+ ";" + ;
						"AB7_TIPO"			+ ";" + ;
						"AB7_NUMSER"		+ ";" + ;
						"AB7_CODPRB"		+ ";" + ;
						"AB7_NRCHAM"		+ ";" + ;
						"AB7_NUMORC"		+ ";" + ;
						"AB7_CODFAB"		+ ";" + ;
						"AB7_LOJAFA"		+ ";" + ;
						"AB7_CODCLI"		+ ";" + ;
						"AB7_LOJA"			+ ";" + ;
						"AB7_NUMHDE"		+ ";" + ;
						"AB7_CODCON"		+ ";" + ;
						"AB7_TMKLST"		+ ";" + ;
						"AB8_SUBITE"		+ ";" + ;
						"AB8_CODPRO"		+ ";" + ;
						"AB8_DESPRO"		+ ";" + ;
						"AB8_CODSER"		+ ";" + ;
						"AB8_QUANT"			+ ";" + ;
						"AB8_VUNIT"			+ ";" + ;
						"AB8_TOTAL"			+ ";" + ;
						"AB8_ENTREG"		+ ";" + ;
						"AB8_DTGAR"			+ ";" + ;
						"AB8_NUMPV"			+ ";" + ;
						"AB8_PRCLIS"		+ ";" + ;
						"AB8_CODPRD"		+ ";" + ;
						"AB8_NUMSER"		+ ";" + ;
						"AB8_NUMPVF"		+ ";" + ;
						"AB8_LOCAL"			+ ";" + ;
						"AB8_LOCALI"		+ ";" + ;
						"CLIENTE_KEY"		+ ";" + ;
						"PRODUTO_KEY"		+ ";" + ;
						"EQUIPAMENTO_KEY"	+ ";" + ;
						"CONDPAG_KEY"		+ ";" + ;
						"ARMAZEM_KEY"		+ ";" + ;
						"MOEDA_KEY"			+ ";" + ; 
						"VENDEDOR_KEY"		+ ";" + ;
			       		"DATA_EXTRACAO"		+ CRLF )
		nCont++			       		
	
		While ( cAliasT )->( !Eof() )
		
			If !lAuto
				oProcess:IncRegua1("Extraindo Ordem de Servico..." )
			EndIf

			If Year( StoD( ( cAliasT )->AB6_EMISSA ) ) > 2050
				cDtEmiss := "31/12/2050" 
			Else
				cDtEmiss := If( Empty( ( cAliasT )->AB6_EMISSA ) ,"",AllTrim( DtoC( StoD( ( cAliasT )->AB6_EMISSA ) ) ) )
			EndIf
			
			If Year( StoD( ( cAliasT )->AB6_DATA1 ) ) > 2050
				cData1 := "31/12/2050" 
			Else
				cData1 := If( Empty( ( cAliasT )->AB6_DATA1 ) ,"",AllTrim( DtoC( StoD( ( cAliasT )->AB6_DATA1 ) ) ) )
			EndIf							
			
			If Year( StoD( ( cAliasT )->AB6_DATA2 ) ) > 2050
				cData2 := "31/12/2050" 
			Else
				cData2 := If( Empty( ( cAliasT )->AB6_DATA2 ) ,"",AllTrim( DtoC( StoD( ( cAliasT )->AB6_DATA2 ) ) ) )
			EndIf			

			If Year( StoD( ( cAliasT )->AB6_DATA3 ) ) > 2050
				cData3 := "31/12/2050" 
			Else
				cData3 := If( Empty( ( cAliasT )->AB6_DATA3 ) ,"",AllTrim( DtoC( StoD( ( cAliasT )->AB6_DATA3 ) ) ) )
			EndIf			

			If Year( StoD( ( cAliasT )->AB6_DATA4 ) ) > 2050
				cData4 := "31/12/2050" 
			Else
				cData4 := If( Empty( ( cAliasT )->AB6_DATA4 ) ,"",AllTrim( DtoC( StoD( ( cAliasT )->AB6_DATA4 ) ) ) )
			EndIf			
			  		
			FWRITE(	nHandle,AllTrim( ( cAliasT )->AB6_FILIAL ) + AllTrim( ( cAliasT )->AB6_NUMOS ) + ";" + ;
			       			AllTrim( ( cAliasT )->AB6_FILIAL )			+ ";" + ;			       									       						       			
			       			AllTrim( ( cAliasT )->AB6_NUMOS )			+ ";" + ;
			       			cDtEmiss									+ ";" + ;
			       			AllTrim( ( cAliasT )->AB6_ATEND )			+ ";" + ;
			       			AllTrim( ( cAliasT )->AB6_STATUS )			+ ";" + ;			       			
			       			AllTrim( Str( ( cAliasT )->AB6_DESC1 ) )	+ ";" + ;
			       			AllTrim( Str( ( cAliasT )->AB6_DESC2 ) )	+ ";" + ;
			       			AllTrim( Str( ( cAliasT )->AB6_DESC3 ) )	+ ";" + ;
			       			AllTrim( Str( ( cAliasT )->AB6_DESC4 ) )	+ ";" + ;			       			
			       			AllTrim( ( cAliasT )->AB6_TABELA )			+ ";" + ;			       			
			       			AllTrim( Str( ( cAliasT )->AB6_PARC1 ) )	+ ";" + ;			       						       						       			
			       			cData1										+ ";" + ;
			       			AllTrim( Str( ( cAliasT )->AB6_PARC2 ) )	+ ";" + ;
			       			cData2										+ ";" + ;
			       			AllTrim( Str( ( cAliasT )->AB6_PARC3 ) )	+ ";" + ;
			       			cData3										+ ";" + ;			       			
			       			AllTrim( Str( ( cAliasT )->AB6_PARC4 ) )	+ ";" + ;
			       			cData4										+ ";" + ;			       						       			
			       			AllTrim( ( cAliasT )->AB6_OK )				+ ";" + ;
			       			AllTrim( ( cAliasT )->AB6_HORA )			+ ";" + ;
			       			AllTrim( ( cAliasT )->AB6_REGIAO )			+ ";" + ;
			       			AllTrim( ( cAliasT )->AB6_MSG )				+ ";" + ;
			       			AllTrim( Str( ( cAliasT )->AB6_MOEDA ) )	+ ";" + ;
			       			AllTrim( Str( ( cAliasT )->AB6_TXMOED ) )	+ ";" + ;			       						       						       						       						       			
			       			AllTrim( ( cAliasT )->AB6_NUMLOJ )			+ ";" + ;
			       			AllTrim( ( cAliasT )->AB6_TPCONT )			+ ";" + ;
			       			AllTrim( ( cAliasT )->AB6_CONTRT )			+ ";" + ;
			       			AllTrim( ( cAliasT )->AB6_SITPEC )			+ ";" + ;
			       			AllTrim( ( cAliasT )->AB7_ITEM )			+ ";" + ;
			       			AllTrim( ( cAliasT )->AB7_TIPO )			+ ";" + ;
			       			AllTrim( ( cAliasT )->AB7_NUMSER )			+ ";" + ;			       			
			       			AllTrim( ( cAliasT )->AB7_CODPRB )			+ ";" + ;
			       			AllTrim( xFilial("AB1") ) + AllTrim( ( cAliasT )->AB7_NRCHAM )			+ ";" + ;
			       			AllTrim( ( cAliasT )->AB7_NUMORC )			+ ";" + ;
			       			AllTrim( ( cAliasT )->AB7_CODFAB )			+ ";" + ;
			       			AllTrim( ( cAliasT )->AB7_LOJAFA )			+ ";" + ;
			       			AllTrim( ( cAliasT )->AB7_CODCLI )			+ ";" + ;			       			
			       			AllTrim( ( cAliasT )->AB7_LOJA )			+ ";" + ;
			       			AllTrim( ( cAliasT )->AB7_NUMHDE )			+ ";" + ;			       			
			       			AllTrim( ( cAliasT )->AB7_CODCON )			+ ";" + ;
			       			AllTrim( ( cAliasT )->AB7_TMKLST )			+ ";" + ;			       			
			       			AllTrim( ( cAliasT )->AB8_SUBITE )			+ ";" + ;			       			
			       			AllTrim( ( cAliasT )->AB8_CODPRO )			+ ";" + ;
			       			AllTrim( ( cAliasT )->AB8_DESPRO )			+ ";" + ;
			       			AllTrim( ( cAliasT )->AB8_CODSER )			+ ";" + ;
			       			AllTrim( Str(( cAliasT )->AB8_QUANT))		+ ";" + ;
			       			AllTrim( Str(( cAliasT )->AB8_VUNIT))		+ ";" + ;
			       			AllTrim( Str(( cAliasT )->AB8_TOTAL))		+ ";" + ;
			       			AllTrim( ( cAliasT )->AB8_ENTREG )			+ ";" + ;
			       			AllTrim( ( cAliasT )->AB8_DTGAR )			+ ";" + ;
			       			AllTrim( ( cAliasT )->AB8_NUMPV )			+ ";" + ;			       			
			       			AllTrim( ( cAliasT )->AB8_PRCLIS )			+ ";" + ;
			       			AllTrim( ( cAliasT )->AB8_CODPRD )			+ ";" + ;
			       			AllTrim( ( cAliasT )->AB8_NUMSER )			+ ";" + ;			       			
			       			AllTrim( ( cAliasT )->AB8_NUMPVF )			+ ";" + ;
			       			AllTrim( ( cAliasT )->AB8_LOCAL )			+ ";" + ;
			       			AllTrim( ( cAliasT )->AB8_LOCALI )			+ ";" + ;
			       			AllTrim( xFilial("SA1") ) + AllTrim( ( cAliasT )->AB6_CODCLI ) + AllTrim( ( cAliasT )->AB6_LOJA ) + ";" + ;
			       			AllTrim( xFilial("SB1") ) + AllTrim( ( cAliasT )->AB8_CODPRO ) 						+ ";" + ;
			       			AllTrim( xFilial("SB1") ) + AllTrim( ( cAliasT )->AB7_CODPRO ) 						+ ";" + ;
			       			AllTrim( xFilial("SE4") ) + AllTrim( ( cAliasT )->AB6_CONPAG ) 						+ ";" + ;			       			
			       			AllTrim( ( cAliasT )->AB8_FILIAL ) + AllTrim( AllTrim( ( cAliasT )->AB8_LOCAL ) )	+ ";" + ; 
			       			AllTrim( Str( ( cAliasT )->AB6_MOEDA ) )											+ ";" + ;  
			       			AllTrim( ( cAliasT )->Vendedor  )	   	   											+ ";" + ;
			       			cExtracao + CRLF )
			nCont++
		
			( cAliasT )->( dbSkip() )
			
		EndDo
	
		cMsg += "Registros exportados da Tabela Ordem de Serviço (AB6/AB7/AB8): " + cValToChar( nCont ) + CRLF
		
	EndIf
	
	( cAliasT )->( dbCloseArea() )
	
	fClose( nHandle )
	
	If !lAuto
		oProcess:SaveLog( "Fim da Exportação da Tabela Ordem de Serviço (AB6/AB7/AB8) " )
	EndIf
	
Return( cMsg )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ M010MOEExp ³ Autor ³ Douglas Garcia  ³ Data ³  12/02/2018  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Processa a exportacao da Tabela de Moedas do Sistema       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function M010MOEExp(oProcess,lAuto)

	Local cMsg 		:= ""
	Local cExtracao	:= DtoC( Date() ) + " - " + Time()
	Local nCont		:= 0
	Local nHandle	:= 0 
	Local cMoeda	:= ""

	If !lAuto		
		oProcess:SaveLog("Inicio da Exportacao da Tabela de Moedas")
		oProcess:SetRegua1( 0 )
	Else
		ConOut("Inicio da Exportacao da Tabela de Moedas - SCHEDULE")	
	EndIf
	
	//dbSelectArea("SM0")
	
	nHandle := fCreate("\m010Exporta\moedas.csv", FC_NORMAL)

	//Titulo das colunas do arquivo
	FWRITE(	nHandle, "MOEDA_KEY"			+ ";" + ;
					 "MOEDA" 	   			+ ";" + ;
		       		 "DATA_EXTRACAO"		+ CRLF )
	nCont++
			
	While nCont <= 5
		
		cMoeda := cValToChar(nCont)
		
		If !lAuto
			oProcess:IncRegua1("Exportando Tabela de Moedas..." )
		EndIf
					
		FWRITE(	nHandle, AllTrim( cMoeda )				+ ";" + ;
		       			 AllTrim( GetMv("MV_MOEDA"+cMoeda) )	+ ";" + ;
		       			 cExtracao + CRLF )
		
		nCont++			       		
	
	EndDo
	
	cMsg += "Registros exportados da Tabela de Moedas: " + cValToChar( nCont ) + CRLF
			
	fClose( nHandle )
	
	If !lAuto
		oProcess:SaveLog( "Fim da Exportacao da Tabela de Moedas" )
	EndIf
		
Return( cMsg )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ M010CriaSX1 ³ Autor ³ Denis Rodrigues  ³ Data ³ 12/12/2016  ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cria as perguntas no dicionario                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CriaSX1(cExp1)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cExp1 = Nome da pergunta                                    ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente TOTVS RS                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function M010CriaSX1(cPerg)

	Local aArea		:= GetArea()
	Local aAreaSX1	:= SX1->( GetArea() )
	Local aPergt	:= {}
	Local aHelp		:= {}
	Local nX       	:= 0

	cGrupoPerg := PadR( cPerg, Len(SX1->X1_GRUPO) )
	
    //     Grupo    Ordem Perguntas    			  	  	  	  Variavel  Tipo Tam Dec Variavel   GSC  F3  Def01 Def02 Def03 Def04 Def05 Valid
    aAdd( aPergt, { "01", "Envia para FTP?"		 			, "mv_ch0", "C", 01 , 0 ,"MV_PAR01","C" ," ", "Sim","Nao"," " ," "	," "  ,"" } )
	aAdd( aPergt, { "02", "Endereço do FTP?"				, "mv_ch1", "C", 90 , 0 ,"MV_PAR02","G" ," ",""    ,""   ,""  ,""   ,""   ,"" } )
	aAdd( aPergt, { "03", "Usuario do FTP?"     			, "mv_ch2", "C", 50 , 0 ,"MV_PAR03","G" ," ",""    ,""   ,""  ,""	,""   ,"" } )
	aAdd( aPergt, { "04", "Senha do FTP?"   				, "mv_ch3", "C", 30 , 0 ,"MV_PAR04","G" ," ",""    ,""   ,""  ,"" 	,""   ,"" } )
	aAdd( aPergt, { "05", "Diretorio destino do FTP"		, "mv_ch4", "C", 35 , 0 ,"MV_PAR05","G" ," ",""    ,""   ,""  ,"" 	,""   ,"" } )	
	aAdd( aPergt, { "06", "Exportar Cliente?"		 		, "mv_ch5", "N", 01 , 0 ,"MV_PAR06","C" ," ", "Sim","Nao"," " ," "	," "  ,"" } )
	aAdd( aPergt, { "07", "Exportar Vendedores?"	 		, "mv_ch6", "N", 01 , 0 ,"MV_PAR07","C" ," ", "Sim","Nao"," " ," "	," "  ,"" } )
	aAdd( aPergt, { "08", "Exportar Produtos?"		 		, "mv_ch7", "N", 01 , 0 ,"MV_PAR08","C" ," ", "Sim","Nao"," " ," "	," "  ,"" } )
	aAdd( aPergt, { "09", "Exportar Pedido Venda?"	 		, "mv_ch8", "N", 01 , 0 ,"MV_PAR09","C" ," ", "Sim","Nao"," " ," "	," "  ,"" } )
	aAdd( aPergt, { "10", "Exportar Fornecedor?"	 		, "mv_ch9", "N", 01 , 0 ,"MV_PAR10","C" ," ", "Sim","Nao"," " ," "	," "  ,"" } )
	aAdd( aPergt, { "11", "Exportar CRM?"			 		, "mv_cha", "N", 01 , 0 ,"MV_PAR11","C" ," ", "Sim","Nao"," " ," "	," "  ,"" } )
	aAdd( aPergt, { "12", "Exportar Status Pedido?"	 		, "mv_chb", "N", 01 , 0 ,"MV_PAR12","C" ," ", "Sim","Nao"," " ," "	," "  ,"" } )
	aAdd( aPergt, { "13", "Exportar Faturamento?"	 		, "mv_chc", "N", 01 , 0 ,"MV_PAR13","C" ," ", "Sim","Nao"," " ," "	," "  ,"" } )
	aAdd( aPergt, { "14", "Exportar Contas Receber?" 		, "mv_chd", "N", 01 , 0 ,"MV_PAR14","C" ," ", "Sim","Nao"," " ," "	," "  ,"" } )
	aAdd( aPergt, { "15", "Exportar Contas a Pagar?" 		, "mv_che", "N", 01 , 0 ,"MV_PAR15","C" ," ", "Sim","Nao"," " ," "	," "  ,"" } )
	aAdd( aPergt, { "16", "Exportar Mov.Financeiro?" 		, "mv_chf", "N", 01 , 0 ,"MV_PAR16","C" ," ", "Sim","Nao"," " ," "	," "  ,"" } )
	aAdd( aPergt, { "17", "Exportar Lanc.Contabil?"  		, "mv_chg", "N", 01 , 0 ,"MV_PAR17","C" ," ", "Sim","Nao"," " ," "	," "  ,"" } )
	aAdd( aPergt, { "18", "Exportar Plano de Contas?"		, "mv_chh", "N", 01 , 0 ,"MV_PAR18","C" ," ", "Sim","Nao"," " ," "	," "  ,"" } )
	aAdd( aPergt, { "19", "Exportar Visoes Gerencias?"  	, "mv_chi", "N", 01 , 0 ,"MV_PAR19","C" ," ", "Sim","Nao"," " ," "	," "  ,"" } )
	aAdd( aPergt, { "20", "Exportar Orcamentos?"  			, "mv_chj", "N", 01 , 0 ,"MV_PAR20","C" ," ", "Sim","Nao"," " ," "	," "  ,"" } )	
	aAdd( aPergt, { "21", "Exportar TES?" 		 			, "mv_chk", "N", 01 , 0 ,"MV_PAR21","C" ," ", "Sim","Nao"," " ," "	," "  ,"" } )
	aAdd( aPergt, { "22", "Exportar Centro de Custos?" 		, "mv_chl", "N", 01 , 0 ,"MV_PAR22","C" ," ", "Sim","Nao"," " ," "	," "  ,"" } )
	aAdd( aPergt, { "23", "Exportar Meta de Vendas?" 		, "mv_chm", "N", 01 , 0 ,"MV_PAR23","C" ," ", "Sim","Nao"," " ," "	," "  ,"" } )
	aAdd( aPergt, { "24", "Exportar Tabela de Precos?" 		, "mv_chn", "N", 01 , 0 ,"MV_PAR24","C" ," ", "Sim","Nao"," " ," "	," "  ,"" } )
	aAdd( aPergt, { "25", "Exportar Estabelecimentos?" 		, "mv_cho", "N", 01 , 0 ,"MV_PAR25","C" ," ", "Sim","Nao"," " ," "	," "  ,"" } )
	aAdd( aPergt, { "26", "Exportar Documento Entrada?"		, "mv_chp", "N", 01 , 0 ,"MV_PAR26","C" ," ", "Sim","Nao"," " ," "	," "  ,"" } )
	aAdd( aPergt, { "27", "Exportar Saldo Fisico/Financ?" 	, "mv_chq", "N", 01 , 0 ,"MV_PAR27","C" ," ", "Sim","Nao"," " ," "	," "  ,"" } )
	aAdd( aPergt, { "28", "Exportar Saldo por Lote?" 		, "mv_chr", "N", 01 , 0 ,"MV_PAR28","C" ," ", "Sim","Nao"," " ," "	," "  ,"" } )
	aAdd( aPergt, { "29", "Exportar Poder de Terceiros?" 	, "mv_chs", "N", 01 , 0 ,"MV_PAR29","C" ," ", "Sim","Nao"," " ," "	," "  ,"" } )
	aAdd( aPergt, { "30", "Exportar Tipo de Movimentacao?" 	, "mv_cht", "N", 01 , 0 ,"MV_PAR30","C" ," ", "Sim","Nao"," " ," "	," "  ,"" } )
	aAdd( aPergt, { "31", "Exportar Tabela de Armazens?" 	, "mv_chu", "N", 01 , 0 ,"MV_PAR31","C" ," ", "Sim","Nao"," " ," "	," "  ,"" } )
	aAdd( aPergt, { "32", "Exportar Movimentacoes Internas?", "mv_chv", "N", 01 , 0 ,"MV_PAR32","C" ," ", "Sim","Nao"," " ," "	," "  ,"" } )
	aAdd( aPergt, { "33", "Exportar Pedido de Compra?"		, "mv_chx", "N", 01 , 0 ,"MV_PAR33","C" ," ", "Sim","Nao"," " ," "	," "  ,"" } )
	aAdd( aPergt, { "34", "Exportar Natureza de Operacao?"	, "mv_chy", "N", 01 , 0 ,"MV_PAR34","C" ," ", "Sim","Nao"," " ," "	," "  ,"" } )
	aAdd( aPergt, { "35", "Exportar Gestao de Servicos?"	, "mv_chz", "N", 01 , 0 ,"MV_PAR35","C" ," ", "Sim","Nao"," " ," "	," "  ,"" } )
	aAdd( aPergt, { "36", "Exportar Solicitacao ao Armazem?", "mv_36" , "N", 01 , 0 ,"MV_PAR36","C" ," ", "Sim","Nao"," " ," "	," "  ,"" } )
	aAdd( aPergt, { "37", "Exportar Tabela de Tecnicos?"	, "mv_37" , "N", 01 , 0 ,"MV_PAR37","C" ," ", "Sim","Nao"," " ," "	," "  ,"" } )
	aAdd( aPergt, { "38", "Exportar Chamado Tecnico?"		, "mv_38" , "N", 01 , 0 ,"MV_PAR38","C" ," ", "Sim","Nao"," " ," "	," "  ,"" } )
	aAdd( aPergt, { "39", "Exportar Orcamento Tecnico?"		, "mv_39" , "N", 01 , 0 ,"MV_PAR39","C" ," ", "Sim","Nao"," " ," "	," "  ,"" } )
	aAdd( aPergt, { "40", "Exportar Requisicao de OS?"		, "mv_40" , "N", 01 , 0 ,"MV_PAR40","C" ," ", "Sim","Nao"," " ," "	," "  ,"" } )
	aAdd( aPergt, { "41", "Exportar Ordem de Servico?"		, "mv_41" , "N", 01 , 0 ,"MV_PAR41","C" ," ", "Sim","Nao"," " ," "	," "  ,"" } )
	aAdd( aPergt, { "42", "Exportar Moedas?"				, "mv_42" , "N", 01 , 0 ,"MV_PAR42","C" ," ", "Sim","Nao"," " ," "	," "  ,"" } )
	aAdd( aPergt, { "43", "Exportar Comodatos?"				, "mv_AA" , "N", 01 , 0 ,"MV_PAR43","C" ," ", "Sim","Nao"," " ," "	," "  ,"" } )
	aAdd( aPergt, { "44", "Exportar Fechamento Estoque?"	, "mv_44" , "N", 01 , 0 ,"MV_PAR44","C" ," ", "Sim","Nao"," " ," "	," "  ,"" } )
	aAdd( aPergt, { "45", "Exportar App Inventario?"		, "mv_45" , "N", 01 , 0 ,"MV_PAR45","C" ," ", "Sim","Nao"," " ," "	," "  ,"" } )
	aAdd( aPergt, { "46", "Exportar Matriz Reposicao"		, "mv_46" , "N", 01 , 0 ,"MV_PAR46","C" ," ", "Sim","Nao"," " ," "	," "  ,"" } )
	

	aAdd(aHelp,{"Informe se o arquivo deve ser enviado ", " ao servidor FTP ", "  os campos abaixo devem ser preenchidos" })
	aAdd(aHelp,{"Informar o endereço do ftp sem a porta. ", " Por exemplo:  ", " ftp.totvs.com.br" })
	aAdd(aHelp,{"Informar o login para acesso ao FTP"})
	aAdd(aHelp,{"Informar a senha para acesso ao FTP"})
	aAdd(aHelp,{"Informar o diretorio de destino", " no servidor FTP."})
			
	aAdd(aHelp,{"Informe se deseja ou nao rodar ", " a exportacao da tabela ", " de Clientes (SA1)" })
	aAdd(aHelp,{"Informe se deseja ou nao rodar ", " a exportacao da tabela ", " de Vendedores (SA3)" })
	aAdd(aHelp,{"Informe se deseja ou nao rodar ", " a exportacao da tabela ", " de Produtos (SB1)" })
	aAdd(aHelp,{"Informe se deseja ou nao rodar ", " a exportacao da tabela ", " de Pedidos de Venda (SC5/SC6)" })
	aAdd(aHelp,{"Informe se deseja ou nao rodar ", " a exportacao da tabela ", " de Fornecedor (SA2)" })
/*	aAdd(aHelp,{"Informe se deseja ou nao rodar ", " a exportacao da tabela ", " do CRM (CRM)" })
*/	aAdd(aHelp,{"Informe se deseja ou nao rodar ", " a exportacao do "		 , " Status do Pedido (SC5) " })
	aAdd(aHelp,{"Informe se deseja ou nao rodar ", " a exportacao da tabela ", " de Faturamento (SF2/SD2)" })
/*	aAdd(aHelp,{"Informe se deseja ou nao rodar ", " a exportacao da tabela ", " do Contas a Receber (SE1)" })	
	aAdd(aHelp,{"Informe se deseja ou nao rodar ", " a exportacao da tabela ", " do Contas a Pagar (SE2)" })
	aAdd(aHelp,{"Informe se deseja ou nao rodar ", " a exportacao da tabela ", " de Movimentacao Financeira (SE5)" })	
*/	aAdd(aHelp,{"Informe se deseja ou nao rodar ", " a exportacao da tabela ", " de Lancamentos Contabeis (CT2)" })
	aAdd(aHelp,{"Informe se deseja ou nao rodar ", " a exportacao da tabela ", " de Plano de Contas (CT1)" })
	aAdd(aHelp,{"Informe se deseja ou nao rodar ", " a exportacao da tabela ", " de Visualizacoes Gerenciais (CTS)" })	
	aAdd(aHelp,{"Informe se deseja ou nao rodar ", " a exportacao da tabela ", " de Orcamentos (CV1)." })	
	aAdd(aHelp,{"Informe se deseja ou nao rodar ", " a exportacao da tabela ", " de TES (SF4)." })
	aAdd(aHelp,{"Informe se deseja ou nao rodar ", " a exportacao da tabela ", " de Centro de Custos (CTT)." })
	aAdd(aHelp,{"Informe se deseja ou nao rodar ", " a exportacao da tabela "	, " de Meta de Vendas (SCT)." })
	aAdd(aHelp,{"Informe se deseja ou nao rodar ", " a exportacao da  "		 	, " Tabela de Precos (DA0/DA1)." })
	aAdd(aHelp,{"Informe se deseja ou nao rodar ", " a exportacao da Tabela "	, " de Filiais - Estabelecimentos (SM0)." })	
	aAdd(aHelp,{"Informe se deseja ou nao rodar ", " a exportacao do "		 	, " Documento de Entrada (SF1/SD1)." })
	aAdd(aHelp,{"Informe se deseja ou nao rodar ", " a exportacao da Tabela "	, " de Saldo Fisico e Financeiro (SB2)." })
	aAdd(aHelp,{"Informe se deseja ou nao rodar ", " a exportacao da Tabela "	, " de Saldos por Lote (SB8)." })
	aAdd(aHelp,{"Informe se deseja ou nao rodar ", " a exportacao da Tabela "	, " de Poder de Terceiros (SB6)." })
	aAdd(aHelp,{"Informe se deseja ou nao rodar ", " a exportacao da Tabela "	, " de Tipos de Movimentacao (SF5)." })
	aAdd(aHelp,{"Informe se deseja ou nao rodar ", " a exportacao da Tabela "	, " de Armazens (NNR)." })
	aAdd(aHelp,{"Informe se deseja ou nao rodar ", " a exportacao da Tabela "	, " de Movimentacoes Internas (SD3)." })
	aAdd(aHelp,{"Informe se deseja ou nao rodar ", " a exportacao da Tabela "	, " de Pedidos de Compra (SC7)." })	
	aAdd(aHelp,{"Informe se deseja ou nao rodar ", " a exportacao da Tabela "	, " de Naturezas de Operacao (SED)." })	
	aAdd(aHelp,{"Informe se deseja ou nao rodar ", " a exportacao da Tabela "	, " de Gestão de Servicos (AA3)." })	
	aAdd(aHelp,{"Informe se deseja ou nao rodar ", " a exportacao da Tabela "	, " de Solicitacao ao Armazem (SCP)." })
	aAdd(aHelp,{"Informe se deseja ou nao rodar ", " a exportacao da Tabela "	, " de Tecnicos (AA1)." })
	aAdd(aHelp,{"Informe se deseja ou nao rodar ", " a exportacao da Tabela "	, " de Chamado Tecnico (AB1/AB2)." })
	aAdd(aHelp,{"Informe se deseja ou nao rodar ", " a exportacao da Tabela "	, " de Orcamento Tecnico (AB3/AB4/AB5)." })
	aAdd(aHelp,{"Informe se deseja ou nao rodar ", " a exportacao da Tabela "	, " de Requisicao de OS (ABF/ABG)." })
	aAdd(aHelp,{"Informe se deseja ou nao rodar ", " a exportacao da Tabela "	, " de Ordem de Servico (AB6/AB7/AB8)." })
	aAdd(aHelp,{"Informe se deseja ou nao rodar ", " a exportacao da Tabela "	, " de Moedas." })
	aAdd(aHelp,{"Informe se deseja ou nao rodar ", " a exportacao da Tabela "	, " de Comodatos." })
	aAdd(aHelp,{"Informe se deseja ou nao rodar ", " a exportacao da Tabela "	, " de Fechamento de Estoque." })
	aAdd(aHelp,{"Informe se deseja ou nao rodar ", " a exportacao da Tabela "	, " de App Inventario." })
	aAdd(aHelp,{"Informe se deseja ou nao rodar ", " a exportacao da Tabela "	, " de Matriz Reposicao." })
	
	dbSelectArea("SX1")
	dbSetOrder(1)
	For nX := 1 to Len( aPergt )
		
		If !dbSeek( cGrupoPerg + aPergt[nX][1] )			
			RecLock("SX1",.T.)
				SX1->X1_GRUPO	:= cGrupoPerg 
				SX1->X1_ORDEM	:= aPergt[nX][01]
				SX1->X1_PERGUNT := aPergt[nX][02] 
				SX1->X1_VARIAVL	:= aPergt[nX][03]
				SX1->X1_TIPO	:= aPergt[nX][04] 
				SX1->X1_TAMANHO	:= aPergt[nX][05]
				SX1->X1_DECIMAL	:= aPergt[nX][06] 
				SX1->X1_VAR01	:= aPergt[nX][07]
				SX1->X1_GSC		:= aPergt[nX][08]
				SX1->X1_F3		:= aPergt[nX][09]
				SX1->X1_Def01	:= aPergt[nX][10] 
				SX1->X1_Def02	:= aPergt[nX][11]
				SX1->X1_Def03	:= aPergt[nX][12] 
				SX1->X1_Def04	:= aPergt[nX][13]
				SX1->X1_Def05	:= aPergt[nX][14] 
				SX1->X1_Valid	:= aPergt[nX][15]
			MsUnlock()                       
		EndIf
		
	Next nX
	
	RestArea( aAreaSX1 )
	RestArea( aArea )
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ M010FTP  ³ Autor ³ Denis Rodrigues     ³ Data ³  15/12/2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Envia os arquivos para o servidor FTP                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function M010FTP( oProcess, cNomArq, lAuto )

	Local cRetLog	:= ""
	Local cEndFTP	:= ""
	Local cUserFTP	:= ""
	Local cPassFTP	:= ""
	Local cDirFTP	:= ""	
	Local aFiles	:= {}
	Local aFilZip	:= {}	
	Local aInfo 	:= {}
	Local nRet 		:= 0
 
	If !lAuto
		oProcess:SaveLog("Inicio da compactacao dos arquivos...")
		oProcess:SetRegua1( 0 )
	Else
		ConOut("Inicio da compactacao dos arquivos - SCHEDULE")
	EndIf
	cEndFTP		:= AllTrim( GetMV("ES_ENDFTP") ) + cNomArq	
	If lAuto

		cEndFTP		:= AllTrim( GetMV("ES_ENDFTP") ) + cNomArq
		cUserFTP	:= AllTrim( GetMV("ES_USERFTP") )
		cPassFTP	:= AllTrim( GetMV("ES_PSWFTP") )
		cDirFTP		:= AllTrim( GetMV("ES_DIRFTP") )	
	
	Else

		cEndFTP		:= AllTrim( MV_PAR02 ) + cNomArq
		cUserFTP	:= AllTrim( MV_PAR03 )
		cPassFTP	:= AllTrim( MV_PAR04 )
		cDirFTP		:= AllTrim( MV_PAR05 )	
	
	EndIf

	//+=========================+
	//| COMPACTAR OARQUIVOS     |
	//+=========================+
	aFilZip := Directory("\m010exporta\*.csv", "D")//Pega todos os arquivos de extensao CSV		
	aEval( aFilZip,{|x| aAdd( aFiles, "\m010exporta\" + Lower( x[1] ) ) } )//deixa o nome dos arquivo em minusculo
	tarCompress( aFiles, "\m010exporta\extract.zip" )//Aglutina os arquivos mas NAO COMPACTA
	GzCompress( "\m010exporta\extract.zip", "\m010exporta\extracao.zip" )//Faz a compactacao do arquivo		
	fErase("\m010exporta\extract.zip")//Apaga o arquivo aglutinado
	
		
	//Se o Arquivo existir
	If File( "\m010Exporta\" + cNomArq )
					
		//Tenta se conectar ao servidor ftp na porta 21
		//cEndFTP :="https://secure-di.gooddata.com/project-uploads/cc00xdhd903m377w9le5pcv7h2zidpe8/protheus/" + cNomArq
		cUserFTP := "douglas.garcia@totvs.com.br"
		cPassFTP := "fluig2016"
		 			
		//nRet := WDClient("PUT" , "D:\TOTVS\ERP_PRODUCAO\Protheus12\protheus_data\m010exporta\" + cNomArq , cEndFTP, "", cUserFTP + ":"+ cPassFTP , @aInfo )
		nRet := WDClient("PUT" , "D:\Totvs\Protheus_data\m010Exporta\" + cNomArq , cEndFTP, "", cUserFTP + ":"+ cPassFTP , @aInfo )
		
		If nRet == 0
   			cRetLog += "Upload bem sucedido, verifique no site. Arquivo: " + cNomArq + CRLF
		Else
		
			cRetLog += "- Erro " + cValToChar( nRet ) + " no upload." + CRLF
		   	cRetLog += "- aInfo1 = httpRespCode=" + AllTrim(cValToChar(aInfo[1])) + CRLF
		   	cRetLog += "- aInfo2 = " + AllTrim( cValToChar(aInfo[2])) + CRLF
		   	cRetLog += "- aInfo3 = " + AllTrim(cValToChar(aInfo[3])) + CRLF
		   
		EndIf
		
		ConOut(cRetLog)		
	Else
		cRetLog += "Nao foi possível realizar o envio."
		ConOut(cRetLog)		
	EndIf
	
Return( cRetLog ) 



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ lLibFat  ³ Autor ³ Ednei Silva           ³ Data ³12/04/2018³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna se todas as linhas do pedido estao aguardando      ´±±
±±³faturamento     							                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ lLibFat(cPedido,cFilial)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                              		                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MAHC010                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                          ULTIMAS ALTERACOES                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ Motivo da Alteracao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function lLibFat(cZPed,cZFil)

Local lLibOk:=.T.



cQuery := " SELECT C9_BLCRED,C9_BLEST,C9_BLWMS,C6_NOTA "
cQuery += " FROM " + RetSqlName("SC9") + " SC9 "
cQuery += " INNER JOIN " + RetSqlName("SC6") + " SC6 ON (SC9.C9_PEDIDO=SC6.C6_NUM AND SC9.C9_FILIAL=SC6.C6_FILIAL AND SC6.D_E_L_E_T_<>'*') "
cQuery += " WHERE SC9.C9_PEDIDO = '" + cZPed + "'"
cQuery += "   AND SC9.C9_FILIAL = '" + cZFil + "'"
cQuery += "   AND SC9.D_E_L_E_T_<>'*' "
cQuery := ChangeQuery(cQuery)
MEMOWRITE ("\libFatBI.SQL", cQuery)
dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQuery), "LIBFAT", .F., .T.) // executa query

DbGoTop()
While !Eof()
	
	If	Empty(LIBFAT->C9_BLCRED) .And. Empty(LIBFAT->C9_BLEST) .And. Empty(LIBFAT->C9_BLWMS) .And. Empty(LIBFAT->C6_NOTA) .And. lLibOk
		
		lLibOk:=.T.
	else
		
		lLibOk:=.F.
		
	Endif
	
	DbSkip()
EndDo


dbCloseArea("LIBFAT")
return lLibOk
  
  
Static Function sSldReserv(cZFilial,cZPedido,cZItem,cZProduto)

Local cAliasT	:= GetNextAlias()
Local cQuery 	:= ""
Local nReserv   :=0

cQuery:=" SELECT ISNULL(SUM(C9_QTDLIB),0) C9_QTDLIB "
cQuery+=" FROM " + RetSQLName("SC9") 
cQuery+=" WHERE "
cQuery+=" 	  RTRIM(C9_FILIAL) = '" + AllTrim(cZFilial) + "'"
cQuery+=" AND RTRIM(C9_PEDIDO) = '" + AllTrim(cZPedido) + "'"
cQuery+=" AND RTRIM(C9_ITEM)   = '" + AllTrim(cZITEM)   + "'"
cQuery+=" AND RTRIM(C9_PRODUTO)= '" + AllTrim(cZProduto)+ "'"
cQuery+=" AND D_E_L_E_T_<>'*' "
cQuery+=" AND C9_BLCRED='' "
cQuery+=" AND C9_BLEST=''  "
cQuery+=" AND C9_BLWMS=''  "
//MEMOWRITE ("reservado.SQL", cQuery)
cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T. )
	
nReserv:=( cAliasT )->C9_QTDLIB

 
( cAliasT )->( dbCloseArea() )

Return nReserv

Static Function cVendNF(cF2Fil,cF2Doc,cF2Serie,cF2Cliente,cF2Loja)

Local cAliasF2	:= GetNextAlias()
Local cQuery 	:=""
Local cRetVend  :=""



cQuery:=" SELECT F2_VEND1 " 
cQuery+=" FROM  " + RetSQLName("SF2") 
cQuery+=" WHERE "
cQuery+=" 	  RTRIM(F2_FILIAL)	 ='" + AllTrim(cF2Fil) + "'"
cQuery+=" AND RTRIM(F2_DOC)	     ='" + AllTrim(cF2Doc) + "'" 
cQuery+=" AND RTRIM(F2_SERIE)	 ='" + AllTrim(cF2Serie) + "'"
cQuery+=" AND RTRIM(F2_CLIENTE)  ='" + AllTrim(cF2Cliente) + "'"
cQuery+=" AND RTRIM(F2_LOJA)	 ='" + AllTrim(cF2Loja) + "'"
cQuery+=" AND D_E_L_E_T_ <>'*' "

cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TOPCONN",TcGenQry(,,cQuery),cAliasF2,.F.,.T. )
	
cRetVend:=( cAliasF2 )->F2_VEND1

 
( cAliasF2 )->( dbCloseArea() )

Return cRetVend 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÝÝÝÝÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝËÝÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝËÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝÝÝÝ»±±
±±ºFunction ³zeraZ30     ºAutor  ³Ednei Silva        º Data ³  20/01/19   º±±
±±ÌÝÝÝÝÝÝÝÝÝÝØÝÝÝÝÝÝÝÝÝÝÊÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÊÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¹±±
±±ºDesc.     ³  Zerar a coluna Z30_QTDCOM                                 º±±
±±º          ³                                                            º±±
±±ÌÝÝÝÝÝÝÝÝÝÝØÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¹±±
±±ºUso       ³  atuZ30()                                                  º±±
±±ÈÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


Static Function atuB6BI()
Local nRetReg:=0
Local cQuery :=""
Local cMsg   :=""
Local nRegAdd:=0

cQuery:= " SELECT	B6_FILIAL, "
cQuery+= " B6_DOC,      "
cQuery+= " B6_SERIE,    "
cQuery+= " B6_CLIFOR,   "
cQuery+= " B6_TPCF,     "
cQuery+= " B6_PRODUTO,  "
cQuery+= " B6_QUANT,    "
cQuery+= " B6_PRUNIT,   "
cQuery+= " B6_EMISSAO,  "
cQuery+= " B6_TIPO,     "
cQuery+= " B6_TES,      "
cQuery+= " B6_PODER3,   "
cQuery+= " F4_FINALID,  "
cQuery+= " B6_SALDO,    "
cQuery+= " B1_DESC,     "
cQuery+= " B6_IDENT,    "
cQuery+= " B6_LOJA,     "
cQuery+= " B6_CUSTO1,   "
cQuery+= " B1_GRUPO,    "
cQuery+= " B1_MARCA,    "
cQuery+= " B1_DESCMAR  ,"
cQuery+= " A3_COD,      "
cQuery+= " A3_NOME,     "
cQuery+= " A1_NOME ,    "
cQuery+= " A1_LOJA,     "
cQuery+= " BM_DESC      "

cQuery+= " FROM  SB6010 SB6  INNER JOIN  SD2010 SD2 ON (SD2.D2_DOC=SB6.B6_DOC AND SD2.D2_SERIE=SB6.B6_SERIE AND SD2.D2_CLIENTE=SB6.B6_CLIFOR    AND SD2.D2_LOJA=SB6.B6_LOJA AND SD2.D2_ITEM='01' AND SD2.D_E_L_E_T_<>'*') "
cQuery+= " INNER JOIN  SC5010 SC5 ON (SD2.D2_PEDIDO=SC5.C5_NUM and SD2.D2_FILIAL=SC5.C5_FILIAL AND  SD2.D_E_L_E_T_<>'*')"
cQuery+= " INNER JOIN  SA1010 SA1 ON (SC5.C5_CLIENTE=SA1.A1_COD AND SC5.C5_LOJACLI=SA1.A1_LOJA AND SA1.D_E_L_E_T_<>'*') "
//cQuery+= " INNER JOIN  SA3010 SA3 ON (SA3.A3_COD=SC5.C5_VEND1 AND SA3.D_E_L_E_T_<>'*') " --Davidson 29/11/2022 a pedido do Gabriel Hochmuller
cQuery+= " INNER JOIN  SA3010 SA3 ON (SA3.A3_COD=SC5.C5_VEND1 AND SA3.D_E_L_E_T_<>'*' AND SA3.A3_FILIAL = '01') " //--Davidson 29/11/2022 a pedido do Gabriel Hochmuller
cQuery+= " JOIN  SB1010 SB1 ON (SB6.B6_PRODUTO=SB1.B1_COD AND  SB1.D_E_L_E_T_<>'*') " 
cQuery+= " JOIN  SF4010 SF4 ON (SB6.B6_FILIAL=SF4.F4_FILIAL AND SB6.B6_TES=SF4.F4_CODIGO AND SF4.D_E_L_E_T_<>'*') "
cQuery+= " JOIN  SBM010 SBM ON (SB1.B1_GRUPO=SBM.BM_GRUPO AND SBM.D_E_L_E_T_<>'*') "

cQuery+= " WHERE SB6.B6_DOC >= '' "
cQuery+= " AND SB6.B6_DOC <= 'ZZZZZZZZZ' "
cQuery+= " AND SB6.B6_SERIE   	 >= '' "
cQuery+= " AND SB6.B6_SERIE   	 <= 'ZZZ' "
cQuery+= " AND SB6.B6_EMISSAO 	 >= '20150101' "
cQuery+= " AND SB6.B6_EMISSAO 	 <=  '" + DTOS(dDataBase) + "'"
cQuery+= " AND SB6.B6_PRODUTO 	 >= '' "
cQuery+= " AND SB6.B6_PRODUTO 	 <= 'ZZZZZZZZZZZ' "
cQuery+= " AND SB6.B6_SALDO		 >0 "
cQuery+= " AND SA3.A3_COD         >= '' "
cQuery+= " AND SA3.A3_COD  	     <= 'ZZZZZZ' "
cQuery+= " AND B6_TPCF			  = 'C' "
cQuery+= " AND SB6.B6_TIPO		  = 'E' "
cQuery+= " AND SB6.B6_TES		  IN ('608','683') "
cQuery+= " AND SB6.D_E_L_E_T_	 <> '*' "
cQuery+= " AND SB1.B1_TIPO	 	  = 'M1' "
cQuery+= " AND B6_IDENT NOT IN('145959','145960','145961','145962','145963','145964','145965','145966','145967','145968','145969','145970','145971','145972', "
cQuery+= "		'151272','294963','294964','296555','315049','321881','327462','327463','327464','327465','301562','145959','145960', "
cQuery+= "     '145961','145962','145963','145964','145965','145966','145967','145968','145969','145970','145971','145972','151272', "
cQuery+= "     '294963','294964','296555','315049','321881','327462','327463','327464','327465','301562') "
	
cQuery+= " Order By SB6.B6_DOC, SB6.B6_SERIE, SB6.B6_EMISSAO "



//MEMOWRITE("EMTERCEIROSXLS.SQL",cQuery)

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry( ,, cQuery ),"TSB6",.F.,.T.)
TCSETFIELD( "TSB6","DB_DATA","D")


nRetReg:=0
cMsg   :=''
dbGoTop()
zeraZ30()
While !TSB6->(Eof())
	
	nRetReg:=atuZ30(TSB6->B6_CLIFOR, TSB6->B6_LOJA, TSB6->B6_SALDO,TSB6->B1_GRUPO)
	If nRetReg=0
		nRegAdd++
		DbSelectArea("Z30")
		reclock("Z30",.T.)
		//--------------------------
		
		//cMsg += '[ITEM - '      +cValToChar(nRegAdd)			  +']; '
	    //cMsg += '[ NF/SERIE'    + TSB6->B6_DOC +'/'+ TSB6->B6_DOC +']; '  
		//cMsg += '[ Z30->CODGRU' + TSB6->B1_GRUPO 				  +']; '
		//cMsg += '[ Z30_DESCRI ' + TSB6->BM_DESC  				  +']; '
		//cMsg += '[ Z30_CODCLI ' + TSB6->B6_CLIFOR				  +']; '
		//cMsg += '[ Z30_LOJA   ' + TSB6->A1_LOJA					  +']; '
		//cMsg += '[ Z30_NOME   ' + TSB6->A1_NOME					  +']; '
		//cMsg += '[ Z30_QUANT  ' + '0'							  +']; '
		//cMsg += '[ Z30_MARCA  ' + TSB6->B1_MARCA				  +']; '
		//cMsg += '[ Z30_DESMAR ' + TSB6->B1_DESCMAR				  +']; '
		//cMsg += '[ Z30_VALOR  ' + '0'							  +']; '
		//cMsg += '[ Z30_DTINIC ' + str(YEAR(ddatabase))+'0101'	  +']; '
		//cMsg += '[ Z30_QTDCOM ' + '0'							  +']; '
		//cMsg += '[ Z30_PRVCOM ' + cValToChar(TSB6->B6_SALDO)	  +']; '+ CRLF
		
		
		
		//Z30->Z30_FILIAL :=TSB6->B6_FILIAL
		Z30->Z30_CODCLI :=TSB6->B6_CLIFOR
		Z30->Z30_LOJA   :=TSB6->A1_LOJA
		Z30->Z30_DTINIC :=StoD(Year2Str(ddatabase)+'0101')
		Z30->Z30_DTFIM  :=StoD(Year2Str(ddatabase)+'1231')
		Z30->Z30_CODGRU :=TSB6->B1_GRUPO
		Z30->Z30_DESCRI :=TSB6->BM_DESC
		Z30->Z30_NOME   :=TSB6->A1_NOME
		Z30->Z30_QUANT  :=0
		Z30->Z30_MARCA  :=TSB6->B1_MARCA
		Z30->Z30_DESMAR :=TSB6->B1_DESCMAR
		Z30->Z30_VALOR  :=0
		//Z30->Z30_QTDCOM :='0'
		Z30->Z30_PRVCOM :=TSB6->B6_SALDO
		//--------------------------
		MsUnLock()
				
	endif
	TSB6->(dbSkip())
	
Enddo

//MEMOWRITE("LogComodato_"+dToS(ddatabase)+".TXT",cMsg)
//Alert('Atualizacao concluida. Forma incluidos mais: '+cValToChar(nRegAdd))
dbCloseArea("Z30")	    
dbCloseArea("TSB6")
return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÝÝÝÝÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝËÝÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝËÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝÝÝÝ»±±
±±ºFunction ³zeraZ30     ºAutor  ³Ednei Silva        º Data ³  20/01/19   º±±
±±ÌÝÝÝÝÝÝÝÝÝÝØÝÝÝÝÝÝÝÝÝÝÊÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÊÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¹±±
±±ºDesc.     ³  Zerar a coluna Z30_QTDCOM                                 º±±
±±º          ³                                                            º±±
±±ÌÝÝÝÝÝÝÝÝÝÝØÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¹±±
±±ºUso       ³  atuZ30()                                                  º±±
±±ÈÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

static function zeraZ30()

//Local cArea01 := Alias()

cQureryAZ30:=""
cQureryAZ30+=" UPDATE Z30010 SET Z30_PRVCOM=0"
cQureryAZ30+=" WHERE D_E_L_E_T_ <> '*' "

nRet:=TcSqlExec(cQureryAZ30)
If nRet<>0
	Alert(TCSQLERROR())
Endif

//dbCloseArea(cArea01)

return




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÝÝÝÝÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝËÝÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝËÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝÝÝÝ»±±
±±ºFunction ³atuZ30      ºAutor  ³Ednei Silva        º Data ³  20/01/19   º±±
±±ÌÝÝÝÝÝÝÝÝÝÝØÝÝÝÝÝÝÝÝÝÝÊÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÊÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¹±±
±±ºDesc.     ³  Atualizr a coluna Z30_QTDCOM                              º±±
±±º          ³                                                            º±±
±±ÌÝÝÝÝÝÝÝÝÝÝØÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¹±±
±±ºUso       ³  atuZ30()                                                  º±±
±±ÈÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


Static Function atuZ30(cCliente, cLoja, nB6SLD, cGrupo)

//Local cArea02 := Alias()
Local nRegZ30 :=0

cQuery03:=""
cQuery03:=" SELECT * FROM Z30010 "
cQuery03+=" WHERE "
cQuery03+=" Z30_CODCLI 		= '"+cCliente+"'"
cQuery03+=" AND Z30_LOJA 	= '"+cLoja+"'"
cQuery03+=" AND Z30_CODGRU  = '"+cGrupo+"'"
cQuery03+=" AND D_E_L_E_T_  <> '*' "

MEMOWRITE("atuZ30_Query03.SQL",cQuery03)
cQuery03 := ChangeQuery(cQuery03)
dbUseArea(.T.,"TOPCONN",TcGenQry( ,, cQuery03 ),"TZ30",.F.,.T.)


While !TZ30->(Eof())
	
	nRegZ30++
	TZ30->(dbSkip())	
Enddo                        

dbCloseArea("TZ30")
dbSelectArea("TSB6")

cQureryUZ30:=""
cQureryUZ30+=" UPDATE Z30010 SET Z30_PRVCOM=Z30_PRVCOM+"+cValToChar(nB6SLD)
cQureryUZ30+=" WHERE "
cQureryUZ30+=" Z30_CODCLI	= '"+cCliente+"'"
cQureryUZ30+=" AND Z30_LOJA = '"+cLoja+"'"
cQureryUZ30+=" AND Z30_CODGRU = '"+cGrupo+"'"
cQureryUZ30+=" AND D_E_L_E_T_ <> '*' "

nRet:=TcSqlExec(cQureryUZ30)
If nRet<>0
	Alert(TCSQLERROR())
Endif




//dbCloseArea(cArea02)


return nRegZ30


Static Function aSldCli()
Local cQueryX :=""
Local nRet:= 0

cQueryX := " UPDATE SA1010  SET A1_SALPEDL= "
cQueryX += " ISNULL((SELECT   "
cQueryX += " ISNULL(SUM(C9_QTDLIB * C9_PRCVEN),0)  "
cQueryX += " FROM SC5010 SC5  "
cQueryX += " INNER JOIN       SC6010 SC6 ON C6_FILIAL = C5_FILIAL AND C6_NUM = C5_NUM  "
cQueryX += " LEFT  OUTER JOIN SC9010 SC9 ON C9_FILIAL = C6_FILIAL AND C9_PEDIDO = C6_NUM AND C9_ITEM = C6_ITEM AND SC9.D_E_L_E_T_ = ' '  " 
cQueryX += " INNER JOIN       SA1010 SA1 ON A1_COD = C5_CLIENTE AND A1_LOJA = C5_LOJACLI  " 
cQueryX += " INNER JOIN       SB1010 SB1 ON B1_COD = C6_PRODUTO " 
cQueryX += " INNER JOIN       SF4010 SF4 ON F4_FILIAL = C6_FILIAL AND F4_CODIGO = C6_TES and (F4_DUPLIC='S' or F4_CODIGO IN('697','722')) "
cQueryX += " WHERE  C5_FILIAL <> '0707' " 
cQueryX += " AND C5_NUM     BETWEEN ('      ') AND ('zzz   ') " 
cQueryX += " AND C5_CLIENTE = SA1010.A1_COD "
cQueryX += " AND C5_LOJACLI = SA1010.A1_LOJA "
cQueryX += " AND C9_NFISCAL='' "
cQueryX += " AND SC5.D_E_L_E_T_ = ' ' " 
cQueryX += " AND SC6.D_E_L_E_T_ = ' ' " 
cQueryX += " AND SA1.D_E_L_E_T_ = ' ' " 
cQueryX += " AND SB1.D_E_L_E_T_ = ' ' " 
cQueryX += " AND SF4.D_E_L_E_T_ = ' ' "
cQueryX += " AND SA1.R_E_C_N_O_=SA1010.R_E_C_N_O_ "
cQueryX += " GROUP BY A1_COD,A1_LOJA),0) "

nRet:=TcSqlExec(cQueryX)
If nRet<>0
	Alert(TCSQLERROR())
Endif


return 

                                         
