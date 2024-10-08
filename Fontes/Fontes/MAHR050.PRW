#INCLUDE "FATR050.ch"
#INCLUDE "FATR050.CH"
#include "Protheus.ch"
#DEFINE CHRCOMP If(aReturn[4]==1,15,18)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � FATR050  � Autor � Marco Bianchi         � Data �25/05/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relatorio de metas de vendas x realizado                   ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function MAHR050()

Local oReport

If FindFunction("TRepInUse") .And. TRepInUse()
	//-- Interface de impressao
	oReport := ReportDef()
	oReport:PrintDialog()
Else
	FATR050R3()
EndIf

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor � Marco Bianchi         � Data �25/05/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpO1: Objeto do relat�rio                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()

Local oReport
Local cAliasQry := GetNextAlias()

Private nValReal := 0					// Valor Real
Private nQtdReal := 0					// Quantidade Real
Private nValMeta := 0					// Valor da Meta
Private aVendas  := { 0, 0, 0 } 		
Private aDevol   := { 0, 0, 0 }   

	
//������������������������������������������������������������������������Ŀ
//�Criacao do componente de impressao                                      �
//�                                                                        �
//�TReport():New                                                           �
//�ExpC1 : Nome do relatorio                                               �
//�ExpC2 : Titulo                                                          �
//�ExpC3 : Pergunte                                                        �
//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
//�ExpC5 : Descricao                                                       �
//�                                                                        �
//��������������������������������������������������������������������������
oReport := TReport():New("FATR050",STR0007,"FTR050P9R1", {|oReport| ReportPrint(oReport,cAliasQry)},STR0008+ " " + STR0009)
oReport:SetLandscape() 
oReport:SetTotalInLine(.F.)

