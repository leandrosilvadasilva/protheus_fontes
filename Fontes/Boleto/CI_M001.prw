#Include "RPTDEF.CH"
#Include "FwPrintSetup.ch"
#Include "CI_M001.CH"
#INCLUDE "TbiConn.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � CI_F001  � Autor � Fabio Briddi          � Data � Nov/2013 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Impressao de Boletos Bancarios com Codigo de Barras        ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Financeiro / Faturamento                                   ���
�������������������������������������������������������������������������Ĵ��
���                         Manutencoes                                   ���
�������������������������������������������������������������������������Ĵ��
���Analista  � Motivo                                            �  Data  ���
�������������������������������������������������������������������������Ĵ��
���F.Briddi  � Criacao original Banco Itau                       �Nov/2013���
���Denis Rod � Adicionado impressao para o Banco do Brasil       �Dez/2013���
���Denis Rod � Adicionado impressao para o Banco HSBC            �Dez/2013���
���Denis Rod � Adicionado impressao para o Banco Bradesco        �Jan/2014���
���Denis Rod � Adicionado impressao para o Banco Caixa           �Jan/2014���
���F.Briddi  � Implementado Impressao Boleto Banrisul            �Jan/2014���
���F.Briddi  � Implementado Impressao Boleto Santander           �Jun/2014���
���F.Briddi  � Implementado Criacao de Arquivo p/ Cliente+Loja e �Dez/2014���
���          � p/ Cliente+Loja+Prefixo+Titulo                    �        ���
���F.Briddi  � Implementado Envio p/ E-mail e impressao cega,    �Dez/2014���
���          � p/ uso Schedule / WS                              �        ���
���Giovanni M� Adicionado impressao para o Banco Safra           �Fev/2015���
���Giovanni M� Adicionado impressao para o Banco Fibra           �Fev/2015���
���Giovanni M� Adicionado impressao para a Coop. Cred. Sicredi   �Fev/2015���
���Giovanni M� Adicionado impressao para o Banco Redasset        �Fev/2015���
���Giovanni M� Adicionado impressao para o Banco ABC Brasil      �Mar/2015���
���Giovanni M� Adicionado impressao para o Banco Votorantim      �Mar/2015���
���Giovanni M� Adicionado impressao para o Banco do Nordeste     �Mar/2015���
���F.Briddi  � Alterado Caluculo DV Cod Emp CAIXA de Mod11B9     �Mai/2015���
���          � para Mod11B29 (Modulo 11 Base de 2 a 9)           �        ���
���Jeferson D� Inclusao / validacao do campo EE_ACEITE           �Mai/2015���
���Paola     � Alterada a valida��o do tamanho da conta          �        ���
���          � corrente do banco ABC  de 5 para 8                �Mai/2015���
���Paola     � Inclus�o do calculo do DV do nosso n�mero em banco�        ���
���          � correspondentes Bradesco nos que nao estavam      �Mai/2015���
���          � gravando no campo E1_NUMBCO                       �        ���
���Paola     � Na impressao so nosso n�mero o Banco Nordeste     �        ���
���          � n�o deve ser impresso o c�digo da carteira        �Jun/2015���
���Paola     � Altera��o na impressao por faixa de / ate dos     �        ���
���          � bancos correspondentes                            �Jun/2015���
���Paola     � Altera��o na valida��o da CC Votorantin           �        ���
���          � contem 9 digitos ao inv�s de 5                    �Jun/2015���
���Paola     � Altera��o na valida��o da agencia  de 4 digitos   �        ���
���          � para 3 NORDESTE                                   �Jun/2015���
���Paola     � Altera��o na valida��o da CC NORDESTE             �        ���
���          � contem 7 digitos ao inv�s de 3                    �Jun/2015���
���Paola     � Altera��o para gravar nosso numero + DV           �        ���
���          � no campo E1_NUMBCO NORDESTE                       �Jun/2015���
���Paola     � Altera��o para gravar nosso numero + DV           �        ���
���          � no campo E1_NUMBCO   ABC                          �Jun/2015���
���Giovanni M� Ajustes necessarios na geracao do Cod.Barras e no �Jun/2015���
���          � DV do Nosso Numero da Caixa                       �        ���
���Paola    M� calculo novo do BANRISUL,quando o resto e 0 ou 1  �Jun/2015���
���          � tem regras a definir, inclui outro c�lculo para   �        ���
���          � o c�lculo do nosso n�mero.                        �        ���
���Giovanni M� Corre��es no boleto CITI, no calculo do DV do     �Jun/2015���
���          � Nosso Numero e informacoes a serem impressas      �        ���
���Paola    M� AFEC solicitou voltar a valida��o do tamanho da   �Jun/2015���
���          � agencia do banco Nordeste conforme manual de 3    �        ���
���          � para 4                                            �        ���
���Paola    M� Altera��o na impress�o do valor do titulo         �Jun/2015���
���          � o CLIENTE ter�  op��o  para iformar como          �        ���
���          � qual valor a considerar para a impress�o.         �        ���
���          � parametro CI_MVALIMP                              �        ���
���Paola    M� Altera��o no digito verificador do nosso          �Jun/2015���
���          � numero, alterar o DV calculado no modulo 10       �        ���
���          � quando resto for 1 ou 0                           �        ���
���Paola    M� Altera��o para gravar o digito do nosso numero    �Jun/2015���
���          � no campo E1_NUMBCO banco CITIBANK                 �        ���
���Paola    M� Altera��o para gravar o digito do nosso numero    �Jun/2015���
���          � no campo E1_NUMBCO banco SICREDI                  �        ���
���Paola    M� Altera��o no calculo da linha digit�vel do        �Jun/2015���
���          � boleto da CAIXA                                   �        ���
���Giovanni M� Alteracao no calculo do DV Nosso Numero boleto    �Jun/2015���
���          � Banco Nordeste, utilizando o Modulo11 Base 8.     �        ���
���Giovanni M� Inclusao da formacao do codigo de barras do Banco �Jul/2015���
���          � do Brasil com CODEMP tamanho 4, 6 e 7 posicoes    �        ���
���Giovanni M� Tratamento no tamanho do numero da conta, quando  �Jul/2015���
���          � o tamanho do convenio for diferente de 7          �        ���
���Giovanni M� Adicionado impressao para o Banco BBM,            �Jul/2015���
���          � correspondente Banco Bradesco                     �        ���
���Paola     � Para O BANCO ITAU 400 posi��es n�o tem necessidade�Jul/2015���
���          � de informar o DV do nosso numero , mas para layout�        ���
���          � de 240 posi��es � preciso informar , assim vamos  �        ���
���          � gravar o DV no campo E1_NUMBCO.                   �        ���
���Paola     � Altera��o para o banco do BRASIL com 4 e 6 posi�oe�Jul/2015���
���          � do n�mero do conv�nio. Gravar e imprimir DV       �        ���
���          � do nosso n�mero                                   �        ���
���Paola     � Altera��o na impressao do logo do banco           �Jul/2015���
���          � fun��o saybitmap esta com problemas, abri um      �        ���
���          � chamado n�mero TSTXAI - Ate a fun��o estar ok     �        ���
���          �  foi criada a F001TEMP                            �        ���
���Paola     � Altera��o no c�lculo do DV BB conv�nio 6 posi��es �Jul/2015���
���          �                                                   �        ���
���Paola     � Altera��o no c�lculo do DV SAFRA com correspondent�Jul/2015���
���          � Bradesco. Calcula DV do SAFRA mai DV do BRADESCO  �        ���
���Paola     � Altera��o referente ao logo BBM quando corresponde�Jul/2015���
���          � Bradesco.                                         �        ���
���Paola     � Altera��o no reimpressao no nosso numero BB       �Jul/2015���
���          � quando conv�nio 6 posi��es                        �        ���
���Giovanni M� Altera��o na impressao do campo ESPECIE do banco  �Ago/2015���
���          � Sicredi como DMI, conforme especificado pelo banco�        ���
���Giovanni M� Altera��o na impressao do campo agencia\Beneficia �Ago/2015���
���          � ario n�o e preciso imprimir DV da conta           �        ���
���Giovanni M� Altera��o no campo livre do Banco SAFRA corresp.  �Ago/2015���
���          � BRADESCO                                          �        ���
���Giovanni M� Inclus�o de mensagem para SAFRA correspondente    �Ago/2015���
���          � BRADESCO,assim foi preciso mudar o espa�amento    �        ���
���          � do boleto                                         �        ���
���Paola    M� Alteracao na valida��o da conta corrente do       �Ago/2015���
���          � banco do Brasil.Verificamos que al�m da conta de  �        ���
���          � 5 digitos pode variar de 4 a 8                    �        ���
���Paola    M� Alteracao na impressao do endere�o do beneficiario�Ago/2015���
���          � com carteira de cobran�a correspondente,imprimir  �        ���
���          � informa��es do cadastro do bco correspondente.    �        ���
���Giovanni M� Tratamento na validacao do campo EE_CONTA com tama�Set/2015���
���          � nho entre 4 e 8 posicoes para boletos do Banco do �        ���
���          � Brasil.                                           �        ���
���Giovanni M� Tratamento na geracao do campo livre do codigo de �Set/2015���
���          � barras do Banco Safra correspondente Bradesco.    �        ���
���Giovanni M� Tratamento no calculo do DV do Nosso Numero Banco �Set/2015���
���          � Safra, removendo a subtracao do Resto por 11.     �        ���
���Paola     � Altera��o para impress�o do CNPJ do banco         �Set/2015���
���          � correspondente.                                   �        ���
���Giovanni M� Altera��o na composi��o do Nosso N�mero Bco. Safra�Nov/2015���
���          � Correspondente Bradesco, alterado no c�lculo data �        ���
���          � do vcto pela data de emiss�o, cfe. manual do banco�        ���
���Giovanni M� Alteracao na impressao do CNPJ do Avalista, para  �Nov/2015���
���          � impressao de mais de um titulo na mesma impressao �        ���
���Leonir D  � Inclusao do campo E1_CODDIG para gravacao         �Jan/2016���
���          � da linha digitavel                                �        ���
���Giovanni M� Criado o modulo Mod11B27B para calcular o segundo �Fev/2016���
���          � digito do numero de controle (NC) do Nosso Numero �        ���
���          � do Banco Banrisul                                 �        ���
���Paola     � Mudamos a grava��o do campo EE_FAXATU grava       �mar/2016���
���          � no Reclock ao inves de somar a faixa fora do      �        ���
���          � reclock, devido grande fluxo no cliente.          �        ���
���Leonir D  � Inclus�o da pesquisa do campo E1_FORMA,           �Mar/2016���
���          � verifica se o campo existe, se existe inclui      �        ���
���          � nas perguntas a op��o Forma de Pagamento          �        ���
���Gregory A.� Inclus�o de pergunta, par�metros e Valida��es para�Mar/2016���
���          � a execu��o de impressao de segunda via dos boletos�        ���
���Gregory A.� Atualizacao das validacoes para segunda via para  �Abr/2016���
���          � (nao existencia dos campos de segunda via)        �        ���
���Giovanni M� Inclusao de impressao Cobr. Direta BCO ABC BRASIL �Ago/2016���
���Joao Mttos� Alteracao da Funcao CI_F001D Via WebServices rece-�Ago/2016���
���          � bendo como parametro objeto de impressao          �        ���
���          � FWMSPrinter                                       �        ���
���Paola     � Alteracao para buscar o campo E1_VLCRUZ ao inv�s d�Marc/2017��
���          � valor, devido outras moedas. O campo E1_SALDO     �        ���
���          � convertemos caso necess�rio.                      �        ���
���Paola     � Alteracao para considerar o parametro CI_MBOL01   �27/04/17���
���          � No caso de banco correspondente considerar        �        ���
���          � para a impress�o dos dados do benefici�rio        �        ���
���          � no boleto os dados do beneficiario ou o banco     �        ���
���          � correspondente.                                   �        ���
���Jeferson D� Inclusao de regra para exibir mensagem de abatimen�11/06/18���
���          � to na funcao F001Proc. Neste processo incluimos o �        ���
���          � campo A1_IMPABAT responsavel por esse controle.   �        ���
���Paola     � Inclusao pto de entrada TF001BCLI para considerar �13/11/18���
���          � banco do cadastro do cliente ao inv�s dos         �        ���
���          � parametros.                                       �        ��� 
���Paola     � Retirei a valida��o de valores no caso do MBCAD   �10/12/18���
���          � Devido solicita��o do cliente MAZER. Somente este �        ���
���          � cliente utiliza MBCAD.                            �        ��� 
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������

*/
User Function CI_F001( cAlias, nReg, nOpc )

	Local   aCores    := {}
	Private cCadastro := "Contas a Receber - Impress�o de Boletos"
	Private aRotina   := MenuDef()

	Private lForma		:= (SE1->(FieldPos("E1_FORMA"))   > 0)
	Private lSegundaVia	:= .F.
	Private nSegVia		:= 0

	Private lValidBco	:= SuperGetMV("CI_MBOL02", .F., .T.)
	Private lMensRecibo	:= SuperGetMV("CI_MBOL03", .F., .F.)
	
	If SE1->( FieldPos("E1_PORBCO")) > 0 .AND. SE1->( FieldPos("E1_PORAGC")) > 0 .AND.;
		SE1->( FieldPos("E1_PORDVA")) > 0 .AND. SE1->( FieldPos("E1_PORCTA")) > 0 .AND.;
		SE1->( FieldPos("E1_PORDVC")) > 0 .AND. SE1->( FieldPos("E1_PORSUB")) > 0
		lSegundaVia := .T.
	EndIf

	If	ValType(cAlias) = "U" .And. ValType(nReg) = "U" .And. ValType(nOpc) = "U"

		cAlias := "SE1"

		dbSelectArea(cAlias)
		&(cAlias)->( DbSetOrder( 1 ) )

		mBrowse( 6, 1, 22, 75, cAlias, , , , , , Fa040Legenda(cAlias) )

	Else

		U_CI_F001B( cAlias, nReg, nOpc )

	EndIf

Return()


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � CI_F001B � Autor � Fabio Briddi          � Data � Nov/2013 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Chamada da Funcao de Processamento de Impressao de Boletos ���
���          � Bancarios                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Uso       � CI_F001 - Programa Principal                               ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function CI_F001B( cAlias, nReg, nOpc )

	Local   aArea       := GetArea()
	Local   nAlias      := Select()
	Local   cPerg       := F001AjSx1()
	Local   lBcoPar     := .T.
	Local   lSetCentury := __SetCentury()

	Local   oBoleto     := Nil
	Local   oSetup      := Nil
	Local   lExistBol   := .F.

	Local	lBlind      := .F.

	Local cTempPath   := IIf( IsBlind(), "\boletos\tmp", GetTempPath())
	Local cBolPath    := "\boletos\"

	Private lBCLI       := .F.

	Private lAmbHml     := (SM0->M0_CODIGO == "99") 
	Private lBCLI       := .F.     
	
	If	!File( cBolPath+"." )
		MakeDir( cBolPath )
	EndIf

	If	!File( cTempPath+"." )
		MakeDir( cTempPath )
	EndIf

	If	!lSetCentury
		__SetCentury("ON")
	EndIf

	If ExistBlock( "TF001PAR" )
    	ExecBlock( "TF001PAR", .F., .F., {} )
	EndIf

	// Pto de entrada se considera o bco do cliente
	If ExistBlock( "TF001BCLI" )
    	lBCLI:= ExecBlock( "TF001BCLI", .F., .F., {} )
	EndIf

	If	Pergunte( cPerg, .T. )

		Private cBanco       := MV_PAR01
		Private cAgencia     := MV_PAR02
		Private cConta       := MV_PAR03
		Private cSubCta      := MV_PAR04
		Private lPosicionado := (MV_PAR05 = 1)
		Private cDoPrefixo   := IIf(lPosicionado, SE1->E1_PREFIXO, MV_PAR06)
		Private cAtePrefixo  := IIf(lPosicionado, SE1->E1_PREFIXO, MV_PAR07)
		Private cDoNum       := IIf(lPosicionado, SE1->E1_NUM,     MV_PAR08)
		Private cAteNum      := IIf(lPosicionado, SE1->E1_NUM,     MV_PAR09)
		Private cDaParcela   := IIf(lPosicionado, SE1->E1_PARCELA, MV_PAR10)
		Private cAteParcel   := IIf(lPosicionado, SE1->E1_PARCELA, MV_PAR11)
		Private cDoTipo      := IIf(lPosicionado, SE1->E1_TIPO,    MV_PAR12)
		Private cAteTipo     := IIf(lPosicionado, SE1->E1_TIPO,    MV_PAR13)
		Private dDaEmissao   := MV_PAR14
		Private dAteEmissao  := MV_PAR15
		Private dDoVencRea   := MV_PAR16
		Private dAteVencRea  := MV_PAR17
		Private cDoNumBor    := MV_PAR18
		Private cAteNumBor   := MV_PAR19
		Private cDoCliente   := MV_PAR20
		Private cDaLoja      := MV_PAR21
		Private cAteCliente  := MV_PAR22
		Private cAteLoja     := MV_PAR23
		Private nTipoPDF     := MV_PAR24
		Private lEmail       := (MV_PAR25 = 2)

		If lForma
			Private cForma		:= IIf(lPosicionado, SE1->E1_FORMA, MV_PAR26)
		EndIf

		If lSegundaVia
			nSegVia		:=	 MV_PAR27
		EndIf

		Private nPosBcoHml   := 0
		Private lIniImp      := .F.

		If	lEmail

			lBlind := .T.
			If	nTipoPDF = 1
				nTipoPDF := 2
			EndIf

		EndIf

		If	F001ValParam()

			Processa( {|| F001Proc( @oBoleto, @oSetup, @lExistBol, @lBlind  ) }, "Impress�o de Boletos" ,"Aguarde...." )

		EndIf

	EndIf

	If	!lSetCentury

		__SetCentury("OFF")

	EndIf

	RestArea(aArea)
	dbSelectArea(nAlias)

Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � CI_F001C � Autor � Fabio Briddi          � Data � Jul/2014 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Chamada da Funcao de Processamento de Impressao de Boletos ���
���          � Bancarios por Rotinas Diversas fora da CI_F001.PRW         ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Uso       � CI_F001 - Programa Principal                               ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

/*
//������������������������������������������������������Ŀ
//�Array com os Paramentros dos Titulos a Serem Impressos�
//�                                                      �
//�Manter essa Ordem                                     �
//�                                                      �
//�01 - Prefixo Inicial                                  �
//�02 - Prefixo Final                                    �
//�03 - Titulo Inical                                    �
//�04 - Titulo Final                                     �
//�05 - Parcela Inicial                                  �
//�06 - Parcela Final                                    �
//�07 - Tipo Titulo Inicial                              �
//�08 - Tipo Titulo Final                                �
//�09 - Data Emissao Inicial                             �
//�10 - Data Emissao Final                               �
//�11 - Data Vencimento Real Inicial                     �
//�12 - Data Vencimento Real Final                       �
//�13 - Bordero Inicial                                  �
//�14 - Bordero Final                                    �
//�15 - Cliente Inicial                                  �
//�16 - Loja Inicial                                     �
//�17 - Cliente Inicial                                  �
//�18 - Loja Inicial                                     �
//��������������������������������������������������������
*/

User Function CI_F001C( aTitBol, aBcoBol )

	Local   aArea       := GetArea()
	Local   aAreaSE1    := SE1->(GetArea())
	Local   aAreaSA1    := SA1->(GetArea())
	Local   aAreaSA6    := SA6->(GetArea())
	Local   aAreaSEE    := SEE->(GetArea())
	Local   nAlias      := Select()
	Local   lBcoPar     := .T.
	Local   lSetCentury := __SetCentury()
	Local   oBoleto     := Nil
	Local   oSetup      := Nil
	Local   lExistBol   := .F.

	Local cMsg          := ""

	Private lAmbHml     := (SM0->M0_CODIGO=="99")  
	Private lBCLI       := .F.

	//=====================//
	// Tratamento de Forma //
	//=====================//
	Private lForma		:= .F. //Forma de Pagamento n�o � considerada em pontos de entrada
	//=======================================//
	// Tratamento de impress�o de segunda via//
	//=======================================//
	Private lSegundaVia	:= .F. //Segunda via de boleto n�o ser� considerado em pontos de entrada
	Private nSegVia		:= 0

	If	!lSetCentury
		__SetCentury("ON")
	EndIf

	ConOut( "1111" )
	VarInfo("aTitBol", aTitBol)
	VarInfo("aBcoBol", aBcoBol)

	If	(ValType(aTitBol) = "A" .And. ValType(aBcoBol) = "A") .And.;
		(Len(aTitBol) = 18 .And. Len(aBcoBol) = 4)

		Private cBanco       := PadR( aBcoBol[01] , TamSX3("EE_CODIGO")[1] )
		Private cAgencia     := PadR( aBcoBol[02] , TamSX3("EE_AGENCIA")[1] )
		Private cConta       := PadR( aBcoBol[03] , TamSX3("EE_CONTA")[1] )
		Private cSubCta      := PadR( aBcoBol[04] , TamSX3("EE_SUBCTA")[1] )
		Private lPosicionado := .F.
		Private cDoPrefixo   := PadR( aTitBol[01] , TamSX3("E1_PREFIXO")[1] )
		Private cAtePrefixo  := PadR( aTitBol[02] , TamSX3("E1_PREFIXO")[1] )
		Private cDoNum       := PadR( aTitBol[03] , TamSX3("E1_NUM")[1] )
		Private cAteNum      := PadR( aTitBol[04] , TamSX3("E1_NUM")[1] )
		Private cDaParcela   := PadR( aTitBol[05] , TamSX3("E1_PARCELA")[1] )
		Private cAteParcel   := PadR( aTitBol[06] , TamSX3("E1_PARCELA")[1] )
		Private cDoTipo      := PadR( aTitBol[07] , TamSX3("E1_TIPO")[1] )
		Private cAteTipo     := PadR( aTitBol[08] , TamSX3("E1_TIPO")[1] )
		Private dDaEmissao   := aTitBol[09]
		Private dAteEmissao  := aTitBol[10]
		Private dDoVencRea   := aTitBol[11]
		Private dAteVencRea  := aTitBol[12]
		Private cDoNumBor    := PadR( aTitBol[13] , TamSX3("E1_NUMBOR")[1] )
		Private cAteNumBor   := PadR( aTitBol[14] , TamSX3("E1_NUMBOR")[1] )
		Private cDoCliente   := PadR( aTitBol[15] , TamSX3("E1_CLIENTE")[1] )
		Private cDaLoja		 := PadR( aTitBol[16] , TamSX3("E1_LOJA")[1] )
		Private cAteCliente  := PadR( aTitBol[17] , TamSX3("E1_CLIENTE")[1] )
		Private cAteLoja     := PadR( aTitBol[18] , TamSX3("E1_LOJA")[1] )
		Private nTipoPDF     := 1
		Private lEmail       := .T.

		Private nPosBcoHml   := 0
		Private lIniImp      := .F.
        

		If	F001ValParam( @cMsg )

			ConOut( "22222" )

			Processa( {|| F001Proc( @oBoleto, @oSetup, @lExistBol, .F. ) }, "Impress�o de Boletos" ,"Aguarde...." )
	 	Else

			VarInfo( "F001ValParam", cMsg )	
		EndIf

		If	ValType(oBoleto) = "O" .And. nTipoPDF = 1

			If	oBoleto:nDevice = IMP_PDF .And. lExistBol

				oBoleto:Preview()

			EndIf

			FreeObj(oBoleto)
			FreeObj(oSetup)
			oBoleto   := Nil
			oSetup    := Nil
			lExistBol := .F.

		EndIf

	EndIf

	ConOut( "3333" )
	If	!lSetCentury

		__SetCentury("OFF")

	EndIf

	RestArea(aArea)
	dbSelectArea(nAlias)

Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � CI_F001D � Autor � Denis Rodrigues       � Data � Dez/2014 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Chamada da Funcao de Processamento de Impressao de Boletos ���
���          � Bancarios pelo WebServices                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Uso       � CI_F001 - Programa Principal                               ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

/*
//������������������������������������������������������Ŀ
//�Array com os Paramentros dos Titulos a Serem Impressos�
//�                                                      �
//�Manter essa Ordem                                     �
//�                                                      �
//�01 - Prefixo Inicial                                  �
//�02 - Prefixo Final                                    �
//�03 - Titulo Inical                                    �
//�04 - Titulo Final                                     �
//�05 - Parcela Inicial                                  �
//�06 - Parcela Final                                    �
//�07 - Tipo Titulo Inicial                              �
//�08 - Tipo Titulo Final                                �
//�09 - Data Emissao Inicial                             �
//�10 - Data Emissao Final                               �
//�11 - Data Vencimento Real Inicial                     �
//�12 - Data Vencimento Real Final                       �
//�13 - Bordero Inicial                                  �
//�14 - Bordero Final                                    �
//�15 - Cliente Inicial                                  �
//�16 - Loja Inicial                                     �
//�17 - Cliente Inicial                                  �
//�18 - Loja Inicial                                     �
//��������������������������������������������������������
*/


User Function CI_F001D( aTitBol, aBcoBol, oBoleto )

	Local   aArea       := GetArea()
	Local   aAreaSE1    := SE1->(GetArea())
	Local   aAreaSA1    := SA1->(GetArea())
	Local   aAreaSA6    := SA6->(GetArea())
	Local   aAreaSEE    := SEE->(GetArea())
	Local   nAlias      := Select()
	Local   lBcoPar     := .T.
	Local   lSetCentury := __SetCentury()
	Local   oSetup      := Nil
	Local   lExistBol   := .F.

	Private lAmbHml     := (SM0->M0_CODIGO=="99")  
	Private lBCLI       := .F.

	//=====================//
	// Tratamento de Forma //
	//=====================//
	Private lForma		:= .F. //Forma de Pagamento n�o � considerada no WebService
	//===========================//
	// Tratamento de Segunda Via //
	//===========================//
	Private lSegundaVia	:= .F. //Segunda Via de boleto n�o ser� considerado no WebService
	Private nSegVia		:= 0

	If	!lSetCentury
		__SetCentury("ON")
	EndIf

	If	(ValType(aTitBol) = "A" .And. ValType(aBcoBol) = "A") .And.;
		(Len(aTitBol) = 18 .And. Len(aBcoBol) = 4)

		Private cBanco       := PadR( aBcoBol[01] , TamSX3("EE_CODIGO")[1] )
		Private cAgencia     := PadR( aBcoBol[02] , TamSX3("EE_AGENCIA")[1] )
		Private cConta       := PadR( aBcoBol[03] , TamSX3("EE_CONTA")[1] )
		Private cSubCta      := PadR( aBcoBol[04] , TamSX3("EE_SUBCTA")[1] )
		Private lPosicionado := .F.
		Private cDoPrefixo   := PadR( aTitBol[01] , TamSX3("E1_PREFIXO")[1] )
		Private cAtePrefixo  := PadR( aTitBol[02] , TamSX3("E1_PREFIXO")[1] )
		Private cDoNum       := PadR( aTitBol[03] , TamSX3("E1_NUM")[1] )
		Private cAteNum      := PadR( aTitBol[04] , TamSX3("E1_NUM")[1] )
		Private cDaParcela   := PadR( aTitBol[05] , TamSX3("E1_PARCELA")[1] )
		Private cAteParcel   := PadR( aTitBol[06] , TamSX3("E1_PARCELA")[1] )
		Private cDoTipo      := PadR( aTitBol[07] , TamSX3("E1_TIPO")[1] )
		Private cAteTipo     := PadR( aTitBol[08] , TamSX3("E1_TIPO")[1] )
		Private dDaEmissao   := aTitBol[09]
		Private dAteEmissao  := aTitBol[10]
		Private dDoVencRea   := aTitBol[11]
		Private dAteVencRea  := aTitBol[12]
		Private cDoNumBor    := PadR( aTitBol[13] , TamSX3("E1_NUMBOR")[1] )
		Private cAteNumBor   := PadR( aTitBol[14] , TamSX3("E1_NUMBOR")[1] )
		Private cDoCliente   := PadR( aTitBol[15] , TamSX3("E1_CLIENTE")[1] )
		Private cDaLoja      := PadR( aTitBol[16] , TamSX3("E1_LOJA")[1] )
		Private cAteCliente  := PadR( aTitBol[17] , TamSX3("E1_CLIENTE")[1] )
		Private cAteLoja     := PadR( aTitBol[18] , TamSX3("E1_LOJA")[1] )
		Private nTipoPDF     := 1
		Private lEmail       := .F.

		Private nPosBcoHml   := 0
		Private lIniImp      := .F.

		dbSelectArea("SEE")
		dbSetOrder(1)	//-- EE_FILIAL+EE_CODIGO+EE_AGENCIA+EE_CONTA+EE_SUBCTA
		dbSeek( xFilial("SEE") + cBanco + cAgencia + cConta + cSubCta )

		F001Proc( @oBoleto, @oSetup, @lExistBol, .T. )

	EndIf

	If	!lSetCentury

		__SetCentury("OFF")

	EndIf

	RestArea(aArea)
	dbSelectArea(nAlias)

