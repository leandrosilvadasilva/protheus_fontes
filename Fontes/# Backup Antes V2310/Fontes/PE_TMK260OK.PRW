/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �U_TMK260OK� Autor � Expedito Mendonca Jr  � Data �15/05/2015���
�������������������������������������������������������������������������Ĵ��
���Descricao � Ponto de entrada de validacao do cadastro de prospects.    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � U_TMK260OK()                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � NIL                                                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���                          ULTIMAS ALTERACOES                           ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � Motivo da Alteracao                             ���
�������������������������������������������������������������������������Ĵ��
���            �        �                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������*/
User Function TMK260OK()
Local cAreaAnt := alias()
Local aAreaSA1 := SA1->(GetArea())
Local lRet := .T.      

If !Empty(M->US_CGC)
	dbSelectArea("SA1")
	dbSetOrder(3)		// A1_FILIAL+A1_CGC
	If dbSeek( xFilial("SA1")+M->US_CGC , .F. )
		lRet := .F.
		Alert("Empresa j� se encontra cadastrada no cadastro de clientes. C�digo: "+SA1->A1_COD+" Loja: "+SA1->A1_LOJA+" CNPJ: "+SA1->A1_CGC+" Nome: "+Alltrim(SA1->A1_NOME)+". Se desejar cadastrar uma nova filial deste cliente, cadastrar esta filial diretamente no cadastro de clientes.")
	Else
		If dbSeek( xFilial("SA1")+SubStr(M->US_CGC,1,8) , .F. )
			lRet := .F.
			Alert("Outra filial desta empresa ja se encontra cadastrada no cadastro de clientes. C�digo: "+SA1->A1_COD+" Loja: "+SA1->A1_LOJA+" CNPJ: "+SA1->A1_CGC+" Nome: "+Alltrim(SA1->A1_NOME)+". Cadastrar esta filial diretamente no cadastro de clientes.")
		Endif	
	Endif
Endif	

// Restaura o ambiente
Restarea(aAreaSA1)
dbSelectArea(cAreaAnt)	

Return lRet