Pergunte(oReport:uParam,.F.)
//������������������������������������������������������������������������Ŀ
//�Criacao da secao utilizada pelo relatorio                               �
//�                                                                        �
//�TRSection():New                                                         �
//�ExpO1 : Objeto TReport que a secao pertence                             �
//�ExpC2 : Descricao da se�ao                                              �
//�ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   �
//�        sera considerada como principal para a se��o.                   �
//�ExpA4 : Array com as Ordens do relat�rio                                �
//�ExpL5 : Carrega campos do SX3 como celulas                              �
//�        Default : False                                                 �
//�ExpL6 : Carrega ordens do Sindex                                        �
//�        Default : False                                                 �
//�                                                                        �
//��������������������������������������������������������������������������
//������������������������������������������������������������������������Ŀ
//�Criacao da celulas da secao do relatorio                                �
//�                                                                        �
//�TRCell():New                                                            �
//�ExpO1 : Objeto TSection que a secao pertence                            �
//�ExpC2 : Nome da celula do relat�rio. O SX3 ser� consultado              �
//�ExpC3 : Nome da tabela de referencia da celula                          �
//�ExpC4 : Titulo da celula                                                �
//�        Default : X3Titulo()                                            �
//�ExpC5 : Picture                                                         �
//�        Default : X3_PICTURE                                            �
//�ExpC6 : Tamanho                                                         �
//�        Default : X3_TAMANHO                                            �
//�ExpL7 : Informe se o tamanho esta em pixel                              �
//�        Default : False                                                 �
//�ExpB8 : Bloco de c�digo para impressao.                                 �
//�        Default : ExpC2                                                 �
//�                                                                        �
//��������������������������������������������������������������������������
oMetas := TRSection():New(oReport,STR0020,{"SCT"},/*{Array com as ordens do relat�rio}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oMetas:SetTotalInLine(.F.)

TRCell():New(oMetas,"CT_DOC"    ,"SCT",STR0019   ,/*Picture*/			  			,TamSX3("CT_DOC")		[1],/*lPixel*/,/*{|| code-block de impressao }*/)						// Codigo da Meta
TRCell():New(oMetas,"CT_SEQUEN" ,"SCT",STR0012   ,/*Picture*/			  			,TamSX3("CT_SEQUEN")	[1],/*lPixel*/,/*{|| code-block de impressao }*/)						// Sequencia da Meta
TRCell():New(oMetas,"CT_DESCRI" ,"SCT",STR0011   ,/*Picture*/			  			,TamSX3("CT_DESCRI")	[1],/*lPixel*/,/*{|| code-block de impressao }*/)						// Descricao da Meta
TRCell():New(oMetas,"CT_DATA"   ,"SCT",/*Titulo*/,/*Picture*/			  			,TamSX3("CT_DATA")	[1],/*lPixel*/,/*{|| code-block de impressao }*/)						// Data da Meta
TRCell():New(oMetas,"CT_VEND"   ,"SCT",/*Titulo*/,/*Picture*/			  			,TamSX3("CT_VEND")	[1],/*lPixel*/,/*{|| code-block de impressao }*/)						// Codigo do Vendedor
TRCell():New(oMetas,"CT_REGIAO" ,"SCT",/*Titulo*/,/*Picture*/			  			,TamSX3("CT_REGIAO")	[1],/*lPixel*/,/*{|| code-block de impressao }*/)						// Regiao
TRCell():New(oMetas,"CT_PRODUTO","SCT",/*Titulo*/,/*Picture*/			  			,TamSX3("CT_PRODUTO")[1],/*lPixel*/,/*{|| code-block de impressao }*/)						// Codigo do Produto
TRCell():New(oMetas,"CT_GRUPO"  ,"SCT",/*Titulo*/,/*Picture*/			  			,TamSX3("CT_GRUPO")	[1],/*lPixel*/,/*{|| code-block de impressao }*/)						// Grupo do Produto
TRCell():New(oMetas,"CT_TIPO"   ,"SCT",STR0013   ,/*Picture*/			  			,TamSX3("CT_TIPO")	[1],/*lPixel*/,/*{|| code-block de impressao }*/)						// Tipo do Produto
TRCell():New(oMetas,"NVALMETA"  ,"   ",STR0010   ,PesqPict("SCT","CT_VALOR")	,TamSX3("CT_VALOR")	[1],/*lPixel*/,{|| xMoeda( CT_VALOR, CT_MOEDA, MV_PAR10, CT_DATA ) },,,"RIGHT")	// Valor da Meta
TRCell():New(oMetas,"CT_QUANT"  ,"SCT",STR0018   ,PesqPict("SCT","CT_QUANT")	,TamSX3("CT_QUANT")	[1],/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")						// Quantidade da Meta
TRCell():New(oMetas,"NVALREAL"  ,"   ",STR0014   ,PesqPict("SCT","CT_VALOR")	,TamSX3("CT_VALOR")	[1],/*lPixel*/,{|| nValReal },,,"RIGHT")			        						// Valor Real
TRCell():New(oMetas,"NQTDREAL"  ,"   ",STR0015   ,PesqPict("SCT","CT_QUANT") ,TamSX3("CT_QUANT")	[1],/*lPixel*/,{|| nQtdReal },,,"RIGHT")											// Quantidade Real
TRCell():New(oMetas,"nVRMM"     ,"   ",STR0016   ,PesqPict("SCT","CT_VALOR")	,TamSX3("CT_VALOR")	[1],/*lPixel*/,{|| nValReal - nValMeta },,,"RIGHT")								// Valor Real - Meta
TRCell():New(oMetas,"nQRMM"     ,"   ",STR0017   ,PesqPict("SCT","CT_QUANT")	,TamSX3("CT_QUANT")	[1],/*lPixel*/,{|| nQtdReal - CT_QUANT },,,"RIGHT")								// Quantidade Real - Meta

Return(oReport)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrin� Autor �Eduardo Riera          � Data �04.05.2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpO1: Objeto Report do Relat�rio                           ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportPrint(oReport,cAliasQry)

Local cEstoq 	:= If( (mv_par12 == 1),"'S'",If( (mv_par12 == 2),"'N'","'S','N'" ) )
Local cDupli 	:= If( (mv_par11 == 1),"'S'",If( (mv_par11 == 2),"'N'","'S','N'" ) )

#IFNDEF TOP
	Local cCondicao := ""
#ENDIF

//������������������������������������������������������������������������Ŀ
//�Filtragem do relat�rio                                                  �
//��������������������������������������������������������������������������
#IFDEF TOP
	
	//������������������������������������������������������������������������Ŀ
	//�Transforma parametros Range em expressao SQL                            �
	//��������������������������������������������������������������������������
	MakeSqlExpr(oReport:uParam)

	//������������������������������������������������������������������������Ŀ
	//�Query do relat�rio da secao 1                                           �
	//��������������������������������������������������������������������������
	oReport:Section(1):BeginQuery()	
		
	BeginSql Alias cAliasQry
    SELECT SCT.* 
		FROM %table:SCT% SCT
		WHERE CT_FILIAL = %xFilial:SCT% AND  
		CT_REGIAO >= %Exp:MV_PAR03% AND 
		CT_REGIAO <= %Exp:MV_PAR04% AND 		
		CT_DATA   >= %Exp:DToS(MV_PAR08)% AND 
		CT_DATA   <= %Exp:DToS(MV_PAR09)% AND 	
		SCT.%notdel% 
	EndSql 
	//������������������������������������������������������������������������Ŀ
	//�Metodo EndQuery ( Classe TRSection )                                    �
	//�                                                                        �
	//�Prepara o relat�rio para executar o Embedded SQL.                       �
	//�                                                                        �
	//�ExpA1 : Array com os parametros do tipo Range                           �
	//�                                                                        �
	//��������������������������������������������������������������������������
	oReport:Section(1):EndQuery({MV_PAR05,MV_PAR06})
		
#ELSE
    cAliasQry := "SCT"

	//����������������������������������������������������������������������������������������������������Ŀ
	//�Utilizar a funcao MakeAdvlExpr, somente quando for utilizar o range de parametros para ambiente CDX �
	//������������������������������������������������������������������������������������������������������
	MakeAdvplExpr("FTR050P9R1") 

	//���������������������������������������������������������������������Ŀ
	//� Logica para ISAM                                                    �
	//�����������������������������������������������������������������������
	dbSelectArea("SCT")
	dbSetOrder(2)
	cCondicao += "CT_FILIAL='"      +xFilial("SCT")+"'.AND."
	
    // Regiao
	cCondicao += "CT_REGIAO>='"     + MV_PAR03+"'.AND."
	cCondicao += "CT_REGIAO<='"     + MV_PAR04+"'.AND."	

    // Tipo de produto
	If !Empty(mv_par05)
		cCondicao += +MV_PAR05+" .AND."
	EndIf	           

	// Grupo de produto
	If !Empty(mv_par06)
		cCondicao += +MV_PAR06+" .AND."
	EndIf	          

	cCondicao += "DTOS(CT_DATA)>='" +DToS(MV_PAR08)+"'.AND."
	cCondicao += "DTOS(CT_DATA)<='" +DToS(MV_PAR09)+"'
		
	oReport:Section(1):SetFilter(cCondicao,SCT->(IndexKey()))
	
#ENDIF		
//������������������������������������������������������������������������Ŀ
//�Metodo TrPosition()                                                     �
//�                                                                        �
//�Posiciona em um registro de uma outra tabela. O posicionamento ser�     �
//�realizado antes da impressao de cada linha do relat�rio.                �
//�                                                                        �
//�                                                                        �
//�ExpO1 : Objeto Report da Secao                                          �
//�ExpC2 : Alias da Tabela                                                 �
//�ExpX3 : Ordem ou NickName de pesquisa                                   �
//�ExpX4 : String ou Bloco de c�digo para pesquisa. A string ser� macroexe-�
//�        cutada.                                                         �
//�                                                                        �				
//��������������������������������������������������������������������������

//������������������������������������������������������������������������Ŀ
//�Inicio da impressao do fluxo do relat�rio                               �
//��������������������������������������������������������������������������
oReport:SetMeter(SCT->(LastRec()))


dbSelectArea(cAliasQry)
dbGoTop()
oReport:Section(1):Init()
While !oReport:Cancel() .And. !(cAliasQry)->(Eof())

	//��������������������������������������������������������������Ŀ
	//� Chama a funcao de calculo das vendas                         �
	//����������������������������������������������������������������
	aVendas := FtNfVendas(4,(cAliasQry)->CT_VEND,MV_PAR01,MV_PAR02,(cAliasQry)->CT_REGIAO,(cAliasQry)->CT_TIPO,(cAliasQry)->CT_GRUPO,(cAliasQry)->CT_PRODUTO,MV_PAR10,"","","",,cDupli,cEstoq)
	
	aDevol := { 0,0,0 }
	If MV_PAR07 == 1  	
		//��������������������������������������������������������������Ŀ
		//� Chama a funcao de calculo das devolucoes de venda            �
		//����������������������������������������������������������������
		aDevol := FtNfDevol(4,(cAliasQry)->CT_VEND,MV_PAR01,MV_PAR02,(cAliasQry)->CT_REGIAO,(cAliasQry)->CT_TIPO,(cAliasQry)->CT_GRUPO,(cAliasQry)->CT_PRODUTO,MV_PAR10,"","",,cDupli,cEstoq)
	EndIf 			
 	nValReal := aVendas[ 1 ] - aDevol[ 1 ]
 	nQtdReal := aVendas[ 2 ] - aDevol[ 2 ]
	nValMeta := xMoeda( ( cAliasQry )->CT_VALOR, ( cAliasQry )->CT_MOEDA, MV_PAR10, ( cAliasQry )->CT_DATA ) 

	oReport:Section(1):PrintLine()
	
	
	dbSelectArea(cAliasQry)
	dbSkip()
	oReport:IncMeter()
EndDo
oReport:Section(1):Finish()
oReport:Section(1):SetPageBreak(.T.) 


Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � FATR050R3� Autor � Sergio Silveira       � Data �09/09/2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relatorio de metas de vendas x realizado                   ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function FATR050R3()
//������������������������������������������������������������������������Ŀ
//�Define Vari�veis                                                        �
//��������������������������������������������������������������������������
Local Titulo  := OemToAnsi(STR0001)  //"Relacao de metas de vendas x vendas realizadas"
Local cDesc1  := OemToAnsi(STR0002) //"Este relatorio ira imprimir a relacao das metas de vendas"
Local cDesc2  := OemToAnsi(STR0003) //"em relacao as vendas realizadas conforme parametros"
Local cDesc3  := OemToAnsi("") 

Local cString    := "SCT"  // Alias utilizado na Filtragem
Local lDic       := .F.    // Habilita/Desabilita Dicionario
Local lComp      := .T.    // Habilita/Desabilita o Formato Comprimido/Expandido
Local lFiltro    := .T.    // Habilita/Desabilita o Filtro
Local wnrel      := "FATR050"  // Nome do Arquivo utilizado no Spool
Local nomeprog   := "FATR050"  // nome do programa
Local aOrderKey  := {} 

Private Tamanho  := "G"  // P/M/G
Private Limite   := 220  // 80/132/220
Private cPerg    := "FTR050"  // Pergunta do Relatorio
Private aReturn  := { STR0004, 1, STR0005, 1, 2, 1, "",1 }   //"Zebrado"###"Administracao"
						//[1] Reservado para Formulario
						//[2] Reservado para N� de Vias
						//[3] Destinatario
						//[4] Formato => 1-Comprimido 2-Normal
						//[5] Midia   => 1-Disco 2-Impressora
						//[6] Porta ou Arquivo 1-LPT1... 4-COM1...
						//[7] Expressao do Filtro
						//[8] Ordem a ser selecionada
						//[9]..[10]..[n] Campos a Processar (se houver)

Private lEnd     := .F.// Controle de cancelamento do relatorio
Private m_pag    := 1  // Contador de Paginas
Private nLastKey := 0  // Controla o cancelamento da SetPrint e SetDefault

//������������������������������������������������������������������������Ŀ
//�Verifica as Perguntas Seleciondas                                       �
//��������������������������������������������������������������������������

Pergunte(cPerg,.F.)

//������������������������������������������������������������������������Ŀ
//�Envia para a SetPrinter                                                 �
//��������������������������������������������������������������������������

wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,lDic,,lComp,Tamanho,lFiltro)
If ( nLastKey==27 )
	dbSelectArea(cString)
	dbSetOrder(1)
	Set Filter to
	Return
