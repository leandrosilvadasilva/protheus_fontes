#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#include 'Totvs.ch'
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � MT100GE2    � Autor � Ednei Silva	    � Data �14/03/2018���
�������������������������������������������������������������������������Ĵ��
���Descricao � Monta uma tela para Informar o Motivo da Devolucao         ���
���          � 									                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MAHOPITALAR / Faturamento                                  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � Motivo da Alteracao                             ���
�������������������������������������������������������������������������Ĵ��
���            �        �                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
#define DS_MODALFRAME   128

User Function MT100AG()
Local 	nLinha	  := 010
Local 	lEdita	  := .F.
Local 	oCodDev
Local 	oDescDev
Local 	aArea     := GetArea()
Local 	aAreaSE2  := SE2->(GetArea())
Local 	aAreaSD1  := SD1->(GetArea())
Local 	aAreaSF1  := SF1->(GetArea())
Private cCodDev	  := SPACE(4)
Private cDesDev	  := SPACE(50)
Private oDlg01
Private lGrava	  := .F.

IF ISINCALLSTACK("U_DEVOLUCAO") .OR. ISINCALLSTACK("U_DEV2")
	RETURN
ENDIF

IF SF1->F1_TIPO = 'D'

Define MsDialog oDlg01 Title "Motivo da Devolucao"  From 000,000 To 250, 730 Pixel Style DS_MODALFRAME

@ nLinha + 002, 010 Say OemToAnsi("Motivo Devolucao") Of oDlg01 Pixel
//	@ nLinha, 055 MsGet oTransp Var cTransp of oDlg01  Pixel F3 "Z40" Valid (Vazio() .or. A010ValTrp(cTransp))
@ nLinha, 055 MsGet oCodDev  Var cCodDev of oDlg01  Pixel F3 "Z40" Valid (Vazio() .or. A010ValMot(cCodDev))
@ nLinha, 100 MsGet oDescDev Var cDesDev of oDlg01  Pixel When lEdita  Size 261, 012
nLinha += 018

@ 080, 330 Button 'Ok'		Size 030,015 Of oDlg01 Pixel Action (Grava())
//	@ nLinha, 290 Button 'Cancelar'	Size 030,015 Of oDlg01 Pixel Action ( oDlg01:End(), lgrava:= .F. )

@ 110 + 002, 010 Say OemToAnsi("* � obrigat�rio informar o motivo de devolu��o para este tipo de documento") Of oDlg01 Pixel


Activate MsDialog oDlg01 Centered

ENDIF

RestArea(aAreaSE2)
RestArea(aAreaSD1)
RestArea(aAreaSF1)
RestArea(aArea)
Return(.T.)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � A010ValMot � Autor �   Ednei Silva    	� Data �14/03/2018���
�������������������������������������������������������������������������Ĵ��
���Descricao �Valida��o do Motivo		                                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �  A010ValMot()                                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� _cMotivo - Motivo da Devolucao			                  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �                                                            ���
���          �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function A010ValMot(_cMotivo)

lRet := .T.

If !Empty(_cMotivo)
	
	DbSelectArea("Z40")
	DbSetOrder(1)
	
	If	DbSeek(xFilial("Z40")+_cMotivo)
		cDesDev  := Z40->Z40_DESCRI
		lGrava   := .T.
	Else
		
		Aviso("AVISO","Motivo de Devoluc�o n�o cadastrada!", { "Sair" }, 2)
		lRet := .F.
		
	EndIf
	
EndIf

Return(lRet)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � Grava � Autor �   Ednei Silva    		� Data �15/03/2018���
�������������������������������������������������������������������������Ĵ��
���Descricao �Grava o motivo de devolucao no cabecalho da nota			  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �  Grava()         	                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros� 											                  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �                                                            ���
���          �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Grava()

If	lGrava
	RecLock('SF1',.F.)
	   SF1->F1_ZMOTDEV := cCodDev
	   SF1->F1_ZDESMOT := cDesDev
	SF1->(MsUnlock())
	
	MsgInfo("Dados gravados com sucesso!","Informa��o!")
	oDlg01:End()
Else
	MsgInfo("Selecione um motivo de devolucao!","Informa��o!")
EndIf

Return ()