Return( oBoleto )
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � F001ValParam � Autor � Fabio Briddi      � Data � Nov/2013 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Validacao dos Parametros informados                        ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Uso       � CI_F001 - Programa Principal                               ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function F001ValParam( cMsg )

	Local lRet    := .T.
	Local lBcoCorr:= .T.
	Local cMsg    := ""
	Local nPosHml := 0

	If	( nPosBcoHml := aScan( BANCO_HML, {|x| x[1] == cBanco } ) ) = 0

			cMsg := "Banco n�o Homologado nessa Vers�o do CI_F001" + CRLF
			Help( "", 1, "CI_F001|PARAM01", , cMsg, 1, 0 )

			lRet := .F.

	EndIf

	If	lRet
		/*
		//-- Verifica se Empresa esta autorizada a imprimir
		aDadosAux := { "CI_F001", SM0->M0_CGC, cBanco }
		aRet := u_SFAUTORI( aDadosAux )

		If	!aRet[1]

			cMsg += aRet[2]
			Help( "", 1, "CI_F001|AUTORIZ", , cMsg, 1, 0 )

			lRet := .F.
		EndIf
		*/
	EndIf

	If lRet

		//-- Verifica se a forma � compAT�vel com a pergunta, mesmo na op��o posicionado
		If lForma

			If (lPosicionado) .AND. (AllTrim(SE1->E1_FORMA) <> AllTrim(MV_PAR26))
				cMsg := "Par�metro:" + CRLF
				cMsg += "Forma Pagto." + CRLF
				cMsg += "n�o � compativel com o registro posicionado" + CRLF
				Help( "", 1, "CI_F001|PARAM26", , cMsg, 1, 0 )
				lRet := .F.
			EndIf

		EndIf

	EndIf

   // Valida��o para tipo de Titulo
	// IF  !cDoTipo  $ "BOL" .and. !cAteTipo $ "BOL"
	// lRet:= .F.
	//	Help( "", 1, "ALERT TIPO", , "TESTE" 1, 0 )
   // Endif

	If	lRet
		If	Empty(cBanco) .Or.;
			Empty(cAgencia) .Or.;
			Empty(cConta) .Or.;
			Empty(cSubCta)

			cMsg := "Par�metros:" + CRLF
			cMsg += IIf(Empty(cBanco),"Banco" + CRLF,"")
			cMsg += IIf(Empty(cAgencia),"Ag�ncia" + CRLF,"")
			cMsg += IIf(Empty(cConta),"Conta" + CRLF,"")
			cMsg += IIf(Empty(cSubCta),"SubConta" + CRLF,"")
			cMsg += "Em Branco" + CRLF
			Help( "", 1, "CI_F001|PARAM02", , cMsg, 1, 0 )

			lRet := .F.

		EndIf
	EndIf

	If	lRet
		//-- Posiciona SA6 - Bancos
		DbSelectArea("SA6")
		DbSetOrder(1)
		If	!dbSeek(xFilial('SA6') + cBanco + cAgencia + cConta)

			cMsg := "Par�metros:" + CRLF
			cMsg += "Banco/Ag�ncia/Conta" + CRLF
			cMsg += "n�o Cadastrado (Tabela SA6)" + CRLF
			Help( "", 1, "CI_F001|PARAM03", , cMsg, 1, 0 )

			lRet := .F.
		Else
			//-- Posiciona SEE - Parametros/Configuracoes de Bancos
			DbSelectArea("SEE")
			DbSetOrder(1)
			If	!DbSeek(xFilial("SEE") + cBanco + cAgencia + cConta + cSubCta)

				cMsg := "Par�metros:" + CRLF
				cMsg += "Banco/Ag�ncia/Conta" + CRLF
				cMsg += "n�o Cadastrados (Tabela SEE)" + CRLF
				Help( "", 1, "CI_F001|PARAM04", , cMsg, 1, 0 )

				lRet := .F.

			EndIf

		EndIf

	EndIf

	If	lRet
		If	Empty(SEE->EE_FAXATU) .Or.;
			(Empty(SEE->EE_NOME).AND. !cBanco = BANRISUL)  .Or.;
			Empty(SEE->EE_CODCART) .Or.;
			Empty(SEE->EE_ACEITE)

			cMsg := "Campos em Branco (Tabela SEE) Par�metros de Bancos" + CRLF
			cMsg += IIf(Empty(SEE->EE_FAXATU),"Faixa Atual" + CRLF,"")
			cMsg += IIf(Empty(SEE->EE_NOME),"Nome do Banco" + CRLF,"")
			cMsg += IIf(Empty(SEE->EE_CODCART),"Cod Carteira" + CRLF,"")
			cMsg += IIf(Empty(SEE->EE_ACEITE),"Aceite" + CRLF,"")
			cMsg += CRLF + "Altere o Cadastro e Execute novamente a Rotina" + CRLF
			Help( "", 1, "CI_F001|PARAM05", , cMsg, 1, 0 )

			lRet := .F.

		EndIf

	EndIf

	If	lRet
		If	((cBanco == FIBRA .Or. cBanco == REDASSET .Or. cBanco == BBM .Or. cBanco == VOTORANTIM) .And. Empty(SEE->EE_CODCOR)) ;
		     .Or.;
			(cBanco = SAFRA .And. SEE->EE_CODCART = "09" .And. Empty(SEE->EE_CODCOR))

			cMsg := "Campos em Branco (Tabela SEE) Par�metros de Bancos" + CRLF
			cMsg += IIf(Empty(SEE->EE_CODCOR),"Banco Correspondente" + CRLF,"")
			cMsg += CRLF + "Este Banco s� utiliza impress�o por Banco Correspondente." + CRLF
			cMsg += CRLF + "Altere o Cadastro e Execute novamente a Rotina" + CRLF
			Help( "", 1, "CI_F001|PARAM05", , cMsg, 1, 0 )

			lRet := .F.

		EndIf

	EndIf

	If	lRet
		If	!Empty(SEE->EE_CODCOR) .And.;
			(Empty(SEE->EE_AGECOR) .Or.;
			 Empty(SEE->EE_CTACOR) .Or.;
			 Empty(SEE->EE_NOMECOR))

			cMsg := "Campos em Branco (Tabela SEE) Par�metros de Bancos" + CRLF
			cMsg += IIf(Empty(SEE->EE_AGECOR),"Ag�ncia Banco Correspondente" + CRLF,"")
			cMsg += IIf(Empty(SEE->EE_CTACOR),"Conta Banco Correspondente " + CRLF,"")
			cMsg += IIf(Empty(SEE->EE_NOMECOR),"Nome do Banco Correspondente" + CRLF,"")
			cMsg += CRLF + "Altere o Cadastro e Execute novamente a Rotina" + CRLF
			Help( "", 1, "CI_F001|PARAM05", , cMsg, 1, 0 )

			lRet := .F.

		EndIf

	EndIf

	If	lRet

		//���������������������������������������Ŀ
		//� Validacao especifica para cada Banco  �
		//�����������������������������������������

		If		cBanco = BRASIL

				If	Len(AllTrim(SEE->EE_FAXATU))  <> 05 .And.;
					Len(AllTrim(SEE->EE_FAXATU))  <> 07 .And.;
					Len(AllTrim(SEE->EE_FAXATU))  <> 10 .Or.;
					Len(AllTrim(SEE->EE_AGENCIA)) <> 04 .Or.;
					Len(AllTrim(SEE->EE_CONTA))    < 04 .And.;
					Len(AllTrim(SEE->EE_CONTA))    > 08 .Or.;
					Len(AllTrim(SEE->EE_CODCART)) <> 02 .Or.;
					Len(AllTrim(SEE->EE_CODEMP))  <> 04 .And.;
					Len(AllTrim(SEE->EE_CODEMP))  <> 06 .And.;
					Len(AllTrim(SEE->EE_CODEMP))  <> 07

					cMsg := "Campos com tamanhos Divergentes (Tabela SEE) Par�metros de Bancos" + CRLF
					cMsg += IIf(Len(AllTrim(SEE->EE_AGENCIA))<>04,"Ag�ncia"      + CRLF,"")
					cMsg += IIf(Len(AllTrim(SEE->EE_CONTA))  < 04 .And.;
					            Len(AllTrim(SEE->EE_CONTA))  > 08,"Conta"        + CRLF,"")
					cMsg += IIf(Len(AllTrim(SEE->EE_FAXATU)) <>05 .And.;
					            Len(AllTrim(SEE->EE_FAXATU)) <>07 .And.;
					            Len(AllTrim(SEE->EE_FAXATU)) <>10,"Faixa Atual"  + CRLF,"")
					cMsg += IIf(Len(AllTrim(SEE->EE_CODCART))<>02,"Cod Carteira" + CRLF,"")
					cMsg += IIf(Len(AllTrim(SEE->EE_CODEMP)) <>04 .And.;
					            Len(AllTrim(SEE->EE_CODEMP)) <>06 .And.;
					            Len(AllTrim(SEE->EE_CODEMP)) <>07,"Cod Empresa"  + CRLF,"")
					cMsg += CRLF + "Altere o Cadastro e Execute novamente a Rotina" + CRLF

					lRet := .F.

				EndIf

		ElseIf cBanco = SANTANDER

				If	Len(AllTrim(SEE->EE_FAXATU))  <> 12 .Or.;
					Len(AllTrim(SEE->EE_AGENCIA)) <> 04 .Or.;
					Len(AllTrim(SEE->EE_CODEMP))  <> 07

					cMsg := "Campos com tamanhos Divergentes (Tabela SEE) Par�metros de Bancos" + CRLF
					cMsg += IIf(Len(AllTrim(SEE->EE_AGENCIA))<>04,"Ag�ncia"      + CRLF,"")
					cMsg += IIf(Len(AllTrim(SEE->EE_FAXATU)) <>12,"Faixa Atual"  + CRLF,"")
					cMsg += IIf(Len(AllTrim(SEE->EE_CODEMP)) <>07,"Cod Empresa"  + CRLF,"")
					cMsg += CRLF + "Altere o Cadastro e Execute novamente a Rotina" + CRLF

					lRet := .F.

				EndIf

				If	lRet
					If	!(AllTrim(SEE->EE_CODCART)  $ "101|102|201")

						cMsg += "Cod Carteira Inv�lido"  + CRLF
						cMsg += CRLF
						cMsg += "Use 101, 102 ou 201"  + CRLF
						lRet := .F.

					EndIf
				EndIf

		ElseIf cBanco = BANRISUL

				If	Len(AllTrim(SEE->EE_FAXATU))  <> 08 .Or.;
					Len(AllTrim(SEE->EE_AGENCIA)) <> 04 .Or.;
					Len(AllTrim(SEE->EE_CODEMP))  <> 09

					cMsg := "Campos com tamanhos Divergentes (Tabela SEE) Par�metros de Bancos" + CRLF
					cMsg += IIf(Len(AllTrim(SEE->EE_AGENCIA))<>04,"Ag�ncia"      + CRLF,"")
					cMsg += IIf(Len(AllTrim(SEE->EE_FAXATU)) <>08,"Faixa Atual"  + CRLF,"")
					cMsg += IIf(Len(AllTrim(SEE->EE_CODEMP)) <>09,"Cod Empresa"  + CRLF,"")
					cMsg += CRLF + "Altere o Cadastro e Execute novamente a Rotina" + CRLF

					lRet := .F.

				EndIf

		ElseIf cBanco = CAIXA

				cMsg := ""

				If	!(AllTrim(SEE->EE_CODCART)  $ "RG|SR")

					cMsg += "Cod Carteira Inv�lido"  + CRLF
					cMsg += CRLF
					cMsg += "Use RG ou SR"  + CRLF
					lRet := .F.

				EndIf

				If	lRet
               
					//�����������������������������������������������������������������������������������������������������Ŀ
					//� Para a Caixa o Nosso Numero eh tamanho 15, nas primeiras versoes foram alterados os campos para 15. �
					//� Mas, por  de dicionarios em versoes do Protheus passei a tratar somente com 12.             �
					//�������������������������������������������������������������������������������������������������������
				
					If	(Len(AllTrim(SEE->EE_FAXATU)) <> 15 .And. Len(AllTrim(SEE->EE_FAXATU)) <> 12) .Or.;
						Len(AllTrim(SEE->EE_CODCART)) <> 02 .Or.;
						Len(AllTrim(SEE->EE_AGENCIA)) <> 04 .Or.;
						Len(AllTrim(SEE->EE_CODEMP))  <> 06

						cMsg := "Campos com tamanhos Divergentes (Tabela SEE) Par�metros de Bancos" + CRLF
						cMsg += IIf(Len(AllTrim(SEE->EE_AGENCIA))<>04,"Ag�ncia"      + CRLF,"")
						cMsg += IIf((Len(AllTrim(SEE->EE_FAXATU))<>15 .And.;
									 Len(AllTrim(SEE->EE_FAXATU))<>12),"Faixa Atual" + CRLF,"")
						cMsg += IIf(Len(AllTrim(SEE->EE_CODCART))<>02,"Cod Carteira" + CRLF,"")
						cMsg += IIf(Len(AllTrim(SEE->EE_CODEMP)) <>06,"Cod Empresa"  + CRLF,"")
						cMsg += CRLF + "Altere o Cadastro e Execute novamente a Rotina" + CRLF

						lRet := .F.

					EndIf
				EndIf

		ElseIf cBanco = BRADESCO

				If	Len(AllTrim(SEE->EE_FAXATU))  <> 11 .Or.;
					Len(AllTrim(SEE->EE_CODCART)) <> 02 .Or.;
					Len(AllTrim(SEE->EE_AGENCIA)) <> 04 .Or.;
					Len(AllTrim(SEE->EE_CONTA))   <> 07

					cMsg := "Campos com tamanhos Divergentes (Tabela SEE) Par�metros de Bancos" + CRLF
					cMsg += IIf(Len(AllTrim(SEE->EE_AGENCIA))<>04,"Ag�ncia"      + CRLF,"")
					cMsg += IIf(Len(AllTrim(SEE->EE_CONTA))  <>07,"Conta"        + CRLF,"")
					cMsg += IIf(Len(AllTrim(SEE->EE_FAXATU)) <>11,"Faixa Atual"  + CRLF,"")
					cMsg += IIf(Len(AllTrim(SEE->EE_CODCART))<>02,"Cod Carteira" + CRLF,"")
					cMsg += CRLF + "Altere o Cadastro e Execute novamente a Rotina" + CRLF

					lRet := .F.

				EndIf


		ElseIf	cBanco = ITAU

				If	Len(AllTrim(SEE->EE_FAXATU))  <> 8 .Or.;
					Len(AllTrim(SEE->EE_CODCART)) <> 3 .Or.;
					Len(AllTrim(SEE->EE_AGENCIA)) <> 4 .Or.;
					Len(AllTrim(SEE->EE_CONTA))   <> 5

					cMsg := "Campos com tamanhos Divergentes (Tabela SEE) Par�metros de Bancos" + CRLF
					cMsg += IIf(Len(AllTrim(SEE->EE_AGENCIA))<>04,"Ag�ncia"      + CRLF,"")
					cMsg += IIf(Len(AllTrim(SEE->EE_CONTA))  <>05,"Conta"        + CRLF,"")
					cMsg += IIf(Len(AllTrim(SEE->EE_FAXATU)) <>08,"Faixa Atual"  + CRLF,"")
					cMsg += IIf(Len(AllTrim(SEE->EE_CODCART))<>03,"Cod Carteira" + CRLF,"")
					cMsg += CRLF + "Altere o Cadastro e Execute novamente a Rotina" + CRLF

					lRet := .F.

				EndIf

		ElseIf	cBanco = HSBC

				cMsg := ""

				If	!(AllTrim(SEE->EE_CODCART)  $ "CNR|CSB")

					cMsg += "Cod Carteira Inv�lido"  + CRLF
					cMsg += CRLF
					cMsg += "Use CNR ou CSB"  + CRLF
					lRet := .F.

				EndIf

				If	lRet
					If	Len(AllTrim(SEE->EE_CODCART)) <> 03 .Or.;
						Len(AllTrim(SEE->EE_AGENCIA)) <> 04 .Or.;
						Len(AllTrim(SEE->EE_CODEMP))  <> 07

						cMsg += IIf(Len(AllTrim(SEE->EE_AGENCIA))<>04,"Ag�ncia"      + CRLF,"")
						cMsg += IIf(Len(AllTrim(SEE->EE_CODCART))<>03,"Cod Carteira" + CRLF,"")
						cMsg += IIf(Len(AllTrim(SEE->EE_CODEMP)) <>07,"Cod Empresa"  + CRLF,"")
						lRet := .F.

					Else
						If	(SEE->EE_CODCART = "CNR" .And. Len(AllTrim(SEE->EE_FAXATU))  <> 08) .Or.;
							(SEE->EE_CODCART = "CSB" .And. Len(AllTrim(SEE->EE_FAXATU))  <> 10)

							cMsg += "Faixa Atual"  + CRLF
							lRet := .F.

						EndIf

					EndIf

				EndIf

				If	!lRet

					cMsg := "Campos com tamanhos ou conte�dos Divergentes (Tabela SEE) Par�metros de Bancos" + CRLF + cMsg
					cMsg += CRLF + "Altere o Cadastro e Execute novamente a Rotina" + CRLF

				EndIf


		ElseIf cBanco = SAFRA

				cMsg := ""

				If	!(AllTrim(SEE->EE_CODCART)  $ "01|06|09")

					cMsg += "Cod Carteira Inv�lido"  + CRLF
					cMsg += CRLF
					cMsg += "Use 01, 06 ou 09"  + CRLF
					lRet := .F.

				EndIf

				If lRet .And. AllTrim(SEE->EE_CODCART) = "06" //-- COBRANCA EXPRESS

					If	Len(AllTrim(SEE->EE_FAXATU))  <> 10 .Or.;
						Len(AllTrim(SEE->EE_CODCART)) <> 02 .Or.;
						Len(AllTrim(SEE->EE_AGENCIA)) <> 05 .Or.;
						Len(AllTrim(SEE->EE_CODEMP))  <> 06 .Or.;
						Len(AllTrim(SEE->EE_CONTA))   <> 09

						cMsg := "Campos com tamanhos Divergentes (Tabela SEE) Par�metros de Bancos" + CRLF
						cMsg += IIf(Len(AllTrim(SEE->EE_AGENCIA))<>05,"Ag�ncia"      + CRLF,"")
						cMsg += IIf(Len(AllTrim(SEE->EE_CONTA))  <>09,"Conta"        + CRLF,"")
						cMsg += IIf(Len(AllTrim(SEE->EE_FAXATU)) <>10,"Faixa Atual"  + CRLF,"")
						cMsg += IIf(Len(AllTrim(SEE->EE_CODCART))<>02,"Cod Carteira" + CRLF,"")
						cMsg += IIf(Len(AllTrim(SEE->EE_CODEMP)) <>06,"Cod Empresa"  + CRLF,"")
						cMsg += CRLF + "Altere o Cadastro e Execute novamente a Rotina" + CRLF

						lRet := .F.

					EndIf

				ElseIf lRet .And. AllTrim(SEE->EE_CODCART) = "01" //-- COBRANCA REGISTRADA

					If	Len(AllTrim(SEE->EE_FAXATU))  <> 08 .Or.;
						Len(AllTrim(SEE->EE_CODCART)) <> 02 .Or.;
						Len(AllTrim(SEE->EE_AGENCIA)) <> 05 .Or.;
						Len(AllTrim(SEE->EE_CONTA))   <> 09

						cMsg := "Campos com tamanhos Divergentes (Tabela SEE) Par�metros de Bancos" + CRLF
						cMsg += IIf(Len(AllTrim(SEE->EE_AGENCIA))<>05,"Ag�ncia"      + CRLF,"")
						cMsg += IIf(Len(AllTrim(SEE->EE_CONTA))  <>09,"Conta"        + CRLF,"")
						cMsg += IIf(Len(AllTrim(SEE->EE_FAXATU)) <>08,"Faixa Atual"  + CRLF,"")
						cMsg += IIf(Len(AllTrim(SEE->EE_CODCART))<>02,"Cod Carteira" + CRLF,"")
						cMsg += CRLF + "Altere o Cadastro e Execute novamente a Rotina" + CRLF

						lRet := .F.

					EndIf

				ElseIf lRet .And. AllTrim(SEE->EE_CODCART) = "09"  //-- COBRANCA CORRESPONDENTE BRADESCO

					If AllTrim(SEE->EE_CODCOR)  = BRADESCO

							If	Len(AllTrim(SEE->EE_FAXATU))  <> 08 .Or.;
								Len(AllTrim(SEE->EE_CODCART)) <> 02 .Or.;
								Len(AllTrim(SEE->EE_AGENCIA)) <> 05 .Or.;
								Len(AllTrim(SEE->EE_CONTA))   <> 09 .Or.;
								Len(AllTrim(SEE->EE_AGECOR))  <> 04 .Or.;
								Len(AllTrim(SEE->EE_CTACOR))  <> 07 .Or.;
								Empty(SEE->EE_NOMECOR)

								cMsg := "Campos com tamanhos Divergentes (Tabela SEE) Par�metros de Bancos" + CRLF
								cMsg += IIf(Len(AllTrim(SEE->EE_AGENCIA))<>05,"Ag�ncia"               + CRLF,"")
								cMsg += IIf(Len(AllTrim(SEE->EE_CONTA))  <>09,"Conta"                 + CRLF,"")
								cMsg += IIf(Len(AllTrim(SEE->EE_FAXATU)) <>08,"Faixa Atual"           + CRLF,"")
								cMsg += IIf(Len(AllTrim(SEE->EE_CODCART))<>02,"Cod Carteira"          + CRLF,"")
								cMsg += IIf(Len(AllTrim(SEE->EE_AGECOR)) <>04,"Ag�ncia Correspondente"+ CRLF,"")
								cMsg += IIf(Len(AllTrim(SEE->EE_CTACOR)) <>07,"Conta Correspondente"  + CRLF,"")
								cMsg += IIf(Empty(SEE->EE_NOMECOR)           ,"Nome Banco Corresp."   + CRLF,"")
								cMsg += CRLF + "Altere o Cadastro e Execute novamente a Rotina"       + CRLF

								lRet := .F.

							EndIf

					Else

						lBcoCorr := .F.
						lRet     := .F.

					EndIf

				EndIf

		ElseIf cBanco = FIBRA

				cMsg := ""

				If	!(AllTrim(SEE->EE_CODCART)  $ "19")

					cMsg += "Cod Carteira Inv�lido"  + CRLF
					cMsg += CRLF
					cMsg += "Use 19"  + CRLF
					lRet := .F.

				EndIf

				If lRet .And. AllTrim(SEE->EE_CODCART) = "19" //-- COBRANCA CORRESPONDENTE BRADESCO

					If AllTrim(SEE->EE_CODCOR) = BRADESCO

						If	Len(AllTrim(SEE->EE_FAXATU))  <> 11 .Or.;
							Len(AllTrim(SEE->EE_CODCART)) <> 02 .Or.;
							Len(AllTrim(SEE->EE_AGENCIA)) <> 04 .Or.;
							Len(AllTrim(SEE->EE_CONTA))   <> 07 .Or.;
							Len(AllTrim(SEE->EE_AGECOR))  <> 04 .Or.;
							Len(AllTrim(SEE->EE_CTACOR))  <> 07 .Or.;
							Empty(SEE->EE_NOMECOR)

							cMsg := "Campos com tamanhos Divergentes (Tabela SEE) Par�metros de Bancos" + CRLF
							cMsg += IIf(Len(AllTrim(SEE->EE_AGENCIA))<>04,"Ag�ncia"               + CRLF,"")
							cMsg += IIf(Len(AllTrim(SEE->EE_CONTA))  <>07,"Conta"                 + CRLF,"")
							cMsg += IIf(Len(AllTrim(SEE->EE_FAXATU)) <>11,"Faixa Atual"           + CRLF,"")
							cMsg += IIf(Len(AllTrim(SEE->EE_CODCART))<>02,"Cod Carteira"          + CRLF,"")
							cMsg += IIf(Len(AllTrim(SEE->EE_AGECOR)) <>04,"Ag�ncia Correspondente"+ CRLF,"")
							cMsg += IIf(Len(AllTrim(SEE->EE_CTACOR)) <>07,"Conta Correspondente"  + CRLF,"")
							cMsg += IIf(Empty(SEE->EE_NOMECOR)           ,"Nome Banco Corresp."   + CRLF,"")
							cMsg += CRLF + "Altere o Cadastro e Execute novamente a Rotina"       + CRLF

							lRet := .F.

						EndIf

					Else

						lBcoCorr := .F.
						lRet     := .F.

					EndIf

				EndIf

		ElseIf cBanco = SICREDI

				If	AllTrim(SEE->EE_CODCART) <> "A"

					cMsg += "Cod Carteira Inv�lido"  + CRLF
					cMsg += CRLF
					cMsg += "Use 1"  + CRLF
					lRet := .F.

				EndIf
				//�����������������������������������������������������������Ŀ
				//� O Sicredi possui um codigo referente ao posto/agencia da  �
				//� agencia do beneficiario. Para isso, devera ser criado no  �
				//� configurador o campo EE_POSTO, conforme boletim tecnico.  �
				//�������������������������������������������������������������
                
				If	Len(AllTrim(SEE->EE_POSTO))   <> 02 .Or.;
					Len(AllTrim(SEE->EE_FAXATU))  <> 12 .Or.;
					Len(AllTrim(SEE->EE_CODCART)) <> 01 .Or.;
					Len(AllTrim(SEE->EE_AGENCIA)) <> 04 .Or.;
					Len(AllTrim(SEE->EE_CONTA))   <> 06

					cMsg := "Campos com tamanhos Divergentes (Tabela SEE) Par�metros de Bancos" + CRLF
					cMsg += IIf(Len(AllTrim(SEE->EE_AGENCIA))<>04,"Ag�ncia"      + CRLF,"")
					cMsg += IIf(Len(AllTrim(SEE->EE_CONTA))  <>05,"Conta"        + CRLF,"")
					cMsg += IIf(Len(AllTrim(SEE->EE_FAXATU)) <>05,"Faixa Atual"  + CRLF,"")
					cMsg += IIf(Len(AllTrim(SEE->EE_POSTO))  <>01,"Cod Carteira" + CRLF,"")
					cMsg += IIf(Len(AllTrim(SEE->EE_CODEMP)) <>02,"Cod Empresa"  + CRLF,"")
					cMsg += CRLF + "Altere o Cadastro e Execute novamente a Rotina" + CRLF

					lRet := .F.

				EndIf

		ElseIf cBanco = REDASSET

				cMsg := ""

				If	!(AllTrim(SEE->EE_CODCART)  $ "09")

					cMsg += "Cod Carteira Inv�lido"  + CRLF
					cMsg += CRLF
					cMsg += "Use 09"  + CRLF
					lRet := .F.

				EndIf

				If lRet .And. AllTrim(SEE->EE_CODCART) = "09" //-- COBRANCA CORRESPONDENTE BRADESCO

					If AllTrim(SEE->EE_CODCOR) = BRADESCO

						If	Len(AllTrim(SEE->EE_FAXATU))  <> 11 .Or.;
							Len(AllTrim(SEE->EE_CODCART)) <> 02 .Or.;
							Len(AllTrim(SEE->EE_AGENCIA)) <> 04 .Or.;
							Len(AllTrim(SEE->EE_CONTA))   <> 07 .Or.;
							Len(AllTrim(SEE->EE_AGECOR))  <> 04 .Or.;
							Len(AllTrim(SEE->EE_CTACOR))  <> 07 .Or.;
							Empty(SEE->EE_NOMECOR)

							cMsg := "Campos com tamanhos Divergentes (Tabela SEE) Par�metros de Bancos" + CRLF
							cMsg += IIf(Len(AllTrim(SEE->EE_AGENCIA))<>04,"Ag�ncia"               + CRLF,"")
							cMsg += IIf(Len(AllTrim(SEE->EE_CONTA))  <>07,"Conta"                 + CRLF,"")
							cMsg += IIf(Len(AllTrim(SEE->EE_FAXATU)) <>11,"Faixa Atual"           + CRLF,"")
							cMsg += IIf(Len(AllTrim(SEE->EE_CODCART))<>02,"Cod Carteira"          + CRLF,"")
							cMsg += IIf(Len(AllTrim(SEE->EE_AGECOR)) <>04,"Ag�ncia Correspondente"+ CRLF,"")
							cMsg += IIf(Len(AllTrim(SEE->EE_CTACOR)) <>07,"Conta Correspondente"  + CRLF,"")
							cMsg += IIf(Empty(SEE->EE_NOMECOR)           ,"Nome Banco Corresp."   + CRLF,"")
							cMsg += CRLF + "Altere o Cadastro e Execute novamente a Rotina"       + CRLF

							lRet := .F.

						EndIf

					Else

						lBcoCorr := .F.
						lRet     := .F.

					EndIf

				EndIf

		ElseIf cBanco = BBM

				cMsg := ""

				If	!(AllTrim(SEE->EE_CODCART)  $ "09")

					cMsg += "Cod Carteira Inv�lido"  + CRLF
					cMsg += CRLF
					cMsg += "Use 09"  + CRLF
					lRet := .F.

				EndIf

				If lRet .And. AllTrim(SEE->EE_CODCART) = "09" //-- COBRANCA CORRESPONDENTE BRADESCO

					If AllTrim(SEE->EE_CODCOR) = BRADESCO

						If	Len(AllTrim(SEE->EE_FAXATU))  <> 11 .Or.;
							Len(AllTrim(SEE->EE_CODCART)) <> 02 .Or.;
							Len(AllTrim(SEE->EE_AGENCIA)) <> 04 .Or.;
							Len(AllTrim(SEE->EE_CONTA))   <> 07 .Or.;
							Len(AllTrim(SEE->EE_AGECOR))  <> 04 .Or.;
							Len(AllTrim(SEE->EE_CTACOR))  <> 07 .Or.;
							Empty(SEE->EE_NOMECOR)

							cMsg := "Campos com tamanhos Divergentes (Tabela SEE) Par�metros de Bancos" + CRLF
							cMsg += IIf(Len(AllTrim(SEE->EE_AGENCIA))<>04,"Ag�ncia"               + CRLF,"")
							cMsg += IIf(Len(AllTrim(SEE->EE_CONTA))  <>07,"Conta"                 + CRLF,"")
							cMsg += IIf(Len(AllTrim(SEE->EE_FAXATU)) <>11,"Faixa Atual"           + CRLF,"")
							cMsg += IIf(Len(AllTrim(SEE->EE_CODCART))<>02,"Cod Carteira"          + CRLF,"")
							cMsg += IIf(Len(AllTrim(SEE->EE_AGECOR)) <>04,"Ag�ncia Correspondente"+ CRLF,"")
							cMsg += IIf(Len(AllTrim(SEE->EE_CTACOR)) <>07,"Conta Correspondente"  + CRLF,"")
							cMsg += IIf(Empty(SEE->EE_NOMECOR)           ,"Nome Banco Corresp."   + CRLF,"")
							cMsg += CRLF + "Altere o Cadastro e Execute novamente a Rotina"       + CRLF

							lRet := .F.

						EndIf

					Else

						lBcoCorr := .F.
						lRet     := .F.

					EndIf

				EndIf

		ElseIf	cBanco = ABC

			cMsg := ""

			If	!(AllTrim(SEE->EE_CODCART)  $ "109|110|121")

				cMsg += "Cod Carteira Inv�lido"  + CRLF
				cMsg += CRLF
				cMsg += "Use 109, 110 ou 121"  + CRLF
				lRet := .F.

			EndIf

			If AllTrim(SEE->EE_CODCART) = "109" // Banco Correspondente

				If AllTrim(SEE->EE_CODCOR) = ITAU

					If	Len(AllTrim(SEE->EE_FAXATU))  <> 08 .Or.;
						Len(AllTrim(SEE->EE_CODCART)) <> 03 .Or.;
						Len(AllTrim(SEE->EE_AGENCIA)) <> 04 .Or.;
						Len(AllTrim(SEE->EE_AGECOR))  <> 04 .Or.;
						Len(AllTrim(SEE->EE_CTACOR))  <> 05 .Or.;
						Len(AllTrim(SEE->EE_DVCTCOR)) <> 01 .Or.;
						Empty(SEE->EE_NOMECOR)

						cMsg := "Campos com tamanhos Divergentes (Tabela SEE) Par�metros de Bancos" + CRLF
						cMsg += IIf(Len(AllTrim(SEE->EE_AGENCIA))<>04,"Ag�ncia"               + CRLF,"")
						cMsg += IIf(Len(AllTrim(SEE->EE_FAXATU)) <>08,"Faixa Atual"           + CRLF,"")
						cMsg += IIf(Len(AllTrim(SEE->EE_CODCART))<>03,"Cod Carteira"          + CRLF,"")
						cMsg += IIf(Len(AllTrim(SEE->EE_AGECOR)) <>04,"Ag�ncia Correspondente"+ CRLF,"")
						cMsg += IIf(Len(AllTrim(SEE->EE_CTACOR)) <>05,"Conta Correspondente"  + CRLF,"")
						cMsg += IIf(Len(AllTrim(SEE->EE_DVCTCOR))<>01,"Digito Conta Corresp." + CRLF,"")
						cMsg += IIf(Empty(SEE->EE_NOMECOR)           ,"Nome Banco Corresp."   + CRLF,"")
						cMsg += CRLF + "Altere o Cadastro e Execute novamente a Rotina" + CRLF

						lRet := .F.

					EndIf

				Else

					lBcoCorr := .F.
					lRet 	 := .F.

				EndIf

			ElseIf AllTrim(SEE->EE_CODCART) = "110" // Cobranca Direta

					If	Len(AllTrim(SEE->EE_FAXATU))  <> 10 .Or.;
						Len(AllTrim(SEE->EE_CODCART)) <> 03 .Or.;
						Len(AllTrim(SEE->EE_AGENCIA)) <> 04 .Or.;
						Len(AllTrim(SEE->EE_CODEMP))  <> 07

						cMsg := "Campos com tamanhos Divergentes (Tabela SEE) Par�metros de Bancos" + CRLF
						cMsg += IIf(Len(AllTrim(SEE->EE_AGENCIA))<>04,"Ag�ncia"               + CRLF,"")
						cMsg += IIf(Len(AllTrim(SEE->EE_CODEMP)) <>07,"Conta"                 + CRLF,"")
						cMsg += IIf(Len(AllTrim(SEE->EE_FAXATU)) <>10,"Faixa Atual"           + CRLF,"")
						cMsg += IIf(Len(AllTrim(SEE->EE_CODCART))<>03,"Cod Carteira"          + CRLF,"")
						cMsg += CRLF + "Altere o Cadastro e Execute novamente a Rotina" + CRLF

						lRet := .F.

					EndIf

			EndIf

		ElseIf		cBanco = VOTORANTIM

			If AllTrim(SEE->EE_CODCOR) = BRASIL

				If	Len(AllTrim(SEE->EE_FAXATU))  <> 10 .Or.;
					Len(AllTrim(SEE->EE_AGENCIA)) <> 04 .Or.;
					Len(AllTrim(SEE->EE_CONTA))   <> 09 .Or.; //Paola - 10/06/2015
					Len(AllTrim(SEE->EE_CODCART)) <> 02 .Or.;
					Len(AllTrim(SEE->EE_AGECOR))  <> 04 .Or.;
					Len(AllTrim(SEE->EE_CTACOR))  <> 05 .Or.;
					Len(AllTrim(SEE->EE_CODEMP))  <> 07

					cMsg := "Campos com tamanhos Divergentes (Tabela SEE) Par�metros de Bancos" + CRLF
					cMsg += IIf(Len(AllTrim(SEE->EE_AGENCIA))<>04,"Ag�ncia"      + CRLF,"")
					cMsg += IIf(Len(AllTrim(SEE->EE_CONTA))  <>05,"Conta"        + CRLF,"")
					cMsg += IIf(Len(AllTrim(SEE->EE_FAXATU)) <>10,"Faixa Atual"  + CRLF,"")
					cMsg += IIf(Len(AllTrim(SEE->EE_CODCART))<>02,"Cod Carteira" + CRLF,"")
					cMsg += IIf(Len(AllTrim(SEE->EE_AGECOR)) <>04,"Ag�ncia Correspondente"+ CRLF,"")
					cMsg += IIf(Len(AllTrim(SEE->EE_CTACOR)) <>05,"Conta Correspondente"  + CRLF,"")
					cMsg += IIf(Len(AllTrim(SEE->EE_CODEMP)) <>07,"Cod Empresa"  + CRLF,"")
					cMsg += CRLF + "Altere o Cadastro e Execute novamente a Rotina" + CRLF

					lRet := .F.

				EndIf

			Else

				lBcoCorr := .F.
				lRet     := .F.

			EndIf

		ElseIf		cBanco = NORDESTE

				If	Len(AllTrim(SEE->EE_FAXATU))  <> 07 .Or.;
					Len(AllTrim(SEE->EE_AGENCIA)) <> 04 .Or.;
					Len(AllTrim(SEE->EE_CONTA))   <> 07 .Or.; // cfe. pagina 4 do manual, conta DEVE possuir 7 digitos
					Len(AllTrim(SEE->EE_CODCART)) <> 02

					cMsg := "Campos com tamanhos Divergentes (Tabela SEE) Par�metros de Bancos" + CRLF
					cMsg += IIf(Len(AllTrim(SEE->EE_AGENCIA))<>04,"Ag�ncia"      + CRLF,"")
					cMsg += IIf(Len(AllTrim(SEE->EE_CONTA))  <>07,"Conta"        + CRLF,"")
					cMsg += IIf(Len(AllTrim(SEE->EE_FAXATU)) <>07,"Faixa Atual"  + CRLF,"")
					cMsg += IIf(Len(AllTrim(SEE->EE_CODCART))<>02,"Cod Carteira" + CRLF,"")
					cMsg += CRLF + "Altere o Cadastro e Execute novamente a Rotina" + CRLF

					lRet := .F.

				EndIf

		ElseIf		cBanco = CITIBANK

				If	Len(AllTrim(SEE->EE_FAXATU))  <> 11 .Or.;
					Len(AllTrim(SEE->EE_AGENCIA)) <> 04 .Or.;
					Len(AllTrim(SEE->EE_CONTA))   <> 09 .Or.;
					Len(AllTrim(SEE->EE_DVCTA))   <> 01 .Or.;
					Len(AllTrim(SEE->EE_CODCART)) <> 03

					cMsg := "Campos com tamanhos Divergentes (Tabela SEE) Par�metros de Bancos" + CRLF
					cMsg += IIf(Len(AllTrim(SEE->EE_AGENCIA))<>04,"Ag�ncia"      + CRLF,"")
					cMsg += IIf(Len(AllTrim(SEE->EE_CONTA))  <>09,"Conta"        + CRLF,"")
					cMsg += IIf(Len(AllTrim(SEE->EE_DVCTA))  <>01,"DV Conta"     + CRLF,"")
					cMsg += IIf(Len(AllTrim(SEE->EE_FAXATU)) <>11,"Faixa Atual"  + CRLF,"")
					cMsg += IIf(Len(AllTrim(SEE->EE_CODCART))<>03,"Cod Carteira" + CRLF,"")
					cMsg += CRLF + "Altere o Cadastro e Execute novamente a Rotina" + CRLF

					lRet := .F.

				EndIf

		EndIf

		If !lBcoCorr //-- Banco Correspondente invalido

			cMsg := "Banco correspondente inv�lido para este tipo de carteira." + CRLF
			cMsg += CRLF + "Carteira informada: " + AllTrim(SEE->EE_CODCART)    + CRLF
			cMsg += "Banco selecionado: "         + AllTrim(SEE->EE_CODCOR)     + CRLF
			cMsg += CRLF + "Altere o Cadastro e Execute novamente a Rotina"     + CRLF

		EndIf

		If !lRet
			Help( "", 1, "CI_F001|PARAM06", , cMsg, 1, 0 )
		EndIf

	EndIf