Endif
SetDefault(aReturn,cString)
If ( nLastKey==27 )
	dbSelectArea(cString)
	dbSetOrder(1)
	Set Filter to
	Return
Endif

RptStatus({|lEnd| ImpDet(@lEnd,wnRel,cString,nomeprog,Titulo)},Titulo)

Return(.T.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Program   � ImpDet   � Autor � Sergio Silveira       � Data �09/09/2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Controle de Fluxo do Relatorio.                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function ImpDet(lEnd,wnrel,cString,nomeprog,Titulo)

Local aRegAD6     := {} 
Local aVendas     := { 0, 0, 0 } 
Local aDevol      := { 0, 0, 0 } 

Local bCondFil    := { || .T. }    
Local bWhile      := { || .T. } 
Local bBlock      := { || .T. } 

Local cCabec1     := STR0006 //"NUMERO  SEQ  DESCRICAO                       DATA        VENDEDOR  REGIAO  PRODUTO          GRUPO  TIPO          VALOR/META      QUANT/META          VALOR/REAL      QUANT/REAL     DIFERENCA VALOR   DIFERENCA QTD"
Local cCabec2     := ""

Local cTit1       := ""        // Titulo da 1.o Quebra recebe o valor de um campo
Local cTit2       := ""        // Titulo da 2.o Quebra recebe o valor de um campo
Local cTitulo1    := ""        // Titulo descritivo em formato texto
Local cTitulo2    := ""        // Titulo descritivo em formato texto
Local cbCont      := 0         // Numero de Registros Processados
Local cbText      := ""        // Mensagem do Rodape
Local cAliasSCT   := ""
Local cIndSCT     := ""
Local cQuery      := ""
Local cCond       := ""
Local cKey        := ""
Local cBlockFil   := "" 
Local cArqInd     := "" 

Local lImp        := .F.       // Indica se algo foi impresso
Local lQuery      := .F.
Local cEstoq 		:= If( (mv_par14 == 1),"'S'",If( (mv_par14 == 2),"'N'","'S','N'" ) )
Local cDupli 		:= If( (mv_par13 == 1),"'S'",If( (mv_par13 == 2),"'N'","'S','N'" ) )

//������������������������������������������������������������������������Ŀ
//� VARIAVEIS DE COLUNAS                                                   �
//� As variaveis abaixo nCol???, guardam valores das colunas que ser�o     �
//� usadas na impressao, pois como tem 4 formas de quebra, a cada forma de �
//� um cabecalho diferente as colunas ir�o mudar.                          �
//��������������������������������������������������������������������������
Local nOrdem      := aReturn[ 8 ] 
Local nLoop       := 0
Local nValor      := 0 
Local nValorQueb  := 0 
Local nValorTot   := 0 
Local nValReal    := 0 
Local nValMeta    := 0 
Local nQtdReal    := 0 

//����������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                     �
//�                                                          �
//� mv_par01            // Dt. emissao de ?                  �
//� mv_par02            // Dt. emissao ate ?                 �
//� mv_par03            // Regiao de ?                       �
//� mv_par04            // Regiao ate ?                      �
//� mv_par05            // Tipo de ?                         �
//� mv_par06            // Tipo ate ?                        �
//� mv_par07            // Grupo de ?                        �
//� mv_par08            // Grupo ate ?                       �
//� mv_par09            // Considera devolucao Sim/Nao       �
//� mv_par10            // Dt. emissao de ?                  �
//� mv_par11            // Dt. emissao ate ?                 �
//� mv_par12            // Moeda ?                           �
//������������������������������������������������������������

Li := 100 

dbSelectArea(cString)
SetRegua(LastRec())
dbSetOrder(1)
dbSeek(xFilial())

//���������������������������������������������������������������������Ŀ
//� Imprime o relatorio                                                 �
//�����������������������������������������������������������������������

//���������������������������������������������������������������������Ŀ
//� Cria o code-block de filtro do usuario                              �
//�����������������������������������������������������������������������   

If !Empty( aReturn[7] ) 
	cBlockFil := "{ || " + aReturn[ 7 ] + " }"
	bCondFil  := &cBlockFil 
EndIf 	

AD5->( dbSetOrder( 1 ) ) 
cKey := AD5->( IndexKey() ) 

//��������������������������������������������������������������Ŀ
//� Selecao dos registros validos para o processamento           �
//����������������������������������������������������������������
#IFDEF TOP                 

	//���������������������������������������������������������������������Ŀ
	//� Logica para SQL                                                     �
	//�����������������������������������������������������������������������
	cAliasSCT := GetNextAlias()

	aStruSCT := SCT->( dbStruct() ) 

	lQuery := .T.                      
    
	If Empty( aReturn[ 7 ] ) 
		cQuery := "SELECT CT_DOC,CT_SEQUEN,CT_TIPO,CT_GRUPO,CT_PRODUTO,CT_VEND,CT_REGIAO,CT_MOEDA,CT_DESCRI,CT_DATA,CT_VALOR,CT_QUANT "
	Else	
		cQuery := "SELECT * "
	EndIf 
		
	cQuery += "FROM "
	cQuery += RetSQLName("SCT")+" SCT "
	cQuery += "WHERE CT_FILIAL='"+xFilial("SCT")+"' AND "
	cQuery += "CT_REGIAO>='"+MV_PAR03+"' AND "
	cQuery += "CT_REGIAO<='"+MV_PAR04+"' AND "	
	cQuery += "CT_TIPO>='"  +MV_PAR05+"' AND "
	cQuery += "CT_TIPO<='"  +MV_PAR06+"' AND "	
	cQuery += "CT_GRUPO>='" +MV_PAR07+"' AND "
	cQuery += "CT_GRUPO<='" +MV_PAR08+"' AND "	
	cQuery += "CT_DATA>='"  +DToS(MV_PAR10)+"' AND "
	cQuery += "CT_DATA<='"  +DToS(MV_PAR11)+"' AND "	
	
	cQuery += "SCT.D_E_L_E_T_=' '" 

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSCT,.T.,.T.)

	For nLoop := 1 To Len( aStruSCT ) 
		If aStruSCT[ nLoop, 2 ] <> "C" .And. !Empty( ( cAliasSCT )->( FieldPos( aStruSCT[ nLoop, 1 ] ) ) )
			TcSetField(cAliasSCT,aStruSCT[ nLoop, 1 ],aStruSCT[ nLoop, 2 ],aStruSCT[ nLoop, 3 ],aStruSCT[ nLoop, 4 ] )
		EndIf 		
	Next nLoop 	
	
	bWhile := { || !( cAliasSCT )->( Eof() ) }
	
	nValor := 0 
	nQuant := 0     
	
