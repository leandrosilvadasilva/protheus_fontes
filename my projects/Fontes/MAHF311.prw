#Include 'rwmake.ch'

/*
�����������������������������������������������������������������������������
���ADAPTADO  �MAHF311   �Autor  �Marcelo Tarasconi   � Data �  29/11/2008 ���
���Programa  �MAHF311   �Autor  �Marcelo Tarasconi   � Data �  05/04/2007 ���
�������������������������������������������������������������������������͹��
���Descricao �Funcao para declarar variaveis contadoras para cnab a pagar ���
�������������������������������������������������������������������������͹��
���Uso       � MP 12                                                      ���
�����������������������������������������������������������������������������
*/

User Function MAHF311()

If SE2->E2_NUMBOR <> __cNumBor //J� estou no proximo bordero //Var Public que sabe qual bordero anterior
   __cNumbor := SE2->E2_NUMBOR
   __cNum := StrZERO((Val(__cNum)+1),4)
EndIf

Return(__cNum)