Return(lRet)
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � F001Proc � Autor � Fabio Briddi          � Data � Nov/2013 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Funcao de Processamento para a Impressao de Boletos        ���
���          � Bancarios                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Uso       � CI_F001 - Programa Principal                               ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function F001Proc( oBoleto, oSetup, lExistBol, lBlind )

	Local aCedente   := {}
	Local aBanco     := {}
	Local aAvalista  := {}
	Local aSacado    := {}
	Local aTitulo    := {}
	Local cAliasSE1  := GetNextAlias()
	Local cPorBco    := ""
	Local cPorAgc    := ""
	Local cPorCta    := ""
	Local cPorSub    := ""
	Local lNrEnd     := (SA1->(FieldPos("A1_NR_END"))  > 0)
	Local lNrEndC    := (SA1->(FieldPos("A1_NR_ENDC")) > 0)
	Local lComplC    := (SA1->(FieldPos("A1_COMPLEC")) > 0)
	Local lEmailBl   := (SA1->(FieldPos("A1_EMAILBL")) > 0)
	Local lImpAbat	 := (SA1->(FieldPos("A1_IMPABAT")) > 0)
	Local lAbatcli	 := .F.
	Local lStart     := .T.
	Local aTitMail   := {}
	Local aSegVia     := {}
	Local lReimprime := .T.
	Local nMsg       := 0

	Local cTempPath	:= IIf( IsBlind(), "\boletos\tmp\", GetTempPath() )
	Local cBolPath	:= "\boletos\"

	Local nValorImp	:= 0
	Local lVlrOrigi	:= GetMv("CI_MVALIMP") = 1
	Local lErrSaldo	:= .F. //Variavel para tratamentos de erro de saldo AP�S a query
	Local cTitLiq	:= ""
	Local cMsgErr	:= ""

	Private lValidBco	:= SuperGetMV("CI_MBOL02", .F., .T.)
	Private lMensRecibo	:= SuperGetMV("CI_MBOL03", .F., .F.)

	Private nDadBenf  := SuperGetMV("CI_MBOL01", .T., 2) // No caso de Banco correpondente imprime dados no beneficiario do Banco ou do beneficiario
	//IATAN EM 27/08/2022
	IF IsInCallStack("U_GERADANFE") .OR. IsInCallStack("U_GRDANFE2") 
		cBolPath := "\pdf_wms\boleto\"
	ENDIF

	If	!File( cBolPath+"." )
		MakeDir( cBolPath )
	EndIf

	If	!File( cTempPath+"." )
		MakeDir( cTempPath )
	EndIf

	//�������������������������������Ŀ
	//�Valida Cedente                 �
	//�e Carrega Dados Array aCedente �
	//���������������������������������

	If !lBCLI
		F001Cedente( @aCedente,Nil )
	EndIf

	//�������������������������������Ŀ
	//�Valida Banco                   �
	//�e Carrega Dados Array aBanco   �
	//���������������������������������
	If lSegundaVia

		If nSegVia = 1
			F001Banco( @aBanco, nil )
		EndIf

	Else
		F001Banco( @aBanco, nil )
	EndIf


	cQuery := "SELECT "
	If lBCLI
		cQuery +=       " DISTINCT(SEE.EE_CODIGO) BANCO, "
	EndIf
	cQuery +=       " E1_FILIAL, E1_TIPO, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_CLIENTE, E1_LOJA "
	cQuery +=       " ,E1_EMISSAO, E1_VENCTO, E1_VENCREA, E1_MOEDA "
	cQuery +=       " ,E1_NUMBCO, E1_PORTADO, E1_NUMBOR "
	cQuery +=       " ,E1_NUMNOTA, E1_SERIE "
	cQuery +=       " ,E1_VALOR, E1_SALDO ,E1_VLCRUZ  "
	cQuery +=       " ,E1_DECRESC, E1_SDDECRE, E1_ACRESC, E1_SDACRES "
	cQuery +=       " ,E1_MULTA, E1_JUROS "
	cQuery +=       " ,E1_IRRF, E1_ISS, E1_INSS, E1_PIS, E1_COFINS, E1_CSLL ,E1_CODCART"
	cQuery +=       IIf(lForma," ,E1_FORMA ", "")
	cQuery +=       " ,SE1.R_E_C_N_O_ AS E1_RECNO "
	cQuery +=       " ,A1_COD, A1_LOJA, A1_NOME, A1_PESSOA, A1_CGC "
	cQuery +=       " ,A1_END "
	cQuery +=       IIf(lNrEnd, ", A1_NR_END", "")
	cQuery +=       " ,A1_COMPLEM, A1_MUN, A1_EST, A1_CEP, A1_BAIRRO "
	cQuery +=       " ,A1_ENDCOB "
	cQuery +=       IIf(lNrEndC, ", A1_NR_ENDC", "")
	cQuery +=       IIf(lComplC, ", A1_COMPLEC", "")
	cQuery +=       " ,A1_MUNC, A1_ESTC, A1_BAIRROC, A1_CEPC "
	cQuery +=       " ,A1_BCO1 "
	cQuery +=       " ,A1_CONTATO "
	cQuery +=       " ,A1_EMAIL "
	cQuery +=       IIf(lEmailBl, ", A1_EMAILBL", "")
	cQuery +=       IIf(lEmailBl, ", A1_ZEMAOPM", "")

	If nSegVia = 2
		cQuery +=		" ,E1_PORBCO, E1_PORAGC, E1_PORCTA, E1_PORSUB, E1_PORDVA, E1_PORDVC "
	EndIf

	cQuery +=       " ,SA1.R_E_C_N_O_ AS A1_RECNO "
	cQuery += "FROM " + RetSqlName("SE1") + " SE1, "
	cQuery +=           RetSqlName("SA1") + " SA1 "

	If lBCLI
		cQuery += BCCLI('INNER')
	EndIf

	cQuery += "WHERE SE1.E1_FILIAL  =  '" + xFilial("SE1")    + "' "
	cQuery += "AND   SE1.E1_PREFIXO >= '" + cDoPrefixo        + "' "
	cQuery += "AND   SE1.E1_PREFIXO <= '" + cAtePrefixo       + "' "
	cQuery += "AND   SE1.E1_NUM     >= '" + cDoNum            + "' "
	cQuery += "AND   SE1.E1_NUM     <= '" + cAteNum           + "' "
	cQuery += "AND   SE1.E1_PARCELA >= '" + cDaParcela        + "' "
	cQuery += "AND   SE1.E1_PARCELA <= '" + cAteParcel       + "' "
	cQuery += "AND   SE1.E1_TIPO    >= '" + cDoTipo           + "' "
	cQuery += "AND   SE1.E1_TIPO    <= '" + cAteTipo          + "' "
	cQuery += "AND   SE1.E1_TIPO    NOT IN " + FormatIn(MVPROVIS+"|"+MVABATIM,"|")

	If lValidBco

		// Se � Segunda Via (2-Sim) e os campos customizados para a Segunda Via foram criados , considera os mesmos. 
		// Se n�o � Segunda Via (1 - N�o) e os campos customizados para a Segunda Via foram criados, busca apenas titulos n�o impressos.
		// Se os campos n�o foram criados busca informa��es banc�rias do pergunte.

		If lSegundaVia  .AND. nSegVia = 2

			cQuery += "AND  SE1.E1_PORTADO <> '' "
			cQuery += "AND  SE1.E1_PORBCO  <> '' "

		ElseIf lSegundaVia  .AND. nSegVia = 1
			cQuery += "AND  (SE1.E1_PORTADO = '' OR "
			cQuery += "      SE1.E1_PORTADO = "+IIF(lBCLI,"SEE.EE_CODIGO","'"+cBanco+"'") + " ) "
		Else

			cQuery += "AND  (SE1.E1_PORTADO =  '' OR "
			cQuery += "     SE1.E1_PORTADO = "+IIF(lBCLI,"SEE.EE_CODIGO","'"+cBanco+"'") + " ) "

		EndIf

		// Se � Segunda Via e os campos customizados para a Segunda Via foram criados , considera. Se os campos n�o foram criados
		// e n�o � Segunda Via busca informa��es banc�rias do pergunte
		If !lSegundaVia .AND. !lBCLI
			cQuery += "AND  (SE1.E1_CODCART =  '' OR "
			cQuery += "      SE1.E1_CODCART =  '" + aBanco[BCO_CARTEIR]  + "') "
		EndIf

	Else 
		
		If lSegundaVia  .AND. nSegVia = 2

			cQuery += "AND  SE1.E1_PORTADO <> '' "
			cQuery += "AND  SE1.E1_PORBCO  <> '' "

		EndIf

	Endif

	If	!(lPosicionado)

		cQuery += "AND   SE1.E1_EMISSAO >= '" + DToS(dDaEmissao)  + "' "
		cQuery += "AND   SE1.E1_EMISSAO <= '" + DToS(dAteEmissao) + "' "
		cQuery += "AND   SE1.E1_VENCREA >= '" + DToS(dDoVencRea)  + "' "
		cQuery += "AND   SE1.E1_VENCREA <= '" + DToS(dAteVencRea) + "' "
		cQuery += "AND   SE1.E1_NUMBOR  >= '" + cDoNumBor         + "' "
		cQuery += "AND   SE1.E1_NUMBOR  <= '" + cAteNumBor        + "' "
		cQuery += "AND   SE1.E1_CLIENTE >= '" + cDoCliente        + "' "
		cQuery += "AND   SE1.E1_CLIENTE <= '" + cAteCliente       + "' "
		cQuery += "AND   SE1.E1_LOJA    >= '" + cDaLoja           + "' "
		cQuery += "AND   SE1.E1_LOJA    <= '" + cAteLoja          + "' "

		If lForma
			cQuery += "AND   SE1.E1_FORMA    IN " + FormatIn(Alltrim(cForma), ";")
		EndIf

	EndIf

	cQuery += "AND   SE1.D_E_L_E_T_ <> '*'  "
	cQuery += "AND   SA1.A1_FILIAL  =  '" + xFilial("SA1") + "' "
	cQuery += "AND   SA1.A1_COD     =  SE1.E1_CLIENTE "
	cQuery += "AND   SA1.A1_LOJA    =  SE1.E1_LOJA "
	cQuery += "AND   SA1.D_E_L_E_T_ <> '*'  "
	
	if !lBCLI
		cQuery += "ORDER BY E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO "
    Else
		cQuery += "ORDER BY E1_FILIAL,E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO "    
    Endif
   
	cQuery := ChangeQuery(cQuery)

	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery), cAliasSE1, .T., .T. )
	TCSetField( cAliasSE1, "E1_EMISSAO", "D", 8, 0 )
	TCSetField( cAliasSE1, "E1_VENCTO" , "D", 8, 0 )
	TCSetField( cAliasSE1, "E1_VENCREA", "D", 8, 0 )

	DbSelectArea(cAliasSE1)
	Count to nReg
	DbGoTop()

	ProcRegua(nReg)

	If	!((cAliasSE1)->(EOF()))


		//����������������������������������������������������Ŀ
		//� Chama a SumAbatRec para abrir alias auxiliar __SE1 �
		//������������������������������������������������������
			
		If	Select("__SE1") == 0
			SumAbatRec("","","",1,"")
		EndIf

		Do While !( (cAliasSE1)->(EOF()) )


			If	nTipoPDF = 1 .Or. !lIniImp

				lContinua := F001IniImp( @oBoleto, @oSetup, @lExistBol, @lBlind, aBanco, Array(TAM_TIT), aSacado )

			EndIf

			If	!lContinua
				Exit
			EndIf

			If		nTipoPDF = 1 //-- Arquivo unico

					cCpoQuebra := "(E1_FILIAL)"
					cCntQuebra := (cAliasSE1)->(E1_FILIAL)

			ElseIf	nTipoPDF = 2 //-- Por Cliente

					cCpoQuebra := "(E1_FILIAL+E1_CLIENTE+E1_LOJA)"
					cCntQuebra := (cAliasSE1)->(E1_FILIAL+E1_CLIENTE+E1_LOJA)

			ElseIf	nTipoPDF = 3 //-- Por Titulo

					cCpoQuebra := "(E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM)"
					cCntQuebra := (cAliasSE1)->(E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM)

			EndIf

			Do While (cAliasSE1)->&(cCpoQuebra) == cCntQuebra .And. !((cAliasSE1)->(EOF()))

				 If lBCLI

				 	If nSegVia == 1
		    	        dbSelectArea("SEE")
			            dbSetOrder(1)
			            dbSeek(xFilial("SEE")+(cAliasSE1)->BANCO)

			            cBanco   := SEE->EE_CODIGO
						cAgencia := SEE->EE_AGENCIA
						cConta   := SEE->EE_CONTA
						cSubCta  := SEE->EE_SUBCTA
					Else
						cBanco := (cAliasSE1)->(E1_PORBCO)
						cAgencia := (cAliasSE1)->(E1_PORAGC)
						cConta := (cAliasSE1)->(E1_PORCTA)
						cSubCta := (cAliasSE1)->(E1_PORSUB)
					EndIf

					
					//�������������������������������Ŀ
					//�Valida Cedente                 �
					//�e Carrega Dados Array aCedente �
					//���������������������������������

					F001Cedente( @aCedente,Nil )

	    	        F001Banco( @aBanco, nil )

	        	    If !Empty((cAliasSE1)->(E1_CODCART))
	        	    	If (cAliasSE1)->(E1_CODCART) <> aBanco[BCO_CARTEIR]
	        	    		(cAliasSE1)->(dbSkip())
	        	    		loop
	        	    	EndIf
		           EndIf

				EndIf

				If nSegVia = 2

					aSegVia := {}

					cPorBco := (cAliasSE1)->(E1_PORBCO)
					cPorAgc := (cAliasSE1)->(E1_PORAGC)
					cPorCta := (cAliasSE1)->(E1_PORCTA)
					cPorSub := (cAliasSE1)->(E1_PORSUB)

					aAdd(aSegVia, cPorBco)
					aAdd(aSegVia, cPorAgc)
					aAdd(aSegVia, cPorCta)
					aAdd(aSegVia, cPorSub)

					F001Banco(@aBanco, aSegVia)
					F001Cedente(@aCedente,aSegVia)

				EndIf

				IncProc()

				//�������������������������������������������������������������������������������������Ŀ
				//� Posiciono no Registro Correspondente do SE1 e no SA1                                �
				//� para perfeito executar as formulas das Mensagens.                                   �
				//���������������������������������������������������������������������������������������
				dbSelectArea("SE1")
				dbGoTo((cAliasSE1)->E1_RECNO)

				dbSelectArea("SA1")
				dbGoTo((cAliasSE1)->A1_RECNO)

				If lImpAbat
					lAbatCli := ( (SA1->A1_IMPABAT="S") .Or. Empty( SA1->A1_IMPABAT ) )
				EndIf

				If	SE1->E1_ORIGEM = 'MATA460'

					dbSelectArea("SF2")
					dbSetOrder(2)	//-- F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_DOC+F2_SERIE
					dbSeek( xFilial("SF2") + (cAliasSE1)->A1_COD + (cAliasSE1)->A1_LOJA + (cAliasSE1)->E1_NUM + (cAliasSE1)->E1_SERIE )

				EndIf

				//�������������������������������Ŀ
				//� Carrega Dados Array aSacado   �
				//���������������������������������
				aSacado := Array(TAM_SAC)
				aSacado[SAC_NOME] := IIf(lAmbHml, "Cliente Teste", (cAliasSE1)->A1_NOME)									//-- Razao Social
				aSacado[SAC_CNPJ] := TransForm((cAliasSE1)->A1_CGC, IIf((cAliasSE1)->A1_PESSOA = "J", PICT_CNPJ, PICT_CPF))	//-- CNPJ/CPF

				aSacado[SAC_CONTATO] := IIf(lAmbHml, "Contato Teste", (cAliasSE1)->A1_CONTATO)							//-- Contato

				If	lEmailBl
					// Especifico MA A1_ZEMAOPM
					If	!Empty( (cAliasSE1)->A1_ZEMAOPM )
						aSacado[SAC_EMAIL] := Lower(AllTrim((cAliasSE1)->A1_ZEMAOPM))									//-- Email Especifico P/ Boletos
					Else

						If	!Empty( (cAliasSE1)->A1_EMAILBL )
							aSacado[SAC_EMAIL] := Lower(AllTrim((cAliasSE1)->A1_EMAILBL))									//-- Email Especifico P/ Boletos
						Else
							aSacado[SAC_EMAIL] := Lower(AllTrim((cAliasSE1)->A1_EMAIL))										//-- Email Cadastro
						EndIf

					Endif 
				Else
					aSacado[SAC_EMAIL] := Lower(AllTrim((cAliasSE1)->A1_EMAIL))											//-- Email Cadastro
				EndIf

				If	!Empty((cAliasSE1)->A1_ENDCOB)
					aSacado[SAC_END] := AllTrim((cAliasSE1)->A1_ENDCOB)												//-- Endereco
					If	lNrEndC .And. !Empty((cAliasSE1)->A1_NR_ENDC) .And. !( AllTrim((cAliasSE1)->A1_NR_ENDC) $ aSacado[SAC_END] )
						aSacado[SAC_END] += ", " + AllTrim((cAliasSE1)->A1_NR_ENDC)									//-- Numero do Endereco
					EndIf

					If	lComplC
						aSacado[SAC_END] += IIf( !Empty((cAliasSE1)->A1_COMPLEC)," - "+AllTrim((cAliasSE1)->A1_COMPLEC),"")	//-- Complemento do Endereco
					EndIf

					aSacado[SAC_END] += IIf( !Empty((cAliasSE1)->A1_BAIRROC)," - "+AllTrim((cAliasSE1)->A1_BAIRROC),"")	//-- Bairro
					aSacado[SAC_END] += " - " + AllTrim((cAliasSE1)->A1_MUNC)										//-- Cidade
					aSacado[SAC_END] += "-"   + AllTrim((cAliasSE1)->A1_ESTC)										//-- Estado
					aSacado[SAC_END] += "  CEP: " + TransForm((cAliasSE1)->A1_CEPC,PICT_CEP)							//-- CEP
				Else
					aSacado[SAC_END] := AllTrim((cAliasSE1)->A1_END)													//-- Endereco

					If	lNrEnd .And. !Empty((cAliasSE1)->A1_NR_END) .And. !( AllTrim((cAliasSE1)->A1_NR_END) $ aSacado[SAC_END] )
						aSacado[SAC_END] += ", " + AllTrim((cAliasSE1)->A1_NR_END)									//-- Numero do Endereco
					EndIf

					aSacado[SAC_END] += IIf( !Empty((cAliasSE1)->A1_COMPLEM)," - "+AllTrim((cAliasSE1)->A1_COMPLEM),"")	//-- Complemento do Endereco
					aSacado[SAC_END] += IIf( !Empty((cAliasSE1)->A1_BAIRRO)," - "+AllTrim((cAliasSE1)->A1_BAIRRO),"")		//-- Bairro
					aSacado[SAC_END] += " - " + AllTrim((cAliasSE1)->A1_MUN)											//-- Cidade
					aSacado[SAC_END] += "-"   + AllTrim((cAliasSE1)->A1_EST)											//-- Estado
					aSacado[SAC_END] += "  CEP: " + TransForm((cAliasSE1)->A1_CEP,PICT_CEP)							//-- CEP
				EndIf

				//-- SumAbatRec( cPrefixo,cNumero,cParcela,nMoeda,cCpo,dData,nTotAbImp,nTotIrAbt,nTotCsAbt,nTotPisAbt,nTotCofAbt,nTotInsAbt,cFilAbat)
				nTotAbImp  := 0
				nTotIrAbt  := 0
				nTotCsAbt  := 0
				nTotPisAbt := 0
				nTotCofAbt := 0
				nTotInsAbt := 0
				nTotIssAbt := 0
				nTotTitAbt := 0

				nValorImp  := If(lVlrOrigi, (cAliasSE1)->E1_VLCRUZ, xMoeda((cAliasSE1)->E1_SALDO,(cAliasSE1)->E1_MOEDA,1,DdataBase) )

				nValAbat := SumAbatRec( (cAliasSE1)->E1_PREFIXO, (cAliasSE1)->E1_NUM, (cAliasSE1)->E1_PARCELA, (cAliasSE1)->E1_MOEDA, "S", dDataBase, @nTotAbImp, @nTotIrAbt, @nTotCsAbt, @nTotPisAbt, @nTotCofAbt, @nTotInsAbt, @nTotIssAbt, @nTotTitAbt )
				nSaldo   := nValorImp - (cAliasSE1)->E1_DECRESC + (cAliasSE1)->E1_ACRESC
				nSaldo   := nSaldo - nValAbat

				aTitulo := Array(TAM_TIT)
				aTitulo[TIT_PREF]   := (cAliasSE1)->E1_PREFIXO					//-- Prefixo da NF
				aTitulo[TIT_NUM]    := (cAliasSE1)->E1_PREFIXO
				aTitulo[TIT_NUM]    += " " + (cAliasSE1)->E1_NUM
				aTitulo[TIT_NUM]    += " " + (cAliasSE1)->E1_PARCELA 			//-- Prefixo/Numero/Parcela do Titulo
				aTitulo[TIT_DTEMI]  := DTOC((cAliasSE1)->E1_EMISSAO)			//-- Data Emissao Titulo
				aTitulo[TIT_DTPROC] := DTOC(MsDate())							//-- Data Emissao Boleto
				If aBanco[BCO_MBCARD] = "1"
					aTitulo[TIT_DTVCTO] := DTOC((cAliasSE1)->E1_VENCTO)			//-- Data Vencimento
				Else
					aTitulo[TIT_DTVCTO] := DTOC((cAliasSE1)->E1_VENCREA)			//-- Data Vencimento
	            Endif
				aTitulo[TIT_VALOR]  := nSaldo									//-- Valor do Titulo
				aTitulo[TIT_TIPO]   := (cAliasSE1)->E1_TIPO						//-- Tipo do Titulo
				aTitulo[TIT_IRRF]   := nTotIrAbt								//-- IRRF
				aTitulo[TIT_ISS]    := nTotIssAbt								//-- ISS
				aTitulo[TIT_INSS]   := nTotInsAbt								//-- INSS
				aTitulo[TIT_PIS]    := nTotPisAbt								//-- PIS
				aTitulo[TIT_COFINS] := nTotCofAbt								//-- COFINS
				aTitulo[TIT_CSLL]   := nTotCsAbt								//-- CSLL
				aTitulo[TIT_DECRES] := (cAliasSE1)->E1_DECRESC					//-- Decrescimos
				aTitulo[TIT_ACRESC] := (cAliasSE1)->E1_ACRESC						//-- Acrescimos
				aTitulo[TIT_ABATIM] := nTotTitAbt								//-- Abatimentos (AB-)
				aTitulo[TIT_RECSE1] := (cAliasSE1)->E1_RECNO						//-- Recno do Titulo no SE1
				aTitulo[TIT_RECSA1] := (cAliasSE1)->A1_RECNO						//-- Recno do Titulo no SA1

				If	!Empty(SEE->EE_NUMTIT)

					aTitulo[TIT_NUM] := &(SEE->EE_NUMTIT)

				EndIf