#ELSE 

	//���������������������������������������������������������������������Ŀ
	//� Logica para ISAM                                                    �
	//�����������������������������������������������������������������������
   
	cQuery := "" 
	cQuery += "CT_FILIAL='"  + xFilial("SCT") + "'.AND."
	cQuery += "CT_REGIAO>='" + MV_PAR03       + "'.AND."
	cQuery += "CT_REGIAO<='" + MV_PAR04+"'.AND."	
	cQuery += "CT_TIPO>='"   + MV_PAR05+"'.AND."
	cQuery += "CT_TIPO<='"   + MV_PAR06+"'.AND."	
	cQuery += "CT_GRUPO>='"  + MV_PAR07+"'.AND."
	cQuery += "CT_GRUPO<='"  + MV_PAR08+"'.AND."	
	cQuery += "DTOS(CT_DATA)>='" + DToS(MV_PAR10)+"'.AND."
	cQuery += "DTOS(CT_DATA)<='" + DToS(MV_PAR11)+"'
		
	cIndSCT := CriaTrab( , .F. ) 
	IndRegua("SCT", cIndSCT, SCT->( IndexKey()) ,,cQuery,"Selecionando Registros ...")	
	nIndex := RetIndex("SCT")
	
	SCT->( dbSetIndex(cIndSCT+OrdBagExt() ) ) 
	SCT->( dbSetOrder( nIndex+1 ) )

	bWhile := { || !SCT->( Eof() ) }
	                                 
	cAliasSCT := "SCT" 

