#Include 'rwmake.ch'

/*
�����������������������������������������������������������������������������
���ADAPTADO  �MAHF312   �Autor  �Marcelo Tarasconi   � Data �  29/11/2008 ���
���Programa  �MAHF312   �Autor  �Marcelo Tarasconi   � Data �  12/04/2007 ���
�������������������������������������������������������������������������͹��
���Descricao �Funcao para declarar variaveis contadoras para cnab a pagar ���
�������������������������������������������������������������������������͹��
���Uso       � MP 12                                                      ���
�����������������������������������������������������������������������������
*/

User Function MAHF312()

__cLinhas := StrZERO((Val(__cLinhas)+1),6) //Contador de linhas do arquivo

Return('1')