/*
				If 		aBanco[BCO_NUMBCO] = CITIBANK

						aTitulo[TIT_NUM] := (cAliasSE1)->E1_PREFIXO + " " + Right( (cAliasSE1)->E1_NUM ,5 ) + "/" + (cAliasSE1)->E1_PARCELA

				EndIf
*/

				If		aBanco[BCO_NUMBCO] = HSBC

					aTitulo[TIT_ESPECIE] := "PD"							//-- Especie Documento

				ElseIf aBanco[BCO_NUMBCO] = CITIBANK


					aTitulo[TIT_ESPECIE] := "DMI"                           //-- Especie Documento

				ElseIf aBanco[BCO_NUMBCO] = SICREDI

					aTitulo[TIT_ESPECIE] := "DMI"                           //-- Especie Documento

				ElseIf aBanco[BCO_MBCARD]= "1"

					aTitulo[TIT_ESPECIE] := "Recibo"                           //-- Especie Documento - MBCAD
				Else

					aTitulo[TIT_ESPECIE] := "DM"							//-- Especie Documento

				EndIf

				//�������������������������������Ŀ
				//� Carrega Dados Array aAvalista �
				//���������������������������������
				F001Avalista( @aAvalista, @aCedente, aSacado, aBanco, aTitulo )

				//-- Mensagens para o Boleto
				aMsgBol  := {}
				If	lAmbHml
					cMsg := "* * * BOLETO EMITIDO PARA HOMOLOGA��O DE IMPRESS�O, SEM VALOR COMERCIAL * * *"
					aAdd( aMsgBol, cMsg )
				EndIf

				For nMsg := BCO_MSG1 To BCO_MSG6
					If	!Empty(aBanco[nMsg])
						cMsg := &(aBanco[nMsg])
						If	!Empty(cMsg)
							aAdd( aMsgBol, cMsg )
						EndIf
					EndIf
				Next nMsg

				//������������������������������������������������������������������������������������������������Ŀ
				//� Mensagens demosntrativas                                                                       �
				//� Deducoes, Impostos, Abatimentos (AB-), Acrescimos e Descrescimos                               �
				//� Posiciona nas duas ultimas linhas das Mensagens                                                �
				//��������������������������������������������������������������������������������������������������
				If	aTitulo[TIT_PIS] + aTitulo[TIT_COFINS] + aTitulo[TIT_CSLL] + aTitulo[TIT_IRRF] + aTitulo[TIT_ISS] + aTitulo[TIT_INSS] > 0
						cMsg := ""
						cMsg += "Dedu��es/Impostos: "
						If	aTitulo[TIT_PIS] > 0
							cMsg += "PIS: " + AllTrim(F001FormVal(aTitulo[TIT_PIS])) + " "
						EndIf
						If	aTitulo[TIT_COFINS] > 0
							cMsg += "COFINS: " + AllTrim(F001FormVal(aTitulo[TIT_COFINS])) + " "
						EndIf
						If	aTitulo[TIT_CSLL] > 0
							cMsg += "CSLL: " + AllTrim(F001FormVal(aTitulo[TIT_CSLL])) + " "
						EndIf
						If	aTitulo[TIT_IRRF] > 0
							cMsg += "IR: " + AllTrim(F001FormVal(aTitulo[TIT_IRRF])) + " "
						EndIf
						If	aTitulo[TIT_ISS] > 0
							cMsg += "ISS: " + AllTrim(F001FormVal(aTitulo[TIT_ISS])) + " "
						EndIf
						If	aTitulo[TIT_INSS] > 0
							cMsg += "INSS: " + AllTrim(F001FormVal(aTitulo[TIT_INSS])) + " "
						EndIf
						aAdd( aMsgBol, cMsg )
				EndIf

				cMsg := ""
				If	aTitulo[TIT_ABATIM] + aTitulo[TIT_DECRES] > 0

					If lAbatCli
						cMsg += "Abatimentos/Decrescimos: "
						cMsg += AllTrim( F001FormVal(aTitulo[TIT_ABATIM] + aTitulo[TIT_DECRES])) + "  "
					EndIf

				EndIf

				If	aTitulo[TIT_ACRESC] > 0
					cMsg += "Acrescimos: "
					cMsg += AllTrim( F001FormVal(aTitulo[TIT_ACRESC]) ) + "  "
				EndIf
				aAdd( aMsgBol, cMsg )

				//�������������������������������������������������������������������������������������Ŀ
				//� Adiciona linhas em branco ate Limte do Tamanho do Quadro de Mensagens               �
				//���������������������������������������������������������������������������������������
 				For	 nMsg := (Len(aMsgBol)+1) To 9
					aAdd( aMsgBol, "" )
				Next nMsg

				aTitulo[TIT_MSGS]   := aMsgBol									//-- Mensagens / Instrucoes

				If Empty(aBanco[BCO_LOCPAG]) .And. Empty(aBanco[BCO_NOMCOR])

					aTitulo[TIT_LOCPAG] := {"AT� O VENCIMENTO PAGUE PREFERENCIALMENTE NO " + aBanco[BCO_NOMBCO],;
											"AP�S O VENCIMENTO PAGUE SOMENTE NO " + aBanco[BCO_NOMBCO]}

				ElseIf Empty(aBanco[BCO_LOCPAG]) .And. !Empty(aBanco[BCO_NOMCOR])

					aTitulo[TIT_LOCPAG] := {"AT� O VENCIMENTO PAGUE PREFERENCIALMENTE NO " + aBanco[BCO_NOMCOR],;
											"AP�S O VENCIMENTO PAGUE SOMENTE NO " + aBanco[BCO_NOMCOR]}

				Else

					aTitulo[TIT_LOCPAG]	:= {aBanco[BCO_LOCPAG],""}

				EndIf

				//�������������������������������������������������������������������������������������Ŀ
				//� Monta o Nosso Numero e Calcula o Digito Verificador                                 �
				//� Carrega Informacoes nas posicoes do aTitulo                                         �
				//���������������������������������������������������������������������������������������
				F001NNum( aBanco, @aTitulo)

				//�������������������������������������������������������������������������������������Ŀ
				//� Monta o Codigo de Barras e Calcula Digito Verificador                               �
				//� Carrega Informacoes nas posicoes do aTitulo                                         �
				//���������������������������������������������������������������������������������������
				F001CodBar( aBanco, @aTitulo)

				//�������������������������������������������������������������������������������������Ŀ
				//� Monta a Linha Digitavel e Calcula os Digitos Verificadores dos Campos               �
				//� Carrega Informacoes nas posicoes do aTitulo                                         �
				//���������������������������������������������������������������������������������������
				F001LinDig( aBanco, @aTitulo )

				//�������������������������������������������������������������������������������������Ŀ
				//� Grava a Linha Digitavel no banco de dados                                           �
				//���������������������������������������������������������������������������������������

				F001GrvLin ( @aTitulo )

				//�������������������������������������������������������������������������������������Ŀ
				//�                                                                                     �
				//� Funcao que executa Impressao de Boleto Bancario conforme laytout no formato retrato �
				//�                                                                                     �
				//���������������������������������������������������������������������������������������

				aMsgBol := aTitulo[TIT_CODBAR]


				If lValidBco

					If F001ValImp(aTitulo, aBanco) 

						If aTitulo[TIT_VALOR] > 0 //Valida impress�o de t�tulo com valor zerado

							F001Imprime( aCedente, aBanco, aSacado, aAvalista, aTitulo, @oBoleto, @oSetup, @lExistBol, @lStart, cTempPath ,@lBlind)
							aAdd( aTitMail, { aTitulo[TIT_NUM], aTitulo[TIT_DTVCTO], AllTrim(F001FormVal(aTitulo[TIT_VALOR])), aBanco[BCO_NUMBCO] } )

						Else
							If !lBlind //Tratamento de WS
								lErrSaldo := .T.
								cTitLiq += aTitulo[TIT_NUM] + CRLF
							EndIf
						EndIf

					EndIf

				Else 

						If aTitulo[TIT_VALOR] > 0 //Valida impress�o de t�tulo com valor zerado

							F001Imprime( aCedente, aBanco, aSacado, aAvalista, aTitulo, @oBoleto, @oSetup, @lExistBol, @lStart, cTempPath ,@lBlind)
							aAdd( aTitMail, { aTitulo[TIT_NUM], aTitulo[TIT_DTVCTO], AllTrim(F001FormVal(aTitulo[TIT_VALOR])), aBanco[BCO_NUMBCO] } )

						Else
							If !lBlind //Tratamento de WS
								lErrSaldo := .T.
								cTitLiq += aTitulo[TIT_NUM] + CRLF
							EndIf
						EndIf

				Endif
		
				DbSelectArea(cAliasSE1)
				(cAliasSE1)->(dbSkip())

			EndDo

			//IATAN EM 27/08/2022
			If !lBlind .AND. !IsInCallStack("U_GERADANFE") .AND. !IsInCallStack("U_GRDANFE2") 
			//If !lBlind
				If lErrSaldo
					cMsgErr := "Saldo zerado." + CRLF
					cMsgErr += "Os seguintes t�tulos est�o totalmente liquidados:" + CRLF
					cMsgErr += cTitLiq
					Aviso( "CI_F001|SALDO", cMsgErr, {"OK"},2 )
				EndIf
			EndIf


			If	ValType(oBoleto) = "O"

				If	lBlind

					If	lEmail

						If	oBoleto:nDevice = IMP_PDF .And. lExistBol

							oBoleto:Preview()

							cPathPDF  := AllTrim( oBoleto:cPathPDF )
							cFileName := StrTran( Lower( AllTrim( oBoleto:cFileName ) ) , ".rel" , ".pdf" )

							//IATAN EM 27/08/2022
							IF IsInCallStack("U_GERADANFE") .OR. IsInCallStack("U_GRDANFE2") 

							ELSE
								If __CopyFile( cPathPDF + cFileName , cBolPath + cFileName )
									FErase( cPathPDF + cFileName )//Apaga o arquivo
								EndIf
							ENDIF

								aRet := F001Email( aCedente, aSacado, aTitMail, cBolPath + cFileName)

							//IATAN EM 27/08/2022
							IF IsInCallStack("U_GERADANFE") .OR. IsInCallStack("U_GRDANFE2") 

							ELSE
								If aRet[1]
									FErase( cBolPath + cFileName )	//--	Se Envio Ok, Deleta PDF
								Else
									Aviso( "Aten��o!","Falha no Envio do Email" + CRLF + aRet[2], { "OK" } )
								EndIf
							ENDIF

						EndIf

						FreeObj(oBoleto)

						If	ValType(oSetup) = "O"

							FreeObj(oSetup)

						EndIf

						oBoleto   := Nil
						oSetup    := Nil

						lExistBol := .F.
						lIniImp   := .F.
						aTitMail  := {}

					EndIf

				Else

					If	lEmail

						If	oBoleto:nDevice = IMP_PDF .And. lExistBol


							oBoleto:Preview()

							cPathPDF  := AllTrim( oBoleto:cPathPDF )
							cFileName := StrTran( Lower( AllTrim( oBoleto:cFileName ) ) , ".rel" , ".pdf" )
							
							IF IsInCallStack("U_GERADANFE") .OR. IsInCallStack("U_GRDANFE2") 

							ELSE
								If __CopyFile( cPathPDF + cFileName , cBolPath + cFileName )
									FErase( cPathPDF + cFileName )//Apaga o arquivo
								EndIf
							ENDIF

							IF IsInCallStack("U_GERADANFE") .OR. IsInCallStack("U_GRDANFE2") 

								nomeTemp := DTOS(MsDate())+StrTran(Time(),":","")+strtran(alltrim(str(seconds() )),".","")
								__CopyFile( cBolPath + cFileName , "\pdf_wms\boleto_email\" + "boleto_" + nomeTemp + ".pdf" )
								aRet := F001Email( aCedente, aSacado, aTitMail, "\pdf_wms\boleto_email\" + "boleto_" + nomeTemp + ".pdf" )

							ELSE 
								aRet := F001Email( aCedente, aSacado, aTitMail, cBolPath + cFileName)
							ENDIF

							//IATAN EM 27/08/2022
							IF IsInCallStack("U_GERADANFE") .OR. IsInCallStack("U_GRDANFE2") 

							ELSE
								If aRet[1]
									FErase( cBolPath + cFileName )	//--	Se Envio Ok, Deleta PDF
								Else
									Aviso( "Aten��oo!","Falha no Envio do Email" + CRLF + aRet[2], { "OK" } )
								EndIf
							ENDIF
                        Endif
					Else
						If	oBoleto:nDevice = IMP_PDF .And. lExistBol

							oBoleto:Preview()

						EndIf


					EndIf

					If	ValType(oSetup) = "O"

						FreeObj(oSetup)

					EndIf

					oBoleto   := Nil
					oSetup    := Nil

					lExistBol := .F.
					lIniImp   := .F.
					aTitMail  := {}

				EndIf

			EndIf
			(cAliasSE1)->(DbSkip())
		EndDo

	Else
		//IATAN EM 27/08/2022
		IF IsInCallStack("U_GERADANFE") .OR. IsInCallStack("U_GRDANFE2") 

		ELSE
			MsgInfo("Nenhum registro encontrado. Por favor, verifique os par�metros.", "Aten��o")
		ENDIF

	EndIf

	DbSelectArea(cAliasSE1)
	(cAliasSE1)->(DbCloseArea())

Return(Nil)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �F001GrvLin � Autor � Leonir Donatti       � Data �08/01/2016���
�������������������������������������������������������������������������Ĵ��
���Descricao � Grava a linha digit�vel no banco de dados                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� @aTitulo - array com dados a serem gravados                ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Uso       � CI_F001                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function F001GrvLin ( aTitulo )

	Local cLinDig := ""

	cLinDig := STRTRAN( aTitulo[TIT_LINDIG], ".", "" )
	cLinDig := STRTRAN( cLinDig, " ", "" )

	dbSelectArea("SE1")

	RecLock( "SE1",.F. )
		SE1->E1_CODDIG  := cLinDig
	MsUnLock()

Return( Nil )

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �F001Cedente� Autor � Fabio Briddi         � Data � Nov/2013 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Inicializa Array aCedente                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� @aCedente - Array com os dados da Empresa/Filial           ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Uso       � CI_F001                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function F001Cedente( aCedente, aSegVia )

    Local cBOLMBC:= "2" // n�o eh boleto MBCAD
	aCedente := Array(TAM_CED)
	//-- Posiciona SEE - Parametros/Configuracoes de Bancos
	If nSegVia = 2 .and. !aSegVia == NIL
		dbSelectArea("SEE")
		dbSeek(xFilial("SEE") + aSegVia[1] + aSegVia[2] + aSegVia[3] + aSegVia[4] )
	Else
		DbSelectArea("SEE")
		DbSetOrder(1)
		DbSeek(xFilial("SEE") + cBanco + cAgencia + cConta + cSubCta)

   Endif

	IF SEE->( FieldPos("EE_BOLMBCA")) > 0

       IF SEE->EE_BOLMBCA = "1" // Se n�o for MBCAD

          cBOLMBC:= "1"
       Else

          cBOLMBC:= "2"
       Endif
   Endif

    If cBolMBC <> "1"

		SM0->(DbSeek(cEmpAnt+cFilAnt))

		aCedente[CED_NOME] := IIf(lAmbHml,"Empresa Teste",AllTrim(SM0->M0_NOMECOM))				//-- Nome da Empresa
		aCedente[CED_CNPJ] := TransForm(SM0->M0_CGC,PICT_CNPJ)									//-- CNPJ
		aCedente[CED_END]  :=  AllTrim(SM0->M0_ENDCOB)											//-- Endereco
		aCedente[CED_END]  +=  IIf( !Empty(SM0->M0_COMPCOB)," - "+AllTrim(SM0->M0_COMPCOB),"")	//-- Complemento do Endereco
		aCedente[CED_END]  +=  IIf( !Empty(SM0->M0_BAIRCOB)," - "+AllTrim(SM0->M0_BAIRCOB),"")	//-- Bairro
		aCedente[CED_END]  +=  " - " + AllTrim(SM0->M0_CIDCOB)									//-- Cidade
		aCedente[CED_END]  +=  "-" + SM0->M0_ESTCOB												//-- Estado
		aCedente[CED_END]  +=  " CEP: " + TransForm(SM0->M0_CEPCOB,PICT_CEP)					//-- CEP

    Else

			If SEE->( FieldPos("EE_BENFMB")) > 0  .AND.;
			   SEE->( FieldPos("EE_CNPJMB")) > 0 .AND.;
		       SEE->( FieldPos("EE_ENDMB")) > 0 .AND. ;
		       SEE->( FieldPos("EE_COMPMB")) > 0 .AND.;
			   SEE->( FieldPos("EE_BAIMB")) > 0 .AND. ;
			   SEE->( FieldPos("EE_MUNMB")) > 0 .AND.;
			   SEE->( FieldPos("EE_ESTMB")) > 0 .AND.;
			   SEE->( FieldPos("EE_CEPMB")) > 0




			  	aCedente[CED_NOME] := SEE->EE_BENFMB	//-- Nome da Empresa
				aCedente[CED_CNPJ] := SEE->EE_CNPJMB	//-- CNPJ
				aCedente[CED_END]  := IIF(!Empty(alltrim(SEE->EE_ENDMB)),alltrim(SEE->EE_ENDMB),"")		//-- Endereco
				aCedente[CED_END]  += IIF(!Empty(alltrim(SEE->EE_COMPMB))," - " +alltrim(SEE->EE_COMPMB),"")   	//-- Complemento do Endereco
				aCedente[CED_END]  += IIF(!Empty(alltrim(SEE->EE_BAIMB))," - "+alltrim(SEE->EE_BAIMB),"")		//-- Bairro
				aCedente[CED_END]  += IIF(!Empty(alltrim(SEE->EE_MUNMB))," - "+alltrim(SEE->EE_MUNMB),"")		//-- Cidade
				aCedente[CED_END]  += IIF(!Empty(alltrim(SEE->EE_ESTMB))," - " + alltrim(SEE->EE_ESTMB),"")		//-- Estado
				aCedente[CED_END]  += IIF(!Empty(alltrim(SEE->EE_CEPMB))," - " +alltrim(SEE->EE_CEPMB),"")		//-- CEP

           Else



   			   		aCedente[CED_NOME] := "Inclua campos MBCAD"	//-- Nome da Empresa
					aCedente[CED_CNPJ] := ""    	//-- CNPJ
					aCedente[CED_END]  := ""		//-- Endereco
					aCedente[CED_END]  += ""    	//-- Complemento do Endereco
					aCedente[CED_END]  += ""		//-- Bairro
					aCedente[CED_END]  += ""		//-- Cidade
					aCedente[CED_END]  += ""		//-- Estado
					aCedente[CED_END]  += ""		//-- CEP
			Endif // Se campos incluidos no dicion�rio


  Endif
Return( )

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �F001Banco  � Autor � Fabio Briddi         � Data � Nov/2013 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Inicializa Array aBanco                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� @aBanco  - Array com os dados do Banco Selecionado         ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Uso       � CI_F001                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function F001Banco( aBanco, aSegVia )

	Local cBcoCorr := ""
    Local cBOLMBC:= "2" // n�o eh boleto MBCAD

	aBanco := Array(TAM_BCO)

	nPosBcoHml := aScan( BANCO_HML, {|x| x[1] == cBanco } )
	If nSegVia = 2 .AND. aSegVia != Nil
		dbSelectArea("SEE")
		dbSeek(xFilial("SEE") + aSegVia[1] + aSegVia[2] + aSegVia[3] + aSegVia[4] )
	EndIf
	IF SEE->( FieldPos("EE_BOLMBCA")) > 0

       IF SEE->EE_BOLMBCA = "1" // Se n�o for MBCAD

          cBOLMBC:= "1"
       Else

          cBOLMBC:= "2"
       Endif
   Endif

	cBcoCorr := AllTrim(SEE->EE_CODCOR)

	aBanco[BCO_NUMBCO]  := AllTrim(SEE->EE_CODIGO) //-- Numero Banco no BACEN
	aBanco[BCO_DVBCO]   := BANCO_HML[nPosBcoHml,2]	//-- Digito Banco
	aBanco[BCO_NUMAGE]  := AllTrim(SEE->EE_AGENCIA)//-- Numero Agencia
	aBanco[BCO_DVAGE]   := AllTrim(SEE->EE_DVAGE)	//-- Digito Agencia
	aBanco[BCO_NUMCTA]  := AllTrim(SEE->EE_CONTA)	//-- Numero Conta
	aBanco[BCO_DVCTA]   := AllTrim(SEE->EE_DVCTA)	//-- Digito Conta
	aBanco[BCO_NOMBCO]  := AllTrim(SEE->EE_NOME)	//-- Nome do Banco
	aBanco[BCO_SUBCTA]  := AllTrim(SEE->EE_SUBCTA)	//-- Subconta
	aBanco[BCO_CODEMP]  := AllTrim(SEE->EE_CODEMP)	//-- Codigo Cedente
	aBanco[BCO_CARTEIR] := AllTrim(SEE->EE_CODCART)//-- Codigo da Carteira
	aBanco[BCO_VARIAC]  := AllTrim(SEE->EE_VARIAC)	//-- Variacao da Carteira
	aBanco[BCO_MSG1]    := AllTrim(SEE->EE_FORMEN1)//-- Formula Mensagem 1
	aBanco[BCO_MSG2]    := AllTrim(SEE->EE_FORMEN2)//-- Formula Mensagem 2
	aBanco[BCO_MSG3]    := AllTrim(SEE->EE_FOREXT1)//-- Formula Mensagem 3
	aBanco[BCO_MSG4]    := AllTrim(SEE->EE_FOREXT2)//-- Formula Mensagem 4
	aBanco[BCO_MSG5]    := AllTrim(SEE->EE_FOREXT3)//-- Formula Mensagem 5
	aBanco[BCO_MSG6]    := AllTrim(SEE->EE_FOREXT4)//-- Formula Mensagem 6
	aBanco[BCO_LOCPAG]  := IIf(SEE->(FieldPos("EE_MSLOCPG"))>0,AllTrim(SEE->EE_MSLOCPG),"") //-- Mensagem Local de Pagamento
	aBanco[BCO_BCOFORM] := "|" + TransForm(AllTrim(aBanco[BCO_NUMBCO]) + aBanco[BCO_DVBCO],PICT_BANCO) + "|"
	aBanco[BCO_AGEFORM] := AllTrim(aBanco[BCO_NUMAGE]) + IIf(!Empty(aBanco[BCO_DVAGE]), "-"+AllTrim(aBanco[BCO_DVAGE]) , "" )
	aBanco[BCO_CTAFORM] := AllTrim(aBanco[BCO_NUMCTA]) + IIf(!Empty(aBanco[BCO_DVCTA]), "-"+AllTrim(aBanco[BCO_DVCTA]) , "" )
	aBanco[BCO_ACEITE]  := SEE->EE_ACEITE //-- Aceite ( S = Sim ou N = Nao )
	IF cBOLMBC = "1"
		aBanco[BCO_USOBCO]  := "8650"  // MBCAD
    ELSE
	    aBanco[BCO_USOBCO]  := If(CITIBANK $ aBanco[BCO_NUMBCO], "CLIENTE", "") //-- Uso exclusivo do Citibank
	ENDIF

	aBanco[BCO_MBCARD]:=cBOLMBC

	If	!Empty(SEE->EE_CODCOR)

		// Banco Correspondente
		nPosBcoHml := aScan( BANCO_HML, {|x| x[1] == cBcoCorr } )
		aBanco[BCO_BCOCOR]  := AllTrim(SEE->EE_CODCOR)  //-- Numero Banco Correspondente no BACEN
		aBanco[BCO_DVBCOR]  := BANCO_HML[nPosBcoHml,2]  //-- Digito Banco Correspondente
		aBanco[BCO_AGECOR]  := AllTrim(SEE->EE_AGECOR)  //-- Numero Agencia Banco Correspondente
		aBanco[BCO_DVAGCO]  := AllTrim(SEE->EE_DVAGCOR) //-- Digito Agencia Banco Correspondente
		aBanco[BCO_NCTACO]  := AllTrim(SEE->EE_CTACOR)  //-- Numero Conta Banco Correspondente
		aBanco[BCO_DVCTCO]  := AllTrim(SEE->EE_DVCTCOR) //-- Digito Conta Banco Correspondente
		aBanco[BCO_NOMCOR]  := AllTrim(SEE->EE_NOMECOR) //-- Nome do Banco Correspondente

	Else

		aBanco[BCO_BCOCOR]  := ""  //-- Numero Banco Correspondente no BACEN
		aBanco[BCO_DVBCOR]  := ""  //-- Digito Banco Correspondente
		aBanco[BCO_AGECOR]  := ""  //-- Numero Agencia Banco Correspondente
		aBanco[BCO_DVAGCO]  := ""  //-- Digito Agencia Banco Correspondente
		aBanco[BCO_NCTACO]  := ""  //-- Numero Conta Banco Correspondente
		aBanco[BCO_DVCTCO]  := ""  //-- Digito Conta Banco Correspondente
		aBanco[BCO_NOMCOR]  := ""  //-- Nome do Banco Correspondente

	EndIf


	If		aBanco[BCO_NUMBCO] = SANTANDER

			aBanco[BCO_AGECTA]  := aBanco[BCO_AGEFORM] +" /  "+ aBanco[BCO_CODEMP]

	ElseIf	aBanco[BCO_NUMBCO] = BANRISUL

			aBanco[BCO_AGECTA] := aBanco[BCO_AGEFORM] + " / " + TransForm(aBanco[BCO_CODEMP],"@R 999999.9.99")

	ElseIf	aBanco[BCO_NUMBCO] = CAIXA

			aBanco[BCO_AGECTA]  := aBanco[BCO_AGEFORM]+"/"+aBanco[BCO_CODEMP] + "-" + Mod11B29(aBanco[BCO_CODEMP])

	ElseIf	aBanco[BCO_NUMBCO] = HSBC

			If	aBanco[BCO_CARTEIR] = "CNR"
				aBanco[BCO_AGECTA]  := aBanco[BCO_CODEMP]
			Else
				aBanco[BCO_AGECTA]  := aBanco[BCO_AGEFORM] +" "+ aBanco[BCO_CODEMP]
			EndIf

	ElseIf	aBanco[BCO_NUMBCO] = SAFRA

			If	aBanco[BCO_CARTEIR] = "09"
				aBanco[BCO_BCOFORM] := "|" + TransForm(AllTrim(aBanco[BCO_BCOCOR]) + aBanco[BCO_DVBCOR],PICT_BANCO) + "|"
				aBanco[BCO_AGEFORM] := AllTrim(aBanco[BCO_AGECOR]) + IIf(!Empty(aBanco[BCO_DVAGCO]), "-"+AllTrim(aBanco[BCO_DVAGCO]) , "" )
				aBanco[BCO_CTAFORM] := AllTrim(aBanco[BCO_NCTACO]) + IIf(!Empty(aBanco[BCO_DVCTCO]), "-"+AllTrim(aBanco[BCO_DVCTCO]) , "" )
			EndIf

			aBanco[BCO_AGECTA]  := aBanco[BCO_AGEFORM] + "/" + aBanco[BCO_CTAFORM]

	ElseIf	aBanco[BCO_NUMBCO] = FIBRA

			If	aBanco[BCO_CARTEIR] = "19"
				aBanco[BCO_BCOFORM] := "|" + TransForm(AllTrim(aBanco[BCO_BCOCOR]) + aBanco[BCO_DVBCOR],PICT_BANCO) + "|"
				aBanco[BCO_AGEFORM] := AllTrim(aBanco[BCO_AGECOR]) + IIf(!Empty(aBanco[BCO_DVAGCO]), "-"+AllTrim(aBanco[BCO_DVAGCO]) , "" )
				aBanco[BCO_CTAFORM] := AllTrim(aBanco[BCO_NCTACO]) + IIf(!Empty(aBanco[BCO_DVCTCO]), "-"+AllTrim(aBanco[BCO_DVCTCO]) , "" )
			EndIf

			aBanco[BCO_AGECTA]  := aBanco[BCO_AGEFORM] + "/" + aBanco[BCO_CTAFORM]

	ElseIf aBanco[BCO_NUMBCO] = SICREDI

			aBanco[BCO_POSTO]   := AllTrim(SEE->EE_POSTO)
			aBanco[BCO_AGECTA]  := aBanco[BCO_NUMAGE] + "." + aBanco[BCO_POSTO] + "." + aBanco[BCO_NUMCTA]

	ElseIf	aBanco[BCO_NUMBCO] = REDASSET

			If	aBanco[BCO_CARTEIR] = "09"
				aBanco[BCO_BCOFORM] := "|" + TransForm(AllTrim(aBanco[BCO_BCOCOR]) + aBanco[BCO_DVBCOR],PICT_BANCO) + "|"
				aBanco[BCO_AGEFORM] := AllTrim(aBanco[BCO_AGECOR]) + IIf(!Empty(aBanco[BCO_DVAGCO]), "-"+AllTrim(aBanco[BCO_DVAGCO]) , "" )
				aBanco[BCO_CTAFORM] := AllTrim(aBanco[BCO_NCTACO]) + IIf(!Empty(aBanco[BCO_DVCTCO]), "-"+AllTrim(aBanco[BCO_DVCTCO]) , "" )
			EndIf

			aBanco[BCO_AGECTA]  := aBanco[BCO_AGEFORM] + "/" + aBanco[BCO_CTAFORM]

	ElseIf	aBanco[BCO_NUMBCO] = BBM

			If	aBanco[BCO_CARTEIR] = "09"
				aBanco[BCO_BCOFORM] := "|" + TransForm(AllTrim(aBanco[BCO_BCOCOR]) + aBanco[BCO_DVBCOR],PICT_BANCO) + "|"
				aBanco[BCO_AGEFORM] := AllTrim(aBanco[BCO_AGECOR]) + IIf(!Empty(aBanco[BCO_DVAGCO]), "-"+AllTrim(aBanco[BCO_DVAGCO]) , "" )
				aBanco[BCO_CTAFORM] := AllTrim(aBanco[BCO_NCTACO]) + IIf(!Empty(aBanco[BCO_DVCTCO]), "-"+AllTrim(aBanco[BCO_DVCTCO]) , "" )
			EndIf

			aBanco[BCO_AGECTA]  := aBanco[BCO_AGEFORM] + "/" + aBanco[BCO_CTAFORM]

	ElseIf aBanco[BCO_NUMBCO] = ABC

			If aBanco[BCO_CARTEIR] = "109" // Banco Correspondente
				aBanco[BCO_BCOFORM] := "|" + TransForm(AllTrim(aBanco[BCO_BCOCOR]) + aBanco[BCO_DVBCOR],PICT_BANCO) + "|"
				aBanco[BCO_AGEFORM] := AllTrim(aBanco[BCO_AGECOR]) + IIf(!Empty(aBanco[BCO_DVAGCO]), "-"+AllTrim(aBanco[BCO_DVAGCO]) , "" )
				aBanco[BCO_CTAFORM] := AllTrim(aBanco[BCO_NCTACO]) + IIf(!Empty(aBanco[BCO_DVCTCO]), "-"+AllTrim(aBanco[BCO_DVCTCO]) , "" )
			EndIf

			aBanco[BCO_AGECTA]  := aBanco[BCO_AGEFORM] + "/" + aBanco[BCO_CTAFORM]

	ElseIf aBanco[BCO_NUMBCO] = VOTORANTIM

			aBanco[BCO_BCOFORM] := "|" + TransForm(AllTrim(aBanco[BCO_BCOCOR]) + aBanco[BCO_DVBCOR],PICT_BANCO) + "|"
			aBanco[BCO_AGEFORM] := AllTrim(aBanco[BCO_AGECOR]) + IIf(!Empty(aBanco[BCO_DVAGCO]), "-"+AllTrim(aBanco[BCO_DVAGCO]) , "" )
			aBanco[BCO_CTAFORM] := AllTrim(aBanco[BCO_NCTACO]) + IIf(!Empty(aBanco[BCO_DVCTCO]), "-"+AllTrim(aBanco[BCO_DVCTCO]) , "" )

			aBanco[BCO_AGECTA]  := aBanco[BCO_AGEFORM] + "/" + aBanco[BCO_CTAFORM]

	ElseIf aBanco[BCO_NUMBCO] = NORDESTE

			aBanco[BCO_AGECTA]  := aBanco[BCO_AGEFORM] + " " + aBanco[BCO_CTAFORM]

	ElseIf aBanco[BCO_NUMBCO] = CITIBANK

			aBanco[BCO_AGECTA] := aBanco[BCO_AGEFORM] + "  " + TransForm(aBanco[BCO_NUMCTA],"@R 9.999999.99") + "." + aBanco[BCO_DVCTA]

	Else

			aBanco[BCO_AGECTA]  := aBanco[BCO_AGEFORM] + "/" + aBanco[BCO_CTAFORM]

	EndIf

Return( )

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �F001Avalista� Autor � Fabio Briddi        � Data � Nov/2013 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Inicializa Array aAvalista                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros� @aAvalista - Array com os dados do Avalista do Titulo      ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Uso       � CI_F001                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function F001Avalista( aAvalista, aCedente, aSacado, aBanco, aTitulo )

	Local l001PeAval := ExistBlock("TF001Aval")

	aAvalista := Array(TAM_AVA)

	aAvalista[AVA_NOME]   := ""	//-- Nome da Empresa
	aAvalista[AVA_CNPJ]   := ""	//-- CNPJ
	aAvalista[AVA_END]    := ""	//-- Endereco
	aAvalista[AVA_COMPL]  := ""	//-- Complemento do Endereco
	aAvalista[AVA_BAIRRO] := ""	//-- Bairro
	aAvalista[AVA_MUN]    := ""	//-- Cidade
	aAvalista[AVA_EST]    := ""	//-- Estado
	aAvalista[AVA_CEP]    := ""	//-- CEP


		// Se o banco correpondente estiver preenchido e o conte�do do parametro for configurado para imprimir os dados do banco correspondente.
	If  !Empty(aBanco[BCO_BCOCOR]).and. nDadBenf = 2 //GetMv("CI_MBOL01")Correspondente

		aAvalista[AVA_NOME]   := AllTrim(SM0->M0_NOMECOM) //aCedente[CED_NOME]	//-- Nome da Empresa - Paola- 10/06/2015- faixa
		aAvalista[AVA_CNPJ]   := TransForm(SM0->M0_CGC,PICT_CNPJ) //aCedente[CED_CNPJ]  //-- CNPJ - Giovanni - 06/11/2015
		aAvalista[AVA_END]    := aCedente[CED_END]	//-- Endereco
		aAvalista[AVA_COMPL]  := aCedente[CED_COMPL]	//-- Complemento do Endereco
		aAvalista[AVA_BAIRRO] := aCedente[CED_BAIRRO]	//-- Bairro
		aAvalista[AVA_MUN]    := aCedente[CED_MUN]	//-- Cidade
		aAvalista[AVA_EST]    := aCedente[CED_EST]	//-- Estado
		aAvalista[AVA_CEP]    := aCedente[CED_CEP]	//-- CEP


		aCedente[CED_NOME]  := aBanco[BCO_NOMBCO]
		aCedente[CED_CNPJ]  := TransForm( AllTrim( SA6->A6_CGC ), PICT_CNPJ )
		aCedente[CED_END]   := AllTrim( SA6->A6_END ) + " - " +;
								  AllTrim( SA6->A6_BAIRRO ) + " - " +;
								  AllTrim( SA6->A6_MUN ) + "-" +;
								  AllTrim( SA6->A6_EST ) + " " +;
								  "CEP " + AllTrim( SA6->A6_CEP )

		aCedente[CED_END]   := If( Empty( SA6->A6_END ),"", aCedente[CED_END])

	EndIf

	If	l001PeAval

		aAvalAux := U_TF001Aval( aAvalista, aSacado, aBanco, aTitulo )

		If	ValType( aAvalAux ) = "A" .And. Len(aAvalAux) = TAM_AVA
			aAvalista := aAvalAux
		EndIf

	EndIF

Return( )

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � F001NNum � Autor � Fabio Briddi          � Data � Nov/2013 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Monta o Nosso Numero e Calcula o Digito Verificador        ���
�������������������������������������������������������������������������Ĵ��
���Parametros� aBanco = Array com Dados do Banco Selecionado              ���
���          � aTitulos = Array com Informacoes do Titulo sendo impresso  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Uso       � CI_F001                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function F001NNum( aBanco,  aTitulo )

	Local aArea      := GetArea()
	Local cNNum      := ""
	Local cDvNNum    := ""
	Local cNNumAux   := ""
	Local cFaixaAtu  := ""
	Local cFaixaProx := ""
	Local cAnoVcto   := ""
	Local cAnoAtual  := ""

	dbSelectArea("SE1")
	SE1->(dbGoTo(aTitulo[TIT_RECSE1]))

	If 	Empty(SE1->E1_NUMBCO) .Or.	Empty(SE1->E1_PORTADO)

		//���������������������������������������������������������Ŀ
		//� Pega a Faixa Atual do Nosso Numero e Calcula a Proxima, �
		//� Salvando no SEE                                         �
		//�����������������������������������������������������������
		dbSelectArea("SEE")
		RecLock("SEE",.F.)
			cFaixaAtu  := AllTrim(SEE->EE_FAXATU)
			cFaixaProx := Soma1(cFaixaAtu)
            SEE->EE_FAXATU := cFaixaProx
		MsUnLock()

		//���������������������������������������������������������Ŀ
		//� Grava Faixa atual do Nosso Numero e Portador no SE1     �
		//�                                                         �
		//� A Gravacao do Nosso numero no SE1 sem o Dig Verificador �
		//� devido aos criterios diferenciados de calculo entre os  �
		//� Bancos. Sao recalculados a cada impressao               �
		//�����������������������������������������������������������

		RecLock("SE1",.F.)

			SE1->E1_PORTADO := SEE->EE_CODIGO //aBanco[BCO_NUMBCO]- Paola - 10/06/2015 - faixa
			SE1->E1_NUMBCO  := cFaixaAtu
			SE1->E1_CODCART := aBanco[BCO_CARTEIR]
			SE1->E1_AGEDEP  := SEE->EE_AGENCIA
			SE1->E1_CONTA   := SEE->EE_CONTA

			//If lSegundaVia

				SE1->E1_PORBCO	:= SEE->EE_CODIGO
				SE1->E1_PORAGC	:= SEE->EE_AGENCIA
				SE1->E1_PORDVA	:= SEE->EE_DVAGE
				SE1->E1_PORCTA	:= SEE->EE_CONTA
				SE1->E1_PORDVC	:= SEE->EE_DVCTA
				SE1->E1_PORSUB	:= SEE->EE_SUBCTA

			//EndIf

		MsUnLock()

	Else


	EndIf

	//���������������������������������������������������������Ŀ
	//� Nesse Ponto deve ser realizado os tratamentos           �
	//� especificos de cada Banco para a Montagem do Nosso      �
	//� Numero e  Calculo do Digito Verificador                 �
	//�����������������������������������������������������������

	If		aBanco[BCO_NUMBCO] = BRASIL

			If		Len( aBanco[BCO_CODEMP] ) = 4

				If Len( AllTrim(SE1->E1_NUMBCO) ) = 5
					cNNum := Right(AllTrim(SE1->E1_NUMBCO),7)
				Else
					cNNum := SubStr(SE1->E1_NUMBCO,1,7)
				EndIf

			ElseIf	Len( aBanco[BCO_CODEMP] ) = 6

				If Len( AllTrim(SE1->E1_NUMBCO) ) = 5
					cNNum := Right(AllTrim(SE1->E1_NUMBCO),5)
				Else
					cNNum := SubStr(SE1->E1_NUMBCO,1,5)
				EndIf

			ElseIf	Len( aBanco[BCO_CODEMP] ) = 7

				cNNum := SubStr(SE1->E1_NUMBCO,1,10)

			EndIf

			//-- Monta String para Calculo do Digito Verificador
			cNNumAux := aBanco[BCO_CODEMP]	//-- Numero da Agencia (4 Digitos)
			cNNumAux += cNNum				//-- Sequencial Nosso Numero

			aTitulo[TIT_NNUM]     := cNNum
			aTitulo[TIT_DVNNUM]   := If( Len(aBanco[BCO_CODEMP]) <> 7, Mod11B92(cNNumAux), "" )
			aTitulo[TIT_NNUMFORM] := aBanco[BCO_CODEMP] + aTitulo[TIT_NNUM]
			aTitulo[TIT_NNUMFORM] += If( Len(aBanco[BCO_CODEMP]) <> 7, "-", "" )
			aTitulo[TIT_NNUMFORM] += If( Val(aTitulo[TIT_DVNNUM]) > 9, "X", aTitulo[TIT_DVNNUM])

			//���������������������������������������������������������Ŀ
			//� Grava Faixa atual do Nosso Numero e Portador no SE1     �
			//�                                                         �
			//� A Gravacao do Nosso numero no SE1 sem o Dig Verificador �
			//� devido aos criterios diferenciados de calculo entre os  �
			//� Bancos. Sao recalculados a cada impressao               �
			//�����������������������������������������������������������

			If Len(aBanco[BCO_CODEMP]) <> 7
				RecLock("SE1",.F.)
					// Tratamento do DV "X" realizado na gravacao do E1_NUMBCO, para evitar erros de conversao
					SE1->E1_NUMBCO  := aTitulo[TIT_NNUM] + If( Val(aTitulo[TIT_DVNNUM]) > 9, "X", aTitulo[TIT_DVNNUM])
				MsUnLock()
			Endif


	ElseIf	aBanco[BCO_NUMBCO] = SANTANDER

			cNNum    := SubStr(SE1->E1_NUMBCO,01,12)
			cDvNNum  := Mod11CB( cNNum , .F. )				//-- Calcula Primeiro DV Nosso Numero (Modulo 11)

			aTitulo[TIT_NNUM]     := cNNum
			aTitulo[TIT_DVNNUM]   := cDvNNum
			aTitulo[TIT_NNUMFORM] := aTitulo[TIT_NNUM] + "-" +aTitulo[TIT_DVNNUM]

			//���������������������������������������������������������Ŀ
			//� Grava Faixa atual do Nosso Numero e Portador no SE1     �
			//�                                                         �
			//� A Gravacao do Nosso numero no SE1 sem o Dig Verificador �
			//� devido aos criterios diferenciados de calculo entre os  �
			//� Bancos. Sao recalculados a cada impressao               �
			//�����������������������������������������������������������
			RecLock("SE1",.F.)
				SE1->E1_NUMBCO  := aTitulo[TIT_NNUM] + aTitulo[TIT_DVNNUM]
			MsUnLock()

	ElseIf	aBanco[BCO_NUMBCO] = BANRISUL

			cNNum    := SubStr(SE1->E1_NUMBCO,01,08)

			cNNumAux := cNNum
			cDv1NNum := Modulo10( cNNumAux )					//-- Calcula Primeiro DV Nosso Numero (Modulo 10)
			cNNumAux := cNNum + cDv1NNum
			cDv2NNum := Mod11B27B( cNNumAux )					//-- Calcula Segundo DV Nosso Numero (Modulo 11)

			aTitulo[TIT_NNUM]     := cNNum
			aTitulo[TIT_DVNNUM]   := cDv2NNum					//-- O DV 1 pode modificar devido o calculo do DV2
																//-- ent�o do DV 2 retorna os dois // Paola -01/2018
			aTitulo[TIT_NNUMFORM] := aTitulo[TIT_NNUM] + "." + aTitulo[TIT_DVNNUM]

			//���������������������������������������������������������Ŀ
			//� Grava Faixa atual do Nosso Numero e Portador no SE1     �
			//�                                                         �
			//� A Gravacao do Nosso numero no SE1 sem o Dig Verificador �
			//� devido aos criterios diferenciados de calculo entre os  �
			//� Bancos. Sao recalculados a cada impressao               �
			//�����������������������������������������������������������
			RecLock("SE1",.F.)
				SE1->E1_NUMBCO  := aTitulo[TIT_NNUM] + aTitulo[TIT_DVNNUM]
			MsUnLock()

	ElseIf	aBanco[BCO_NUMBCO] = CAIXA

			//�����������������������������������������������������������������������������������������������������Ŀ
			//� Para a Caixa o Nosso Numero e tamanho 15, nas primeiras versoes foram alterados os campos para 15. �
			//� Mas, por  de dicionarios em versoes do Protheus passei a tratar somente com 12.             �
			//�������������������������������������������������������������������������������������������������������
			If	(Len(AllTrim(SE1->E1_NUMBCO)) = 12)

				cNNum   := "000" + SE1->E1_NUMBCO
			Else

				cNNum   := SE1->E1_NUMBCO

			EndIf

			//-- Monta String para Calculo do Digito Verificador
			cNNumAux += Iif( aBanco[BCO_CARTEIR] = "RG","1","2")//-- Carteira de Cobranca (1 Digitos)
			cNNumAux += "4"										//-- Emissao do boleto (4-Beneficiario)
			cNNumAux += cNNum									//-- Sequencial Nosso Numero
			cDvNNum := Mod11B29( AllTrim(cNNumAux) )		//-- Calcula DV Nosso Numero

			aTitulo[TIT_NNUM]     := cNNum
			aTitulo[TIT_DVNNUM]   := cDvNNum
			aTitulo[TIT_NNUMFORM] := Iif( aBanco[BCO_CARTEIR] = "RG","1","2") + "4" + aTitulo[TIT_NNUM] + "-" +aTitulo[TIT_DVNNUM]

	ElseIf	aBanco[BCO_NUMBCO] = BRADESCO

			cNNum   := SubStr(SE1->E1_NUMBCO,1,11)

			//-- Monta String para Calculo do Digito Verificador
			cNNumAux += aBanco[BCO_CARTEIR]	//-- Carteira de Cobranca (2 Digitos)
			cNNumAux += cNNum				//-- Sequencial Nosso Numero
			cDvNNum := Mod11B7( cNNumAux )  //-- Calcula DV Nosso Numero

			aTitulo[TIT_NNUM]     := cNNum
			aTitulo[TIT_DVNNUM]   := cDvNNum
			aTitulo[TIT_NNUMFORM] := aBanco[BCO_CARTEIR] + "/" + aTitulo[TIT_NNUM] + "-" + aTitulo[TIT_DVNNUM]

			//���������������������������������������������������������Ŀ
			//� Grava Faixa atual do Nosso Numero e Portador no SE1     �
			//�                                                         �
			//� A Gravacao do Nosso numero no SE1 sem o Dig Verificador �
			//� devido aos criterios diferenciados de calculo entre os  �
			//� Bancos. Sao recalculados a cada impressao               �
			//�                                                         �
			//� Somente para o Bradesco foi alterado para Gravar o DV   �
			//� pois o mesmo e necessario ser enviado via CNAB          �
			//�����������������������������������������������������������
			RecLock("SE1",.F.)
				If aBanco[BCO_MBCARD]= "1"
					SE1->E1_NUMBCO  := aTitulo[TIT_NNUM]
			    Else
		    		SE1->E1_NUMBCO  := aTitulo[TIT_NNUM] + aTitulo[TIT_DVNNUM]
			    Endif
			MsUnLock()

	ElseIf 	aBanco[BCO_NUMBCO] = ITAU

			cNNum   := SubStr(SE1->E1_NUMBCO,1,8)

			//-- Monta String para Calculo do Digito Verificador
			cNNumAux := aBanco[BCO_NUMAGE]	//-- Numero da Agencia (4 Digitos)
			cNNumAux += aBanco[BCO_NUMCTA]	//-- Numero da Conta (5 Digitos)
			cNNumAux += aBanco[BCO_CARTEIR]	//-- Carteira de Cobranca (3 Digitos)
			cNNumAux += cNNum				//-- Sequencial Nosso Numero
			cDvNNum := Modulo10( cNNumAux , aBanco[BCO_NUMBCO])	//-- Calcula DV Nosso Numero

			aTitulo[TIT_NNUM]     := cNNum
			aTitulo[TIT_DVNNUM]   := cDvNNum
			aTitulo[TIT_NNUMFORM] := aBanco[BCO_CARTEIR] + "/" + aTitulo[TIT_NNUM]+"-"+aTitulo[TIT_DVNNUM]

			//���������������������������������������������������������Ŀ
			//� Grava Faixa atual do Nosso Numero e Portador no SE1     �
			//�                                                         �
			//� A Gravacao do Nosso numero no SE1 sem o Dig Verificador �
			//� devido aos criterios diferenciados de calculo entre os  �
			//� Bancos. Sao recalculados a cada impressao               �
			//�                                                         �
			//� Somente para o Bradesco foi alterado para Gravar o DV   �
			//� pois o mesmo e necessario ser enviado via CNAB          �
			//�����������������������������������������������������������
			RecLock("SE1",.F.)
				SE1->E1_NUMBCO  := aTitulo[TIT_NNUM] + aTitulo[TIT_DVNNUM]
			MsUnLock()

	ElseIf	aBanco[BCO_NUMBCO] = HSBC

			If		aBanco[BCO_CARTEIR] = "CNR"

					cNNum    := SubStr(SE1->E1_NUMBCO,01,08)
					cDvNNum1 := Mod11B9(cNNum)      // 1o Digito verificador no Nosso Numero

					cNNumAux := AllTrim( Str( Val( cNNum + cDvNNum1 + "4" ) + Val(aBanco[BCO_CODEMP]) + Val( GravaData( cToD(aTitulo[TIT_DTVCTO]),.F.,1) ) ) )

					cDvNNum2 := Mod11B9( cNNumAux ) // 2o Digito verificador no Nosso Numero

					aTitulo[TIT_NNUM]     := cNNum
					aTitulo[TIT_DVNNUM]   := AllTrim( cDvNNum1 + "4" + cDvNNum2 )
					aTitulo[TIT_NNUMFORM] := aTitulo[TIT_NNUM] + aTitulo[TIT_DVNNUM]

			ElseIf	aBanco[BCO_CARTEIR] = "CSB"

					cNNum    := SubStr(SE1->E1_NUMBCO,01,10)
					cNNumAux := cNNum
					cDvNNum  := Mod11B7(cNNumAux) 	     //Digito verificador no Nosso Numero

					aTitulo[TIT_NNUM]     := cNNum
					aTitulo[TIT_DVNNUM]   := cDvNNum
					aTitulo[TIT_NNUMFORM] := aTitulo[TIT_NNUM] + " " + aTitulo[TIT_DVNNUM]

					//���������������������������������������������������������Ŀ
					//� Grava Faixa atual do Nosso Numero e Portador no SE1     �
					//�                                                         �
					//� A Gravacao do Nosso numero no SE1 sem o Dig Verificador �
					//� devido aos criterios diferenciados de calculo entre os  �
					//� Bancos. Sao recalculados a cada impressao               �
					//�����������������������������������������������������������
					RecLock("SE1",.F.)
						SE1->E1_NUMBCO  := aTitulo[TIT_NNUM] + aTitulo[TIT_DVNNUM]
					MsUnLock()

			EndIf

	ElseIf 	aBanco[BCO_NUMBCO] = SAFRA

			If 		aBanco[BCO_CARTEIR] = "06" //-- COBRANCA EXPRESS

				//�����������������������������������������������������������Ŀ
				//� Em caso de cobranca sem registro (Express) o campo Nosso  �
				//� Numero no corpo do boleto deve conter a literal "EXPRESS" �
				//�������������������������������������������������������������
				aTitulo[TIT_NNUMFORM]  := "EXPRESS"

			ElseIf aBanco[BCO_CARTEIR] = "01" //-- COBRANCA REGISTRADA

				cNNum   := SubStr(SE1->E1_NUMBCO,1,8)
				cDvNNum := Mod11B29(cNNum)

				aTitulo[TIT_NNUM]     := cNNum
				aTitulo[TIT_DVNNUM]   := cDvNNum
				aTitulo[TIT_NNUMFORM] := cNNum + "-" + cDvNNum

				RecLock("SE1", .F.)
					//SE1->E1_IDCNAB := AllTrim(SEE->EE_FAXATU)
					//SE1->E1_NUMBCO := AllTrim(SEE->EE_FAXATU)
					SE1->E1_IDCNAB := cNNum+cDvNNum
					SE1->E1_NUMBCO := cNNum+cDvNNum
				MsUnlock()

			ElseIf aBanco[BCO_CARTEIR] = "09" //-- COBRANCA CORRESPONDENTE BRADESCO

				cNNum    := SubStr(SE1->E1_NUMBCO,1,8)
				cAnoVcto := Right(aTitulo[TIT_DTEMI], 2)

				cNNumAux += aBanco[BCO_CARTEIR]	           //-- Carteira de Cobranca (2 Digitos)
				cNNumAux += cAnoVcto                       //-- Ano Vencimento 2 digitos
				cNNumAux += cNNum                          //-- Sequencial Nosso Numero
				cNNumAux += Mod11B29(cNNum)                //-- Calcula DV Nosso Numero Safra

				cDvNNum  := Mod11B27( cNNumAux )            //-- Calcula DV Nosso Numero Bradesco

				aTitulo[TIT_NNUM]     := cNNum + Mod11B29(cNNum)
				aTitulo[TIT_DVNNUM]   := cDvNNum
				aTitulo[TIT_NNUMFORM] := aBanco[BCO_CARTEIR] + "/" + cAnoVcto + Space(1) + aTitulo[TIT_NNUM] + "-" + aTitulo[TIT_DVNNUM]

				//���������������������������������������������������������Ŀ
				//� Grava Faixa atual do Nosso Numero e Portador no SE1     �
				//�                                                         �
				//� A Gravacao do Nosso numero no SE1 sem o Dig Verificador �
				//� devido aos criterios diferenciados de calculo entre os  �
				//� Bancos. Sao recalculados a cada impressao               �
				//�                                                         �
				//� Somente para o Bradesco foi alterado para Gravar o DV   �
				//� pois o mesmo e necessario ser enviado via CNAB          �
				//�                                                         �
				//� Neste caso, para o Banco Safra, n�o � necess�rio o DV   �
				//� do Banco Correspondente, apenas o DV do Banco Safra     �
				//�����������������������������������������������������������
				RecLock("SE1",.F.)
					SE1->E1_NUMBCO  := aTitulo[TIT_NNUM]
				MsUnLock()

			EndIf

	ElseIf 	aBanco[BCO_NUMBCO] = FIBRA

		If 		aBanco[BCO_CARTEIR] = "19" //-- COBRANCA CORRESPONDENTE BRADESCO

			cNNum   := SubStr(SE1->E1_NUMBCO,1,11)

			//-- Monta String para Calculo do Digito Verificador
			cNNumAux += aBanco[BCO_CARTEIR]	//-- Carteira de Cobranca (2 Digitos)
			cNNumAux += cNNum				//-- Sequencial Nosso Numero
			cDvNNum := Mod11B7( cNNumAux )  //-- Calcula DV Nosso Numero

			aTitulo[TIT_NNUM]     := cNNum
			aTitulo[TIT_DVNNUM]   := cDvNNum
			aTitulo[TIT_NNUMFORM] := aBanco[BCO_CARTEIR] + "/" + aTitulo[TIT_NNUM] + "-" + aTitulo[TIT_DVNNUM]

			//���������������������������������������������������������Ŀ
			//� Grava Faixa atual do Nosso Numero e Portador no SE1     �
			//�                                                         �
			//� A Gravacao do Nosso numero no SE1 sem o Dig Verificador �
			//� devido aos criterios diferenciados de calculo entre os  �
			//� Bancos. Sao recalculados a cada impressao               �
			//�                                                         �
			//� Somente para o Bradesco foi alterado para Gravar o DV   �
			//� pois o mesmo e necessario ser enviado via CNAB          �
			//�����������������������������������������������������������
			RecLock("SE1",.F.)
				SE1->E1_NUMBCO  := aTitulo[TIT_NNUM] + aTitulo[TIT_DVNNUM]
			MsUnLock()

		EndIf

	ElseIf 	aBanco[BCO_NUMBCO] = SICREDI

		cAnoAtual := Right(CValToChar(Year( Date() )), 2)
		cNNum     := Left(SE1->E1_NUMBCO, 5)

		// Tratamento para a reimpress�o do boleto,
		// evitando que seja gerado um novo nosso n�mero
		If Len( AllTrim(SE1->E1_NUMBCO) ) > 5

			cNNum := SubStr(cFaixaProx, 6, 5)   //  SubStr(SE1->E1_NUMBCO, 4, 5)
		EndIf

		// Calculo do DV do Nosso Numero
		cNNumAux  += aBanco[BCO_NUMAGE]         //-- Agencia cedente
		cNNumAux  += aBanco[BCO_POSTO]          //-- Posto cedente
		cNNumAux  += "02819"                    // aBanco[BCO_NUMCTA]         //-- Conta cedente
		cNNumAux  += cAnoAtual                  //-- Ano atual
		cNNumAux  += "2"                        //-- Indicador de geracao do Nosso Numero (2 a 9)
		cNNumAux  += cNNum                      //-- Sequencial Nosso Numero

		cDvNNum   += Mod11B29(cNNumAux)

		aTitulo[TIT_NNUM]     := cAnoAtual + SubStr(cNNumAux, 14,1) + cNNum // Right(cNNumAux, 8)
		aTitulo[TIT_DVNNUM]   := cDvNNum
		aTitulo[TIT_NNUMFORM] := cAnoAtual + "/" + SubStr(cNNumAux, 14,1) + cNNum + "-" + cDvNNum


		//���������������������������������������������������������Ŀ
		//� Grava Faixa atual do Nosso Numero e Portador no SE1     �
		//�                                                         �
		//� A Gravacao do Nosso numero no SE1 sem o Dig Verificador �
		//� devido aos criterios diferenciados de calculo entre os  �
		//� Bancos. Sao recalculados a cada impressao               �
		//�                                                         �
		//� Somente para o Bradesco foi alterado para Gravar o DV   �
		//� pois o mesmo e necessario ser enviado via CNAB          �
		//�����������������������������������������������������������
		RecLock("SE1",.F.)
			SE1->E1_NUMBCO  := cAnoAtual + SubStr(cNNumAux, 14,1) + cNNum + cDvNNum  /// aTitulo[TIT_NNUM] + aTitulo[TIT_DVNNUM]
		MsUnLock()

	ElseIf 	aBanco[BCO_NUMBCO] = REDASSET

		If 		aBanco[BCO_CARTEIR] = "09" //-- COBRANCA CORRESPONDENTE BRADESCO

			cNNum   := SubStr(SE1->E1_NUMBCO,1,11)

			//-- Monta String para Calculo do Digito Verificador
			cNNumAux += aBanco[BCO_CARTEIR]	//-- Carteira de Cobranca (2 Digitos)
			cNNumAux += cNNum				//-- Sequencial Nosso Numero
			cDvNNum := Mod11B7( cNNumAux )  //-- Calcula DV Nosso Numero

			aTitulo[TIT_NNUM]     := cNNum
			aTitulo[TIT_DVNNUM]   := cDvNNum
			aTitulo[TIT_NNUMFORM] := aBanco[BCO_CARTEIR] + "/" + aTitulo[TIT_NNUM] + "-" + aTitulo[TIT_DVNNUM]

			//���������������������������������������������������������Ŀ
			//� Grava Faixa atual do Nosso Numero e Portador no SE1     �
			//�                                                         �
			//� A Gravacao do Nosso numero no SE1 sem o Dig Verificador �
			//� devido aos criterios diferenciados de calculo entre os  �
			//� Bancos. Sao recalculados a cada impressao               �
			//�                                                         �
			//� Somente para o Bradesco foi alterado para Gravar o DV   �
			//� pois o mesmo e necessario ser enviado via CNAB          �
			//�����������������������������������������������������������
			RecLock("SE1",.F.)
				SE1->E1_NUMBCO  := aTitulo[TIT_NNUM] + aTitulo[TIT_DVNNUM]
			MsUnLock()

		EndIf

	ElseIf 	aBanco[BCO_NUMBCO] = BBM

		If 		aBanco[BCO_CARTEIR] = "09" //-- COBRANCA CORRESPONDENTE BRADESCO

			cNNum   := SubStr(SE1->E1_NUMBCO,1,11)

			//-- Monta String para Calculo do Digito Verificador
			cNNumAux += aBanco[BCO_CARTEIR]	//-- Carteira de Cobranca (2 Digitos)
			cNNumAux += cNNum				//-- Sequencial Nosso Numero
			cDvNNum := Mod11B7( cNNumAux )  //-- Calcula DV Nosso Numero

			aTitulo[TIT_NNUM]     := cNNum
			aTitulo[TIT_DVNNUM]   := cDvNNum
			aTitulo[TIT_NNUMFORM] := aBanco[BCO_CARTEIR] + "/" + aTitulo[TIT_NNUM] + "-" + aTitulo[TIT_DVNNUM]

			//���������������������������������������������������������Ŀ
			//� Grava Faixa atual do Nosso Numero e Portador no SE1     �
			//�                                                         �
			//� A Gravacao do Nosso numero no SE1 sem o Dig Verificador �
			//� devido aos criterios diferenciados de calculo entre os  �
			//� Bancos. Sao recalculados a cada impressao               �
			//�                                                         �
			//� Somente para o Bradesco foi alterado para Gravar o DV   �
			//� pois o mesmo e necessario ser enviado via CNAB          �
			//�����������������������������������������������������������
			RecLock("SE1",.F.)
				SE1->E1_NUMBCO  := aTitulo[TIT_NNUM] + aTitulo[TIT_DVNNUM]
			MsUnLock()

		EndIf

	ElseIf 	aBanco[BCO_NUMBCO] = ABC

		If aBanco[BCO_CARTEIR] = "109" // Banco Correspondente

			cNNum   := SubStr(SE1->E1_NUMBCO,1,8)

			//-- Monta String para Calculo do Digito Verificador
			cNNumAux := aBanco[BCO_AGECOR]	//-- Numero da Agencia (4 Digitos)
			cNNumAux += aBanco[BCO_NCTACO]	//-- Numero da Conta (8 Digitos)
			cNNumAux += aBanco[BCO_CARTEIR]	//-- Carteira de Cobranca (3 Digitos)
			cNNumAux += cNNum				//-- Sequencial Nosso Numero
			cDvNNum := Modulo10( cNNumAux , aBanco[BCO_BCOCOR])	//-- Calcula DV Nosso Numero

			aTitulo[TIT_NNUM]     := cNNum
			aTitulo[TIT_DVNNUM]   := cDvNNum
			aTitulo[TIT_NNUMFORM] := aBanco[BCO_CARTEIR] + "/" + aTitulo[TIT_NNUM]+"-"+aTitulo[TIT_DVNNUM]

			//���������������������������������������������������������Ŀ
			//� Grava Faixa atual do Nosso Numero e Portador no SE1     �
			//�                                                         �
			//� A Gravacao do Nosso numero no SE1 sem o Dig Verificador �
			//� devido aos criterios diferenciados de calculo entre os  �
			//� Bancos. Sao recalculados a cada impressao               �
			//�                                                         �
			//� Somente para o Bradesco foi alterado para Gravar o DV   �
			//� pois o mesmo e necessario ser enviado via CNAB          �
			//�����������������������������������������������������������
			RecLock("SE1",.F.) //Paola - 10/06/2015
				SE1->E1_NUMBCO  := aTitulo[TIT_NNUM] + aTitulo[TIT_DVNNUM]
			MsUnLock()

		ElseIf aBanco[BCO_CARTEIR] = "110" // cobran�a Direta

			cNNum   := SubStr(SE1->E1_NUMBCO,1,10)

			//-- Monta String para Calculo do Digito Verificador
			cNNumAux := aBanco[BCO_NUMAGE]	//-- Numero da Agencia (4 Digitos)
			cNNumAux += aBanco[BCO_CARTEIR]	//-- Carteira de Cobranca (3 Digitos)
			cNNumAux += cNNum				//-- Sequencial Nosso Numero (10 Digitos)
			cDvNNum  := Modulo10( cNNumAux , aBanco[BCO_NUMBCO] )	//-- Calcula DV Nosso Numero

			aTitulo[TIT_NNUM]     := cNNum
			aTitulo[TIT_DVNNUM]   := cDvNNum
			aTitulo[TIT_NNUMFORM] := aBanco[BCO_CARTEIR] + "/" + aTitulo[TIT_NNUM]+"-"+aTitulo[TIT_DVNNUM]

			//���������������������������������������������������������Ŀ
			//� Grava Faixa atual do Nosso Numero e Portador no SE1     �
			//�                                                         �
			//� A Gravacao do Nosso numero no SE1 sem o Dig Verificador �
			//� devido aos criterios diferenciados de calculo entre os  �
			//� Bancos. Sao recalculados a cada impressao               �
			//�����������������������������������������������������������
			RecLock("SE1",.F.) //Paola - 10/06/2015
				SE1->E1_NUMBCO  := aTitulo[TIT_NNUM] + aTitulo[TIT_DVNNUM]
			MsUnLock()

		EndIf

	ElseIf		aBanco[BCO_NUMBCO] = VOTORANTIM

			cNNum := SubStr(SE1->E1_NUMBCO,1,10)

			//-- Monta String para Calculo do Digito Verificador
			cNNumAux := aBanco[BCO_CODEMP]	//-- Numero da Agencia (4 Digitos)
			cNNumAux += cNNum				//-- Sequencial Nosso Numero

			aTitulo[TIT_NNUM]     := cNNum
			aTitulo[TIT_DVNNUM]   := ""
			aTitulo[TIT_NNUMFORM] := aBanco[BCO_CODEMP] + aTitulo[TIT_NNUM]

	ElseIf		aBanco[BCO_NUMBCO] = NORDESTE

			cNNum   := SubStr(SE1->E1_NUMBCO,1,7)
			cDvNNum := Mod11B8(AllTrim(cNNum))

			aTitulo[TIT_NNUM]     := cNNum
			aTitulo[TIT_DVNNUM]   := cDvNNum
			aTitulo[TIT_NNUMFORM] := cNNum + "-" + cDvNNum   // + Space(5) + aBanco[BCO_CARTEIR] - nosso numero sem carteira - Paola - 10/06/2015

			//���������������������������������������������������������Ŀ
			//� Grava Faixa atual do Nosso Numero e Portador no SE1     �
			//�                                                         �
			//� A Gravacao do Nosso numero no SE1 sem o Dig Verificador �
			//� devido aos criterios diferenciados de calculo entre os  �
			//� Bancos. Sao recalculados a cada impressao               �
			//�                                                         �
			//� Somente para o Bradesco foi alterado para Gravar o DV   �
			//� pois o mesmo e necessario ser enviado via CNAB          �
			//�����������������������������������������������������������
			RecLock("SE1",.F.)  //Paola - 10/06/2015
				SE1->E1_NUMBCO  := aTitulo[TIT_NNUM] + aTitulo[TIT_DVNNUM]
			MsUnLock()


	ElseIf		aBanco[BCO_NUMBCO] = CITIBANK

			cNNum   := SubStr(SE1->E1_NUMBCO,1,11)
			cDvNNum := Mod11B29(cNNum)

			aTitulo[TIT_NNUM]     := cNNum
			aTitulo[TIT_DVNNUM]   := cDvNNum
			aTitulo[TIT_NNUMFORM] := cNNum + " " + cDvNNum


			//���������������������������������������������������������Ŀ
			//� Grava Faixa atual do Nosso Numero e Portador no SE1     �
			//�                                                         �
			//� A Gravacao do Nosso numero no SE1 sem o Dig Verificador �
			//� devido aos criterios diferenciados de calculo entre os  �
			//� Bancos. Sao recalculados a cada impressao               �
			//�                                                         �
			//� Somente para o Bradesco foi alterado para Gravar o DV   �
			//� pois o mesmo e necessario ser enviado via CNAB          �
			//�����������������������������������������������������������
			RecLock("SE1",.F.)
				SE1->E1_NUMBCO  := aTitulo[TIT_NNUM] + aTitulo[TIT_DVNNUM]
			MsUnLock()


	EndIf

	RestArea(aArea)

Return( )

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �F001CodBar � Autor � Fabio Briddi         � Data � Nov/2013 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Monta o Codigo de Barras                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� aBanco = Array com Dados do Banco Selecionado              ���
���          � aTitulos = Array com Informacoes do Titulo sendo impresso  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Uso       � CI_F001                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function F001CodBar( aBanco, aTitulo, nValor )

	Local dDtBase	   := CTOD("07/10/1997")
	Local cFatorVencto := ""
	Local cValor       := ""
	Local cPsq         := ""
	Local cCpoLivre    := ""

	//-- Calculo do Fator de Vencimento do Titulo
	cFatorVencto := StrZero( CTOD(aTitulo[TIT_DTVCTO]) - dDtBase, 4 )
	//If aBanco[BCO_MBCARD] = "1"
	//	cValor       := "0000000000"
	//Else
		cValor       := StrZero( (aTitulo[TIT_VALOR]*100), 10) // Retirei as informa��es acima a pedido do cliente MAZER que � o �nico que utiliza em 10/12/18
		
    //Endif
	//����������������������������������������������������������������Ŀ
	//� Montagem dos Dados Para o Codigo de Barras                     �
	//������������������������������������������������������������������
	//����������������������������������������������������������������Ŀ
	//� Da Posicao 01 a 19 e igual para Todos os Bancos               �
	//������������������������������������������������������������������

	cCodBar := aBanco[BCO_NUMBCO]			//-- 01-03 - Codigo do Banco
	cCodBar += "9"							//-- 04-04 - Codigo da Moeda
	cCodBar += ""							//-- 05-05 - DAC do Codigo de Barras
	cCodBar += cFatorVencto					//-- 06-09 - Fator de Vencimento
	cCodBar += cValor						//-- 10-19 - Valor

	//����������������������������������������������������������������Ŀ
	//� Da Posicao 20 a 44 Campo Livre de Acordo com o Manual do Banco �
	//������������������������������������������������������������������
	If	 	aBanco[BCO_NUMBCO] = BRASIL

		If		Len( aBanco[BCO_CODEMP] ) = 4

			cCodBar += aBanco[BCO_CODEMP]						//-- 20-23 - Cod Empresa (fornecido pelo banco)
			cCodBar += aTitulo[TIT_NNUM]						//-- 24-30 - Sequencial Nosso Numero
			cCodBar += aBanco[BCO_NUMAGE]						//-- 31-34 - Agencia
			cCodBar += StrZero(Val( aBanco[BCO_NUMCTA] ),8,0)//-- 35-42 - Conta corrente
			cCodBar += aBanco[BCO_CARTEIR]						//-- 43-44 - Carteira

		ElseIf Len( aBanco[BCO_CODEMP] ) = 6

			cCodBar += aBanco[BCO_CODEMP]						//-- 20-25 - Cod Empresa (fornecido pelo banco)
			cCodBar += aTitulo[TIT_NNUM]						//-- 26-30 - Sequencial Nosso Numero
			cCodBar += aBanco[BCO_NUMAGE]						//-- 31-34 - Agencia
			cCodBar += StrZero(Val( aBanco[BCO_NUMCTA] ),8,0)//-- 35-42 - Conta corrente
			cCodBar += aBanco[BCO_CARTEIR]						//-- 43-44 - Carteira

		ElseIf	Len( aBanco[BCO_CODEMP] ) = 7

			cCodBar += Replicate("0",6)	   						//-- 20-25 - Zeros fixos
			cCodBar += aBanco[BCO_CODEMP]						//-- 26-32 - Cod Empresa
			cCodBar += aTitulo[TIT_NNUM]						//-- 33-42 - Sequencial Nosso Numero
			cCodBar += aBanco[BCO_CARTEIR]						//-- 43-44 - Carteira

		EndIf

	ElseIf	aBanco[BCO_NUMBCO] = SANTANDER

			cCodBar += "9"										//-- 20-20 - Constante 9
			cCodBar += Left(aBanco[BCO_CODEMP],7)	  			//-- 21-27 - Cod. Beneficiario
			cCodBar += aTitulo[TIT_NNUM]						//-- 28-39 - Nosso Numero
			cCodBar += aTitulo[TIT_DVNNUM]						//-- 40-40 - Dig Verificador Nosso Numero
			cCodBar += "0"										//-- 41-41 - Constante 0
			cCodBar += aBanco[BCO_CARTEIR]						//-- 42-44 - Carteira

	ElseIf	aBanco[BCO_NUMBCO] = BANRISUL

			cCpoLivre := "2"									//-- 20-20 - Produto:
																//-- 1-Cobranca Normal / 2-Cobranca Direta (Emisssao Cliente)
			cCpoLivre += "1"									//-- 21-21 - Constante 1
			cCpoLivre += aBanco[BCO_NUMAGE]						//-- 22-25 - Agencia Cedente (Cobranca)
			cCpoLivre += Left(aBanco[BCO_CODEMP],7)	  			//-- 26-32 - Cod. Beneficiario
			cCpoLivre += aTitulo[TIT_NNUM]						//-- 33-40 - Sequencial Nosso Numero
			cCpoLivre += "40"									//-- 41-42 - Constante 40

			cCpoAux  := cCpoLivre
			cDv1Cpo  := Modulo10( cCpoLivre )					//-- Calcula Primeiro DV Pos 20 a 42 Campo Livre (Modulo 10)
			cCpoAux  := cCpoLivre + cDv1Cpo
			cDv2Cpo  := Mod11B27B( cCpoAux )					//-- Calcula Segundo DV Pos 20 a 42 Campo Livre (Modulo 11)

			cCodBar  += cCpoLivre + cDv2Cpo						//-- 43-44 - Duplo D�gito referente �s posi��es 20 a 42 (m�dulos 10 e 11)
                                                                // O DV 1 pode modificar AP�S o calculo do DV 2 ent�o
                                                                // o DV 2 Volta com os dois - Paola - 01/2018
	ElseIf	aBanco[BCO_NUMBCO] = CAIXA

	       	cDvCodEmp := ""  // DV do cod. Beneficiario
	       	cDv1Cpo   := ""  // DV do campo livre
	       	cDv1cBar  := ""  // DV do codigo de barras

			cCpoLivre += AllTrim(aBanco[BCO_CODEMP])               //-- 20-25 - Cod. Beneficiario
			cDvCodEmp += Mod11B29(AllTrim(aBanco[BCO_CODEMP]))     //-- 26-26 - DV do Cod. Beneficiario
			cCpoLivre += cDvCodEmp                                 //Calcula o DV do COd. Beneficiario
			cCpoLivre += SubStr(aTitulo[TIT_NNUMFORM], 3, 3)       //-- 27-29 - Posicao 3 a 5 do Nosso Numero
			cCpoLivre += Iif( aBanco[BCO_CARTEIR] = "RG","1","2")  //-- 30-30 - Tipo de Cobranca (1-Registrada / 2-Sem Registro)
			cCpoLivre += SubStr(aTitulo[TIT_NNUMFORM], 6, 3)       //-- 31-33 - Posicao 6 a 8 do Nosso Numero
			cCpoLivre += "4"                                       //-- 34-34 - Identificador de Emissao do Boleto (4-Beneficiario)
			cCpoLivre += SubStr(aTitulo[TIT_NNUMFORM], 9, 9)       //-- 35-43 - Posicao 9 a 17 do Nosso Numero

			cCodBen := AllTrim(aBanco[BCO_CODEMP]) + AllTrim(aTitulo[TIT_DVNNUM])
			//cNNum   := Iif( aBanco[BCO_CARTEIR] = "RG","1","2") + "4" + AllTrim(aTitulo[TIT_NNUM])

			cDv1Cpo +=Mod11B29(AllTrim(cCpoLivre))//-- 44-44 - Digito Campo livre
			cCodBar +=cCpoLivre  + cDv1Cpo //Codigo de barras = campo livre + DV do campo livre

	ElseIf	aBanco[BCO_NUMBCO] = BRADESCO

			cCodBar += AllTrim(aBanco[BCO_NUMAGE])				//-- 20-23 - Agencia Cedente (Cobranca)
			cCodBar += AllTrim(aBanco[BCO_CARTEIR])				//-- 24-25 - Carteira
			cCodBar += aTitulo[TIT_NNUM]						//-- 26-36 - Sequencial Nosso Numero
			cCodBar += AllTrim(aBanco[BCO_NUMCTA]) 				//-- 37-43 - Conta Cedente (Cobranca)
			cCodBar += "0"										//-- 44-44 - Zero fixo

	ElseIf	aBanco[BCO_NUMBCO] = ITAU

			cCodBar += aBanco[BCO_CARTEIR]						//-- 20-22 - Carteira
			cCodBar += aTitulo[TIT_NNUM]						//-- 23-30 - Nosso Numero
			cCodBar += aTitulo[TIT_DVNNUM]						//-- 31-31 - DAC Age+Cta+Cart+Nosso numero
			cCodBar += AllTrim(aBanco[BCO_NUMAGE])				//-- 32-35 - Agencia
			cCodBar += AllTrim(aBanco[BCO_NUMCTA])				//-- 36-40 - Conta Corrente
			cCodBar += AllTrim(aBanco[BCO_DVCTA])				//-- 41-41 - DAC Conta
			cCodBar += "000"									//-- 42-44 - Posicoes Livres (zeros)

	ElseIf 	aBanco[BCO_NUMBCO] = HSBC

			If	aBanco[BCO_CARTEIR] = "CNR"

				cAno    := StrZero(Year(cToD(aTitulo[TIT_DTVCTO])),4)
				dPriAno := CTOD("01/01/"+cAno)
				cVencJul:= StrZero((cToD(aTitulo[TIT_DTVCTO]) - dPriAno)+1,3)

				cCodBar += aBanco[BCO_CODEMP]					//-- 20-26 - Codigo Beneficiario
				cCodBar += "00000" + AllTrim(aTitulo[TIT_NNUM]) //-- 27-39 - Sequencial Nosso Numero
				cCodBar += cVencJul								//-- 40-43 - Data Vencimento Formato Juliano
				cCodBar += Right(cAno,1)						//-- 44-44 - Correspondem ao algarismo final do ano da data de vencimento
				cCodBar += "2"									//-- 45-45 - Codigo do Produto CNR, deve preencher o numero 2.

			ElseIf aBanco[BCO_CARTEIR] = "CSB"

				cCodBar += aTitulo[TIT_NNUM]					//-- 20-29 - Sequencial Nosso Numero
				cCodBar += aTitulo[TIT_DVNNUM]					//-- 30-30 - Digito Verificador	Nosso Numero
				cCodBar += AllTrim(aBanco[BCO_NUMAGE])			//-- 31-34 - Agencia
				cCodBar += AllTrim(aBanco[BCO_CODEMP])			//-- 35-41 - Conta Cobranca (EE_CODEMP)
				cCodBar += "00"									//-- 42-43 - Codigo Carteira
				cCodBar += "1"									//-- 44-44 - Codigo do aplicativo da Cobranca (COB) = '1'

			EndIf

	ElseIf	aBanco[BCO_NUMBCO] = SAFRA

		If	aBanco[BCO_CARTEIR] = "06"                       	//-- COBRANCA EXPRESS

			cCodBar += "7"                                   	//-- 20    - Digito Banco Safra
			cCodBar += Left(aBanco[BCO_CODEMP],6)            	//-- 21-26 - Identificacao do Beneficiario
			cCodBar += AllTrim(SEE->EE_FAXATU)               	//-- 27-36 - No. livre do cliente (Faixa Sequencial)
			cCodBar += PadL(aBanco[BCO_CODEMP],7,"0")        	//-- 37-43 - No. livre do cliente (Codigo Empresa)
			cCodBar += "4"                                   	//-- 44    - Tipo de Cobranca (Nao registrada)

		ElseIf aBanco[BCO_CARTEIR] = "01"                   	//-- COBRANCA REGISTRADA

			cCodBar += "7"                                   	//-- 20    - Digito Banco Safra
			cCodBar += AllTrim(aBanco[BCO_NUMAGE])           	//-- 21-25 - Agencia do Cliente
			cCodBar += AllTrim(aBanco[BCO_NUMCTA])           	//-- 26-34 - Conta Corrente
			cCodBar += aTitulo[TIT_NNUM]                     	//-- 35-42 - Nosso Numero
			cCodBar += aTitulo[TIT_DVNNUM]                   	//-- 43-43 - DV Nosso Numero
			cCodBar += "2"                                   	//-- 44    - Tipo de Cobranca (Registrada)

		ElseIf aBanco[BCO_CARTEIR] = "09"                   	//-- COBRANCA CORRESPONDENTE BRADESCO

			cAno := Str( Year( Date() ) )

			//�������������������������������������������������������Ŀ
			//� Substitui os 3 primeiros digitos do banco cedente, no �
			//� codigo de barras, pelo banco correspondente           �
			//���������������������������������������������������������
			If !Empty(aBanco[BCO_BCOCOR])

				cPsq	:= Left(cCodBar, 3)
				cCodBar := StrTran(cCodBar, cPsq, AllTrim(aBanco[BCO_BCOCOR]))

			EndIf

			cCodBar += AllTrim(aBanco[BCO_AGECOR])           	//-- 20-23 - Agencia Beneficiario
			cCodBar += aBanco[BCO_CARTEIR]                   	//-- 24-25 - Carteira
			cCodBar += Right(cAno, 2)                        	//-- 26-27 - Ano Emissao do Boleto
			cCodBar += aTitulo[TIT_NNUM]                     	//-- 28-35 - Nosso Numero Safra
//			cCodBar += Mod11B29(aTitulo[TIT_NNUM])					//-- 36-36 - DV Nosso Numero Safra
			cCodBar += AllTrim(aBanco[BCO_NCTACO])           	//-- 37-43 - Conta Beneficiario
			cCodBar += "0"                                   	//-- 44-44 - Zero fixo

		EndIf

	ElseIf	aBanco[BCO_NUMBCO] = FIBRA

		If aBanco[BCO_CARTEIR] = "19"                   		//-- COBRANCA CORRESPONDENTE BRADESCO

			//�������������������������������������������������������Ŀ
			//� Substitui os 3 primeiros digitos do banco cedente, no �
			//� codigo de barras, pelo banco correspondente           �
			//���������������������������������������������������������
			If !Empty(aBanco[BCO_BCOCOR])

				cPsq	:= Left(cCodBar, 3)
				cCodBar := StrTran(cCodBar, cPsq, AllTrim(aBanco[BCO_BCOCOR]))

			EndIf

			cCodBar += AllTrim(aBanco[BCO_AGECOR])				//-- 20-23 - Agencia Cedente (Cobranca)
			cCodBar += AllTrim(aBanco[BCO_CARTEIR])				//-- 24-25 - Carteira
			cCodBar += aTitulo[TIT_NNUM]						//-- 26-36 - Sequencial Nosso Numero
			cCodBar += AllTrim(aBanco[BCO_NCTACO]) 				//-- 37-43 - Conta Cedente (Cobranca)
			cCodBar += "0"			                         	//-- 44-44 - Zero fixo

		EndIf

	ElseIf	aBanco[BCO_NUMBCO] = SICREDI

		//������������������������������������������������������Ŀ
		//� Calculo do Digito Verificador do Campo Livre do      �
		//� Codigo de Barras                                     �
		//��������������������������������������������������������
		cCpoLivre += "1"                                      //-- 20-20 - Tipo de Cobranca "Com registro"
		cCpoLivre += "1"  // AllTrim(aBanco[BCO_CARTEIR])     //-- 21-21 - Carteira
		cCpoLivre += aTitulo[TIT_NNUM]                        //-- 22-29 - Nosso Numero
		cCpoLivre += aTitulo[TIT_DVNNUM]                      //-- 30-30 - DV Nosso Numero
		cCpoLivre += AllTrim(aBanco[BCO_NUMAGE])              //-- 31-34 - Cooperativa/Agencia beneficiaria
		cCpoLivre += AllTrim(aBanco[BCO_POSTO])               //-- 35-36 - Posto da Cooperativa/Agencia
		cCpoLivre += "02819"  // AllTrim(aBanco[BCO_NUMCTA])              //-- 37-41 - Codigo/Conta do cedente
		cCpoLivre += Iif(!Empty(SE1->E1_VLCRUZ), "1","0")      //-- 42-42 - Sera '1' quando houver valor no documento
		cCpoLivre += "0"                                      //-- 43-43 - Filler - zero fixo
		cCpoLivre += Mod11CB( cCpoLivre , .F. )               //-- 44-44 - DV do Campo Livre

		cCodBar += cCpoLivre

	ElseIf	aBanco[BCO_NUMBCO] = REDASSET

		If aBanco[BCO_CARTEIR] = "09"                   		//-- COBRANCA CORRESPONDENTE BRADESCO

			//�������������������������������������������������������Ŀ
			//� Substitui os 3 primeiros digitos do banco cedente, no �
			//� codigo de barras, pelo banco correspondente           �
			//���������������������������������������������������������
			If !Empty(aBanco[BCO_BCOCOR])

				cPsq	:= Left(cCodBar, 3)
				cCodBar := StrTran(cCodBar, cPsq, AllTrim(aBanco[BCO_BCOCOR]))

			EndIf

			cCodBar += AllTrim(aBanco[BCO_AGECOR])				//-- 20-23 - Agencia Cedente (Cobranca)
			cCodBar += AllTrim(aBanco[BCO_CARTEIR])				//-- 24-25 - Carteira
			cCodBar += aTitulo[TIT_NNUM]						//-- 26-36 - Sequencial Nosso Numero
			cCodBar += AllTrim(aBanco[BCO_NCTACO]) 				//-- 37-43 - Conta Cedente (Cobranca)
			cCodBar += "0"			                         	//-- 44-44 - Zero fixo

		EndIf

	ElseIf	aBanco[BCO_NUMBCO] = BBM

		If aBanco[BCO_CARTEIR] = "09"                   		//-- COBRANCA CORRESPONDENTE BRADESCO

			//�������������������������������������������������������Ŀ
			//� Substitui os 3 primeiros digitos do banco cedente, no �
			//� codigo de barras, pelo banco correspondente           �
			//���������������������������������������������������������
			If !Empty(aBanco[BCO_BCOCOR])

				cPsq	:= Left(cCodBar, 3)
				cCodBar := StrTran(cCodBar, cPsq, AllTrim(aBanco[BCO_BCOCOR]))

			EndIf

			cCodBar += AllTrim(aBanco[BCO_AGECOR])				//-- 20-23 - Agencia Cedente (Cobranca)
			cCodBar += AllTrim(aBanco[BCO_CARTEIR])				//-- 24-25 - Carteira
			cCodBar += aTitulo[TIT_NNUM]						//-- 26-36 - Sequencial Nosso Numero
			cCodBar += AllTrim(aBanco[BCO_NCTACO]) 				//-- 37-43 - Conta Cedente (Cobranca)
			cCodBar += "0"			                         	//-- 44-44 - Zero fixo

		EndIf

	ElseIf		aBanco[BCO_NUMBCO] = ABC

		If aBanco[BCO_CARTEIR] = "109" // Banco Correspondente

			//�������������������������������������������������������Ŀ
			//� Substitui os 3 primeiros digitos do banco cedente, no �
			//� codigo de barras, pelo banco correspondente           �
			//���������������������������������������������������������
			If !Empty(aBanco[BCO_BCOCOR])

				cPsq	:= Left(cCodBar, 3)
				cCodBar := StrTran(cCodBar, cPsq, AllTrim(aBanco[BCO_BCOCOR]))

			EndIf

			cCodBar += aBanco[BCO_CARTEIR]						//-- 20-22 - Carteira
			cCodBar += aTitulo[TIT_NNUM]						//-- 23-30 - Nosso Numero
			cCodBar += aTitulo[TIT_DVNNUM]						//-- 31-31 - DAC Age+Cta+Cart+Nosso numero
			cCodBar += AllTrim(aBanco[BCO_AGECOR])				//-- 32-35 - Agencia
			cCodBar += AllTrim(aBanco[BCO_NCTACO])				//-- 36-40 - Conta Corrente
			cCodBar += AllTrim(aBanco[BCO_DVCTCO])				//-- 41-41 - DAC Conta
			cCodBar += "000"									//-- 42-44 - Posicoes Livres (zeros)

		ElseIf  aBanco[BCO_CARTEIR] = "110" // cobran�a Direta

			cCodBar += AllTrim(aBanco[BCO_NUMAGE])				//-- 20-23 - Agencia
			cCodBar += aBanco[BCO_CARTEIR]						//-- 24-26 - Carteira
			cCodBar += Left(aBanco[BCO_CODEMP],7)				//-- 27-33 - Num. Operacao
			cCodBar += aTitulo[TIT_NNUM] + aTitulo[TIT_DVNNUM]	//-- 34-44 - Nosso Numero + DV

		EndIf

	ElseIf	 	aBanco[BCO_NUMBCO] = VOTORANTIM

			//�������������������������������������������������������Ŀ
			//� Substitui os 3 primeiros digitos do banco cedente, no �
			//� codigo de barras, pelo banco correspondente           �
			//���������������������������������������������������������
			If !Empty(aBanco[BCO_BCOCOR])

				cPsq	:= Left(cCodBar, 3)
				cCodBar := StrTran(cCodBar, cPsq, AllTrim(aBanco[BCO_BCOCOR]))

			EndIf

			cCodBar += Replicate("0",6)	   						//-- 20-25 - Zeros fixos
			cCodBar += aBanco[BCO_CODEMP]						//-- 26-32 - Cod Empresa
			cCodBar += aTitulo[TIT_NNUM]						//-- 33-42 - Sequencial Nosso Numero
			cCodBar += aBanco[BCO_CARTEIR]						//-- 43-44 - Carteira

	ElseIf		aBanco[BCO_NUMBCO] = NORDESTE

			cCodBar += aBanco[BCO_NUMAGE]                    //-- 20-23 - Agencia
			cCodBar += aBanco[BCO_NUMCTA]                    //-- 24-30 - Conta Corrente
			cCodBar += aBanco[BCO_DVCTA]                     //-- 31-31 - DV Conta Corrente
			cCodBar += aTitulo[TIT_NNUM]                     //-- 32-38 - Nosso Numero
			cCodBar += aTitulo[TIT_DVNNUM]                   //-- 39-39 - DV Nosso Numero
			cCodBar += aBanco[BCO_CARTEIR]                   //-- 40-41 - Carteira
			cCodBar += Replicate("0",3)	   						//-- 42-44 - Zeros fixos

	ElseIf		aBanco[BCO_NUMBCO] = CITIBANK

			cCodBar += "3"                                   //-- 20-20 - Cobranca com registro / sem registro
			cCodBar += aBanco[BCO_CARTEIR]                   //-- 21-23 - Portfolio (Equivalente a carteira)
			cCodBar += SubStr(aBanco[BCO_NUMCTA],2,6)        //-- 24-29 - Base Conta Cosmos
			cCodBar += SubStr(aBanco[BCO_NUMCTA],8,9)        //-- 30-31 - Sequencia Conta Cosmos
			cCodBar += aBanco[BCO_DVCTA]                     //-- 32-32 - DV Conta Cosmos
			cCodBar += aTitulo[TIT_NNUM]						//-- 33-43 - Nosso Numero
			cCodBar += aTitulo[TIT_DVNNUM]                   //-- 44-44 - DV Nosso Numero

	EndIf

	cDvCodBar := Mod11CB( cCodBar , .T. )								//-- Digito verificador do Codigo de Barras
	cCodBar   := SubStr(cCodBar,1,4) + cDvCodBar + SubStr(cCodBar,5,39)	//-- Insere o DAC na posicao 5 do Codigo de Barras

	aTitulo[TIT_CODBAR] := cCodBar

	//MemoWrite("C:\Temp\codbar.txt", cCodBar)

Return()

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �F001LinDig� Autor � Fabio Briddi          � Data � Nov/2013 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Monta a Linha Digitavel a partir do Codigo de Barras       ���
�������������������������������������������������������������������������Ĵ��
���Parametros� aBanco = Array com Dados do Banco Selecionado              ���
���          � aTitulos = Array com Informacoes do Titulo sendo impresso  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Uso       � CI_F001                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function F001LinDig( aBanco, aTitulo )

	Local cCampo1 := cCampo2 := cCampo3 := cCampo4 := cCampo5 := ""
	Local cCodBar := aTitulo[TIT_CODBAR]

	//������������������������������������������������������Ŀ
	//� Montagem da Linha Digitavel Igual p/ Todos os Bancos �
	//��������������������������������������������������������

	cCampo1  := SubStr(cCodBar,01,03)	//-- Codigo do Banco
	cCampo1  += SubStr(cCodBar,04,01)	//-- Codigo da Moeda
	cCampo1  += SubStr(cCodBar,20,05)	//--
	cCampo1  += Modulo10( cCampo1 , aBanco[BCO_NUMBCO])

	cCampo2  := SubStr(cCodBar,25,10)	//--
	cCampo2  += Modulo10( cCampo2 , aBanco[BCO_NUMBCO])

	cCampo3  := SubStr(cCodBar,35,10)	//--
	cCampo3  += Modulo10( cCampo3 , aBanco[BCO_NUMBCO])

	cCampo4  := SubStr(cCodBar,05,01)	//-- DAC Codigo de Barras

	cCampo5  := SubStr(cCodBar,06,04)	//-- Fator de Vencimento
	If aBanco[BCO_MBCARD] = "1"
		cCampo5  += "0000000000"	//-- Valor
    Else
		cCampo5  += SubStr(cCodBar,10,10)	//-- Valor
    Endif

	cLinDig  := cCampo1 + cCampo2 + cCampo3 + cCampo4 + cCampo5

	cLinDig := FinCbLd( cCodBar )

	aTitulo[TIT_LINDIG] := TransForm(cLinDig, PICT_LINDIG )

    _CodBanco        := aBanco[ 1 ]
	_Moeda           := "9"
    _ComSemRegistro  := "3"
    _TipoCarteira    := "1"
    _NossoNumero     := aBanco[BCO_NUMBCO]
    _cDVNossoNumero  := ""
    _DV1Campo        := ""
    _Cooperativa     := ""
    _DV2Campo        := ""
    _UA              := ""
    _Cedente         := ""
    _ComSemValor     := ""
    _CampoFIXO       := ""
    _DVCampoLivre    := ""
    _DV3Campo        := ""
    _DVGeral         := ""
    _FatorVencimento := ""
    _DataVencimento  := ""
    _VALOR           := ""



Return()

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �  Mod11Cb � Autor �                       � Data �          ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Calculo Modulo 11 Base 9 para Codigo de Barras             ���
�������������������������������������������������������������������������Ĵ��
���Uso       � CI_F001                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function Mod11CB( cString , lCBarr )

	Local nStr  := Len(cString)
	Local nSoma := 0
	Local nBase := 1
	Local nDvCB := 0

	While nStr > 0
		nBase++
		nSoma += (Val(SubStr(cString, nStr, 1)) * nBase)
		nBase := IIf( nBase = 9, 1, nBase)
		nStr--
	EndDo

	nCBResto := Mod(nSoma,11)  //-- Resto da Divisao

	If	lCBarr

		nDvCB    := (11 - nCBResto)

		If	(nDvCB == 0 .Or. nDvCB == 1 .Or. nDvCB == 10 .Or. nDvCB == 11)
			nDvCB := 1
		EndIf

	Else

		If		(nCBResto == 10)
				nDvCB := 1

		ElseIf	(nCBResto == 0 .Or. nCBResto == 1)
				nDvCB := 0

		Else
				nDvCB := Abs(11 - nCBResto)

		EndIf

	EndIf

Return( AllTrim(Str(nDvCB)) )


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � Modulo10 � Autor �                       � Data �          ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Calcula Digito Verificador Pelo Modulo 10 da String Passada���
�������������������������������������������������������������������������Ĵ��
���Uso       � CI_F001 - Geracao e Impressao de Boletos                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function Modulo10( cString , cBanco )

	Local nStr  := Len( cString )
	Local nSoma := 0
	Local nDac  := 0
	Local nPeso := 2
	Local nPos  := 0

	Do	While nStr > 0
		nPos := (Val(SubStr(cString, nStr, 1)) * nPeso)
		If	nPos > 9
	  		nSoma += (nPos - 9)
		Else
			nSoma += nPos
		EndIf
		nPeso := IIf( nPeso = 2, 1, 2)
		nStr--
	EndDo

	nDac := Mod(nSoma,10)
	nDac := 10 - nDac

	If	nDac == 10
		nDac := 0
	EndIf

Return( AllTrim(Str(nDac)) )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �Mod11B27B � Autor �Giovanni Melo          � Data �17/02/2016���
�������������������������������������������������������������������������Ĵ��
���Descricao �Calculo Modulo 11 Base 2 a 7 para nosso Numero BANRISUL     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �Mod11B27B(ExpC1)                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1: Nosso Numero + DV calculado pelo Modulo10            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpC1: Segundo DV gerado                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Mod11B27B( cString )

	Local nStr   := Len(cString)
	Local nSoma  := 0
	Local nPeso  := 2
	Local nDV    := 0
	Local nDvAnt := Val( SubStr( cString, nStr, 1 ) )

	While nStr > 0
		nSoma += Val( SubStr( cString, nStr, 1 ) ) * nPeso
		nPeso++
		nPeso := Iif(nPeso > 7, 2, nPeso )
		nStr--
	EndDo

	If nSoma < 11
		nResto := nSoma
	Else
		nResto := Mod(nSoma,11)

		If nResto = 1 //-- DV invalido

			/*
			If nDvAnt >= 9 //-- DV invalido
				nDvAnt := 0
				cString := SubStr( cString, 1, nStr-1 ) + CValToChar( nDvAnt )
			Else
				nDvAnt++
				cString := Soma1( cString )
			EndIf

			Mod11B27B( cString )
			*/

			If nDvAnt = 9 //-- DV invalido
				nDvAnt := 0
				cString := SubStr( cString, 1, ( Len( cString ) - 1 ) ) + cValToChar( nDvAnt )
			Else
				nDvAnt++
				cString := Soma1( cString )
			EndIf

			Mod11B27B( cString )

		EndIf
	EndIf

	If nResto != 0
		nDV := 11 - nResto
	EndIf

Return( cValToChar( nDvAnt ) + cValToChar( nDv ) )

Static Function Mod11B27( cString )

	Local nStr   := Len(cString)
	Local nSoma  := 0
	Local nPeso  := 2
	Local nDV    := 0

	While nStr > 0
		nSoma += Val( SubStr( cString, nStr, 1 ) ) * nPeso
		nPeso++
		nPeso := Iif(nPeso > 7, 2, nPeso )
		nStr--
	EndDo

	nResto := Mod(nSoma,11)	//-- Resto da Divisao

	If	nResto = 0
		nDV := 0
	ElseIf nResto = 1
		nDv := "P"
	Else
		nDV := (11 - nResto)
	EndIf

Return( AllTrim(cValToChar(nDV)) )

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �  Mod11B27� Autor � Giovanni Melo         � Data �30/06/2015���
�������������������������������������������������������������������������Ĵ��
���Descricao � Calculo Modulo 11 Base 2 a 7 DV Nosso Numero Bradesco      ���
�������������������������������������������������������������������������Ĵ��
���Uso       � CI_F001                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function Mod11B7( cString )

	Local nStr   := Len(cString)
	Local nSoma  := 0
	Local nPeso  := 2
	Local nDV    := 0

	While nStr > 0
		nSoma += Val( SubStr( cString, nStr, 1 ) ) * nPeso
		nPeso++
		nPeso := Iif(nPeso = 8, 2, nPeso )
		nStr--
	EndDo

	nResto := Mod(nSoma,11)	//-- Resto da Divisao

	If	cBanco = BRADESCO

		Do Case

			Case nResto = 0

				nDV := 0

			Case nResto = 1

				nDV := "P"

			OtherWise

				nDV := 11 - nResto

		EndCase

	Else

		If	(nResto = 0 .Or. nResto = 1)

			nDV := 0

		Else

			nDV := 11 - nResto

		EndIf

	EndIf

Return( AllTrim(cValToChar(nDV)) )
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �  Mod11B9 � Autor �                       � Data �          ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Calculo Modulo 11 Base 9 para Codigo de Barras             ���
�������������������������������������������������������������������������Ĵ��
���Uso       � CI_F001                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function Mod11B9( cString )

	Local nStr   := Len(cString)
	Local nSoma  := 0
	Local nPeso  := 9
	Local nDV    := 0

	While nStr > 0
		nSoma += Val( SubStr( cString, nStr, 1 ) ) * nPeso
		nPeso--
		nPeso := Iif(nPeso = 1, 9, nPeso )
		nStr--
	EndDo

	nResto := Mod(nSoma,11)	//-- Resto da Divisao
	nDV    := (11 - nResto)

	If	nDV > 9
		nDV := 0
	EndIf

Return( AllTrim(Str(nDV)) )

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �  Mod11B8 � Autor �                       � Data �          ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Calculo Modulo 11 Base 9 para Codigo de Barras Bco Nordeste���
�������������������������������������������������������������������������Ĵ��
���Uso       � CI_F001                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function Mod11B8( cString )

	Local nStr   := Len(cString)
	Local nSoma  := 0
	Local nPeso  := 2
	Local nDV    := 0

	While nStr > 0
		nSoma += Val( SubStr( cString, nStr, 1 ) ) * nPeso
		nPeso++
		nPeso := Iif(nPeso > 8, 2, nPeso )
		nStr--
	EndDo

	nResto := Mod(nSoma,11)	//-- Resto da Divisao
	nDV    := (11 - nResto)

	If	nDV > 9
		nDV := 0
	ElseIf nDv < 2
		nDv := 1
	EndIf

Return( AllTrim(Str(nDV)) )

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �  Mod11B29 � Autor �                       � Data �         ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Calculo Modulo 11 Base de 2 a 9 para Codigo de Barras      ���
�������������������������������������������������������������������������Ĵ��
���Uso       � CI_F001                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function Mod11B29( cString )

	Local nStr   := Len(cString)
	Local nSoma  := 0
	Local nPeso  := 2
	Local nDV    := 0

	While nStr > 0
		nSoma += Val( SubStr( cString, nStr, 1 ) ) * nPeso
		nPeso++
		nPeso := Iif(nPeso > 9, 2, nPeso )
		nStr--
	EndDo

	nResto := Mod(nSoma,11)	//-- Resto da Divisao
	nDV    := (11 - nResto)

	If cBanco = SAFRA
		If nResto = 0
			nDv := 1
		ElseIf nResto = 1
			nDv := 0
		EndIf
	EndIf

	If    nDV > 9
		If 	!cBanco = BRASIL
			nDV := 0
		EndIf
    EndIf


Return( AllTrim(Str(nDv)) )
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �  Mod11B29 � Autor �                       � Data �         ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Calculo Modulo 11 Base de 2 a 9 para Codigo de Barras      ���
�������������������������������������������������������������������������Ĵ��
���Uso       � CI_F001                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function Mod11B92( cString )

	Local nStr   := Len(cString)
	Local nSoma  := 0
	Local nPeso  := 9
	Local nResto := 0

	While nStr > 0
		nSoma += Val( SubStr( cString, nStr, 1 ) ) * nPeso
		nPeso--
		nPeso := Iif(nPeso < 2, 9, nPeso )
		nStr--
	EndDo

	nResto := Mod(nSoma,11)	//-- Resto da Divisao

	//-- Tratamento do DV "X" na gravacao do E1_NUMBCO
Return( AllTrim(Str(nResto)) )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �F001Imprime� Autor �Fabio Briddi          � Data � Nov/2013 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Impressao de Boleto Bancario grafico conforme laytout no    ���
���          �formato retrato                                             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �F001Imprime( aCedente, aBanco, aSacado, aAvalista, aTitulo )���
�������������������������������������������������������������������������Ĵ��
���Parametros� aCedente:                                                  ���
���          � aBanco:                                                    ���
���          � aSacado:                                                   ���
���          � aAvalista:                                                 ���
���          � oBoleto:                                                   ���
���          � oSetup:                                                    ���
���          � lExistBol:                                                 ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function F001Imprime( aCedente, aBanco, aSacado, aAvalista, aTitulo, oBoleto, oSetup, lExistBol, lStart, cTempPath, lBlind )

	Local cPixel      := "-1"	//-- Espessura da linha de Bordas em pixels
	Local cCnpjCor    := ""
	Local cInstrucoes := ""
	Local cMsg1Pag    := ""
	Local cMsg2Pag    := ""
	Local nLinha, x   := 0
	Local nLinIni     := 0000	//-- Linha Inicial do Quadro
	Local nColIni     := 0000	//-- Coluna Inicial do Quadro
	Local lBox        := .T.
	Local lNoBox      := .F.

	oArial06   := TFontEx():New(oBoleto,"Arial"      ,06,06,.F.,.T.,.F.)
	oArial06n  := TFontEx():New(oBoleto,"Arial"      ,06,06,.T.,.T.,.F.)
	oArial08   := TFontEx():New(oBoleto,"Arial"      ,08,08,.T.,.T.,.F.)
	oArial09   := TFontEx():New(oBoleto,"Arial"      ,09,09,.F.,.T.,.F.)
	oArial10   := TFontEx():New(oBoleto,"Arial"      ,10,10,.F.,.T.,.F.)
	oArial13   := TFontEx():New(oBoleto,"Arial"      ,13,13,.F.,.T.,.F.)
	oArial13n  := TFontEx():New(oBoleto,"Arial"      ,13,13,.T.,.T.,.F.)
	oArial14n  := TFontEx():New(oBoleto,"Arial"      ,14,14,.T.,.T.,.F.)
	oCourier10 := TFontEx():New(oBoleto,"Courier New",10,10,.T.,.T.,.F.)
	oCourier08 := TFontEx():New(oBoleto,"Courier New",08,08,.T.,.T.,.F.)

	oBoleto:StartPage()   		// Inicia uma nova p�gina

	nLinBar   :=  000						//-- Linha Inicial do Codigo de Barras
	nLinIni   :=  000						//-- Linha Inicial do Quadro
	nColIni   :=  000						//-- Coluna Inicial do Quadro
	cBCO_NUMBCO:= aBanco[BCO_NUMBCO]	//Paola - 10/06/2015 - faixa
	cBCO_NOMBCO:= aBanco[BCO_NOMBCO] 	// Paola - 10/06/2015 - faixa

	cInstrucoes := STRBOL018

	//aBanco[BCO_NUMBCO] = SAFRA    .Or.;
	If		aBanco[BCO_NUMBCO] = REDASSET .Or.;
			aBanco[BCO_NUMBCO] = FIBRA    .Or.;
			aBanco[BCO_NUMBCO] = BBM

		cInstrucoes := STRBOL034

		If	aBanco[BCO_CARTEIR] = "09" .Or. aBanco[BCO_CARTEIR] = "19"			//-- COBRANCA CORRESPONDENTE BRADESCO


			cBCO_NUMBCO:= aBanco[BCO_BCOCOR]  //  aBanco[BCO_NUMBCO]  := aBanco[BCO_BCOCOR] -Paola - 10/06/2015 - faixa
			cBCO_NOMBCO:= aBanco[BCO_NOMCOR] // aBanco[BCO_NOMBCO]  := aBanco[BCO_NOMCOR]   -Paola - 10/06/2015 - faixa

			//-- Mensagem inclu�da no boleto banco Safra correspondente Bradesco, conforme solicita��o do pr�prio banco
			cMsg1Pag := "ESTE BOLETO REPRESENTA DUPLICATA CEDIDA FIDUCIARIAMENTE AO " + AllTrim(aBanco[BCO_NOMBCO]) + ", FICANDO"
			cMsg2Pag := "VEDADO O PAGAMENTO DE QUALQUER OUTRA FORMA QUE n�o ATRAV�S DO PRESENTE BOLETO"

		EndIf

	EndIf

	If		( aBanco[BCO_NUMBCO] = ABC .And. aBanco[BCO_CARTEIR] = "109") .Or. aBanco[BCO_NUMBCO] = VOTORANTIM

			//cInstrucoes := STRBOL034
			cInstrucoes := "Instru��es (Todas as Informa��es deste bloqueto sao de EXCLUSIVA responsabilidade do Sacador/Avalista)"

			cBCO_NUMBCO:= aBanco[BCO_BCOCOR] // aBanco[BCO_NUMBCO]  := aBanco[BCO_BCOCOR] -Paola - 10/06/2015 - faixa
 			cBCO_NOMBCO:= aBanco[BCO_NOMCOR]// aBanco[BCO_NOMBCO]  := aBanco[BCO_NOMCOR] - Paola - 10/06/2015 - faixa

	EndIf

	cCnpjCor := " " + If( !Empty(aBanco[BCO_BCOCOR]), aAvalista[AVA_CNPJ], aCedente[CED_CNPJ] )

//	For nImp := 1 To 2
	aCampos := {}
	//-- Recibo do Pagador
	//-- aCampos  { Linha Inicial, Coluna Inicial, Linha Final, Coluna Final, Box, Nome Campo, Conteudo Campo, Fonte Conteudo, alinhamento, ajuste Linha}
	aAdd(aCampos, {-015, 493, 000, 605, lNoBox, STRBOL000, STRBOL030            , oArial08:oFont,  1, 0  }) //-- "" # "Recibo do Pagador"

	aAdd(aCampos, { 000, 060, 015, 200, lNoBox, STRBOL000, cBCO_NOMBCO   , oArial13:oFont,  0, 0  }) //-- "" #   // aBanco[BCO_NOMBCO]   -Paola - 10/06/2015
	aAdd(aCampos, { 000, 200, 015, 260, lNoBox, STRBOL000, aBanco[BCO_BCOFORM]  , oArial14n:oFont, 1, 0  }) //-- "" #
	aAdd(aCampos, { 000, 260, 015, 600, lNoBox, STRBOL000, aTitulo[TIT_LINDIG]  , oArial13n:oFont, 0, 0  })

	aAdd(aCampos, { 015, 000, 032, 320, lBox  , STRBOL003, STRBOL000            , oArial09:oFont,  0, 06 }) //-- "Benefici�rio"
	aAdd(aCampos, { 015, 000, 032, 230, lNoBox, STRBOL003, aCedente[CED_NOME]   , oArial09:oFont,  0, 06 }) //-- "Benefici�rio"
    If !aBanco[BCO_NUMBCO] $ BANRISUL
		aAdd(aCampos, { 015, 230, 032, 320, lNoBox, STRBOL004, aCedente[CED_CNPJ]   , oArial09:oFont,  0, 06 }) //-- "CNPJ/CPF"
    Endif
	aAdd(aCampos, { 015, 320, 032, 495, lBox  , STRBOL027, Left(aAvalista[AVA_NOME],20) + cCnpjCor  , oArial09:oFont,  0, 06 }) //-- "Sacador/Avalista"
	aAdd(aCampos, { 015, 495, 032, 600, lBox  , STRBOL002, aTitulo[TIT_DTVCTO]  , oArial09:oFont,  2, 06 }) //-- "Vencimento"

	aAdd(aCampos, { 032, 000, 049, 600, lBox  , STRBOL029, aCedente[CED_END]    , oArial09:oFont,  0, 06 }) //-- "Endere�o Benefici�rio/Sacador Avalista"

	aAdd(aCampos, { 049, 000, 066, 600, lBox  , STRBOL000, STRBOL000            , oArial09:oFont,  0, 06 }) //-- ""
	aAdd(aCampos, { 049, 000, 066, 300, lNoBox, STRBOL024, aSacado[SAC_NOME]    , oArial09:oFont,  0, 06 }) //-- "Pagador:"
	aAdd(aCampos, { 049, 300, 066, 600, lNoBox, STRBOL025, aSacado[SAC_CNPJ]    , oArial09:oFont,  0, 06 }) //-- "CNPJ/CPF:"

	aAdd(aCampos, { 066, 000, 083, 140, lBox  , STRBOL011, aTitulo[TIT_NNUMFORM], oArial09:oFont,  2, 06 }) //-- "Nosso N�mero"
	aAdd(aCampos, { 066, 140, 083, 200, lBox  , STRBOL013, aBanco[BCO_CARTEIR]  , oArial09:oFont,  2, 06 }) //-- "Carteira"
	aAdd(aCampos, { 066, 200, 083, 250, lBox  , STRBOL014, "R$"                 , oArial09:oFont,  1, 06 }) //-- "Esp�cie"
	aAdd(aCampos, { 066, 250, 083, 360, lBox  , STRBOL015, STRBOL000            , oArial09:oFont,  1, 06 }) //-- "Quantidade"
	aAdd(aCampos, { 066, 360, 083, 485, lBox  , STRBOL016, STRBOL000            , oArial09:oFont,  1, 06 }) //-- "Valor"
	aAdd(aCampos, { 066, 485, 083, 600, lBox  , STRBOL005, aBanco[BCO_AGECTA]   , oArial09:oFont,  2, 06 }) //-- "Ag�ncia/C�digo do Benefici�rio"

	aAdd(aCampos, { 083, 000, 100, 085, lBox  , STRBOL006, aTitulo[TIT_DTPROC]  , oArial09:oFont,  2, 06 }) //-- "Data do Documento"
	aAdd(aCampos, { 083, 085, 100, 225, lBox  , STRBOL007, aTitulo[TIT_NUM]     , oArial09:oFont,  2, 06 }) //-- "N�mero do Documento"
	aAdd(aCampos, { 083, 225, 100, 310, lBox  , STRBOL008, aTitulo[TIT_ESPECIE] , oArial09:oFont,  2, 06 }) //-- "Esp�cie do Documento"
	aAdd(aCampos, { 083, 310, 100, 360, lBox  , STRBOL009, aBanco[BCO_ACEITE]   , oArial09:oFont,  2, 06 }) //-- "Aceite"
	aAdd(aCampos, { 083, 360, 100, 450, lBox  , STRBOL010, aTitulo[TIT_DTPROC]  , oArial09:oFont,  2, 06 }) //-- "Data de Processamento"
	aAdd(aCampos, { 083, 450, 100, 600, lBox  , STRBOL033, F001FormVal(aTitulo[TIT_VALOR]) , oArial09:oFont,  1, 06 }) //-- "Valor do Documento"

	aAdd(aCampos, { 100, 450, 110, 605, lNoBox, STRBOL000, STRBOL032            , oArial08:oFont,  1, 00 }) //-- "" # "autentica��o Mec�nica"

	If lMensRecibo
		//-- Mensagem de recbido
		cMsg1Pag := "NOME DO RECEBEDOR (legivel):____________________________________________________________________________________"
		cMsg2Pag := "ASSINATURA DO RECEBEDOR:______________________________________________DATA DO RECEBIMENTO __________________" 
	
		aAdd(aCampos, { 105, 000, 115, 605, lNoBox, STRBOL000, cMsg1Pag            , oArial09:oFont,  0, 06 }) //-- "Linha 1 Mensagem Pagador"
		aAdd(aCampos, { 130, 000, 140, 605, lNoBox, STRBOL000, cMsg2Pag            , oArial09:oFont,  0, 06 }) //-- "Linha 2 Mensagem Pagador"
	Else

		aAdd(aCampos, { 095, 000, 105, 605, lNoBox, STRBOL000, cMsg1Pag            , oArial09:oFont,  0, 06 }) //-- "Linha 1 Mensagem Pagador"
		aAdd(aCampos, { 105, 000, 115, 605, lNoBox, STRBOL000, cMsg2Pag            , oArial09:oFont,  0, 06 }) //-- "Linha 2 Mensagem Pagador"

	Endif
	//-- Ficha de Compensacao

	aAdd(aCampos, { 100, 450, 110, 605, lNoBox, STRBOL000, STRBOL032            , oArial08:oFont,  1, 00 }) //-- "" # "autentica��o Mec�nica"

	aAdd(aCampos, { 095, 000, 105, 605, lNoBox, STRBOL000, cMsg1Pag            , oArial09:oFont,  0, 06 }) //-- "Linha 1 Mensagem Pagador"
	aAdd(aCampos, { 105, 000, 115, 605, lNoBox, STRBOL000, cMsg2Pag            , oArial09:oFont,  0, 06 }) //-- "Linha 2 Mensagem Pagador"

	// Cria a pasta temporaria se n�o existir, porque a fun��o saybitmap n�o imprime a 2 imagem do systempath do protheus
   	//If !lBlind  //FunName("CI_F001C") .And. !FunName("CI_F001D")
	//	F001TEMP ( @oBoleto )
	//Else
   	//	oBoleto:SayBitmap(  -002,001,"lgbco"+cBCO_NUMBCO+".bmp",060,015, , )//Logotipo Ficha Compensacao
	//EndIf
	F001TEMP ( @oBoleto )

   	//oBoleto:SayBitmap(  128,001,"lgbco"+cBCO_NUMBCO+".bmp",060,015, , )//Logotipo Ficha Compensacao

	aAdd(aCampos, { 155, 060, 040, 200, lNoBox, STRBOL000, cBCO_NOMBCO          , oArial13:oFont,  0, 00 }) //-- "" #   // aBanco[BCO_NOMBCO] - Paola - 10/06/2015
	aAdd(aCampos, { 155, 200, 040, 260, lNoBox, STRBOL000, aBanco[BCO_BCOFORM]  , oArial14n:oFont, 1, 00 }) //-- "" #
	aAdd(aCampos, { 155, 260, 040, 600, lNoBox, STRBOL000, aTitulo[TIT_LINDIG]  , oArial13n:oFont, 0, 00 }) //-- "" #

	aAdd(aCampos, { 170, 000, 195, 450, lBox  , STRBOL001, STRBOL000            , oArial08:oFont,  0, 00 }) //-- "Local Pagamento"
	aAdd(aCampos, { 175, 000, 185, 450, lNoBox, STRBOL000, aTitulo[TIT_LOCPAG,1], oArial08:oFont,  0, 00 }) //-- "Local Pagamento"
	aAdd(aCampos, { 185, 000, 195, 450, lNoBox, STRBOL000, aTitulo[TIT_LOCPAG,2], oArial08:oFont,  0, 00 }) //-- ""
	aAdd(aCampos, { 170, 450, 195, 600, lBox  , STRBOL002, aTitulo[TIT_DTVCTO]  , oArial10:oFont,  2, 08 }) //-- "Vencimento"

    aAdd(aCampos, { 195, 000, 215, 450, lBox  , STRBOL003, STRBOL000            , oArial10:oFont,  0, 08 }) //-- "Benefici�rio/Cedente"

	If !aBanco[BCO_MBCARD]  = "1"
		aAdd(aCampos, { 195, 000, 215, 300, lNoBox, STRBOL003, aCedente[CED_NOME] + "- " + Space(1) + aCedente[CED_END] , oArial10:oFont,  0, 08 }) //-- "Benefici�rio/Cedente"
		aAdd(aCampos, { 195, 300, 215, 450, lNoBox, STRBOL004, aCedente[CED_CNPJ]   , oArial10:oFont,  0, 08 }) //-- "CNPJ/CPF"
		aAdd(aCampos, { 195, 450, 215, 600, lBox  , STRBOL005, aBanco[BCO_AGECTA]   , oArial10:oFont,  2, 08 }) //-- "Ag�ncia/C�digo do Benefici�rio"
    Else

		aAdd(aCampos, { 195, 000, 215, 350, lNoBox, STRBOL003, alltrim(aCedente[CED_NOME])  ,  oCourier10:oFont, 0, 00  }) //-- "Benefici�rio/Cedente"
	   	aAdd(aCampos, { 195, 350, 215, 450, lNoBox, STRBOL004, aCedente[CED_CNPJ]   , oArial10:oFont,  0, 08 }) //-- "CNPJ/CPF"
		aAdd(aCampos, { 195, 450, 215, 600, lBox  , STRBOL005, aBanco[BCO_AGECTA]   , oArial10:oFont,  2, 08 }) //-- "Ag�ncia/C�digo do Benefici�rio"
		aAdd(aCampos, { 202, 000, 215, 600, lNoBox, STRBOL000, alltrim(aCedente[CED_END])   ,  oCourier10:oFont, 0, 00  })


   Endif
	aAdd(aCampos, { 215, 000, 235, 100, lBox  , STRBOL006, aTitulo[TIT_DTEMI]   , oArial10:oFont,  2, 08 }) //-- "Data Documento"
	aAdd(aCampos, { 215, 100, 235, 250, lBox  , STRBOL007, aTitulo[TIT_NUM]     , oArial10:oFont,  2, 08 }) //-- "N�mero do Documento"
	aAdd(aCampos, { 215, 250, 235, 315, lBox  , STRBOL008, aTitulo[TIT_ESPECIE] , oArial10:oFont,  2, 08 }) //-- "Esp�cie Documento"
	aAdd(aCampos, { 215, 315, 235, 375, lBox  , STRBOL009, aBanco[BCO_ACEITE]   , oArial10:oFont,  2, 08 }) //-- "Aceite"
	aAdd(aCampos, { 215, 375, 235, 450, lBox  , STRBOL010, aTitulo[TIT_DTPROC]  , oArial10:oFont,  2, 08 }) //-- "Data Processamento"
	aAdd(aCampos, { 215, 450, 235, 600, lBox  , STRBOL011, aTitulo[TIT_NNUMFORM], oArial10:oFont,  2, 08 }) //-- "Nosso N�mero"
	aAdd(aCampos, { 235, 000, 255, 100, lBox  , STRBOL012, aBanco[BCO_USOBCO]   , oArial10:oFont,  0, 08 }) //-- "Uso do Banco"
	If aBanco[BCO_MBCARD]  = "1"
		aAdd(aCampos, { 235, 100, 255, 150, lBox  , "CIP", "000"                    , oArial10:oFont,  2, 08 }) //-- "Carteira"
		aAdd(aCampos, { 235, 150, 255, 200, lBox  , STRBOL013, aBanco[BCO_CARTEIR]  , oArial10:oFont,  2, 08 }) //-- "Carteira"
	Else
		aAdd(aCampos, { 235, 100, 255, 200, lBox  , STRBOL013, aBanco[BCO_CARTEIR]  , oArial10:oFont,  2, 08 }) //-- "Carteira"
	Endif
	aAdd(aCampos, { 235, 200, 255, 255, lBox  , STRBOL014, "R$"                 , oArial10:oFont,  2, 08 }) //-- "Esp�cie"
	aAdd(aCampos, { 235, 255, 255, 315, lBox  , STRBOL015, STRBOL000            , oArial10:oFont,  1, 08 }) //-- "Quantidade"
	aAdd(aCampos, { 235, 315, 255, 450, lBox  , STRBOL016, STRBOL000            , oArial10:oFont,  1, 08 }) //-- "Valor"
	aAdd(aCampos, { 235, 450, 255, 600, lBox  , STRBOL017, F001FormVal(aTitulo[TIT_VALOR])   , oArial10:oFont,  1, 08 }) //-- "(=) Valor Documento"

    If !aBanco[BCO_MBCARD] = "1"
		aAdd(aCampos, { 255, 000, 355, 450, lBox  , cInstrucoes, STRBOL000            , oArial10:oFont,   0, 05 }) //-- "Instru��es" // Somente Monta o Quadro Maior
		aAdd(aCampos, { 260, 000, 285, 450, lNoBox, STRBOL000, aTitulo[TIT_MSGS][1] , oCourier08:oFont, 0, 00 }) //-- Linha 1 Mensagem Boleto
		aAdd(aCampos, { 270, 000, 280, 450, lNoBox, STRBOL000, aTitulo[TIT_MSGS][2] , oCourier08:oFont, 0, 00 }) //-- Linha 2 Mensagem Boleto
		aAdd(aCampos, { 280, 000, 290, 450, lNoBox, STRBOL000, aTitulo[TIT_MSGS][3] , oCourier08:oFont, 0, 00 }) //-- Linha 3 Mensagem Boleto
		aAdd(aCampos, { 290, 000, 300, 450, lNoBox, STRBOL000, aTitulo[TIT_MSGS][4] , oCourier08:oFont, 0, 00 }) //-- Linha 4 Mensagem Boleto
		aAdd(aCampos, { 300, 000, 310, 450, lNoBox, STRBOL000, aTitulo[TIT_MSGS][5] , oCourier08:oFont, 0, 00 }) //-- Linha 5 Mensagem Boleto
		aAdd(aCampos, { 310, 000, 320, 450, lNoBox, STRBOL000, aTitulo[TIT_MSGS][6] , oCourier08:oFont, 0, 00 }) //-- Linha 6 Mensagem Boleto
		aAdd(aCampos, { 320, 000, 330, 450, lNoBox, STRBOL000, aTitulo[TIT_MSGS][7] , oCourier08:oFont, 0, 00 }) //-- Linha 7 Mensagem Boleto
		aAdd(aCampos, { 330, 000, 340, 450, lNoBox, STRBOL000, aTitulo[TIT_MSGS][8] , oCourier08:oFont, 0, 00 }) //-- Linha 8 Mensagem Boleto
		aAdd(aCampos, { 340, 000, 350, 450, lNoBox, STRBOL000, aTitulo[TIT_MSGS][9] , oCourier08:oFont, 0, 00 }) //-- Linha 9 Mensagem Boleto

    Else

		dbSelectArea("SEE")
		dbSetOrder(1)	//-- EE_FILIAL+EE_CODIGO+EE_AGENCIA+EE_CONTA+EE_SUBCTA
		dbSeek( xFilial("SEE") + cBanco + cAgencia + cConta + cSubCta )


	    aAdd(aCampos, { 255, 000, 355, 450, lBox  , cInstrucoes, STRBOL000            , oArial10:oFont,   0, 05 }) //-- "Instru��es" // Somente Monta o Quadro Maior
		aAdd(aCampos, { 260, 000, 285, 450, lNoBox, STRBOL000, aTitulo[TIT_MSGS][1] , oCourier08:oFont, 0, 00 }) //-- Linha 1 Mensagem Boleto
		aAdd(aCampos, { 270, 000, 280, 450, lNoBox, STRBOL000, aTitulo[TIT_MSGS][2] , oCourier08:oFont, 0, 00 }) //-- Linha 2 Mensagem Boleto
		aAdd(aCampos, { 280, 000, 290, 450, lNoBox, STRBOL000, aTitulo[TIT_MSGS][3] , oCourier08:oFont, 0, 00 }) //-- Linha 3 Mensagem Boleto
		aAdd(aCampos, { 290, 000, 300, 450, lNoBox, STRBOL000, aTitulo[TIT_MSGS][4] , oCourier08:oFont, 0, 00 }) //-- Linha 4 Mensagem Boleto
		aAdd(aCampos, { 300, 000, 310, 450, lNoBox, STRBOL000, aTitulo[TIT_MSGS][5] , oCourier08:oFont, 0, 00 }) //-- Linha 5 Mensagem Boleto
		aAdd(aCampos, { 310, 000, 320, 450, lNoBox, STRBOL000, aTitulo[TIT_MSGS][6] , oCourier08:oFont, 0, 00 }) //-- Linha 6 Mensagem Boleto
		If !Empty(SEE->EE_FORMBC1)
			aAdd(aCampos, { 320, 000, 330, 450, lNoBox, STRBOL000, &(Alltrim(SEE->EE_FORMBC1)), oCourier08:oFont, 0, 00 }) //-- Linha 7 Mensagem Boleto
        Endif

		If !Empty(SEE->EE_FORMBC2)
			aAdd(aCampos, { 330, 000, 340, 450, lNoBox, STRBOL000, &(Alltrim(SEE->EE_FORMBC2)), oCourier08:oFont, 0, 00 }) //-- Linha 7 Mensagem Boleto
        Endif


		If !Empty(SEE->EE_FORMBC3)
			aAdd(aCampos, { 340, 000, 350, 450, lNoBox, STRBOL000, &(Alltrim(SEE->EE_FORMBC3)), oCourier08:oFont, 0, 00 }) //-- Linha 7 Mensagem Boleto
        Endif

    Endif
	aAdd(aCampos, { 255, 450, 275, 600, lBox  , STRBOL019, STRBOL000            , oArial10:oFont,   1, 08 }) //-- "(-) Descontos/Abatimentos"
	aAdd(aCampos, { 275, 450, 295, 600, lBox  , STRBOL020, STRBOL000            , oArial10:oFont,   1, 08 }) //-- "(-) Outras Dedu��es"
	aAdd(aCampos, { 295, 450, 315, 600, lBox  , STRBOL021, STRBOL000            , oArial10:oFont,   1, 08 }) //-- "(+) Multa/Mora"
	aAdd(aCampos, { 315, 450, 335, 600, lBox  , STRBOL022, STRBOL000            , oArial10:oFont,   1, 08 }) //-- "(+) Outros Acr�scimos"
	aAdd(aCampos, { 335, 450, 355, 600, lBox  , STRBOL023, STRBOL000            , oArial10:oFont,   1, 08 }) //-- "(=) Valor Cobrado"

	aAdd(aCampos, { 355, 000, 400, 600, lBox  , STRBOL000, STRBOL000            , oArial10:oFont,   0, 08 }) //-- ""
	aAdd(aCampos, { 355, 000, 370, 300, lNoBox, STRBOL024, aSacado[SAC_NOME]    , oArial10:oFont,   0, 05 }) //-- "Pagador:"
	aAdd(aCampos, { 355, 300, 370, 450, lNoBox, STRBOL025, aSacado[SAC_CNPJ]    , oArial10:oFont,   0, 05 }) //-- "CNPJ/CPF:"
	aAdd(aCampos, { 370, 000, 385, 600, lNoBox, STRBOL026, aSacado[SAC_END]     , oArial10:oFont,   0, 05 }) //-- "Endere�o:"
	aAdd(aCampos, { 385, 000, 400, 300, lNoBox, STRBOL027, aAvalista[AVA_NOME]  , oArial10:oFont,   0, 05 }) //-- "Sacador/Avalista:"
	aAdd(aCampos, { 385, 300, 400, 450, lNoBox, STRBOL025, aAvalista[AVA_CNPJ]  , oArial10:oFont,   0, 05 }) //-- "CNPJ/CPF:"
	aAdd(aCampos, { 385, 450, 400, 600, lNoBox, STRBOL028, STRBOL000            , oArial10:oFont,   0, 05 }) //-- "C�digo de Baixa:"
	aAdd(aCampos, { 400, 420, 415, 605, lNoBox, STRBOL000, STRBOL031            , oArial06n:oFont,  1, 00 }) //-- "" # "autentica��o Mec�nica / FICHA DE COMPENSA��O"

	For nLinha := 1 To Len(aCampos)

		// Jeferson Silva - Desloca a segunda parte do boleto mais para baixo em 0030 pontos
		//If	aCampos[nLinha,1] = 155 .And. aCampos[nLinha,2] = 060
		//	nLinIni += 0030 
		//	nLinBar += 0030
		//EndIf
		
		If	aCampos[nLinha,5] //-- Se executa o Box
			oBoleto:Box( nLinIni+aCampos[nLinha,1], nColIni+aCampos[nLinha,2], nLinIni+aCampos[nLinha,3],nColIni+aCampos[nLinha,4], cPixel)
		EndIf

		//�������������������������������������������������������Ŀ
		//� Impressao do Rotulo                                   �
		//���������������������������������������������������������
		oBoleto:Say( nLinIni+aCampos[nLinha,1]+005, nColIni+aCampos[nLinha,2]+003, aCampos[nLinha,6], oArial06:oFont)

		//�������������������������������������������������������Ŀ
		//�Para conteudo dos campos utilizado SayAlign()          �
		//�para Alinhamentos a Direita de Valores e Centralizados �
		//���������������������������������������������������������
		nLI      := nLinIni+(aCampos[nLinha,1]+aCampos[nLinha,10])
		nCI      := nColIni+(aCampos[nLinha,2]+03)
		nLF      := nLinIni+aCampos[nLinha,3]
		nCF      := nColIni+(aCampos[nLinha,4]-05)
		nLargura := ((nCF - nCI) - 5)
		nAltura  := (nLF - nLI)

		oBoleto:SayAlign( nLI, nCI, aCampos[nLinha,7], aCampos[nLinha,8] , nLargura, nAltura, , aCampos[nLinha,9], 1 )

	Next nLinha

	//�������������������������������������������������������Ŀ
	//� Marcacao  do Picote                                   �
	//���������������������������������������������������������
    For x := nColIni To nColIni+600 Step 10
		//If !lMensRecibo
			oBoleto:Line(  nLinIni+140, x ,  nLinIni+140, x + 5, 0 , cPixel )
		//Endif
		oBoleto:Line(  nLinIni+450, x ,  nLinIni+450, x + 5, 0 , cPixel )
	Next x

 	//oBoleto:SayBitmap( -002,001,"lgbco"+cBCO_NUMBCO+".bmp",060,015, , )//Logotipo Recibo do Pagador  // aBanco[BCO_NUMBCO] - Paola - 10/06/2015
	//oBoleto:SayBitmap(  128,001,"lgbco"+cBCO_NUMBCO+".bmp",060,015, , )//Logotipo Ficha Compensacao


	oBoleto:FwMsBar( "INT25", nLinBar+034, nColIni, aTitulo[TIT_CODBAR], oBoleto, .F., , , ,1.0, , , , .F. )

	nLinBar += 039	//-- Linha Inicial do Quadro
	nLinIni += 460	//-- Linha Inicial do Quadro

	lExistBol := .T.

//	Next nImp

	oBoleto:EndPage() //-- Finaliza a p�gina

Return()

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �F001IniImp � Autor � Fabio Briddi         � Data � Nov/2013 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Inicializa Objetos de Impressao e de Setup de Impressao    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� @oBoleto - Objeto de Impressao do Boleto                   ���
���          � @oSetup  - Objeto comas as Configuracoes de Impressao      ���
���          � lExistBol-                                                 ���
���          � lBlind   - Controla se a rotina esta sendo chamada via WS  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � lRet  - .T. se Confirmado o Dialogo de Configuracao        ���
���          �         .F. se Cancelado o Dialogo de Configuracao         ���
�������������������������������������������������������������������������Ĵ��
���Uso       � CI_F001                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function F001IniImp( oBoleto, oSetup, lExistBol, lBlind, aBanco, aTitulo, aSacado )

	Local lRet       := .T.
	Local cFilePrint := "BOLETO_"+DTOS(MsDate())+StrTran(Time(),":","")+strtran(alltrim(str(seconds() )),".","")
	Local aDevice    := {}
	Local cSession   := GetPrinterSession()

	If lBlind
		Public cNomArq := cFilePrint
	EndIf

	//IATAN EM 27/08/2022
	IF IsInCallStack("U_GERADANFE") .OR. IsInCallStack("U_GRDANFE2") 
		cFilePrint := SF2->F2_CHVNFE
	ENDIF	

	aAdd(aDevice,"DISCO") // 1
	aAdd(aDevice,"SPOOL") // 2
	aAdd(aDevice,"EMAIL") // 3
	aAdd(aDevice,"EXCEL") // 4
	aAdd(aDevice,"HTML" ) // 5
	aAdd(aDevice,"PDF"  ) // 6

	nLocal       	:= If(GetProfString(cSession,"LOCAL","SERVER",.T.)=="SERVER",1,2 )
	nOrientation 	:= If(GetProfString(cSession,"ORIENTATION","PORTRAIT",.T.)=="PORTRAIT",1,2)
	cDevice	     	:= GetProfString(cSession,"PRINTTYPE","SPOOL",.T.)
	nPrintType      := aScan(aDevice,{|x| x == cDevice })
	cPathInServer   := "\spool\"

	lAdjustToLegacy := .F.
	lDisableSetup   := .T.
	lViewPDF        := !(lBlind)	//--	.T. Apresenta Preview / .F. Nao Apresenta
	lPdfAsPng       := .T.		//--	.T. Pdf

	If oBoleto == Nil

		//IATAN EM 27/08/2022
		IF IsInCallStack("U_GERADANFE") .OR. IsInCallStack("U_GRDANFE2") 
			//ALTERADO IATAN
			oBoleto := FWMSPrinter():New( cFilePrint , IMP_PDF,         .F., "\pdf_wms\boleto\", .T., .F., , , .T., .T., , .F.)
		ELSE
			//PADRAO CI
			oBoleto := FWMSPrinter():New( cFilePrint , IMP_PDF , lAdjustToLegacy , cPathInServer , lDisableSetup , , , , lPdfAsPng , , , lViewPDF )
		ENDIF

		//IATAN EM 27/8/2022
		If !lBlind .AND. !IsInCallStack("U_GERADANFE") .AND. !IsInCallStack("U_GRDANFE2") // Se nao estiver sendo chamado via Web Service
		//If !lBlind// Se nao estiver sendo chamado via Web Service

			// ----------------------------------------------
			// Cria e exibe tela de Setup Customizavel
			// OBS: Utilizar include "FWPrintSetup.ch"
			// ----------------------------------------------
			nFlags := PD_ISTOTVSPRINTER + PD_DISABLEPAPERSIZE + PD_DISABLEPREVIEW + PD_DISABLEMARGIN
			oSetup := FWPrintSetup():New( nFlags , cFilePrint )

			// ----------------------------------------------
			// Define saida
			// ----------------------------------------------
			oSetup:SetPropert(PD_PRINTTYPE   , nPrintType)
			oSetup:SetPropert(PD_ORIENTATION , nOrientation)
			oSetup:SetPropert(PD_DESTINATION , nLocal)
			oSetup:SetPropert(PD_MARGIN      , {60,60,60,60})
			oSetup:SetPropert(PD_PAPERSIZE   , 2)

			// ----------------------------------------------
			// Pressionado bot�o OK na tela de Setup
			// ----------------------------------------------
			If oSetup:Activate() == PD_OK // PD_OK =1
				//�������������������������������������������Ŀ
				//�Salva os Parametros no Profile             �
				//���������������������������������������������
		        WriteProfString( cSession, "LOCAL"      , If(oSetup:GetProperty(PD_DESTINATION)==1 ,"SERVER"    ,"CLIENT"    ), .T. )
		        WriteProfString( cSession, "PRINTTYPE"  , If(oSetup:GetProperty(PD_PRINTTYPE)==1   ,"SPOOL"     ,"PDF"       ), .T. )
		        WriteProfString( cSession, "ORIENTATION", If(oSetup:GetProperty(PD_ORIENTATION)==1 ,"PORTRAIT"  ,"LANDSCAPE" ), .T. )

				If oSetup:GetProperty(PD_ORIENTATION) == 2

					MsgInfo("Use Orienta��o Retrato")
					lRet := .F.

				EndIf

			Else

				MsgInfo("RelAT�rio cancelado pelo usu�rio.")
				lRet := .F.

			EndIf

		EndIf

		If	lRet

			// Ordem obrigatoria de configuracao do relatorio
			oBoleto:SetResolution(78) //Tamanho estipulado para o Boleto
			oBoleto:SetPortrait()
			oBoleto:SetPaperSize(DMPAPER_A4)
			oBoleto:SetMargin(60,60,60,60)

			//IATAN EM 27/8/2022
			If !lBlind .AND. !IsInCallStack("U_GERADANFE") .AND. !IsInCallStack("U_GRDANFE2") // Se nao estiver sendo chamado via Web Service
			//If !lBlind// Se nao estiver sendo chamado via Web Service

				// ----------------------------------------------
				// Define saida de impress�o
				// ----------------------------------------------

				If	oSetup:GetProperty(PD_PRINTTYPE) = IMP_SPOOL

					oBoleto:nDevice := IMP_SPOOL
					// ----------------------------------------------
					// Salva impressora selecionada
					// ----------------------------------------------
					fwWriteProfString(GetPrinterSession(),"DEFAULT", oSetup:aOptions[PD_VALUETYPE], .T.)
					oBoleto:cPrinter := oSetup:aOptions[PD_VALUETYPE]

				ElseIf oSetup:GetProperty(PD_PRINTTYPE) = IMP_PDF

					oBoleto:nDevice := IMP_PDF
					// ----------------------------------------------
					// Define para salvar o PDF
					// ----------------------------------------------
					oBoleto:cPathPDF := oSetup:aOptions[PD_VALUETYPE]

				EndIf

			Else

				oBoleto:nDevice := IMP_PDF
				// ----------------------------------------------
				// Define para salvar o PDF
				// ----------------------------------------------

				cTempPath   := IIf( IsBlind(), "\boletos\tmp\", GetTempPath())
				cBolPath    := "\boletos\"

				If	!File( cBolPath+"." )
					MakeDir( cBolPath )
				EndIf

				If	!File( cTempPath+"." )
					MakeDir( cTempPath )
				EndIf

				//IATAN EM 27/08/2022
				IF IsInCallStack("U_GERADANFE") .OR. IsInCallStack("U_GRDANFE2") 
					oBoleto:cPathPDF := "\pdf_wms\boleto\"
				ELSE 
					oBoleto:cPathPDF := cTempPath //--"\portal_licenciado\boletos\"
				ENDIF

			EndIf

		EndIf
	EndIf

	lIniImp := .T.

Return( lRet )

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � MenuDef  � Autor � Fabio Briddi          � Data � Nov/2013 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Definicao de Menu Funcional Especifico da Rotina           ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � aRotina - Array com as Opcoes da Rotina                    ���
���          � 1. Nome que aparecera nas Acoes Relacionadas               ���
���          � 2. Nome da Rotina associada                                ���
���          � 3. Reservado                                               ���
���          � 4. Tipo de Transacao a ser efetuada:                       ���
���          �    1 - Pesquisa e Posiciona em um Banco de Dados           ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          � 5. Nivel de acesso                                         ���
���          � 6. Habilita Menu Funcional                                 ���
�������������������������������������������������������������������������Ĵ��
���Uso       � CI_F001 - Programa Principal                               ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()

	Local aRotina := {}

	aAdd(aRotina,{"Pesquisar"   ,"AxPesqui"   ,0 ,1 })
	aAdd(aRotina,{"Visualizar"  ,"AxVisual"   ,0 ,2 })
	aAdd(aRotina,{"Impr. Boleto","U_CI_F001B" ,0 ,3 })

Return(aRotina)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � F001AjSx1 � Autor � Fabio Briddi         � Data � Nov/2013 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Verifica e Cria Grupo de Perguntas SX1 se necessario       ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � cPerg - nome do Grupo de Perguntas                         ���
�������������������������������������������������������������������������Ĵ��
���Uso       � CI_F001                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function F001AjSx1( )

	Local cPerg  := PadR("CI_F001",Len(SX1->X1_GRUPO))
	Local aP     := {}
	Local nI     := 0
	Local cSeq   := ""
	Local cMvCh  := ""
	Local cMvPar := ""
	Local aHelp  := {}

	//--      Texto Pergunta         , Tipo                   , Tam                    , Dec          , G=Get/C=Combo, Val,       F3,                 Def01,              Def02,        Def03, Def04, Def05
	aAdd(aP,{ "C�digo Banco:"        , TamSX3("EE_CODIGO")[3] , TamSX3("EE_CODIGO")[1] , TamSX3("EE_CODIGO")[2] , "G",  "", "SEEBOL",                    "",                 "",           "",    "",    "" })
	aAdd(aP,{ "C�digo Ag�ncia:"      , TamSX3("EE_AGENCIA")[3], TamSX3("EE_AGENCIA")[1], TamSX3("EE_AGENCIA")[2], "G",  "",       "",                    "",                 "",           "",    "",    "" })
	aAdd(aP,{ "C�digo Conta:"        , TamSX3("EE_CONTA")[3]  , TamSX3("EE_CONTA")[1]  , TamSX3("EE_CONTA")[2]  , "G",  "",       "",                    "",                 "",           "",    "",    "" })
	aAdd(aP,{ "C�digo Sub-Conta:"    , TamSX3("EE_SUBCTA")[3] , TamSX3("EE_SUBCTA")[1] , TamSX3("EE_SUBCTA")[2] , "G",  "",       "",                    "",                 "",           "",    "",    "" })
	aAdd(aP,{ "Gerar Boleto:"        , "N"                    , 1                      , 0                      , "C",  "",       "",   "Reg Posicionado  ","Cons Par Abaixo  ",           "",    "",    "" })
	aAdd(aP,{ "Do Prefixo:"          , TamSX3("E1_PREFIXO")[3], TamSX3("E1_PREFIXO")[1], TamSX3("E1_PREFIXO")[2], "G",  "",       "",                    "",                 "",           "",    "",    "" })
	aAdd(aP,{ "At� Prefixo:"         , TamSX3("E1_PREFIXO")[3], TamSX3("E1_PREFIXO")[1], TamSX3("E1_PREFIXO")[2], "G",  "",       "",                    "",                 "",           "",    "",    "" })
	aAdd(aP,{ "Do t�tulo:"           , TamSX3("E1_NUM")[3]    , TamSX3("E1_NUM")[1]    , TamSX3("E1_NUM")[2]    , "G",  "",       "",                    "",                 "",           "",    "",    "" })
	aAdd(aP,{ "At� t�tulo:"          , TamSX3("E1_NUM")[3]    , TamSX3("E1_NUM")[1]    , TamSX3("E1_NUM")[2]    , "G",  "",       "",                    "",                 "",           "",    "",    "" })
	aAdd(aP,{ "Do Parcela:"          , TamSX3("E1_PARCELA")[3], TamSX3("E1_PARCELA")[1], TamSX3("E1_PARCELA")[2], "G",  "",       "",                    "",                 "",           "",    "",    "" })
	aAdd(aP,{ "At� Parcel:"          , TamSX3("E1_PARCELA")[3], TamSX3("E1_PARCELA")[1], TamSX3("E1_PARCELA")[2], "G",  "",       "",                    "",                 "",           "",    "",    "" })
	aAdd(aP,{ "Do Tipo:"             , TamSX3("E1_TIPO")[3]   , TamSX3("E1_TIPO")[1]   , TamSX3("E1_TIPO")[2]   , "G",  "",       "",                    "",                 "",           "",    "",    "" })
	aAdd(aP,{ "At� Tipo:"            , TamSX3("E1_TIPO")[3]   , TamSX3("E1_TIPO")[1]   , TamSX3("E1_TIPO")[2]   , "G",  "",       "",                    "",                 "",           "",    "",    "" })
	aAdd(aP,{ "Da Emiss�o:"          , TamSX3("E1_EMISSAO")[3], TamSX3("E1_EMISSAO")[1], TamSX3("E1_EMISSAO")[2], "G",  "",       "",                    "",                 "",           "",    "",    "" })
	aAdd(aP,{ "At� Emiss�o:"         , TamSX3("E1_EMISSAO")[3], TamSX3("E1_EMISSAO")[1], TamSX3("E1_EMISSAO")[2], "G",  "",       "",                    "",                 "",           "",    "",    "" })
	aAdd(aP,{ "Do Vencimento:"       , TamSX3("E1_VENCREA")[3], TamSX3("E1_VENCREA")[1], TamSX3("E1_VENCREA")[2], "G",  "",       "",                    "",                 "",           "",    "",    "" })
	aAdd(aP,{ "At� Vencimento:"      , TamSX3("E1_VENCREA")[3], TamSX3("E1_VENCREA")[1], TamSX3("E1_VENCREA")[2], "G",  "",       "",                    "",                 "",           "",    "",    "" })
	aAdd(aP,{ "Do Border�:"          , TamSX3("E1_NUMBOR")[3] , TamSX3("E1_NUMBOR")[1] , TamSX3("E1_NUMBOR")[2] , "G",  "",       "",                    "",                 "",           "",    "",    "" })
	aAdd(aP,{ "At� Border�:"         , TamSX3("E1_NUMBOR")[3] , TamSX3("E1_NUMBOR")[1] , TamSX3("E1_NUMBOR")[2] , "G",  "",       "",                    "",                 "",           "",    "",    "" })

	aAdd(aP,{ "Cliente De:"          , TamSX3("A1_COD")[3]	  , TamSX3("A1_COD")[1]    , TamSX3("A1_COD")[2]    , "G",  "",    "SA1",                    "",                 "",           "",    "",    "" })
	aAdd(aP,{ "Loja De:"             , TamSX3("A1_LOJA")[3]   , TamSX3("A1_LOJA")[1]   , TamSX3("A1_LOJA")[2]   , "G",  "",       "",                    "",                 "",           "",    "",    "" })
	aAdd(aP,{ "Cliente At�:"         , TamSX3("A1_COD")[3]    , TamSX3("A1_COD")[1]    , TamSX3("A1_COD")[2]    , "G",  "",    "SA1",                    "",                 "",           "",    "",    "" })
	aAdd(aP,{ "Loja At�:"            , TamSX3("A1_LOJA")[3]   , TamSX3("A1_LOJA")[1]   , TamSX3("A1_LOJA")[2]   , "G",  "",       "",                    "",                 "",           "",    "",    "" })

	aAdd(aP,{ "Gerar PDF:"           , "N"                    , 1                      , 0                      , "C",  "",       "",       "Arquivo �nico",       "P/ Cliente",  "P/ t�tulo",    "",    "" })
	aAdd(aP,{ "Envia E-mail:"        , "N"                    , 1                      , 0                      , "C",  "",       "",                 "n�o",              "Sim",           "",    "",    "" })

	If lForma
		aAdd(aP,{ "Forma Pagto:"      , TamSX3("E1_FORMA")[3]  , 30  , TamSX3("E1_FORMA")[2]  , "G",  "",       "",                    "",                 "",           "",    "",    "" })
	EndIf

	If lSegundaVia
		aAdd(aP,{ "Segunda Via?"      , "N"						  , 1								, 0							 , "C",  "",       "",                  "n�o",              "Sim",           "",    "",    "" })
	Endif


	 //           123456789123456789012345678901234567890
    //                   1         2         3         4
	aAdd(aHelp,{"Selecione o C�digo do Banco que ser�    ","usado para a gera��o do Boleto.         ","Tecla [F3] dispon�vel para consultar o  ",;
				"Cadastro de Bancos e preencher os       ","pr�ximos par�metros 'C�digo da Ag�ncia:'",", 'C�digo da Conta:' e 'C�digo da       ",;
				"Sub-Conta:' automaticamente.            " })
	aAdd(aHelp,{"Informe o C�digo da Ag�ncia que ser�    ","usada na gera��o do Boleto.             " })
	aAdd(aHelp,{"Informe o C�digo da Conta que ser�      ","usada na gera��o do Boleto.             " })
	aAdd(aHelp,{"Informe o C�digo da Sub-Conta que ser�  ","usada na gera��o do Boleto.             " })
	aAdd(aHelp,{"Informe 'Reg Posicionado' se deseja     ","gerar apenas o Titulo em destaque no    ","no Browse ou Informe os par�metros      ",;
				"abaixo com os dados dos t�tulos para a  ","setle��o no Contas a Receber.            " })
	aAdd(aHelp,{"Informe o prefixo inicial do intervalo  ","de prefixos a serem considerados para a ","a gera��o de Boletos                    " })
	aAdd(aHelp,{"Informe o prefixo final do intervalo de ","prefixos a serem considerados para a    ","gera��o de Boletos                      " })
	aAdd(aHelp,{"Informe o t�tulo inicial do intervalo   ","de t�tulos a serem considerados para a  ","gera��o de Boletos                      " })
	aAdd(aHelp,{"Informe o t�tulo final do intervalo de  ","t�tulos a serem considerados para a     ","gera��o de Boletos                      " })
	aAdd(aHelp,{"Informe o Parcela inicial do intervalo  ","de parcelas a serem considerados para a ","gera��o de Boletos                      " })
	aAdd(aHelp,{"Informe o Parcela final do intervalo de ","parcelas a serem considerados para a    ","gera��o de Boletos                      " })
	aAdd(aHelp,{"Informe o Tipo de t�tulo inicial do     ","intervalo de tipos de t�tulo a ser      ","considerado para a gera��o de Boletos.  ",;
				"Tecla <F3> dispon�vel para consulta a   ","tabela de tipos de t�tulos.             " })
	aAdd(aHelp,{"Informe o Tipo de t�tulo final do       ","intervalo de tipos de t�tulo a ser      ","considerado para a gera��o de Boletos.  ",;
				"Tecla <F3> dispon�vel para consulta a   ","tabela de tipos de t�tulos.             " })
	aAdd(aHelp,{"Informe Data Inicial do intervalo de    ","Datas de Emiss�o a serem considerados   ",;
				"para a gera��o de Boletos.              ","Bot�o 'Calend�rio' dispon�vel           " })
	aAdd(aHelp,{"Informe Data Final do intervalo de Datas","de Emiss�o a serem considerados para a  ",;
				"gera��o de Boletos.                     ","Bot�o 'Calend�rio' dispon�vel           " })
	aAdd(aHelp,{"Informe Data Inicial do intervalo de    ","Datas de Vencimento a serem considerados ",;
				"para a gera��o de Boletos.              ","Bot�o 'Calend�rio' dispon�vel           " })
	aAdd(aHelp,{"Informe Data Final do intervalo de Datas","de Vencimento a serem considerados para ",;
				"a gera��o de Boletos.                   ","Bot�o 'Calend�rio' dispon�vel           " })
	aAdd(aHelp,{"Informe C�digo inicial do intervalo de  ","border�s a serem considerados para a    ","gera��o de Boletos                      " })
	aAdd(aHelp,{"Informe C�digo final do intervalo de    ","border�s serem considerados para a      ","gera��o de Boletos                      " })
	aAdd(aHelp,{"Informe C�digo inicial do cliente       "})
	aAdd(aHelp,{"Informe C�digo inicial da loja			 "})
	aAdd(aHelp,{"Informe C�digo final do cliente         "})
	aAdd(aHelp,{"Informe C�digo final da loja   	     "})

	aAdd(aHelp,{"Informe se como deseja que seja gerado o","arquivo PDF:                            ",;
				"1-�nico                                 ","2-Cliente + Loja                        ","3-Cliente+Loja+Prefixo+N�mero T�titulo  "})
	aAdd(aHelp,{"Informe se ser� o Boleto ser� enviado   ","para o e-mail cadastrado para o Cliente ","Ap�s a gera��o                          ",;
				"Obs.:                                   ",;
				"Os Boletos devem ser impressos em:      ","'PDF p/ Cliente' ou 'PDF p/ Boletos'    ","para serem enviados por email.          ",;
				"                                        ",;
				"O Texto do email dever� estar na        ","Pasta: \protheus_data\modelos_html\     ","Arquivo Padr�o: CI_f001_mod1.html       "})
	If lForma
		aAdd(aHelp,{"Informe a forma de pagamento     "})
	EndIf

	If lSegundaVia
		aAdd(aHelp,{"Informe se ser� impress�o de segunda via do boleto."})
	EndIf

	For nI := 1 To Len(aP)

		cSeq	:= StrZero(nI,2,0)
		cMvPar	:= "mv_par"+cSeq
		cMvCh	:= "mv_ch"+IIF(nI<=9,Chr(nI+48),Chr(nI+87))

		PutSx1(	cPerg,;							//-- cGrupo
				cSeq,;							//-- cOrdem
				aP[nI,01],aP[nI,01],aP[nI,01],;	//-- cPergunt,cPerSpa,cPerEng
				cMvCh,;							//-- cVar
				aP[nI,02],;						//-- cTipo
				aP[nI,03],;						//-- nTamanho
				aP[nI,04],;						//-- Decimal
				0,;								//-- nPreSel
				aP[nI,05],;						//-- cGSC
				aP[nI,06],;						//-- cValid
				aP[nI,07],;						//-- cF3
				"",;							//-- cGrpSXG
				"",;							//-- cPyme
				cMvPar,;						//-- cVar01
				aP[nI,08],aP[nI,08],aP[nI,08],;	//-- cDef01,cDefSpa1,cDefEng1
				"",;							//-- cCnt01
				aP[nI,09],aP[nI,09],aP[nI,09],;	//-- cDef02,cDefSpa2,cDefEng2
				aP[nI,10],aP[nI,10],aP[nI,10],;	//-- cDef03,cDefSpa3,cDefEng3
				aP[nI,11],aP[nI,11],aP[nI,11],;	//-- cDef04,cDefSpa4,cDefEng4
				aP[nI,12],aP[nI,12],aP[nI,12],;	//-- cDef05,cDefSpa5,cDefEng5
				aHelp[nI],;						//-- aHelpPor
				{},;							//-- aHelpEng
				{},;							//-- aHelpSpa
				"")								//-- cHelp

	Next nI

	//����������������������������������������������������������������������Ŀ
	//� Verifica e Compatibiliza a Consulta Padrao dos Parametros dos Bancos �
	//� Primeiro Verifica se o SX1->X1_F3 esta com o SEEBOL                  �
	//� Segundo Verifica se Existe a Consulta Padrao SEEBOL no SXB           �
	//������������������������������������������������������������������������

	dbSelectArea("SX1")
	dbSetOrder(1)
	If	dbSeek(cPerg+"01")
		If	SX1->X1_F3 <> "SEEBOL"
			RecLock("SX1",.F.)
				SX1->X1_F3 := "SEEBOL"
			MsUnLock()
		EndIf
	EndIf

	dbSelectArea("SXB")
	dbSetOrder(1)
	If !dbSeek("SEEBOL")
		F001AjSxb()
	EndIf

Return( cPerg )

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � F001AjSxb � Autor � Fabio Briddi         � Data � Jan/2014 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Cria Consulta Padrao (SXB)                                 ���
���          � Consulta: SEEBOL - Parametros de Bancos p/ Impr. Boletos   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Uso       � CI_F001                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function F001AjSxb()

	Local cConPad := "SEEBOL"
	Local aConPad := {}
	Local nInd    := 0

	//--            XB_ALIAS, XB_TIPO, XB_SEQ, XB_COLUNA, XB_DESCRI, XB_DESCSPA, XB_DESCENG, XB_CONTEM
	aAdd( aConPad, { cConPad, "1", "01", "DB", "Bancos / Par�metros" , "Bancos / Par�metros" , "Bancos / Par�metros" , "SEE"            } )
	aAdd( aConPad, { cConPad, "2", "01", "01", "Banco + Agencia + Co", "Banco + Agencia + Cu", "Bank + Bank Office +", ""               } )
	aAdd( aConPad, { cConPad, "4", "01", "01", "Banco"               , "Banco"               , "Bank"                , "EE_CODIGO"      } )
	aAdd( aConPad, { cConPad, "4", "01", "02", "Agencia"             , "Agencia"             , "Bank Office"         , "EE_AGENCIA"     } )
	aAdd( aConPad, { cConPad, "4", "01", "03", "Conta"               , "Cuenta"              , "C. Account"          , "EE_CONTA"       } )
	aAdd( aConPad, { cConPad, "4", "01", "04", "Sub Conta"           , "Subcuenta"           , "Sub Account"         , "EE_SUBCTA"      } )
	aAdd( aConPad, { cConPad, "4", "01", "05", "Operacao"            , "Operacion"           , "Operation"           , "EE_OPER"        } )
	aAdd( aConPad, { cConPad, "5", "01", ""  , ""                    , ""                    , ""                    , "SEE->EE_CODIGO" } )
	aAdd( aConPad, { cConPad, "5", "02", ""  , ""                    , ""                    , ""                    , "SEE->EE_AGENCIA"} )
	aAdd( aConPad, { cConPad, "5", "03", ""  , ""                    , ""                    , ""                    , "SEE->EE_CONTA"  } )
	aAdd( aConPad, { cConPad, "5", "04", ""  , ""                    , ""                    , ""                    , "SEE->EE_SUBCTA" } )

	For nInd := 1 To Len(aConPad)

		RecLock("SXB",.T.)
			SXB->XB_ALIAS   := aConPad[nInd,1]
			SXB->XB_TIPO    := aConPad[nInd,2]
			SXB->XB_SEQ     := aConPad[nInd,3]
			SXB->XB_COLUNA  := aConPad[nInd,4]
			SXB->XB_DESCRI  := aConPad[nInd,5]
			SXB->XB_DESCSPA := aConPad[nInd,6]
			SXB->XB_DESCENG := aConPad[nInd,7]
			SXB->XB_CONTEM  := aConPad[nInd,8]
		MsUnLock()

	Next nInd

Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � F001Mail � Autor � Fabio Briddi          � Data � Dez/2014 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Gera e-mail apartir de modelo Html                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � F001Email( aCedente, aSacado, aTitMail, cPdf )             ���
�������������������������������������������������������������������������Ĵ��
���Parametros� aCedente - Dados da Empresa/Filial Emitente Boleto         ���
���          � aSacado  - Dados do Devedor do Titulo                      ���
���          � aTitMail - Titulos contidos no Pdf                         ���
���          � cPdf     - Nome do arquivo Pdf para anexar ao e-mail       ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � aRet     - Status Envio                                    ���
���          � aRet[1]  - .T. = Envio Ok  - .F. = Falha Envio             ���
���          � aRet[2]  - Mensagem                                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CI_F001 - Impressao de Boletos Bancarios                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function F001Email( aCedente, aSacado, aTitMail, cPdf )

	Local cHtml     := ""
	Local cModPath  := "\modelos_html\"
	Local cNomeArq  := "CI_f001_Mod1"
	Local cArqMod   := ""
	Local cError    := ""
	Local cBoleto   := ""
	Local aArqMod   := {}
	Local aConteudo := {}
	Local aRet      := {}
	Local lExiste   := .F.
	Local lOK       := .F.
	Local cTitulos  := ""
	Local nInd      := 0
	Local nI        := 0

	aAdd(aArqMod, cModPath + cNomeArq + cEmpAnt + cFilAnt + ".html")
	aAdd(aArqMod, cModPath + cNomeArq + cEmpAnt + ".html")
	aAdd(aArqMod, cModPath + cNomeArq + ".html") //-- Modelo Padr�o

	// Cria a pasta, se n�o existir
	If	!File( cModPath + "." )
		MakeDir( cModPath )
	EndIf

	// Verifica se h� modelos salvos
	For nI := 1 To Len(aArqMod)

		If	File( aArqMod[nI] )
			cArqMod := aArqMod[nI]
			lExiste := .T.
		EndIf

	Next nI

	// Cria um modelo Padr�o, se n�o existir algum modelo salvo
	If !lExiste
		F001ModHtml( aArqMod[3] )
	EndIf

	//��������������������������������������������������������������������Ŀ
	//�Monta a Lista dos Titulos contidos no Pdf                           �
	//����������������������������������������������������������������������
 	cTitulos += "<Table border=2 CELLPADDING=5>"
	cTitulos += " <tr>"
	cTitulos += "  <th> t�tulo  	 </th>"
	cTitulos += "  <th> Vencimento  </th>"
	cTitulos += "  <th> Valor       </th>"
	cTitulos += "  <th> Banco       </th>"
	cTitulos += " </tr>"

	For nInd := 1 To Len(aTitmail)

		cTitulos += " <tr>"
		cTitulos += "  <td> " + aTitMail[nInd,1] + "</td>"
		cTitulos += "  <td> " + aTitMail[nInd,2] + "</td>"
		cTitulos += "  <td> " + aTitMail[nInd,3] + "</td>"
		cTitulos += "  <td> " + aTitMail[nInd,4] + "</td>"
		cTitulos += " </tr>"

		cBoleto += aTitMail[nInd,1] + If( nInd != Len(aTitmail), ", ", "" )

	Next nInd

	cTitulos += "</table><br>"

	//��������������������������������������������������������������������Ŀ
	//�Monta o Array com as Variveis no Html a serem substituidas          �
	//����������������������������������������������������������������������
	aAdd( aConteudo,{ "%cContato%"    , aSacado[SAC_CONTATO] } )
	aAdd( aConteudo,{ "%cNomeSacado%" , aSacado[SAC_NOME]    } )
	aAdd( aConteudo,{ "%cCnpjSacado%" , aSacado[SAC_CNPJ]    } )
	aAdd( aConteudo,{ "%cEmitente%"   , aCedente[CED_NOME]   } )
	aAdd( aConteudo,{ "%cTitulos%"    , cTitulos             } )

	cAssunto := AllTrim(aCedente[CED_NOME]) + " - Boleto cobran�a " + cBoleto

	If File( cArqMod )

		//��������������������������������������������������������������������Ŀ
		//�Le Arquivo Modelo substituindo as macros pelo conteudo das variaveis�
		//����������������������������������������������������������������������
		cHtml  := F001MontaHtml( cArqMod, aConteudo )
		cEmail := aSacado[SAC_EMAIL]

		//��������������������������������������������������������������������Ŀ
		//�Envia o Email apos a montagem                                       �
		//����������������������������������������������������������������������
		aRet  := F001EnviaMail( cHTML, cEmail, cAssunto, cPdf )

	Else

		cError := "- Arquivo modelo n�o encontrado. " + CRLF
		cError += "Caminho: " + cArqMod + CRLF
		aRet:= {.F. , cError}

	Endif

Return( aRet )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � F001MontaHtml � Autor � Fabio Briddi     � Data � Dez/2014 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Insere informacoes no Arquivo HTML                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � F001MontaHtml( cExp1, aExp1 )                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cExp1 - Caminho do Arquivo modelo HTML                     ���
���          � aExp1 - Variavel com o conteudo a ser apendada             ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � cHtml - String HTML modificada                             ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CI_F001 - Impressao de Boletos Bancarios                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function F001MontaHtml( cArqMod, aConteudo, cPdf )

	Local nA        := 0
	Local cHtml     := ""
	Local cLinha    := ""
	Local cLinhaNew := ""

	FT_FUse(cArqMod)
	FT_FGOTOP()

	Do While !FT_FEOF()

		cLinha := FT_FREADLN()

		nAchou := AT('%',cLinha)// Verifica se a Linha Tem Campo a Substituir

		If nAchou > 0

			For nA := 1 To Len(aConteudo)

				nAchou := AT(Upper(aConteudo[nA,1]),Upper(cLinha))
				cLinhaNew := ""

				If nAchou > 0
					cLinhaNew := Substr(cLinha,1,nAchou-1)
					cLinhaNew += aConteudo[nA,2]
					cLinhaNew += Substr(cLinha,nAchou+Len(aConteudo[nA,1]))
					cLinha    := cLinhaNew
				Endif

			Next

		Endif

		cHtml += cLinha
		FT_FSKIP()

	EndDo

Return( cHtml )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao  � A040EnviaMail � Autor � Jeferson Dambros � Data � 16/10/2014 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Gera o arquivo HTML e  envia o e-mail com a liberacao      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A040GeraEmail( cExp1, cExp2 )                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cExp1 -  Tabela posicionada                                ���
���          � cExp2 -  endereco de e-mail                                ���
���          � cExp3 -  Indica a tabela que esta sendo utilizada          ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico Cliente S.C Internacional                       ���
�������������������������������������������������������������������������Ĵ��
���                          ULTIMAS ALTERACOES                           ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � Motivo da Alteracao                             ���
�������������������������������������������������������������������������Ĵ��
���            �        �                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function F001EnviaMail( cHTML, cTo, cSubject, cPdf )

	Local cError     := ""
	Local cMsg       := ""
	Local lOK        := .F.
	Local lMsgError  := .T.
	Local lAuth      := GetMv( "MV_RELAUTH" )
	Local cServer    := GetMv( "MV_RELSERV" )
	Local cAccount   := GetMv( "MV_RELACNT" )
	Local cPassword  := GetMv( "MV_RELPSW"  )
	Local aFiles     := { cPdf }

	// conectando-se com o servidor de e-mail
	CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lResult

		// Fazendo autenticacao
		If lResult .And. lAuth

			lResult := MailAuth( cAccount,cPassword )
			If !lResult

				If lMsgError// Erro na conexao com o SMTP Server

					GET MAIL ERROR cError
					cMsg += "- Erro na autentica��o da conta do e-mail. " + cError + CRLF
					lOK:= .F.

				EndIf

			EndIf

		Else

			If !lResult

				If lMsgError//Erro na conexao com o SMTP Server

					GET MAIL ERROR cError
					cMsg += "- Erro de conex�o com servidor SMTP. " + cError + CRLF
					lOK:= .F.

				EndIf

			EndIf

		EndIf

		If !lResult

			GET MAIL ERROR cError
			cMsg += "- Erro ao conectar a conta de e-mail. " + cError
			lOK:= .F.

		Else

			SEND MAIL FROM cAccount TO cTo SUBJECT cSubject BODY cHTML ATTACHMENT aFiles[1] RESULT lResult

			If !lResult

				GET MAIL ERROR cError
				cMsg := "- Erro no Envio do e-mail. " + cError + CRLF
				lOK  := .F.

			EndIf

			lOK := .T.

		EndIf

		DISCONNECT SMTP SERVER

Return( {lOK, cMsg} )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � F001ModHtml   � Autor � Fabio Briddi     � Data � Dez/2014 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Insere informacoes no Arquivo HTML                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � F001ModHtml( cExp1, aExp1 )                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cExp1 - Caminho do Arquivo modelo HTML                     ���
���          � aExp1 - Variavel com o conteudo a ser apendada             ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � cHtml - String HTML modificada                             ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CI_F001 - Impressao de Boletos Bancarios                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function F001ModHtml( cArqMod )

	Local cHtml := ''

	cHtml += ' <!DOCTYPE HTML> ' + CRLF
	cHtml += ' <html> ' + CRLF
	cHtml += ' 	<body> ' + CRLF
	cHtml += ' 	<style type="text/css"> ' + CRLF
	cHtml += ' 	body{ ' + CRLF
	cHtml += ' 		  font-family: Arial Narrow;	 ' + CRLF
	cHtml += ' 		  font-size: 16	   ' + CRLF
	cHtml += ' 		} ' + CRLF
	cHtml += ' 	p{ ' + CRLF
	cHtml += ' 	  font-family: Arial Narrow; ' + CRLF
	cHtml += ' 	  line-height:100%; ' + CRLF
	cHtml += ' 	  white-space: pre-line ' + CRLF
	cHtml += ' 	 } ' + CRLF
	cHtml += ' 	 span{ ' + CRLF
	cHtml += ' 	  font-family: Arial Narrow ' + CRLF
	cHtml += ' 		 } ' + CRLF
	cHtml += ' 	  ' + CRLF
	cHtml += ' 	<!-- ' + CRLF
	cHtml += ' 	</span><img src="http://downloads.empresamodelo.com.br/header_empresa_modelo.jpg" height="76" width="588"><br> ' + CRLF
	cHtml += ' 	--> ' + CRLF
	cHtml += '  ' + CRLF
	cHtml += ' 	</style><span style="font-weight: bold;"><br><br> ' + CRLF
	cHtml += ' 	Prezado(a) %cContato%:</span><br> ' + CRLF
	cHtml += ' 	<p> ' + CRLF
	cHtml += ' 	Segue em anexo o(s) boletos(s) banc�rio(s) enviados pelo emitente %cEmitente%, conforme detalhados abaixo: ' + CRLF
	cHtml += ' 	</p> ' + CRLF
	cHtml += ' 		Sacado: %cNomeSacado% <br> ' + CRLF
	cHtml += ' 		CNPJ: %cCnpjSacado%<br> ' + CRLF
	cHtml += ' 	</p> ' + CRLF
	cHtml += ' 	%cTitulos% ' + CRLF
	cHtml += ' 	</p> ' + CRLF
	cHtml += ' 	</p> ' + CRLF
	cHtml += ' 	</p> ' + CRLF

	cHtml += ' 	<span style="font-weight: bold;"> ' + CRLF
	cHtml += ' 	Em caso de d�vidas ou altera��es no cadastro, entre em contato com nosso departamento financeiro: ' + CRLF
	cHtml += ' 	<br> ' + CRLF
	cHtml += ' 	<span style="font-weight: bold;"; color: rgb(51, 102, 255);"> ' + CRLF
	cHtml += ' 	Telefone: (51) 9999-9999<br> ' + CRLF
	cHtml += ' 	financeiro@empresamodelo.com.br<br> ' + CRLF
	cHtml += ' 	<a href="http://www.empresamodelo.com.br" target="_blank">www.empresamodelo.com.br</a><br> ' + CRLF
	cHtml += ' 	<p> ' + CRLF
	cHtml += ' 	Atenciosamente,<br> ' + CRLF
	cHtml += ' 	%cEmitente% ' + CRLF

	cHtml += ' 	<!-- ' + CRLF
	cHtml += ' 	</span><img src="http://downloads.empresamodelo.com.br/footer_empresa_modelo.jpg" height="76" width="588"><br> ' + CRLF
	cHtml += ' 	--> ' + CRLF

	cHtml += ' 	</span> ' + CRLF
	cHtml += ' 	</body> ' + CRLF
	cHtml += ' </html> ' + CRLF

	MemoWrite( cArqMod, cHtml  )

	alert(cHtml)

Return( )

/*
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
*/

Static Function F001FormVal( nValor )

	cVlrFornat	:= TransForm( nValor, PICT_VALOR )

Return( cVlrFornat )

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �SumAbatRec� Autor � Wagner Xavier         � Data � 23/03/93 ���
�������������������������������������������������������������������������Ĵ��
���Adpatacao �SumAbatRec� Analis� Fabio Briddi          � Data � Dez/2014 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Soma titulos de abatimento relacionado a um determinado titu���
���          �lo a receber                                                ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �SumAbatRec()                                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Prefixo,Numero,Parcela,Moeda,Saldo ou Valor                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �CI_F001                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function SumAbatRec( cPrefixo, cNumero, cParcela, nMoeda, cCpo, dData, nTotAbImp, nTotIrAbt, nTotCsAbt, nTotPisAbt, nTotCofAbt, nTotInsAbt, nTotIssAbt, nTotTitAbt )

	Local cAlias   := Alias()
	Local nTotAbat := 0
	Local nRec     := RecNo()
	Local cCliLj   := ""
	Local lPccBxCr		:= FPccBxCr()

	cFilAbat       := xFilial("SE1")
	dData  := IIf( dData  == Nil , dDataBase, dData)
	nMoeda := IIf( nMoeda == Nil , 1, nMoeda)

	cCampo := IIf( cCpo == "V", "E1_VALOR" , "E1_SALDO" )

	cCliLj := SE1->(E1_CLIENTE+E1_LOJA)

	If Select("__SE1") == 0
		ChkFile("SE1",.F.,"__SE1")
	Else
		dbSelectArea("__SE1")
	EndIf


	dbSetOrder( 1 )
	dbSeek( cFilAbat + cPrefixo + cNumero + cParcela )

	While	!Eof()					.And.;
			E1_FILIAL  == cFilAbat	.And.;
			E1_PREFIXO == cPrefixo	.And.;
			E1_NUM     == cNumero	.And.;
			E1_PARCELA == cParcela

			If E1_CLIENTE+E1_LOJA == cCliLj
				If E1_TIPO $ MVABATIM+"/"+MVIRABT+"/"+MVINABT+"/"+MVCSABT+"/"+MVCFABT+"/"+MVPIABT
					nTotAbat+=xMoeda(&cCampo.,E1_MOEDA, nMoeda,dData)
				EndIf
			  	If E1_TIPO $ MVIRABT+"/"+MVINABT+"/"+MVCSABT+"/"+MVCFABT+"/"+MVPIABT+"/"+MVISABT+"/"+MVFUABT
					nTotAbImp +=xMoeda(&cCampo,E1_MOEDA, nMoeda,dData)
				EndIf
				//--	Irrf
				If E1_TIPO $ MVIRABT .And. E1_TIPO $ MVABATIM
					nTotIrAbt +=xMoeda(&cCampo,E1_MOEDA, nMoeda,dData)
				EndIf
				//--	Csll
				If E1_TIPO $ MVCSABT .And. E1_TIPO $ MVABATIM
					nTotCsAbt +=xMoeda(&cCampo,E1_MOEDA, nMoeda,dData)
				EndIf
				//--	PIS
				If E1_TIPO $ MVPIABT .And. E1_TIPO $ MVABATIM
					nTotPisAbt +=xMoeda(&cCampo,E1_MOEDA, nMoeda,dData)
				EndIf
				//--	COFINS
				If E1_TIPO $ MVCFABT .And. E1_TIPO $ MVABATIM
					nTotCofAbt +=xMoeda(&cCampo,E1_MOEDA, nMoeda,dData)
				EndIf
				//--	INSS
				If E1_TIPO $ MVINABT .And. E1_TIPO $ MVABATIM
					nTotInsAbt +=xMoeda(&cCampo,E1_MOEDA, nMoeda,dData)
				EndIf

				//--	ISS
				If E1_TIPO $ MVISABT .And. E1_TIPO $ MVABATIM
					nTotIssAbt +=xMoeda(&cCampo,E1_MOEDA, nMoeda,dData)
				EndIf

				//--	AB-
				If E1_TIPO $ "AB-" .And. E1_TIPO $ MVABATIM
					nTotTitAbt +=xMoeda(&cCampo,E1_MOEDA, nMoeda,dData)
				EndIf

			EndIf

			dbSkip()

	EndDo

	dbSelectArea( cAlias )
	dbGoTo(nRec)

    IF lPccBxCr	    // PCC na baixa
       nTotAbat+= xMoeda(SE1->E1_PIS+SE1->E1_COFINS+SE1->E1_CSLL,SE1->E1_MOEDA,nMoeda,dData)
	   nTotCsAbt :=xMoeda(SE1->E1_CSLL,SE1->E1_MOEDA, nMoeda,dData)
	   nTotPisAbt:=xMoeda(SE1->E1_PIS, SE1->E1_MOEDA, nMoeda,dData)
       nTotCofAbt:=xMoeda(SE1->E1_COFINS,SE1->E1_MOEDA, nMoeda,dData)
	EndIf
Return (NoRound(nTotAbat))

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �F001ValImp� Autor �Giovanni Melo          � Data �27/02/2015���
�������������������������������������������������������������������������Ĵ��
���Descricao �Valida a reimpressao do boleto                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �F001ValImp(aTitulo, aBanco)                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�aTitulo                                                     ���
���          �aBanco                                                      ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �lImprime                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function F001ValImp(aTitulo, aBanco)

	Local lImprime := .F.

	dbSelectArea("SE1")
	SE1->(dbGoTo(aTitulo[TIT_RECSE1]))

	If Empty(SE1->E1_PORTADO) .And. Empty(SE1->E1_NUMBCO)
		lImprime := .T.
	Else
		If aBanco[BCO_NUMBCO] = AllTrim(SE1->E1_PORTADO)
			lImprime := .T.
		EndIf
	EndIf

Return(lImprime)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �F001TEMP  � Autor � Paola                 � Data �08/07/2015���
�������������������������������������������������������������������������Ĵ��
���Descricao �Copia logo para pasta temporaria                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �F001TEMP ( @Boleto )                                        ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpO01 - Objeto de impressao                                ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function F001TEMP ( oBoleto )

	Local clogo	:= ""
	Local nX		:= 0
	Local cTempPath   := IIf( IsBlind(), "\boletos\bmp", GetTempPath())
	Local aTemp	:= { cTempPath, cTempPath+"\bmp\" }
	Local aLinha	:= { -002, 153 }

   	cLogo := "lgbco"+cBCO_NUMBCO+".bmp"

	For nX	:= 1 to Len(aTemp)

		If	!File( aTemp[nX] + "." )
			MakeDir( aTemp[nX] )
		EndIf

		__CopyFile( "\system\" + clogo, aTemp[nX] + cLOGO )

		oBoleto:SayBitmap( aLinha[nX],001, aTemp[nX] + cLOGO ,060,015)//Logotipo Ficha Compensacao

	Next nX

Return ( Nil )

/*
|============================================================================|
|============================================================================|
|||-----------+----------+-------+-----------------------+------+----------|||
||| Funcao    |BCCLI  | Autor | Samuel Schneider      | Data |13/11/2018   |||
|||-----------+----------+-------+-----------------------+------+----------|||
||| Descricao | Monta Joins para Query para regra de um  cliente           |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   | BCCLI()                                                    |||
|||-----------+------------------------------------------------------------|||
||| Parametros| tipo = 'INNER'                                             |||
|||-----------+------------------------------------------------------------|||
||| Retorno   | 								                           |||
|||-----------+------------------------------------------------------------|||
|============================================================================|
|============================================================================|*/
Static Function BCCLI(cTipo)
	Local cRet := ""

	If cTipo == 'INNER'

		cRet := " INNER JOIN "+RetSqlName("SEE")+" SEE ON "+ CRLF
		cRet += " SEE.EE_FILIAL = '"+xFilial("SEE")+"'    "+ CRLF
		cRet += " AND SEE.EE_CODIGO = SA1.A1_BCO1         "+ CRLF
		cRet += " AND SEE.D_E_L_E_T_ <> '*'               "+ CRLF

	EndIf


Return cRet