#ENDIF	
	
While Eval( bWhile ) 
      
	If Empty( aReturn[ 7 ] ) .Or. &( aReturn[ 7 ] )       
                              
		//��������������������������������������������������������������Ŀ
		//� Chama a funcao de calculo das vendas                         �
		//����������������������������������������������������������������
		aVendas := FtNfVendas(4,(cAliasSCT)->CT_VEND,MV_PAR01,MV_PAR02,(cAliasSCT)->CT_REGIAO,(cAliasSCT)->CT_TIPO,(cAliasSCT)->CT_GRUPO,(cAliasSCT)->CT_PRODUTO,MV_PAR12,"","","",,cDupli,cEstoq)
	
		aDevol := { 0,0,0 }
		
		If MV_PAR09 == 1  	
			//��������������������������������������������������������������Ŀ
			//� Chama a funcao de calculo das devolucoes de venda            �
			//����������������������������������������������������������������
			aDevol := FtNfDevol(4,(cAliasSCT)->CT_VEND,MV_PAR01,MV_PAR02,(cAliasSCT)->CT_REGIAO,(cAliasSCT)->CT_TIPO,(cAliasSCT)->CT_GRUPO,(cAliasSCT)->CT_PRODUTO,MV_PAR12,"","",,cDupli,cEstoq)
		EndIf 			
				
		Li++                     
		
		nValMeta := xMoeda( ( cAliasSCT )->CT_VALOR, ( cAliasSCT )->CT_MOEDA, MV_PAR12, ( cAliasSCT )->CT_DATA ) 
	
		If ( Li > 58 )
			li := cabec(Titulo,cCabec1,cCabec2,nomeprog,Tamanho,CHRCOMP)
			li++
		Endif         
	
	//     NUMERO  SEQ  DESCRICAO                       DATA        VENDEDOR  REGIAO  PRODUTO          GRUPO  TIPO          VALOR/META      QUANT/META          VALOR/REAL      QUANT/REAL     DIFERENCA VALOR   DIFERENCA QTD
	//               1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
	//     01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	//     XXXXXX  XXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XX/XX/XXXX  XXXXXX    XXX     XXXXXXXXXXXXXXX  XXXX   XX    999,999,999,999.99  999,999,999.99  999,999,999,999.99  999,999,999.99  999,999,999,999.99  999,999,999.99     
	 	
	 	@ Li, 00 PSAY ( cAliasSCT )->CT_DOC
	 	@ Li, 08 PSAY ( cAliasSCT )->CT_SEQUEN	 	
	 	@ Li, 13 PSAY Left( ( cAliasSCT )->CT_DESCRI, 30 ) 
	 	@ Li, 45 PSAY ( cAliasSCT )->CT_DATA 
	
	 	@ Li, 57 PSAY ( cAliasSCT )->CT_VEND 	 	
	 	
	 	@ Li, 67 PSAY ( cAliasSCT )->CT_REGIAO 	 	
	 	@ Li, 75 PSAY ( cAliasSCT )->CT_PRODUTO
	 	@ Li, 92 PSAY ( cAliasSCT )->CT_GRUPO 	
	 	@ Li, 99 PSAY ( cAliasSCT )->CT_TIPO 		 	
	 	
	 	@ Li,105 PSAY nValMeta                PICTURE "@E 999,999,999,999.99"
	 	@ Li,125 PSAY ( cAliasSCT )->CT_QUANT PICTURE "@E 999,999,999.99"	 	
	 	
	 	nValReal := aVendas[ 1 ] - aDevol[ 1 ]
	 	nQtdReal := aVendas[ 2 ] - aDevol[ 2 ]
	 	
		@ Li,141 PSAY nValReal PICTURE "@E 999,999,999,999.99" 
		@ Li,161 PSAY nQtdReal PICTURE "@E 999,999,999.99" 
		                                                       
		@ Li,177 PSAY nValReal - nValMeta                 PICTURE "@E 999,999,999,999.99"
		@ Li,197 PSAY nQtdReal - ( cAliasSCT )->CT_QUANT  PICTURE "@E 999,999,999.99"

	EndIf 
			
	( cAliasSCT )->( dbSkip() ) 
	
EndDo

//��������������������������������������������������������������Ŀ
//� Restaura a integridade da rotina                             �
//����������������������������������������������������������������
#IFDEF TOP
  	( cAliasSCT )->( dbCloseArea() ) 
  	dbSelectArea( "SCT" ) 
#ELSE  	
	RetIndex("SCT")
	FErase(cIndSCT+OrdBagExt())	
#ENDIF
	
If ( lImp )
	Roda(cbCont,cbText,Tamanho)
EndIf       

Set Device To Screen
Set Printer To
If ( aReturn[5] = 1 )
	dbCommitAll()
	OurSpool(wnrel)
Endif
MS_FLUSH()

dbSelectArea( "SCT" )
RetIndex("SCT")

Return(.T.)
