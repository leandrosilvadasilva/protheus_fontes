#include 'protheus.ch'
#Include 'rwmake.ch'



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � MA030BUT � Autor � Ednei Silva  � Data �        13/02/2019 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Criar botao no cadastro de cliente 			              ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico Cliente                                         ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/



User Function MA030BUT()

Local aBtn 		:= Array(0)
Local cFunName  := FunName()
Local aArea 	:= GetArea()
Local aAreaSA1  := SA1->(GetArea())



//If cFunName $ 'MATA450/MATA450A' .and. ParamIxb[1] == 2 //somente adiciono botao se for chamado na rotina de credito
IF !INCLUI .AND. !ALTERA
	
	Aadd(aBtn,{"BUDGET", {|| U_MAH0200() },"Hist. Cliente"})//Visualiza tabela Z80 - Historico de Cliente
    
ENDIF
//EndIf



RestArea(aAreaSA1)
RestArea(aArea)
Return(aBtn)
